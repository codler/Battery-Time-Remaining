//
//  BatteryTimeRemainingViewController.m
//  Battery Time Remaining
//
//  Created by Oliver Sigge on 07.09.12.
//  Copyright (c) 2012 Pinky Brains. All rights reserved.
//

#import "MainMenuViewController.h"
#import "MainMenu.h"
#import "PowerSource.h"
#import <IOKit/ps/IOPowerSources.h>
#import <IOKit/ps/IOPSKeys.h>
#import <IOKit/pwr_mgt/IOPM.h>
#import <IOKit/pwr_mgt/IOPMLib.h>
#import "BTRConstants.h"
#import "StatusItemImageProvider.h"

@interface MainMenuViewController ()

@property(nonatomic, strong) NSMenu *mainMenu;
@property(nonatomic, strong) NSStatusItem *statusItem;
@property(nonatomic, strong) PowerSource *powerSource;

@end

@implementation MainMenuViewController

@synthesize mainMenu;
@synthesize statusItem;
@synthesize powerSource;

static void PowerSourceChanged(void * context){
    MainMenuViewController *object = (__bridge MainMenuViewController *)context;
    [object updateStatusItem];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
        self.mainMenu = [[MainMenu alloc] init];
        self.statusItem.menu = self.mainMenu;
        self.statusItem.highlightMode = YES;
    }

    CFRunLoopSourceRef loop = IOPSNotificationCreateRunLoopSource(PowerSourceChanged, (__bridge void *)self);
    CFRunLoopAddSource(CFRunLoopGetCurrent(), loop, kCFRunLoopDefaultMode);
    CFRelease(loop);
    
    [self updateStatusItem];
    return self;
}

- (void)updateStatusItem{
    self.powerSource = [[PowerSource alloc] init];
    NSString *humanReadableTime = [self.powerSource stringWithHumanReadableTimeRemaining];
    [self setStatusItemTitle:humanReadableTime];
    
    [self notifyMenuItemsOfPowerStateChange];
    
    StatusItemImageProvider *statusItemImage = [[StatusItemImageProvider alloc] initWithPowerSource:self.powerSource];
    self.statusItem.image = [statusItemImage image];

    // Get the estimated time remaining
//    CFTimeInterval timeRemaining = IOPSGetTimeRemainingEstimate();
//
//    // Get list of power sources
//    CFTypeRef psBlob = IOPSCopyPowerSourcesInfo();
//    NSArray *powerSourcesList = (__bridge NSArray*)IOPSCopyPowerSourcesList(psBlob);
//
//    for (id powerSource in powerSourcesList) {
//        NSDictionary *powerSourceDescription = (__bridge NSDictionary*)IOPSGetPowerSourceDescription(psBlob, (__bridge CFTypeRef)(powerSource));
//        if (![powerSourceDescription valueForKey:[NSString stringWithUTF8String:kIOPSIsPresentKey]]){
//            continue;
//        }
//        
//        
//    }
    
//    for (CFIndex i = 0; i < count; i++)    {
//        CFTypeRef powersource = CFArrayGetValueAtIndex(psList, i);
//        CFDictionaryRef description = IOPSGetPowerSourceDescription(psBlob, powersource);
//
//        // Skip if not present
//        if (CFDictionaryGetValue(description, CFSTR(kIOPSIsPresentKey)) == kCFBooleanFalse)
//        {
//            continue;
//        }
//
//        // Calculate the percent
//        NSNumber *currentBatteryCapacity = CFDictionaryGetValue(description, CFSTR(kIOPSCurrentCapacityKey));
//        NSNumber *maxBatteryCapacity = CFDictionaryGetValue(description, CFSTR(kIOPSMaxCapacityKey));
//
//        self.currentPercent = (int)[currentBatteryCapacity doubleValue] / [maxBatteryCapacity doubleValue] * 100;
//
//        NSString *psState = CFDictionaryGetValue(description, CFSTR(kIOPSPowerSourceStateKey));
//
//        psState =   ([psState isEqualToString:(NSString *)CFSTR(kIOPSBatteryPowerValue)]) ?
//                        NSLocalizedString(@"Battery Power", @"Powersource state") :
//                    ([psState isEqualToString:(NSString *)CFSTR(kIOPSACPowerValue)]) ?
//                        NSLocalizedString(@"AC Power", @"Powersource state") :
//                        NSLocalizedString(@"Off Line", @"Powersource state");
//
////        [self.statusItem.menu itemWithTag:kBTRMenuPowerSourceState].title = [NSString stringWithFormat:NSLocalizedString(@"Power source: %@", @"Powersource menuitem"), psState];
//
//        // We're connected to an unlimited power source (AC adapter probably)
//        if (kIOPSTimeRemainingUnlimited == timeRemaining)
//        {
//            // Check if the battery is charging atm
//            if (CFDictionaryGetValue(description, CFSTR(kIOPSIsChargingKey)) == kCFBooleanTrue)
//            {
//                CFNumberRef timeToChargeNum = CFDictionaryGetValue(description, CFSTR(kIOPSTimeToFullChargeKey));
//                int timeTilCharged = [(__bridge NSNumber *)timeToChargeNum intValue];
//
//                if (timeTilCharged > 0)
//                {
//                    // Calculate the hour/minutes
//                    NSInteger hour = timeTilCharged / 60;
//                    NSInteger minute = timeTilCharged % 60;
//
//                    NSString *title = (showParenthesis) ? @" (%ld:%02ld)" : @" %ld:%02ld";
//
//                    // Return the time remaining string
//                    [self setStatusBarImage:[self getBatteryIconNamed:@"BatteryCharging"] title:[NSString stringWithFormat:title, hour, minute]];
//                }
//                else
//                {
//                    [self setStatusBarImage:[self getBatteryIconNamed:@"BatteryCharging"] title:[NSString stringWithFormat:@" %@", NSLocalizedString(@"Calculating…", @"Calculating sidetext")]];
//                }
//            }
//            else
//            {
//                // Not charging and on a endless powersource
//                [self setStatusBarImage:[self getBatteryIconNamed:@"BatteryCharged"] title:@""];
//
//                NSNumber *currentBatteryCapacity = CFDictionaryGetValue(description, CFSTR(kIOPSCurrentCapacityKey));
//                NSNumber *maxBatteryCapacity = CFDictionaryGetValue(description, CFSTR(kIOPSMaxCapacityKey));
//
//                // Notify user when battery is charged
//                if ([currentBatteryCapacity intValue] == [maxBatteryCapacity intValue] &&
//                    self.previousPercent != self.currentPercent &&
//                    [[self.notifications valueForKey:@"100"] boolValue])
//                {
//
//                    [self notify:NSLocalizedString(@"Charged", @"Charged notification")];
//                    self.previousPercent = self.currentPercent;
//                }
//            }
//
//        }
//        // Still calculating the estimated time remaining...
//        else if (kIOPSTimeRemainingUnknown == timeRemaining)
//        {
//            [self setStatusBarImage:[self getBatteryIconPercent:self.currentPercent] title:[NSString stringWithFormat:@" %@", NSLocalizedString(@"Calculating…", @"Calculating sidetext")]];
//        }
//        // Time is known!
//        else
//        {
//            // Calculate the hour/minutes
//            NSInteger hour = (int)timeRemaining / 3600;
//            NSInteger minute = (int)timeRemaining % 3600 / 60;
//
//            NSString *title = (showParenthesis) ? @" (%ld:%02ld)" : @" %ld:%02ld";
//
//            // Return the time remaining string
//           [self setStatusBarImage:[self getBatteryIconPercent:self.currentPercent] title:[NSString stringWithFormat:title, hour, minute]];
//
//            for (NSString *key in self.notifications)
//            {
//                if ([[self.notifications valueForKey:key] boolValue] && [key intValue] == self.currentPercent)
//                {
//                    // Send notification once
//                    if (self.previousPercent != self.currentPercent)
//                    {
//                        [self notify:NSLocalizedString(@"Battery Time Remaining", "Battery Time Remaining notification") message:[NSString stringWithFormat:NSLocalizedString(@"%1$ld:%2$02ld left (%3$ld%%)", @"Time remaining left notification"), hour, minute, self.currentPercent]];
//                    }
//                    break;
//                }
//            }
//            self.previousPercent = self.currentPercent;
//        }
//
//    }
//
//    CFRelease(psList);
//    CFRelease(psBlob);
}

- (void)setStatusItemTitle:(NSString*)title{
    NSDictionary *statusItemTextStyle = [NSDictionary dictionaryWithObject:[NSFont menuFontOfSize:12.0f] forKey:NSFontAttributeName];
    NSAttributedString *titleForStatusItem = [[NSAttributedString alloc] initWithString:title
                                                                             attributes:statusItemTextStyle];
    self.statusItem.attributedTitle = titleForStatusItem;
}

- (void)notifyMenuItemsOfPowerStateChange{
    NSNotification *notification = [NSNotification notificationWithName:PowerStateChangedNotification object:self.powerSource];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

@end
