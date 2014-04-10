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

+ (ReplayQueue *)sharedQueue;
- (void)enqueue:(NSURLRequest *)request;
- (void)dispatch;
- (void)startTimer;
- (void)stopTimer;
- (void)saveQueueToDisk;
- (void)loadQueueFromDisk;

@property (nonatomic) Reachability* reachability;
@property (nonatomic, strong) NSMutableArray* requestQueue;
@property (nonatomic) NSInteger dispatchInterval;

@end
