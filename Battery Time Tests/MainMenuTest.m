//
//  MainMenuTest.m
//  Battery Time Remaining
//
//  Created by Oliver Sigge on 08.09.12.
//  Copyright (c) 2012 Pinky Brains. All rights reserved.
//

#import "MainMenuTest.h"
#import "MainMenu.h"
#import "PercentageMenuItem.h"
#import "BTRConstants.h"
#import "PowerSourceMock.h"
#import "PowerSource.h"

@interface MainMenuTest (){
    MainMenu *mainMenu;
}

@end

@implementation MainMenuTest

- (void)setUp{
    mainMenu = [[MainMenu alloc] init];
}

- (void)testMenuItemWithClassNameNotNil{
    NSMenuItem *menuItem = [mainMenu menuItemWithClassName:@"PercentageMenuItem"];
    STAssertTrue([menuItem isKindOfClass:[PercentageMenuItem class]], @"menuItem should not be nil");
}

- (void)testNotificationSent{
    PowerSource *powerSource = [[PowerSourceMock alloc] init];
    NSNotification *notification = [NSNotification notificationWithName:PowerStateChangedNotification object:powerSource];
    NSMenuItem *menuItem = [mainMenu menuItemWithClassName:@"PowerSourceMenuItem"];
    menuItem.title = @"test";
    [[NSNotificationCenter defaultCenter] postNotification:notification];
    STAssertTrue([[mainMenu menuItemWithClassName:@"PowerSourceMenuItem"].title rangeOfString:@"test"].location == NSNotFound, @"PowerSourceMenuItem should have changed its title");
}

@end
