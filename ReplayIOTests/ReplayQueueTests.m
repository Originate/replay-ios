//
//  ReplayQueueTests.m
//  ReplayIO
//
//  Created by Allen Wu on 4/7/14.
//  Copyright (c) 2014 Originate. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ReplayQueue.h"


static NSString* const REPLAY_PLIST_KEY = @"ReplayIO.savedRequestQueue";


@interface ReplayQueueTests : XCTestCase {
  ReplayQueue* _replayQueue;
}
@end

@implementation ReplayQueueTests

- (void)setUp {
  [super setUp];
  
  _replayQueue = [[ReplayQueue alloc] init];
}

- (void)tearDown {
  _replayQueue = nil;
  
  [super tearDown];
}

- (void)testEnqueueWithManualDispatch {
  NSUInteger queueCountBefore = [_replayQueue.requestQueue count];
  
  [_replayQueue setDispatchInterval:-1];
  
  NSURLRequest* urlRequest = [[NSURLRequest alloc] init];
  [_replayQueue enqueue:urlRequest];
  
  NSUInteger queueCountAfter = [_replayQueue.requestQueue count];
  
  XCTAssert(queueCountBefore + 1 == queueCountAfter, @"Enqueuing in dispatch mode should increase the queue size");
}


- (void)testTimerNotRunningWithPeriodicDispatchAndEmptyQueue {
  _replayQueue.requestQueue = [NSMutableArray array];
  _replayQueue.dispatchInterval = 3;
  [_replayQueue startTimerIfNeeded];
  
  XCTAssertNil(_replayQueue.dispatchTimer, @"Dispatch timer should be off when the queue is empty, even with periodic dispatch on");
}

- (void)testTimerRunningWithPeriodicDispatchAndNonEmptyQueue {
  NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"test.com"]];
  
  _replayQueue.requestQueue = [NSMutableArray arrayWithArray:@[request]];
  _replayQueue.dispatchInterval = 3;
  [_replayQueue startTimerIfNeeded];
  
  XCTAssertNotNil(_replayQueue.dispatchTimer, @"Dispatch timer should be on when the queue isn't empty and with periodic dispatch on");
}


- (void)testTimerNotRunningWithManualDispatchAndEmptyQueue {
  _replayQueue.requestQueue = [NSMutableArray array];
  _replayQueue.dispatchInterval = -1;
  [_replayQueue startTimerIfNeeded];
  
  XCTAssertNil(_replayQueue.dispatchTimer, @"Dispatch timer should be off when using manual dispatch and queue is empty");
}

- (void)testTimerNotRunningWithManualDispatchAndNonEmptyQueue {
  NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"test.com"]];
  
  _replayQueue.requestQueue = [NSMutableArray arrayWithArray:@[request]];
  _replayQueue.dispatchInterval = -1;
  [_replayQueue startTimerIfNeeded];
  
  XCTAssertNil(_replayQueue.dispatchTimer, @"Dispatch timer should be off when using manual dispatch and queue isn't empty");
}


- (void)testTimerNotRunningWithImmediateDispatchAndEmptyQueue {
  _replayQueue.requestQueue = [NSMutableArray array];
  _replayQueue.dispatchInterval = 0;
  [_replayQueue startTimerIfNeeded];
  
  XCTAssertNil(_replayQueue.dispatchTimer, @"Dispatch timer should be off when using immediate dispatch and queue is empty");
}

- (void)testTimerNotRunningWithImmediateDispatchAndNonEmptyQueue {
  NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"test.com"]];
  
  _replayQueue.requestQueue = [NSMutableArray arrayWithArray:@[request]];
  _replayQueue.dispatchInterval = 0;
  [_replayQueue startTimerIfNeeded];
  
  XCTAssertNil(_replayQueue.dispatchTimer, @"Dispatch timer should be off when using immediate dispatch and queue isn't empty");
}


- (void)testStopTimer {
  NSTimer* testTimer = [NSTimer scheduledTimerWithTimeInterval:1
                                                        target:self
                                                      selector:@selector(fakeSelector:)
                                                      userInfo:nil
                                                       repeats:YES];
  _replayQueue.dispatchTimer = testTimer;
  [_replayQueue stopTimer];
  
  XCTAssertNil(_replayQueue.dispatchTimer, @"Dispatch timer shouldn't be running after stopping it");
}

- (void)testSaveQueueToDisk {
  NSUInteger queueSize = 5;
  
  // Add a test array to NSUserDefaults
  [self populateNSUserDefaultsWithTestQueueOfSize:queueSize];
  
  NSData* beforeData = [[NSUserDefaults standardUserDefaults] objectForKey:REPLAY_PLIST_KEY];
  NSArray* beforeArray = [NSKeyedUnarchiver unarchiveObjectWithData:beforeData];
  NSUInteger beforeCount = [beforeArray count];
  
  // Create the new queue, with a size different from the test array so we can tell that the
  // save operation actually modified NSUserDefaults as expected
  int difference = 10;
  NSMutableArray* testQueue = [NSMutableArray array];
  for (int i = 0; i < beforeCount + difference; i++) {
    NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"test.com"]];
    [testQueue addObject:request];
  }
  
  _replayQueue.requestQueue = testQueue;
  [_replayQueue saveQueueToDisk];
  
  NSData* afterData = [[NSUserDefaults standardUserDefaults] objectForKey:REPLAY_PLIST_KEY];
  NSArray* afterArray = [NSKeyedUnarchiver unarchiveObjectWithData:afterData];
  NSUInteger afterCount = [afterArray count];
  
  XCTAssert(beforeCount + difference == afterCount, @"Saving queue to disk should increase the number of items in NSUserDefaults by the queue size");
  XCTAssert([_replayQueue.requestQueue count] == 0, @"Saving queue to disk should also clear the queue from memory");
}

- (void)testLoadQueueFromDisk {
  NSUInteger queueSize = 3;
  
  _replayQueue.requestQueue = [NSMutableArray array];
  [self populateNSUserDefaultsWithTestQueueOfSize:queueSize];
  
  [_replayQueue loadQueueFromDisk];
  
  XCTAssert([_replayQueue.requestQueue count] == queueSize, @"The request queue should have the same number of items as the persisted queue on disk had");
  
  NSData* queueData = [[NSUserDefaults standardUserDefaults] objectForKey:REPLAY_PLIST_KEY];
  NSArray* queueArray = [NSKeyedUnarchiver unarchiveObjectWithData:queueData];
  
  XCTAssert([queueArray count] == 0, @"Loading queue to memory should also clear the queue from disk");
}

// TODO: figure out how to test the networking/async stuff


#pragma mark - Helpers

- (void)fakeSelector:(NSTimer*)timer {
  NSLog(@"Fake timer triggered");
}

- (void)populateNSUserDefaultsWithTestQueueOfSize:(NSUInteger)size {
  
  NSMutableArray* testQueue = [NSMutableArray array];
  
  for (int i = 0; i < size; i++) {
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"www.test-%i.com", size]];
    NSURLRequest* request = [NSURLRequest requestWithURL:url];
    [testQueue addObject:request];
  }
  
  NSData* testData  = [NSKeyedArchiver archivedDataWithRootObject:testQueue];
  [[NSUserDefaults standardUserDefaults] setObject:testData forKey:REPLAY_PLIST_KEY];
  [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
