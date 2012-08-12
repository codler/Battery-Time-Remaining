//
//  AppDelegate.h
//  Battery Time Remaining
//
//  Created by Han Lin Yap on 2012-08-01.
//  Copyright (c) 2012 Han Lin Yap. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate, NSUserNotificationCenterDelegate, NSMenuDelegate>

- (void)updateStatusItem;
- (NSImage *)getBatteryIconNamed:(NSString *)iconName;

@property (strong) NSStatusItem *statusItem;
@property (strong) NSMenuItem *startupToggle;
@property (strong) NSMenuItem *updaterMenu;
@property (nonatomic) NSInteger previousPercent;
@property (strong) NSMutableDictionary *notifications;

@end
