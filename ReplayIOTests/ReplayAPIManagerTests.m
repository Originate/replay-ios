//
//  ReplayAPIManagerTests.m
//  ReplayIO
//
//  Created by Allen Wu on 4/2/14.
//  Copyright (c) 2014 Originate. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ReplayAPIManager.h"

#define kTestApiKey @"testApiKey"
#define kClientUUID @"clientUUID"
#define kSessionUUID @"sessionUUID"

@interface ReplayAPIManagerTests : XCTestCase {
  ReplayAPIManager* _replayAPIManagerInstance1;
  ReplayAPIManager* _replayAPIManagerInstance2;
}
@end


@implementation ReplayAPIManagerTests

- (void)setUp {
  [super setUp];
  
  _replayAPIManagerInstance1 = [ReplayAPIManager sharedManager];
  _replayAPIManagerInstance2 = [ReplayAPIManager sharedManager];
}

- (void)tearDown {
  [super tearDown];
}

- (void)testIsSingleton {
  XCTAssertEqualObjects(_replayAPIManagerInstance1, _replayAPIManagerInstance2, @"ReplayAPIManager should be a singleton");
}

- (void)testAggregateSetter {
  [_replayAPIManagerInstance1 setAPIKey:kTestApiKey
                             clientUUID:kClientUUID
                            sessionUUID:kSessionUUID];
  
  XCTAssertEqualObjects(_replayAPIManagerInstance1.apiKey, kTestApiKey, @"ReplayAPIManager apiKey property should be set via setAPIKey:clientUUID:sessionUUID:");
  XCTAssertEqualObjects(_replayAPIManagerInstance1.clientUUID, kClientUUID, @"ReplayAPIManager clientUUID property should be set via setAPIKey:clientUUID:sessionUUID:");
  XCTAssertEqualObjects(_replayAPIManagerInstance1.sessionUUID, kSessionUUID, @"ReplayAPIManager sessionUUID property should be set via setAPIKey:clientUUID:sessionUUID:");
}

@end
