//
//  PowerSourceMock.m
//  Battery Time Remaining
//
//  Created by Oliver Sigge on 08.09.12.
//  Copyright (c) 2012 Pinky Brains. All rights reserved.
//

#import "PowerSourceMock.h"
#import <IOKit/ps/IOPSKeys.h>

@interface PowerSourceMock ()

@property(nonatomic, strong) NSMutableDictionary *powerSourceDescription;

@end

@implementation PowerSourceMock

- (id)init{
    self = [super init];
    if (self) {
        self.powerSourceDescription = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       @"Battery Power", [NSString stringWithUTF8String:kIOPSBatteryPowerValue],
                                       @"Battery Power", [NSString stringWithUTF8String:kIOPSPowerSourceStateKey],
                                       nil];
    }
    return self;
}

- (NSNumber*)timeRemaining{
    return [NSNumber numberWithInt:111];
}

- (id)attributeValueForKey:(char const*)key{
    return [self.powerSourceDescription valueForKey:[NSString stringWithUTF8String:key]];
}

@end
