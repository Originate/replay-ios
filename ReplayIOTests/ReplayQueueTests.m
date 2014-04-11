//
//  ReplayQueueTests.m
//  ReplayIO
//
//  Created by Allen Wu on 4/7/14.
//  Copyright (c) 2014 Originate. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ReplayQueue.h"

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

// TODO: figure out how to test the networking/async stuff

@end
