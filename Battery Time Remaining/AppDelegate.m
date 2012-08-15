//
//  AppDelegate.m
//  Battery Time Remaining
//
//  Created by Han Lin Yap on 2012-08-01.
//  Copyright (c) 2012 Han Lin Yap. All rights reserved.
//

#import "AppDelegate.h"
#import "HttpGet.h"
#import "LLManager.h"
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
    
    // Power source menu
    self.psTimeMenu = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"Loading…", @"Remaining menuitem") action:nil keyEquivalent:@""];
    [self.psTimeMenu setEnabled:NO];

    self.psStateMenu = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"Power source: Unknown", @"Powersource menuitem") action:nil keyEquivalent:@""];
    [self.psStateMenu setEnabled:NO];
    
#ifndef SANDBOX
    // Create the startup at login toggle
    self.startupToggle = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"Start at login", @"Start at login setting") action:@selector(toggleStartAtLogin:) keyEquivalent:@""];
    self.startupToggle.target = self;
    self.startupToggle.state = ([LLManager launchAtLogin]) ? NSOnState : NSOffState;
#endif
    
    // Build the notification submenu
    NSMenu *notificationSubmenu = [[NSMenu alloc] initWithTitle:@"Notification Menu"];
    for (int i = 5; i <= 100; i = i + 5) {
        BOOL state = [[self.notifications valueForKey:[NSString stringWithFormat:@"%d", i]] boolValue];
        
        NSMenuItem *notificationSubmenuItem = [[NSMenuItem alloc] initWithTitle:[NSString stringWithFormat:@"%d%%", i] action:@selector(toggleNotification:) keyEquivalent:@""];
        notificationSubmenuItem.tag = i;
        notificationSubmenuItem.state = (state) ? NSOnState : NSOffState;
        [notificationSubmenu addItem:notificationSubmenuItem];
    }
    
    NSMenuItem *notificationMenu = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"Notifications", @"Notification menuitem") action:nil keyEquivalent:@""];
    [notificationMenu setSubmenu:notificationSubmenu];
    
    // Updater menu
    self.updaterMenu = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"Checking for updates…", @"Update menuitem") action:nil keyEquivalent:@""];
    [self.updaterMenu setEnabled:NO];

    // Build the status menu
    NSMenu *statusMenu = [[NSMenu alloc] initWithTitle:@"Status Menu"];
    [statusMenu setDelegate:self];
    [statusMenu addItem:self.psTimeMenu];
    [statusMenu addItem:self.psStateMenu];
    [statusMenu addItem:[NSMenuItem separatorItem]];
#ifndef SANDBOX
    [statusMenu addItem:self.startupToggle];
#endif
    [statusMenu addItem:notificationMenu];
    [statusMenu addItem:[NSMenuItem separatorItem]];

    [statusMenu addItemWithTitle:NSLocalizedString(@"Energy Saver Preferences…", @"Open Energy Saver Preferences menuitem") action:@selector(openEnergySaverPreference:) keyEquivalent:@""];
    [statusMenu addItem:[NSMenuItem separatorItem]];
    [statusMenu addItem:self.updaterMenu];
    [statusMenu addItem:[NSMenuItem separatorItem]];
    [statusMenu addItemWithTitle:NSLocalizedString(@"Quit", @"Quit menuitem") action:@selector(terminate:) keyEquivalent:@""];

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
    
    // Get list of power sources
    CFTypeRef psBlob = IOPSCopyPowerSourcesInfo();
    CFArrayRef psList = IOPSCopyPowerSourcesList(psBlob);

    // Loop through the list of power sources
    CFIndex count = CFArrayGetCount(psList);
    for (CFIndex i = 0; i < count; i++)
    {
        CFTypeRef powersource = CFArrayGetValueAtIndex(psList, i);
        CFDictionaryRef description = IOPSGetPowerSourceDescription(psBlob, powersource);
        
        // Skip if not present
        if (CFDictionaryGetValue(description, CFSTR(kIOPSIsPresentKey)) == kCFBooleanFalse)
        {
            continue;
        }
        
        // Calculate the percent
        NSNumber *currentBatteryCapacity = CFDictionaryGetValue(description, CFSTR(kIOPSCurrentCapacityKey));
        NSNumber *maxBatteryCapacity = CFDictionaryGetValue(description, CFSTR(kIOPSMaxCapacityKey));
        
        NSInteger percent = (int)[currentBatteryCapacity doubleValue] / [maxBatteryCapacity doubleValue] * 100;
        
        // Update menu title
        self.psTimeMenu.title = [NSString stringWithFormat:NSLocalizedString(@"%ld %% left", @"Percentage left menuitem"), percent];
        self.psStateMenu.title = [NSString stringWithFormat:NSLocalizedString(@"Power source: %@", @"Powersource menuitem"), CFDictionaryGetValue(description, CFSTR(kIOPSPowerSourceStateKey))];
        
        // We're connected to an unlimited power source (AC adapter probably)
        if (kIOPSTimeRemainingUnlimited == timeRemaining)
        {
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
                    self.statusItem.title = NSLocalizedString(@" Calculating…", @"Calculating sidetext");
                }
            }
            else
            {
                // Not charging and on a endless powersource
                self.statusItem.image = [self getBatteryIconNamed:@"BatteryCharged"];
                self.statusItem.title = @"";

                NSNumber *currentBatteryCapacity = CFDictionaryGetValue(description, CFSTR(kIOPSCurrentCapacityKey));
                NSNumber *maxBatteryCapacity = CFDictionaryGetValue(description, CFSTR(kIOPSMaxCapacityKey));
                
                if ([currentBatteryCapacity intValue] == [maxBatteryCapacity intValue] &&
                    self.previousPercent != percent &&
                    [[self.notifications valueForKey:@"100"] boolValue]) {
                    
                    [self notify:@"Charged"];
                    self.previousPercent = percent;
                }
            }

        }
        // Still calculating the estimated time remaining...
        else if (kIOPSTimeRemainingUnknown == timeRemaining)
        {
            self.statusItem.image = [self getBatteryIconPercent:percent];
            self.statusItem.title = NSLocalizedString(@" Calculating…", @"Calculating sidetext");
        }
        // Time is known!
        else
        {
            // Calculate the hour/minutes
            NSInteger hour = (int)timeRemaining / 3600;
            NSInteger minute = (int)timeRemaining % 3600 / 60;
            
            // Return the time remaining string
            self.statusItem.image = [self getBatteryIconPercent:percent];
            self.statusItem.title = [NSString stringWithFormat:@" %ld:%02ld", hour, minute];

            for (NSString *key in self.notifications) {
                if ([[self.notifications valueForKey:key] boolValue] && [key intValue] == percent) {
                    // Send notification once
                    if (self.previousPercent != percent) {
                        [self notify:[NSString stringWithFormat:NSLocalizedString(@"%ld:%02ld left (%ld%%)", @"Percentage left menuitem"), hour, minute, percent]];
                    }
                    break;
                }
            }
            self.previousPercent = percent;
        }
        
    }
}

- (NSImage *)getBatteryIconPercent:(NSInteger)percent
{
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
    
    return batteryDynamic;
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

- (void)openHomeUrl:(id)sender
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://github.com/codler/Battery-Time-Remaining/downloads"]];
}

#ifndef SANDBOX
- (void)toggleStartAtLogin:(id)sender
{
    if ([LLManager launchAtLogin]) {
        [LLManager setLaunchAtLogin:NO];
        self.startupToggle.state = NSOffState;
    } else {
        [LLManager setLaunchAtLogin:YES];
        self.startupToggle.state = NSOnState;
    }
}
#endif

- (void)notify:(NSString *)message
{
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    [notification setTitle:NSLocalizedString(@"Battery Time Remaining", @"Notification title")];
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
    if (immutableNotifications) {
        self.notifications = [immutableNotifications mutableCopy];
    } else {
        self.notifications = [NSMutableDictionary new];
    }
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

#pragma mark - NSUserNotificationCenterDelegate methods

// Force show notification
- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification
{
    return YES;
}

- (void)userNotificationCenter:(NSUserNotificationCenter *)center didActivateNotification:(NSUserNotification *)notification
{
    if ([[notification informativeText] isEqualToString:NSLocalizedString(@"A newer version is available", @"Update menuitem")]) {
        [self openHomeUrl:nil];
    }
}

#pragma mark - NSMenuDelegate methods

- (void)menuWillOpen:(NSMenu *)menu
{
    // Stop checking if newer version is available
    if ([self.updaterMenu isEnabled]) {
        return;
    }
    
    // Check for newer version
    [[HttpGet new] url:@"https://raw.github.com/codler/Battery-Time-Remaining/master/build_version" success:^(NSString *result){
        NSInteger latestBuildVersion = [result integerValue];
        NSInteger currentBuildVersion = [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"] integerValue];
        
        if (!latestBuildVersion) {
            self.updaterMenu.title = NSLocalizedString(@"Could not check for updates", @"Update menuitem");
            return;
        }
        
        // Newer version available
        if (latestBuildVersion > currentBuildVersion) {
            self.updaterMenu.title = NSLocalizedString(@"A newer version is available", @"Update menuitem");
            [self.updaterMenu setAction:@selector(openHomeUrl:)];
            [self.updaterMenu setEnabled:YES];
            [self notify:NSLocalizedString(@"A newer version is available", @"Update notification")];
        } else {
            self.updaterMenu.title = NSLocalizedString(@"Up to date", @"Update menuitem");
        }
    } error:^(NSError *error) {
        self.updaterMenu.title = NSLocalizedString(@"Could not check for updates", @"Update menuitem");
    }];
}

@end