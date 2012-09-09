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
@synthesize advancedBatteryInfo, powerSourceDescription;
@synthesize remainingHours, remainingMinutes;
@synthesize current, capacity, cycleCount, watt, temperature, remainingChargeInPercent;

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
    }
//    else if([self isCharged]){
//    }else if([self isFinishingCharge]){
//    }   
    return [self timeUntilEmptyInMinutes];
}

- (NSNumber*)current{
    return (NSNumber*)[self advancedAttributeValueForKey:@"Current"];
}

- (NSNumber*)capacity{
    return (NSNumber*)[self advancedAttributeValueForKey:@"Capacity"];
}

- (NSNumber*)cycleCount{
    return (NSNumber*)[self advancedAttributeValueForKey:@"Cycle Count"];
}

- (NSNumber*)watt{
    NSNumber *amperage = [advancedBatteryInfo objectForKey:@"Amperage"];
    NSNumber *voltage = [advancedBatteryInfo objectForKey:@"Voltage"];
    return [NSNumber numberWithDouble:[amperage doubleValue] / 1000 * [voltage doubleValue] / 1000];
}

- (NSNumber*)temperature{
    CFMutableDictionaryRef matching, properties = NULL;
    io_registry_entry_t entry = 0;
    matching = IOServiceNameMatching("AppleSmartBattery");
    entry = IOServiceGetMatchingService(kIOMasterPortDefault, matching);
    IORegistryEntryCreateCFProperties(entry, &properties, NULL, 0);
    NSDictionary *advancedBatteryInformations = (__bridge NSDictionary *)properties;
    return [NSNumber numberWithDouble:[[advancedBatteryInformations objectForKey:@"Temperature"] doubleValue] / 100];
}

- (NSString*)stringWithHumanReadableTimeRemaining{
    if([self isCharged]) return NSLocalizedString(@"Charged", @"Charged notification");
    if([self isCalculating]) return NSLocalizedString(@"Calculating…", @"Calculating sidetext");
    int hours = floor([self.timeRemaining doubleValue]/60.0f);
    int minutes = floor(fmod([self.timeRemaining doubleValue], 60.0f));
    
    remainingHours = [NSNumber numberWithInt:hours];
    remainingMinutes = [NSNumber numberWithInt:minutes];
    
    NSString* humanReadableTime = [[NSString alloc] initWithFormat:@"(%d:%02d)", hours, minutes];
    return humanReadableTime;
}

#pragma mark - Helper methods

- (id)attributeValueForKey:(char const*)key{
    return [self.powerSourceDescription valueForKey:[NSString stringWithUTF8String:key]];
}

- (id)advancedAttributeValueForKey:(NSString*)key{
    return [self.advancedBatteryInfo valueForKey:key];
}

- (NSNumber*)timeUntilFullyChargedInMinutes{
    return (NSNumber*)[self attributeValueForKey:kIOPSTimeToFullChargeKey];
}

- (BOOL)isFinishingCharge{
    return [self attributeValueForKey:kIOPSIsFinishingChargeKey] == @YES;
}

- (NSNumber*)timeUntilEmptyInMinutes{
    return (NSNumber*)[self attributeValueForKey:kIOPSTimeToEmptyKey];
}

- (BOOL)isCharged{
    return [self attributeValueForKey:kIOPSIsChargedKey] == @YES;
}

- (BOOL)isCharging{
    return [self attributeValueForKey:kIOPSIsChargingKey] == @YES;
}

- (BOOL)isCalculating{
    return [self.timeRemaining integerValue] == -1;
}

- (BOOL)lowBatteryWarning{
    return self.remainingChargeInPercent <= [NSNumber numberWithInteger:LowBatteryWarningThreshold];
}

- (BOOL)isOnBatteryPower{
    return [[self attributeValueForKey:kIOPSPowerSourceStateKey] isEqualToString:[NSString stringWithUTF8String:kIOPSBatteryPowerValue]];
}

- (NSNumber*)remainingChargeInPercent{
    NSNumber *currentBatteryCapacity = [self attributeValueForKey:kIOPSCurrentCapacityKey];
    NSNumber *maxBatteryCapacity = [self attributeValueForKey:kIOPSMaxCapacityKey];
    return [NSNumber numberWithDouble:([currentBatteryCapacity doubleValue] / [maxBatteryCapacity doubleValue]) * 100];
}

@end
