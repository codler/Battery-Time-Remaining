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

+ (NSImage *)invertColor:(NSImage *)_image
{
    NSImage *image = [_image copy];
    [image lockFocus];
    
    CIImage *ciImage = [[CIImage alloc] initWithData:[image TIFFRepresentation]];
    CIFilter *filter = [CIFilter filterWithName:@"CIColorInvert"];
    [filter setDefaults];
    [filter setValue:ciImage forKey:@"inputImage"];
    CIImage *output = [filter valueForKey:@"outputImage"];
    [output drawInRect:NSMakeRect(0, 0, [_image size].width, [_image size].height) fromRect:NSRectFromCGRect([output extent]) operation:NSCompositeSourceOver fraction:1.0];
    
    [image unlockFocus];
    
    return image;
}

@end
