//
//  MainMenu.m
//  Battery Time Remaining
//
//  Created by Oliver Sigge on 08.09.12.
//  Copyright (c) 2012 Pinky Brains. All rights reserved.
//

#import "MainMenu.h"

@interface MainMenu ()

@property (nonatomic, strong) NSMutableDictionary *menuItems;

@end

@implementation MainMenu

@synthesize menuItems;

- (id)init{
    self = [super init];
    if (self) {
        self.menuItems = [NSMutableDictionary dictionaryWithCapacity:14];
        
        [self addItem:[self menuItemWithClassName:@"PercentageMenuItem"]];
        [self addItem:[self menuItemWithClassName:@"PowerSourceMenuItem"]];
        [self addItem:[self menuItemWithClassName:@"LoadCyclesMenuItem"]];
        [self addItem:[self menuItemWithClassName:@"PowerUsageMenuItem"]];
        [self addItem:[self menuItemWithClassName:@"TemperatureMenuItem"]];
        [self addItem:[NSMenuItem separatorItem]];
        [self addItem:[self menuItemWithClassName:@"StartAtLoginMenuItem"]];

        NSMenuItem *notificationsMenuItem = [self menuItemWithClassName:@"NotificationsMenuItem"];
        [self addItem:notificationsMenuItem];
        NSMenu *notificationMenu = [[NSMenu alloc] initWithTitle:@"NotificationMenu"];
        [self setSubmenu:notificationMenu forItem:notificationsMenuItem];

    }
    return self;
}

- (NSMenuItem*)menuItemWithClassName:(NSString*)className{
    NSMenuItem *menuItem = [self.menuItems valueForKey:className];
    if(menuItem != nil) return menuItem;
    
    Class menuItemClass = NSClassFromString(className);
    menuItem = [[menuItemClass alloc] init];
    menuItem.title = NSLocalizedString(className, className);
    if([menuItem respondsToSelector:@selector(action:)]){
        menuItem.target = menuItem;
        menuItem.action = @selector(action:);
    }
    [self.menuItems setValue:menuItem forKey:className];
    return menuItem;
}



@end
