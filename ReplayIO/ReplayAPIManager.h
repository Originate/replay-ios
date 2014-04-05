//
//  ReplayAPIManager.h
//  ReplayIO
//
//  Created by Allen Wu on 3/28/14.
//  Copyright (c) 2014 Originate. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ReplayAPIManager : NSObject

@property (nonatomic, strong, readonly) NSString* apiKey;
@property (nonatomic, strong, readonly) NSString* clientUUID;
@property (nonatomic, strong, readonly) NSString* sessionUUID;

+ (ReplayAPIManager *)sharedManager;

- (void)setAPIKey:(NSString *)apiKey clientUUID:(NSString *)clientUUID sessionUUID:(NSString *)sessionUUID;

- (NSURLRequest *)requestForEvent:(NSString *)eventName withData:(NSDictionary *)data;
- (NSURLRequest *)requestForAlias:(NSString *)alias;

@end
