//
//  ReplayQueue.m
//  ReplayIO
//
//  Created by Allen Wu on 4/7/14.
//  Copyright (c) 2014 Originate. All rights reserved.
//

#import "ReplayQueue.h"
#import "Reachability/Reachability.h"
#import "ReplayConfig.h"

typedef NS_ENUM(NSUInteger, ReplayDispatchMode) {
  kReplayDispatchModeImmediate = 1,
  kReplayDispatchModeManual    = 2,
  kReplayDispatchModeTimer     = 3
};


@interface ReplayQueue ()
@property (nonatomic) BOOL currentlyProcessingQueue;
@property (nonatomic) ReplayDispatchMode dispatchMode;
@property (nonatomic) NSTimer* dispatchTimer;
@end


@implementation ReplayQueue

SYNTHESIZE_SINGLETON(ReplayQueue, sharedQueue);

- (instancetype)init {
  self = [super init];
  if (self) {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
    
    self.reachability = [Reachability reachabilityForInternetConnection];
    [self.reachability startNotifier];
    
    self.requestQueue             = [NSMutableArray array];
    self.dispatchInterval         = 0;
    self.currentlyProcessingQueue = NO;
  }
  return self;
}

#pragma mark - Reachability notifications

- (void)reachabilityChanged:(NSNotification *)notification {
  Reachability* reachability = [notification object];
  
  // we have internet access so try to dequeue now
  if ([reachability isReachable] &&
      (self.dispatchMode == kReplayDispatchModeTimer || self.dispatchMode == kReplayDispatchModeImmediate))
  {
    DEBUG_LOG(@">>>>> Reachability: reachable");
    [self dequeue];
  }
  else {
    DEBUG_LOG(@">>>>> Reachability: unreachable");
  }
}


#pragma mark - Public methods

- (void)enqueue:(NSURLRequest *)request {
  DEBUG_LOG(@"Enqueuing request (t = %li)", (long)self.dispatchInterval);
  
  [self.requestQueue addObject:request];
  
  // immediate dispatching
  if (self.dispatchMode == kReplayDispatchModeImmediate) {
    [self dequeue];
  }
}

- (void)dispatch {
  DEBUG_LOG(@"Manual dispatch");
  
  [self dequeue];
}

- (void)setDispatchInterval:(NSInteger)dispatchInterval {
  _dispatchInterval = dispatchInterval;
  
  // manual dispatching
  if (dispatchInterval < 0) {
    DEBUG_LOG(@"Dispatch mode = manual");
    self.dispatchMode = kReplayDispatchModeManual;
    self.dispatchTimer = nil;
  }
  // immediate dispatching
  else if (dispatchInterval == 0) {
    DEBUG_LOG(@"Dispatch mode = immediate");
    self.dispatchMode = kReplayDispatchModeImmediate;
    self.dispatchTimer = nil;
  }
  // timer-based dispatching
  else {
    DEBUG_LOG(@"Dispatch mode = timer (t = %li)", (long)dispatchInterval);
    self.dispatchMode = kReplayDispatchModeTimer;
    self.dispatchTimer = [NSTimer scheduledTimerWithTimeInterval:dispatchInterval
                                                          target:self
                                                        selector:@selector(timerDidFire:)
                                                        userInfo:nil
                                                         repeats:YES];
  }
}


#pragma mark - Helpers

// send off a single request
// if it's successful, send off the next request in the queue
- (void)sendAsynchronousRequest:(NSURLRequest *)request {
  DEBUG_LOG(@"Sending request...");
  
  NSMutableURLRequest* requestWithShorterTimeout = [request mutableCopy];
  [requestWithShorterTimeout setTimeoutInterval:15]; // default of 60 sec is too long
  
  [NSURLConnection sendAsynchronousRequest:requestWithShorterTimeout
                                     queue:[NSOperationQueue mainQueue]
                         completionHandler:^(NSURLResponse* response, NSData* data, NSError* connectionError) {
                           // success - remove request from queue and process next item
                           if (!connectionError) {
                             [self.requestQueue removeObjectAtIndex:0];
                             
                             DEBUG_LOG(@"  Sent successfully");
                             DEBUG_LOG(@"  Requests remaining in queue: %lu", (unsigned long)[self.requestQueue count]);
                             
                             if ([self.requestQueue count] > 0) {
                               NSURLRequest* nextRequest = [self.requestQueue objectAtIndex:0];
                               [self sendAsynchronousRequest:nextRequest];
                               return;
                             }
                           }
                           
                           // failure - wait for Reachability notification to call dequeue
                           else {
                             DEBUG_LOG(@"  Sent failure");
                             DEBUG_LOG(@"  Requests remaining in queue: %lu", (unsigned long)[self.requestQueue count]);
                           }
                           
                           self.currentlyProcessingQueue = NO;
                         }];
}

// attempt to send off all requests in the queue
- (void)dequeue {
  if (!self.currentlyProcessingQueue && [self.requestQueue count] > 0) {
    self.currentlyProcessingQueue = YES;
    
    NSURLRequest* firstRequest = [self.requestQueue objectAtIndex:0];
    [self sendAsynchronousRequest:firstRequest];
  }
  else {
    DEBUG_LOG(@"Can't dequeue -- request in progress OR empty queue");
  }
}

- (void)timerDidFire:(NSTimer *)timer {
  DEBUG_LOG(@"Timer fired!");
  [self dequeue];
}

@end
