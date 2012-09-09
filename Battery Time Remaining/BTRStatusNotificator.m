//
//  BTRStatusNotificator.m
//  Battery Time Remaining
//
//  Created by Oliver Sigge on 09.09.12.
//  Copyright (c) 2012 Pinky Brains. All rights reserved.
//

#import "BTRStatusNotificator.h"

@implementation BTRStatusNotificator

+ (BTRStatusNotificator *)sharedNotificator{
    static BTRStatusNotificator *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[BTRStatusNotificator alloc] init];
    });
    return sharedInstance;
}

- (void)notifyWithMessage:(NSString *)message{
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    notification.title = [self appName];
    notification.informativeText = message;
    notification.soundName = NSUserNotificationDefaultSoundName;
    NSUserNotificationCenter *center = [NSUserNotificationCenter defaultUserNotificationCenter];
    [center scheduleNotification:notification];
}

- (NSString*)appName{
    NSBundle* mainBundle = [NSBundle mainBundle];
    return [mainBundle objectForInfoDictionaryKey:@"CFBundleName"];
}

@end
