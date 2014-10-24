//
//  ImageFilter.m
//  Battery Time Remaining
//
//  Created by Han Lin Yap on 2012-10-08.
//  Copyright (c) 2013 Han Lin Yap. All rights reserved.
//

#import "ImageFilter.h"
#import <QuartzCore/QuartzCore.h>

@implementation ImageFilter

+ (NSImage *)offset:(NSImage *)_image top:(CGFloat)top
{
    NSImage *newImage = [[NSImage alloc] initWithSize:NSMakeSize(_image.size.width, _image.size.height + top)];
    [newImage lockFocus];
    
    [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];
    [_image drawInRect:NSMakeRect(0, 0, _image.size.width, _image.size.height)
              fromRect:NSMakeRect(0, 0, _image.size.width, _image.size.height)
             operation:NSCompositeSourceOver
              fraction:1.0];
    
    [newImage unlockFocus];
    
    return newImage;
}

@end
