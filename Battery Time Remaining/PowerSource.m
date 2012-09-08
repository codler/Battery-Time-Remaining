//
//  PowerSource.m
//  Battery Time Remaining
//
//  Created by Oliver Sigge on 08.09.12.
//  Copyright (c) 2012 Pinky Brains. All rights reserved.
//

#import "PowerSource.h"
#import <IOKit/ps/IOPowerSources.h>
#import <IOKit/pwr_mgt/IOPM.h>
#import <IOKit/pwr_mgt/IOPMLib.h>
#import "BTRConstants.h"

@interface PowerSource ()

@property (nonatomic, readonly, strong) NSNumber* timeRemaining;
@property (nonatomic, strong) NSDictionary *powerSourceDescription;
@property (nonatomic, strong) NSDictionary *advancedBatteryInfo;

@end

@implementation PowerSource

@synthesize timeRemaining;

- (id)init{
    self = [super init];
    if (self) {
        CFTypeRef powerSourcesInfo = IOPSCopyPowerSourcesInfo();
        NSArray *powerSourcesList = (__bridge NSArray*)IOPSCopyPowerSourcesList(powerSourcesInfo);
        
        for (id powerSource in powerSourcesList) {
            self.powerSourceDescription = (__bridge NSDictionary*)IOPSGetPowerSourceDescription(powerSourcesInfo, (__bridge CFTypeRef)(powerSource));
            if (![self.powerSourceDescription valueForKey:[NSString stringWithUTF8String:kIOPSIsPresentKey]]){
                continue;
            }
            
            mach_port_t masterPort;
            CFArrayRef batteryInfo;

            if (kIOReturnSuccess == IOMasterPort(MACH_PORT_NULL, &masterPort) &&
                kIOReturnSuccess == IOPMCopyBatteryInfo(masterPort, &batteryInfo)){
                self.advancedBatteryInfo = [(__bridge NSArray*)batteryInfo objectAtIndex:0];
            }
        }
    }
    return self;
}

- (NSNumber*)timeRemaining{
    if ([self isCharging]){
        return [self timeUntilFullyChargedInMinutes];
    }else if([self isCharged]){
        //TODO Message "charged"
    }else if([self isFinishingCharge]){
        //TODO Message "finishing"
    }   
    return [self timeUntilEmptyInMinutes];

}

- (NSString*)stringWithHumanReadableTimeRemaining{
    if([self isCalculating]) return NSLocalizedString(@"Calculating…", @"Calculating sidetext");
    int hours = floor([self.timeRemaining doubleValue]/60.0f);
    int minutes = floor(fmod([self.timeRemaining doubleValue], 60.0f));
    
    NSString* humanReadableTime = [[NSString alloc] initWithFormat:@"(%d:%02d)", hours, minutes];
    return humanReadableTime;
}

- (id)attributeValueForKey:(char const*)key{
    return [self.powerSourceDescription valueForKey:[NSString stringWithUTF8String:key]];
}

- (id)advancedAttributeValueForKey:(NSString*)key{
    return [self.advancedBatteryInfo valueForKey:key];
}

- (BOOL)isCharging{
    return [self attributeValueForKey:kIOPSIsChargingKey] == @YES;
}

- (NSNumber*)timeUntilFullyChargedInMinutes{
    return (NSNumber*)[self attributeValueForKey:kIOPSTimeToFullChargeKey];
}

- (BOOL)isCharged{
    return [self attributeValueForKey:kIOPSIsChargedKey] == @YES;
}

- (BOOL)isFinishingCharge{
    return [self attributeValueForKey:kIOPSIsFinishingChargeKey] == @YES;
}

- (NSNumber*)timeUntilEmptyInMinutes{
    return (NSNumber*)[self attributeValueForKey:kIOPSTimeToEmptyKey];
}

- (BOOL)isCalculating{
    return [self.timeRemaining integerValue] == -1;
}

- (BOOL)lowBattery{
    return [NSNumber numberWithInteger:LowBatteryWarningThreshold] == [self chargeInPercent];
}

- (NSNumber*)chargeInPercent{
    NSNumber *currentBatteryCapacity = [self attributeValueForKey:kIOPSCurrentCapacityKey];
    NSNumber *maxBatteryCapacity = [self attributeValueForKey:kIOPSMaxCapacityKey];
    return [NSNumber numberWithDouble:([currentBatteryCapacity doubleValue] / [maxBatteryCapacity doubleValue]) * 100];
}

@end
