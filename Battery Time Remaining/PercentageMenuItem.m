//
//  PercentageMenuItem.m
//  Battery Time Remaining
//
//  Created by Oliver Sigge on 08.09.12.
//  Copyright (c) 2012 Pinky Brains. All rights reserved.
//

#import "PercentageMenuItem.h"

@implementation PercentageMenuItem

- (void)powerStateChanged:(NSNotification*)notification{
    [super powerStateChanged:notification];
    PowerSource *powerSource = (PowerSource*)[notification object];
    NSNumber *chargeInPercent = powerSource.remainingChargeInPercent;
    
    NSString *title = [NSString stringWithFormat:NSLocalizedString(@"%ld %% left", @"Percentage left menuitem"), [chargeInPercent integerValue]];
    if(self.settings.advancedMode){
        NSNumber *current = powerSource.current;
        NSNumber *capacity = powerSource.capacity;
        title = [NSString stringWithFormat:NSLocalizedString(@"%ld %% left ( %ld/%ld mAh )", @"Advanced percentage left menuitem"), [chargeInPercent integerValue], [current integerValue], [capacity integerValue]];
    }
    self.title = title;
}

@end
