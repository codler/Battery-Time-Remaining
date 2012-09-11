//
//  NotificationsMenuItem.m
//  Battery Time Remaining
//
//  Created by Oliver Sigge on 08.09.12.
//  Copyright (c) 2012 Pinky Brains. All rights reserved.
//

#import "NotificationsMenuItem.h"
#import "Settings.h"

@interface NotificationsMenuItem ()

@property(nonatomic, strong) Settings *settings;

@end

@implementation NotificationsMenuItem

- (id)init{
    self = [super init];
    if (self) {
        self.title = NSLocalizedString(@"Notifications", @"Notification menuitem");
        
        NSMenu *notificationMenu = [[NSMenu alloc] initWithTitle:@"NotificationMenu"];
        [notificationMenu setSubmenu:notificationMenu forItem:self];
        
        for (int index = 5; index <= 95; index = index + 5){
            BOOL state = [self.settings notificationsContainValue:[NSNumber numberWithInt:index]];

            NSMenuItem *notificationSubmenuItem = [[NSMenuItem alloc] init];
            notificationSubmenuItem.title = [NSString stringWithFormat:@"%d%%", index];
            notificationSubmenuItem.action = @selector(toggleNotificationForMenuItem:);
            notificationSubmenuItem.target = self;
            notificationSubmenuItem.tag = index;
            notificationSubmenuItem.state = (state) ? NSOnState : NSOffState;
            [notificationMenu addItem:notificationSubmenuItem];
        }
    }
    return self;
}

- (void)toggleNotificationForMenuItem:(id)sender{
    NSMenuItem *menuItem = (NSMenuItem*)sender;
    NSCellStateValue currentState = menuItem.state;
    if(currentState == NSOnState){
        [self.settings removeNotificationValueInPercent:[NSNumber numberWithInteger:menuItem.tag]];
    }else{
        [self.settings addNotificationValueInPercent:[NSNumber numberWithInteger:menuItem.tag]];
    }
    menuItem.state = currentState == NSOnState ? NSOffState : NSOnState;
}

@end
