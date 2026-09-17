# Scrcpy Mate

A native macOS companion for Android, powered by [scrcpy](https://github.com/Genymobile/scrcpy) and ADB. It combines mirroring, wireless debugging, audio/input controls, DeX and file transfer in one app.

原生 macOS Android 助手：将 scrcpy 镜像、无线调试、声音与输入控制、DeX 和文件互传整合到一个应用中。

## Download / 下载

Download the latest ready-to-use package from **[GitHub Releases](https://github.com/AnthonyTsun/Scrcpy-Mate/releases/latest)**.

从 **[GitHub Releases](https://github.com/AnthonyTsun/Scrcpy-Mate/releases/latest)** 下载最新版 `Scrcpy Mate Portable.zip`。便携版已经包含 scrcpy、ADB 及运行所需的动态库，不需要另外安装 Homebrew。

## Install / 安装

1. Download and unzip `Scrcpy Mate Portable.zip`.
2. Drag **Scrcpy Mate** to Applications.
3. If macOS displays a warning on first launch, right-click the app and choose **Open**.
4. Enable **Developer options** and **USB debugging** on the Android phone.

1. 下载并解压 `Scrcpy Mate Portable.zip`。
2. 将 **Scrcpy Mate** 拖入“应用程序”。
3. 如果首次启动出现安全提示，请右键应用并选择“打开”。
4. 在 Android 手机中开启“开发者选项”和“USB 调试”。

> The downloadable build is ad-hoc signed, not Apple-notarized. macOS may ask for confirmation when it is first opened.
>
> 下载版采用临时签名，尚未经过 Apple 公证，因此 macOS 首次打开时可能需要用户确认。

## Quick start / 快速使用

### USB

1. Connect the phone with a data-capable USB cable. / 使用支持数据传输的 USB 线连接手机。
2. Accept the USB debugging authorization on the phone. / 在手机上允许 USB 调试授权。
3. Select the device and click **Start Mirror / 开始镜像**.

### Wi-Fi

1. Connect the Mac and phone to the same network. / 将 Mac 和手机连接到同一网络。
2. After USB succeeds, Scrcpy Mate can prepare and test Wi-Fi mirroring automatically. / USB 连接成功后，应用会自动准备并测试 Wi-Fi 镜像。
3. Android 11 or later can also pair through **Wireless debugging** using QR or a pairing code. / Android 11 及以上也可通过“无线调试”的 QR 或配对码连接。
4. After validation, click **Wireless Mirror / 无线镜像**.

Wireless pairing and the later ADB connection may use different dynamic ports. Pair or reconnect after the phone changes networks.

无线配对端口和之后的 ADB 连接端口可能不同；手机更换网络后请重新配对或连接。

## Features / 功能

- USB and Wi-Fi mirroring / USB 与 Wi-Fi 镜像
- Wireless-debugging QR and pairing-code support / 无线调试 QR 与配对码
- Phone audio, microphone, keyboard and mouse controls / 手机声音、麦克风、键盘与鼠标控制
- Samsung DeX virtual desktop with adjustable density / 可调显示密度的三星 DeX 虚拟桌面
- Embedded two-pane Mac/Android file manager / 内置 Mac 与 Android 双栏文件管理器
- Drag-and-drop files, folders and APKs / 拖放文件、文件夹和 APK
- Clipboard text sync and image transfer / 剪贴板文字同步及图片传送
- Chinese and English interface / 中英文界面
- System, light and dark themes / 跟随系统、浅色与深色主题
- Menu-bar mode and global shortcuts / 菜单栏模式与全局快捷键
- Portable bundled dependencies / 便携版内置运行依赖

## Shortcuts / 快捷键

| Shortcut / 快捷键 | Action / 功能 |
| --- | --- |
| `Command-Shift-M` | Show or hide the control panel / 显示或隐藏控制面板 |
| `Control-Option-Space` | Switch the macOS input language / 切换 macOS 输入语言 |
| `Control-Option-Command-Escape` | Emergency stop and release input / 紧急停止并释放键盘鼠标 |

The mirror window also supports standard scrcpy shortcuts such as `Command-H` for Home, `Command-B` for Back and `Command-F` for full screen.

镜像窗口也支持 scrcpy 常用快捷键，例如 `Command-H` 返回主页、`Command-B` 返回、`Command-F` 全屏。

## Privacy / 隐私

Scrcpy Mate runs locally. Device addresses and pairing information are used only to connect to the selected Android device. It contains no analytics and does not upload personal files to third-party services.

Scrcpy Mate 在本机运行。设备地址和配对信息仅用于连接所选 Android 设备；应用不包含数据分析，也不会将个人文件上传到第三方服务。

## Build from source / 从源码构建

Requirements / 环境要求：macOS 13 or later, Xcode Command Line Tools, scrcpy and Android platform-tools.

The current AppKit implementation is in `work/ScrcpyMate.m`. `work/bundle_portable_deps.sh` prepares the portable bundle. Generated apps, downloaded tools, caches and local device data are intentionally excluded from the repository.

当前 AppKit 实现在 `work/ScrcpyMate.m`，`work/bundle_portable_deps.sh` 用于制作便携版。仓库不包含生成的应用、下载缓存或本地设备数据。

## Acknowledgements / 致谢

- [scrcpy](https://github.com/Genymobile/scrcpy) by Genymobile provides the core Android display and control technology. / 提供 Android 显示与控制核心技术。
- [OpenMTP](https://github.com/ganeshrvel/openmtp) by Ganesh Rathinavel inspired the dual-pane file-management architecture and interaction model. Scrcpy Mate uses its own ADB-backed transfer implementation, allowing file management over USB and Wi-Fi without exclusively occupying the phone's MTP interface. / 双栏文件管理架构与交互方式参考了 OpenMTP；Scrcpy Mate 使用独立的 ADB 传输实现，可通过 USB 或 Wi-Fi 工作，而不会独占手机的 MTP 接口。
- Android Debug Bridge is part of Android SDK Platform-Tools. / Android Debug Bridge 来自 Android SDK Platform-Tools。

Third-party notices / 第三方版权与许可：[`work/OPEN_SOURCE_NOTICES.txt`](work/OPEN_SOURCE_NOTICES.txt)

## Licence / 许可

Scrcpy Mate source is available under the [MIT License](LICENSE). Bundled third-party components remain under their respective licences.

Scrcpy Mate 源码采用 [MIT License](LICENSE)；内置的第三方组件仍遵循各自的许可协议。
