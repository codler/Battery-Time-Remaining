//
//  SettingsTest.m
//  Battery Time Remaining
//
//  Created by Oliver Sigge on 06.09.12.
//  Copyright (c) 2012 Pinky Brains. All rights reserved.
//

#import "SettingsTest.h"
#import "Settings.h"

@implementation SettingsTest

- (void)setUp{
    
}

- (void)testAdvancedMode{
    Settings *settings = [[Settings alloc] init];
    settings.advancedMode = NSOnState;
    Settings *newSettings = [[Settings alloc] init];
    STAssertTrue(newSettings.advancedMode == NSOnState, @"Advanced mode should be set");
}

@end
