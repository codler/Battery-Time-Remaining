//
//  PowerUsageMenuItem.m
//  Battery Time Remaining
//
//  Created by Oliver Sigge on 08.09.12.
//  Copyright (c) 2012 Han Pinky Brains. All rights reserved.
//

#import "PowerUsageMenuItem.h"

@implementation PowerUsageMenuItem

- (void)powerStateChanged:(NSNotification*)notification{
    [super powerStateChanged:notification];
    PowerSource *powerSource = (PowerSource*)[notification object];
    
    [self setHidden:[powerSource isCalculating] || (!self.settings.advancedMode && ![powerSource isCalculating])];
    
    self.title = [NSString stringWithFormat:NSLocalizedString(@"Power usage: %.2f Watt", @"Advanced battery info menuitem"), [powerSource.watt doubleValue]];
}

@end
