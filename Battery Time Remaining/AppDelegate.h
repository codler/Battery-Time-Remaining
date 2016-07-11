//
//  AppDelegate.h
//  Battery Time Remaining
//
//  Created by Han Lin Yap on 2012-08-01.
//  Copyright (c) 2013 Han Lin Yap. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#ifndef _BTR_MENU
#define _BTR_MENU

#define kBTRMenuPowerSourcePercent  1
#define kBTRMenuPowerSourceState    2
#define kBTRMenuPowerSourceAdvanced 3
#define kBTRMenuStartAtLogin        4
#define kBTRMenuNotification        5
#define kBTRMenuSetting             6
#define kBTRMenuAdvanced            7
#define kBTRMenuParenthesis         8
#define kBTRMenuFahrenheit          9
#define kBTRMenuPercentage          10
#define kBTRMenuWhiteText           11
#define kBTRMenuHideIcon            12
#define kBTRMenuHideTime            13
#define kBTRMenuEnergySaverSetting  14
#define kBTRMenuUpdater             15
#define kBTRMenuQuitKey             16
#define kBTRMenuLowBatteryDialog    17

#endif

@interface AppDelegate : NSObject <NSApplicationDelegate, NSUserNotificationCenterDelegate, NSMenuDelegate>

- (void)updateStatusItem;
- (NSImage *)getBatteryIconNamed:(NSString *)iconName;
- (NSImage *)getBatteryIconPercent:(NSInteger)percent;

@property (strong) NSStatusItem *statusItem;
@property (nonatomic) NSInteger previousPercent;
@property (nonatomic) NSInteger currentPercent;
@property (strong) NSMutableDictionary *notifications;
@property (nonatomic) bool advancedSupported;

@end
