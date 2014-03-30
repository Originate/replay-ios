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

+ (ReplayAPIManager *)sharedManager;
- (void)setAPIKey:(NSString *)apiKey clientUUID:(NSString *)clientUUID sessionUUID:(NSString *)sessionUUID;
- (void)callEndpoint:(NSString *)endpointName withData:(id)data completionHandler:(void (^)(NSURLResponse* response, NSData* data, NSError* connectionError)) handler;

+ (NSString *)mapLocalKeyFromServerKey:(NSString *)serverKey;

@end
