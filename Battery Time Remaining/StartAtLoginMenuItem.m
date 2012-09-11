//
//  StartAtLoginMenuItem.m
//  Battery Time Remaining
//
//  Created by Oliver Sigge on 08.09.12.
//  Copyright (c) 2012 Pinky Brains. All rights reserved.
//

#import "StartAtLoginMenuItem.h"
#import "Settings.h"

@implementation StartAtLoginMenuItem

- (id)init{
    self = [super init];
    if (self) {
        self.state = self.settings.startAtLogin ? NSOnState : NSOffState;
        self.title = NSLocalizedString(@"Start at login", @"Start at login setting");
    }
    return self;
}

- (void)action:(id)sender{
    NSMenuItem *startLoginMenuItem = (NSMenuItem*)sender;
    BOOL startAtLogin = startLoginMenuItem.state == NSOnState ? NSOffState : NSOnState;
    self.settings.startAtLogin = startAtLogin;
    self.state = startAtLogin ? NSOnState : NSOffState;
}

@end
