//
//  AppDelegate.h
//  Battery Time Remaining
//
//  Created by Han Lin Yap on 2012-08-01.
//  Copyright (c) 2012 Han Lin Yap. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#ifndef _BTR_MENU
#define _BTR_MENU

#define kBTRMenuPowerSourcePercent  1
#define kBTRMenuPowerSourceState    2
#define kBTRMenuStartAtLogin        3
#define kBTRMenuNotification        4
#define kBTRMenuAdvancedMode        5
#define kBTRMenuEnergySaverSetting  6
#define kBTRMenuUpdater             7
#define kBTRMenuQuitKey             8

#endif

@interface AppDelegate : NSObject <NSApplicationDelegate, NSUserNotificationCenterDelegate, NSMenuDelegate>

- (void)updateStatusItem;
- (NSImage *)getBatteryIconNamed:(NSString *)iconName;
- (NSImage *)getBatteryIconPercent:(NSInteger)percent;

@property (strong) NSStatusItem *statusItem;
@property (nonatomic) NSInteger previousPercent;
@property (strong) NSMutableDictionary *notifications;

@end
