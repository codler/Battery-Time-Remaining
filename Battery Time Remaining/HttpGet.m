//
//  HttpGet.m
//  Battery Time Remaining
//
//  Created by Han Lin Yap on 2012-08-12.
//  Copyright (c) 2013 Han Lin Yap. All rights reserved.
//

#import "HttpGet.h"

static HttpGet *sHttpGet;

// Private properties
@interface HttpGet()
@property (nonatomic, copy) void(^successBlock)(NSString *result);
@property (nonatomic, copy) void(^errorBlock)(NSError *error);
@property (nonatomic, strong) NSURLConnection *urlConnection;
@property (nonatomic, strong) NSMutableData *tempData;
@end

@implementation HttpGet
@synthesize successBlock, errorBlock, urlConnection, tempData;

- (id)init
{
    self = [super init];
    if (self) {
        self.tempData = [NSMutableData new];
    }
    return self;
}

#pragma mark - Singleton setup

+ (void)initialize
{
    NSAssert(self == [HttpGet class],
             @"HttpGet is not designed to be subclassed");
    sHttpGet = [HttpGet new];
}

+ (HttpGet *)sharedHttpGet
{
    return sHttpGet;
}

#pragma mark - Public methods

- (void)url:(NSString *)url success:(void(^)(NSString *result))aSuccessBlock
{
    [self url:url success:aSuccessBlock error:nil];
}

- (void)url:(NSString *)url success:(void(^)(NSString *result))aSuccessBlock error:(void(^)(NSError *error))aErrorBlock
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    self.successBlock = aSuccessBlock;
    self.errorBlock = aErrorBlock;
    
    // Cancel last url connection if we have one
    [self.urlConnection cancel];

    self.urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

#pragma mark - NSURLConnectionDelegate methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [self.tempData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.tempData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    self.errorBlock(error);
    
    [self.tempData setLength:0];
    self.urlConnection = nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    self.successBlock([[NSString alloc] initWithData:self.tempData encoding:NSUTF8StringEncoding]);
    
    [self.tempData setLength:0];
    self.urlConnection = nil;
}

@end
