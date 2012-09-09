//
//  Settings.m
//  Battery Time Remaining
//
//  Created by Oliver Sigge on 06.09.12.
//  Copyright (c) 2012 Pinky Brains. All rights reserved.
//

#import "Settings.h"
#import "LLManager.h"

@interface Settings()

@property (nonatomic, strong) NSUserDefaults *userDefaults;
@property (nonatomic, strong) NSMutableArray *notificationValues;

@end

@implementation Settings

@synthesize advancedMode, startAtLogin, notificationValues;
@synthesize userDefaults;

+ (Settings *)sharedSettings{
    static Settings *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[Settings alloc] init];
        sharedInstance.userDefaults = [NSUserDefaults standardUserDefaults];
        sharedInstance.notificationValues = [[sharedInstance.userDefaults objectForKey:@"notifications"] mutableCopy];
    });
    return sharedInstance;
}

- (BOOL)advancedMode{
    return [self.userDefaults boolForKey:@"advanced"];
}

- (void)setAdvancedMode:(BOOL)advancedModeState{
    advancedMode = advancedModeState;
    [self.userDefaults setBool:advancedModeState forKey:@"advanced"];
    [self.userDefaults synchronize];
}

- (BOOL)startAtLogin{
    return [LLManager launchAtLogin];
}

- (void)setStartAtLogin:(BOOL)startAtLoginState{
    startAtLogin = startAtLoginState;
    [LLManager setLaunchAtLogin:startAtLoginState];
}

- (BOOL)notificationsContainValue:(NSNumber*)value{
    return [[self.userDefaults valueForKey:@"notifications"] containsObject:value];
}

- (void)addNotificationValueInPercent:(NSNumber*)value{
    [self.notificationValues addObject:value];
    [self.userDefaults setObject:self.notificationValues forKey:@"notifications"];
    [self.userDefaults synchronize];
}

- (void)removeNotificationValueInPercent:(NSNumber*)value{
    [self.notificationValues removeObject:value];
    [self.userDefaults setObject:self.notificationValues forKey:@"notifications"];
    [self.userDefaults synchronize];
}

@end
