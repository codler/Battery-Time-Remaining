//
//  AppDelegate.m
//  Battery Time Remaining
//
//  Created by Han Lin Yap on 2012-08-01.
//  Copyright (c) 2012 Han Lin Yap. All rights reserved.
//

#import "AppDelegate.h"
#import "Settings.h"
#import "MainMenuViewController.h"

@interface AppDelegate ()

@property (nonatomic, strong) MainMenuViewController *batteryTimeRemainingViewController;

@end

@implementation AppDelegate

@synthesize batteryTimeRemainingViewController;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification{
    self.batteryTimeRemainingViewController = [[MainMenuViewController alloc] init];
}

@end