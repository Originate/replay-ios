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
@property (nonatomic, strong, readonly) NSString* sessionUUID; // NOTE: why are these readonly if you can mutate them through -setAPIKey:clientUUID:sessionUUID:? Why not set those through an initializer?

- (void)setAPIKey:(NSString *)apiKey clientUUID:(NSString *)clientUUID sessionUUID:(NSString *)sessionUUID;
- (void)updateSessionUUID:(NSString *)sessionUUID; // NOTE: why isn't sessionUUID readwrite?

- (NSURLRequest *)requestForEvent:(NSString *)eventName
                       distinctId:(NSString *)distinctId
                       properties:(NSDictionary *)properties;

- (NSURLRequest *)requestForTraitsWithDistinctId:(NSString *)distinctId
                                      properties:(NSDictionary *)properties;

@end
