//
//  SettingsTest.m
//  Battery Time Remaining
//
//  Created by Oliver Sigge on 06.09.12.
//  Copyright (c) 2012 Pinky Brains. All rights reserved.
//

#import "SettingsTest.h"
#import "Settings.h"

@interface SettingsTest (){
    
    Settings *settings;
    
}

@end

@implementation SettingsTest

- (void)setUp{
    settings = [Settings sharedSettings];
}

- (void)testAdvancedMode{
    settings.advancedMode = YES;
    Settings *newSettings = [Settings sharedSettings];
    STAssertTrue(newSettings.advancedMode == YES, @"Advanced mode should be set");
}

- (void)testAddNotificationValue{
    [settings addNotificationValueInPercent:[NSNumber numberWithInteger:5]];
    STAssertTrue([settings notificationsContainValue:[NSNumber numberWithInteger:5]], @"notifications should contain nsnumber with value 5");
}


- (void)testRemoveNotificationValue{
    [settings addNotificationValueInPercent:[NSNumber numberWithInteger:5]];
    [settings removeNotificationValueInPercent:[NSNumber numberWithInteger:5]];
    STAssertFalse([settings notificationsContainValue:[NSNumber numberWithInteger:5]], @"notifications should not contain nsnumber with value 5");
}
@end
