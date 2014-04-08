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


@interface ReplayQueue ()
@property (nonatomic) BOOL currentlyProcessingQueue;
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
    
    self.requestQueue = [NSMutableArray array];
    self.queueMode    = ReplayQueueModeAutomatic;
    self.currentlyProcessingQueue = NO;
  }
  return self;
}

#pragma mark - Reachability notifications

- (void)reachabilityChanged:(NSNotification *)notification {
  Reachability* reachability = [notification object];
  
  // ReplayIO server is reachable now
  if ([reachability isReachable]) {
    DEBUG_LOG(@">>>>> Reachability: reachable");
    [self dequeue];
  }
  else {
    DEBUG_LOG(@">>>>> Reachability: unreachable");
  }
}


#pragma mark - Public methods

- (void)enqueue:(NSURLRequest *)request {
  // automatic mode: send request immediately
  if (self.queueMode == ReplayQueueModeAutomatic) {
    DEBUG_LOG(@"Enqueuing request (automatic mode)");
    [self.requestQueue addObject:request];
    [self dequeue];
  }
  
  // dispatch mode: enqueue the request
  else {
    DEBUG_LOG(@"Enqueuing request (dispatch mode)");
    [self.requestQueue addObject:request];
  }
}

- (void)dispatch {
  [self dequeue];
}


#pragma mark - Helpers

// send off a single request
// if it's successful, send off the next request in the queue
- (void)sendAsynchronousRequest:(NSURLRequest *)request {
  DEBUG_LOG(@"Sending request...");
  
  [NSURLConnection sendAsynchronousRequest:request
                                     queue:[NSOperationQueue mainQueue]
                         completionHandler:^(NSURLResponse* response, NSData* data, NSError* connectionError) {
                           // success - remove request from queue and process next item
                           if (!connectionError) {
                             DEBUG_LOG(@"  Sent successfully");
                             
                             [self.requestQueue removeObjectAtIndex:0];
                             
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
    NSURLRequest* firstRequest = [self.requestQueue objectAtIndex:0];

    self.currentlyProcessingQueue = YES;
    [self sendAsynchronousRequest:firstRequest];
  }
  else {
    DEBUG_LOG(@"Request in progress, can't dequeue");
  }
}

@end
