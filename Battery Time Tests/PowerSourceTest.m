//
//  PowerSourceTest.m
//  Battery Time Remaining
//
//  Created by Oliver Sigge on 08.09.12.
//  Copyright (c) 2012 Pinky Brains. All rights reserved.
//

#import "PowerSourceTest.h"
#import "ChargingPowerSourceMock.h"
#import "ChargedPowerSourceMock.h"
#import "BatteryPowerSourceMock.h"

@implementation PowerSourceTest

- (void)testHumanReadableTimeRemaining{
    PowerSource *powerSource = [[ChargingPowerSourceMock alloc] init];
    NSString *humanReadableTimeRemaining = [powerSource stringWithHumanReadableTimeRemaining];
    STAssertNotNil([powerSource stringWithHumanReadableTimeRemaining], @"human reeadable time remaining should not be null");
    STAssertTrue([humanReadableTimeRemaining rangeOfString:@":"].location != NSNotFound, @"human readable time should provide a colon");
    STAssertTrue([humanReadableTimeRemaining length] >= 4, @"human readable time should at least have 4 symbols");
}

- (void)testAttributeValueForKey{
    PowerSource *powerSource = [[BatteryPowerSourceMock alloc] init];
    NSString *batteryPowerValue = [powerSource attributeValueForKey:kIOPSBatteryPowerValue];
    STAssertEquals(batteryPowerValue, @"Battery Power", @"battery power value should have correct value");
}

@end
