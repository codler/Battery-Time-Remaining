//
//  PowerSource.h
//  Battery Time Remaining
//
//  Created by Oliver Sigge on 08.09.12.
//  Copyright (c) 2012 Pinky Brains. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <IOKit/ps/IOPSKeys.h>

@interface PowerSource : NSObject

- (NSString*)stringWithHumanReadableTimeRemaining;
- (id)advancedAttributeValueForKey:(NSString*)key;
- (id)attributeValueForKey:(char const*)key;

- (BOOL)lowBattery;
- (NSNumber*)chargeInPercent;
- (BOOL)isCharged;
- (BOOL)isCharging;

@end
