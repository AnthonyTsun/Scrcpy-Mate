#import <Cocoa/Cocoa.h>
#import <CoreImage/CoreImage.h>
#import <Carbon/Carbon.h>
#import <netdb.h>

@class AppDelegate;
static AppDelegate *gAppDelegate;
static OSStatus ScrcpyMateHotKeyHandler(EventHandlerCallRef nextHandler, EventRef event, void *userData);

@interface GlassBackgroundView : NSView
@end

@implementation GlassBackgroundView
- (instancetype)initWithFrame:(NSRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.wantsLayer = YES;
    }
    return self;
}
- (BOOL)mouseDownCanMoveWindow { return YES; }
- (void)mouseDown:(NSEvent *)event { [self.window performWindowDragWithEvent:event]; }
- (void)drawRect:(NSRect)dirtyRect {
    BOOL dark = [[[self effectiveAppearance] bestMatchFromAppearancesWithNames:@[NSAppearanceNameDarkAqua, NSAppearanceNameAqua]] isEqualToString:NSAppearanceNameDarkAqua];
    NSColor *top = dark ? [NSColor colorWithRed:0.105 green:0.12 blue:0.15 alpha:1] : [NSColor colorWithRed:0.975 green:0.987 blue:1.0 alpha:1];
    NSColor *bottom = dark ? [NSColor colorWithRed:0.07 green:0.085 blue:0.115 alpha:1] : [NSColor colorWithRed:0.90 green:0.95 blue:1.0 alpha:1];
    [[[NSGradient alloc] initWithStartingColor:top endingColor:bottom] drawInRect:self.bounds angle:-90];
    [[NSColor colorWithRed:0.40 green:0.67 blue:1 alpha:0.10] setFill];
    [[NSBezierPath bezierPathWithOvalInRect:NSMakeRect(-180, 360, 620, 520)] fill];
    [[NSColor colorWithWhite:1 alpha:0.48] setFill];
    [[NSBezierPath bezierPathWithOvalInRect:NSMakeRect(690, 180, 700, 650)] fill];
}
@end

@interface SettingsSidebarView : NSVisualEffectView
@end

@implementation SettingsSidebarView
- (instancetype)initWithFrame:(NSRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.material = NSVisualEffectMaterialSidebar; self.blendingMode = NSVisualEffectBlendingModeBehindWindow;
        self.state = NSVisualEffectStateFollowsWindowActiveState; self.emphasized = YES; self.wantsLayer = YES;
        self.layer.borderWidth = 0; self.layer.backgroundColor = NSColor.clearColor.CGColor;
    }
    return self;
}
- (BOOL)mouseDownCanMoveWindow { return YES; }
- (void)mouseDown:(NSEvent *)event { [self.window performWindowDragWithEvent:event]; }
- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    BOOL dark = [[[self effectiveAppearance] bestMatchFromAppearancesWithNames:@[NSAppearanceNameDarkAqua, NSAppearanceNameAqua]] isEqualToString:NSAppearanceNameDarkAqua];
    NSColor *top = [NSColor colorWithWhite:1 alpha:dark ? 0.035 : 0.16]; NSColor *bottom = [NSColor colorWithRed:0.28 green:0.58 blue:1 alpha:dark ? 0.045 : 0.07]; [[[NSGradient alloc] initWithStartingColor:top endingColor:bottom] drawInRect:self.bounds angle:-75];
    [[NSColor colorWithWhite:1 alpha:0.56] setStroke];
    NSBezierPath *edge = [NSBezierPath bezierPath]; [edge moveToPoint:NSMakePoint(NSMaxX(self.bounds)-0.5, 0)]; [edge lineToPoint:NSMakePoint(NSMaxX(self.bounds)-0.5, NSMaxY(self.bounds))]; [edge stroke];
}
@end

@interface GlassCardView : NSView
@end


@implementation GlassCardView
- (instancetype)initWithFrame:(NSRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.wantsLayer = YES;
        self.layer.cornerRadius = 16;
        self.layer.masksToBounds = NO;
        self.layer.borderWidth = 1.0;
        self.layer.borderColor = [NSColor colorWithWhite:1 alpha:0.46].CGColor;
        self.layer.shadowColor = NSColor.blackColor.CGColor;
        self.layer.shadowOpacity = 0.10;
        self.layer.shadowRadius = 14;
        self.layer.shadowOffset = CGSizeMake(0, -4);
    }
    return self;
}
- (BOOL)mouseDownCanMoveWindow { return YES; }
- (void)mouseDown:(NSEvent *)event { [self.window performWindowDragWithEvent:event]; }
- (void)drawRect:(NSRect)dirtyRect {
    BOOL dark = [[[self effectiveAppearance] bestMatchFromAppearancesWithNames:@[NSAppearanceNameDarkAqua, NSAppearanceNameAqua]] isEqualToString:NSAppearanceNameDarkAqua];
    NSRect inset = NSInsetRect(self.bounds, 1, 1);
    NSBezierPath *glass = [NSBezierPath bezierPathWithRoundedRect:inset xRadius:15 yRadius:15];
    NSColor *top = dark ? [NSColor colorWithRed:0.16 green:0.18 blue:0.22 alpha:0.98] : [NSColor colorWithWhite:1 alpha:0.98];
    NSColor *bottom = dark ? [NSColor colorWithRed:0.105 green:0.13 blue:0.17 alpha:0.98] : [NSColor colorWithRed:0.955 green:0.977 blue:1 alpha:0.96];
    [[[NSGradient alloc] initWithStartingColor:top endingColor:bottom] drawInBezierPath:glass angle:-90];
    glass.lineWidth = 1.0; [[NSColor colorWithRed:0.74 green:0.82 blue:0.92 alpha:0.55] setStroke]; [glass stroke];

    NSBezierPath *shine = [NSBezierPath bezierPath];
    [shine moveToPoint:NSMakePoint(18, NSHeight(self.bounds)-1.5)];
    [shine lineToPoint:NSMakePoint(NSWidth(self.bounds)-18, NSHeight(self.bounds)-1.5)];
    shine.lineWidth = 1.1;
    [[NSColor colorWithWhite:1 alpha:0.62] setStroke];
    [shine stroke];
}
@end

@interface ModernToggleButton : NSButton
@end


@implementation ModernToggleButton
- (instancetype)initWithFrame:(NSRect)frameRect {
    if ((self = [super initWithFrame:frameRect])) { self.bordered = NO; self.buttonType = NSButtonTypeToggle; self.font = [NSFont systemFontOfSize:14 weight:NSFontWeightMedium]; self.alignment = NSTextAlignmentLeft; }
    return self;
}
- (void)drawRect:(NSRect)dirtyRect {
    NSDictionary *attrs = @{NSFontAttributeName:self.font ?: [NSFont systemFontOfSize:14], NSForegroundColorAttributeName:NSColor.labelColor};
    [self.title drawAtPoint:NSMakePoint(0, (NSHeight(self.bounds)-17)/2.0) withAttributes:attrs];
    CGFloat h = 24, w = 43; NSRect trackRect = NSMakeRect(NSWidth(self.bounds)-w, (NSHeight(self.bounds)-h)/2, w, h);
    NSBezierPath *track = [NSBezierPath bezierPathWithRoundedRect:trackRect xRadius:h/2 yRadius:h/2];
    NSColor *trackColor = self.state == NSControlStateValueOn ? [NSColor colorWithRed:0.08 green:0.49 blue:1 alpha:1] : [NSColor colorWithWhite:0.67 alpha:0.45]; [trackColor setFill]; [track fill];
    CGFloat knobX = self.state == NSControlStateValueOn ? NSMaxX(trackRect)-h+2 : NSMinX(trackRect)+2;
    NSRect knobRect = NSMakeRect(knobX, NSMinY(trackRect)+2, h-4, h-4); NSShadow *shadow = [NSShadow new]; shadow.shadowColor = [NSColor colorWithWhite:0 alpha:0.18]; shadow.shadowBlurRadius = 3; shadow.shadowOffset = NSMakeSize(0,-1); [shadow set];
    [NSColor.whiteColor setFill]; [[NSBezierPath bezierPathWithOvalInRect:knobRect] fill];
}
@end

@interface PrimaryActionButton : NSButton
@end

@implementation PrimaryActionButton
- (instancetype)initWithFrame:(NSRect)frameRect { if ((self = [super initWithFrame:frameRect])) { self.bordered = NO; self.font = [NSFont systemFontOfSize:16 weight:NSFontWeightSemibold]; self.contentTintColor = NSColor.whiteColor; } return self; }
- (void)drawRect:(NSRect)dirtyRect {
    NSRect rect = NSInsetRect(self.bounds, 1, 1); NSBezierPath *shape = [NSBezierPath bezierPathWithRoundedRect:rect xRadius:10 yRadius:10];
    NSColor *start = [NSColor colorWithRed:0.08 green:0.47 blue:1 alpha:self.enabled ? 1 : 0.45]; NSColor *end = [NSColor colorWithRed:0.12 green:0.63 blue:1 alpha:self.enabled ? 1 : 0.45];
    [[[NSGradient alloc] initWithStartingColor:start endingColor:end] drawInBezierPath:shape angle:0];
    NSImage *play = [[NSImage imageWithSystemSymbolName:@"play.fill" accessibilityDescription:nil] imageWithSymbolConfiguration:[NSImageSymbolConfiguration configurationWithPointSize:16 weight:NSFontWeightSemibold]];
    [play drawInRect:NSMakeRect(24, (NSHeight(self.bounds)-18)/2, 18, 18) fromRect:NSZeroRect operation:NSCompositingOperationSourceOver fraction:1 respectFlipped:YES hints:@{NSForegroundColorAttributeName:NSColor.whiteColor}];
    NSDictionary *attrs = @{NSFontAttributeName:self.font, NSForegroundColorAttributeName:NSColor.whiteColor}; NSSize size = [self.title sizeWithAttributes:attrs]; [self.title drawAtPoint:NSMakePoint((NSWidth(self.bounds)-size.width)/2+9, (NSHeight(self.bounds)-size.height)/2) withAttributes:attrs];
}
@end

@interface ModernSegmentedControl : NSSegmentedControl
@end

@implementation ModernSegmentedControl
- (instancetype)initWithFrame:(NSRect)frameRect {
    if ((self = [super initWithFrame:frameRect])) { self.font = [NSFont systemFontOfSize:13 weight:NSFontWeightMedium]; }
    return self;
}
- (void)drawRect:(NSRect)dirtyRect {
    NSRect trackRect = NSInsetRect(self.bounds, 1, 2); NSBezierPath *track = [NSBezierPath bezierPathWithRoundedRect:trackRect xRadius:9 yRadius:9];
    [[NSColor colorWithWhite:0.62 alpha:0.16] setFill]; [track fill];
    NSInteger count = MAX(self.segmentCount, 1); CGFloat segmentWidth = NSWidth(trackRect)/count;
    if (self.selectedSegment >= 0) {
        NSRect selected = NSMakeRect(NSMinX(trackRect)+segmentWidth*self.selectedSegment, NSMinY(trackRect), segmentWidth, NSHeight(trackRect));
        NSBezierPath *selection = [NSBezierPath bezierPathWithRoundedRect:NSInsetRect(selected, 2, 2) xRadius:8 yRadius:8];
        [[[NSGradient alloc] initWithStartingColor:[NSColor colorWithRed:0.08 green:0.47 blue:1 alpha:1] endingColor:[NSColor colorWithRed:0.12 green:0.62 blue:1 alpha:1]] drawInBezierPath:selection angle:0];
    }
    for (NSInteger i = 0; i < count; i++) {
        NSString *title = [self labelForSegment:i] ?: @""; NSColor *color = i == self.selectedSegment ? NSColor.whiteColor : NSColor.labelColor;
        NSDictionary *attrs = @{NSFontAttributeName:self.font ?: [NSFont systemFontOfSize:13], NSForegroundColorAttributeName:color}; NSSize size = [title sizeWithAttributes:attrs];
        [title drawAtPoint:NSMakePoint(NSMinX(trackRect)+segmentWidth*i+(segmentWidth-size.width)/2, NSMidY(trackRect)-size.height/2) withAttributes:attrs];
    }
}
- (void)mouseDown:(NSEvent *)event {
    NSPoint point = [self convertPoint:event.locationInWindow fromView:nil]; NSInteger count = MAX(self.segmentCount, 1); NSInteger index = MIN(MAX((NSInteger)(point.x/(NSWidth(self.bounds)/count)), 0), count-1);
    self.selectedSegment = index; [self setNeedsDisplay:YES]; [self sendAction:self.action to:self.target];
}
@end

@interface PhonePreviewView : NSView
@end

@implementation PhonePreviewView
- (void)drawRect:(NSRect)dirtyRect {
    NSShadow *shadow = [NSShadow new]; shadow.shadowColor = [NSColor colorWithWhite:0 alpha:0.25]; shadow.shadowBlurRadius = 9; shadow.shadowOffset = NSMakeSize(0,-3); [shadow set];
    NSRect outer = NSInsetRect(self.bounds, 5, 2); NSBezierPath *phone = [NSBezierPath bezierPathWithRoundedRect:outer xRadius:12 yRadius:12]; [[NSColor colorWithWhite:0.08 alpha:1] setFill]; [phone fill];
    [NSGraphicsContext saveGraphicsState]; NSRect screen = NSInsetRect(outer, 3, 4); NSBezierPath *clip = [NSBezierPath bezierPathWithRoundedRect:screen xRadius:9 yRadius:9]; [clip addClip];
    NSColor *top = [NSColor colorWithRed:0.20 green:0.55 blue:1 alpha:1], *bottom = [NSColor colorWithRed:0.48 green:0.35 blue:0.96 alpha:1]; [[[NSGradient alloc] initWithStartingColor:top endingColor:bottom] drawInRect:screen angle:-35];
    [[NSColor colorWithRed:0.42 green:0.86 blue:1 alpha:0.60] setFill]; [[NSBezierPath bezierPathWithOvalInRect:NSMakeRect(NSMinX(screen)-18, NSMinY(screen)+8, 65, 80)] fill];
    [[NSColor colorWithRed:0.37 green:0.22 blue:0.87 alpha:0.60] setFill]; [[NSBezierPath bezierPathWithOvalInRect:NSMakeRect(NSMinX(screen)+18, NSMinY(screen)-10, 70, 88)] fill]; [NSGraphicsContext restoreGraphicsState];
    [NSColor.blackColor setFill]; [[NSBezierPath bezierPathWithOvalInRect:NSMakeRect(NSMidX(outer)-2, NSMaxY(outer)-10, 4, 4)] fill];
}
@end

@interface HeaderPillView : NSView
@end

@implementation HeaderPillView
- (BOOL)mouseDownCanMoveWindow { return YES; }
- (void)mouseDown:(NSEvent *)event { [self.window performWindowDragWithEvent:event]; }
- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    NSRect rect = NSInsetRect(self.bounds, 1, 1);
    NSBezierPath *pill = [NSBezierPath bezierPathWithRoundedRect:rect xRadius:NSHeight(rect)/2 yRadius:NSHeight(rect)/2];
    [[NSColor.controlBackgroundColor colorWithAlphaComponent:0.58] setFill]; [pill fill];
    pill.lineWidth = 1.0; [[NSColor.separatorColor colorWithAlphaComponent:0.75] setStroke]; [pill stroke];
    NSBezierPath *shine = [NSBezierPath bezierPath]; [shine moveToPoint:NSMakePoint(22, NSHeight(self.bounds)-2)]; [shine lineToPoint:NSMakePoint(NSWidth(self.bounds)-22, NSHeight(self.bounds)-2)];
    shine.lineWidth = 0.8; [[NSColor colorWithWhite:1 alpha:0.35] setStroke]; [shine stroke];
}
@end

@interface BrandArtworkView : NSView
@end

@implementation BrandArtworkView
- (BOOL)mouseDownCanMoveWindow { return YES; }
- (void)mouseDown:(NSEvent *)event { [self.window performWindowDragWithEvent:event]; }
- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    NSRect tile = NSInsetRect(self.bounds, 3, 3);
    NSBezierPath *shape = [NSBezierPath bezierPathWithRoundedRect:tile xRadius:15 yRadius:15];
    NSGradient *gradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithRed:0.19 green:0.48 blue:1 alpha:1] endingColor:[NSColor colorWithRed:0.92 green:0.18 blue:0.60 alpha:1]];
    [gradient drawInBezierPath:shape angle:-35];
    NSShadow *shadow = [NSShadow new]; shadow.shadowColor = [NSColor colorWithWhite:0 alpha:0.20]; shadow.shadowBlurRadius = 12; shadow.shadowOffset = NSMakeSize(0, -3); [shadow set];
    NSImage *symbol = [NSImage imageWithSystemSymbolName:@"macbook.and.iphone" accessibilityDescription:@"Mac and Android"];
    symbol = [symbol imageWithSymbolConfiguration:[NSImageSymbolConfiguration configurationWithPointSize:29 weight:NSFontWeightSemibold]];
    [symbol drawInRect:NSInsetRect(self.bounds, 12, 12) fromRect:NSZeroRect operation:NSCompositingOperationSourceOver fraction:1 respectFlipped:YES hints:@{NSForegroundColorAttributeName:NSColor.whiteColor}];
}
@end

@interface SidebarButton : NSButton
@property(nonatomic) BOOL active;
@end

@implementation SidebarButton
- (void)setActive:(BOOL)active { _active = active; self.contentTintColor = active ? NSColor.whiteColor : NSColor.secondaryLabelColor; [self setNeedsDisplay:YES]; }
- (void)drawRect:(NSRect)dirtyRect {
    if (self.active) { NSBezierPath *shape = [NSBezierPath bezierPathWithRoundedRect:NSInsetRect(self.bounds, 1, 1) xRadius:9 yRadius:9]; NSGradient *gradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithRed:0.10 green:0.48 blue:1 alpha:1] endingColor:[NSColor colorWithRed:0.18 green:0.61 blue:1 alpha:1]]; [gradient drawInBezierPath:shape angle:0]; }
    [super drawRect:dirtyRect];
}
@end

@interface DeviceStatsView : NSView
@property BOOL connected;
@property NSInteger battery;
@property NSInteger cpuPercent;
@property CGFloat memoryFraction, storageFraction;
@property NSString *memoryText, *storageText, *emptyText;
@end

@implementation DeviceStatsView
- (void)drawBar:(NSRect)rect fraction:(CGFloat)fraction color:(NSColor *)color label:(NSString *)label {
    NSBezierPath *track = [NSBezierPath bezierPathWithRoundedRect:rect xRadius:rect.size.height/2 yRadius:rect.size.height/2];
    [[NSColor colorWithWhite:0.5 alpha:0.16] setFill]; [track fill];
    NSRect fill = rect; fill.size.width = MAX(rect.size.height, rect.size.width * MIN(MAX(fraction, 0), 1));
    [color setFill]; [[NSBezierPath bezierPathWithRoundedRect:fill xRadius:fill.size.height/2 yRadius:fill.size.height/2] fill];
    NSDictionary *attrs = @{NSFontAttributeName:[NSFont monospacedSystemFontOfSize:9 weight:NSFontWeightMedium], NSForegroundColorAttributeName:NSColor.secondaryLabelColor};
    [label drawAtPoint:NSMakePoint(NSMaxX(rect)+6, rect.origin.y-2) withAttributes:attrs];
}
- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    if (!self.connected) {
        NSDictionary *attrs = @{NSFontAttributeName:[NSFont systemFontOfSize:11 weight:NSFontWeightMedium], NSForegroundColorAttributeName:NSColor.tertiaryLabelColor};
        [(self.emptyText ?: @"") drawAtPoint:NSMakePoint(0, MAX(2, (NSHeight(self.bounds)-14)/2)) withAttributes:attrs]; return;
    }
    NSArray *names = @[@"电池", @"CPU", @"内存", @"存储"];
    NSArray *values = @[[NSString stringWithFormat:@"%ld%%", (long)self.battery], [NSString stringWithFormat:@"%ld%%", (long)MAX(self.cpuPercent,0)], [NSString stringWithFormat:@"%.0f%%", self.memoryFraction*100], [NSString stringWithFormat:@"%.0f%%", self.storageFraction*100]];
    NSArray *symbols = @[@"battery.75percent", @"cpu", @"memorychip", @"internaldrive"];
    NSArray *colors = @[NSColor.systemGreenColor, NSColor.systemBlueColor, NSColor.systemIndigoColor, NSColor.systemPurpleColor];
    CGFloat width = NSWidth(self.bounds)/4.0;
    for (NSInteger i = 0; i < 4; i++) {
        CGFloat x = width*i; NSDictionary *titleAttrs = @{NSFontAttributeName:[NSFont systemFontOfSize:10 weight:NSFontWeightMedium], NSForegroundColorAttributeName:NSColor.secondaryLabelColor}; NSSize ts = [names[i] sizeWithAttributes:titleAttrs]; [names[i] drawAtPoint:NSMakePoint(x+(width-ts.width)/2, 31) withAttributes:titleAttrs];
        NSImage *icon = [[NSImage imageWithSystemSymbolName:symbols[i] accessibilityDescription:nil] imageWithSymbolConfiguration:[NSImageSymbolConfiguration configurationWithPointSize:17 weight:NSFontWeightMedium]]; [icon drawInRect:NSMakeRect(x+12, 4, 22, 22) fromRect:NSZeroRect operation:NSCompositingOperationSourceOver fraction:1 respectFlipped:YES hints:@{NSForegroundColorAttributeName:NSColor.secondaryLabelColor}];
        CGFloat fraction = i == 0 ? self.battery/100.0 : (i == 1 ? self.cpuPercent/100.0 : (i == 2 ? self.memoryFraction : self.storageFraction)); NSRect ring = NSMakeRect(x+43, 4, 22, 22); NSBezierPath *circle = [NSBezierPath bezierPathWithOvalInRect:ring]; circle.lineWidth = 3; [[NSColor colorWithWhite:0.6 alpha:0.18] setStroke]; [circle stroke]; NSBezierPath *arc = [NSBezierPath bezierPath]; [arc appendBezierPathWithArcWithCenter:NSMakePoint(NSMidX(ring),NSMidY(ring)) radius:9.5 startAngle:90 endAngle:90-360*MIN(MAX(fraction,0),1) clockwise:YES]; arc.lineWidth=3; [colors[i] setStroke]; [arc stroke];
        NSDictionary *valueAttrs = @{NSFontAttributeName:[NSFont monospacedDigitSystemFontOfSize:10 weight:NSFontWeightMedium], NSForegroundColorAttributeName:NSColor.labelColor}; [values[i] drawAtPoint:NSMakePoint(x+72, 8) withAttributes:valueAttrs];
        if (i > 0) { [[NSColor.separatorColor colorWithAlphaComponent:0.45] setStroke]; NSBezierPath *line=[NSBezierPath bezierPath]; [line moveToPoint:NSMakePoint(x,3)]; [line lineToPoint:NSMakePoint(x,43)]; [line stroke]; }
    }
}
@end

@protocol DropHandler <NSObject>
- (void)handleDroppedURLs:(NSArray<NSURL *> *)urls;
@end

@interface DropView : NSView <NSDraggingDestination>
@property (weak) id<DropHandler> handler;
@property NSString *displayText;
@end

@implementation DropView
- (instancetype)initWithFrame:(NSRect)frameRect { if ((self = [super initWithFrame:frameRect])) { self.displayText = @"⇩  拖放文件、文件夹或 APK 到这里"; [self registerForDraggedTypes:@[NSPasteboardTypeFileURL]]; } return self; }
- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect]; NSBezierPath *p = [NSBezierPath bezierPathWithRoundedRect:NSInsetRect(self.bounds, 1, 1) xRadius:9 yRadius:9]; CGFloat dash[] = {5, 4}; [p setLineDash:dash count:2 phase:0]; p.lineWidth = 1.2; [[NSColor colorWithRed:0.47 green:0.62 blue:0.80 alpha:0.45] setStroke]; [p stroke];
    if (NSHeight(self.bounds) > 70) {
        BOOL english = [self.displayText containsString:@"Drop"]; NSImage *icon = [[NSImage imageWithSystemSymbolName:@"doc.badge.arrow.up" accessibilityDescription:nil] imageWithSymbolConfiguration:[NSImageSymbolConfiguration configurationWithPointSize:29 weight:NSFontWeightRegular]]; [icon drawInRect:NSMakeRect(NSMidX(self.bounds)-18, 66, 36, 36) fromRect:NSZeroRect operation:NSCompositingOperationSourceOver fraction:0.85 respectFlipped:YES hints:@{NSForegroundColorAttributeName:NSColor.secondaryLabelColor}];
        NSString *title = english ? @"Drop files here" : @"将文件拖到此处"; NSString *subtitle = english ? @"Send files to your Android device" : @"发送文件到你的 Android 设备";
        NSDictionary *titleAttrs=@{NSFontAttributeName:[NSFont systemFontOfSize:13 weight:NSFontWeightSemibold],NSForegroundColorAttributeName:NSColor.labelColor}; NSDictionary *subAttrs=@{NSFontAttributeName:[NSFont systemFontOfSize:11],NSForegroundColorAttributeName:NSColor.secondaryLabelColor}; NSSize titleSize=[title sizeWithAttributes:titleAttrs], subSize=[subtitle sizeWithAttributes:subAttrs]; [title drawAtPoint:NSMakePoint(NSMidX(self.bounds)-titleSize.width/2,43) withAttributes:titleAttrs]; [subtitle drawAtPoint:NSMakePoint(NSMidX(self.bounds)-subSize.width/2,24) withAttributes:subAttrs];
    } else { NSDictionary *attrs = @{NSFontAttributeName:[NSFont systemFontOfSize:11], NSForegroundColorAttributeName:NSColor.secondaryLabelColor}; NSString *text = self.displayText ?: @""; NSSize s = [text sizeWithAttributes:attrs]; [text drawAtPoint:NSMakePoint((NSWidth(self.bounds)-s.width)/2, (NSHeight(self.bounds)-s.height)/2) withAttributes:attrs]; }
}
- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender { return NSDragOperationCopy; }
- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender { NSArray *urls = [sender.draggingPasteboard readObjectsForClasses:@[[NSURL class]] options:@{NSPasteboardURLReadingFileURLsOnlyKey:@YES}]; if (!urls.count) return NO; [self.handler handleDroppedURLs:urls]; return YES; }
@end

@interface AppDelegate : NSObject <NSApplicationDelegate, NSWindowDelegate, NSTableViewDataSource, NSTableViewDelegate, NSNetServiceBrowserDelegate, NSNetServiceDelegate, DropHandler>
@property NSWindow *window;
@property NSPopUpButton *devices, *audio, *quality;
@property NSTextField *wifi, *target, *status;
@property DeviceStatsView *deviceStats;
@property DeviceStatsView *audioDeviceStats;
@property DeviceStatsView *overviewDeviceStats;
@property NSButton *stayAwake, *screenOff, *alwaysOnTop, *keyboardControl, *mouseControl, *autoWiFi, *dexMode, *startButton, *hideAfterStart;
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
@property NSMutableArray *extraTasks, *appItems, *allAppItems;
@property NSTableView *appsTable;
@property NSSearchField *appsSearch;
@property NSInteger reconnectAttempts;
@property BOOL reconnecting;
@property BOOL pendingSettingsRestart;
@property BOOL pendingRestartWireless;
@property EventHotKeyRef emergencyHotKey;
@property EventHotKeyRef panelHotKey, inputLanguageHotKey;
@property NSStatusItem *statusItem;
@property NSMenu *statusMenu;
@property NSMenuItem *menuDevice, *menuStats;
@property NSTimer *deviceStatsTimer;
@property NSView *settingsSidebar;
@property NSView *audioCameraPage;
@property NSSearchField *sidebarSearch;
@property NSArray<NSView *> *overviewViews;
@property NSMutableArray<NSView *> *sectionPages;
@property NSMutableArray<NSButton *> *sidebarButtons;
@property NSSegmentedControl *outputRoute, *microphoneRoute;
@property NSButton *rememberSettings;
@property NSButton *overviewStartButton;
@property NSTextField *overviewDeviceName, *overviewConnectionState, *connectionDeviceName, *connectionStateLabel, *appsCountLabel;
@property BOOL settingsStyleShell;
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
    if ([title containsString:@"镜像"] || [title isEqualToString:@"连接"]) {
        b.bezelColor = NSColor.systemBlueColor; b.contentTintColor = NSColor.whiteColor;
    } else if ([title isEqualToString:@"QR"] || [title isEqualToString:@"配对码"]) {
        b.contentTintColor = NSColor.systemPurpleColor;
    } else if ([title containsString:@"文件"] || [title containsString:@"粘贴图片"]) {
        b.contentTintColor = NSColor.systemIndigoColor;
    }
    return b;
}

- (NSView *)card:(NSRect)frame {
    return [[GlassCardView alloc] initWithFrame:frame];
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

- (NSButton *)sidebarButton:(NSString *)title symbol:(NSString *)symbol tag:(NSInteger)tag y:(CGFloat)y {
    SidebarButton *button = [[SidebarButton alloc] initWithFrame:NSMakeRect(14, y, 202, 42)];
    button.title = title; button.tag = tag; button.target = self; button.action = @selector(selectSettingsSection:);
    button.bordered = NO; button.imagePosition = NSImageLeading;
    button.alignment = NSTextAlignmentLeft; button.font = [NSFont systemFontOfSize:14 weight:NSFontWeightMedium];
    button.image = [NSImage imageWithSystemSymbolName:symbol accessibilityDescription:title];
    return button;
}

- (void)installSettingsStyleShell {
    self.settingsStyleShell = YES;
    NSView *root = self.window.contentView;
    self.overviewViews = [root.subviews copy];
    for (NSView *view in self.overviewViews) view.hidden = YES;

    NSRect windowFrame = self.window.frame; windowFrame.origin.x -= 290; windowFrame.origin.y -= 26; windowFrame.size = NSMakeSize(1280, 760); [self.window setFrame:windowFrame display:YES];
    self.window.minSize = NSMakeSize(1280, 760); self.window.maxSize = NSMakeSize(1280, 760);

    self.settingsSidebar = [[SettingsSidebarView alloc] initWithFrame:NSMakeRect(0, 0, 232, 760)];
    self.settingsSidebar.autoresizingMask = NSViewHeightSizable; [root addSubview:self.settingsSidebar];
    self.sidebarSearch = [[NSSearchField alloc] initWithFrame:NSMakeRect(14, 684, 202, 36)]; self.sidebarSearch.placeholderString = @"搜索设置"; self.sidebarSearch.sendsSearchStringImmediately = YES; self.sidebarSearch.sendsWholeSearchString = NO; self.sidebarSearch.target = self; self.sidebarSearch.action = @selector(filterSidebar:); self.sidebarSearch.focusRingType = NSFocusRingTypeNone; [self.settingsSidebar addSubview:self.sidebarSearch];
    NSArray *titles = @[@"概览", @"连接设置", @"画面与输入", @"声音与摄像头", @"文件传输", @"应用", @"工具箱", @"高级设置"];
    NSArray *symbols = @[@"house.fill", @"link", @"display", @"speaker.wave.2.fill", @"folder.fill", @"square.grid.2x2.fill", @"wrench.and.screwdriver.fill", @"gearshape.fill"];
    self.sidebarButtons = [NSMutableArray array];
    for (NSInteger i = 0; i < titles.count; i++) { SidebarButton *b = (SidebarButton *)[self sidebarButton:titles[i] symbol:symbols[i] tag:i y:625-i*47]; b.active = i == 0; [self.settingsSidebar addSubview:b]; [self.sidebarButtons addObject:b]; }
    BrandArtworkView *smallMark = [[BrandArtworkView alloc] initWithFrame:NSMakeRect(18, 34, 52, 52)]; [self.settingsSidebar addSubview:smallMark];
    NSTextField *brand = [self label:@"Scrcpy Mate" frame:NSMakeRect(78, 56, 135, 22)]; brand.font = [NSFont systemFontOfSize:14 weight:NSFontWeightSemibold]; [self.settingsSidebar addSubview:brand];
    NSTextField *tagline = [self label:@"Mirror. Control. Do More." frame:NSMakeRect(78, 34, 140, 20)]; tagline.font = [NSFont systemFontOfSize:10]; tagline.textColor = NSColor.secondaryLabelColor; [self.settingsSidebar addSubview:tagline];

    self.sectionPages = [NSMutableArray array];
    for (NSInteger i = 0; i < 8; i++) { NSView *page = [[NSView alloc] initWithFrame:NSMakeRect(250, 20, 1012, 700)]; page.hidden = i != 0; [root addSubview:page]; [self.sectionPages addObject:page]; }
    [self buildOverviewPage:self.sectionPages[0]];
    [self buildConnectionPage:self.sectionPages[1]];
    [self buildDisplayInputPage:self.sectionPages[2]];
    self.audioCameraPage = self.sectionPages[3]; [self buildAudioCameraPage:self.audioCameraPage];
    [self buildFileTransferPage:self.sectionPages[4]];
    [self buildAppsPage:self.sectionPages[5]];
    [self buildToolboxPage:self.sectionPages[6]];
    [self buildAdvancedPage:self.sectionPages[7]];
}

- (void)setOverviewHidden:(BOOL)hidden {
    for (NSView *view in self.overviewViews) view.hidden = hidden;
}

- (void)selectSettingsSection:(NSButton *)sender {
    for (SidebarButton *button in self.sidebarButtons) button.active = NO;
    ((SidebarButton *)sender).active = YES;
    for (NSInteger i = 0; i < self.sectionPages.count; i++) self.sectionPages[i].hidden = i != sender.tag;
    if (sender.tag == 4) { self.filePanelExpanded = YES; [self refreshLocal:nil]; if (self.serial.length) [self refreshRemote:nil]; }
    if (sender.tag == 5 && self.serial.length) [self openAppLauncher:nil];
}

- (void)filterSidebar:(NSSearchField *)sender {
    NSString *query = [sender.stringValue stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet].lowercaseString;
    NSArray *keywords = @[
        @"概览 overview 首页 状态 电量 cpu 内存 storage battery",
        @"连接 connection usb wifi 无线 配对 qr",
        @"画面 显示 输入 display input dex 分辨率 键盘 鼠标 字体",
        @"声音 摄像头 audio camera 麦克风 mic 扬声器",
        @"文件 传输 file transfer mtp 上传 下载",
        @"应用 apps app 启动器 微信 抖音",
        @"工具箱 toolbox 工具 截图 录屏 电话 短信 快捷键",
        @"高级 advanced 性能 主题 语言 安全 重试"
    ];
    NSInteger visibleIndex = 0; SidebarButton *firstMatch = nil;
    for (SidebarButton *button in self.sidebarButtons) {
        NSString *haystack = [NSString stringWithFormat:@"%@ %@", button.title.lowercaseString, keywords[button.tag]];
        BOOL match = !query.length || [haystack containsString:query]; button.hidden = !match;
        if (match) { button.frame = NSMakeRect(14, 625-visibleIndex*47, 202, 42); visibleIndex++; if (!firstMatch) firstMatch = button; }
    }
    if (query.length && firstMatch) [self selectSettingsSection:firstMatch];
}

- (void)addPageHeading:(NSString *)title subtitle:(NSString *)subtitle to:(NSView *)page {
    NSTextField *heading = [self label:title frame:NSMakeRect(18, 642, 600, 38)]; heading.font = [NSFont systemFontOfSize:28 weight:NSFontWeightBold]; [page addSubview:heading];
    NSTextField *sub = [self label:subtitle frame:NSMakeRect(18, 617, 760, 22)]; sub.textColor = NSColor.secondaryLabelColor; [page addSubview:sub];
}

- (void)addCardTitle:(NSString *)title symbol:(NSString *)symbol x:(CGFloat)x y:(CGFloat)y to:(NSView *)page {
    NSImageView *icon = [[NSImageView alloc] initWithFrame:NSMakeRect(x, y, 27, 27)]; icon.image = [NSImage imageWithSystemSymbolName:symbol accessibilityDescription:title]; icon.contentTintColor = NSColor.secondaryLabelColor; [page addSubview:icon];
    NSTextField *label = [self sectionLabel:title frame:NSMakeRect(x + 36, y + 1, 230, 27)]; label.font = [NSFont systemFontOfSize:17 weight:NSFontWeightSemibold]; [page addSubview:label];
}

- (NSButton *)pageSwitch:(NSString *)title frame:(NSRect)frame state:(BOOL)state action:(SEL)action {
    ModernToggleButton *button = [[ModernToggleButton alloc] initWithFrame:frame]; button.title = title; button.state = state ? NSControlStateValueOn : NSControlStateValueOff; button.target = self; button.action = action; return button;
}

- (NSPopUpButton *)pagePopup:(NSArray<NSString *> *)items frame:(NSRect)frame action:(SEL)action {
    NSPopUpButton *popup = [[NSPopUpButton alloc] initWithFrame:frame pullsDown:NO]; [popup addItemsWithTitles:items]; popup.target = self; popup.action = action; return popup;
}

- (void)buildOverviewPage:(NSView *)page {
    [self addPageHeading:@"Scrcpy Mate" subtitle:@"通过 macOS 控制你的 Android 设备。" to:page];
    [page addSubview:[self card:NSMakeRect(0, 500, 1012, 110)]];
    PhonePreviewView *phone = [[PhonePreviewView alloc] initWithFrame:NSMakeRect(34, 505, 72, 98)]; [page addSubview:phone];
    self.overviewDeviceName = [self label:@"Android 手机" frame:NSMakeRect(122, 559, 310, 28)]; self.overviewDeviceName.font = [NSFont systemFontOfSize:21 weight:NSFontWeightBold]; [page addSubview:self.overviewDeviceName];
    self.overviewConnectionState = [self label:@"●  正在查找设备" frame:NSMakeRect(122, 532, 300, 24)]; self.overviewConnectionState.textColor = NSColor.systemOrangeColor; [page addSubview:self.overviewConnectionState];
    NSSegmentedControl *transport = [[ModernSegmentedControl alloc] initWithFrame:NSMakeRect(520, 539, 220, 38)]; transport.segmentCount = 2; transport.segmentStyle = NSSegmentStyleCapsule; transport.selectedSegmentBezelColor = [NSColor colorWithRed:0.08 green:0.49 blue:1 alpha:1]; [transport setLabel:@"USB" forSegment:0]; [transport setLabel:@"Wi‑Fi" forSegment:1]; transport.selectedSegment = 0; [page addSubview:transport];
    self.overviewStartButton = [[PrimaryActionButton alloc] initWithFrame:NSMakeRect(770, 527, 220, 52)]; self.overviewStartButton.title = @"开始镜像"; self.overviewStartButton.target = self; self.overviewStartButton.action = @selector(toggleMirror:); [page addSubview:self.overviewStartButton];

    [page addSubview:[self card:NSMakeRect(0, 235, 490, 245)]]; [self addCardTitle:@"画面与输入" symbol:@"display" x:22 y:438 to:page];
    [page addSubview:[self label:@"分辨率" frame:NSMakeRect(22, 389, 120, 24)]]; NSPopUpButton *resolution = [self pagePopup:@[@"自动", @"1280", @"1600", @"1920", @"2560"] frame:NSMakeRect(245, 384, 220, 30) action:@selector(overviewResolutionChanged:)]; resolution.tag = 10; [resolution selectItemAtIndex:self.quality.indexOfSelectedItem]; [page addSubview:resolution];
    NSButton *dex = [self pageSwitch:@"使用 DeX 模式" frame:NSMakeRect(22, 346, 443, 26) state:self.dexMode.state == NSControlStateValueOn action:@selector(overviewToggleChanged:)]; dex.tag = 1; [page addSubview:dex];
    NSButton *keyboard = [self pageSwitch:@"发送键盘输入" frame:NSMakeRect(22, 306, 443, 26) state:YES action:@selector(overviewToggleChanged:)]; keyboard.tag = 2; [page addSubview:keyboard];
    NSButton *mouse = [self pageSwitch:@"发送鼠标输入" frame:NSMakeRect(22, 266, 443, 26) state:YES action:@selector(overviewToggleChanged:)]; mouse.tag = 3; [page addSubview:mouse];
    NSTextField *smallA = [self label:@"A" frame:NSMakeRect(160, 246, 20, 20)]; smallA.font = [NSFont systemFontOfSize:11]; [page addSubview:smallA]; NSSlider *scale = [[NSSlider alloc] initWithFrame:NSMakeRect(190, 239, 215, 24)]; scale.minValue = 150; scale.maxValue = 240; scale.doubleValue = self.dexScale.doubleValue; scale.target = self; scale.action = @selector(overviewScaleChanged:); [page addSubview:scale]; NSTextField *largeA = [self label:@"A" frame:NSMakeRect(425, 239, 25, 28)]; largeA.font = [NSFont systemFontOfSize:21 weight:NSFontWeightSemibold]; [page addSubview:largeA];

    [page addSubview:[self card:NSMakeRect(506, 360, 506, 120)]]; [self addCardTitle:@"声音" symbol:@"speaker.wave.2.fill" x:528 y:438 to:page];
    [page addSubview:[self label:@"手机声音播放到" frame:NSMakeRect(528, 402, 155, 24)]]; NSSegmentedControl *route = [[ModernSegmentedControl alloc] initWithFrame:NSMakeRect(712, 397, 278, 32)]; route.segmentCount = 2; route.segmentStyle = NSSegmentStyleCapsule; route.selectedSegmentBezelColor = [NSColor colorWithRed:0.08 green:0.49 blue:1 alpha:1]; [route setLabel:@"Mac" forSegment:0]; [route setLabel:@"手机" forSegment:1]; route.selectedSegment = 0; route.target = self; route.action = @selector(overviewAudioChanged:); [page addSubview:route];
    [page addSubview:[self label:@"麦克风来源" frame:NSMakeRect(528, 365, 155, 24)]]; NSPopUpButton *mic = [self pagePopup:@[@"手机麦克风"] frame:NSMakeRect(712, 360, 278, 30) action:nil]; [page addSubview:mic];

    [page addSubview:[self card:NSMakeRect(506, 235, 506, 105)]]; [self addCardTitle:@"设备状态" symbol:@"waveform.path.ecg.rectangle" x:528 y:302 to:page];
    self.overviewDeviceStats = [[DeviceStatsView alloc] initWithFrame:NSMakeRect(535, 250, 430, 48)]; self.overviewDeviceStats.emptyText = @"连接手机后显示电量、CPU、内存与存储"; [page addSubview:self.overviewDeviceStats];

    [page addSubview:[self card:NSMakeRect(0, 18, 1012, 195)]]; [self addCardTitle:@"文件传输" symbol:@"folder.fill" x:22 y:174 to:page];
    DropView *drop = [[DropView alloc] initWithFrame:NSMakeRect(22, 38, 968, 120)]; drop.handler = self; drop.displayText = @"⇩  将文件拖到此处发送到 Android 设备"; [page addSubview:drop];
    NSButton *choose = [self button:@"选择文件…" frame:NSMakeRect(820, 78, 140, 36) action:@selector(chooseFilesToSend:)]; [page addSubview:choose];
}

- (void)buildConnectionPage:(NSView *)page {
    [self addPageHeading:@"连接" subtitle:@"管理 USB、Wi‑Fi 和无线调试连接。" to:page];
    [page addSubview:[self card:NSMakeRect(0, 500, 1012, 110)]]; PhonePreviewView *mark = [[PhonePreviewView alloc] initWithFrame:NSMakeRect(34, 505, 72, 98)]; [page addSubview:mark];
    self.connectionDeviceName = [self label:@"Android 手机" frame:NSMakeRect(122, 559, 420, 28)]; self.connectionDeviceName.font = [NSFont systemFontOfSize:21 weight:NSFontWeightBold]; [page addSubview:self.connectionDeviceName];
    self.connectionStateLabel = [self label:@"●  正在查找设备" frame:NSMakeRect(122, 532, 350, 24)]; self.connectionStateLabel.textColor = NSColor.systemOrangeColor; [page addSubview:self.connectionStateLabel];
    NSButton *refresh = [self button:@"刷新" frame:NSMakeRect(845, 535, 145, 38) action:@selector(refresh:)]; [page addSubview:refresh];

    [page addSubview:[self card:NSMakeRect(0, 245, 490, 235)]]; [self addCardTitle:@"连接方式" symbol:@"link" x:22 y:438 to:page];
    NSSegmentedControl *mode = [[ModernSegmentedControl alloc] initWithFrame:NSMakeRect(22, 386, 446, 38)]; mode.segmentCount = 2; mode.segmentStyle = NSSegmentStyleCapsule; mode.selectedSegmentBezelColor = [NSColor colorWithRed:0.08 green:0.49 blue:1 alpha:1]; [mode setLabel:@"USB" forSegment:0]; [mode setLabel:@"Wi‑Fi" forSegment:1]; mode.selectedSegment = 0; [page addSubview:mode];
    [page addSubview:[self label:@"设备 IP 地址" frame:NSMakeRect(22, 346, 180, 22)]];
    [self.wifi removeFromSuperview]; self.wifi.frame = NSMakeRect(22, 304, 446, 34); self.wifi.hidden = NO; [page addSubview:self.wifi];
    NSButton *connect = [self button:@"连接" frame:NSMakeRect(22, 258, 446, 36) action:@selector(connectWiFi:)]; connect.bezelColor = NSColor.systemBlueColor; [page addSubview:connect];

    [page addSubview:[self card:NSMakeRect(506, 245, 506, 235)]]; [self addCardTitle:@"无线调试" symbol:@"wifi" x:528 y:438 to:page];
    [self.qrImageView removeFromSuperview]; self.qrImageView = [[NSImageView alloc] initWithFrame:NSMakeRect(528, 285, 132, 132)]; self.qrImageView.imageScaling = NSImageScaleProportionallyUpOrDown; [page addSubview:self.qrImageView];
    NSTextField *scan = [self label:@"使用手机扫描二维码进行配对" frame:NSMakeRect(680, 386, 290, 24)]; scan.font = [NSFont systemFontOfSize:14 weight:NSFontWeightSemibold]; [page addSubview:scan];
    [page addSubview:[self label:@"配对码" frame:NSMakeRect(680, 344, 80, 22)]]; NSTextField *pair = [[NSTextField alloc] initWithFrame:NSMakeRect(680, 305, 180, 32)]; pair.placeholderString = @"123 456"; [page addSubview:pair]; NSButton *pairButton = [self button:@"配对" frame:NSMakeRect(870, 305, 110, 32) action:@selector(pairWiFi:)]; [page addSubview:pairButton];
    NSTextField *wait = [self label:@"●  等待手机扫描" frame:NSMakeRect(680, 268, 230, 24)]; wait.textColor = NSColor.systemOrangeColor; [page addSubview:wait];

    [page addSubview:[self card:NSMakeRect(0, 18, 490, 207)]]; [self addCardTitle:@"自动连接" symbol:@"gearshape.fill" x:22 y:184 to:page];
    self.autoWiFi = [self pageSwitch:@"USB 连接后验证 Wi‑Fi" frame:NSMakeRect(22, 138, 446, 28) state:YES action:nil]; [page addSubview:self.autoWiFi];
    NSButton *remember = [self pageSwitch:@"记住此设备" frame:NSMakeRect(22, 96, 446, 28) state:YES action:nil]; [page addSubview:remember];
    [self.hideAfterStart removeFromSuperview]; self.hideAfterStart.frame = NSMakeRect(22, 54, 446, 28); self.hideAfterStart.hidden = NO; [page addSubview:self.hideAfterStart];

    [page addSubview:[self card:NSMakeRect(506, 18, 506, 207)]]; [self addCardTitle:@"最近的设备" symbol:@"clock.fill" x:528 y:184 to:page];
    NSTextField *recent = [self label:@"Samsung Galaxy\n上次连接：今天" frame:NSMakeRect(548, 117, 410, 50)]; recent.maximumNumberOfLines = 2; recent.font = [NSFont systemFontOfSize:14 weight:NSFontWeightMedium]; [page addSubview:recent];
    NSTextField *recent2 = [self label:@"无线设备\n等待连接" frame:NSMakeRect(548, 55, 410, 50)]; recent2.maximumNumberOfLines = 2; recent2.textColor = NSColor.secondaryLabelColor; [page addSubview:recent2];
}

- (void)buildDisplayInputPage:(NSView *)page {
    [self addPageHeading:@"画面与输入" subtitle:@"调整镜像画面、DeX 桌面和电脑输入。" to:page];
    [page addSubview:[self card:NSMakeRect(0, 360, 490, 250)]]; [self addCardTitle:@"显示" symbol:@"display" x:22 y:568 to:page];
    [page addSubview:[self label:@"分辨率" frame:NSMakeRect(22, 520, 120, 24)]]; [self.quality removeFromSuperview]; self.quality.frame = NSMakeRect(245, 516, 220, 30); self.quality.hidden = NO; [page addSubview:self.quality];
    [page addSubview:[self label:@"帧率" frame:NSMakeRect(22, 478, 120, 24)]]; NSPopUpButton *fps = [self pagePopup:@[@"60 fps", @"30 fps"] frame:NSMakeRect(245, 474, 220, 30) action:nil]; [page addSubview:fps];
    [page addSubview:[self label:@"画面质量" frame:NSMakeRect(22, 436, 120, 24)]]; [self.profile removeFromSuperview]; self.profile.frame = NSMakeRect(245, 432, 220, 30); [page addSubview:self.profile];
    [page addSubview:[self label:@"文字大小" frame:NSMakeRect(22, 394, 120, 24)]]; [self.dexScale removeFromSuperview]; self.dexScale.frame = NSMakeRect(205, 392, 220, 28); self.dexScale.hidden = NO; [page addSubview:self.dexScale];

    [page addSubview:[self card:NSMakeRect(506, 360, 506, 250)]]; [self addCardTitle:@"Samsung DeX" symbol:@"rectangle.connected.to.line.below" x:528 y:568 to:page];
    [self.dexMode removeFromSuperview]; self.dexMode.frame = NSMakeRect(528, 516, 462, 28); self.dexMode.hidden = NO; self.dexMode.title = @"启用 DeX 桌面"; [page addSubview:self.dexMode];
    [page addSubview:[self label:@"画面比例" frame:NSMakeRect(528, 474, 130, 24)]]; NSPopUpButton *ratio = [self pagePopup:@[@"16:9"] frame:NSMakeRect(760, 470, 230, 30) action:nil]; [page addSubview:ratio];
    NSButton *dynamic = [self pageSwitch:@"动态窗口大小" frame:NSMakeRect(528, 426, 462, 28) state:YES action:nil]; [page addSubview:dynamic]; NSTextField *dexNote = [self label:@"根据 DeX 桌面内容自动调整窗口大小。" frame:NSMakeRect(528, 390, 420, 24)]; dexNote.textColor = NSColor.secondaryLabelColor; [page addSubview:dexNote];

    [page addSubview:[self card:NSMakeRect(0, 145, 490, 195)]]; [self addCardTitle:@"输入" symbol:@"keyboard" x:22 y:298 to:page];
    [self.keyboardControl removeFromSuperview]; self.keyboardControl.frame = NSMakeRect(22, 252, 443, 28); self.keyboardControl.hidden = NO; [page addSubview:self.keyboardControl];
    [self.mouseControl removeFromSuperview]; self.mouseControl.frame = NSMakeRect(22, 212, 443, 28); self.mouseControl.hidden = NO; [page addSubview:self.mouseControl];
    [self.keyboardMode removeFromSuperview]; self.keyboardMode.frame = NSMakeRect(245, 166, 220, 30); [page addSubview:self.keyboardMode]; [page addSubview:[self label:@"键盘模式" frame:NSMakeRect(22, 170, 150, 24)]];

    [page addSubview:[self card:NSMakeRect(506, 145, 506, 195)]]; [self addCardTitle:@"窗口" symbol:@"macwindow" x:528 y:298 to:page];
    [self.alwaysOnTop removeFromSuperview]; self.alwaysOnTop.frame = NSMakeRect(528, 252, 462, 28); self.alwaysOnTop.hidden = NO; [page addSubview:self.alwaysOnTop];
    [self.screenOff removeFromSuperview]; self.screenOff.frame = NSMakeRect(528, 212, 462, 28); self.screenOff.hidden = NO; [page addSubview:self.screenOff];
    [self.stayAwake removeFromSuperview]; self.stayAwake.frame = NSMakeRect(528, 172, 462, 28); self.stayAwake.hidden = NO; [page addSubview:self.stayAwake];

    [page addSubview:[self card:NSMakeRect(0, 18, 1012, 105)]]; [self addCardTitle:@"快捷操作" symbol:@"bolt.fill" x:22 y:80 to:page];
    NSArray *quick = @[@"⌂  主页  ⌘H", @"←  返回  ⌘B", @"⛶  全屏  ⌘F", @"■  紧急停止  ⌃⌥⌘Esc"];
    for (NSInteger i = 0; i < quick.count; i++) { NSTextField *q = [self label:quick[i] frame:NSMakeRect(30 + i*245, 40, 225, 28)]; q.alignment = NSTextAlignmentCenter; q.font = [NSFont systemFontOfSize:13 weight:NSFontWeightMedium]; [page addSubview:q]; }
}

- (void)buildAudioCameraPage:(NSView *)page {
    NSTextField *heading = [self label:@"声音与摄像头" frame:NSMakeRect(18, 642, 420, 38)]; heading.font = [NSFont systemFontOfSize:28 weight:NSFontWeightBold]; [page addSubview:heading];
    NSTextField *sub = [self label:@"选择声音、麦克风和手机摄像头的来源。" frame:NSMakeRect(18, 617, 520, 22)]; sub.textColor = NSColor.secondaryLabelColor; [page addSubview:sub];
    [page addSubview:[self card:NSMakeRect(0, 360, 490, 240)]]; [page addSubview:[self card:NSMakeRect(506, 360, 506, 240)]];
    [page addSubview:[self card:NSMakeRect(0, 112, 490, 230)]]; [page addSubview:[self card:NSMakeRect(506, 112, 506, 230)]];
    [page addSubview:[self card:NSMakeRect(0, 18, 1012, 76)]];
    NSTextField *outputTitle = [self sectionLabel:@"声音输出" frame:NSMakeRect(22, 560, 180, 28)]; outputTitle.font = [NSFont systemFontOfSize:17 weight:NSFontWeightSemibold]; [page addSubview:outputTitle];
    self.outputRoute = [[ModernSegmentedControl alloc] initWithFrame:NSMakeRect(22, 506, 446, 36)]; self.outputRoute.segmentCount = 3; self.outputRoute.segmentStyle = NSSegmentStyleCapsule; self.outputRoute.selectedSegmentBezelColor = [NSColor colorWithRed:0.08 green:0.49 blue:1 alpha:1]; [self.outputRoute setLabel:@"Mac" forSegment:0]; [self.outputRoute setLabel:@"手机" forSegment:1]; [self.outputRoute setLabel:@"Mac + 手机" forSegment:2]; self.outputRoute.selectedSegment = 0; self.outputRoute.target = self; self.outputRoute.action = @selector(audioRouteChanged:); [page addSubview:self.outputRoute];
    [page addSubview:[self label:@"输出设备" frame:NSMakeRect(22, 458, 110, 24)]]; NSPopUpButton *outputDevice = [[NSPopUpButton alloc] initWithFrame:NSMakeRect(164, 454, 304, 30) pullsDown:NO]; [outputDevice addItemsWithTitles:@[@"Mac 系统默认扬声器"]]; [page addSubview:outputDevice];
    NSTextField *volumeLabel = [self label:@"输出音量" frame:NSMakeRect(22, 410, 110, 24)]; [page addSubview:volumeLabel]; NSSlider *volume = [[NSSlider alloc] initWithFrame:NSMakeRect(164, 409, 304, 28)]; volume.doubleValue = 72; [page addSubview:volume];

    NSTextField *micTitle = [self sectionLabel:@"麦克风输入" frame:NSMakeRect(528, 560, 180, 28)]; micTitle.font = [NSFont systemFontOfSize:17 weight:NSFontWeightSemibold]; [page addSubview:micTitle];
    self.microphoneRoute = [[ModernSegmentedControl alloc] initWithFrame:NSMakeRect(528, 506, 462, 36)]; self.microphoneRoute.segmentCount = 1; self.microphoneRoute.segmentStyle = NSSegmentStyleCapsule; self.microphoneRoute.selectedSegmentBezelColor = [NSColor colorWithRed:0.08 green:0.49 blue:1 alpha:1]; [self.microphoneRoute setLabel:@"手机麦克风" forSegment:0]; self.microphoneRoute.selectedSegment = 0; [page addSubview:self.microphoneRoute];
    [page addSubview:[self label:@"输入电平" frame:NSMakeRect(528, 458, 100, 24)]]; NSLevelIndicator *meter = [[NSLevelIndicator alloc] initWithFrame:NSMakeRect(650, 460, 340, 20)]; meter.minValue = 0; meter.maxValue = 100; meter.doubleValue = 58; meter.levelIndicatorStyle = NSLevelIndicatorStyleContinuousCapacity; [page addSubview:meter];
    NSTextField *micNote = [self label:@"使用手机麦克风进行通话、录音或监听。" frame:NSMakeRect(528, 405, 430, 42)]; micNote.textColor = NSColor.secondaryLabelColor; [page addSubview:micNote];

    NSTextField *cameraTitle = [self sectionLabel:@"使用手机摄像头" frame:NSMakeRect(22, 300, 220, 28)]; cameraTitle.font = [NSFont systemFontOfSize:17 weight:NSFontWeightSemibold]; [page addSubview:cameraTitle];
    NSButton *cameraToggle = [self check:@"启用摄像头预览" y:264]; cameraToggle.frame = NSMakeRect(22, 264, 220, 24); cameraToggle.state = NSControlStateValueOn; cameraToggle.target = self; cameraToggle.action = @selector(startCamera:); [page addSubview:cameraToggle];
    [page addSubview:[self label:@"摄像头" frame:NSMakeRect(22, 220, 90, 24)]]; NSPopUpButton *camera = [[NSPopUpButton alloc] initWithFrame:NSMakeRect(140, 216, 328, 30) pullsDown:NO]; [camera addItemsWithTitles:@[@"后置摄像头", @"前置摄像头"]]; [page addSubview:camera];
    [page addSubview:[self label:@"画质" frame:NSMakeRect(22, 177, 90, 24)]]; NSPopUpButton *cameraQuality = [[NSPopUpButton alloc] initWithFrame:NSMakeRect(140, 173, 328, 30) pullsDown:NO]; [cameraQuality addItemsWithTitles:@[@"1080p · 30 fps", @"720p · 30 fps", @"1080p · 60 fps"]]; [page addSubview:cameraQuality];
    NSButton *preview = [self button:@"打开摄像头预览" frame:NSMakeRect(140, 132, 328, 32) action:@selector(startCamera:)]; preview.bezelColor = NSColor.systemBlueColor; preview.contentTintColor = NSColor.whiteColor; [page addSubview:preview];

    NSTextField *savedTitle = [self sectionLabel:@"保存设置" frame:NSMakeRect(528, 300, 180, 28)]; savedTitle.font = [NSFont systemFontOfSize:17 weight:NSFontWeightSemibold]; [page addSubview:savedTitle];
    self.rememberSettings = [self check:@"记住这台手机的设置" y:258]; self.rememberSettings.frame = NSMakeRect(528, 258, 300, 26); self.rememberSettings.state = NSControlStateValueOn; [page addSubview:self.rememberSettings];
    NSTextField *savedNote = [self label:@"声音、摄像头、画面和输入设置将在下次连接时自动恢复。" frame:NSMakeRect(528, 205, 430, 48)]; savedNote.maximumNumberOfLines = 2; savedNote.textColor = NSColor.secondaryLabelColor; [page addSubview:savedNote];
    NSButton *save = [self button:@"保存设置" frame:NSMakeRect(528, 135, 462, 42) action:@selector(saveDevicePreferences:)]; save.bezelColor = NSColor.systemBlueColor; save.contentTintColor = NSColor.whiteColor; [page addSubview:save];

    NSTextField *health = [self sectionLabel:@"设备状态" frame:NSMakeRect(22, 60, 100, 24)]; [page addSubview:health];
    self.audioDeviceStats = [[DeviceStatsView alloc] initWithFrame:NSMakeRect(140, 35, 520, 45)]; self.audioDeviceStats.connected = NO; self.audioDeviceStats.emptyText = @"连接手机后显示电量、CPU、内存与存储"; [page addSubview:self.audioDeviceStats];
}

- (void)buildFileTransferPage:(NSView *)page {
    [self addPageHeading:@"文件传输" subtitle:@"在 Mac 与 Android 设备之间管理和传输文件。" to:page];
    [page addSubview:[self card:NSMakeRect(0, 525, 1012, 85)]];
    [page addSubview:[self label:@"Mac 路径" frame:NSMakeRect(22, 568, 100, 20)]]; self.localPathField = [[NSTextField alloc] initWithFrame:NSMakeRect(22, 538, 280, 28)]; self.localPathField.stringValue = [NSHomeDirectory() stringByAppendingPathComponent:@"Downloads"]; [page addSubview:self.localPathField];
    [page addSubview:[self label:@"手机路径" frame:NSMakeRect(320, 568, 100, 20)]]; self.remotePathField = [[NSTextField alloc] initWithFrame:NSMakeRect(320, 538, 280, 28)]; self.remotePathField.stringValue = self.target.stringValue.length ? self.target.stringValue : @"/sdcard/Download/"; [page addSubview:self.remotePathField];
    [page addSubview:[self button:@"新建文件夹" frame:NSMakeRect(620, 538, 135, 30) action:@selector(remoteMkdir:)]]; [page addSubview:[self button:@"刷新" frame:NSMakeRect(765, 538, 105, 30) action:@selector(refreshRemote:)]];
    self.fileStatus = [self label:@"准备传输" frame:NSMakeRect(880, 540, 110, 26)]; self.fileStatus.textColor = NSColor.secondaryLabelColor; [page addSubview:self.fileStatus];

    [page addSubview:[self card:NSMakeRect(0, 190, 470, 315)]]; [self addCardTitle:@"Mac" symbol:@"desktopcomputer" x:22 y:465 to:page];
    [page addSubview:[self button:@"返回上级" frame:NSMakeRect(342, 462, 105, 28) action:@selector(localUp:)]];
    NSScrollView *localScroll = [[NSScrollView alloc] initWithFrame:NSMakeRect(18, 210, 434, 240)]; localScroll.hasVerticalScroller = YES; localScroll.borderType = NSNoBorder; self.localTable = [[NSTableView alloc] initWithFrame:localScroll.bounds]; self.localTable.headerView = nil; self.localTable.rowHeight = 34; self.localTable.delegate = self; self.localTable.dataSource = self; self.localTable.target = self; self.localTable.doubleAction = @selector(localDoubleClick:); NSTableColumn *lc = [[NSTableColumn alloc] initWithIdentifier:@"local"]; lc.width = 420; [self.localTable addTableColumn:lc]; localScroll.documentView = self.localTable; [page addSubview:localScroll];

    [page addSubview:[self card:NSMakeRect(542, 190, 470, 315)]]; [self addCardTitle:@"Samsung Galaxy" symbol:@"iphone" x:564 y:465 to:page];
    [page addSubview:[self button:@"返回上级" frame:NSMakeRect(884, 462, 105, 28) action:@selector(remoteUp:)]];
    NSScrollView *remoteScroll = [[NSScrollView alloc] initWithFrame:NSMakeRect(560, 210, 434, 240)]; remoteScroll.hasVerticalScroller = YES; remoteScroll.borderType = NSNoBorder; self.remoteTable = [[NSTableView alloc] initWithFrame:remoteScroll.bounds]; self.remoteTable.headerView = nil; self.remoteTable.rowHeight = 34; self.remoteTable.delegate = self; self.remoteTable.dataSource = self; self.remoteTable.target = self; self.remoteTable.doubleAction = @selector(remoteDoubleClick:); NSTableColumn *rc = [[NSTableColumn alloc] initWithIdentifier:@"remote"]; rc.width = 420; [self.remoteTable addTableColumn:rc]; remoteScroll.documentView = self.remoteTable; [page addSubview:remoteScroll];

    NSButton *upload = [self button:@"上传 →" frame:NSMakeRect(474, 345, 64, 42) action:@selector(fileManagerUpload:)]; upload.bezelColor = NSColor.systemBlueColor; [page addSubview:upload]; NSButton *download = [self button:@"← 下载" frame:NSMakeRect(474, 292, 64, 42) action:@selector(fileManagerDownload:)]; download.bezelColor = NSColor.systemBlueColor; [page addSubview:download];
    DropView *drop = [[DropView alloc] initWithFrame:NSMakeRect(0, 18, 1012, 150)]; drop.handler = self; drop.displayText = @"⇧  将文件拖到此处上传到手机"; [page addSubview:drop];
    self.remoteItems = [NSMutableArray array]; self.localItems = [NSMutableArray array]; self.filePanel = page; self.filePanelExpanded = YES; self.filePanelGeneration += 1; [self refreshLocal:nil];
}

- (void)buildAppsPage:(NSView *)page {
    [self addPageHeading:@"应用" subtitle:@"快速查找并在镜像窗口中打开手机应用。" to:page];
    [page addSubview:[self card:NSMakeRect(0, 525, 1012, 85)]]; self.appsSearch = [[NSSearchField alloc] initWithFrame:NSMakeRect(22, 546, 500, 38)]; self.appsSearch.placeholderString = @"搜索应用"; self.appsSearch.target = self; self.appsSearch.action = @selector(filterApps:); [page addSubview:self.appsSearch];
    self.appLaunchMode = [self pagePopup:@[@"自动适配", @"DeX 桌面", @"手机竖屏"] frame:NSMakeRect(542, 550, 210, 32) action:nil]; [page addSubview:self.appLaunchMode]; [page addSubview:[self button:@"刷新" frame:NSMakeRect(765, 550, 95, 32) action:@selector(openAppLauncher:)]]; self.appsCountLabel = [self label:@"正在读取应用…" frame:NSMakeRect(870, 554, 125, 24)]; self.appsCountLabel.textColor = NSColor.secondaryLabelColor; [page addSubview:self.appsCountLabel];
    [page addSubview:[self card:NSMakeRect(0, 80, 650, 425)]]; [self addCardTitle:@"应用库" symbol:@"square.grid.2x2.fill" x:22 y:465 to:page];
    NSScrollView *scroll = [[NSScrollView alloc] initWithFrame:NSMakeRect(18, 100, 614, 350)]; scroll.hasVerticalScroller = YES; scroll.borderType = NSNoBorder; self.appsTable = [[NSTableView alloc] initWithFrame:scroll.bounds]; self.appsTable.headerView = nil; self.appsTable.rowHeight = 58; self.appsTable.delegate = self; self.appsTable.dataSource = self; self.appsTable.target = self; self.appsTable.doubleAction = @selector(launchSelectedApp:); NSTableColumn *col = [[NSTableColumn alloc] initWithIdentifier:@"app"]; col.width = 600; [self.appsTable addTableColumn:col]; scroll.documentView = self.appsTable; [page addSubview:scroll];
    [page addSubview:[self card:NSMakeRect(670, 255, 342, 250)]]; [self addCardTitle:@"启动方式" symbol:@"paperplane.fill" x:692 y:465 to:page];
    NSArray *modes = @[@"自动适配\n根据应用选择最佳显示方式", @"DeX 桌面\n在桌面窗口中启动应用", @"手机竖屏\n以完整竖屏窗口启动应用"];
    for (NSInteger i = 0; i < modes.count; i++) { NSTextField *m = [self label:modes[i] frame:NSMakeRect(705, 392-i*64, 280, 48)]; m.maximumNumberOfLines = 2; m.font = [NSFont systemFontOfSize:13 weight:i == 0 ? NSFontWeightSemibold : NSFontWeightRegular]; if (i > 0) m.textColor = NSColor.secondaryLabelColor; [page addSubview:m]; }
    [page addSubview:[self card:NSMakeRect(670, 80, 342, 155)]]; [self addCardTitle:@"使用提示" symbol:@"info.circle.fill" x:692 y:195 to:page]; NSTextField *hint = [self label:@"双击应用即可启动。\n抖音、微信等竖屏应用会自动使用合适的显示比例。" frame:NSMakeRect(692, 112, 290, 68)]; hint.maximumNumberOfLines = 3; hint.textColor = NSColor.secondaryLabelColor; [page addSubview:hint];
}

- (void)buildToolboxPage:(NSView *)page {
    [self addPageHeading:@"工具箱" subtitle:@"常用 Android 操作集中在一个页面中。" to:page];
    [page addSubview:[self card:NSMakeRect(0, 430, 1012, 180)]]; [self addCardTitle:@"实用工具" symbol:@"wrench.and.screwdriver.fill" x:22 y:568 to:page];
    NSArray *tools = @[@"截图", @"开始录屏", @"手机相机", @"新建镜像"];
    NSArray *toolSymbols = @[@"camera.fill", @"record.circle", @"camera.viewfinder", @"rectangle.on.rectangle"];
    SEL actions[] = {@selector(takeScreenshot:), @selector(toggleRecording:), @selector(startCamera:), @selector(startAdditionalMirror:)};
    for (NSInteger i = 0; i < tools.count; i++) { NSButton *button = [self button:tools[i] frame:NSMakeRect(30+i*237, 492, 216, 50) action:actions[i]]; button.image = [NSImage imageWithSystemSymbolName:toolSymbols[i] accessibilityDescription:tools[i]]; button.imagePosition = NSImageLeading; button.font = [NSFont systemFontOfSize:14 weight:NSFontWeightMedium]; if (i == 1) self.recordButton = button; [page addSubview:button]; }
    NSTextField *toolHint = [self label:@"这些操作会应用到当前连接的 Android 设备" frame:NSMakeRect(30, 450, 952, 22)]; toolHint.alignment = NSTextAlignmentCenter; toolHint.font = [NSFont systemFontOfSize:11]; toolHint.textColor = NSColor.secondaryLabelColor; [page addSubview:toolHint];

    [page addSubview:[self card:NSMakeRect(0, 205, 630, 205)]]; [self addCardTitle:@"快速控制" symbol:@"bolt.fill" x:22 y:368 to:page];
    NSArray *controls = @[@"返回", @"主页", @"最近", @"通知", @"音量−", @"音量+", @"锁屏"];
    NSArray *controlSymbols = @[@"chevron.backward", @"house.fill", @"rectangle.stack", @"bell.fill", @"speaker.minus.fill", @"speaker.plus.fill", @"lock.fill"];
    for (NSInteger i = 0; i < controls.count; i++) { NSInteger row=i/4, column=i%4; NSButton *button=[self button:controls[i] frame:NSMakeRect(22+column*148, 298-row*58, 134, 44) action:@selector(quickControl:)]; button.tag=i; button.image=[NSImage imageWithSystemSymbolName:controlSymbols[i] accessibilityDescription:controls[i]]; [page addSubview:button]; }

    [page addSubview:[self card:NSMakeRect(646, 205, 366, 205)]]; [self addCardTitle:@"通讯与剪贴板" symbol:@"message.fill" x:668 y:368 to:page];
    [page addSubview:[self button:@"电话" frame:NSMakeRect(668, 304, 152, 44) action:@selector(openPhone:)]]; [page addSubview:[self button:@"短信" frame:NSMakeRect(838, 304, 152, 44) action:@selector(openMessages:)]]; [page addSubview:[self button:@"粘贴图片" frame:NSMakeRect(668, 246, 322, 44) action:@selector(pasteImageToPhone:)]];

    [page addSubview:[self card:NSMakeRect(0, 18, 1012, 167)]]; [self addCardTitle:@"快捷键与安全" symbol:@"keyboard.badge.ellipsis" x:22 y:143 to:page];
    NSTextField *shortcut = [self label:@"⌘H 主页　⌘B 返回　⌘F 全屏　⌘⇧M 显示控制面板\n⌃⌥Space 切换 Mac 输入语言　⌃⌥⌘Esc 紧急停止并释放输入" frame:NSMakeRect(30, 70, 735, 58)]; shortcut.maximumNumberOfLines = 2; shortcut.font = [NSFont systemFontOfSize:14]; shortcut.textColor = NSColor.secondaryLabelColor; [page addSubview:shortcut];
    NSButton *more = [self button:@"查看全部快捷键" frame:NSMakeRect(790, 77, 190, 42) action:@selector(showShortcuts:)]; [page addSubview:more];
}

- (void)buildAdvancedPage:(NSView *)page {
    [self addPageHeading:@"高级设置" subtitle:@"调整性能、连接恢复和应用行为。" to:page];
    [page addSubview:[self card:NSMakeRect(0, 370, 490, 240)]]; [self addCardTitle:@"性能" symbol:@"cpu.fill" x:22 y:568 to:page];
    [page addSubview:[self label:@"性能配置" frame:NSMakeRect(22, 520, 120, 24)]]; self.profile = [self pagePopup:@[@"平衡", @"高画质", @"流畅", @"低延迟", @"演示模式"] frame:NSMakeRect(210, 516, 255, 30) action:@selector(mirrorSettingChanged:)]; [page addSubview:self.profile];
    [page addSubview:[self label:@"视频码率" frame:NSMakeRect(22, 472, 120, 24)]]; NSSlider *bitrate = [[NSSlider alloc] initWithFrame:NSMakeRect(175, 470, 245, 28)]; bitrate.doubleValue = 60; [page addSubview:bitrate]; [page addSubview:[self label:@"16 Mbps" frame:NSMakeRect(425, 472, 60, 24)]];
    [page addSubview:[self label:@"音频缓冲" frame:NSMakeRect(22, 422, 120, 24)]]; NSSlider *buffer = [[NSSlider alloc] initWithFrame:NSMakeRect(175, 420, 245, 28)]; buffer.doubleValue = 50; [page addSubview:buffer]; [page addSubview:[self label:@"120 ms" frame:NSMakeRect(425, 422, 60, 24)]];

    [page addSubview:[self card:NSMakeRect(506, 370, 506, 240)]]; [self addCardTitle:@"连接恢复" symbol:@"arrow.clockwise" x:528 y:568 to:page];
    self.autoReconnect = [self pageSwitch:@"断线后自动重试" frame:NSMakeRect(528, 516, 462, 28) state:NO action:nil]; [page addSubview:self.autoReconnect]; [page addSubview:[self label:@"最大重试次数" frame:NSMakeRect(528, 468, 150, 24)]]; [page addSubview:[self pagePopup:@[@"3 次", @"2 次", @"1 次"] frame:NSMakeRect(760, 464, 230, 30) action:nil]]; [page addSubview:[self label:@"重试间隔" frame:NSMakeRect(528, 420, 150, 24)]]; [page addSubview:[self pagePopup:@[@"5 秒", @"3 秒", @"10 秒"] frame:NSMakeRect(760, 416, 230, 30) action:nil]];

    [page addSubview:[self card:NSMakeRect(0, 145, 490, 205)]]; [self addCardTitle:@"输入安全" symbol:@"shield.lefthalf.filled" x:22 y:308 to:page];
    self.physicalInput = [self pageSwitch:@"鼠标直通（实验性）" frame:NSMakeRect(22, 260, 443, 28) state:NO action:@selector(mirrorSettingChanged:)]; [page addSubview:self.physicalInput]; self.gamepadControl = [self pageSwitch:@"手柄直通（实验性）" frame:NSMakeRect(22, 220, 443, 28) state:NO action:@selector(mirrorSettingChanged:)]; [page addSubview:self.gamepadControl]; NSTextField *warning = [self label:@"实验性直通可能占用 Mac 输入。紧急停止：⌃⌥⌘Esc" frame:NSMakeRect(22, 168, 440, 36)]; warning.maximumNumberOfLines = 2; warning.textColor = NSColor.systemRedColor; [page addSubview:warning];

    [page addSubview:[self card:NSMakeRect(506, 145, 506, 205)]]; [self addCardTitle:@"外观与行为" symbol:@"paintpalette.fill" x:528 y:308 to:page];
    [page addSubview:[self label:@"语言" frame:NSMakeRect(528, 264, 120, 24)]]; self.language = [self pagePopup:@[@"中文", @"English"] frame:NSMakeRect(760, 260, 230, 30) action:@selector(changeLanguage:)]; [self.language selectItemAtIndex:self.englishUI ? 1 : 0]; [page addSubview:self.language];
    [page addSubview:[self label:@"主题" frame:NSMakeRect(528, 222, 120, 24)]]; self.theme = [self pagePopup:@[@"跟随系统", @"浅色", @"深色"] frame:NSMakeRect(760, 218, 230, 30) action:@selector(changeTheme:)]; [self.theme selectItemAtIndex:[NSUserDefaults.standardUserDefaults integerForKey:@"ThemeMode"]]; [page addSubview:self.theme];
    NSButton *menuStats = [self pageSwitch:@"菜单栏显示设备状态" frame:NSMakeRect(528, 174, 462, 28) state:YES action:nil]; [page addSubview:menuStats];

    [page addSubview:[self card:NSMakeRect(0, 18, 1012, 105)]]; [self addCardTitle:@"关于" symbol:@"info.circle.fill" x:22 y:80 to:page]; BrandArtworkView *icon = [[BrandArtworkView alloc] initWithFrame:NSMakeRect(190, 38, 55, 55)]; [page addSubview:icon]; NSTextField *about = [self label:@"Scrcpy Mate 10.3\n内置 scrcpy、adb 与开放源代码组件" frame:NSMakeRect(260, 42, 440, 48)]; about.maximumNumberOfLines = 2; about.font = [NSFont systemFontOfSize:14 weight:NSFontWeightMedium]; [page addSubview:about]; NSButton *notices = [self button:@"开源项目致谢" frame:NSMakeRect(790, 48, 190, 34) action:@selector(showOpenSourceNotices:)]; [page addSubview:notices];
}

- (void)audioRouteChanged:(NSSegmentedControl *)sender { NSInteger map[] = {0, 3, 1}; [self.audio selectItemAtIndex:map[sender.selectedSegment]]; [self mirrorSettingChanged:sender]; }
- (void)microphoneRouteChanged:(NSSegmentedControl *)sender { if (sender.selectedSegment == 1) { [self.audio selectItemAtIndex:2]; [self mirrorSettingChanged:sender]; } }
- (void)overviewResolutionChanged:(NSPopUpButton *)sender { [self.quality selectItemAtIndex:sender.indexOfSelectedItem]; [self mirrorSettingChanged:sender]; }
- (void)overviewScaleChanged:(NSSlider *)sender { self.dexScale.doubleValue = sender.doubleValue; [self dexScaleChanged:self.dexScale]; }
- (void)overviewAudioChanged:(NSSegmentedControl *)sender { [self.audio selectItemAtIndex:sender.selectedSegment == 0 ? 0 : 3]; [self.outputRoute setSelectedSegment:sender.selectedSegment == 0 ? 0 : 1]; [self mirrorSettingChanged:sender]; }
- (void)overviewToggleChanged:(NSButton *)sender {
    NSButton *target = sender.tag == 1 ? self.dexMode : (sender.tag == 2 ? self.keyboardControl : self.mouseControl); target.state = sender.state; [self mirrorSettingChanged:sender];
}
- (void)saveDevicePreferences:(id)sender {
    NSUserDefaults *d = NSUserDefaults.standardUserDefaults; [d setInteger:self.outputRoute.selectedSegment forKey:@"SavedOutputRoute"]; [d setInteger:self.quality.indexOfSelectedItem forKey:@"SavedResolution"]; [d setBool:self.dexMode.state == NSControlStateValueOn forKey:@"SavedDexMode"]; [d setBool:self.keyboardControl.state == NSControlStateValueOn forKey:@"SavedKeyboard"]; [d setBool:self.mouseControl.state == NSControlStateValueOn forKey:@"SavedMouse"]; [d setBool:self.rememberSettings.state == NSControlStateValueOn forKey:@"RememberDeviceSettings"]; self.status.stringValue = self.englishUI ? @"Settings saved for this phone." : @"已保存这台手机的设置。";
}

- (void)restoreDevicePreferences {
    NSUserDefaults *d = NSUserDefaults.standardUserDefaults;
    BOOL hasPreference = [d objectForKey:@"RememberDeviceSettings"] != nil;
    BOOL remember = hasPreference ? [d boolForKey:@"RememberDeviceSettings"] : YES;
    self.rememberSettings.state = remember ? NSControlStateValueOn : NSControlStateValueOff;
    if (!remember) return;
    NSInteger route = [d objectForKey:@"SavedOutputRoute"] ? [d integerForKey:@"SavedOutputRoute"] : 0;
    route = MIN(MAX(route, 0), 2); self.outputRoute.selectedSegment = route;
    NSInteger audioMap[] = {0, 3, 1}; [self.audio selectItemAtIndex:audioMap[route]];
    if ([d objectForKey:@"SavedResolution"]) [self.quality selectItemAtIndex:MIN(MAX([d integerForKey:@"SavedResolution"], 0), self.quality.numberOfItems-1)];
    if ([d objectForKey:@"SavedDexMode"]) self.dexMode.state = [d boolForKey:@"SavedDexMode"] ? NSControlStateValueOn : NSControlStateValueOff;
    if ([d objectForKey:@"SavedKeyboard"]) self.keyboardControl.state = [d boolForKey:@"SavedKeyboard"] ? NSControlStateValueOn : NSControlStateValueOff;
    if ([d objectForKey:@"SavedMouse"]) self.mouseControl.state = [d boolForKey:@"SavedMouse"] ? NSControlStateValueOn : NSControlStateValueOff;
}

- (void)applicationDidFinishLaunching:(NSNotification *)note {
    self.window = [[NSWindow alloc] initWithContentRect:NSMakeRect(0, 0, 700, 708)
        styleMask:NSWindowStyleMaskTitled|NSWindowStyleMaskClosable|NSWindowStyleMaskMiniaturizable|NSWindowStyleMaskFullSizeContentView
        backing:NSBackingStoreBuffered defer:NO];
    self.window.title = @"Scrcpy Mate 10.3";
    self.window.delegate = self;
    self.window.titlebarAppearsTransparent = YES; self.window.titleVisibility = NSWindowTitleHidden;
    self.window.backgroundColor = NSColor.clearColor;
    self.window.opaque = NO;
    self.window.movableByWindowBackground = YES;
    if (@available(macOS 11.0, *)) self.window.titlebarSeparatorStyle = NSTitlebarSeparatorStyleNone;
    [self.window center];
    GlassBackgroundView *c = [[GlassBackgroundView alloc] initWithFrame:NSMakeRect(0, 0, 700, 708)];
    c.autoresizingMask = NSViewWidthSizable|NSViewHeightSizable;
    self.window.contentView = c;

    NSImage *appIcon = [self applicationIcon]; NSApp.applicationIconImage = appIcon;
    BrandArtworkView *mark = [[BrandArtworkView alloc] initWithFrame:NSMakeRect(24, 614, 52, 52)]; [c addSubview:mark];
    [c addSubview:[self card:NSMakeRect(18, 490, 664, 104)]];
    [c addSubview:[self card:NSMakeRect(18, 187, 664, 290)]];
    [c addSubview:[self card:NSMakeRect(18, 96, 664, 78)]];
    [c addSubview:[self card:NSMakeRect(18, 20, 664, 58)]];
    [c addSubview:[[HeaderPillView alloc] initWithFrame:NSMakeRect(432, 614, 250, 50)]];

    NSTextField *title = [self label:@"Scrcpy Mate" frame:NSMakeRect(88, 627, 300, 34)];
    title.font = [NSFont systemFontOfSize:26 weight:NSFontWeightBold]; [c addSubview:title];
    NSTextField *version = [self label:@"10.3" frame:NSMakeRect(272, 635, 52, 20)]; version.font = [NSFont monospacedSystemFontOfSize:10 weight:NSFontWeightSemibold]; version.textColor = NSColor.secondaryLabelColor; version.alignment = NSTextAlignmentCenter; version.wantsLayer = YES; version.layer.cornerRadius = 8; version.layer.backgroundColor = [NSColor.controlBackgroundColor colorWithAlphaComponent:0.55].CGColor; [c addSubview:version];
    NSTextField *sub = [self label:@"让手机和 Mac 更自然地一起用" frame:NSMakeRect(89, 602, 350, 22)];
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
    self.hideAfterStart = [[NSButton alloc] initWithFrame:NSMakeRect(390, 316, 260, 24)]; self.hideAfterStart.title = @"镜像启动后隐藏控制面板"; self.hideAfterStart.buttonType = NSButtonTypeSwitch; self.hideAfterStart.state = [NSUserDefaults.standardUserDefaults objectForKey:@"HideAfterMirrorStart"] ? [NSUserDefaults.standardUserDefaults boolForKey:@"HideAfterMirrorStart"] : NSControlStateValueOn; self.hideAfterStart.target = self; self.hideAfterStart.action = @selector(hideAfterStartChanged:); [c addSubview:self.hideAfterStart];
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

    self.status = [self label:@"正在查找手机…" frame:NSMakeRect(30, 46, 470, 22)]; self.status.textColor = NSColor.secondaryLabelColor; [c addSubview:self.status];
    self.deviceStats = [[DeviceStatsView alloc] initWithFrame:NSMakeRect(30, 25, 335, 18)];
    self.deviceStats.emptyText = @"电量、内存与存储信息会在连接后显示"; [c addSubview:self.deviceStats];
    self.wirelessButton = [self button:@"无线镜像" frame:NSMakeRect(375, 30, 135, 36) action:@selector(startWirelessMirror:)]; self.wirelessButton.hidden = YES; self.wirelessButton.bezelColor = NSColor.systemBlueColor; [c addSubview:self.wirelessButton];
    self.startButton = [self button:@"开始镜像" frame:NSMakeRect(520, 30, 135, 36) action:@selector(toggleMirror:)]; self.startButton.keyEquivalent = @"\r"; self.startButton.bezelColor = NSColor.systemRedColor; [c addSubview:self.startButton];
    [self.window makeKeyAndOrderFront:nil]; [NSApp activateIgnoringOtherApps:YES];
    // Keep a Dock fallback in addition to the status item, so hiding or closing
    // the panel can never leave the user without a way back into the app.
    [NSApp setActivationPolicy:NSApplicationActivationPolicyRegular];
    [self setupStatusItem];
    self.deviceStatsTimer = [NSTimer scheduledTimerWithTimeInterval:12.0 target:self selector:@selector(updateDeviceStats:) userInfo:nil repeats:YES];
    self.extraTasks = [NSMutableArray array];
    [self setupEmbeddedTools];
    [self installSettingsStyleShell];
    [self restoreDevicePreferences];
    self.englishUI = [NSUserDefaults.standardUserDefaults boolForKey:@"EnglishUI"];
    [self.language selectItemAtIndex:self.englishUI ? 1 : 0];
    [self rebuildStatusMenu];
    [self setupMainMenu];
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
    self.statusItem = [NSStatusBar.systemStatusBar statusItemWithLength:NSVariableStatusItemLength];
    self.statusItem.button.image = [NSImage imageWithSystemSymbolName:@"iphone.and.arrow.forward" accessibilityDescription:@"Scrcpy Mate"];
    self.statusItem.button.image.template = YES; self.statusItem.button.imagePosition = NSImageLeading; self.statusItem.button.title = @" Scrcpy Mate"; self.statusItem.visible = YES;
    self.statusItem.button.target = self; self.statusItem.button.action = @selector(showStatusMenu:);
    [self.statusItem.button sendActionOn:NSEventMaskLeftMouseUp|NSEventMaskRightMouseUp];
    [self rebuildStatusMenu];
}

- (NSMenuItem *)mainMenuItem:(NSString *)title action:(SEL)action key:(NSString *)key modifiers:(NSEventModifierFlags)modifiers {
    NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:title action:action keyEquivalent:key ?: @""]; item.keyEquivalentModifierMask = modifiers; item.target = self; return item;
}

- (void)setupMainMenu {
    NSString *(^L)(NSString *, NSString *) = ^NSString *(NSString *zh, NSString *en) { return self.englishUI ? en : zh; };
    NSMenu *main = [NSMenu new];

    NSMenuItem *appRoot = [[NSMenuItem alloc] initWithTitle:@"Scrcpy Mate" action:nil keyEquivalent:@""]; NSMenu *appMenu = [NSMenu new];
    [appMenu addItem:[self mainMenuItem:L(@"关于 Scrcpy Mate", @"About Scrcpy Mate") action:@selector(openAdvancedFromMenu:) key:@"" modifiers:0]];
    [appMenu addItem:NSMenuItem.separatorItem]; [appMenu addItem:[self mainMenuItem:L(@"设置…", @"Settings…") action:@selector(openAdvancedFromMenu:) key:@"," modifiers:NSEventModifierFlagCommand]];
    [appMenu addItem:NSMenuItem.separatorItem]; NSMenuItem *hide=[self mainMenuItem:L(@"隐藏 Scrcpy Mate", @"Hide Scrcpy Mate") action:@selector(hide:) key:@"h" modifiers:NSEventModifierFlagCommand]; hide.target=NSApp; [appMenu addItem:hide]; NSMenuItem *hideOthers=[self mainMenuItem:L(@"隐藏其他", @"Hide Others") action:@selector(hideOtherApplications:) key:@"h" modifiers:NSEventModifierFlagCommand|NSEventModifierFlagOption]; hideOthers.target=NSApp; [appMenu addItem:hideOthers]; NSMenuItem *showAll=[self mainMenuItem:L(@"全部显示", @"Show All") action:@selector(unhideAllApplications:) key:@"" modifiers:0]; showAll.target=NSApp; [appMenu addItem:showAll];
    [appMenu addItem:NSMenuItem.separatorItem]; NSMenuItem *quit=[self mainMenuItem:L(@"退出 Scrcpy Mate", @"Quit Scrcpy Mate") action:@selector(terminate:) key:@"q" modifiers:NSEventModifierFlagCommand]; quit.target=NSApp; [appMenu addItem:quit]; appRoot.submenu=appMenu; [main addItem:appRoot];

    NSMenuItem *deviceRoot=[[NSMenuItem alloc] initWithTitle:L(@"设备", @"Device") action:nil keyEquivalent:@""]; NSMenu *device=[NSMenu new]; [device addItem:[self mainMenuItem:L(@"刷新设备", @"Refresh Devices") action:@selector(refresh:) key:@"r" modifiers:NSEventModifierFlagCommand]]; [device addItem:[self mainMenuItem:L(@"开始／停止镜像", @"Start / Stop Mirroring") action:@selector(toggleMirror:) key:@"s" modifiers:NSEventModifierFlagCommand|NSEventModifierFlagShift]]; [device addItem:[self mainMenuItem:L(@"无线镜像", @"Wireless Mirroring") action:@selector(startWirelessMirror:) key:@"w" modifiers:NSEventModifierFlagCommand|NSEventModifierFlagShift]]; deviceRoot.submenu=device; [main addItem:deviceRoot];

    NSMenuItem *toolsRoot=[[NSMenuItem alloc] initWithTitle:L(@"工具", @"Tools") action:nil keyEquivalent:@""]; NSMenu *tools=[NSMenu new]; [tools addItem:[self mainMenuItem:L(@"打开工具箱", @"Open Toolbox") action:@selector(openToolboxFromMenu:) key:@"t" modifiers:NSEventModifierFlagCommand|NSEventModifierFlagShift]]; [tools addItem:NSMenuItem.separatorItem]; [tools addItem:[self mainMenuItem:L(@"截图", @"Screenshot") action:@selector(takeScreenshot:) key:@"" modifiers:0]]; [tools addItem:[self mainMenuItem:L(@"开始／停止录屏", @"Start / Stop Recording") action:@selector(toggleRecording:) key:@"" modifiers:0]]; [tools addItem:[self mainMenuItem:L(@"手机相机", @"Phone Camera") action:@selector(startCamera:) key:@"" modifiers:0]]; [tools addItem:[self mainMenuItem:L(@"新建镜像", @"New Mirror") action:@selector(startAdditionalMirror:) key:@"" modifiers:0]]; [tools addItem:NSMenuItem.separatorItem]; [tools addItem:[self mainMenuItem:L(@"镜像快捷键…", @"Mirroring Shortcuts…") action:@selector(showShortcuts:) key:@"/" modifiers:NSEventModifierFlagCommand]]; toolsRoot.submenu=tools; [main addItem:toolsRoot];

    NSMenuItem *viewRoot=[[NSMenuItem alloc] initWithTitle:L(@"视图", @"View") action:nil keyEquivalent:@""]; NSMenu *view=[NSMenu new]; NSArray *viewTitles=self.englishUI ? @[@"Overview",@"Connection",@"Display & Input",@"Audio & Camera",@"File Transfer",@"Apps",@"Toolbox",@"Advanced"] : @[@"概览",@"连接设置",@"画面与输入",@"声音与摄像头",@"文件传输",@"应用",@"工具箱",@"高级设置"]; for (NSInteger i=0;i<viewTitles.count;i++){ NSMenuItem *item=[self mainMenuItem:viewTitles[i] action:@selector(selectSectionFromMenu:) key:[NSString stringWithFormat:@"%ld",(long)i+1] modifiers:NSEventModifierFlagCommand]; item.tag=i; [view addItem:item]; } viewRoot.submenu=view; [main addItem:viewRoot];

    NSMenuItem *helpRoot=[[NSMenuItem alloc] initWithTitle:L(@"帮助", @"Help") action:nil keyEquivalent:@""]; NSMenu *help=[NSMenu new]; [help addItem:[self mainMenuItem:L(@"快捷键与安全", @"Shortcuts & Safety") action:@selector(showShortcuts:) key:@"" modifiers:0]]; [help addItem:[self mainMenuItem:L(@"开源项目致谢", @"Open-source Acknowledgements") action:@selector(showOpenSourceNotices:) key:@"" modifiers:0]]; helpRoot.submenu=help; [main addItem:helpRoot];
    NSApp.mainMenu = main;
}

- (void)showStatusMenu:(id)sender {
    [self updateDeviceStats:nil];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    [self.statusItem popUpStatusItemMenu:self.statusMenu];
#pragma clang diagnostic pop
}

- (void)rebuildStatusMenu {
    NSMenu *menu = [NSMenu new];
    NSString *(^L)(NSString *, NSString *) = ^NSString *(NSString *zh, NSString *en) { return self.englishUI ? en : zh; };
    NSMenuItem *heading = [[NSMenuItem alloc] initWithTitle:@"Scrcpy Mate" action:nil keyEquivalent:@""]; heading.image = [NSImage imageWithSystemSymbolName:@"iphone.and.arrow.forward" accessibilityDescription:nil]; [menu addItem:heading];
    self.menuDevice = [[NSMenuItem alloc] initWithTitle:L(@"未连接手机", @"No phone connected") action:nil keyEquivalent:@""]; [menu addItem:self.menuDevice];
    self.menuStats = [[NSMenuItem alloc] initWithTitle:L(@"连接后显示电量、内存与存储", @"Battery, memory and storage appear after connection") action:nil keyEquivalent:@""]; [menu addItem:self.menuStats];
    [menu addItem:NSMenuItem.separatorItem];
    NSMenuItem *show = [[NSMenuItem alloc] initWithTitle:L(@"显示／隐藏控制面板", @"Show / Hide Control Panel") action:@selector(toggleControlPanel:) keyEquivalent:@"m"]; show.keyEquivalentModifierMask = NSEventModifierFlagCommand|NSEventModifierFlagShift; show.target = self; show.image = [NSImage imageWithSystemSymbolName:@"slider.horizontal.3" accessibilityDescription:nil]; [menu addItem:show];
    NSMenuItem *toolbox = [[NSMenuItem alloc] initWithTitle:L(@"打开工具箱", @"Open Toolbox") action:@selector(openToolboxFromMenu:) keyEquivalent:@"t"]; toolbox.keyEquivalentModifierMask = NSEventModifierFlagCommand|NSEventModifierFlagShift; toolbox.target = self; toolbox.image = [NSImage imageWithSystemSymbolName:@"wrench.and.screwdriver" accessibilityDescription:nil]; [menu addItem:toolbox];
    NSMenuItem *input = [[NSMenuItem alloc] initWithTitle:L(@"切换 Mac 输入语言", @"Switch Mac Input Language") action:@selector(toggleInputLanguage:) keyEquivalent:@" "]; input.keyEquivalentModifierMask = NSEventModifierFlagControl|NSEventModifierFlagOption; input.target = self; input.image = [NSImage imageWithSystemSymbolName:@"globe" accessibilityDescription:nil]; [menu addItem:input];
    NSMenuItem *mirror = [[NSMenuItem alloc] initWithTitle:L(@"开始／停止镜像", @"Start / Stop Mirror") action:@selector(toggleMirror:) keyEquivalent:@"s"]; mirror.keyEquivalentModifierMask = NSEventModifierFlagCommand|NSEventModifierFlagShift; mirror.target = self; mirror.image = [NSImage imageWithSystemSymbolName:@"play.rectangle" accessibilityDescription:nil]; [menu addItem:mirror];
    NSMenuItem *refresh = [[NSMenuItem alloc] initWithTitle:L(@"刷新设备信息", @"Refresh Device Info") action:@selector(refresh:) keyEquivalent:@"r"]; refresh.keyEquivalentModifierMask = NSEventModifierFlagCommand; refresh.target = self; refresh.image = [NSImage imageWithSystemSymbolName:@"arrow.clockwise" accessibilityDescription:nil]; [menu addItem:refresh];
    [menu addItem:NSMenuItem.separatorItem];
    NSMenuItem *hint = [[NSMenuItem alloc] initWithTitle:L(@"紧急停止直通：⌃⌥⌘Esc", @"Emergency passthrough release: ⌃⌥⌘Esc") action:nil keyEquivalent:@""]; [menu addItem:hint];
    NSMenuItem *quit = [[NSMenuItem alloc] initWithTitle:L(@"退出 Scrcpy Mate", @"Quit Scrcpy Mate") action:@selector(terminate:) keyEquivalent:@"q"]; quit.image = [NSImage imageWithSystemSymbolName:@"power" accessibilityDescription:nil]; [menu addItem:quit];
    self.statusMenu = menu;
}

- (void)hideAfterStartChanged:(NSButton *)sender {
    [NSUserDefaults.standardUserDefaults setBool:sender.state == NSControlStateValueOn forKey:@"HideAfterMirrorStart"];
}

- (void)toggleControlPanel:(id)sender {
    if (self.window.visible) [self.window orderOut:nil];
    else { [NSApp activateIgnoringOtherApps:YES]; [self.window makeKeyAndOrderFront:nil]; }
}

- (void)openToolboxFromMenu:(id)sender {
    [NSApp activateIgnoringOtherApps:YES]; [self.window makeKeyAndOrderFront:nil];
    if (self.sidebarButtons.count > 6) [self selectSettingsSection:self.sidebarButtons[6]];
}

- (void)selectSectionFromMenu:(NSMenuItem *)sender {
    [NSApp activateIgnoringOtherApps:YES]; [self.window makeKeyAndOrderFront:nil]; self.sidebarSearch.stringValue = @""; [self filterSidebar:self.sidebarSearch];
    if (sender.tag >= 0 && sender.tag < self.sidebarButtons.count) [self selectSettingsSection:self.sidebarButtons[sender.tag]];
}

- (void)openAdvancedFromMenu:(id)sender {
    [NSApp activateIgnoringOtherApps:YES]; [self.window makeKeyAndOrderFront:nil]; self.sidebarSearch.stringValue = @""; [self filterSidebar:self.sidebarSearch];
    if (self.sidebarButtons.count > 7) [self selectSettingsSection:self.sidebarButtons[7]];
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
- (BOOL)applicationShouldHandleReopen:(NSApplication *)sender hasVisibleWindows:(BOOL)flag {
    if (!flag) { [self.window makeKeyAndOrderFront:nil]; [NSApp activateIgnoringOtherApps:YES]; }
    return YES;
}

- (NSDictionary<NSString *, NSString *> *)translations {
    return @{
        @"让手机和 Mac 更自然地一起用":@"Use your Android naturally with your Mac", @"无线调试扫码":@"Wireless debugging QR", @"跟随系统":@"System", @"浅色":@"Light", @"深色":@"Dark",
        @"设备":@"Device", @"刷新":@"Refresh", @"连接":@"Connect", @"配对码":@"Pair code",
        @"声音 / Mic":@"Audio / Mic", @"手机系统声音 → 电脑":@"Phone audio → Mac", @"手机和电脑同时播放":@"Play on phone and Mac", @"手机麦克风 → 电脑":@"Phone mic → Mac", @"静音":@"Mute",
        @"可切换手机声音或手机 Mic；电脑 Mic → 手机需要额外虚拟音频驱动。":@"Switch phone audio or microphone; Mac mic to phone requires a virtual audio driver.",
        @"画面与输入":@"Display & Input", @"自动":@"Auto", @"电脑键盘控制手机":@"Mac keyboard controls phone", @"电脑鼠标控制手机":@"Mac mouse controls phone", @"保持手机唤醒":@"Keep phone awake",
        @"镜像启动后隐藏控制面板":@"Hide control panel after mirror starts",
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
        @"电量、内存与存储信息会在连接后显示":@"Battery, memory and storage appear after connection",
        @"概览":@"Overview", @"连接设置":@"Connection", @"声音与摄像头":@"Audio & Camera", @"文件传输":@"File Transfer", @"工具箱":@"Toolbox", @"高级设置":@"Advanced",
        @"选择声音、麦克风和手机摄像头的来源。":@"Choose where sound, microphone and phone camera come from.", @"声音输出":@"Sound Output", @"输出设备":@"Output device", @"Mac 系统默认扬声器":@"Mac system default speakers", @"输出音量":@"Output volume",
        @"麦克风输入":@"Microphone Input", @"Mac 麦克风":@"Mac Microphone", @"手机麦克风":@"Phone Microphone", @"输入电平":@"Input level", @"测试":@"Test", @"使用手机麦克风进行通话、录音或监听。":@"Use the phone microphone for calls, recording or monitoring.",
        @"使用手机摄像头":@"Use Phone as Camera", @"启用摄像头预览":@"Enable camera preview", @"摄像头":@"Camera", @"后置摄像头":@"Rear Camera", @"前置摄像头":@"Front Camera", @"打开摄像头预览":@"Open Camera Preview",
        @"保存设置":@"Save Settings", @"记住这台手机的设置":@"Remember settings for this phone", @"声音、摄像头、画面和输入设置将在下次连接时自动恢复。":@"Audio, camera, display and input preferences will restore automatically.", @"设备状态":@"Device Health", @"连接手机后显示电量、CPU、内存与存储":@"Battery, CPU, memory and storage appear after connection",
        @"双击文件夹进入；选择项目后用中间按钮双向传输":@"Double-click folders; select an item and use the centre buttons to transfer.",
        @"通过 macOS 控制你的 Android 设备。":@"Control your Android device from macOS.", @"使用 DeX 模式":@"Use DeX mode", @"发送键盘输入":@"Send keyboard input", @"发送鼠标输入":@"Send mouse input", @"手机声音播放到":@"Play phone audio on", @"麦克风来源":@"Microphone source",
        @"管理 USB、Wi‑Fi 和无线调试连接。":@"Manage USB, Wi-Fi and wireless debugging connections.", @"连接方式":@"Connection Method", @"设备 IP 地址":@"Device IP address", @"无线调试":@"Wireless Debugging", @"使用手机扫描二维码进行配对":@"Scan the QR code with your phone to pair", @"配对":@"Pair", @"●  等待手机扫描":@"●  Waiting for phone scan", @"自动连接":@"Automatic Connection", @"USB 连接后验证 Wi‑Fi":@"Verify Wi-Fi after USB connection", @"记住此设备":@"Remember this device", @"最近的设备":@"Recent Devices",
        @"调整镜像画面、DeX 桌面和电脑输入。":@"Adjust mirror display, DeX desktop and computer input.", @"显示":@"Display", @"分辨率":@"Resolution", @"帧率":@"Frame rate", @"画面质量":@"Image quality", @"文字大小":@"Text size", @"启用 DeX 桌面":@"Enable DeX desktop", @"画面比例":@"Aspect ratio", @"动态窗口大小":@"Dynamic window size", @"根据 DeX 桌面内容自动调整窗口大小。":@"Automatically fit the window to DeX desktop content.", @"输入":@"Input", @"键盘模式":@"Keyboard mode", @"窗口":@"Window", @"快捷操作":@"Shortcuts",
        @"在 Mac 与 Android 设备之间管理和传输文件。":@"Manage and transfer files between Mac and Android.", @"Mac 路径":@"Mac path", @"手机路径":@"Phone path", @"准备传输":@"Ready to transfer", @"将文件拖到此处上传到手机":@"Drop files here to upload to your phone",
        @"快速查找并在镜像窗口中打开手机应用。":@"Find and open phone apps in the mirror window.", @"搜索应用":@"Search apps", @"应用库":@"App Library", @"启动方式":@"Launch Mode", @"使用提示":@"Tips", @"双击应用即可启动。\n抖音、微信等竖屏应用会自动使用合适的显示比例。":@"Double-click an app to launch it.\nPortrait apps automatically use a suitable aspect ratio.", @"常用 Android 操作集中在一个页面中。":@"All common Android actions in one place.", @"这些操作会应用到当前连接的 Android 设备":@"These actions apply to the currently connected Android device", @"通讯与剪贴板":@"Communication & Clipboard", @"快捷键与安全":@"Shortcuts & Safety", @"查看全部快捷键":@"View All Shortcuts",
        @"调整性能、连接恢复和应用行为。":@"Adjust performance, connection recovery and app behaviour.", @"性能":@"Performance", @"性能配置":@"Performance profile", @"视频码率":@"Video bitrate", @"音频缓冲":@"Audio buffer", @"连接恢复":@"Connection Recovery", @"断线后自动重试":@"Retry automatically after disconnect", @"最大重试次数":@"Maximum retries", @"重试间隔":@"Retry interval", @"输入安全":@"Input Safety", @"鼠标直通（实验性）":@"Mouse passthrough (experimental)", @"手柄直通（实验性）":@"Gamepad passthrough (experimental)", @"实验性直通可能占用 Mac 输入。紧急停止：⌃⌥⌘Esc":@"Experimental passthrough may capture Mac input. Emergency stop: ⌃⌥⌘Esc", @"外观与行为":@"Appearance & Behaviour", @"语言":@"Language", @"主题":@"Theme", @"菜单栏显示设备状态":@"Show device status in menu bar", @"关于":@"About", @"开源项目致谢":@"Open-source Acknowledgements", @"选择文件…":@"Choose Files…", @"Scrcpy Mate 10.3\n内置 scrcpy、adb 与开放源代码组件":@"Scrcpy Mate 10.3\nIncludes scrcpy, adb and open-source components"
    };
}

- (NSString *)localizedUIString:(NSString *)value toEnglish:(BOOL)english {
    NSDictionary *map = self.translations;
    if (english) return map[value] ?: value;
    if ([value isEqualToString:@"File Transfer"]) return @"文件传输";
    if ([value isEqualToString:@"Connection"]) return @"连接设置";
    for (NSString *key in map) if ([map[key] isEqualToString:value]) return key;
    return value;
}

- (void)applyLanguageToView:(NSView *)view {
    if ([view isKindOfClass:NSTextField.class]) { NSTextField *field = (NSTextField *)view; if (!field.editable) field.stringValue = [self localizedUIString:field.stringValue toEnglish:self.englishUI]; }
    if ([view isKindOfClass:NSButton.class] && ![view isKindOfClass:NSPopUpButton.class]) { NSButton *button = (NSButton *)view; button.title = [self localizedUIString:button.title toEnglish:self.englishUI]; }
    if ([view isKindOfClass:NSPopUpButton.class] && view != self.language) { NSPopUpButton *popup = (NSPopUpButton *)view; for (NSMenuItem *item in popup.itemArray) item.title = [self localizedUIString:item.title toEnglish:self.englishUI]; }
    if ([view isKindOfClass:NSSegmentedControl.class]) { NSSegmentedControl *segmented = (NSSegmentedControl *)view; for (NSInteger i = 0; i < segmented.segmentCount; i++) [segmented setLabel:[self localizedUIString:[segmented labelForSegment:i] toEnglish:self.englishUI] forSegment:i]; }
    if ([view isKindOfClass:DropView.class]) { ((DropView *)view).displayText = self.englishUI ? @"⇩  Drop files, folders or APKs here" : @"⇩  拖放文件、文件夹或 APK 到这里"; [view setNeedsDisplay:YES]; }
    for (NSView *child in view.subviews) [self applyLanguageToView:child];
}

- (void)changeLanguage:(NSPopUpButton *)sender {
    self.englishUI = sender.indexOfSelectedItem == 1; [NSUserDefaults.standardUserDefaults setBool:self.englishUI forKey:@"EnglishUI"];
    [self applyLanguageToView:self.window.contentView];
    self.sidebarSearch.placeholderString = self.englishUI ? @"Search settings" : @"搜索设置";
    [self rebuildStatusMenu];
    [self setupMainMenu];
    [self updateDeviceStats:nil];
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

- (NSString *)valueForKey:(NSString *)key inColonLines:(NSString *)text {
    for (NSString *line in [text componentsSeparatedByString:@"\n"]) {
        NSString *trimmed = [line stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
        NSString *prefix = [key stringByAppendingString:@":"];
        if ([trimmed hasPrefix:prefix]) return [[trimmed substringFromIndex:prefix.length] stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
    }
    return @"";
}

- (NSArray<NSString *> *)words:(NSString *)line {
    NSMutableArray *values = [NSMutableArray array];
    for (NSString *word in [line componentsSeparatedByCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet]) if (word.length) [values addObject:word];
    return values;
}

- (NSArray<NSNumber *> *)cpuCountersFromProcStat:(NSString *)text {
    NSString *first = [text componentsSeparatedByString:@"\n"].firstObject ?: @"";
    NSArray *parts = [self words:first]; NSMutableArray *numbers = [NSMutableArray array];
    if (parts.count < 5 || ![parts[0] isEqualToString:@"cpu"]) return numbers;
    for (NSUInteger i = 1; i < parts.count; i++) [numbers addObject:@([parts[i] longLongValue])];
    return numbers;
}

- (NSInteger)cpuPercentFromBefore:(NSArray<NSNumber *> *)before after:(NSArray<NSNumber *> *)after {
    if (before.count < 4 || before.count != after.count) return -1;
    unsigned long long totalBefore = 0, totalAfter = 0;
    for (NSNumber *n in before) totalBefore += n.unsignedLongLongValue;
    for (NSNumber *n in after) totalAfter += n.unsignedLongLongValue;
    unsigned long long idleBefore = before[3].unsignedLongLongValue + (before.count > 4 ? before[4].unsignedLongLongValue : 0);
    unsigned long long idleAfter = after[3].unsignedLongLongValue + (after.count > 4 ? after[4].unsignedLongLongValue : 0);
    unsigned long long delta = totalAfter-totalBefore; if (!delta) return -1;
    return (NSInteger)llround(100.0 * (delta-(idleAfter-idleBefore)) / delta);
}

- (NSInteger)cpuPercentFromDumpsys:(NSString *)text {
    for (NSString *line in [text componentsSeparatedByString:@"\n"]) {
        NSString *trimmed = [line stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
        NSRange marker = [trimmed rangeOfString:@"% TOTAL:"];
        if (marker.location != NSNotFound) return [[trimmed substringToIndex:marker.location] integerValue];
    }
    return -1;
}

- (void)syncAudioDeviceStats {
    for (DeviceStatsView *stats in @[self.audioDeviceStats ?: [NSNull null], self.overviewDeviceStats ?: [NSNull null]]) {
        if (![stats isKindOfClass:DeviceStatsView.class]) continue;
        stats.connected = self.deviceStats.connected; stats.battery = self.deviceStats.battery; stats.cpuPercent = self.deviceStats.cpuPercent; stats.memoryFraction = self.deviceStats.memoryFraction; stats.storageFraction = self.deviceStats.storageFraction; stats.memoryText = self.deviceStats.memoryText; stats.storageText = self.deviceStats.storageText; stats.emptyText = self.englishUI ? @"Battery, CPU, memory and storage appear after connection" : @"连接手机后显示电量、CPU、内存与存储"; [stats setNeedsDisplay:YES];
    }
}

- (void)updateDeviceStats:(id)sender {
    NSString *serial = self.serial;
    if (!serial.length || [self.devices.titleOfSelectedItem containsString:@"未找到"] || [self.devices.titleOfSelectedItem containsString:@"No device"]) {
        self.deviceStats.connected = NO;
        self.deviceStats.emptyText = self.englishUI ? @"Battery, memory and storage appear after connection" : @"电量、内存与存储信息会在连接后显示";
        [self.deviceStats setNeedsDisplay:YES];
        [self syncAudioDeviceStats];
        self.menuDevice.title = self.englishUI ? @"No phone connected" : @"未连接手机";
        self.menuStats.title = self.deviceStats.emptyText;
        self.statusItem.button.title = @" Scrcpy Mate";
        self.statusItem.button.image = [NSImage imageWithSystemSymbolName:@"iphone.slash" accessibilityDescription:nil];
        self.statusItem.button.toolTip = self.menuStats.title;
        return;
    }
    NSString *deviceName = self.devices.titleOfSelectedItem ?: serial;
    NSString *adb = [self tool:@"adb"];
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_UTILITY, 0), ^{
        NSString *battery = [self run:adb args:@[@"-s", serial, @"shell", @"dumpsys", @"battery"]][@"text"];
        NSString *memory = [self run:adb args:@[@"-s", serial, @"shell", @"cat", @"/proc/meminfo"]][@"text"];
        NSString *storage = [self run:adb args:@[@"-s", serial, @"shell", @"df", @"-k", @"/data"]][@"text"];
        NSArray *cpuBefore = [self cpuCountersFromProcStat:[self run:adb args:@[@"-s", serial, @"shell", @"cat", @"/proc/stat"]][@"text"]];
        [NSThread sleepForTimeInterval:0.25];
        NSArray *cpuAfter = [self cpuCountersFromProcStat:[self run:adb args:@[@"-s", serial, @"shell", @"cat", @"/proc/stat"]][@"text"]];
        NSInteger cpuPercent = [self cpuPercentFromBefore:cpuBefore after:cpuAfter];
        if (cpuPercent < 0) cpuPercent = [self cpuPercentFromDumpsys:[self run:adb args:@[@"-s", serial, @"shell", @"dumpsys", @"cpuinfo"]][@"text"]];
        NSInteger level = [[self valueForKey:@"level" inColonLines:battery] integerValue];
        CGFloat temperature = [[self valueForKey:@"temperature" inColonLines:battery] doubleValue] / 10.0;
        double totalKB = [[[self valueForKey:@"MemTotal" inColonLines:memory] componentsSeparatedByString:@" "].firstObject doubleValue];
        double availableKB = [[[self valueForKey:@"MemAvailable" inColonLines:memory] componentsSeparatedByString:@" "].firstObject doubleValue];
        NSArray *storageLines = [storage componentsSeparatedByString:@"\n"]; NSArray *disk = @[];
        for (NSString *line in storageLines) { NSArray *candidate = [self words:line]; if (candidate.count >= 6 && ![candidate[0] hasPrefix:@"Filesystem"]) disk = candidate; }
        double diskTotalKB = disk.count >= 6 ? [disk[disk.count-5] doubleValue] : 0;
        double diskUsedKB = disk.count >= 6 ? [disk[disk.count-4] doubleValue] : 0;
        double usedGB = MAX(0, totalKB-availableKB)/1048576.0, totalGB = totalKB/1048576.0;
        double storageUsedGB = diskUsedKB/1048576.0, storageTotalGB = diskTotalKB/1048576.0;
        NSString *link = [serial containsString:@":"] || [serial hasPrefix:@"127.0.0.1:"] ? @"Wi‑Fi" : @"USB";
        NSString *summary = self.englishUI
            ? [NSString stringWithFormat:@"🔋 %ld%%  ·  CPU %@  ·  RAM %.1f/%.1f GB  ·  Storage %.0f/%.0f GB  ·  %@", (long)level, cpuPercent >= 0 ? [NSString stringWithFormat:@"%ld%%", (long)cpuPercent] : @"—", usedGB, totalGB, storageUsedGB, storageTotalGB, link]
            : [NSString stringWithFormat:@"🔋 %ld%%  ·  CPU %@  ·  内存 %.1f/%.1f GB  ·  存储 %.0f/%.0f GB  ·  %@", (long)level, cpuPercent >= 0 ? [NSString stringWithFormat:@"%ld%%", (long)cpuPercent] : @"—", usedGB, totalGB, storageUsedGB, storageTotalGB, link];
        if (temperature > 0) summary = [summary stringByAppendingFormat:@"  ·  %.1f°C", temperature];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (![self.serial isEqualToString:serial]) return;
            self.deviceStats.connected = YES; self.deviceStats.battery = level; self.deviceStats.cpuPercent = MAX(cpuPercent, 0);
            self.deviceStats.memoryFraction = totalKB > 0 ? (totalKB-availableKB)/totalKB : 0;
            self.deviceStats.storageFraction = diskTotalKB > 0 ? diskUsedKB/diskTotalKB : 0;
            self.deviceStats.memoryText = [NSString stringWithFormat:@"CPU %@ · %.0f%%", cpuPercent >= 0 ? [NSString stringWithFormat:@"%ld%%", (long)cpuPercent] : @"—", totalKB > 0 ? (totalKB-availableKB)*100.0/totalKB : 0];
            self.deviceStats.storageText = [NSString stringWithFormat:@"%.0f/%.0fG", storageUsedGB, storageTotalGB];
            [self.deviceStats setNeedsDisplay:YES];
            [self syncAudioDeviceStats];
            self.menuDevice.title = [NSString stringWithFormat:@"%@  ·  %@", deviceName, link];
            self.menuStats.title = summary;
            NSString *batterySymbol = level <= 20 ? @"battery.25" : (level <= 50 ? @"battery.50" : (level <= 75 ? @"battery.75" : @"battery.100"));
            self.menuStats.image = [NSImage imageWithSystemSymbolName:batterySymbol accessibilityDescription:nil];
            self.statusItem.button.image = [NSImage imageWithSystemSymbolName:batterySymbol accessibilityDescription:nil];
            NSInteger ramPercent = totalKB > 0 ? lround((totalKB-availableKB)*100.0/totalKB) : 0;
            self.statusItem.button.title = [NSString stringWithFormat:@" %ld%% · CPU %@ · RAM %ld%%", (long)level, cpuPercent >= 0 ? [NSString stringWithFormat:@"%ld%%", (long)cpuPercent] : @"—", (long)ramPercent];
            self.statusItem.button.toolTip = [NSString stringWithFormat:@"%@\n%@", deviceName, summary];
        });
    });
}

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
            NSString *displayName = found.count ? found.firstObject[@"label"] : (self.englishUI ? @"No Android device" : @"未连接 Android 设备");
            self.overviewDeviceName.stringValue = displayName; self.connectionDeviceName.stringValue = displayName;
            self.overviewConnectionState.stringValue = found.count ? (self.englishUI ? @"●  Connected" : @"●  已连接") : (self.englishUI ? @"●  Searching for device" : @"●  正在查找设备"); self.overviewConnectionState.textColor = found.count ? NSColor.systemGreenColor : NSColor.systemOrangeColor;
            self.connectionStateLabel.stringValue = self.overviewConnectionState.stringValue; self.connectionStateLabel.textColor = self.overviewConnectionState.textColor;
            [self updateDeviceStats:nil];
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
    self.dexScaleValue.hidden = self.settingsStyleShell || !samsung;
    if (!samsung) self.dexMode.state = NSControlStateValueOff;
    NSString *label = self.devices.titleOfSelectedItem ?: @"Android 手机"; self.overviewDeviceName.stringValue = label; self.connectionDeviceName.stringValue = label;
    [self updateDeviceStats:nil];
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
    if (self.settingsStyleShell) { self.toolsPanel.hidden = YES; if (self.appsTable && self.serial.length) [self openAppLauncher:nil]; return; }
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
            if ([raw containsString:@"/private/"] || [raw containsString:@"/Contents/"] || [raw containsString:@"127.0.0.1"] || [raw containsString:@"dylib"]) continue;
            NSArray<NSTextCheckingResult *> *matches = [packagePattern matchesInString:raw options:0 range:NSMakeRange(0, raw.length)]; if (!matches.count) continue;
            NSTextCheckingResult *match = matches.lastObject; NSString *pkg = [raw substringWithRange:match.range];
            if ([pkg hasPrefix:@"github.com"] || [pkg hasPrefix:@"Genymobile.scrcpy"] || [pkg componentsSeparatedByString:@"."].count < 2 || [[NSCharacterSet decimalDigitCharacterSet] characterIsMember:[pkg characterAtIndex:0]]) continue;
            NSString *name = [[raw substringToIndex:match.range.location] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" *\t-[]"]];
            NSRange colon = [name rangeOfString:@"] " options:NSBackwardsSearch]; if (colon.location != NSNotFound) name = [name substringFromIndex:NSMaxRange(colon)];
            if (!name.length || [name containsString:@"INFO:"] || [name containsString:@"List of apps"]) name = known[pkg];
            if (!name.length) { NSString *last = pkg.pathExtension; name = last.length ? [last.capitalizedString stringByReplacingOccurrencesOfString:@"_" withString:@" "] : pkg; }
            [apps addObject:@{@"name":name, @"package":pkg, @"display":[NSString stringWithFormat:@"%@\n%@", name, pkg]}];
        }
        if (!apps.count) { NSDictionary *fallback = [self run:[self tool:@"adb"] args:@[@"-s", serial, @"shell", @"pm", @"list", @"packages", @"-3"]]; for (NSString *line in [fallback[@"text"] componentsSeparatedByString:@"\n"]) if ([line hasPrefix:@"package:"]) { NSString *pkg = [line substringFromIndex:8], *name = known[pkg] ?: pkg.pathExtension.capitalizedString; [apps addObject:@{@"name":name, @"package":pkg, @"display":[NSString stringWithFormat:@"%@\n%@", name, pkg]}]; } }
        [apps sortUsingComparator:^NSComparisonResult(NSDictionary *a, NSDictionary *b) { return [a[@"name"] localizedCaseInsensitiveCompare:b[@"name"]]; }];
        dispatch_async(dispatch_get_main_queue(), ^{ self.allAppItems = apps; self.appItems = [apps mutableCopy]; [self.appsTable reloadData]; self.status.stringValue = apps.count ? [NSString stringWithFormat:@"已读取 %lu 个应用", (unsigned long)apps.count] : @"无法读取应用名称"; self.appsCountLabel.stringValue = apps.count ? [NSString stringWithFormat:@"%lu 个应用", (unsigned long)apps.count] : @"未找到应用"; });
    });
}

- (void)filterApps:(NSSearchField *)sender {
    NSString *query = [sender.stringValue stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
    if (!query.length) self.appItems = [self.allAppItems mutableCopy] ?: [NSMutableArray array];
    else { self.appItems = [NSMutableArray array]; for (NSDictionary *app in self.allAppItems) if ([app[@"name"] rangeOfString:query options:NSCaseInsensitiveSearch].location != NSNotFound || [app[@"package"] rangeOfString:query options:NSCaseInsensitiveSearch].location != NSNotFound) [self.appItems addObject:app]; }
    [self.appsTable reloadData]; self.appsCountLabel.stringValue = [NSString stringWithFormat:@"%lu 个应用", (unsigned long)self.appItems.count];
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

- (void)showOpenSourceNotices:(id)sender {
    NSString *path = [NSBundle.mainBundle.resourcePath stringByAppendingPathComponent:@"OPEN_SOURCE_NOTICES.txt"];
    NSString *notices = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    if (!notices.length) notices = @"Scrcpy Mate includes scrcpy and Android platform tools. Their licences and acknowledgements are included with the application.";

    NSTextView *textView = [[NSTextView alloc] initWithFrame:NSMakeRect(0, 0, 560, 300)];
    textView.string = notices; textView.editable = NO; textView.selectable = YES;
    textView.font = [NSFont systemFontOfSize:12]; textView.textContainerInset = NSMakeSize(10, 10);
    NSScrollView *scroll = [[NSScrollView alloc] initWithFrame:NSMakeRect(0, 0, 560, 300)];
    scroll.hasVerticalScroller = YES; scroll.borderType = NSBezelBorder; scroll.documentView = textView;
    NSAlert *alert = [NSAlert new]; alert.messageText = self.englishUI ? @"Open-source Acknowledgements" : @"开源项目致谢";
    alert.informativeText = self.englishUI ? @"Licences for the open-source components bundled with Scrcpy Mate." : @"Scrcpy Mate 内置开放源代码组件的许可与致谢。";
    alert.accessoryView = scroll; [alert addButtonWithTitle:self.englishUI ? @"Done" : @"完成"]; [alert runModal];
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

- (void)chooseFilesToSend:(id)sender {
    NSOpenPanel *panel = [NSOpenPanel openPanel]; panel.allowsMultipleSelection = YES; panel.canChooseFiles = YES; panel.canChooseDirectories = YES;
    if ([panel runModal] == NSModalResponseOK) [self handleDroppedURLs:panel.URLs];
}

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
        weakSelf.startButton.title = @"开始镜像"; weakSelf.overviewStartButton.title = @"开始镜像";
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
    NSError *error; if ([self.mirrorTask launchAndReturnError:&error]) { NSTask *launchedTask = self.mirrorTask; self.startButton.title = @"停止镜像"; self.overviewStartButton.title = @"停止镜像"; self.status.stringValue = usingWireless ? @"无线镜像运行中；低延迟画面与稳定音频已启用" : @"镜像运行中；拖动窗口边缘即可缩放"; [self updateDeviceStats:nil]; if (self.hideAfterStart.state == NSControlStateValueOn) dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 120 * NSEC_PER_MSEC), dispatch_get_main_queue(), ^{ if (launchedTask.running) [self.window orderOut:nil]; }); dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{ [self updateDeviceStats:nil]; }); dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 10 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{ if (self.mirrorTask == launchedTask && launchedTask.running) self.reconnectAttempts = 0; }); } else self.status.stringValue = error.localizedDescription;
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
    if (self.settingsStyleShell && self.sidebarButtons.count > 4) { [self selectSettingsSection:self.sidebarButtons[4]]; return; }
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
    NSString *pkg = app[@"package"] ?: @"", *symbol = @"app.fill";
    if ([pkg containsString:@"message"] || [pkg containsString:@"tencent.mm"]) symbol = @"message.fill"; else if ([pkg containsString:@"camera"]) symbol = @"camera.fill"; else if ([pkg containsString:@"phone"] || [pkg containsString:@"dialer"]) symbol = @"phone.fill"; else if ([pkg containsString:@"setting"]) symbol = @"gearshape.fill"; else if ([pkg containsString:@"youtube"] || [pkg containsString:@"video"]) symbol = @"play.rectangle.fill"; else if ([pkg containsString:@"file"]) symbol = @"folder.fill"; else if ([pkg containsString:@"browser"] || [pkg containsString:@"chrome"]) symbol = @"globe";
    cell.imageView.image = [NSImage imageWithSystemSymbolName:symbol accessibilityDescription:@"应用"]; cell.imageView.contentTintColor = NSColor.systemBlueColor;
    cell.textField.stringValue = app[@"name"] ?: pkg; cell.textField.font = [NSFont systemFontOfSize:14 weight:NSFontWeightMedium]; cell.textField.textColor = NSColor.labelColor; return cell;
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
