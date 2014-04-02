//
//  ReplayConfig.m
//  ReplayIO
//
//  Created by Allen Wu on 4/2/14.
//  Copyright (c) 2014 Originate. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ReplayConfig.h"

@interface ReplayConfigTests : XCTestCase {
  ReplayConfig* _replayConfigInstance1;
  ReplayConfig* _replayConfigInstance2;
}
@end

@implementation ReplayConfigTests

- (void)setUp {
  [super setUp];
  
  _replayConfigInstance1 = [ReplayConfig sharedInstance];
  _replayConfigInstance2 = [ReplayConfig sharedInstance];
}

- (void)tearDown {
  [super tearDown];
}

- (void)testIsSingleton {
  XCTAssertEqualObjects(_replayConfigInstance1, _replayConfigInstance2, @"ReplayConfig should be a singleton");
}

- (void)testValidEndpointDefinitionIsNotNil {
  NSDictionary* validEndpointDefintion = [ReplayConfig endpointDefinition:@"Events"];
  XCTAssertNotNil(validEndpointDefintion, @"ReplayConfig should return a dictionary endpoint definition for a valid endpoint");
}

- (void)testInvalidEndpointDefinitionIsNil {
  NSDictionary* invalidEndpointDefintion = [ReplayConfig endpointDefinition:@"UnknownEndpoint"];
  XCTAssertNil(invalidEndpointDefintion, @"ReplayConfig should return nil endpoint definition for an invalid endpoint");
}

@end
