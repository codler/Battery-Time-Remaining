//
//  MainMenuItems.m
//  Battery Time Remaining
//
//  Created by Oliver Sigge on 08.09.12.
//  Copyright (c) 2012 Pinky Brains. All rights reserved.
//

#import "MainMenuItems.h"
#import "PowerSource.h"
#import "BTRConstants.h"

@implementation MainMenuItems

- (id)init{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(powerStateChanged:)
                                                     name:PowerStateChangedNotification
                                                   object:nil];
    }
    return self;
}

- (void)powerStateChanged:(NSNotification*)notification{
    if(![notification isKindOfClass:[PowerSource class]]) return;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:PowerStateChangedNotification
                                                  object:nil];
}

@end
