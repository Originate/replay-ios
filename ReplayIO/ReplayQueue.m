//
//  ReplayQueue.m
//  ReplayIO
//
//  Created by Allen Wu on 4/7/14.
//  Copyright (c) 2014 Originate. All rights reserved.
//

#import "ReplayQueue.h"
#import "Reachability/Reachability.h"


@implementation ReplayQueue

SYNTHESIZE_SINGLETON(ReplayQueue, sharedQueue);

- (instancetype)init {
  self = [super init];
  if (self) {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
    
    // TODO: use [Reachability reachabilityForAddress] ?
    self.reachability = [Reachability reachabilityForInternetConnection];
    [self.reachability startNotifier];
    
    self.requestQueue = [NSMutableArray array];
    self.queueMode    = ReplayQueueModeAutomatic;
  }
  return self;
}

#pragma mark - Reachability notifications

- (void)reachabilityChanged:(NSNotification *)notification {
  DEBUG_LOG(@"Reachability changed");
  
  Reachability* reachability = [notification object];
  
  // internet is available now
  if (reachability.currentReachabilityStatus != NotReachable) {
    DEBUG_LOG(@"Reachability: reachable");
    [self dequeue];
  }
}


#pragma mark - Public methods

- (void)enqueue:(NSURLRequest *)request {
  // automatic mode: send request immediately
  if (self.queueMode == ReplayQueueModeAutomatic) {
    DEBUG_LOG(@"Enqueuing request - automatic mode");
    [self.requestQueue addObject:request];
    [self dequeue];
  }
  
  // dispatch mode: enqueue the request
  else {
    DEBUG_LOG(@"Enqueuing request - dispatch mode");
    [self.requestQueue addObject:request];
  }
}

- (void)dispatch {
  [self dequeue];
}


#pragma mark - Helpers

- (void)sendAsynchronousRequest:(NSURLRequest *)request {
  DEBUG_LOG(@"Sending request");
  
  [NSURLConnection sendAsynchronousRequest:request
                                     queue:[NSOperationQueue mainQueue]
                         completionHandler:^(NSURLResponse* response, NSData* data, NSError* connectionError) {
                           // success - remove request from queue and process next item
                           if (!connectionError) {
                             DEBUG_LOG(@"Sent successfully");
                             DEBUG_LOG(@"Size before removing first element: %lu", (unsigned long)[self.requestQueue count]);
                             
                             [self.requestQueue removeObjectAtIndex:0];
                             
                             DEBUG_LOG(@"Size after removing first element: %lu", (unsigned long)[self.requestQueue count]);
                             
                             if ([self.requestQueue count] > 0) {
                               NSURLRequest* nextRequest = [self.requestQueue objectAtIndex:0];
                               [self sendAsynchronousRequest:nextRequest];
                             }
                           }
                           
                           // failure
                           else {
                             DEBUG_LOG(@"Sent failure");
                             DEBUG_LOG(@"How many elements in queue: %lu", (unsigned long)[self.requestQueue count]);
                             // wait for Reachability to trigger -dequeue
                           }
                         }];
}

- (void)dequeue {
  NSURLRequest* firstRequest = [self.requestQueue objectAtIndex:0];
  
  if (firstRequest) {
    [self sendAsynchronousRequest:firstRequest];
  }
}

@end
