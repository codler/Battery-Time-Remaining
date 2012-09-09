//
//  StatusItemImage.m
//  Battery Time Remaining
//
//  Created by Oliver Sigge on 08.09.12.
//  Copyright (c) 2012 Pinky Brains. All rights reserved.
//

#import "StatusItemImageProvider.h"
#import "PowerSource.h"
#import <QuartzCore/QuartzCore.h>

@interface StatusItemImageProvider ()

@property(nonatomic, strong) PowerSource *powerSource;

@end

@implementation StatusItemImageProvider

- (id)init{
    @throw @"Use designated initializer with valid PowerSource to generate an image";
}

- (id)initWithPowerSource:(PowerSource*)aPowerSource{
    self = [super init];
    if (self) {
        self.powerSource = aPowerSource;
    }
    return self;
}

- (NSImage*)image{
    if([self.powerSource isCharged]){
        return [self batteryIconWithType:@"Charged"];
    }else if([self.powerSource isCharging]){
        return [self batteryIconWithType:@"Charging"];
    }else{
        NSString *redOrBlackStatus = [self.powerSource lowBatteryWarning] ? @"R" : @"B";
        NSImage *batteryOutline     = [self batteryIconWithType:@"Empty"];
        NSImage *batteryLevelLeft   = [self batteryIconWithType:[NSString stringWithFormat:@"LevelCap%@-L", redOrBlackStatus]];
        NSImage *batteryLevelMiddle = [self batteryIconWithType:[NSString stringWithFormat:@"LevelCap%@-M", redOrBlackStatus]];
        NSImage *batteryLevelRight  = [self batteryIconWithType:[NSString stringWithFormat:@"LevelCap%@-R", redOrBlackStatus]];

        const CGFloat   drawingUnit         = [batteryLevelLeft size].width;
        const CGFloat   capBarLeftOffset    = 3.0f * drawingUnit;
        CGFloat         capBarHeight        = [batteryLevelLeft size].height + 0.0;
        CGFloat         capBarTopOffset     = 3.0f;
        CGFloat         capBarLength        = ceil([self.powerSource.remainingChargeInPercent integerValue] / 8.0f) * drawingUnit;
        if (capBarLength <= (2 * drawingUnit)) {
            capBarLength = (2 * drawingUnit) + 0.1f;
        }

        [batteryOutline lockFocus];
        [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];
        NSDrawThreePartImage(NSMakeRect(capBarLeftOffset, capBarTopOffset, capBarLength, capBarHeight),
                             batteryLevelLeft, batteryLevelMiddle, batteryLevelRight,
                             NO,
                             NSCompositeDestinationOver,
                             0.94f,
                             NO);
        [batteryOutline unlockFocus];
        return batteryOutline;
    }
}

- (NSImage *)batteryIconWithType:(NSString *)type{
    NSString *fileName = [NSString stringWithFormat:@"/System/Library/CoreServices/Menu Extras/Battery.menu/Contents/Resources/Battery%@.pdf", type];
    return [self imageWithOffsetFromImage:[[NSImage alloc] initWithContentsOfFile:fileName]];
}

- (NSImage *)imageWithOffsetFromImage:(NSImage *)image{
    NSImage *newImage = [[NSImage alloc] initWithSize:NSMakeSize(image.size.width, image.size.height + 2.0f)];
    [newImage lockFocus];
    [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];
    [image drawInRect:NSMakeRect(0, 0, image.size.width, image.size.height)
             fromRect:NSMakeRect(0, 0, image.size.width, image.size.height)
            operation:NSCompositeSourceOver
             fraction:1.0];
    [newImage unlockFocus];

    return newImage;
}

@end
