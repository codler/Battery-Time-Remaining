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

+ (NSImage *)blackWhite:(NSImage *)_image
{
    NSImage *image = [_image copy];
    [image lockFocus];
    
    // http://stackoverflow.com/a/10033772/304894
    CIImage *beginImage = [[CIImage alloc] initWithData:[image TIFFRepresentation]];
    CIImage *blackAndWhite = [[CIFilter filterWithName:@"CIColorControls" keysAndValues:kCIInputImageKey, beginImage, @"inputBrightness", [NSNumber numberWithFloat:0.0], @"inputContrast", [NSNumber numberWithFloat:1.1], @"inputSaturation", [NSNumber numberWithFloat:0.0], nil] valueForKey:@"outputImage"];
    CIImage *output = [[CIFilter filterWithName:@"CIExposureAdjust" keysAndValues:kCIInputImageKey, blackAndWhite, @"inputEV", [NSNumber numberWithFloat:0.7], nil] valueForKey:@"outputImage"];
    [output drawInRect:NSMakeRect(0, 0, [_image size].width, [_image size].height) fromRect:NSRectFromCGRect([output extent]) operation:NSCompositeSourceOver fraction:1.0];
    
    [image unlockFocus];
    
    return image;
}

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
