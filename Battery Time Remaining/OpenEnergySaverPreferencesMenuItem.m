//
//  OpenEnergySaverPreferences.m
//  Battery Time Remaining
//
//  Created by Oliver Sigge on 09.09.12.
//  Copyright (c) 2012 Pinky Brains. All rights reserved.
//

#import "OpenEnergySaverPreferencesMenuItem.h"

@implementation OpenEnergySaverPreferencesMenuItem

- (id)init{
    self = [super init];
    if (self) {
        self.title = NSLocalizedString(@"Energy Saver Preferences…", @"Open Energy Saver Preferences menuitem");
    }
    return self;
}

- (void)action:(id)sender{
    [[NSWorkspace sharedWorkspace] performSelector:@selector(openFile:) withObject:@"/System/Library/PreferencePanes/EnergySaver.prefPane" afterDelay:0.0];
}


@end
