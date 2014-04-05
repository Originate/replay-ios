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

- (void)testRequestForEvent {
  
  NSDictionary* correctJson = @{@"replayKey": kTestApiKey,
                                @"clientId" : kClientUUID,
                                @"sessionId": kSessionUUID,
                                @"data"     : @{@"event": @"myEventName",
                                                @"1"    : @"one",
                                                @"2"    : @"two",
                                                @"3"    : @"three"}};
  
  NSURLRequest* request = [_replayAPIManagerInstance1 requestForEvent:@"myEventName"
                                                             withData:@{@"1": @"one",
                                                                        @"2": @"two",
                                                                        @"3": @"three"}];
  
  XCTAssertTrue([request.HTTPMethod isEqualToString:@"POST"],
                @"Request for event should have HTTP Method: POST");
  
  XCTAssertTrue([request.HTTPBody isEqualToData:[NSJSONSerialization dataWithJSONObject:correctJson options:0 error:nil]],
                @"Request for event should have correct HTTP body");
  
  XCTAssertTrue([[request.URL absoluteString] rangeOfString:@"/events"].location != NSNotFound,
                @"Request url should end with /events");
}

- (void)testRequestForAlias {
  
  NSDictionary* correctJson = @{@"replayKey": kTestApiKey,
                                @"clientId" : kClientUUID,
                                @"alias"    : @"testAlias"};
  
  NSURLRequest* request = [_replayAPIManagerInstance1 requestForAlias:@"testAlias"];
  
  XCTAssertTrue([request.HTTPMethod isEqualToString:@"POST"],
                @"Request for alias should have HTTP Method: POST");
  
  XCTAssertTrue([request.HTTPBody isEqualToData:[NSJSONSerialization dataWithJSONObject:correctJson options:0 error:nil]],
                @"Request for alias should have correct HTTP body");
  
  XCTAssertTrue([[request.URL absoluteString] rangeOfString:@"/aliases"].location != NSNotFound,
                @"Request url should end with /aliases");
}

@end
