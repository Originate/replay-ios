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
  ReplayAPIManager* _replayAPIManager;
}
@end


@implementation ReplayAPIManagerTests

- (void)setUp {
  [super setUp];
  
  _replayAPIManager = [[ReplayAPIManager alloc] init];
}

- (void)tearDown {
  _replayAPIManager = nil;
  
  [super tearDown];
}

- (void)testAggregateSetter {
  [_replayAPIManager setAPIKey:kTestApiKey
                    clientUUID:kClientUUID
                   sessionUUID:kSessionUUID];
  
  XCTAssertEqualObjects(_replayAPIManager.apiKey, kTestApiKey, @"ReplayAPIManager apiKey property should be set via setAPIKey:clientUUID:sessionUUID:");
  XCTAssertEqualObjects(_replayAPIManager.clientUUID, kClientUUID, @"ReplayAPIManager clientUUID property should be set via setAPIKey:clientUUID:sessionUUID:");
  XCTAssertEqualObjects(_replayAPIManager.sessionUUID, kSessionUUID, @"ReplayAPIManager sessionUUID property should be set via setAPIKey:clientUUID:sessionUUID:");
}

- (void)testRequestForEvent {
  [_replayAPIManager setAPIKey:kTestApiKey
                    clientUUID:kClientUUID
                  sessionUUID:kSessionUUID];
  
  NSDictionary* correctJson = @{@"replay_key" : kTestApiKey,
                                @"client_id"  : kClientUUID,
                                @"session_id" : kSessionUUID,
                                @"distinct_id": @"abc",
                                @"event_name" : @"myEventName",
                                @"properties" : @{@"1"   : @"one",
                                                  @"2"   : @"two",
                                                  @"3"   : @"three"}};
  
  NSURLRequest* request = [_replayAPIManager requestForEvent:@"myEventName"
                                                  distinctId:@"abc"
                                                  properties:@{@"1": @"one",
                                                               @"2": @"two",
                                                               @"3": @"three"}];
  
  XCTAssertTrue([request.HTTPMethod isEqualToString:@"POST"],
                @"Request for event should have HTTP Method: POST");
  
  XCTAssertTrue([request.HTTPBody isEqualToData:[NSJSONSerialization dataWithJSONObject:correctJson options:0 error:nil]],
                @"Request for event should have correct HTTP body");
  
  XCTAssertTrue([[request.URL absoluteString] rangeOfString:@"/events"].location != NSNotFound,
                @"Request url should contain /events");
}

- (void)testRequestForAlias {
  [_replayAPIManager setAPIKey:kTestApiKey
                    clientUUID:kClientUUID
                   sessionUUID:kSessionUUID];
  
  NSDictionary* correctJson = @{@"replay_key" : kTestApiKey,
                                @"client_id"  : kClientUUID,
                                @"session_id" : kSessionUUID,
                                @"distinct_id": @"xyz",
                                @"properties" : @{@"a": @"A",
                                                  @"b": @"B",
                                                  @"c": @"C"}};
  
  NSURLRequest* request = [_replayAPIManager requestForTraitsWithDistinctId:@"xyz" properties:@{@"a": @"A",
                                                                                                @"b": @"B",
                                                                                                @"c": @"C"}];
  
  XCTAssertTrue([request.HTTPMethod isEqualToString:@"POST"],
                @"Request for alias should have HTTP Method: POST");
  
  XCTAssertTrue([request.HTTPBody isEqualToData:[NSJSONSerialization dataWithJSONObject:correctJson options:0 error:nil]],
                @"Request for alias should have correct HTTP body");
  
  XCTAssertTrue([[request.URL absoluteString] rangeOfString:@"/traits"].location != NSNotFound,
                @"Request url should contain /traits");
}

@end
