//
//  BTRStatusNotificator.h
//  Battery Time Remaining
//
//  Created by Oliver Sigge on 09.09.12.
//  Copyright (c) 2012 Pinky Brains. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BTRStatusNotificator : NSObject

+ (BTRStatusNotificator *)sharedNotificator;

- (void)notifyWithMessage:(NSString *)message;

@end
