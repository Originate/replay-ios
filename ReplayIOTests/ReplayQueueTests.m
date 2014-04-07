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
  ReplayQueue* _replayQueue1;
  ReplayQueue* _replayQueue2;
}
@end

@implementation ReplayQueueTests

- (void)setUp {
  [super setUp];
  
  _replayQueue1 = [ReplayQueue sharedQueue];
  _replayQueue2 = [ReplayQueue sharedQueue];
}

- (void)tearDown {
  [super tearDown];
}

- (void)testIsSingleton {
  XCTAssertEqualObjects(_replayQueue1, _replayQueue2, @"ReplayQueue should be a singleton");
}

- (void)test {
  
}

@end
