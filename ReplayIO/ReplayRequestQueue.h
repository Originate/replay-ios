//
//  ReplayQueue.h
//  ReplayIO
//
//  Created by Allen Wu on 4/7/14.
//  Copyright (c) 2014 Originate. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ReplayRequest;

@interface ReplayRequestQueue : NSObject

@property (nonatomic, readonly) NSArray* requests;

+ (instancetype)requestQueueWithData:(NSData*)data;

- (void)addRequest:(ReplayRequest*)request;
- (void)addRequests:(NSArray*)requests;
- (void)removeRequest:(ReplayRequest*)request;
- (void)mergeWithRequestQueue:(ReplayRequestQueue*)requestQueue;
- (void)clearQueue;
- (NSData*)serializedQueue;

@end
