//
//  PowerSourceMenuItem.m
//  Battery Time Remaining
//
//  Created by Oliver Sigge on 08.09.12.
//  Copyright (c) 2012 Pinky Brains. All rights reserved.
//

#import "PowerSourceMenuItem.h"

@implementation PowerSourceMenuItem

- (void)powerStateChanged:(NSNotification*)notification{
    [super powerStateChanged:notification];
    PowerSource *powerSource = (PowerSource*)[notification object];
    NSString *powerSourceStateKey = [powerSource attributeValueForKey:kIOPSPowerSourceStateKey];
    
    self.title = [self powerSourceOfState:powerSourceStateKey];
}

- (NSString*)powerSourceOfState:(NSString*)state{
    if([state isEqualToString:[NSString stringWithUTF8String:kIOPSBatteryPowerValue]]){
        return [NSString stringWithFormat:NSLocalizedString(@"Power source: %@", @"Powersource item"), NSLocalizedString(@"Battery Power", @"Powersource state")];
    }else if([state isEqualToString:[NSString stringWithUTF8String:kIOPSACPowerValue]]){
        return [NSString stringWithFormat:NSLocalizedString(@"Power source: %@", @"Powersource item"), NSLocalizedString(@"AC Power", @"Powersource state")];
    }else if([state isEqualToString:[NSString stringWithUTF8String:kIOPSOffLineValue]]){
        return [NSString stringWithFormat:NSLocalizedString(@"Power source: %@", @"Powersource item"), NSLocalizedString(@"Off Line", @"Powersource state")];
    }else{
        return @"";
    }
}

@end
