//
//  StartAtLoginMenuItem.m
//  Battery Time Remaining
//
//  Created by Oliver Sigge on 08.09.12.
//  Copyright (c) 2012 Pinky Brains. All rights reserved.
//

#import "StartAtLoginMenuItem.h"
#import "LLManager.h"

@implementation StartAtLoginMenuItem

- (id)init{
    self = [super init];
    if (self) {
        self.enabled = YES;
        self.state = ([LLManager launchAtLogin]) ? NSOnState : NSOffState;
    }
    return self;
}

- (void)action:(id)sender{
    BOOL launchAtLogin = [LLManager launchAtLogin];
    [LLManager setLaunchAtLogin:!launchAtLogin];
    self.state = !launchAtLogin ? NSOnState : NSOffState;
}

@end
