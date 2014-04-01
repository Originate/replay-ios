//
//  ReplayEndpoint.h
//  ReplayIO
//
//  Created by Allen Wu on 3/30/14.
//  Copyright (c) 2014 Originate. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ReplayEndpoint : NSObject

@property (nonatomic, strong, readonly) NSData* jsonData;
@property (nonatomic, strong, readonly) NSURL* url;
@property (nonatomic, strong, readonly) NSString* httpMethod;

- (id)initWithEndpointName:(NSString *)endpointName data:(id)data;
- (void)callWithCompletionHandler:(void (^)(id json, NSError* error)) handler;

@end
