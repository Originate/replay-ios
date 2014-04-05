//
//  ReplaySessionManagerTests.m
//  ReplayIO
//
//  Created by Allen Wu on 4/5/14.
//  Copyright (c) 2014 Originate. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ReplaySessionManager.h"

@interface ReplaySessionManagerTests : XCTestCase
@end

@implementation ReplaySessionManagerTests

- (void)setUp {
  [super setUp];
}

- (void)tearDown {
  [super tearDown];
}

- (void)testSessionUUID {
  NSString* sessionUUID1 = [ReplaySessionManager sessionUUID];
  NSString* sessionUUID2 = [ReplaySessionManager sessionUUID];
  
  XCTAssertEqualObjects(sessionUUID1, sessionUUID2, @"The session UUID should be idempotent across a single session");
}

- (void)testBeginNewSession {
  NSString* sessionUUID1 = [ReplaySessionManager sessionUUID];
  [ReplaySessionManager endSession];
  NSString* sessionUUID2 = [ReplaySessionManager sessionUUID];
  
  XCTAssertNotEqualObjects(sessionUUID1, sessionUUID2, @"The session UUID should be different across multiple sessions");
}

@end
