//
//  StatusItemImageProvider.m
//  Battery Time Remaining
//
//  Created by Oliver Sigge on 09.09.12.
//  Copyright (c) 2012 Pinky Brains. All rights reserved.
//

#import "StatusItemImageProviderTest.h"
#import "StatusItemImageProvider.h"
#import "BatteryPowerSourceMock.h"
#import "ChargedPowerSourceMock.h"
#import "ChargingPowerSourceMock.h"
#import "LowBatteryPowerSourceMock.h"

@interface StatusItemImageProviderTest (){
    
    StatusItemImageProvider *imageProvider;
    
}

@end

@implementation StatusItemImageProviderTest

- (void)testThrowExceptionWhenUsingDefaultInitializer{
    STAssertThrows(imageProvider = [[StatusItemImageProvider alloc] init], @"default initializer should throw exception");
}

- (void)testImageBatteryPower{
    PowerSource *powerSource = [[BatteryPowerSourceMock alloc] init];
    imageProvider = [[StatusItemImageProvider alloc] initWithPowerSource:powerSource];
    STAssertNotNil(imageProvider.image, @"should provide an image");
}

- (void)testImageCharged{
    PowerSource *powerSource = [[ChargedPowerSourceMock alloc] init];
    imageProvider = [[StatusItemImageProvider alloc] initWithPowerSource:powerSource];
    STAssertNotNil(imageProvider.image, @"should provide an image");
}

- (void)testImageCharging{
    PowerSource *powerSource = [[ChargingPowerSourceMock alloc] init];
    imageProvider = [[StatusItemImageProvider alloc] initWithPowerSource:powerSource];
    STAssertNotNil(imageProvider.image, @"should provide an image");
}

- (void)testImageLowBatteryPower{
    PowerSource *powerSource = [[LowBatteryPowerSourceMock alloc] init];
    imageProvider = [[StatusItemImageProvider alloc] initWithPowerSource:powerSource];
    STAssertNotNil(imageProvider.image, @"should provide an image");
}

@end
