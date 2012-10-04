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
#define kBTRMenuPowerSourceAdvanced 3
#define kBTRMenuStartAtLogin        4
#define kBTRMenuNotification        5
#define kBTRMenuSetting             6
#define kBTRMenuAdvanced            7
#define kBTRMenuParenthesis         8
#define kBTRMenuBattery             9
#define kBTRMenuEnergySaverSetting  10
#define kBTRMenuUpdater             11
#define kBTRMenuQuitKey             12

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
