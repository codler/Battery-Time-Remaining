//
//  AdvancedModeMenuItem.m
//  Battery Time Remaining
//
//  Created by Oliver Sigge on 09.09.12.
//  Copyright (c) 2012 Pinky Brains. All rights reserved.
//

#import "AdvancedModeMenuItem.h"
#import "Settings.h"
#import "BTRConstants.h"

@implementation AdvancedModeMenuItem

@synthesize settings;

- (id)init{
    self = [super init];
    if (self) {
        self.enabled = YES;
        self.state = self.settings.advancedMode;
        self.title = NSLocalizedString(@"Advanced mode", @"Advanced mode setting");
    }
    return self;
}

- (void)action:(id)sender{
    NSMenuItem *advancedModeMenuItem = (NSMenuItem*)sender;
    
    NSCellStateValue advancedMode = advancedModeMenuItem.state ? NSOffState : NSOnState;
    self.settings.advancedMode = advancedMode;
    self.state = advancedMode ? NSOnState : NSOffState;
    
    NSNotification *advancedModeChangedNotification = [NSNotification notificationWithName:AdvancedModeChangedNotification object:nil userInfo:[NSDictionary dictionaryWithObject:self.settings forKey:@"settings"]];
    [[NSNotificationCenter defaultCenter] postNotification:advancedModeChangedNotification];
}

@end
