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

static NSString* const REPLAY_PLIST_KEY = @"ReplayIO.savedRequestQueue";


@interface ReplayQueue ()
@property (nonatomic) BOOL currentlyProcessingQueue;
@property (nonatomic) ReplayDispatchMode dispatchMode;
@property (nonatomic) NSTimer* dispatchTimer;
@end


@implementation ReplayQueue

- (instancetype)init {
  self = [super init];
  if (self) {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
    
    self.reachability = [Reachability reachabilityForInternetConnection];
    [self.reachability startNotifier];
    
    [self loadQueueFromDisk];
    self->_dispatchInterval = 0; // bypass setter to avoid DEBUG_LOG circular reference (explanation in git commit)
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
    [self stopTimer];
  }
  // immediate dispatching
  else if (dispatchInterval == 0) {
    DEBUG_LOG(@"Dispatch mode = immediate");
    self.dispatchMode = kReplayDispatchModeImmediate;
    [self stopTimer];
  }
  // timer-based dispatching
  else {
    DEBUG_LOG(@"Dispatch mode = timer (t = %li)", (long)dispatchInterval);
    self.dispatchMode = kReplayDispatchModeTimer;
    [self startTimer];
  }
}

- (void)startTimer {
  [self stopTimer];
  
  if (self.dispatchMode == kReplayDispatchModeTimer) {
    self.dispatchTimer = [NSTimer scheduledTimerWithTimeInterval:self.dispatchInterval
                                                          target:self
                                                        selector:@selector(timerDidFire:)
                                                        userInfo:nil
                                                         repeats:YES];
  }
}

- (void)stopTimer {
  [self.dispatchTimer invalidate];
  self.dispatchTimer = nil;
}

- (void)saveQueueToDisk {
  if ([self.requestQueue count] > 0) {
    NSData* queueData = [NSKeyedArchiver archivedDataWithRootObject:self.requestQueue];
    [[NSUserDefaults standardUserDefaults] setObject:queueData forKey:REPLAY_PLIST_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    self.requestQueue = [NSMutableArray array];
  }
}

- (void)loadQueueFromDisk {
  NSData* savedQueueData = [[NSUserDefaults standardUserDefaults] objectForKey:REPLAY_PLIST_KEY];
  NSArray* savedQueue = [NSKeyedUnarchiver unarchiveObjectWithData:savedQueueData];
  
  self.requestQueue = !savedQueue ? [NSMutableArray array] : [[NSMutableArray alloc] initWithArray:savedQueue];

  [[NSUserDefaults standardUserDefaults] removeObjectForKey:REPLAY_PLIST_KEY];
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
  if (self.dispatchMode == kReplayDispatchModeTimer) {
    [self startTimer];
  }
  
  if (!self.currentlyProcessingQueue && [self.requestQueue count] > 0) {
    self.currentlyProcessingQueue = YES;
    
    NSURLRequest* firstRequest = [self.requestQueue objectAtIndex:0];
    [self sendAsynchronousRequest:firstRequest];
  }
  else {
    if (self.currentlyProcessingQueue)
      DEBUG_LOG(@"  Can't dequeue - request in progress");
    if ([self.requestQueue count] == 0)
      DEBUG_LOG(@"  Empty queue");
  }
}

- (void)timerDidFire:(NSTimer *)timer {
  DEBUG_LOG(@"Timer fired!");
  [self dequeue];
}


@end
