#import <Cocoa/Cocoa.h>

int main(int argc, const char *argv[]) {
    @autoreleasepool {
        if (argc != 2) return 1;
        NSImage *image = [[NSImage alloc] initWithSize:NSMakeSize(1024, 1024)];
        [image lockFocus];
        [[NSColor clearColor] setFill]; NSRectFill(NSMakeRect(0, 0, 1024, 1024));
        NSGradient *gradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithRed:.98 green:.16 blue:.32 alpha:1] endingColor:[NSColor colorWithRed:.48 green:.22 blue:.96 alpha:1]];
        NSBezierPath *tile = [NSBezierPath bezierPathWithRoundedRect:NSMakeRect(92, 92, 840, 840) xRadius:210 yRadius:210];
        [gradient drawInBezierPath:tile angle:-45];
        NSBezierPath *phone = [NSBezierPath bezierPathWithRoundedRect:NSMakeRect(300, 230, 330, 560) xRadius:58 yRadius:58];
        phone.lineWidth = 42; [NSColor.whiteColor setStroke]; [phone stroke];
        NSBezierPath *arrow = [NSBezierPath bezierPath]; arrow.lineWidth = 46; arrow.lineCapStyle = NSLineCapStyleRound; arrow.lineJoinStyle = NSLineJoinStyleRound;
        [arrow moveToPoint:NSMakePoint(455, 510)]; [arrow lineToPoint:NSMakePoint(760, 510)]; [arrow moveToPoint:NSMakePoint(660, 410)]; [arrow lineToPoint:NSMakePoint(760, 510)]; [arrow lineToPoint:NSMakePoint(660, 610)]; [arrow stroke];
        [image unlockFocus];
        CGImageRef cg = [image CGImageForProposedRect:NULL context:nil hints:nil];
        NSBitmapImageRep *rep = [[NSBitmapImageRep alloc] initWithCGImage:cg];
        [[rep representationUsingType:NSBitmapImageFileTypePNG properties:@{}] writeToFile:[NSString stringWithUTF8String:argv[1]] atomically:YES];
    }
    return 0;
}
