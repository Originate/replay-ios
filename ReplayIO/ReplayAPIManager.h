//
//  ReplayAPIManager.h
//  ReplayIO
//
//  Created by Allen Wu on 3/28/14.
//  Copyright (c) 2014 Originate. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ReplayAPIManager : NSObject

@property (nonatomic, strong) NSString* apiKey;
@property (nonatomic, strong) NSString* clientUUID;
@property (nonatomic, strong) NSString* sessionUUID;
@property (nonatomic, strong) NSDictionary* configPlist;

+ (ReplayAPIManager *)sharedManager;
- (void)setAPIKey:(NSString *)apiKey clientUUID:(NSString *)clientUUID sessionUUID:(NSString *)sessionUUID;

+ (void)sendJSONRequestToURL:(NSURL *)url
                  httpMethod:(NSString *)httpMethod
                    httpBody:(NSData *)httpBody
           completionHandler:(void (^)(NSURLResponse* response, NSData* data, NSError* connectionError)) handler;


- (void)callEndpoint:(NSString *)endpoint
            withData:(id)data
   completionHandler:(void (^)(NSURLResponse* response, NSData* data, NSError* connectionError)) handler;

@end
