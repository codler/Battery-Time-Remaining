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
#import <IOKit/pwr_mgt/IOPM.h>
#import <IOKit/pwr_mgt/IOPMLib.h>
#import <QuartzCore/QuartzCore.h>

// In Apple's battery gauge, the battery icon is rendered further down from the
// top than NSStatusItem does it. Hence we add an extra top offset to get the
// exact same look.
#define EXTRA_TOP_OFFSET   2.0f

// IOPS notification callback on power source change
static void PowerSourceChanged(void * context)
{
    // Update the time remaining text
    AppDelegate *self = (__bridge AppDelegate *)context;
    [self updateStatusItem];
}

@interface AppDelegate () {
   NSDictionary      *m_images;
   BOOL              m_showParens;
}
- (void)cacheNamedImages;
- (NSImage *)loadBatteryIconNamed:(NSString *)iconName;
@end

@implementation AppDelegate

@synthesize statusItem, notifications, previousPercent;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.advancedSupported = ([self getAdvancedBatteryInfo] != nil);
    [self cacheNamedImages];

    // Init notification
    [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:self];
    [self loadNotificationSetting];
    
    // Set default notification settings if not set
    if (![self.notifications objectForKey:@"15"])
    {
        [self.notifications setValue:[NSNumber numberWithBool:YES] forKey:@"15"];
    }
    if (![self.notifications objectForKey:@"100"])
    {
        [self.notifications setValue:[NSNumber numberWithBool:YES] forKey:@"100"];
    }
    
    [self saveNotificationSetting];
    
    // Power source menu item
    NSMenuItem *psPercentMenu = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"Loading…", @"Remaining menuitem") action:nil keyEquivalent:@""];
    [psPercentMenu setTag:kBTRMenuPowerSourcePercent];
    [psPercentMenu setEnabled:NO];
    
    NSMenuItem *psStateMenu = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"Power source: Unknown", @"Powersource menuitem") action:nil keyEquivalent:@""];
    [psStateMenu setTag:kBTRMenuPowerSourceState];
    [psStateMenu setEnabled:NO];
    
    NSMenuItem *psAdvancedMenu = [[NSMenuItem alloc] initWithTitle:@"" action:nil keyEquivalent:@""];
    [psAdvancedMenu setTag:kBTRMenuPowerSourceAdvanced];
    [psAdvancedMenu setEnabled:NO];
    [psAdvancedMenu setHidden:![[NSUserDefaults standardUserDefaults] boolForKey:@"advanced"]];
    
    // Start at login menu item
    NSMenuItem *startAtLoginMenu = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"Start at login", @"Start at login setting") action:@selector(toggleStartAtLogin:) keyEquivalent:@""];
    [startAtLoginMenu setTag:kBTRMenuStartAtLogin];
    startAtLoginMenu.target = self;
    startAtLoginMenu.state = ([LLManager launchAtLogin]) ? NSOnState : NSOffState;
    
    // Build the notification submenu
    NSMenu *notificationSubmenu = [[NSMenu alloc] initWithTitle:@"Notification Menu"];
    for (int i = 5; i <= 100; i = i + 5)
    {
        BOOL state = [[self.notifications valueForKey:[NSString stringWithFormat:@"%d", i]] boolValue];
        
        NSMenuItem *notificationSubmenuItem = [[NSMenuItem alloc] initWithTitle:[NSString stringWithFormat:@"%d%%", i] action:@selector(toggleNotification:) keyEquivalent:@""];
        notificationSubmenuItem.tag = i;
        notificationSubmenuItem.state = (state) ? NSOnState : NSOffState;
        [notificationSubmenu addItem:notificationSubmenuItem];
    }
    
    // Notification menu item
    NSMenuItem *notificationMenu = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"Notifications", @"Notification menuitem") action:nil keyEquivalent:@""];
    [notificationMenu setTag:kBTRMenuNotification];
    [notificationMenu setSubmenu:notificationSubmenu];
    [notificationMenu setHidden:self.advancedSupported && ![[NSUserDefaults standardUserDefaults] boolForKey:@"advanced"]];

    // Build the settings submenu
    NSMenu *settingsSubmenu = [[NSMenu alloc] initWithTitle:@"Settings Menu"];
    // Advanced mode menu item
    NSMenuItem *advancedSubmenuItem = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"Advanced mode", @"Advanced mode setting") action:@selector(toggleAdvanced:) keyEquivalent:@""];
    [advancedSubmenuItem setTag:kBTRMenuAdvanced];
    advancedSubmenuItem.target = self;
    advancedSubmenuItem.state = ([[NSUserDefaults standardUserDefaults] boolForKey:@"advanced"]) ? NSOnState : NSOffState;
    [advancedSubmenuItem setHidden:!self.advancedSupported];
    [settingsSubmenu addItem:advancedSubmenuItem];
    // time display control menu item
    NSMenuItem *timeFormatSubmenuItem = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"Time display with braces", @"Time display with braces setting") action:@selector(toggleParentheses:) keyEquivalent:@""];
    [timeFormatSubmenuItem setTag:kBTRMenuParentheses];
    timeFormatSubmenuItem.target = self;
    m_showParens = [[NSUserDefaults standardUserDefaults] boolForKey:@"parentheses"];
    timeFormatSubmenuItem.state = (m_showParens) ? NSOnState : NSOffState;
    [settingsSubmenu addItem:timeFormatSubmenuItem];

   // Settings menu item
   NSMenuItem *settingsMenu = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"Settings", @"Settings menuitem") action:nil keyEquivalent:@""];
   [settingsMenu setTag:kBTRMenuSettings];
   [settingsMenu setSubmenu:settingsSubmenu];

    // Updater menu
    NSMenuItem *updaterMenu = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"Checking for updates…", @"Update menuitem") action:nil keyEquivalent:@""];
    [updaterMenu setTag:kBTRMenuUpdater];
    [updaterMenu setEnabled:NO];
    
    // Build the statusbar menu
    NSMenu *statusBarMenu = [[NSMenu alloc] initWithTitle:@"Status Menu"];
    [statusBarMenu setDelegate:self];
    
    [statusBarMenu addItem:psPercentMenu];
    [statusBarMenu addItem:psStateMenu];
    [statusBarMenu addItem:psAdvancedMenu];
    [statusBarMenu addItem:[NSMenuItem separatorItem]]; // Separator
    
    [statusBarMenu addItem:startAtLoginMenu];
    [statusBarMenu addItem:notificationMenu];
    [statusBarMenu addItem:settingsMenu];
    [statusBarMenu addItem:[NSMenuItem separatorItem]]; // Separator
    
    [statusBarMenu addItemWithTitle:NSLocalizedString(@"Energy Saver Preferences…", @"Open Energy Saver Preferences menuitem") action:@selector(openEnergySaverPreference:) keyEquivalent:@""];
    [statusBarMenu addItem:[NSMenuItem separatorItem]]; // Separator
    
    [statusBarMenu addItem:updaterMenu];
    [statusBarMenu addItem:[NSMenuItem separatorItem]]; // Separator
    
    [statusBarMenu addItemWithTitle:NSLocalizedString(@"Quit", @"Quit menuitem") action:@selector(terminate:) keyEquivalent:@""];
    
    // Create the status item and set initial text
    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    statusItem.highlightMode = YES;
    statusItem.menu = statusBarMenu;
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
        
        self.currentPercent = (int)[currentBatteryCapacity doubleValue] / [maxBatteryCapacity doubleValue] * 100;
        
        [self.statusItem.menu itemWithTag:kBTRMenuPowerSourceState].title = [NSString stringWithFormat:NSLocalizedString(@"Power source: %@", @"Powersource menuitem"), CFDictionaryGetValue(description, CFSTR(kIOPSPowerSourceStateKey))];
        
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
                    [self setStatusBarImage:[self getBatteryIconNamed:@"BatteryCharging"] title:[NSString stringWithFormat:@" %@%ld:%02ld%@",
                                                                                                 (m_showParens)?@"(":@"",
                                                                                                 hour, minute,
                                                                                                 (m_showParens)?@")":@""]];
                }
                else
                {
                    [self setStatusBarImage:[self getBatteryIconNamed:@"BatteryCharging"] title:[NSString stringWithFormat:@" %@", NSLocalizedString(@"Calculating…", @"Calculating sidetext")]];
                }
            }
            else
            {
                // Not charging and on a endless powersource
                [self setStatusBarImage:[self getBatteryIconNamed:@"BatteryCharged"] title:@""];
                
                NSNumber *currentBatteryCapacity = CFDictionaryGetValue(description, CFSTR(kIOPSCurrentCapacityKey));
                NSNumber *maxBatteryCapacity = CFDictionaryGetValue(description, CFSTR(kIOPSMaxCapacityKey));
                
                // Notify user when battery is charged
                if ([currentBatteryCapacity intValue] == [maxBatteryCapacity intValue] &&
                    self.previousPercent != self.currentPercent &&
                    [[self.notifications valueForKey:@"100"] boolValue])
                {
                    
                    [self notify:NSLocalizedString(@"Charged", @"Charged notification")];
                    self.previousPercent = self.currentPercent;
                }
            }
            
        }
        // Still calculating the estimated time remaining...
        else if (kIOPSTimeRemainingUnknown == timeRemaining)
        {
            [self setStatusBarImage:[self getBatteryIconPercent:self.currentPercent] title:[NSString stringWithFormat:@" %@", NSLocalizedString(@"Calculating…", @"Calculating sidetext")]];
        }
        // Time is known!
        else
        {
            // Calculate the hour/minutes
            NSInteger hour = (int)timeRemaining / 3600;
            NSInteger minute = (int)timeRemaining % 3600 / 60;
            
            // Return the time remaining string
           [self setStatusBarImage:[self getBatteryIconPercent:self.currentPercent] title:[NSString stringWithFormat:@" %@%ld:%02ld%@",
                                                                                           (m_showParens)?@"(":@"",
                                                                                           hour, minute,
                                                                                           (m_showParens)?@")":@""]];

            for (NSString *key in self.notifications)
            {
                if ([[self.notifications valueForKey:key] boolValue] && [key intValue] == self.currentPercent)
                {
                    // Send notification once
                    if (self.previousPercent != self.currentPercent)
                    {
                        [self notify:[NSString stringWithFormat:NSLocalizedString(@"%ld:%02ld left (%ld%%)", @"Time remaining left notification"), hour, minute, self.currentPercent]];
                    }
                    break;
                }
            }
            self.previousPercent = self.currentPercent;
        }
        
    }
}

- (void)setStatusBarImage:(NSImage *)image title:(NSString *)title
{
    // Image
    [self.statusItem setImage:image];
    [self.statusItem setAlternateImage:[self imageInvertColor:image]];

    // Title
    NSDictionary *attributedStyle = [NSDictionary dictionaryWithObjectsAndKeys:
                                     // Font
                                     [NSFont menuFontOfSize:12.0f],
                                     NSFontAttributeName,
                                     nil];

    NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:attributedStyle];
    self.statusItem.attributedTitle = attributedTitle;
}

- (NSDictionary *)getAdvancedBatteryInfo
{
    mach_port_t masterPort;
    CFArrayRef batteryInfo;
    
    if (kIOReturnSuccess == IOMasterPort(MACH_PORT_NULL, &masterPort) &&
        kIOReturnSuccess == IOPMCopyBatteryInfo(masterPort, &batteryInfo))
    {
        return [(__bridge NSArray*)batteryInfo objectAtIndex:0];
    }
    return nil;
}

- (NSDictionary *)getMoreAdvancedBatteryInfo
{
    CFMutableDictionaryRef matching, properties = NULL;
    io_registry_entry_t entry = 0;
    // same as matching = IOServiceMatching("IOPMPowerSource");
    matching = IOServiceNameMatching("AppleSmartBattery");
    entry = IOServiceGetMatchingService(kIOMasterPortDefault, matching);
    IORegistryEntryCreateCFProperties(entry, &properties, NULL, 0);
    return (__bridge NSDictionary *)properties;
    //IOObjectRelease(entry);
}

- (NSImage *)getBatteryIconPercent:(NSInteger)percent
{
   //
   // Mimic Apple's original battery icon using hires artwork
   //
   NSImage  *batteryOutline     = [self getBatteryIconNamed:@"BatteryEmpty"];
   NSImage  *batteryLevelLeft   = nil;
   NSImage  *batteryLevelMiddle = nil;
   NSImage  *batteryLevelRight  = nil;

   if (percent > 15) {
      // draw black capacity bar
      batteryLevelLeft   = [self getBatteryIconNamed:@"BatteryLevelCapB-L"];
      batteryLevelMiddle = [self getBatteryIconNamed:@"BatteryLevelCapB-M"];
      batteryLevelRight  = [self getBatteryIconNamed:@"BatteryLevelCapB-R"];
   }
   else {
      // draw red capacity bar
      batteryLevelLeft     = [self getBatteryIconNamed:@"BatteryLevelCapR-L"];
      batteryLevelMiddle   = [self getBatteryIconNamed:@"BatteryLevelCapR-M"];
      batteryLevelRight    = [self getBatteryIconNamed:@"BatteryLevelCapR-R"];
   }

   const CGFloat  drawingUnit        = [batteryLevelLeft size].width;
   const CGFloat  capBarLeftOffset   = 3.0f * drawingUnit;
   CGFloat        capBarHeight       = [batteryLevelLeft size].height;
   CGFloat        capBarTopOffset    = (([batteryOutline size].height - (EXTRA_TOP_OFFSET * drawingUnit)) - capBarHeight) / 2.0;
   CGFloat        capBarLength       = ceil(percent / 8.0f) * drawingUnit;    // max width is 13 units
   if (capBarLength < (2 * drawingUnit)) { capBarLength = 2 * drawingUnit; }

   [batteryOutline lockFocus];
   [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];
   NSDrawThreePartImage(NSMakeRect(capBarLeftOffset, capBarTopOffset, capBarLength, capBarHeight),
                        batteryLevelLeft, batteryLevelMiddle, batteryLevelRight,
                        NO,
                        NSCompositeCopy,
                        0.94f,
                        NO);
   [batteryOutline unlockFocus];

   return batteryOutline;
}

- (NSImage *)getBatteryIconNamed:(NSString *)iconName {
   return [m_images objectForKey:iconName];
}

- (NSImage *)loadBatteryIconNamed:(NSString *)iconName
{
    NSString *fileName = [NSString stringWithFormat:@"/System/Library/CoreServices/Menu Extras/Battery.menu/Contents/Resources/%@.pdf", iconName];
    return [[NSImage alloc] initWithContentsOfFile:fileName];
}

- (void)cacheNamedImages {
   // special treatment for the BatteryCharging, BatteryCharged, and BatteryEmpty images
   // they need to be shifted down by 1px to be in the same position as Apple's
   NSSize   newSize;
   NSImage  *origImg = nil;

   origImg = [self loadBatteryIconNamed:@"BatteryCharging"];
   newSize.width  = origImg.size.width;
   newSize.height = origImg.size.height + EXTRA_TOP_OFFSET;
   NSImage  *imgCharging = [[NSImage alloc] initWithSize:newSize];
   [imgCharging lockFocus];
   [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];
   [origImg drawInRect:NSMakeRect(0, 0, origImg.size.width, origImg.size.height)
              fromRect:NSMakeRect(0, 0, origImg.size.width, origImg.size.height)
             operation:NSCompositeSourceOver
              fraction:1.0];
   [imgCharging unlockFocus];

   origImg = [self loadBatteryIconNamed:@"BatteryCharged"];
   newSize.width  = origImg.size.width;
   newSize.height = origImg.size.height + EXTRA_TOP_OFFSET;
   NSImage  *imgCharged = [[NSImage alloc] initWithSize:newSize];
   [imgCharged lockFocus];
   [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];
   [origImg drawInRect:NSMakeRect(0, 0, origImg.size.width, origImg.size.height)
              fromRect:NSMakeRect(0, 0, origImg.size.width, origImg.size.height)
             operation:NSCompositeSourceOver
              fraction:1.0];
   [imgCharged unlockFocus];

   origImg = [self loadBatteryIconNamed:@"BatteryEmpty"];
   newSize.width  = origImg.size.width;
   newSize.height = origImg.size.height + EXTRA_TOP_OFFSET;
   NSImage  *imgEmpty = [[NSImage alloc] initWithSize:newSize];
   [imgEmpty lockFocus];
   [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];
   [origImg drawInRect:NSMakeRect(0, 0, origImg.size.width, origImg.size.height)
              fromRect:NSMakeRect(0, 0, origImg.size.width, origImg.size.height)
             operation:NSCompositeSourceOver
              fraction:1.0];
   [imgEmpty unlockFocus];

   // finally construct the dictionary from which we will retrieve the images at runtime
   m_images = [NSDictionary dictionaryWithObjectsAndKeys:
               imgCharging,                                       @"BatteryCharging",
               imgCharged,                                        @"BatteryCharged",
               imgEmpty,                                          @"BatteryEmpty",
               [self loadBatteryIconNamed:@"BatteryLevelCapB-L"], @"BatteryLevelCapB-L",
               [self loadBatteryIconNamed:@"BatteryLevelCapB-M"], @"BatteryLevelCapB-M",
               [self loadBatteryIconNamed:@"BatteryLevelCapB-R"], @"BatteryLevelCapB-R",
               [self loadBatteryIconNamed:@"BatteryLevelCapR-L"], @"BatteryLevelCapR-L",
               [self loadBatteryIconNamed:@"BatteryLevelCapR-M"], @"BatteryLevelCapR-M",
               [self loadBatteryIconNamed:@"BatteryLevelCapR-R"], @"BatteryLevelCapR-R",
               nil];
}

- (NSImage *)imageInvertColor:(NSImage *)_image
{
    NSImage *image = [_image copy];
    [image lockFocus];
    
    CIImage *ciImage = [[CIImage alloc] initWithData:[image TIFFRepresentation]];
    CIFilter *filter = [CIFilter filterWithName:@"CIColorInvert"];
    [filter setDefaults];
    [filter setValue:ciImage forKey:@"inputImage"];
    CIImage *output = [filter valueForKey:@"outputImage"];
    [output drawInRect:NSMakeRect(0, 0, [_image size].width, [_image size].height) fromRect:NSRectFromCGRect([output extent]) operation:NSCompositeSourceOver fraction:1.0];
    
    [image unlockFocus];
    
    return image;
}

- (void)openEnergySaverPreference:(id)sender
{
    [[NSWorkspace sharedWorkspace] openFile:@"/System/Library/PreferencePanes/EnergySaver.prefPane"];
}

- (void)openHomeUrl:(id)sender
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://github.com/codler/Battery-Time-Remaining/downloads"]];
}

- (void)toggleStartAtLogin:(id)sender
{
    if ([LLManager launchAtLogin])
    {
        [LLManager setLaunchAtLogin:NO];
        [self.statusItem.menu itemWithTag:kBTRMenuStartAtLogin].state = NSOffState;
    }
    else
    {
        [LLManager setLaunchAtLogin:YES];
        [self.statusItem.menu itemWithTag:kBTRMenuStartAtLogin].state = NSOnState;
    }
}

- (void)toggleAdvanced:(id)sender
{
    NSMenuItem     *item = sender;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    if ([defaults boolForKey:@"advanced"])
    {
        item.state = NSOffState;
        [[self.statusItem.menu itemWithTag:kBTRMenuPowerSourceAdvanced] setHidden:YES];
        [[self.statusItem.menu itemWithTag:kBTRMenuNotification] setHidden:YES];
        [defaults setBool:NO forKey:@"advanced"];
    }
    else
    {
        item.state = NSOnState;
        [[self.statusItem.menu itemWithTag:kBTRMenuPowerSourceAdvanced] setHidden:NO];
        [[self.statusItem.menu itemWithTag:kBTRMenuNotification] setHidden:NO];
        [defaults setBool:YES forKey:@"advanced"];
    }
    [defaults synchronize];
    
    [self updateStatusItem];
}

- (void)toggleParentheses:(id)sender
{
   NSMenuItem     *item = sender;
   NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

   if ([defaults boolForKey:@"parentheses"])
   {
      item.state = NSOffState;
      m_showParens = NO;
      [defaults setBool:NO forKey:@"parentheses"];
   }
   else
   {
      item.state = NSOnState;
      m_showParens = YES;
      [defaults setBool:YES forKey:@"parentheses"];
   }
   [defaults synchronize];

   [self updateStatusItem];
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

- (void)loadNotificationSetting
{
    // Fetch user settings for notifications
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *immutableNotifications = [defaults dictionaryForKey:@"notifications"];
    if (immutableNotifications)
    {
        self.notifications = [immutableNotifications mutableCopy];
    }
    else
    {
        self.notifications = [NSMutableDictionary new];
    }
}

- (void)saveNotificationSetting
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
    
    [self saveNotificationSetting];
}

#pragma mark - NSUserNotificationCenterDelegate methods

// Force show notification
- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification
{
    return YES;
}

- (void)userNotificationCenter:(NSUserNotificationCenter *)center didActivateNotification:(NSUserNotification *)notification
{
    // User has clicked on the notification and will open home URL if newer version is available
    if ([[notification informativeText] isEqualToString:NSLocalizedString(@"A newer version is available", @"Update menuitem")])
    {
        [self openHomeUrl:nil];
    }
}

#pragma mark - NSMenuDelegate methods

- (void)menuWillOpen:(NSMenu *)menu
{
    // Show power source data in menu
    if (self.advancedSupported && [[self.statusItem.menu itemWithTag:kBTRMenuSettings].submenu itemWithTag:kBTRMenuAdvanced].state == NSOnState)
    {
        NSDictionary *advancedBatteryInfo = [self getAdvancedBatteryInfo];
        NSDictionary *moreAdvancedBatteryInfo = [self getMoreAdvancedBatteryInfo];
        
        // Unit mAh
        NSNumber *currentBatteryPower = [advancedBatteryInfo objectForKey:@"Current"];
        // Unit mAh
        NSNumber *maxBatteryPower = [advancedBatteryInfo objectForKey:@"Capacity"];
        // Unit mAh
        NSNumber *Amperage = [advancedBatteryInfo objectForKey:@"Amperage"];
        // Unit mV
        NSNumber *Voltage = [advancedBatteryInfo objectForKey:@"Voltage"];
        NSNumber *cycleCount = [advancedBatteryInfo objectForKey:@"Cycle Count"];
        // Unit Wh
        NSNumber *watt =  [NSNumber numberWithDouble:[Amperage doubleValue] / 1000 * [Voltage doubleValue] / 1000];
        // Unit Celsius
        NSNumber *temperature = [NSNumber numberWithDouble:[[moreAdvancedBatteryInfo objectForKey:@"Temperature"] doubleValue] / 100];
        
        [self.statusItem.menu itemWithTag:kBTRMenuPowerSourcePercent].title = [NSString stringWithFormat: NSLocalizedString(@"%ld %% left ( %ld/%ld mAh )", @"Advanced percentage left menuitem"), self.currentPercent, [currentBatteryPower integerValue], [maxBatteryPower integerValue]];
        
        // Each item in array will be a row in menu
        NSArray *advancedBatteryInfoTexts = [NSArray arrayWithObjects:
                                             [NSString stringWithFormat:NSLocalizedString(@"Cycle count: %ld", @"Advanced battery info menuitem"), [cycleCount integerValue]],
                                             [NSString stringWithFormat:NSLocalizedString(@"Power usage: %.2f Watt", @"Advanced battery info menuitem"), [watt doubleValue]],
                                             [NSString stringWithFormat:NSLocalizedString(@"Temperature: %.1f°C", @"Advanced battery info menuitem"), [temperature doubleValue]],
                                              nil];
        
        NSDictionary *advancedAttributedStyle = [NSDictionary dictionaryWithObjectsAndKeys:
                                                 // Font
                                                 [NSFont systemFontOfSize:[NSFont systemFontSize]+1.f],
                                                 NSFontAttributeName,
                                                 // Text color
                                                 [NSColor disabledControlTextColor],
                                                 NSForegroundColorAttributeName,
                                                 nil];
        
        NSAttributedString *advancedAttributedTitle = [[NSAttributedString alloc] initWithString:[advancedBatteryInfoTexts componentsJoinedByString:@"\n"] attributes:advancedAttributedStyle];
        
        [self.statusItem.menu itemWithTag:kBTRMenuPowerSourceAdvanced].attributedTitle = advancedAttributedTitle;
    }
    else
    {
        [self.statusItem.menu itemWithTag:kBTRMenuPowerSourcePercent].title = [NSString stringWithFormat: NSLocalizedString(@"%ld %% left", @"Percentage left menuitem"), self.currentPercent];
    }
    
    // Update menu
    NSMenuItem *updaterMenu = [self.statusItem.menu itemWithTag:kBTRMenuUpdater];
    
    // Stop checking if newer version is available
    if ([updaterMenu isEnabled])
    {
        return;
    }
    
    // Check for newer version
    [[HttpGet new] url:@"https://raw.github.com/codler/Battery-Time-Remaining/master/build_version" success:^(NSString *result) {
        NSInteger latestBuildVersion = [result integerValue];
        NSInteger currentBuildVersion = [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"] integerValue];
        
        // Wrong format build version
        if (!latestBuildVersion)
        {
            updaterMenu.title = NSLocalizedString(@"Could not check for updates", @"Update menuitem");
            return;
        }
        
        // Newer version available
        if (latestBuildVersion > currentBuildVersion)
        {
            updaterMenu.title = NSLocalizedString(@"A newer version is available", @"Update menuitem");
            [updaterMenu setAction:@selector(openHomeUrl:)];
            [updaterMenu setEnabled:YES];
            [self notify:NSLocalizedString(@"A newer version is available", @"Update notification")];
        }
        else
        {
            updaterMenu.title = NSLocalizedString(@"Up to date", @"Update menuitem");
        }
    } error:^(NSError *error) {
        updaterMenu.title = NSLocalizedString(@"Could not check for updates", @"Update menuitem");
    }];
}

@end