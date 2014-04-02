//
//  ReplayEndpointTests.m
//  ReplayIO
//
//  Created by Allen Wu on 4/1/14.
//  Copyright (c) 2014 Originate. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ReplayEndpoint.h"
#import "ReplayAPIManager.h"

#define kTestApiKey @"testApiKey"
#define kTestClientUUID @"testClientUUID"
#define kTestSessionUUID @"testSessionUUID"

#define kTestEventData @{@"test": @"event"}
#define kTestAliasData @"Test Alias"
#define kTestUnknownData @{@"unknown": @"unknown"}


@interface ReplayEndpointTests : XCTestCase {
  ReplayEndpoint* _endpointEventWithData;
  ReplayEndpoint* _endpointEventWithNilData;
  
  ReplayEndpoint* _endpointAliasWithData;
  ReplayEndpoint* _endpointAliasWithNilData;
  
  ReplayEndpoint* _endpointUnknownWithData;
  ReplayEndpoint* _endpointUnknownWithNilData;
}
@end


@implementation ReplayEndpointTests

- (void)setUp {
  [super setUp];
  
  [[ReplayAPIManager sharedManager] setAPIKey:kTestApiKey clientUUID:kTestClientUUID sessionUUID:kTestSessionUUID];
  
  _endpointEventWithData      = [[ReplayEndpoint alloc] initWithEndpointName:@"Events" data:kTestEventData];
  _endpointEventWithNilData   = [[ReplayEndpoint alloc] initWithEndpointName:@"Events" data:nil];
  
  _endpointAliasWithData      = [[ReplayEndpoint alloc] initWithEndpointName:@"Alias" data:kTestAliasData];
  _endpointAliasWithNilData   = [[ReplayEndpoint alloc] initWithEndpointName:@"Alias" data:nil];
  
  _endpointUnknownWithData    = [[ReplayEndpoint alloc] initWithEndpointName:@"UnknownEndpoint" data:kTestUnknownData];
  _endpointUnknownWithNilData = [[ReplayEndpoint alloc] initWithEndpointName:@"UnknownEndpoint" data:nil];
}

- (void)tearDown {
  [super tearDown];
}


#pragma mark - Endpoint Event with data

- (void)testEventWithDataHasUrl {
  XCTAssertNotNil(_endpointEventWithData.url, @"Event endpoint object should have a url");
}

- (void)testEventWithDataHasHttpMethod {
  XCTAssertEqual(_endpointEventWithData.httpMethod, @"POST", @"Event endpoint object should have HTTP method: POST");
}

- (void)testEndPointEventWithDataHasCorrectJsonData {
  
  NSDictionary* correctJson = @{@"data"     : kTestEventData,
                                @"replayKey": kTestApiKey,
                                @"clientId" : kTestClientUUID,
                                @"sessionId": kTestSessionUUID};
  
  NSData* correctJsonData = [NSJSONSerialization dataWithJSONObject:correctJson options:0 error:nil];
  
  XCTAssertTrue([correctJsonData isEqualToData:_endpointEventWithData.jsonData], @"Event endpoint object produced incorrect jsonData");
}


#pragma mark - Endpoint Alias with data

- (void)testAliasWithDataHasUrl {
  XCTAssertNotNil(_endpointAliasWithData.url, @"Alias endpoint object should have a url");
}

- (void)testAliasWithDataHasHttpMethod {
  XCTAssertEqual(_endpointAliasWithData.httpMethod, @"POST", @"Alias endpoint object should have HTTP method: POST");
}

- (void)testAliasWithDataHasCorrectJsonData {
  
  NSDictionary* correctJson = @{@"data"     : @{@"alias": kTestAliasData},
                                @"replayKey": kTestApiKey,
                                @"clientId" : kTestClientUUID};
  
  NSData* correctJsonData = [NSJSONSerialization dataWithJSONObject:correctJson options:0 error:nil];
  
  XCTAssertTrue([correctJsonData isEqualToData:_endpointAliasWithData.jsonData], @"Alias endpoint object produced incorrect jsonData");
}


#pragma mark - Unknown Alias with data

- (void)testUnknownCallShouldReturnNilJSON {
  
  [_endpointUnknownWithData callWithCompletionHandler:^(id json, NSError *error) {
    XCTAssertNil(json, @"Calling unknown endpoint should return nil JSON");
  }];
}

- (void)testUnknownCallShouldProduceError {
  
  [_endpointUnknownWithData callWithCompletionHandler:^(id json, NSError *error) {
    XCTAssertEqual([error domain], ERROR_DOMAIN_REPLAY_IO, @"Calling unknown endpoint should produce an error");
  }];
}


#pragma mark - Endpoint Event with nil data

- (void)testEventWithNilDataHasUrl {
  XCTAssertNotNil(_endpointEventWithNilData.url, @"Event endpoint object should have a url");
}

- (void)testEventWithNilDataHasHttpMethod {
  XCTAssertEqual(_endpointEventWithNilData.httpMethod, @"POST", @"Event endpoint object should have HTTP method: POST");
}

- (void)testEventWithNilDataHasCorrectJsonData {
  
  NSDictionary* correctJson = @{@"data"     : [NSNull null],
                                @"replayKey": kTestApiKey,
                                @"clientId" : kTestClientUUID,
                                @"sessionId": kTestSessionUUID};
  
  NSData* correctJsonData = [NSJSONSerialization dataWithJSONObject:correctJson options:0 error:nil];
  
  XCTAssertTrue([correctJsonData isEqualToData:_endpointEventWithNilData.jsonData], @"Event endpoint object produced incorrect jsonData");
}


#pragma mark - Endpoint Alias with nil data

- (void)testAliasWithNilDataHasUrl {
  XCTAssertNotNil(_endpointAliasWithNilData.url, @"Alias endpoint object should have a url");
}

- (void)testAliasWithNilDataHasHttpMethod {
  XCTAssertEqual(_endpointAliasWithNilData.httpMethod, @"POST", @"Alias endpoint object should have HTTP method: POST");
}

- (void)testAliasWithNilDataHasCorrectJsonData {
  
  NSDictionary* correctJson = @{@"data"     : @{@"alias": [NSNull null]},
                                @"replayKey": kTestApiKey,
                                @"clientId" : kTestClientUUID};
  
  NSData* correctJsonData = [NSJSONSerialization dataWithJSONObject:correctJson options:0 error:nil];
  
  XCTAssertTrue([correctJsonData isEqualToData:_endpointAliasWithNilData.jsonData], @"Alias endpoint object produced incorrect jsonData");
}


#pragma mark - Unknown Alias with nil data

- (void)testUnknownWithNilDataCallShouldReturnNilJSON {
  
  [_endpointUnknownWithNilData callWithCompletionHandler:^(id json, NSError *error) {
    XCTAssertNil(json, @"Calling unknown endpoint should return nil JSON");
  }];
}

- (void)testUnknownWithNilDataCallShouldProduceError {
  
  [_endpointUnknownWithNilData callWithCompletionHandler:^(id json, NSError *error) {
    XCTAssertEqual([error domain], ERROR_DOMAIN_REPLAY_IO, @"Calling unknown endpoint should produce an error");
  }];
}

@end
