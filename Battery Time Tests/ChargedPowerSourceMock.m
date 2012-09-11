//
//  PowerSourceMock.m
//  Battery Time Remaining
//
//  Created by Oliver Sigge on 08.09.12.
//  Copyright (c) 2012 Pinky Brains. All rights reserved.
//

#import "ChargedPowerSourceMock.h"
#import <IOKit/ps/IOPSKeys.h>

@interface ChargedPowerSourceMock ()

@property(nonatomic, strong) NSMutableDictionary *powerSourceDescription;

@end

@implementation ChargedPowerSourceMock

- (id)init{
    self = [super init];
    if (self) {
        self.powerSourceDescription = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       @"AC Power", [NSString stringWithUTF8String:kIOPSACPowerValue],
                                       @"Battery Power", [NSString stringWithUTF8String:kIOPSPowerSourceStateKey],
                                       nil];
    }
    return self;
}

- (NSNumber*)timeRemaining{
    return [NSNumber numberWithInt:-1];
}

- (id)attributeValueForKey:(char const*)key{
    return [self.powerSourceDescription valueForKey:[NSString stringWithUTF8String:key]];
}

- (NSNumber*)current{
    return [NSNumber numberWithInt:300];
}

- (NSNumber*)capacity{
    return [NSNumber numberWithInt:200];
}

- (NSNumber*)cycleCount{
    return [NSNumber numberWithInt:100];
}

- (NSNumber*)watt{
    return [NSNumber numberWithInt:50];
}

- (NSNumber*)temperature{
    return [NSNumber numberWithInt:30];
}

#pragma mark - Helper methods

- (BOOL)isCharging{
    return NO;
}

- (NSNumber*)timeUntilFullyChargedInMinutes{
    return [NSNumber numberWithInt:-1];
}

- (BOOL)isCharged{
    return YES;
}

- (BOOL)isFinishingCharge{
    return NO;
}

- (BOOL)isCalculating{
    return NO;
}

- (BOOL)lowBatteryWarning{
    return NO;
}

- (NSNumber*)remainingChargeInPercent{
    return [NSNumber numberWithDouble:70];
}

@end
