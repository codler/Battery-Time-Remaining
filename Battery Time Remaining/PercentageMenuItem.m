//
//  PercentageMenuItem.m
//  Battery Time Remaining
//
//  Created by Oliver Sigge on 08.09.12.
//  Copyright (c) 2012 Pinky Brains. All rights reserved.
//

#import "PercentageMenuItem.h"
#import "Settings.h"

@implementation PercentageMenuItem

- (void)powerStateChanged:(NSNotification*)notification{
    [super powerStateChanged:notification];
    PowerSource *powerSource = (PowerSource*)[notification object];
    NSNumber *chargeInPercent = [powerSource chargeInPercent];
    
    NSString *title = [NSString stringWithFormat:NSLocalizedString(@"%ld %% left", @"Percentage left menuitem"), [chargeInPercent integerValue]];
    Settings *settings = [[Settings alloc] init];
    //if(settings.advancedMode == NSOnState){
        NSNumber *current = (NSNumber*)[powerSource advancedAttributeValueForKey:@"Current"];
        NSNumber *capacity = (NSNumber*)[powerSource advancedAttributeValueForKey:@"Capacity"];
        title = [NSString stringWithFormat:NSLocalizedString(@"%ld %% left ( %ld/%ld mAh )", @"Advanced percentage left menuitem"), [chargeInPercent integerValue], [current integerValue], [capacity integerValue]];
    //}
    self.title = title;
}

@end
