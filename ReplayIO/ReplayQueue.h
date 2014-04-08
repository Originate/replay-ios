//
//  ReplayQueue.h
//  ReplayIO
//
//  Created by Allen Wu on 4/7/14.
//  Copyright (c) 2014 Originate. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(NSInteger, ReplayQueueMode) {
  ReplayQueueModeAutomatic = 0,
  ReplayQueueModeDispatch  = 1,
};


@class Reachability;

@interface ReplayQueue : NSObject

+ (ReplayQueue *)sharedQueue;
- (void)enqueue:(NSURLRequest *)request;
- (void)dispatch;

@property (nonatomic) Reachability* reachability;
@property (nonatomic, strong) NSMutableArray* requestQueue;
@property (nonatomic) NSInteger queueMode;

@end
