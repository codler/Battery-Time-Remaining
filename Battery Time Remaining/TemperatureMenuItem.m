//
//  TemperatureMenuItem.m
//  Battery Time Remaining
//
//  Created by Oliver Sigge on 08.09.12.
//  Copyright (c) 2012 Pinky Brains. All rights reserved.
//

#import "TemperatureMenuItem.h"

@implementation TemperatureMenuItem

- (void)powerStateChanged:(NSNotification*)notification{
    [super powerStateChanged:notification];
    PowerSource *powerSource = (PowerSource*)[notification object];
    
    [self setHidden:[powerSource isCalculating] || (!self.settings.advancedMode && ![powerSource isCalculating])];
    
    self.title = [NSString stringWithFormat:NSLocalizedString(@"Temperature: %.1f°C", @"Advanced battery info menuitem"),  [powerSource.temperature doubleValue]];
}

@end
