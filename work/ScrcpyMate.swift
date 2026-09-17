import SwiftUI
import AppKit

struct Device: Identifiable, Hashable {
    let id: String
    let label: String
}

enum AudioMode: String, CaseIterable, Identifiable {
    case phone = "手机系统声音 → 电脑"
    case duplicate = "手机和电脑同时播放"
    case microphone = "手机麦克风 → 电脑"
    case silent = "静音"
    var id: String { rawValue }
}

@MainActor
final class AppModel: ObservableObject {
    @Published var devices: [Device] = []
    @Published var selectedDevice = ""
    @Published var audioMode: AudioMode = .phone
    @Published var width = "自动"
    @Published var stayAwake = true
    @Published var screenOff = false
    @Published var alwaysOnTop = false
    @Published var wifiAddress = ""
    @Published var remotePath = "/sdcard/Download/"
    @Published var status = "正在查找手机…"
    @Published var running = false
    @Published var log = ""

    private var mirrorProcess: Process?
    private let adb = AppModel.findExecutable("adb")
    private let scrcpy = AppModel.findExecutable("scrcpy")

    init() { refreshDevices() }

    static func findExecutable(_ name: String) -> String? {
        ["/opt/homebrew/bin/\(name)", "/usr/local/bin/\(name)", "/usr/bin/\(name)"].first {
            FileManager.default.isExecutableFile(atPath: $0)
        }
    }

    func refreshDevices() {
        guard let adb else { status = "找不到 adb，请先安装 scrcpy"; return }
        Task.detached {
            let result = Self.runSync(adb, ["devices", "-l"])
            let parsed = result.output.split(separator: "\n").dropFirst().compactMap { line -> Device? in
                let text = String(line)
                guard text.contains("\tdevice") else { return nil }
                let serial = text.split(separator: "\t").first.map(String.init) ?? ""
                let model = text.split(separator: " ").first(where: { $0.hasPrefix("model:") })
                    .map { String($0.dropFirst(6)).replacingOccurrences(of: "_", with: " ") }
                return Device(id: serial, label: model.map { "\($0)  ·  \(serial)" } ?? serial)
            }
            await MainActor.run {
                self.devices = parsed
                if !parsed.contains(where: { $0.id == self.selectedDevice }) {
                    self.selectedDevice = parsed.first?.id ?? ""
                }
                self.status = parsed.isEmpty ? "未找到设备，请连接 USB 并允许调试" : "已找到 \(parsed.count) 台设备"
            }
        }
    }

    func connectWiFi() {
        let address = wifiAddress.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !address.isEmpty, let adb else { status = "请输入手机 IP 地址"; return }
        Task.detached {
            let result = Self.runSync(adb, ["connect", address.contains(":") ? address : "\(address):5555"])
            await MainActor.run {
                self.status = result.output.trimmingCharacters(in: .whitespacesAndNewlines)
                self.refreshDevices()
            }
        }
    }

    func toggleMirror() {
        if running { stopMirror(); return }
        guard let scrcpy else { status = "找不到 scrcpy，请先安装：brew install scrcpy"; return }
        guard !selectedDevice.isEmpty else { status = "请先连接并选择手机"; return }

        var args = ["--serial", selectedDevice, "--window-title", "手机 · Scrcpy Mate"]
        switch audioMode {
        case .phone: args += ["--audio-source=output"]
        case .duplicate: args += ["--audio-source=playback", "--audio-dup"]
        case .microphone: args += ["--audio-source=mic"]
        case .silent: args += ["--no-audio"]
        }
        if width != "自动" { args += ["--max-size", width] }
        if stayAwake { args += ["--stay-awake"] }
        if screenOff { args += ["--turn-screen-off"] }
        if alwaysOnTop { args += ["--always-on-top"] }

        let process = Process()
        let pipe = Pipe()
        process.executableURL = URL(fileURLWithPath: scrcpy)
        process.arguments = args
        process.standardOutput = pipe
        process.standardError = pipe
        pipe.fileHandleForReading.readabilityHandler = { [weak self] handle in
            let data = handle.availableData
            guard !data.isEmpty, let text = String(data: data, encoding: .utf8) else { return }
            Task { @MainActor in
                self?.log = String(((self?.log ?? "") + text).suffix(5000))
            }
        }
        process.terminationHandler = { [weak self] _ in
            Task { @MainActor in
                self?.running = false
                self?.status = "镜像已停止"
                pipe.fileHandleForReading.readabilityHandler = nil
            }
        }
        do {
            try process.run()
            mirrorProcess = process
            running = true
            status = "镜像运行中；直接拖动窗口边缘即可缩放"
        } catch {
            status = "启动失败：\(error.localizedDescription)"
        }
    }

    func stopMirror() {
        mirrorProcess?.interrupt()
        mirrorProcess = nil
        running = false
        status = "镜像已停止"
    }

    func uploadFiles() {
        guard !selectedDevice.isEmpty, let adb else { status = "请先连接手机"; return }
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = true
        panel.canChooseDirectories = false
        guard panel.runModal() == .OK else { return }
        let urls = panel.urls
        status = "正在上传 \(urls.count) 个文件…"
        Task.detached {
            var messages: [String] = []
            for url in urls {
                let result = Self.runSync(adb, ["-s", self.selectedDevice, "push", url.path, self.remotePath])
                messages.append(result.output)
            }
            await MainActor.run {
                self.log = messages.joined(separator: "\n")
                self.status = "文件已传到 \(self.remotePath)"
            }
        }
    }

    func downloadFile() {
        guard !selectedDevice.isEmpty, let adb else { status = "请先连接手机"; return }
        let alert = NSAlert()
        alert.messageText = "从手机下载"
        alert.informativeText = "输入手机中的完整文件路径"
        let field = NSTextField(string: "/sdcard/Download/")
        field.frame = NSRect(x: 0, y: 0, width: 380, height: 24)
        alert.accessoryView = field
        alert.addButton(withTitle: "选择保存位置")
        alert.addButton(withTitle: "取消")
        guard alert.runModal() == .alertFirstButtonReturn else { return }

        let source = field.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !source.isEmpty else { return }
        let save = NSSavePanel()
        save.nameFieldStringValue = (source as NSString).lastPathComponent
        guard save.runModal() == .OK, let destination = save.url else { return }
        status = "正在下载…"
        Task.detached {
            let result = Self.runSync(adb, ["-s", self.selectedDevice, "pull", source, destination.path])
            await MainActor.run {
                self.log = result.output
                self.status = result.code == 0 ? "文件已保存到电脑" : "下载失败，请检查手机文件路径"
            }
        }
    }

    nonisolated static func runSync(_ executable: String, _ args: [String]) -> (output: String, code: Int32) {
        let process = Process()
        let pipe = Pipe()
        process.executableURL = URL(fileURLWithPath: executable)
        process.arguments = args
        process.standardOutput = pipe
        process.standardError = pipe
        do {
            try process.run()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            process.waitUntilExit()
            return (String(data: data, encoding: .utf8) ?? "", process.terminationStatus)
        } catch { return (error.localizedDescription, -1) }
    }
}

struct ContentView: View {
    @StateObject private var model = AppModel()

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Image(systemName: "iphone.and.arrow.forward")
                    .font(.system(size: 30)).foregroundStyle(.blue)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Scrcpy Mate").font(.title2.bold())
                    Text("让手机和 Mac 更自然地一起用").foregroundStyle(.secondary)
                }
                Spacer()
                Circle().fill(model.devices.isEmpty ? .orange : .green).frame(width: 9, height: 9)
                Text(model.devices.isEmpty ? "未连接" : "已连接").foregroundStyle(.secondary)
            }.padding(20)

            Divider()

            Form {
                Section("设备") {
                    HStack {
                        Picker("手机", selection: $model.selectedDevice) {
                            if model.devices.isEmpty { Text("未找到设备").tag("") }
                            ForEach(model.devices) { Text($0.label).tag($0.id) }
                        }
                        Button("刷新") { model.refreshDevices() }
                    }
                    HStack {
                        TextField("手机 IP:端口", text: $model.wifiAddress)
                        Button("Wi-Fi 连接") { model.connectWiFi() }
                    }
                }

                Section("画面与控制") {
                    Picker("清晰度", selection: $model.width) {
                        ForEach(["自动", "1280", "1600", "1920", "2560"], id: \.self) { Text($0) }
                    }
                    Toggle("保持手机唤醒", isOn: $model.stayAwake)
                    Toggle("镜像时关闭手机屏幕", isOn: $model.screenOff)
                    Toggle("窗口保持最前", isOn: $model.alwaysOnTop)
                    Text("镜像窗口可直接拖动边缘动态缩放，手机旋转时会自动调整。")
                        .font(.caption).foregroundStyle(.secondary)
                }

                Section("声音") {
                    Picker("音频来源", selection: $model.audioMode) {
                        ForEach(AudioMode.allCases) { Text($0.rawValue).tag($0) }
                    }
                    Text(model.audioMode == .duplicate
                         ? "需要 Android 13 或更高版本，部分应用可能禁止捕获。"
                         : "声音输出使用 Mac 当前选定的扬声器或耳机。电脑麦克风传入手机暂不受 scrcpy 支持。")
                        .font(.caption).foregroundStyle(.secondary)
                }

                Section("文件互传") {
                    HStack {
                        TextField("手机接收目录", text: $model.remotePath)
                        Button("传到手机…") { model.uploadFiles() }
                        Button("从手机下载…") { model.downloadFile() }
                    }
                    Text("文字复制粘贴由 scrcpy 自动双向同步；在镜像窗口使用 ⌘V 即可粘贴。")
                        .font(.caption).foregroundStyle(.secondary)
                }
            }.formStyle(.grouped)

            Divider()
            HStack {
                Text(model.status).lineLimit(1).foregroundStyle(.secondary)
                Spacer()
                Button(model.running ? "停止镜像" : "开始镜像") { model.toggleMirror() }
                    .buttonStyle(.borderedProminent).controlSize(.large)
            }.padding(16)
        }
        .frame(minWidth: 650, idealWidth: 720, minHeight: 640, idealHeight: 700)
    }
}

@main
struct ScrcpyMateApp: App {
    var body: some Scene {
        WindowGroup { ContentView() }
            .windowStyle(.titleBar)
            .commands { CommandGroup(replacing: .newItem) {} }
    }
}
