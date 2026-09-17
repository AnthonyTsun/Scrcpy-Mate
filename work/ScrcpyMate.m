#import <Cocoa/Cocoa.h>
#import <CoreImage/CoreImage.h>
#import <Carbon/Carbon.h>
#import <netdb.h>

@class AppDelegate;
static AppDelegate *gAppDelegate;
static OSStatus ScrcpyMateHotKeyHandler(EventHandlerCallRef nextHandler, EventRef event, void *userData);

@protocol DropHandler <NSObject>
- (void)handleDroppedURLs:(NSArray<NSURL *> *)urls;
@end

@interface DropView : NSView <NSDraggingDestination>
@property (weak) id<DropHandler> handler;
@property NSString *displayText;
@end

@implementation DropView
- (instancetype)initWithFrame:(NSRect)frameRect { if ((self = [super initWithFrame:frameRect])) { self.displayText = @"⇩  拖放文件、文件夹或 APK 到这里"; [self registerForDraggedTypes:@[NSPasteboardTypeFileURL]]; } return self; }
- (void)drawRect:(NSRect)dirtyRect { [super drawRect:dirtyRect]; NSBezierPath *p = [NSBezierPath bezierPathWithRoundedRect:NSInsetRect(self.bounds, 1, 1) xRadius:7 yRadius:7]; CGFloat dash[] = {5, 4}; [p setLineDash:dash count:2 phase:0]; p.lineWidth = 1.2; [NSColor.separatorColor setStroke]; [p stroke]; NSDictionary *attrs = @{NSFontAttributeName:[NSFont systemFontOfSize:11], NSForegroundColorAttributeName:NSColor.secondaryLabelColor}; NSString *text = self.displayText ?: @""; NSSize s = [text sizeWithAttributes:attrs]; [text drawAtPoint:NSMakePoint((NSWidth(self.bounds)-s.width)/2, (NSHeight(self.bounds)-s.height)/2) withAttributes:attrs]; }
- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender { return NSDragOperationCopy; }
- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender { NSArray *urls = [sender.draggingPasteboard readObjectsForClasses:@[[NSURL class]] options:@{NSPasteboardURLReadingFileURLsOnlyKey:@YES}]; if (!urls.count) return NO; [self.handler handleDroppedURLs:urls]; return YES; }
@end

@interface AppDelegate : NSObject <NSApplicationDelegate, NSWindowDelegate, NSTableViewDataSource, NSTableViewDelegate, NSNetServiceBrowserDelegate, NSNetServiceDelegate, DropHandler>
@property NSWindow *window;
@property NSPopUpButton *devices, *audio, *quality;
@property NSTextField *wifi, *target, *status;
@property NSButton *stayAwake, *screenOff, *alwaysOnTop, *keyboardControl, *mouseControl, *autoWiFi, *dexMode, *startButton;
@property NSButton *wirelessButton;
@property NSTask *mirrorTask;
@property NSMutableString *mirrorLog;
@property NSString *autoWiFiAttemptedSerial;
@property NSView *filePanel;
@property NSTableView *remoteTable, *localTable;
@property NSTextField *remotePathField, *localPathField, *fileStatus;
@property NSMutableArray *remoteItems, *localItems;
@property BOOL filePanelExpanded;
@property BOOL filePanelTransitioning;
@property NSUInteger filePanelGeneration;
@property BOOL userStoppingMirror;
@property BOOL forceWirelessNext;
@property NSString *verifiedWiFiSerial;
@property NSNetServiceBrowser *pairingBrowser;
@property NSNetService *pairingService;
@property NSString *pairingServiceName, *pairingPassword;
@property NSTask *pairingProxyTask;
@property NSNetServiceBrowser *connectBrowser;
@property NSNetService *connectService;
@property NSTask *connectProxyTask;
@property NSImageView *qrImageView;
@property NSView *toolsPanel;
@property NSPopUpButton *profile, *keyboardMode, *appLaunchMode;
@property NSSlider *dexScale;
@property NSTextField *dexScaleValue;
@property NSPopUpButton *language, *theme;
@property BOOL englishUI;
@property NSButton *gamepadControl, *autoReconnect, *physicalInput, *recordButton;
@property NSTask *recordTask;
@property NSMutableArray *extraTasks, *appItems;
@property NSTableView *appsTable;
@property NSInteger reconnectAttempts;
@property BOOL reconnecting;
@property BOOL pendingSettingsRestart;
@property BOOL pendingRestartWireless;
@property EventHotKeyRef emergencyHotKey;
@property EventHotKeyRef panelHotKey, inputLanguageHotKey;
@property NSStatusItem *statusItem;
- (void)handleDroppedURLs:(NSArray<NSURL *> *)urls;
@end

@implementation AppDelegate

- (NSString *)tool:(NSString *)name {
    for (NSString *dir in @[@"/opt/homebrew/bin", @"/usr/local/bin", @"/usr/bin"]) {
        NSString *path = [dir stringByAppendingPathComponent:name];
        if ([[NSFileManager defaultManager] isExecutableFileAtPath:path]) return path;
    }
    NSString *bundled = [[NSBundle.mainBundle.resourcePath stringByAppendingPathComponent:@"bin"] stringByAppendingPathComponent:name];
    if ([[NSFileManager defaultManager] isExecutableFileAtPath:bundled]) return bundled;
    return nil;
}

- (NSTextField *)label:(NSString *)text frame:(NSRect)frame {
    NSTextField *v = [[NSTextField alloc] initWithFrame:frame];
    v.stringValue = text; v.editable = NO; v.bezeled = NO; v.drawsBackground = NO;
    return v;
}

- (NSTextField *)sectionLabel:(NSString *)text frame:(NSRect)frame {
    NSTextField *v = [self label:text frame:frame]; v.font = [NSFont systemFontOfSize:13 weight:NSFontWeightSemibold]; v.textColor = NSColor.labelColor; return v;
}

- (NSButton *)button:(NSString *)title frame:(NSRect)frame action:(SEL)action {
    NSButton *b = [[NSButton alloc] initWithFrame:frame];
    b.title = title; b.bezelStyle = NSBezelStyleRounded; b.target = self; b.action = action;
    b.imagePosition = NSImageLeading;
    NSDictionary *icons = @{
        @"刷新": @"arrow.clockwise", @"连接": @"link", @"QR": @"qrcode.viewfinder", @"配对码": @"number",
        @"打开文件管理器…": @"folder", @"文件管理器": @"folder", @"开始镜像": @"play.fill", @"无线镜像": @"wifi",
        @"返回上级": @"chevron.up", @"前往": @"arrow.right", @"上传…": @"arrow.up.circle",
        @"下载…": @"arrow.down.circle", @"新建文件夹": @"folder.badge.plus", @"重命名": @"pencil",
        @"删除": @"trash", @"在 Finder 打开下载": @"finder", @"快捷键": @"command",
        @"电话": @"phone", @"短信": @"message", @"粘贴图片": @"photo.on.rectangle",
        @"工具中心": @"square.grid.2x2", @"截图": @"camera", @"开始录屏": @"record.circle",
        @"停止录屏": @"stop.circle", @"手机相机": @"camera.viewfinder", @"应用启动器": @"app.grid.3x3",
        @"新建镜像": @"rectangle.on.rectangle"
    };
    NSString *symbol = icons[title];
    if (symbol) b.image = [NSImage imageWithSystemSymbolName:symbol accessibilityDescription:title];
    return b;
}

- (NSBox *)card:(NSRect)frame {
    NSBox *box = [[NSBox alloc] initWithFrame:frame]; box.boxType = NSBoxCustom; box.title = @"";
    box.cornerRadius = 14; box.borderWidth = 1; box.borderColor = [NSColor separatorColor];
    box.fillColor = NSColor.controlBackgroundColor; return box;
}

- (NSImage *)applicationIcon {
    NSImage *icon = [[NSImage alloc] initWithSize:NSMakeSize(512, 512)];
    [icon lockFocus];
    NSGradient *gradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithRed:0.96 green:0.20 blue:0.25 alpha:1] endingColor:[NSColor colorWithRed:0.55 green:0.20 blue:0.95 alpha:1]];
    NSBezierPath *shape = [NSBezierPath bezierPathWithRoundedRect:NSMakeRect(36, 36, 440, 440) xRadius:108 yRadius:108]; [gradient drawInBezierPath:shape angle:-45];
    NSImage *symbol = [NSImage imageWithSystemSymbolName:@"iphone.and.arrow.forward" accessibilityDescription:@"Scrcpy Mate"];
    NSImageSymbolConfiguration *config = [NSImageSymbolConfiguration configurationWithPointSize:250 weight:NSFontWeightSemibold]; symbol = [symbol imageWithSymbolConfiguration:config];
    [symbol drawInRect:NSMakeRect(126, 126, 260, 260) fromRect:NSZeroRect operation:NSCompositingOperationSourceOver fraction:1 respectFlipped:YES hints:@{NSForegroundColorAttributeName:NSColor.whiteColor}];
    [icon unlockFocus]; return icon;
}

- (NSButton *)check:(NSString *)title y:(CGFloat)y {
    NSButton *b = [[NSButton alloc] initWithFrame:NSMakeRect(155, y, 220, 24)];
    b.title = title; b.buttonType = NSButtonTypeSwitch;
    return b;
}

- (void)applicationDidFinishLaunching:(NSNotification *)note {
    self.window = [[NSWindow alloc] initWithContentRect:NSMakeRect(0, 0, 700, 680)
        styleMask:NSWindowStyleMaskTitled|NSWindowStyleMaskClosable|NSWindowStyleMaskMiniaturizable
        backing:NSBackingStoreBuffered defer:NO];
    self.window.title = @"Scrcpy Mate 9.6";
    self.window.delegate = self;
    self.window.titlebarAppearsTransparent = YES; self.window.titleVisibility = NSWindowTitleHidden;
    self.window.backgroundColor = NSColor.windowBackgroundColor;
    [self.window center];
    NSView *c = self.window.contentView;

    NSImage *appIcon = [self applicationIcon]; NSApp.applicationIconImage = appIcon;
    NSImageView *mark = [[NSImageView alloc] initWithFrame:NSMakeRect(28, 620, 42, 42)]; mark.image = appIcon; [c addSubview:mark];
    [c addSubview:[self card:NSMakeRect(18, 490, 664, 104)]];
    [c addSubview:[self card:NSMakeRect(18, 187, 664, 290)]];
    [c addSubview:[self card:NSMakeRect(18, 96, 664, 78)]];
    [c addSubview:[self card:NSMakeRect(18, 20, 664, 58)]];

    NSTextField *title = [self label:@"Scrcpy Mate" frame:NSMakeRect(80, 625, 300, 34)];
    title.font = [NSFont boldSystemFontOfSize:25]; [c addSubview:title];
    NSTextField *sub = [self label:@"让手机和 Mac 更自然地一起用" frame:NSMakeRect(81, 602, 400, 22)];
    sub.textColor = NSColor.secondaryLabelColor; [c addSubview:sub];
    self.language = [[NSPopUpButton alloc] initWithFrame:NSMakeRect(445, 625, 95, 26) pullsDown:NO]; [self.language addItemsWithTitles:@[@"中文", @"English"]]; self.language.target = self; self.language.action = @selector(changeLanguage:); [c addSubview:self.language];
    self.theme = [[NSPopUpButton alloc] initWithFrame:NSMakeRect(545, 625, 120, 26) pullsDown:NO]; [self.theme addItemsWithTitles:@[@"跟随系统", @"浅色", @"深色"]]; self.theme.target = self; self.theme.action = @selector(changeTheme:); [c addSubview:self.theme];
    self.qrImageView = [[NSImageView alloc] initWithFrame:NSMakeRect(580, 287, 58, 58)];
    self.qrImageView.imageScaling = NSImageScaleProportionallyUpOrDown; [c addSubview:self.qrImageView];
    NSTextField *qrHint = [self label:@"无线调试扫码" frame:NSMakeRect(559, 270, 98, 18)]; qrHint.font = [NSFont systemFontOfSize:10]; qrHint.textColor = NSColor.secondaryLabelColor; qrHint.alignment = NSTextAlignmentCenter; [c addSubview:qrHint];

    [c addSubview:[self sectionLabel:@"设备" frame:NSMakeRect(30, 552, 100, 24)]];
    self.devices = [[NSPopUpButton alloc] initWithFrame:NSMakeRect(155, 550, 375, 28) pullsDown:NO]; self.devices.target = self; self.devices.action = @selector(deviceSelectionChanged:); [c addSubview:self.devices];
    [c addSubview:[self button:@"刷新" frame:NSMakeRect(545, 550, 110, 28) action:@selector(refresh:)]];
    self.wifi = [[NSTextField alloc] initWithFrame:NSMakeRect(155, 512, 260, 28)]; self.wifi.placeholderString = @"手机 IP:端口"; [c addSubview:self.wifi];
    [c addSubview:[self button:@"连接" frame:NSMakeRect(425, 512, 72, 28) action:@selector(connectWiFi:)]];
    [c addSubview:[self button:@"配对码" frame:NSMakeRect(505, 512, 78, 28) action:@selector(pairWiFi:)]];
    [c addSubview:[self button:@"QR" frame:NSMakeRect(591, 512, 64, 28) action:@selector(pairQR:)]];

    [c addSubview:[self sectionLabel:@"声音 / Mic" frame:NSMakeRect(30, 442, 100, 24)]];
    self.audio = [[NSPopUpButton alloc] initWithFrame:NSMakeRect(155, 440, 500, 28) pullsDown:NO];
    [self.audio addItemsWithTitles:@[@"手机系统声音 → 电脑", @"手机和电脑同时播放", @"手机麦克风 → 电脑", @"静音"]]; self.audio.target = self; self.audio.action = @selector(mirrorSettingChanged:); [c addSubview:self.audio];
    NSTextField *audioNote = [self label:@"可切换手机声音或手机 Mic；电脑 Mic → 手机需要额外虚拟音频驱动。" frame:NSMakeRect(155, 413, 500, 22)];
    audioNote.textColor = NSColor.secondaryLabelColor; audioNote.font = [NSFont systemFontOfSize:12]; [c addSubview:audioNote];

    [c addSubview:[self sectionLabel:@"画面与输入" frame:NSMakeRect(30, 387, 110, 24)]];
    self.quality = [[NSPopUpButton alloc] initWithFrame:NSMakeRect(155, 385, 220, 28) pullsDown:NO];
    [self.quality addItemsWithTitles:@[@"自动", @"1280", @"1600", @"1920", @"2560"]]; self.quality.target = self; self.quality.action = @selector(mirrorSettingChanged:); [c addSubview:self.quality];
    self.dexMode = [self check:@"DeX 固定桌面（16:9）" y:264]; self.dexMode.hidden = YES; self.dexMode.target = self; self.dexMode.action = @selector(mirrorSettingChanged:); self.dexMode.toolTip = @"固定 2560×1440 横向桌面；抖音等竖屏应用请从右侧应用启动器以“自动”或“竖屏”模式打开"; [c addSubview:self.dexMode];
    self.dexScale = [[NSSlider alloc] initWithFrame:NSMakeRect(390, 258, 150, 28)];
    self.dexScale.minValue = 150; self.dexScale.maxValue = 240; self.dexScale.doubleValue = 200; self.dexScale.numberOfTickMarks = 7; self.dexScale.allowsTickMarkValuesOnly = NO; self.dexScale.continuous = NO; self.dexScale.target = self; self.dexScale.action = @selector(dexScaleChanged:); self.dexScale.hidden = YES; self.dexScale.toolTip = @"拖动调整 DeX 字体和控件大小，运行中会自动重新应用"; [c addSubview:self.dexScale];
    self.dexScaleValue = [self label:@"字体大小：较大" frame:NSMakeRect(395, 286, 140, 18)]; self.dexScaleValue.font = [NSFont systemFontOfSize:11]; self.dexScaleValue.alignment = NSTextAlignmentCenter; self.dexScaleValue.hidden = YES; [c addSubview:self.dexScaleValue];
    self.keyboardControl = [self check:@"电脑键盘控制手机" y:348]; self.keyboardControl.state = NSControlStateValueOn; self.keyboardControl.target = self; self.keyboardControl.action = @selector(mirrorSettingChanged:); [c addSubview:self.keyboardControl];
    NSTextField *wifiNote = [self label:@"USB 连接后会在后台验证 Wi‑Fi；成功后出现“无线镜像”。" frame:NSMakeRect(390, 348, 270, 35)]; wifiNote.font = [NSFont systemFontOfSize:11]; wifiNote.textColor = NSColor.secondaryLabelColor; wifiNote.maximumNumberOfLines = 2; [c addSubview:wifiNote];
    self.mouseControl = [self check:@"电脑鼠标控制手机" y:320]; self.mouseControl.state = NSControlStateValueOn; self.mouseControl.target = self; self.mouseControl.action = @selector(mirrorSettingChanged:); [c addSubview:self.mouseControl];
    self.stayAwake = [self check:@"保持手机唤醒" y:292]; self.stayAwake.state = NSControlStateValueOn; self.stayAwake.target = self; self.stayAwake.action = @selector(mirrorSettingChanged:); [c addSubview:self.stayAwake];
    self.screenOff = [self check:@"镜像时关闭手机屏幕" y:236]; self.screenOff.target = self; self.screenOff.action = @selector(screenPowerChanged:); [c addSubview:self.screenOff];
    self.alwaysOnTop = [self check:@"窗口保持最前" y:208]; self.alwaysOnTop.target = self; self.alwaysOnTop.action = @selector(mirrorSettingChanged:); [c addSubview:self.alwaysOnTop];
    NSTextField *shortcutHint = [self label:@"⌘H 主页　⌘B 返回　⌘F 全屏　⌃⌥⌘Esc 紧急停止" frame:NSMakeRect(365, 212, 290, 22)]; shortcutHint.font = [NSFont systemFontOfSize:11]; shortcutHint.textColor = NSColor.secondaryLabelColor; shortcutHint.alignment = NSTextAlignmentRight; [c addSubview:shortcutHint];
    NSTextField *resizeNote = [self label:@"默认使用安全输入，不会锁住 Mac 键盘和鼠标。" frame:NSMakeRect(390, 245, 265, 20)];
    resizeNote.textColor = NSColor.secondaryLabelColor; resizeNote.font = [NSFont systemFontOfSize:12]; [c addSubview:resizeNote];

    [c addSubview:[self sectionLabel:@"文件互传" frame:NSMakeRect(30, 138, 100, 24)]];
    self.target = [[NSTextField alloc] initWithFrame:NSMakeRect(155, 136, 210, 28)]; self.target.stringValue = @"/sdcard/Download/"; [c addSubview:self.target];
    [c addSubview:[self button:@"文件管理器" frame:NSMakeRect(375, 136, 130, 28) action:@selector(openFileManager:)]];
    [c addSubview:[self button:@"电话" frame:NSMakeRect(515, 136, 65, 28) action:@selector(openPhone:)]];
    [c addSubview:[self button:@"短信" frame:NSMakeRect(590, 136, 65, 28) action:@selector(openMessages:)]];
    DropView *drop = [[DropView alloc] initWithFrame:NSMakeRect(155, 101, 345, 30)]; drop.handler = self; [c addSubview:drop];
    [c addSubview:[self button:@"粘贴图片" frame:NSMakeRect(515, 102, 140, 28) action:@selector(pasteImageToPhone:)]];

    self.status = [self label:@"正在查找手机…" frame:NSMakeRect(30, 35, 470, 30)]; self.status.textColor = NSColor.secondaryLabelColor; [c addSubview:self.status];
    self.wirelessButton = [self button:@"无线镜像" frame:NSMakeRect(375, 30, 135, 36) action:@selector(startWirelessMirror:)]; self.wirelessButton.hidden = YES; self.wirelessButton.bezelColor = NSColor.systemBlueColor; [c addSubview:self.wirelessButton];
    self.startButton = [self button:@"开始镜像" frame:NSMakeRect(520, 30, 135, 36) action:@selector(toggleMirror:)]; self.startButton.keyEquivalent = @"\r"; self.startButton.bezelColor = NSColor.systemRedColor; [c addSubview:self.startButton];
    [self.window makeKeyAndOrderFront:nil]; [NSApp activateIgnoringOtherApps:YES];
    [NSApp setActivationPolicy:NSApplicationActivationPolicyAccessory];
    [self setupStatusItem];
    self.extraTasks = [NSMutableArray array];
    [self setupEmbeddedTools];
    self.englishUI = [NSUserDefaults.standardUserDefaults boolForKey:@"EnglishUI"];
    [self.language selectItemAtIndex:self.englishUI ? 1 : 0];
    NSInteger savedTheme = [NSUserDefaults.standardUserDefaults integerForKey:@"ThemeMode"];
    [self.theme selectItemAtIndex:MIN(MAX(savedTheme, 0), 2)]; [self changeTheme:self.theme];
    if (self.englishUI) [self applyLanguageToView:self.window.contentView];
    NSString *savedWiFi = [NSUserDefaults.standardUserDefaults stringForKey:@"LastWiFiAddress"];
    if (savedWiFi.length) { self.wifi.stringValue = savedWiFi; [self connectWiFi:nil]; }
    [self refresh:nil];
    [self pairQR:nil];
    gAppDelegate = self;
    EventTypeSpec hotKeyEvent = { kEventClassKeyboard, kEventHotKeyPressed };
    InstallApplicationEventHandler(&ScrcpyMateHotKeyHandler, 1, &hotKeyEvent, NULL, NULL);
    EventHotKeyID hotKeyID = { 'SCMT', 1 };
    RegisterEventHotKey(kVK_Escape, controlKey | optionKey | cmdKey, hotKeyID, GetApplicationEventTarget(), 0, &_emergencyHotKey);
    EventHotKeyID panelHotKeyID = { 'SCMT', 2 };
    RegisterEventHotKey(kVK_ANSI_M, cmdKey | shiftKey, panelHotKeyID, GetApplicationEventTarget(), 0, &_panelHotKey);
    EventHotKeyID inputHotKeyID = { 'SCMT', 3 };
    RegisterEventHotKey(kVK_Space, controlKey | optionKey, inputHotKeyID, GetApplicationEventTarget(), 0, &_inputLanguageHotKey);
}

- (void)setupStatusItem {
    self.statusItem = [NSStatusBar.systemStatusBar statusItemWithLength:NSSquareStatusItemLength];
    self.statusItem.button.image = [NSImage imageWithSystemSymbolName:@"iphone.and.arrow.forward" accessibilityDescription:@"Scrcpy Mate"];
    NSMenu *menu = [NSMenu new];
    NSMenuItem *show = [[NSMenuItem alloc] initWithTitle:@"显示／隐藏 Scrcpy Mate" action:@selector(toggleControlPanel:) keyEquivalent:@""]; show.target = self; [menu addItem:show];
    NSMenuItem *input = [[NSMenuItem alloc] initWithTitle:@"切换 Mac 输入语言  ⌃⌥Space" action:@selector(toggleInputLanguage:) keyEquivalent:@""]; input.target = self; [menu addItem:input];
    NSMenuItem *mirror = [[NSMenuItem alloc] initWithTitle:@"开始／停止镜像" action:@selector(toggleMirror:) keyEquivalent:@""]; mirror.target = self; [menu addItem:mirror];
    [menu addItem:NSMenuItem.separatorItem];
    NSMenuItem *quit = [[NSMenuItem alloc] initWithTitle:@"退出 Scrcpy Mate" action:@selector(terminate:) keyEquivalent:@"q"]; [menu addItem:quit];
    self.statusItem.menu = menu;
}

- (void)toggleControlPanel:(id)sender {
    if (self.window.visible) [self.window orderOut:nil];
    else { [NSApp activateIgnoringOtherApps:YES]; [self.window makeKeyAndOrderFront:nil]; }
}

- (void)toggleInputLanguage:(id)sender {
    TISInputSourceRef current = TISCopyCurrentKeyboardInputSource();
    CFBooleanRef currentASCIIValue = current ? TISGetInputSourceProperty(current, kTISPropertyInputSourceIsASCIICapable) : NULL;
    BOOL currentASCII = currentASCIIValue == kCFBooleanTrue;
    NSDictionary *filter = @{(__bridge NSString *)kTISPropertyInputSourceCategory:(__bridge NSString *)kTISCategoryKeyboardInputSource,
                             (__bridge NSString *)kTISPropertyInputSourceIsEnabled:@YES};
    CFArrayRef sourceList = TISCreateInputSourceList((__bridge CFDictionaryRef)filter, false);
    TISInputSourceRef choice = NULL;
    for (id item in (__bridge NSArray *)sourceList) {
        TISInputSourceRef source = (__bridge TISInputSourceRef)item;
        CFBooleanRef asciiValue = TISGetInputSourceProperty(source, kTISPropertyInputSourceIsASCIICapable);
        CFBooleanRef selectableValue = TISGetInputSourceProperty(source, kTISPropertyInputSourceIsSelectCapable);
        BOOL selectable = selectableValue == kCFBooleanTrue;
        BOOL ascii = asciiValue == kCFBooleanTrue;
        if (selectable && ascii != currentASCII) { choice = source; break; }
    }
    if (choice) TISSelectInputSource(choice);
    if (sourceList) CFRelease(sourceList); if (current) CFRelease(current);
}

- (BOOL)windowShouldClose:(NSWindow *)sender { [sender orderOut:nil]; return NO; }

- (NSDictionary<NSString *, NSString *> *)translations {
    return @{
        @"让手机和 Mac 更自然地一起用":@"Use your Android naturally with your Mac", @"无线调试扫码":@"Wireless debugging QR", @"跟随系统":@"System", @"浅色":@"Light", @"深色":@"Dark",
        @"设备":@"Device", @"刷新":@"Refresh", @"连接":@"Connect", @"配对码":@"Pair code",
        @"声音 / Mic":@"Audio / Mic", @"手机系统声音 → 电脑":@"Phone audio → Mac", @"手机和电脑同时播放":@"Play on phone and Mac", @"手机麦克风 → 电脑":@"Phone mic → Mac", @"静音":@"Mute",
        @"可切换手机声音或手机 Mic；电脑 Mic → 手机需要额外虚拟音频驱动。":@"Switch phone audio or microphone; Mac mic to phone requires a virtual audio driver.",
        @"画面与输入":@"Display & Input", @"自动":@"Auto", @"电脑键盘控制手机":@"Mac keyboard controls phone", @"电脑鼠标控制手机":@"Mac mouse controls phone", @"保持手机唤醒":@"Keep phone awake",
        @"DeX 固定桌面（16:9）":@"DeX fixed desktop (16:9)", @"镜像时关闭手机屏幕":@"Turn phone screen off", @"窗口保持最前":@"Keep mirror on top",
        @"字体大小：标准":@"Text size: Standard", @"字体大小：较大":@"Text size: Large", @"字体大小：特大":@"Text size: Extra large",
        @"默认使用安全输入，不会锁住 Mac 键盘和鼠标。":@"Safe input is used by default and will not capture Mac controls.",
        @"文件互传":@"File Transfer", @"文件管理器":@"File Manager", @"电话":@"Phone", @"短信":@"Messages", @"粘贴图片":@"Paste Image",
        @"开始镜像":@"Start Mirror", @"停止镜像":@"Stop Mirror", @"无线镜像":@"Wireless Mirror",
        @"工具中心":@"Tool Centre", @"连接与输入":@"Connection & Input", @"画质":@"Quality", @"平衡":@"Balanced", @"高画质":@"High quality", @"流畅":@"Smooth", @"低延迟":@"Low latency", @"演示模式":@"Presentation",
        @"兼容输入":@"Compatible input", @"手机输入法":@"Phone keyboard", @"断线重试 3 次":@"Retry up to 3 times", @"手柄直通":@"Gamepad passthrough", @"鼠标直通（右 ⌘ 释放）":@"Mouse passthrough (right ⌘ releases)",
        @"实用工具":@"Utilities", @"截图":@"Screenshot", @"开始录屏":@"Start Recording", @"停止录屏":@"Stop Recording", @"手机相机":@"Phone Camera", @"新建镜像":@"New Mirror",
        @"快速控制":@"Quick Controls", @"返回":@"Back", @"主页":@"Home", @"最近":@"Recents", @"通知":@"Notifications", @"音量−":@"Volume −", @"音量+":@"Volume +", @"锁屏":@"Lock",
        @"应用":@"Apps", @"自动适配":@"Auto fit", @"DeX 桌面":@"DeX desktop", @"手机竖屏":@"Phone portrait",
        @"双击启动应用 · 文件可拖入镜像窗口":@"Double-click an app · Drag files into the mirror window",
        @"Mac":@"Mac", @"手机":@"Phone", @"返回上级":@"Up", @"上传 →":@"Upload →", @"← 下载":@"← Download", @"新建文件夹":@"New Folder",
        @"双击文件夹进入；选择项目后用中间按钮双向传输":@"Double-click folders; select an item and use the centre buttons to transfer."
    };
}

- (NSString *)localizedUIString:(NSString *)value toEnglish:(BOOL)english {
    NSDictionary *map = self.translations;
    if (english) return map[value] ?: value;
    for (NSString *key in map) if ([map[key] isEqualToString:value]) return key;
    return value;
}

- (void)applyLanguageToView:(NSView *)view {
    if ([view isKindOfClass:NSTextField.class]) { NSTextField *field = (NSTextField *)view; if (!field.editable) field.stringValue = [self localizedUIString:field.stringValue toEnglish:self.englishUI]; }
    if ([view isKindOfClass:NSButton.class] && ![view isKindOfClass:NSPopUpButton.class]) { NSButton *button = (NSButton *)view; button.title = [self localizedUIString:button.title toEnglish:self.englishUI]; }
    if ([view isKindOfClass:NSPopUpButton.class] && view != self.language) { NSPopUpButton *popup = (NSPopUpButton *)view; for (NSMenuItem *item in popup.itemArray) item.title = [self localizedUIString:item.title toEnglish:self.englishUI]; }
    if ([view isKindOfClass:DropView.class]) { ((DropView *)view).displayText = self.englishUI ? @"⇩  Drop files, folders or APKs here" : @"⇩  拖放文件、文件夹或 APK 到这里"; [view setNeedsDisplay:YES]; }
    for (NSView *child in view.subviews) [self applyLanguageToView:child];
}

- (void)changeLanguage:(NSPopUpButton *)sender {
    self.englishUI = sender.indexOfSelectedItem == 1; [NSUserDefaults.standardUserDefaults setBool:self.englishUI forKey:@"EnglishUI"];
    [self applyLanguageToView:self.window.contentView];
}

- (void)changeTheme:(NSPopUpButton *)sender {
    NSInteger mode = sender.indexOfSelectedItem; [NSUserDefaults.standardUserDefaults setInteger:mode forKey:@"ThemeMode"];
    self.window.appearance = mode == 1 ? [NSAppearance appearanceNamed:NSAppearanceNameAqua] : (mode == 2 ? [NSAppearance appearanceNamed:NSAppearanceNameDarkAqua] : nil);
}

- (NSDictionary *)run:(NSString *)exe args:(NSArray *)args {
    NSTask *task = [NSTask new]; NSPipe *pipe = [NSPipe pipe];
    task.executableURL = [NSURL fileURLWithPath:exe]; task.arguments = args; task.environment = [self childEnvironment]; task.standardOutput = pipe; task.standardError = pipe;
    @try { [task launchAndReturnError:nil]; [task waitUntilExit]; }
    @catch (NSException *e) { return @{ @"text": e.reason ?: @"运行失败", @"code": @(-1) }; }
    NSData *data = [[pipe fileHandleForReading] readDataToEndOfFile];
    return @{ @"text": [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] ?: @"", @"code": @(task.terminationStatus) };
}

- (NSString *)serial { return self.devices.selectedItem.representedObject ?: @""; }

- (void)refresh:(id)sender {
    if (sender) self.autoWiFiAttemptedSerial = nil;
    NSString *adb = [self tool:@"adb"]; if (!adb) { self.status.stringValue = @"找不到 adb，请先安装 scrcpy"; return; }
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
        NSString *out = [self run:adb args:@[@"devices", @"-l"]][@"text"];
        NSMutableArray *found = [NSMutableArray array];
        for (NSString *line in [out componentsSeparatedByString:@"\n"]) {
            NSArray *rawParts = [line componentsSeparatedByCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
            NSMutableArray *parts = [NSMutableArray array];
            for (NSString *part in rawParts) if (part.length) [parts addObject:part];
            if (parts.count < 2 || ![parts[1] isEqualToString:@"device"]) continue;
            NSString *serial = parts[0];
            NSString *label = serial;
            for (NSString *part in parts) if ([part hasPrefix:@"model:"]) label = [NSString stringWithFormat:@"%@  ·  %@", [[part substringFromIndex:6] stringByReplacingOccurrencesOfString:@"_" withString:@" "], serial];
            [found addObject:@{ @"serial": serial, @"label": label }];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.devices removeAllItems];
            if (!found.count) [self.devices addItemWithTitle:@"未找到设备"];
            for (NSDictionary *d in found) { [self.devices addItemWithTitle:d[@"label"]]; self.devices.lastItem.representedObject = d[@"serial"]; }
            [self deviceSelectionChanged:nil];
            for (NSDictionary *d in found) if ([d[@"serial"] containsString:@":"]) { self.wifi.stringValue = d[@"serial"]; [NSUserDefaults.standardUserDefaults setObject:d[@"serial"] forKey:@"LastWiFiAddress"]; }
            self.status.stringValue = found.count ? [NSString stringWithFormat:@"已找到 %lu 台设备", (unsigned long)found.count] : @"未找到设备：可连接 USB，或输入 Wi‑Fi 的 IP:端口后连接";
            if (found.count) [self showEmbeddedTools];
            for (NSDictionary *d in found) {
                NSString *serial = d[@"serial"];
                if (![serial containsString:@":"] && ![self.autoWiFiAttemptedSerial isEqualToString:serial]) { [self autoSwitchToWiFi:serial]; break; }
            }
        });
    });
}

- (void)deviceSelectionChanged:(id)sender {
    NSString *name = self.devices.titleOfSelectedItem.uppercaseString ?: @"";
    BOOL samsung = [name containsString:@"SAMSUNG"] || [name hasPrefix:@"SM "] || [name hasPrefix:@"SM-"];
    self.dexMode.hidden = !samsung;
    self.dexScale.hidden = !samsung;
    self.dexScaleValue.hidden = !samsung;
    if (!samsung) self.dexMode.state = NSControlStateValueOff;
}

- (void)autoSwitchToWiFi:(NSString *)serial {
    self.autoWiFiAttemptedSerial = serial; self.status.stringValue = @"USB 已连接，正在后台验证 Wi‑Fi…"; self.wirelessButton.hidden = YES;
    NSString *adb = [self tool:@"adb"];
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
        NSString *route = [self run:adb args:@[@"-s", serial, @"shell", @"ip", @"route"]][@"text"];
        NSString *ip = nil; NSArray *parts = [route componentsSeparatedByCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
        for (NSUInteger i = 0; i + 1 < parts.count; i++) if ([parts[i] isEqualToString:@"src"] && [parts[i + 1] containsString:@"."]) ip = parts[i + 1];
        if (!ip.length) { dispatch_async(dispatch_get_main_queue(), ^{ self.status.stringValue = @"USB 已连接，可以开始镜像"; }); return; }
        NSDictionary *tcp = [self run:adb args:@[@"-s", serial, @"tcpip", @"5555"]];
        if ([tcp[@"code"] intValue] != 0) { dispatch_async(dispatch_get_main_queue(), ^{ self.status.stringValue = @"Wi‑Fi 验证失败；USB 可以正常镜像"; }); return; }
        [NSThread sleepForTimeInterval:2.0]; NSString *address = [NSString stringWithFormat:@"%@:5555", ip];
        NSDictionary *connection = [self run:adb args:@[@"connect", address]]; NSString *text = connection[@"text"];
        NSDictionary *probeWiFi = [self run:adb args:@[@"-s", address, @"shell", @"echo", @"SCRCPY_MATE_WIFI_READY"]];
        BOOL ok = [connection[@"code"] intValue] == 0 && [probeWiFi[@"code"] intValue] == 0 && [probeWiFi[@"text"] containsString:@"SCRCPY_MATE_WIFI_READY"];
        if (!ok) {
            BOOL usbReady = NO;
            for (NSInteger attempt = 0; attempt < 20 && !usbReady; attempt++) {
                NSDictionary *probe = [self run:adb args:@[@"-s", serial, @"shell", @"echo", @"SCRCPY_MATE_READY"]];
                usbReady = [probe[@"code"] intValue] == 0 && [probe[@"text"] containsString:@"SCRCPY_MATE_READY"];
                if (!usbReady) [NSThread sleepForTimeInterval:0.5];
            }
            dispatch_async(dispatch_get_main_queue(), ^{ self.wifi.stringValue = address; self.status.stringValue = usbReady ? @"Wi‑Fi 验证失败；USB 已恢复，可以开始镜像" : @"USB 正在重新连接，请拔插数据线后点刷新"; self.startButton.enabled = usbReady; self.wirelessButton.hidden = YES; });
        } else dispatch_async(dispatch_get_main_queue(), ^{ self.wifi.stringValue = address; self.verifiedWiFiSerial = address; self.status.stringValue = [NSString stringWithFormat:@"Wi‑Fi 已验证：%@；可选择无线镜像", address]; self.wirelessButton.hidden = NO; [NSUserDefaults.standardUserDefaults setObject:address forKey:@"LastWiFiAddress"]; });
    });
}

- (void)connectWiFi:(id)sender {
    NSString *addr = [self.wifi.stringValue stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
    if (!addr.length) { self.status.stringValue = @"请输入手机 IP 地址"; return; }
    BOOL usedDefaultPort = ![addr containsString:@":"];
    if (usedDefaultPort) addr = [addr stringByAppendingString:@":5555"];
    NSString *adb = [self tool:@"adb"]; self.status.stringValue = @"正在连接…";
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
        NSDictionary *r = [self run:adb args:@[@"connect", addr]];
        NSString *raw = [r[@"text"] stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
        BOOL ok = [r[@"code"] intValue] == 0 && ([raw containsString:@"connected"] || [raw containsString:@"already"]);
        dispatch_async(dispatch_get_main_queue(), ^{
            if (ok) { self.status.stringValue = [NSString stringWithFormat:@"Wi‑Fi 已连接：%@", addr]; self.verifiedWiFiSerial = addr; self.wirelessButton.hidden = NO; [NSUserDefaults.standardUserDefaults setObject:addr forKey:@"LastWiFiAddress"]; [self refresh:nil]; }
            else self.status.stringValue = usedDefaultPort
                ? [NSString stringWithFormat:@"连接失败：手机未开放 5555。请填写无线调试页面的完整 IP:端口。%@", raw.length ? [@" " stringByAppendingString:raw] : @""]
                : [NSString stringWithFormat:@"连接失败：%@", raw.length ? raw : @"请检查 IP、端口和同一 Wi‑Fi"];
        });
    });
}

- (void)pairWiFi:(id)sender {
    NSString *addr = [self.wifi.stringValue stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
    if (!addr.length || ![addr containsString:@":"]) { self.status.stringValue = @"请先输入手机显示的配对 IP:端口"; return; }
    NSAlert *a = [NSAlert new]; a.messageText = @"无线调试配对"; a.informativeText = @"输入手机“使用配对码配对设备”中显示的 6 位配对码";
    NSTextField *code = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 220, 24)]; code.placeholderString = @"配对码"; a.accessoryView = code;
    [a addButtonWithTitle:@"配对"]; [a addButtonWithTitle:@"取消"];
    if ([a runModal] != NSAlertFirstButtonReturn || !code.stringValue.length) return;
    NSString *adb = [self tool:@"adb"]; self.status.stringValue = @"正在无线配对…";
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
        NSDictionary *r = [self run:adb args:@[@"pair", addr, code.stringValue]];
        dispatch_async(dispatch_get_main_queue(), ^{ self.status.stringValue = [r[@"text"] stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet]; if ([r[@"code"] intValue] == 0) self.wifi.placeholderString = @"再输入无线调试主页的 IP:端口并点连接"; });
    });
}

- (NSString *)randomToken:(NSInteger)length {
    NSString *chars = @"abcdefghijkmnopqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ23456789";
    NSMutableString *result = [NSMutableString stringWithCapacity:length];
    for (NSInteger i = 0; i < length; i++) [result appendFormat:@"%C", [chars characterAtIndex:arc4random_uniform((uint32_t)chars.length)]];
    return result;
}

- (void)pairQR:(id)sender {
    [self.pairingBrowser stop];
    NSString *service = [@"studio-" stringByAppendingString:[self randomToken:10]];
    NSString *password = [self randomToken:12];
    NSString *payload = [NSString stringWithFormat:@"WIFI:T:ADB;S:%@;P:%@;;", service, password];
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [filter setValue:[payload dataUsingEncoding:NSUTF8StringEncoding] forKey:@"inputMessage"];
    [filter setValue:@"M" forKey:@"inputCorrectionLevel"];
    CIImage *scaled = [filter.outputImage imageByApplyingTransform:CGAffineTransformMakeScale(10, 10)];
    CGImageRef cg = [[CIContext contextWithOptions:nil] createCGImage:scaled fromRect:scaled.extent];
    NSImage *qr = [[NSImage alloc] initWithCGImage:cg size:NSMakeSize(300, 300)]; CGImageRelease(cg);
    self.qrImageView.image = qr;
    self.pairingServiceName = service; self.pairingPassword = password;
    self.pairingBrowser = [NSNetServiceBrowser new]; self.pairingBrowser.delegate = self;
    [self.pairingBrowser searchForServicesOfType:@"_adb-tls-pairing._tcp." inDomain:@"local."];
    if (sender) self.status.stringValue = @"二维码已更新，等待手机扫描…";
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)browser didFindService:(NSNetService *)service moreComing:(BOOL)moreComing {
    if (browser == self.pairingBrowser) {
        if (![service.name isEqualToString:self.pairingServiceName]) return;
        self.status.stringValue = @"已发现手机，正在解析配对端口…"; self.pairingService = service; self.pairingService.delegate = self; [self.pairingService resolveWithTimeout:10.0];
    } else if (browser == self.connectBrowser && !self.connectService) {
        self.status.stringValue = @"已找到无线连接，正在建立通道…"; self.connectService = service; self.connectService.delegate = self; [self.connectService resolveWithTimeout:12.0];
    }
}

- (void)netServiceDidResolveAddress:(NSNetService *)service {
    NSString *host = nil;
    for (NSData *data in service.addresses) { char buffer[NI_MAXHOST]; const struct sockaddr *sa = data.bytes; if (getnameinfo(sa, (socklen_t)data.length, buffer, sizeof(buffer), NULL, 0, NI_NUMERICHOST) == 0) { NSString *candidate = [NSString stringWithUTF8String:buffer]; if ([candidate containsString:@"."]) { host = candidate; break; } } }
    if (!host.length) host = service.hostName;
    if (service == self.connectService) { [self connectResolvedService:service host:host]; return; }
    NSString *password = self.pairingPassword, *adb = [self tool:@"adb"];
    NSString *proxy = [NSBundle.mainBundle pathForResource:@"wifi_proxy" ofType:nil];
    if (!proxy.length) { self.status.stringValue = @"配对组件缺失，请重新安装应用"; return; }
    NSInteger localPort = 43000 + arc4random_uniform(15000);
    self.pairingProxyTask = [NSTask new]; self.pairingProxyTask.executableURL = [NSURL fileURLWithPath:proxy];
    self.pairingProxyTask.arguments = @[host, [NSString stringWithFormat:@"%ld", (long)service.port], [NSString stringWithFormat:@"%ld", (long)localPort]];
    NSError *proxyError = nil;
    if (![self.pairingProxyTask launchAndReturnError:&proxyError]) { self.status.stringValue = @"无法启动安全配对通道"; return; }
    self.status.stringValue = @"已发现手机，正在通过安全通道配对…";
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
        [NSThread sleepForTimeInterval:0.15];
        NSString *localEndpoint = [NSString stringWithFormat:@"127.0.0.1:%ld", (long)localPort];
        NSDictionary *pair = [self run:adb args:@[@"pair", localEndpoint, password]];
        BOOL ok = [pair[@"code"] intValue] == 0;
        if (self.pairingProxyTask.running) [self.pairingProxyTask terminate];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *detail = [pair[@"text"] stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
            self.status.stringValue = ok ? @"QR 配对成功；请稍候，正在发现无线连接…" : [NSString stringWithFormat:@"QR 配对失败：%@", detail.length ? detail : @"手机关闭了配对通道，请重新扫描"];
            if (ok) { [self.pairingBrowser stop]; [self beginWirelessServiceDiscovery]; }
        });
    });
}

- (void)beginWirelessServiceDiscovery {
    self.connectService = nil;
    self.connectBrowser = [NSNetServiceBrowser new]; self.connectBrowser.delegate = self;
    [self.connectBrowser searchForServicesOfType:@"_adb-tls-connect._tcp." inDomain:@"local."];
    self.status.stringValue = @"QR 配对成功，正在寻找手机的无线连接…";
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 15 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        if (!self.verifiedWiFiSerial.length && self.connectBrowser) self.status.stringValue = @"配对成功，但尚未发现无线连接；请保持手机无线调试页面开启";
    });
}

- (void)connectResolvedService:(NSNetService *)service host:(NSString *)host {
    NSString *proxy = [NSBundle.mainBundle pathForResource:@"wifi_proxy" ofType:nil], *adb = [self tool:@"adb"];
    if (!proxy.length || !host.length) { self.status.stringValue = @"无法建立无线连接通道"; return; }
    if (self.connectProxyTask.running) [self.connectProxyTask terminate];
    NSInteger localPort = 43000 + arc4random_uniform(15000);
    self.connectProxyTask = [NSTask new]; self.connectProxyTask.executableURL = [NSURL fileURLWithPath:proxy];
    self.connectProxyTask.arguments = @[host, [NSString stringWithFormat:@"%ld", (long)service.port], [NSString stringWithFormat:@"%ld", (long)localPort]];
    NSError *error = nil;
    if (![self.connectProxyTask launchAndReturnError:&error]) { self.status.stringValue = @"无线连接通道启动失败"; return; }
    self.status.stringValue = @"正在连接无线设备…";
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
        [NSThread sleepForTimeInterval:0.15];
        NSString *localEndpoint = [NSString stringWithFormat:@"127.0.0.1:%ld", (long)localPort];
        NSDictionary *result = [self run:adb args:@[@"connect", localEndpoint]];
        NSString *detail = [result[@"text"] stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
        NSDictionary *probe = [self run:adb args:@[@"-s", localEndpoint, @"shell", @"echo", @"SCRCPY_MATE_WIFI_READY"]];
        BOOL ok = [result[@"code"] intValue] == 0 && [probe[@"code"] intValue] == 0 && [probe[@"text"] containsString:@"SCRCPY_MATE_WIFI_READY"];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (ok) {
                self.verifiedWiFiSerial = localEndpoint; self.wifi.stringValue = @"QR 无线连接"; self.wirelessButton.hidden = NO;
                self.status.stringValue = @"无线连接已验证，可以拔掉 USB 或直接点“无线镜像”";
                [self.connectBrowser stop]; self.connectBrowser = nil;
                [self refresh:nil];
            } else {
                if (self.connectProxyTask.running) [self.connectProxyTask terminate];
                self.connectService = nil;
                self.status.stringValue = [NSString stringWithFormat:@"已配对，但无线连接验证失败：%@", detail.length ? detail : @"请保持无线调试开启"];
            }
        });
    });
}

- (void)netService:(NSNetService *)sender didNotResolve:(NSDictionary<NSString *,NSNumber *> *)errorDict { self.status.stringValue = @"已扫描二维码，但无法解析手机配对端口"; }

- (void)setupEmbeddedTools {
    self.toolsPanel = [[NSView alloc] initWithFrame:NSMakeRect(700, 20, 330, 640)]; self.toolsPanel.hidden = YES; NSView *c = self.toolsPanel; [self.window.contentView addSubview:c];
    [c addSubview:[self card:NSMakeRect(0, 0, 320, 640)]];
    NSTextField *heading = [self label:@"工具中心" frame:NSMakeRect(18, 598, 200, 30)]; heading.font = [NSFont systemFontOfSize:20 weight:NSFontWeightBold]; [c addSubview:heading];
    [c addSubview:[self card:NSMakeRect(12, 444, 296, 142)]];
    [c addSubview:[self sectionLabel:@"连接与输入" frame:NSMakeRect(26, 554, 120, 22)]];
    [c addSubview:[self label:@"画质" frame:NSMakeRect(26, 520, 38, 22)]];
    self.profile = [[NSPopUpButton alloc] initWithFrame:NSMakeRect(68, 518, 108, 28) pullsDown:NO]; [self.profile addItemsWithTitles:@[@"平衡", @"高画质", @"流畅", @"低延迟", @"演示模式"]]; self.profile.target = self; self.profile.action = @selector(mirrorSettingChanged:); [c addSubview:self.profile];
    self.keyboardMode = [[NSPopUpButton alloc] initWithFrame:NSMakeRect(184, 518, 110, 28) pullsDown:NO]; [self.keyboardMode addItemsWithTitles:@[@"兼容输入", @"手机输入法"]]; self.keyboardMode.target = self; self.keyboardMode.action = @selector(mirrorSettingChanged:); self.keyboardMode.toolTip = @"兼容输入使用文字事件；手机输入法使用实体键盘模式"; [c addSubview:self.keyboardMode];
    self.autoReconnect = [self check:@"断线重试 3 次" y:486]; self.autoReconnect.frame = NSMakeRect(26, 486, 138, 24); [c addSubview:self.autoReconnect];
    self.gamepadControl = [self check:@"手柄直通" y:486]; self.gamepadControl.frame = NSMakeRect(180, 486, 112, 24); self.gamepadControl.target = self; self.gamepadControl.action = @selector(mirrorSettingChanged:); [c addSubview:self.gamepadControl];
    self.physicalInput = [self check:@"鼠标直通（右 ⌘ 释放）" y:458]; self.physicalInput.frame = NSMakeRect(26, 458, 220, 24); self.physicalInput.target = self; self.physicalInput.action = @selector(mirrorSettingChanged:); [c addSubview:self.physicalInput];
    [c addSubview:[self card:NSMakeRect(12, 334, 296, 100)]];
    [c addSubview:[self sectionLabel:@"实用工具" frame:NSMakeRect(26, 404, 100, 22)]];
    NSArray *tools = @[@"截图", @"开始录屏", @"手机相机", @"新建镜像"];
    SEL actions[] = {@selector(takeScreenshot:), @selector(toggleRecording:), @selector(startCamera:), @selector(startAdditionalMirror:)};
    for (NSInteger i = 0; i < 4; i++) { NSButton *b = [self button:tools[i] frame:NSMakeRect(26 + (i % 2) * 138, 370 - (i / 2) * 34, 130, 28) action:actions[i]]; if (i == 1) self.recordButton = b; [c addSubview:b]; }
    [c addSubview:[self card:NSMakeRect(12, 224, 296, 100)]];
    NSTextField *quick = [self sectionLabel:@"快速控制" frame:NSMakeRect(26, 294, 100, 22)]; [c addSubview:quick];
    NSArray *titles = @[@"返回", @"主页", @"最近", @"通知", @"音量−", @"音量+", @"锁屏"];
    for (NSInteger i = 0; i < titles.count; i++) { NSButton *b = [self button:titles[i] frame:NSMakeRect(26 + (i % 4) * 69, 260 - (i / 4) * 30, 63, 25) action:@selector(quickControl:)]; b.tag = i; [c addSubview:b]; }
    [c addSubview:[self card:NSMakeRect(12, 18, 296, 194)]];
    NSTextField *apps = [self sectionLabel:@"应用" frame:NSMakeRect(26, 180, 52, 22)]; [c addSubview:apps];
    self.appLaunchMode = [[NSPopUpButton alloc] initWithFrame:NSMakeRect(78, 176, 136, 27) pullsDown:NO]; [self.appLaunchMode addItemsWithTitles:@[@"自动适配", @"DeX 桌面", @"手机竖屏"]]; self.appLaunchMode.toolTip = @"抖音等竖屏应用建议使用自动适配或手机竖屏"; [c addSubview:self.appLaunchMode];
    NSButton *reload = [self button:@"刷新" frame:NSMakeRect(222, 176, 72, 27) action:@selector(openAppLauncher:)]; [c addSubview:reload];
    NSScrollView *scroll = [[NSScrollView alloc] initWithFrame:NSMakeRect(26, 48, 268, 120)]; scroll.hasVerticalScroller = YES; scroll.borderType = NSBezelBorder;
    self.appsTable = [[NSTableView alloc] initWithFrame:scroll.bounds]; self.appsTable.headerView = nil; self.appsTable.rowHeight = 46; self.appsTable.delegate = self; self.appsTable.dataSource = self; self.appsTable.target = self; self.appsTable.doubleAction = @selector(launchSelectedApp:); NSTableColumn *col = [[NSTableColumn alloc] initWithIdentifier:@"app"]; col.width = 280; [self.appsTable addTableColumn:col]; scroll.documentView = self.appsTable; [c addSubview:scroll];
    NSTextField *tip = [self label:@"双击启动应用 · 文件可拖入镜像窗口" frame:NSMakeRect(26, 26, 268, 18)]; tip.font = [NSFont systemFontOfSize:10]; tip.textColor = NSColor.secondaryLabelColor; [c addSubview:tip];
}

- (void)showEmbeddedTools {
    if (!self.toolsPanel.hidden) return; self.toolsPanel.hidden = NO;
    NSRect frame = self.window.frame; CGFloat delta = 350; frame.origin.x -= delta / 2; frame.size.width += delta; [self.window setFrame:frame display:YES animate:YES]; self.window.minSize = NSMakeSize(1000, 650);
    [self openAppLauncher:nil];
}

- (void)quickControl:(NSButton *)sender {
    NSString *serial = self.serial, *adb = [self tool:@"adb"]; if (!serial.length) { self.status.stringValue = @"请先连接手机"; return; }
    NSArray *commands = @[@[@"input", @"keyevent", @"4"], @[@"input", @"keyevent", @"3"], @[@"input", @"keyevent", @"187"], @[@"cmd", @"statusbar", @"expand-notifications"], @[@"input", @"keyevent", @"25"], @[@"input", @"keyevent", @"24"], @[@"input", @"keyevent", @"26"]];
    NSArray *command = commands[sender.tag]; NSMutableArray *args = [NSMutableArray arrayWithObjects:@"-s", serial, @"shell", nil]; [args addObjectsFromArray:command];
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{ [self run:adb args:args]; });
}

- (NSMutableDictionary *)childEnvironment {
    NSMutableDictionary *env = [NSProcessInfo.processInfo.environment mutableCopy]; NSString *adb = [self tool:@"adb"];
    env[@"ADB"] = adb; env[@"PATH"] = [NSString stringWithFormat:@"%@:%@", adb.stringByDeletingLastPathComponent, env[@"PATH"] ?: @"/usr/bin:/bin:/usr/sbin:/sbin"];
    NSString *server = [NSBundle.mainBundle.resourcePath stringByAppendingPathComponent:@"scrcpy-server"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:server]) env[@"SCRCPY_SERVER_PATH"] = server;
    return env;
}

- (NSTask *)launchScrcpy:(NSArray *)args {
    NSString *scrcpy = [self tool:@"scrcpy"]; if (!scrcpy) return nil; NSTask *task = [NSTask new]; task.executableURL = [NSURL fileURLWithPath:scrcpy]; task.arguments = args; task.environment = [self childEnvironment];
    task.standardOutput = [NSFileHandle fileHandleWithNullDevice]; task.standardError = [NSFileHandle fileHandleWithNullDevice]; NSError *error = nil; return [task launchAndReturnError:&error] ? task : nil;
}

- (void)takeScreenshot:(id)sender {
    NSString *serial = self.serial, *adb = [self tool:@"adb"]; if (!serial.length) { self.status.stringValue = @"请先连接手机"; return; }
    NSSavePanel *save = [NSSavePanel savePanel]; save.nameFieldStringValue = [NSString stringWithFormat:@"Android-%lld.png", (long long)NSDate.date.timeIntervalSince1970]; if ([save runModal] != NSModalResponseOK) return;
    self.status.stringValue = @"正在截图…"; dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
        NSTask *task = [NSTask new]; NSPipe *pipe = [NSPipe pipe]; task.executableURL = [NSURL fileURLWithPath:adb]; task.arguments = @[@"-s", serial, @"exec-out", @"screencap", @"-p"]; task.standardOutput = pipe; task.standardError = [NSFileHandle fileHandleWithNullDevice]; [task launchAndReturnError:nil]; NSData *data = [pipe.fileHandleForReading readDataToEndOfFile]; [task waitUntilExit]; BOOL ok = task.terminationStatus == 0 && [data writeToURL:save.URL atomically:YES]; dispatch_async(dispatch_get_main_queue(), ^{ self.status.stringValue = ok ? @"截图已保存到 Mac" : @"截图失败"; });
    });
}

- (void)toggleRecording:(id)sender {
    if (self.recordTask.running) { [self.recordTask interrupt]; self.recordTask = nil; self.recordButton.title = @"开始录屏"; self.status.stringValue = @"录屏已保存"; return; }
    if (!self.serial.length) { self.status.stringValue = @"请先连接手机"; return; }
    NSSavePanel *save = [NSSavePanel savePanel]; save.nameFieldStringValue = @"Android-recording.mp4"; if ([save runModal] != NSModalResponseOK) return;
    self.recordTask = [self launchScrcpy:@[@"--serial", self.serial, @"--no-playback", [@"--record=" stringByAppendingString:save.URL.path]]];
    if (self.recordTask) { self.recordButton.title = @"停止录屏"; self.status.stringValue = @"正在后台录制手机画面与声音…"; __weak typeof(self) weakSelf = self; self.recordTask.terminationHandler = ^(NSTask *t) { dispatch_async(dispatch_get_main_queue(), ^{ weakSelf.recordTask = nil; weakSelf.recordButton.title = @"开始录屏"; }); }; } else self.status.stringValue = @"无法开始录屏";
}

- (void)startCamera:(id)sender {
    if (!self.serial.length) { self.status.stringValue = @"请先连接手机"; return; }
    NSTask *task = [self launchScrcpy:@[@"--serial", self.serial, @"--video-source=camera", @"--camera-facing=back", @"--camera-size=1920x1080", @"--audio-source=mic", @"--window-title", @"手机相机 · Scrcpy Mate"]];
    if (task) { [self.extraTasks addObject:task]; self.status.stringValue = @"手机相机已打开"; } else self.status.stringValue = @"相机启动失败；需要 Android 12 或以上";
}

- (void)startAdditionalMirror:(id)sender {
    if (!self.serial.length) { self.status.stringValue = @"请先选择设备"; return; }
    NSTask *task = [self launchScrcpy:@[@"--serial", self.serial, @"--keyboard=sdk", @"--mouse=sdk", @"--shortcut-mod=lsuper", @"--window-title", [NSString stringWithFormat:@"%@ · Scrcpy Mate", self.devices.titleOfSelectedItem]]];
    if (task) { [self.extraTasks addObject:task]; self.status.stringValue = @"已打开独立镜像；可切换设备继续打开"; } else self.status.stringValue = @"独立镜像启动失败";
}

- (void)openAppLauncher:(id)sender {
    NSString *serial = self.serial, *scrcpy = [self tool:@"scrcpy"]; if (!serial.length) { self.status.stringValue = @"请先连接手机"; return; }
    self.status.stringValue = @"正在读取应用名称…"; dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
        NSDictionary *r = [self run:scrcpy args:@[@"--serial", serial, @"--list-apps"]]; NSMutableArray *apps = [NSMutableArray array];
        NSRegularExpression *packagePattern = [NSRegularExpression regularExpressionWithPattern:@"[A-Za-z0-9_]+(?:\\.[A-Za-z0-9_]+)+" options:0 error:nil];
        NSDictionary *known = @{@"com.tencent.mm":@"微信", @"com.tencent.mobileqq":@"QQ", @"com.taobao.taobao":@"淘宝", @"com.jingdong.app.mall":@"京东", @"com.sina.weibo":@"微博", @"com.android.chrome":@"Chrome", @"com.google.android.youtube":@"YouTube"};
        for (NSString *raw in [r[@"text"] componentsSeparatedByString:@"\n"]) {
            NSArray<NSTextCheckingResult *> *matches = [packagePattern matchesInString:raw options:0 range:NSMakeRange(0, raw.length)]; if (!matches.count) continue;
            NSTextCheckingResult *match = matches.lastObject; NSString *pkg = [raw substringWithRange:match.range];
            if ([pkg hasPrefix:@"github.com"] || [pkg hasPrefix:@"Genymobile.scrcpy"]) continue;
            NSString *name = [[raw substringToIndex:match.range.location] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" *\t-[]"]];
            NSRange colon = [name rangeOfString:@"] " options:NSBackwardsSearch]; if (colon.location != NSNotFound) name = [name substringFromIndex:NSMaxRange(colon)];
            if (!name.length || [name containsString:@"INFO:"] || [name containsString:@"List of apps"]) name = known[pkg];
            if (!name.length) { NSString *last = pkg.pathExtension; name = last.length ? [last.capitalizedString stringByReplacingOccurrencesOfString:@"_" withString:@" "] : pkg; }
            [apps addObject:@{@"name":name, @"package":pkg, @"display":[NSString stringWithFormat:@"%@\n%@", name, pkg]}];
        }
        if (!apps.count) { NSDictionary *fallback = [self run:[self tool:@"adb"] args:@[@"-s", serial, @"shell", @"pm", @"list", @"packages", @"-3"]]; for (NSString *line in [fallback[@"text"] componentsSeparatedByString:@"\n"]) if ([line hasPrefix:@"package:"]) { NSString *pkg = [line substringFromIndex:8], *name = known[pkg] ?: pkg.pathExtension.capitalizedString; [apps addObject:@{@"name":name, @"package":pkg, @"display":[NSString stringWithFormat:@"%@\n%@", name, pkg]}]; } }
        [apps sortUsingComparator:^NSComparisonResult(NSDictionary *a, NSDictionary *b) { return [a[@"name"] localizedCaseInsensitiveCompare:b[@"name"]]; }];
        dispatch_async(dispatch_get_main_queue(), ^{ self.appItems = apps; [self.appsTable reloadData]; self.status.stringValue = apps.count ? [NSString stringWithFormat:@"已读取 %lu 个应用", (unsigned long)apps.count] : @"无法读取应用名称"; });
    });
}

- (void)launchSelectedApp:(id)sender {
    NSInteger row = self.appsTable.selectedRow; if (row < 0 || row >= self.appItems.count) return;
    NSDictionary *app = self.appItems[row]; NSString *pkg = app[@"package"], *serial = self.serial;
    NSArray *portraitPackages = @[@"com.tencent.mm", @"com.ss.android.ugc.aweme", @"com.zhiliaoapp.musically", @"com.smile.gifmaker", @"com.kuaishou.nebula", @"com.xingin.xhs", @"com.instagram.android"];
    BOOL knownPortrait = [portraitPackages containsObject:pkg]; BOOL portrait = self.appLaunchMode.indexOfSelectedItem == 2 || (self.appLaunchMode.indexOfSelectedItem == 0 && knownPortrait);
    if (portrait) {
        NSString *start = [@"--start-app=+" stringByAppendingString:pkg];
        NSTask *task = [self launchScrcpy:@[@"--serial", serial, @"--new-display=1080x1920/420", @"--display-orientation=0", @"--keep-active", @"--no-vd-destroy-content", start, @"--keyboard=sdk", @"--prefer-text", @"--mouse=sdk", @"--video-codec=h264", @"--video-bit-rate=8M", @"--max-fps=60", @"--window-title", [NSString stringWithFormat:@"%@ · 手机模式", app[@"name"]]]];
        if (task) { [self.extraTasks addObject:task]; self.status.stringValue = [NSString stringWithFormat:@"%@ 已用完整竖屏窗口打开", app[@"name"]]; } else self.status.stringValue = @"无法启动竖屏应用窗口";
    } else {
        NSString *adb = [self tool:@"adb"]; dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{ [self run:adb args:@[@"-s", serial, @"shell", @"monkey", @"-p", pkg, @"-c", @"android.intent.category.LAUNCHER", @"1"]]; dispatch_async(dispatch_get_main_queue(), ^{ self.status.stringValue = [NSString stringWithFormat:@"%@ 已在当前桌面打开", app[@"name"]]; }); });
    }
}

- (void)showShortcuts:(id)sender {
    NSString *device = self.devices.titleOfSelectedItem.uppercaseString ?: @"";
    NSString *brand = ([device containsString:@"SAMSUNG"] || [device hasPrefix:@"SM "]) ? @"三星 / DeX：可使用 Tab、方向键和 Enter 操作桌面；来电与短信通知可直接在镜像窗口处理。\n\n" : @"Android：系统级快捷键会因品牌和启动器而不同。\n\n";
    NSAlert *alert = [NSAlert new]; alert.messageText = @"镜像快捷键";
    alert.informativeText = [brand stringByAppendingString:@"键盘始终使用安全的 Mac 输入模式，可使用 Mac 中文输入法。实验模式只直通鼠标：\n• 按右侧 ⌘ 释放或重新捕获鼠标\n• 按 ⌃⌥⌘Esc 紧急停止镜像并恢复 Mac 控制\n\n如果 Control+Space 在镜像窗口中被 Android 接收，请用 Caps Lock 或 macOS 菜单栏切换中文输入法。\n\n⌘H：主页　⌘B：返回　⌘S：最近任务\n⌘F：全屏　⌘W：窗口适配画面　⌘G：1:1\n⌘↑ / ⌘↓：音量　⌘P：电源\n⌘N：通知栏　⌘C / ⌘X / ⌘V：复制、剪切、粘贴"];
    [alert addButtonWithTitle:@"知道了"]; [alert runModal];
}

- (void)runPhoneAction:(NSArray *)args success:(NSString *)message {
    NSString *serial = self.serial, *adb = [self tool:@"adb"];
    if (!serial.length) { self.status.stringValue = @"请先连接手机"; return; }
    NSMutableArray *full = [NSMutableArray arrayWithObjects:@"-s", serial, @"shell", @"am", @"start", nil]; [full addObjectsFromArray:args];
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{ NSDictionary *r = [self run:adb args:full]; dispatch_async(dispatch_get_main_queue(), ^{ self.status.stringValue = [r[@"code"] intValue] == 0 ? message : @"无法在手机上打开此功能"; }); });
}

- (void)openPhone:(id)sender { [self runPhoneAction:@[@"-a", @"android.intent.action.DIAL"] success:@"已在手机上打开电话"]; }
- (void)openMessages:(id)sender { [self runPhoneAction:@[@"-a", @"android.intent.action.SENDTO", @"-d", @"sms:"] success:@"已在手机上打开短信"]; }

- (void)handleDroppedURLs:(NSArray<NSURL *> *)urls {
    NSString *serial = self.serial, *adb = [self tool:@"adb"]; if (!serial.length) { self.status.stringValue = @"请先连接手机再拖放"; return; }
    NSString *destination = self.target.stringValue.length ? self.target.stringValue : @"/sdcard/Download/"; self.status.stringValue = [NSString stringWithFormat:@"正在处理 %lu 个项目…", (unsigned long)urls.count];
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
        NSInteger installed = 0, transferred = 0, failed = 0;
        for (NSURL *url in urls) {
            NSDictionary *result;
            if ([url.pathExtension.lowercaseString isEqualToString:@"apk"]) { result = [self run:adb args:@[@"-s", serial, @"install", @"-r", url.path]]; if ([result[@"code"] intValue] == 0) installed++; else failed++; }
            else { result = [self run:adb args:@[@"-s", serial, @"push", url.path, destination]]; if ([result[@"code"] intValue] == 0) transferred++; else failed++; }
        }
        dispatch_async(dispatch_get_main_queue(), ^{ self.status.stringValue = [NSString stringWithFormat:@"拖放完成：安装 %ld，传输 %ld，失败 %ld", (long)installed, (long)transferred, (long)failed]; });
    });
}

- (void)pasteImageToPhone:(id)sender {
    NSPasteboard *pasteboard = NSPasteboard.generalPasteboard;
    NSData *png = [pasteboard dataForType:NSPasteboardTypePNG];
    if (!png) { NSData *tiff = [pasteboard dataForType:NSPasteboardTypeTIFF]; if (tiff) { NSBitmapImageRep *rep = [NSBitmapImageRep imageRepWithData:tiff]; png = [rep representationUsingType:NSBitmapImageFileTypePNG properties:@{}]; } }
    if (!png.length) { self.status.stringValue = @"Mac 剪贴板中没有图片"; return; }
    NSString *serial = self.serial, *adb = [self tool:@"adb"]; if (!serial.length) { self.status.stringValue = @"请先连接手机"; return; }
    NSString *name = [NSString stringWithFormat:@"ScrcpyMate-%lld.png", (long long)(NSDate.date.timeIntervalSince1970 * 1000)];
    NSString *local = [NSTemporaryDirectory() stringByAppendingPathComponent:name]; [png writeToFile:local atomically:YES];
    NSString *remoteDir = @"/sdcard/Pictures/ScrcpyMate/", *remote = [remoteDir stringByAppendingString:name]; self.status.stringValue = @"正在把剪贴板图片传到手机…";
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
        [self run:adb args:@[@"-s", serial, @"shell", @"mkdir", @"-p", remoteDir]];
        NSDictionary *push = [self run:adb args:@[@"-s", serial, @"push", local, remote]];
        if ([push[@"code"] intValue] == 0) [self run:adb args:@[@"-s", serial, @"shell", @"am", @"broadcast", @"-a", @"android.intent.action.MEDIA_SCANNER_SCAN_FILE", @"-d", [@"file://" stringByAppendingString:remote]]];
        [[NSFileManager defaultManager] removeItemAtPath:local error:nil];
        dispatch_async(dispatch_get_main_queue(), ^{ self.status.stringValue = [push[@"code"] intValue] == 0 ? @"图片已保存到手机相册：Pictures/ScrcpyMate" : @"图片传输失败"; });
    });
}

- (void)dexScaleChanged:(NSSlider *)sender {
    NSInteger density = ((NSInteger)(sender.doubleValue + 2.5) / 5) * 5;
    sender.doubleValue = density;
    NSString *size = density < 175 ? @"标准" : (density < 215 ? @"较大" : @"特大");
    self.dexScaleValue.stringValue = [NSString stringWithFormat:@"字体大小：%@（%ld）", size, (long)density];
    [self mirrorSettingChanged:sender];
}

- (void)mirrorSettingChanged:(id)sender {
    if (!self.mirrorTask.running || self.pendingSettingsRestart) return;
    self.pendingSettingsRestart = YES;
    self.pendingRestartWireless = self.forceWirelessNext || [self.mirrorTask.arguments containsObject:self.verifiedWiFiSerial ?: @""];
    self.userStoppingMirror = YES;
    self.status.stringValue = @"正在后台应用新设置…";
    [self.mirrorTask interrupt];
}

- (void)screenPowerChanged:(NSButton *)sender {
    NSString *serial = self.serial, *adb = [self tool:@"adb"];
    if (!serial.length || !adb.length) return;
    NSString *key = sender.state == NSControlStateValueOn ? @"223" : @"224";
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
        [self run:adb args:@[@"-s", serial, @"shell", @"input", @"keyevent", key]];
        dispatch_async(dispatch_get_main_queue(), ^{ self.status.stringValue = sender.state == NSControlStateValueOn ? @"手机屏幕已关闭，镜像继续运行" : @"手机屏幕已唤醒"; });
    });
}

- (void)toggleMirror:(id)sender {
    if (self.mirrorTask.running) { self.userStoppingMirror = YES; [self.mirrorTask interrupt]; return; }
    BOOL usingWireless = self.forceWirelessNext;
    BOOL retrying = self.reconnecting; self.reconnecting = NO; if (!retrying) self.reconnectAttempts = 0;
    NSString *scrcpy = [self tool:@"scrcpy"], *serial = usingWireless ? self.verifiedWiFiSerial : self.serial;
    self.forceWirelessNext = NO;
    if (!scrcpy || !serial.length) { self.status.stringValue = @"请先连接并选择手机"; return; }
    self.userStoppingMirror = NO;
    BOOL automaticTCPIP = NO;
    NSMutableArray *a = [NSMutableArray array];
    [a addObjectsFromArray:@[@"--serial", serial]];
    [a addObjectsFromArray:@[@"--window-title", @"手机 · Scrcpy Mate"]];
    switch (self.audio.indexOfSelectedItem) { case 0: [a addObject:@"--audio-source=output"]; break; case 1: [a addObjectsFromArray:@[@"--audio-source=playback", @"--audio-dup"]]; break; case 2: [a addObject:@"--audio-source=mic"]; break; default: [a addObject:@"--no-audio"]; }
    if (self.audio.indexOfSelectedItem != 3) [a addObjectsFromArray:usingWireless ? @[@"--audio-buffer=160", @"--audio-output-buffer=30"] : @[@"--audio-buffer=80", @"--audio-output-buffer=20"]];
    if (self.dexMode.state == NSControlStateValueOn) {
        // Use a larger 16:9 desktop canvas at low density. This keeps DeX apps
        // comfortably desktop-sized without forcing per-app font overrides.
        NSInteger density = ((NSInteger)(self.dexScale.doubleValue + 2.5) / 5) * 5;
        NSString *display = [NSString stringWithFormat:@"--new-display=2560x1440/%ld", (long)density];
        [a addObjectsFromArray:@[display, @"--display-orientation=0", @"--keep-active", @"--no-vd-destroy-content", @"--render-driver=metal"]];
        if (usingWireless) [a addObjectsFromArray:@[@"--video-codec=h264", @"--video-bit-rate=12M", @"--max-fps=60"]];
        else [a addObjectsFromArray:@[@"--video-codec=h265", @"--video-bit-rate=16M"]];
    } else {
        NSInteger maxSize = self.quality.titleOfSelectedItem.integerValue;
        if (maxSize > 0) [a addObjectsFromArray:@[@"--max-size", [NSString stringWithFormat:@"%ld", (long)maxSize]]];
    }
    NSString *profile = self.profile.titleOfSelectedItem ?: @"平衡";
    if ([profile isEqualToString:@"高画质"]) [a addObjectsFromArray:@[@"--video-codec=h264", @"--video-bit-rate=20M", @"--max-fps=60"]];
    else if ([profile isEqualToString:@"流畅"]) [a addObjectsFromArray:@[@"--video-codec=h264", @"--video-bit-rate=8M", @"--max-fps=60", @"--max-size=1920"]];
    else if ([profile isEqualToString:@"低延迟"]) [a addObjectsFromArray:@[@"--video-codec=h264", @"--video-bit-rate=6M", @"--max-fps=60", @"--video-buffer=0"]];
    else if ([profile isEqualToString:@"演示模式"]) [a addObjectsFromArray:@[@"--video-codec=h265", @"--video-bit-rate=12M", @"--max-fps=30"]];
    BOOL physical = self.physicalInput && self.physicalInput.state == NSControlStateValueOn;
    BOOL phoneKeyboard = self.keyboardMode && self.keyboardMode.indexOfSelectedItem == 1;
    [a addObject:(physical || phoneKeyboard) ? @"--shortcut-mod=rsuper" : @"--shortcut-mod=lsuper"];
    if (self.keyboardControl.state != NSControlStateValueOn) [a addObject:@"--keyboard=disabled"];
    else if (phoneKeyboard) [a addObject:@"--keyboard=uhid"];
    else [a addObjectsFromArray:@[@"--keyboard=sdk", @"--prefer-text"]];
    [a addObject:self.mouseControl.state == NSControlStateValueOn ? (physical ? @"--mouse=uhid" : @"--mouse=sdk") : @"--mouse=disabled"];
    if (self.gamepadControl.state == NSControlStateValueOn) [a addObject:@"--gamepad=uhid"];
    if (self.target.stringValue.length) [a addObject:[@"--push-target=" stringByAppendingString:self.target.stringValue]];
    if (self.stayAwake.state == NSControlStateValueOn) [a addObject:@"--stay-awake"];
    if (self.screenOff.state == NSControlStateValueOn) [a addObject:@"--turn-screen-off"];
    if (self.alwaysOnTop.state == NSControlStateValueOn) [a addObject:@"--always-on-top"];
    self.mirrorTask = [NSTask new]; self.mirrorTask.executableURL = [NSURL fileURLWithPath:scrcpy]; self.mirrorTask.arguments = a;
    NSString *adbPath = [self tool:@"adb"];
    self.mirrorTask.environment = [self childEnvironment];
    NSString *logPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"ScrcpyMate-last.log"];
    [[NSFileManager defaultManager] createFileAtPath:logPath contents:nil attributes:nil];
    NSFileHandle *logHandle = [NSFileHandle fileHandleForWritingAtPath:logPath];
    self.mirrorTask.standardOutput = logHandle; self.mirrorTask.standardError = logHandle;
    __weak typeof(self) weakSelf = self;
    self.mirrorTask.terminationHandler = ^(NSTask *t) { dispatch_async(dispatch_get_main_queue(), ^{
        [logHandle closeFile];
        weakSelf.startButton.title = @"开始镜像";
        NSString *detail = [[NSString stringWithContentsOfFile:logPath encoding:NSUTF8StringEncoding error:nil] stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
        NSArray *lines = [detail componentsSeparatedByString:@"\n"];
        NSString *finalLine = (NSString *)lines.lastObject;
        NSString *last = finalLine.length ? finalLine : (lines.count > 1 ? lines[lines.count - 2] : @"");
        for (NSString *line in [lines reverseObjectEnumerator]) if ([line containsString:@"ERROR:"] || [line hasPrefix:@"adb:"] || [line containsString:@"WARN:"]) { last = line; break; }
        weakSelf.status.stringValue = last.length ? [NSString stringWithFormat:@"镜像停止（代码 %d）：%@", t.terminationStatus, last] : [NSString stringWithFormat:@"镜像停止（代码 %d）", t.terminationStatus];
        weakSelf.mirrorTask = nil;
        if (weakSelf.pendingSettingsRestart) {
            BOOL restartWireless = weakSelf.pendingRestartWireless;
            weakSelf.pendingSettingsRestart = NO; weakSelf.pendingRestartWireless = NO; weakSelf.userStoppingMirror = NO;
            weakSelf.status.stringValue = @"设置已更新，正在恢复镜像…";
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 350 * NSEC_PER_MSEC), dispatch_get_main_queue(), ^{ weakSelf.forceWirelessNext = restartWireless; [weakSelf toggleMirror:nil]; });
            return;
        }
        if (!weakSelf.userStoppingMirror && weakSelf.autoReconnect.state == NSControlStateValueOn && t.terminationStatus != 0 && weakSelf.reconnectAttempts < 3) {
            weakSelf.reconnectAttempts += 1; weakSelf.reconnecting = YES;
            weakSelf.status.stringValue = [NSString stringWithFormat:@"连接中断，正在重试（%ld/3）…", (long)weakSelf.reconnectAttempts];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{ weakSelf.forceWirelessNext = usingWireless; [weakSelf toggleMirror:nil]; });
            return;
        }
        if (weakSelf.reconnectAttempts >= 3) weakSelf.status.stringValue = @"自动重连已停止（达到 3 次限制），请检查连接后手动启动";
        if (automaticTCPIP && !weakSelf.userStoppingMirror && t.terminationStatus != 0) {
            weakSelf.status.stringValue = @"Wi‑Fi 自动连接失败，正在恢复 USB 镜像…";
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
                BOOL ready = NO;
                for (NSInteger i = 0; i < 20 && !ready; i++) { NSDictionary *probe = [weakSelf run:adbPath args:@[@"-s", serial, @"shell", @"echo", @"READY"]]; ready = [probe[@"code"] intValue] == 0; if (!ready) [NSThread sleepForTimeInterval:0.5]; }
                dispatch_async(dispatch_get_main_queue(), ^{ if (ready) { weakSelf.autoWiFi.state = NSControlStateValueOff; [weakSelf toggleMirror:nil]; weakSelf.autoWiFi.state = NSControlStateValueOn; } else weakSelf.status.stringValue = @"Wi‑Fi 失败，USB 尚未恢复；请拔插数据线后刷新"; });
            });
        }
    }); };
    NSError *error; if ([self.mirrorTask launchAndReturnError:&error]) { NSTask *launchedTask = self.mirrorTask; self.startButton.title = @"停止镜像"; self.status.stringValue = usingWireless ? @"无线镜像运行中；低延迟画面与稳定音频已启用" : @"镜像运行中；拖动窗口边缘即可缩放"; dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 700 * NSEC_PER_MSEC), dispatch_get_main_queue(), ^{ if (launchedTask.running) [self.window orderOut:nil]; }); dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 4 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{ [self refresh:nil]; }); dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 10 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{ if (self.mirrorTask == launchedTask && launchedTask.running) self.reconnectAttempts = 0; }); } else self.status.stringValue = error.localizedDescription;
}

- (void)startWirelessMirror:(id)sender {
    if (!self.verifiedWiFiSerial.length) { self.wirelessButton.hidden = YES; self.status.stringValue = @"无线连接尚未通过测试，请使用 USB 镜像"; return; }
    self.forceWirelessNext = YES; [self toggleMirror:sender];
}

- (void)upload:(id)sender {
    NSString *serial = self.serial; if (!serial.length) { self.status.stringValue = @"请先连接手机"; return; }
    NSOpenPanel *p = [NSOpenPanel openPanel]; p.allowsMultipleSelection = YES; p.canChooseDirectories = NO;
    if ([p runModal] != NSModalResponseOK) return; self.status.stringValue = @"正在上传…";
    NSString *adb = [self tool:@"adb"], *target = self.target.stringValue;
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{ BOOL ok = YES; for (NSURL *u in p.URLs) if ([[self run:adb args:@[@"-s", serial, @"push", u.path, target]][@"code"] intValue] != 0) ok = NO; dispatch_async(dispatch_get_main_queue(), ^{ self.status.stringValue = ok ? [NSString stringWithFormat:@"文件已传到 %@", target] : @"上传失败，请检查连接和目录"; }); });
}

- (void)download:(id)sender {
    NSString *serial = self.serial; if (!serial.length) { self.status.stringValue = @"请先连接手机"; return; }
    NSAlert *a = [NSAlert new]; a.messageText = @"从手机下载"; a.informativeText = @"输入手机中的完整文件路径";
    NSTextField *field = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 380, 24)]; field.stringValue = @"/sdcard/Download/"; a.accessoryView = field; [a addButtonWithTitle:@"选择保存位置"]; [a addButtonWithTitle:@"取消"];
    if ([a runModal] != NSAlertFirstButtonReturn || !field.stringValue.length) return;
    NSSavePanel *save = [NSSavePanel savePanel]; save.nameFieldStringValue = field.stringValue.lastPathComponent; if ([save runModal] != NSModalResponseOK) return;
    NSString *adb = [self tool:@"adb"], *source = field.stringValue, *dest = save.URL.path; self.status.stringValue = @"正在下载…";
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{ NSDictionary *r = [self run:adb args:@[@"-s", serial, @"pull", source, dest]]; dispatch_async(dispatch_get_main_queue(), ^{ self.status.stringValue = [r[@"code"] intValue] == 0 ? @"文件已保存到电脑" : @"下载失败，请检查手机文件路径"; }); });
}

- (NSString *)quoted:(NSString *)value {
    NSString *s = [value stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"];
    s = [s stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    s = [s stringByReplacingOccurrencesOfString:@"$" withString:@"\\$"];
    s = [s stringByReplacingOccurrencesOfString:@"`" withString:@"\\`"];
    return [NSString stringWithFormat:@"\"%@\"", s];
}

- (void)openFileManager:(id)sender {
    if (!self.serial.length) { self.status.stringValue = @"请先连接并选择手机"; return; }
    if (self.filePanelTransitioning) return;
    self.filePanelTransitioning = YES; self.filePanelGeneration += 1;
    const CGFloat delta = 300;
    if (self.filePanelExpanded) {
        self.localTable.dataSource = nil; self.localTable.delegate = nil;
        self.remoteTable.dataSource = nil; self.remoteTable.delegate = nil;
        [self.filePanel removeFromSuperview]; self.filePanel = nil; self.filePanelExpanded = NO;
        for (NSView *view in self.window.contentView.subviews) { NSRect f = view.frame; f.origin.y -= delta; view.frame = f; }
        NSRect frame = self.window.frame; frame.origin.y += delta; frame.size.height -= delta; [self.window setFrame:frame display:YES animate:YES];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 450 * NSEC_PER_MSEC), dispatch_get_main_queue(), ^{ self.filePanelTransitioning = NO; });
        return;
    }
    self.filePanelExpanded = YES;
    for (NSView *view in self.window.contentView.subviews) { NSRect f = view.frame; f.origin.y += delta; view.frame = f; }
    NSRect frame = self.window.frame; frame.origin.y -= delta; frame.size.height += delta; [self.window setFrame:frame display:YES animate:YES];
    CGFloat width = NSWidth(self.window.contentView.bounds) - 36;
    self.filePanel = [[NSView alloc] initWithFrame:NSMakeRect(18, 12, width, 280)]; NSView *c = self.filePanel; [self.window.contentView addSubview:c];
    [c addSubview:[self card:NSMakeRect(0, 0, width, 280)]];
    NSTextField *leftTitle = [self sectionLabel:@"Mac" frame:NSMakeRect(16, 244, 100, 24)]; [c addSubview:leftTitle];
    NSTextField *rightTitle = [self sectionLabel:@"手机" frame:NSMakeRect(width / 2 + 46, 244, 100, 24)]; [c addSubview:rightTitle];
    CGFloat pane = (width - 150) / 2;
    [c addSubview:[self button:@"返回上级" frame:NSMakeRect(16, 214, 88, 26) action:@selector(localUp:)]];
    self.localPathField = [[NSTextField alloc] initWithFrame:NSMakeRect(110, 214, pane - 94, 26)]; self.localPathField.stringValue = [NSHomeDirectory() stringByAppendingPathComponent:@"Downloads"]; [c addSubview:self.localPathField];
    [c addSubview:[self button:@"返回上级" frame:NSMakeRect(pane + 134, 214, 88, 26) action:@selector(remoteUp:)]];
    self.remotePathField = [[NSTextField alloc] initWithFrame:NSMakeRect(pane + 228, 214, pane - 94, 26)]; self.remotePathField.stringValue = self.target.stringValue.length ? self.target.stringValue : @"/sdcard/Download/"; [c addSubview:self.remotePathField];
    NSScrollView *localScroll = [[NSScrollView alloc] initWithFrame:NSMakeRect(16, 48, pane, 158)]; localScroll.hasVerticalScroller = YES; localScroll.borderType = NSBezelBorder;
    self.localTable = [[NSTableView alloc] initWithFrame:localScroll.bounds]; self.localTable.headerView = nil; self.localTable.delegate = self; self.localTable.dataSource = self; self.localTable.target = self; self.localTable.doubleAction = @selector(localDoubleClick:); NSTableColumn *localColumn = [[NSTableColumn alloc] initWithIdentifier:@"local"]; localColumn.width = pane - 20; [self.localTable addTableColumn:localColumn]; localScroll.documentView = self.localTable; [c addSubview:localScroll];
    NSScrollView *remoteScroll = [[NSScrollView alloc] initWithFrame:NSMakeRect(pane + 134, 48, pane, 158)]; remoteScroll.hasVerticalScroller = YES; remoteScroll.borderType = NSBezelBorder;
    self.remoteTable = [[NSTableView alloc] initWithFrame:remoteScroll.bounds]; self.remoteTable.headerView = nil; self.remoteTable.delegate = self; self.remoteTable.dataSource = self; self.remoteTable.target = self; self.remoteTable.doubleAction = @selector(remoteDoubleClick:); NSTableColumn *remoteColumn = [[NSTableColumn alloc] initWithIdentifier:@"remote"]; remoteColumn.width = pane - 20; [self.remoteTable addTableColumn:remoteColumn]; remoteScroll.documentView = self.remoteTable; [c addSubview:remoteScroll];
    [c addSubview:[self button:@"上传 →" frame:NSMakeRect(pane + 30, 145, 86, 30) action:@selector(fileManagerUpload:)]];
    [c addSubview:[self button:@"← 下载" frame:NSMakeRect(pane + 30, 105, 86, 30) action:@selector(fileManagerDownload:)]];
    [c addSubview:[self button:@"新建文件夹" frame:NSMakeRect(pane + 30, 65, 86, 30) action:@selector(remoteMkdir:)]];
    self.fileStatus = [self label:@"双击文件夹进入；选择项目后用中间按钮双向传输" frame:NSMakeRect(16, 16, width - 68, 24)]; self.fileStatus.textColor = NSColor.secondaryLabelColor; [c addSubview:self.fileStatus];
    self.remoteItems = [NSMutableArray array]; self.localItems = [NSMutableArray array]; [self refreshLocal:nil]; [self refreshRemote:nil];
    if (self.englishUI) [self applyLanguageToView:self.filePanel];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 450 * NSEC_PER_MSEC), dispatch_get_main_queue(), ^{ self.filePanelTransitioning = NO; });
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView { if (tableView == self.appsTable) return self.appItems.count; return tableView == self.localTable ? self.localItems.count : self.remoteItems.count; }
- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    if (tableView == self.appsTable) return row >= 0 && row < self.appItems.count ? self.appItems[row][@"display"] : @"";
    NSArray *items = tableView == self.localTable ? self.localItems : self.remoteItems; if (row < 0 || row >= items.count) return @"";
    NSDictionary *item = items[row]; return [NSString stringWithFormat:@"%@  %@", [item[@"dir"] boolValue] ? @"📁" : @"📄", item[@"name"] ?: @""];
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    if (tableView != self.appsTable) { NSTableCellView *cell = [tableView makeViewWithIdentifier:@"FileCell" owner:self]; if (!cell) { cell = [[NSTableCellView alloc] initWithFrame:NSMakeRect(0, 0, tableColumn.width, 24)]; cell.identifier = @"FileCell"; NSTextField *text = [self label:@"" frame:NSMakeRect(6, 2, tableColumn.width - 12, 20)]; cell.textField = text; [cell addSubview:text]; } NSArray *items = tableView == self.localTable ? self.localItems : self.remoteItems; if (row < 0 || row >= items.count) { cell.textField.stringValue = @""; return cell; } NSDictionary *item = items[row]; cell.textField.stringValue = [NSString stringWithFormat:@"%@  %@", [item[@"dir"] boolValue] ? @"📁" : @"📄", item[@"name"] ?: @""]; return cell; }
    NSDictionary *app = self.appItems[row];
    NSTableCellView *cell = [tableView makeViewWithIdentifier:@"AppCell" owner:self];
    if (!cell) { cell = [[NSTableCellView alloc] initWithFrame:NSMakeRect(0, 0, 280, 44)]; cell.identifier = @"AppCell"; NSImageView *icon = [[NSImageView alloc] initWithFrame:NSMakeRect(5, 7, 30, 30)]; cell.imageView = icon; [cell addSubview:icon]; NSTextField *text = [self label:@"" frame:NSMakeRect(44, 4, 230, 38)]; text.maximumNumberOfLines = 2; cell.textField = text; [cell addSubview:text]; }
    cell.imageView.image = [NSImage imageWithSystemSymbolName:@"app.fill" accessibilityDescription:@"应用"];
    NSMutableAttributedString *value = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n%@", app[@"name"], app[@"package"]]]; [value addAttribute:NSFontAttributeName value:[NSFont systemFontOfSize:13 weight:NSFontWeightMedium] range:NSMakeRange(0, [app[@"name"] length])]; [value addAttribute:NSForegroundColorAttributeName value:NSColor.secondaryLabelColor range:NSMakeRange([app[@"name"] length] + 1, [app[@"package"] length])]; [value addAttribute:NSFontAttributeName value:[NSFont systemFontOfSize:10] range:NSMakeRange([app[@"name"] length] + 1, [app[@"package"] length])]; cell.textField.attributedStringValue = value; return cell;
}

- (void)refreshLocal:(id)sender {
    NSString *path = [self.localPathField.stringValue stringByStandardizingPath]; BOOL isDir = NO;
    if (![[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir] || !isDir) { self.fileStatus.stringValue = @"Mac 文件夹不存在"; return; }
    self.localPathField.stringValue = path; NSError *error = nil;
    NSArray<NSString *> *names = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:&error]; NSMutableArray *items = [NSMutableArray array];
    for (NSString *name in [names sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]) { if ([name hasPrefix:@"."]) continue; BOOL dir = NO; [[NSFileManager defaultManager] fileExistsAtPath:[path stringByAppendingPathComponent:name] isDirectory:&dir]; [items addObject:@{@"name":name, @"dir":@(dir)}]; }
    self.localItems = items; [self.localTable reloadData]; if (error) self.fileStatus.stringValue = @"无法读取 Mac 文件夹";
}

- (NSDictionary *)selectedLocalItem { NSInteger row = self.localTable.selectedRow; return row >= 0 && row < self.localItems.count ? self.localItems[row] : nil; }
- (NSString *)selectedLocalPath { NSDictionary *item = self.selectedLocalItem; return item ? [self.localPathField.stringValue stringByAppendingPathComponent:item[@"name"]] : nil; }
- (void)localDoubleClick:(id)sender { NSDictionary *item = self.selectedLocalItem; if ([item[@"dir"] boolValue]) { self.localPathField.stringValue = self.selectedLocalPath; [self refreshLocal:nil]; } }
- (void)localUp:(id)sender { NSString *p = [self.localPathField.stringValue stringByDeletingLastPathComponent]; self.localPathField.stringValue = p.length ? p : @"/"; [self refreshLocal:nil]; }

- (void)refreshRemote:(id)sender {
    NSString *serial = self.serial, *path = [self.remotePathField.stringValue stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
    if (!path.length) path = @"/sdcard/"; self.remotePathField.stringValue = path; self.fileStatus.stringValue = @"正在读取…";
    NSUInteger generation = self.filePanelGeneration;
    NSString *cmd = [NSString stringWithFormat:@"ls -1p -A %@ 2>/dev/null", [self quoted:path]], *adb = [self tool:@"adb"];
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{ NSDictionary *r = [self run:adb args:@[@"-s", serial, @"shell", @"sh", @"-c", [self quoted:cmd]]]; NSMutableArray *items = [NSMutableArray array]; for (NSString *line in [r[@"text"] componentsSeparatedByString:@"\n"]) if (line.length) { BOOL dir = [line hasSuffix:@"/"]; NSString *name = dir ? [line substringToIndex:line.length - 1] : line; [items addObject:@{ @"name": name, @"dir": @(dir) }]; } dispatch_async(dispatch_get_main_queue(), ^{ if (!self.filePanelExpanded || generation != self.filePanelGeneration) return; self.remoteItems = items; [self.remoteTable reloadData]; self.fileStatus.stringValue = [r[@"code"] intValue] == 0 ? [NSString stringWithFormat:@"%@ · %lu 项", path, (unsigned long)items.count] : @"无法读取此目录"; }); });
}

- (NSDictionary *)selectedRemoteItem { NSInteger row = self.remoteTable.selectedRow; return row >= 0 && row < self.remoteItems.count ? self.remoteItems[row] : nil; }
- (NSString *)selectedRemotePath { NSDictionary *item = self.selectedRemoteItem; return item ? [self.remotePathField.stringValue stringByAppendingPathComponent:item[@"name"]] : nil; }
- (void)remoteDoubleClick:(id)sender { NSDictionary *item = self.selectedRemoteItem; if ([item[@"dir"] boolValue]) { self.remotePathField.stringValue = [self selectedRemotePath]; [self refreshRemote:nil]; } }
- (void)remoteUp:(id)sender { NSString *p = [self.remotePathField.stringValue stringByDeletingLastPathComponent]; self.remotePathField.stringValue = p.length ? p : @"/"; [self refreshRemote:nil]; }

- (void)fileManagerUpload:(id)sender {
    NSString *source = self.selectedLocalPath; if (!source) { self.fileStatus.stringValue = @"请先在左侧选择 Mac 文件或文件夹"; return; }
    NSString *serial = self.serial, *dest = self.remotePathField.stringValue, *adb = [self tool:@"adb"]; self.fileStatus.stringValue = @"正在上传到手机…";
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{ NSDictionary *r = [self run:adb args:@[@"-s", serial, @"push", source, dest]]; dispatch_async(dispatch_get_main_queue(), ^{ self.fileStatus.stringValue = [r[@"code"] intValue] == 0 ? @"上传完成" : @"上传失败"; [self refreshRemote:nil]; }); });
}

- (void)fileManagerDownload:(id)sender {
    NSString *source = self.selectedRemotePath; if (!source) { self.fileStatus.stringValue = @"请先选择文件或文件夹"; return; }
    NSString *serial = self.serial, *adb = [self tool:@"adb"], *dest = self.localPathField.stringValue; self.fileStatus.stringValue = @"正在下载到 Mac…";
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{ NSDictionary *r = [self run:adb args:@[@"-s", serial, @"pull", source, dest]]; dispatch_async(dispatch_get_main_queue(), ^{ self.fileStatus.stringValue = [r[@"code"] intValue] == 0 ? @"下载完成" : @"下载失败"; [self refreshLocal:nil]; }); });
}

- (NSString *)askName:(NSString *)title initial:(NSString *)initial {
    NSAlert *a = [NSAlert new]; a.messageText = title; NSTextField *f = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 320, 24)]; f.stringValue = initial ?: @""; a.accessoryView = f; [a addButtonWithTitle:@"确定"]; [a addButtonWithTitle:@"取消"]; return [a runModal] == NSAlertFirstButtonReturn ? f.stringValue : nil;
}
- (void)remoteMkdir:(id)sender { NSString *name = [self askName:@"新建文件夹" initial:@""]; if (!name.length || [name containsString:@"/"]) return; [self runRemoteCommand:[NSString stringWithFormat:@"mkdir -p %@", [self quoted:[self.remotePathField.stringValue stringByAppendingPathComponent:name]]]]; }
- (void)remoteRename:(id)sender { NSString *old = self.selectedRemotePath; if (!old) return; NSString *name = [self askName:@"重命名" initial:self.selectedRemoteItem[@"name"]]; if (!name.length || [name containsString:@"/"]) return; NSString *newPath = [self.remotePathField.stringValue stringByAppendingPathComponent:name]; [self runRemoteCommand:[NSString stringWithFormat:@"mv %@ %@", [self quoted:old], [self quoted:newPath]]]; }
- (void)remoteDelete:(id)sender { NSString *path = self.selectedRemotePath; if (!path) return; NSAlert *a = [NSAlert new]; a.messageText = @"确定永久删除？"; a.informativeText = path; [a addButtonWithTitle:@"删除"]; [a addButtonWithTitle:@"取消"]; if ([a runModal] != NSAlertFirstButtonReturn) return; [self runRemoteCommand:[NSString stringWithFormat:@"rm -rf %@", [self quoted:path]]]; }
- (void)runRemoteCommand:(NSString *)cmd { NSString *serial = self.serial, *adb = [self tool:@"adb"]; self.fileStatus.stringValue = @"正在处理…"; dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{ NSDictionary *r = [self run:adb args:@[@"-s", serial, @"shell", @"sh", @"-c", [self quoted:cmd]]]; dispatch_async(dispatch_get_main_queue(), ^{ self.fileStatus.stringValue = [r[@"code"] intValue] == 0 ? @"完成" : @"操作失败"; [self refreshRemote:nil]; }); }); }
- (void)openDownloads:(id)sender { [NSWorkspace.sharedWorkspace openURL:[NSURL fileURLWithPath:[NSHomeDirectory() stringByAppendingPathComponent:@"Downloads"]]]; }

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender { return NO; }

- (void)emergencyReleaseInput {
    self.userStoppingMirror = YES; self.reconnecting = NO; self.reconnectAttempts = 0;
    if (self.autoReconnect) self.autoReconnect.state = NSControlStateValueOff;
    if (self.physicalInput) self.physicalInput.state = NSControlStateValueOff;
    if (self.mirrorTask.running) [self.mirrorTask terminate];
    self.status.stringValue = @"已紧急停止镜像并关闭硬件直通；Mac 控制已恢复";
    [NSApp activateIgnoringOtherApps:YES]; [self.window makeKeyAndOrderFront:nil];
}
@end

static OSStatus ScrcpyMateHotKeyHandler(EventHandlerCallRef nextHandler, EventRef event, void *userData) {
    EventHotKeyID hotKeyID = {0};
    GetEventParameter(event, kEventParamDirectObject, typeEventHotKeyID, NULL, sizeof(hotKeyID), NULL, &hotKeyID);
    if (hotKeyID.id == 1) [gAppDelegate emergencyReleaseInput];
    else if (hotKeyID.id == 2) [gAppDelegate toggleControlPanel:nil];
    else if (hotKeyID.id == 3) [gAppDelegate toggleInputLanguage:nil];
    return noErr;
}

int main(int argc, const char *argv[]) {
    @autoreleasepool { NSApplication *app = [NSApplication sharedApplication]; AppDelegate *delegate = [AppDelegate new]; app.delegate = delegate; [app run]; }
    return 0;
}
