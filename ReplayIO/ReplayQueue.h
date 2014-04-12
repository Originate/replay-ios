//
//  ReplayQueue.h
//  ReplayIO
//
//  Created by Allen Wu on 4/7/14.
//  Copyright (c) 2014 Originate. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Reachability;

@interface ReplayQueue : NSObject

// queueing
- (void)enqueue:(NSURLRequest *)request;
- (void)dispatch;

// timer
- (void)startTimerIfNeeded;
- (void)stopTimer;

// persistence
- (void)saveQueueToDisk;
- (void)loadQueueFromDisk;


@property (nonatomic) Reachability* reachability;
@property (nonatomic, strong) NSMutableArray* requestQueue;
@property (nonatomic, strong) NSTimer* dispatchTimer;
@property (nonatomic) NSInteger dispatchInterval;

@end
