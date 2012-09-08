//
//  Settings.m
//  Battery Time Remaining
//
//  Created by Oliver Sigge on 06.09.12.
//  Copyright (c) 2012 Pinky Brains. All rights reserved.
//

#import "Settings.h"

@interface Settings()

@property (nonatomic, strong) NSUserDefaults *userDefaults;

@end

@implementation Settings

@synthesize advancedMode, userDefaults;

- (id)init{
    self = [super init];
    if (self){
        userDefaults = [NSUserDefaults standardUserDefaults];
    }
    return self;
}

- (NSCellStateValue)advancedMode{
    return [userDefaults integerForKey:@"advanced"];
}

- (void)setAdvancedMode:(NSCellStateValue)advancedModeState{
    advancedMode = advancedModeState;
    [userDefaults setInteger:advancedModeState forKey:@"advanced"];
    [userDefaults synchronize];
}

@end
