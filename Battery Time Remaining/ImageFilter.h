//
//  ImageFilter.h
//  Battery Time Remaining
//
//  Created by Han Lin Yap on 2012-10-08.
//  Copyright (c) 2013 Han Lin Yap. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageFilter : NSObject

+ (NSImage *)offset:(NSImage *)_image top:(CGFloat)top;

@end
