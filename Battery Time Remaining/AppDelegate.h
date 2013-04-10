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
#define kBTRMenuEnergySaverSetting  9
#define kBTRMenuUpdater             10
#define kBTRMenuQuitKey             11
#define kBTRMenuFahrenheit           12

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
