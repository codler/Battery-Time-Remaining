//
//  QuitMenuItems.m
//  Battery Time Remaining
//
//  Created by Oliver Sigge on 09.09.12.
//  Copyright (c) 2012 Pinky Brains. All rights reserved.
//

#import "QuitMenuItem.h"

@implementation QuitMenuItem

- (id)init{
    self = [super init];
    if (self) {
        self.title = NSLocalizedString(@"Quit", @"Quit menuitem");
    }
    return self;
}

- (void)action:(id)sender{
    [[NSApplication sharedApplication] performSelector:@selector(terminate:) withObject:self afterDelay:0.0];
}

@end
