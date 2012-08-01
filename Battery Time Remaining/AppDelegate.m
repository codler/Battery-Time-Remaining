//
//  AppDelegate.m
//  Battery Time Remaining
//
//  Created by Han Lin Yap on 2012-08-01.
//  Copyright (c) 2012 Han Lin Yap. All rights reserved.
//

#import "AppDelegate.h"
#import <IOKit/ps/IOPowerSources.h>

static void PowerSourceChanged(void * context) {
    
    AppDelegate * self = (__bridge AppDelegate *)context;
    [self.statusItem setTitle:[self GetTimeRemainingText]];
}

@implementation AppDelegate

@synthesize statusItem;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    NSMenu *stackMenu = [[NSMenu alloc] initWithTitle:@"Status Menu"];
    [stackMenu addItemWithTitle:@"Quit" action:@selector(terminate:) keyEquivalent:@""];
    
    statusItem = [[NSStatusBar systemStatusBar]
                  statusItemWithLength:NSVariableStatusItemLength];
    [statusItem setHighlightMode:YES];
    [statusItem setMenu:stackMenu];
    
    NSString *title = [self GetTimeRemainingText];
    
    [statusItem setTitle:title];
    
    // Update Power Source
    CFRunLoopSourceRef loop = IOPSNotificationCreateRunLoopSource(PowerSourceChanged, (__bridge void *)self);
    CFRunLoopAddSource(CFRunLoopGetCurrent(), loop, kCFRunLoopDefaultMode);
    CFRelease(loop);
}

- (NSString*)GetTimeRemainingText
{
    if (kIOPSTimeRemainingUnlimited == IOPSGetTimeRemainingEstimate()) {
        return @"Ω Unlimited Ω";
    } else if (kIOPSTimeRemainingUnknown == IOPSGetTimeRemainingEstimate()) {
        return @"Ω Calculating Ω";
    } else {
        CFTimeInterval time = IOPSGetTimeRemainingEstimate();
        NSInteger hour = (int)time / 3600;
        NSInteger minut = (int)time % 3600 / 60;
        return [NSString stringWithFormat:@"<%ld:%02ld>", hour, minut];
    }
}

@end