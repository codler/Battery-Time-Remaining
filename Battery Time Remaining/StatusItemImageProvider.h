//
//  StatusItemImage.h
//  Battery Time Remaining
//
//  Created by Oliver Sigge on 08.09.12.
//  Copyright (c) 2012 Pinky Brains. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class PowerSource;

@interface StatusItemImageProvider : NSObject

- (id)initWithPowerSource:(PowerSource*)powerSource;
- (NSImage*)image;

@end
