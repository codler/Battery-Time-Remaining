//
//  BatteryTimeRemainingViewController.m
//  Battery Time Remaining
//
//  Created by Oliver Sigge on 07.09.12.
//  Copyright (c) 2012 Pinky Brains. All rights reserved.
//

#import "MainMenuViewController.h"
#import "MainMenu.h"
#import "PowerSource.h"
#import <IOKit/ps/IOPowerSources.h>
#import "BTRConstants.h"
#import "StatusItemImageProvider.h"
#import "Settings.h"
#import "BTRStatusNotificator.h"

@interface MainMenuViewController ()

@property(nonatomic, strong) MainMenu *mainMenu;
@property(nonatomic, strong) NSStatusItem *statusItem;
@property(nonatomic, strong) PowerSource *powerSource;

@property(nonatomic, strong) NSTimer *menuUpdateTimer;
@property(nonatomic, strong) Settings *settings;

@property(nonatomic, strong) NSNumber *lastNotifiedPercentage;

@end

@implementation MainMenuViewController

@synthesize mainMenu;
@synthesize statusItem;
@synthesize powerSource;
@synthesize menuUpdateTimer;
@synthesize lastNotifiedPercentage;

static void PowerSourceChanged(void * context){
    MainMenuViewController *object = (__bridge MainMenuViewController *)context;
    [object updateStatusItem];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.lastNotifiedPercentage = [NSNumber numberWithInt:-1];
        self.settings = [Settings sharedSettings];
        self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
        self.mainMenu = [[MainMenu alloc] init];
        
        self.mainMenu.delegate = self;
        
        self.statusItem.menu = self.mainMenu;
        self.statusItem.highlightMode = YES;
    }

    CFRunLoopSourceRef loop = IOPSNotificationCreateRunLoopSource(PowerSourceChanged, (__bridge void *)self);
    CFRunLoopAddSource(CFRunLoopGetCurrent(), loop, kCFRunLoopDefaultMode);
    CFRelease(loop);
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(advancedModeHasChanged:) name:AdvancedModeChangedNotification object:nil];
    
    [self updateStatusItem];
    return self;
}

- (void)updateStatusItem{
    self.powerSource = [[PowerSource alloc] init];
    NSString *humanReadableTime = [self.powerSource stringWithHumanReadableTimeRemaining];
    [self setStatusItemTitle:humanReadableTime];
    
    [self notifyMenuItemsOfPowerStateChange];
    
    [self notifyNotificationCenterWithPowerSource:self.powerSource];
    
    StatusItemImageProvider *statusItemImage = [[StatusItemImageProvider alloc] initWithPowerSource:self.powerSource];
    self.statusItem.image = [statusItemImage image];
}

- (void)setStatusItemTitle:(NSString*)title{
    NSDictionary *statusItemTextStyle = [NSDictionary dictionaryWithObjectsAndKeys:
                                         [NSFont menuFontOfSize:12.0f], NSFontAttributeName,
                                         nil];
    NSAttributedString *titleForStatusItem = [[NSAttributedString alloc] initWithString:title
                                                                             attributes:statusItemTextStyle];
    self.statusItem.attributedTitle = titleForStatusItem;
}

- (void)notifyMenuItemsOfPowerStateChange{
    NSNotification *notification = [NSNotification notificationWithName:PowerStateChangedNotification object:self.powerSource];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

- (void)notifyNotificationCenterWithPowerSource:(PowerSource*)aPowerSource{
    BTRStatusNotificator *notificator = [BTRStatusNotificator sharedNotificator];
    if([self.settings notificationsContainValue:[self.powerSource remainingChargeInPercent]] && [self.powerSource isOnBatteryPower] && [self.lastNotifiedPercentage integerValue] != [self.powerSource.remainingChargeInPercent integerValue]){
        self.lastNotifiedPercentage = self.powerSource.remainingChargeInPercent;
        [notificator notifyWithMessage:[NSString stringWithFormat:NSLocalizedString(@"%1$ld:%2$02ld left (%3$ld%%)", @"Time remaining left notification"), [self.powerSource.remainingHours integerValue], [self.powerSource.remainingMinutes integerValue], [self.powerSource.remainingChargeInPercent integerValue]]];
    }
    if([self.powerSource isCharged]){
        [notificator notifyWithMessage:NSLocalizedString(@"Charged", @"Charged notification")];
    }
}

- (void)advancedModeHasChanged:(NSNotification*)notification{
    [self updateStatusItem];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AdvancedModeChangedNotification object:nil];
}

#pragma mark - Menu delegates

- (void)menuWillOpen:(NSMenu *)menu{
    if([[NSApp currentEvent] modifierFlags] & NSAlternateKeyMask) self.settings.advancedMode = YES;
    [self updateStatusItem];
    
    self.menuUpdateTimer = [NSTimer timerWithTimeInterval:0.5
                                                   target:self
                                                 selector:@selector(updateStatusItem)
                                                 userInfo:nil
                                                  repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.menuUpdateTimer forMode:NSRunLoopCommonModes];
}

- (void)menuDidClose:(NSMenu *)menu{
    self.settings.advancedMode = NO;
    [self updateStatusItem];
    
    [self.menuUpdateTimer invalidate];
    self.menuUpdateTimer = nil;
}

@end
