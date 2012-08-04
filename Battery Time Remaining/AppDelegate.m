//
//  AppDelegate.m
//  Battery Time Remaining
//
//  Created by Han Lin Yap on 2012-08-01.
//  Copyright (c) 2012 Han Lin Yap. All rights reserved.
//

#import "AppDelegate.h"
#import "StartAtLoginHelper.h"
#import <IOKit/ps/IOPowerSources.h>
#import <IOKit/ps/IOPSKeys.h>

// IOPS notification callback on power source change
static void PowerSourceChanged(void * context)
{
    // Update the time remaining text
    AppDelegate *self = (__bridge AppDelegate *)context;
    self.statusItem.title = [self getTimeRemainingText];
}

@implementation AppDelegate

@synthesize statusItem;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Create the startup at login toggle
    self.startupToggle = [[NSMenuItem alloc] initWithTitle:@"Start at login" action:@selector(toggleStartAtLogin:) keyEquivalent:@""];
    self.startupToggle.target = self;
    self.startupToggle.state = ([StartAtLoginHelper isInLoginItems]) ? NSOnState : NSOffState;
    
    // Build the status menu
    NSMenu *statusMenu = [[NSMenu alloc] initWithTitle:@"Status Menu"];
    [statusMenu addItem:self.startupToggle];
    [statusMenu addItemWithTitle:@"Quit" action:@selector(terminate:) keyEquivalent:@""];
    
    // Create the status item and set initial text
    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    statusItem.highlightMode = YES;
    statusItem.menu = statusMenu;
    statusItem.title = [self getTimeRemainingText];
    
    // Capture Power Source updates and make sure our callback is called
    CFRunLoopSourceRef loop = IOPSNotificationCreateRunLoopSource(PowerSourceChanged, (__bridge void *)self);
    CFRunLoopAddSource(CFRunLoopGetCurrent(), loop, kCFRunLoopDefaultMode);
    CFRelease(loop);
}

- (NSString *)getTimeRemainingText
{
    // Get the estimated time remaining
    CFTimeInterval timeRemaining = IOPSGetTimeRemainingEstimate();
    
    // We're connected to an unlimited power source (AC adapter probably)
    if (kIOPSTimeRemainingUnlimited == timeRemaining)
    {
        // Get list of power sources
        CFTypeRef psBlob = IOPSCopyPowerSourcesInfo();
        CFArrayRef psList = IOPSCopyPowerSourcesList(psBlob);
        
        // Loop through the list of power sources
        CFIndex count = CFArrayGetCount(psList);
        for (CFIndex i = 0; i < count; i++)
        {
            CFTypeRef powersource = CFArrayGetValueAtIndex(psList, i);
            CFDictionaryRef description = IOPSGetPowerSourceDescription(psBlob, powersource);
            
            // Skip if not present or not a battery
            if (CFDictionaryGetValue(description, CFSTR(kIOPSIsPresentKey)) == kCFBooleanFalse || !CFStringCompare(CFDictionaryGetValue(description, CFSTR(kIOPSPowerSourceStateKey)), CFSTR(kIOPSBatteryPowerValue), 0))
            {
                continue;
            }
                
            // Check if the battery is charging atm
            if (CFDictionaryGetValue(description, CFSTR(kIOPSIsChargingKey)) == kCFBooleanTrue)
            {
                CFNumberRef timeToChargeNum = CFDictionaryGetValue(description, CFSTR(kIOPSTimeToFullChargeKey));
                int timeTilCharged = [(__bridge NSNumber *)timeToChargeNum intValue];
                
                if (timeTilCharged > 0)
                {
                    // Calculate the hour/minutes
                    NSInteger hour = (int)timeTilCharged / 3600;
                    NSInteger minute = (int)timeTilCharged % 3600;
                    
                    // Return the time remaining string
                    return [NSString stringWithFormat:@"🔌 %ld:%02ld", hour, minute];
                }
                else
                {
                    return @"🔌 Calculating…";
                }
            }
            else
            {
                // Not charging and on a endless powersource
                return @"🔌";
            }
            
            return @"Error…";
        }
    }
    // Still calculating the estimated time remaining...
    else if (kIOPSTimeRemainingUnknown == timeRemaining)
    {
        return @"Calculating…";
    }
    // Time is known!
    else
    {
        // Calculate the hour/minutes 
        NSInteger hour = (int)timeRemaining / 3600;
        NSInteger minute = (int)timeRemaining % 3600 / 60;
        
        // Return the time remaining string
        return [NSString stringWithFormat:@"%ld:%02ld", hour, minute];
    }
}

- (void)toggleStartAtLogin:(id)sender
{
    // Check the state of start at login 
    if ([StartAtLoginHelper isInLoginItems])
    {
        [StartAtLoginHelper removeFromLoginItems];
        self.startupToggle.state = NSOffState;
    }
    else
    {
        [StartAtLoginHelper addToLoginItems];
        self.startupToggle.state = NSOnState;
    }
}

@end