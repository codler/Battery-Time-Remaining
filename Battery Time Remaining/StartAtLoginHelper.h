//
//  StartAtLoginHelper.h
//  Battery Time Remaining
//
//  Created by Mathijs Kadijk on 04-08-12.
//  Copyright (c) 2012 Wrep. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StartAtLoginHelper : NSObject

+ (BOOL)isInLoginItems;
+ (void)addToLoginItems;
+ (void)removeFromLoginItems;

@end
