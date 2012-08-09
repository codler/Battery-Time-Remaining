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

//#define SANDBOX

// IOPS notification callback on power source change
static void PowerSourceChanged(void * context)
{
    // Update the time remaining text
    AppDelegate *self = (__bridge AppDelegate *)context;
    [self updateStatusItem];
}

@implementation AppDelegate

@synthesize statusItem, startupToggle, notifications, previousPercent;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
#ifndef SANDBOX
    // Init notification
    [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:self];
    [self fetchNotificationSettings];

    // Set default settings if not set
    if (![self.notifications objectForKey:@"15"]) {
        [self.notifications setValue:[NSNumber numberWithBool:YES] forKey:@"15"];
    }
    if (![self.notifications objectForKey:@"100"]) {
        [self.notifications setValue:[NSNumber numberWithBool:YES] forKey:@"100"];
    }
    
    [self saveNotificationSettings];
    
    // Create the startup at login toggle
    self.startupToggle = [[NSMenuItem alloc] initWithTitle:@"Start at login" action:@selector(toggleStartAtLogin:) keyEquivalent:@""];
    self.startupToggle.target = self;
    self.startupToggle.state = ([StartAtLoginHelper isInLoginItems]) ? NSOnState : NSOffState;

    // Build the notification submenu
    NSMenu *notificationSubmenu = [[NSMenu alloc] initWithTitle:@"Notification Menu"];
    for (int i = 5; i <= 100; i = i + 5) {
        BOOL state = [[self.notifications valueForKey:[NSString stringWithFormat:@"%d", i]] boolValue];
        
        NSMenuItem *notificationSubmenuItem = [[NSMenuItem alloc] initWithTitle:[NSString stringWithFormat:@"%d%%", i] action:@selector(toggleNotification:) keyEquivalent:@""];
        notificationSubmenuItem.tag = i;
        notificationSubmenuItem.state = (state) ? NSOnState : NSOffState;
        [notificationSubmenu addItem:notificationSubmenuItem];
    }
    
    NSMenuItem *notificationMenu = [[NSMenuItem alloc] initWithTitle:@"Notifications" action:nil keyEquivalent:@""];
    [notificationMenu setSubmenu:notificationSubmenu];
#endif   
    // Build the status menu
    NSMenu *statusMenu = [[NSMenu alloc] initWithTitle:@"Status Menu"];
#ifndef SANDBOX
    [statusMenu addItem:self.startupToggle];
    [statusMenu addItem:notificationMenu];
    [statusMenu addItem:[NSMenuItem separatorItem]];
#endif
    [statusMenu addItemWithTitle:@"Energy Saver Preferences…" action:@selector(openEnergySaverPreference:) keyEquivalent:@""];
    [statusMenu addItem:[NSMenuItem separatorItem]];
    [statusMenu addItemWithTitle:@"Quit" action:@selector(terminate:) keyEquivalent:@""];

    // Create the status item and set initial text
    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    statusItem.highlightMode = YES;
    statusItem.menu = statusMenu;
    [self updateStatusItem];
    
    // Capture Power Source updates and make sure our callback is called
    CFRunLoopSourceRef loop = IOPSNotificationCreateRunLoopSource(PowerSourceChanged, (__bridge void *)self);
    CFRunLoopAddSource(CFRunLoopGetCurrent(), loop, kCFRunLoopDefaultMode);
    CFRelease(loop);
}

- (void)updateStatusItem
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
                    NSInteger hour = timeTilCharged / 60;
                    NSInteger minute = timeTilCharged % 60;
                    
                    // Return the time remaining string
                    self.statusItem.image = [self getBatteryIconNamed:@"BatteryCharging"];
                    self.statusItem.title = [NSString stringWithFormat:@" %ld:%02ld", hour, minute];
                }
                else
                {
                    self.statusItem.image = [self getBatteryIconNamed:@"BatteryCharging"];
                    self.statusItem.title = @" Calculating…";
                }
            }
            else
            {
                // Not charging and on a endless powersource
                self.statusItem.image = [self getBatteryIconNamed:@"BatteryCharged"];
                self.statusItem.title = @"";

#ifndef SANDBOX
                NSNumber *currentBatteryCapacity = CFDictionaryGetValue(description, CFSTR(kIOPSCurrentCapacityKey));
                NSNumber *maxBatteryCapacity = CFDictionaryGetValue(description, CFSTR(kIOPSMaxCapacityKey));
                
                if ([currentBatteryCapacity intValue] == [maxBatteryCapacity intValue]) {
                    [self notify:@"Charged"];
                }
#endif
            }
        }
    }
    // Still calculating the estimated time remaining...
    else if (kIOPSTimeRemainingUnknown == timeRemaining)
    {
        self.statusItem.image = [self getBatteryIconNamed:@"BatteryEmpty"];
        self.statusItem.title = @" Calculating…";
    }
    // Time is known!
    else
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
            
            // Calculate the percent
            NSNumber *currentBatteryCapacity = CFDictionaryGetValue(description, CFSTR(kIOPSCurrentCapacityKey));
            NSNumber *maxBatteryCapacity = CFDictionaryGetValue(description, CFSTR(kIOPSMaxCapacityKey));

            NSInteger percent = (int)[currentBatteryCapacity doubleValue] / [maxBatteryCapacity doubleValue] * 100;
            
            // Calculate the hour/minutes
            NSInteger hour = (int)timeRemaining / 3600;
            NSInteger minute = (int)timeRemaining % 3600 / 60;
            
            // Make dynamic battery icon
            NSImage *batteryDynamic = [self getBatteryIconNamed:@"BatteryEmpty"];
            
            [batteryDynamic lockFocus];
              
            NSRect sourceRect;
            sourceRect.origin = NSZeroPoint;
            sourceRect.origin.x += [batteryDynamic size].width / 100 * 15;
            sourceRect.origin.y += [batteryDynamic size].height / 50 * 15;
            sourceRect.size = [batteryDynamic size];
            sourceRect.size.width -= [batteryDynamic size].width / 100 * 43;
            sourceRect.size.height -= [batteryDynamic size].height / 50 * 30;

            sourceRect.size.width -= [batteryDynamic size].width / 100 * (60.f - (60.f / 100.f * percent));
            
            if (percent > 15)
            {
                [[NSColor blackColor] set];
            }
            else
            {
                [[NSColor redColor] set];
            }

            NSRectFill(sourceRect);
            
            [batteryDynamic unlockFocus];
            
            // Return the time remaining string
            self.statusItem.image = batteryDynamic;
            self.statusItem.title = [NSString stringWithFormat:@" %ld:%02ld", hour, minute];

#ifndef SANDBOX
            for (NSString *key in self.notifications) {
                if ([[self.notifications valueForKey:key] boolValue] && [key intValue] == percent) {
                    // Send notification once
                    if (self.previousPercent != percent) {
                        [self notify:[NSString stringWithFormat:@"%ld:%02ld left (%ld%%)", hour, minute, percent]];
                    }
                    break;
                }
            }
            self.previousPercent = percent;
#endif
        }
        
    }
}

- (NSImage *)getBatteryIconNamed:(NSString *)iconName
{
    NSString *fileName = [NSString stringWithFormat:@"/System/Library/CoreServices/Menu Extras/Battery.menu/Contents/Resources/%@.pdf", iconName];
    return [[NSImage alloc] initWithContentsOfFile:fileName];
}

- (void)openEnergySaverPreference:(id)sender
{
    [[NSWorkspace sharedWorkspace] openFile:@"/System/Library/PreferencePanes/EnergySaver.prefPane"];
}

#ifndef SANDBOX
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

- (void)notify:(NSString *)message
{
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    [notification setTitle:@"Battery Time Remaining"];
    [notification setInformativeText:message];
    [notification setSoundName:NSUserNotificationDefaultSoundName];
    NSUserNotificationCenter *center = [NSUserNotificationCenter defaultUserNotificationCenter];
    [center scheduleNotification:notification];
}

- (void)fetchNotificationSettings
{
    // Fetch user settings for notifications
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *immutableNotifications = [defaults dictionaryForKey:@"notifications"];
    self.notifications = [immutableNotifications mutableCopy];
}

- (void)saveNotificationSettings
{
    // Save user settings for notifications
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:self.notifications forKey:@"notifications"];
    [defaults synchronize];
}

- (void)toggleNotification:(id)sender
{
    // Get menu item
    NSMenuItem *item = (NSMenuItem *)sender;
    
    // Toggle state
    item.state = (item.state==NSOnState) ? NSOffState : NSOnState;

    [self.notifications setValue:[NSNumber numberWithBool:(item.state==NSOnState)?YES:NO] forKey:[NSString stringWithFormat:@"%ld", item.tag]];
    
    [self saveNotificationSettings];
}

// Force show notification
- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification
{
    return YES;
}
#endif

@end