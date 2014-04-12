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


static NSString* const REPLAY_PLIST_KEY = @"ReplayIO.savedRequestQueue";

@interface ReplayQueue ()
@property (nonatomic) BOOL currentlyProcessingQueue;
@end


@implementation ReplayQueue

- (instancetype)init {
  self = [super init];
  if (self) {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
    
    // listen for reachability changes
    self.reachability = [Reachability reachabilityForInternetConnection];
    [self.reachability startNotifier];
    
    // retrieve saved queue
    [self loadQueueFromDisk];
    
    // send all requests immediately by default
    self.dispatchInterval = 0;
    self.currentlyProcessingQueue = NO;
  }
  return self;
}

#pragma mark - Reachability notifications

- (void)reachabilityChanged:(NSNotification *)notification {
  Reachability* reachability = [notification object];
  
  // we have internet access so try to dequeue now
  if ([reachability isReachable] && self.dispatchInterval >= 0) {
    DEBUG_LOG(@">>>>> Reachability: reachable");
    [self dequeue];
  }
  else {
    DEBUG_LOG(@">>>>> Reachability: unreachable");
  }
}


#pragma mark - Public methods (queueing)

- (void)enqueue:(NSURLRequest *)request {
  DEBUG_LOG(@"Enqueued request (%i requests in queue)", (int)[self.requestQueue count] + 1);
  
  [self.requestQueue addObject:request];
  [self startTimerIfNeeded];
}

- (void)dispatch {
  DEBUG_LOG(@"Manual dispatch");
  
  [self dequeue];
}


#pragma mark - Public methods (timers)

- (void)startTimerIfNeeded {
  if (self.dispatchInterval > 0 &&
      [self.requestQueue count] > 0 &&
      (!self.dispatchTimer || self.dispatchInterval != (int)self.dispatchTimer.timeInterval))
  {
    self.dispatchTimer = [NSTimer scheduledTimerWithTimeInterval:self.dispatchInterval
                                                          target:self
                                                        selector:@selector(dequeue)
                                                        userInfo:nil
                                                         repeats:YES];
  }
  else if (self.dispatchInterval == 0) {
    [self stopTimer];
    [self dequeue];
  }
}

- (void)stopTimer {
  [self.dispatchTimer invalidate];
  self.dispatchTimer = nil;
}

- (void)stopTimerIfUnneeded {
  if (self.dispatchInterval <= 0 || [self.requestQueue count] == 0) {
    [self stopTimer];
  }
}


#pragma mark - Public methods (persistence)

- (void)saveQueueToDisk {
  if ([self.requestQueue count] > 0) {
    // save to request queue to disk
    NSData* queueData = [NSKeyedArchiver archivedDataWithRootObject:self.requestQueue];
    [[NSUserDefaults standardUserDefaults] setObject:queueData forKey:REPLAY_PLIST_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // clear queue from memory
    self.requestQueue = [NSMutableArray array];
  }
}

- (void)loadQueueFromDisk {
  NSData* savedQueueData = [[NSUserDefaults standardUserDefaults] objectForKey:REPLAY_PLIST_KEY];
  NSArray* savedQueue = savedQueueData ? [NSKeyedUnarchiver unarchiveObjectWithData:savedQueueData] : nil;
  
  // copy queue from disk to memory
  self.requestQueue = !savedQueue ? [NSMutableArray array] : [[NSMutableArray alloc] initWithArray:savedQueue];

  // clear queue from disk
  [[NSUserDefaults standardUserDefaults] removeObjectForKey:REPLAY_PLIST_KEY];
}


#pragma mark - Helpers

// send off a single request
// if it's successful, send off the next request in the queue
- (void)sendAsynchronousRequest:(NSURLRequest *)request {
  DEBUG_LOG(@"  ├── Sending request...");
  
  [NSURLConnection sendAsynchronousRequest:[self urlRequest:request withTimeout:15]
                                     queue:[NSOperationQueue mainQueue]
                         completionHandler:^(NSURLResponse* response, NSData* data, NSError* connectionError) {
                           // success - remove request from queue and process next item
                           if (!connectionError) {
                             [self.requestQueue removeObjectAtIndex:0];
                             [self stopTimerIfUnneeded];
                             
                             DEBUG_LOG(@"  │    └── Sent successfully (%i left)", (int)[self.requestQueue count]);
                             
                             // dequeue next request
                             if ([self.requestQueue count] > 0) {
                               NSURLRequest* nextRequest = [self.requestQueue objectAtIndex:0];
                               [self sendAsynchronousRequest:nextRequest];
                               return;
                             }
                           }
                           
                           // failure - wait for Reachability notification to call dequeue
                           else {
                             DEBUG_LOG(@"  │    └── Sent failure (%i left)", (int)[self.requestQueue count]);
                           }
                           
                           self.currentlyProcessingQueue = NO;
                         }];
}

// attempt to send off all requests in the queue
- (void)dequeue {
  DEBUG_LOG(@"Dequeueing requests...");
  
  if (!self.currentlyProcessingQueue && [self.requestQueue count] > 0) {
    self.currentlyProcessingQueue = YES;
    
    NSURLRequest* firstRequest = [self.requestQueue objectAtIndex:0];
    [self sendAsynchronousRequest:firstRequest];
  }
  else {
    [self stopTimerIfUnneeded];
    
    if (self.currentlyProcessingQueue) {
      DEBUG_LOG(@"  ├── Can't dequeue - request in progress");
    }
    if ([self.requestQueue count] == 0) {
      DEBUG_LOG(@"  ├── Empty queue");
    }
  }
}

- (NSURLRequest *)urlRequest:(NSURLRequest *)request withTimeout:(NSTimeInterval)timeout {
  NSMutableURLRequest* mutableRequest = [request mutableCopy];
  [mutableRequest setTimeoutInterval:timeout];
  
  return [mutableRequest copy];
}


@end
