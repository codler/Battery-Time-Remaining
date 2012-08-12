//
//  HttpGet.h
//  Battery Time Remaining
//
//  Created by Han Lin Yap on 2012-08-12.
//  Copyright (c) 2012 Han Lin Yap. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HttpGet : NSObject <NSURLConnectionDataDelegate, NSURLConnectionDelegate>

+ (HttpGet *)sharedHttpGet;
- (void)url:(NSString *)url success:(void(^)(NSString *result))successBlock;
- (void)url:(NSString *)url success:(void(^)(NSString *result))successBlock error:(void(^)(NSError *error))errorBlock;

@end
