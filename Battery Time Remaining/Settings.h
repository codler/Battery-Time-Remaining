//
//  Settings.h
//  Battery Time Remaining
//
//  Created by Oliver Sigge on 06.09.12.
//  Copyright (c) 2012 Pinky Brains. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Settings : NSObject

@property (nonatomic) BOOL advancedMode;
@property (nonatomic) BOOL startAtLogin;

+ (Settings *)sharedSettings;

- (BOOL)notificationsContainValue:(NSNumber*)value;
- (void)addNotificationValueInPercent:(NSNumber*)value;
- (void)removeNotificationValueInPercent:(NSNumber*)value;

@end
