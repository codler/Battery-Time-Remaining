//
//  MainMenuItems.h
//  Battery Time Remaining
//
//  Created by Oliver Sigge on 08.09.12.
//  Copyright (c) 2012 Pinky Brains. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <IOKit/ps/IOPSKeys.h>
#import "PowerSource.h"

@interface MainMenuItems : NSMenuItem

- (void)powerStateChanged:(NSNotification*)notification;

@end
