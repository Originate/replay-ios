//
//  ReplayIOTests.m
//  ReplayIO
//
//  Created by Allen Wu on 4/2/14.
//  Copyright (c) 2014 Originate. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ReplayIO.h"

@interface ReplayIOTests : XCTestCase {
  ReplayIO* _replayIOInstance1;
  ReplayIO* _replayIOInstance2;
}
@end

@implementation ReplayIOTests

- (void)setUp {
  [super setUp];
  
  _replayIOInstance1 = [ReplayIO sharedTracker];
  _replayIOInstance2 = [ReplayIO sharedTracker];
}

- (void)tearDown {
  [super tearDown];
}

- (void)testIsSingleton {
  XCTAssertEqualObjects(_replayIOInstance1, _replayIOInstance2, @"ReplayIO should be a singleton");
}

- (void)testDebugProperty {
  [_replayIOInstance1 setDebugMode:NO];
  BOOL debugValueBefore = _replayIOInstance1.debugMode;
  
  [_replayIOInstance1 setDebugMode:YES];
  BOOL debugValueAfter = _replayIOInstance1.debugMode;
  
  XCTAssertNotEqual(debugValueBefore, debugValueAfter, @"ReplayIO debugMode property should be modifiable via setDebugMode:");
}

@end
