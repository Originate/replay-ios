//
//  ReplayEndpointTests.m
//  ReplayIO
//
//  Created by Allen Wu on 4/1/14.
//  Copyright (c) 2014 Originate. All rights reserved.
//

#import "ReplayEndpointTests.h"
#import "ReplayEndpoint.h"
#import "ReplayAPIManager.h"

@implementation ReplayEndpointTests

- (void)setUp {
  [[ReplayAPIManager sharedManager] setAPIKey:@"testApiKey" clientUUID:@"testClientUUID" sessionUUID:@"testSessionUUID"];
  
  _endpointEventWithData      = [[ReplayEndpoint alloc] initWithEndpointName:@"Events" data:@{@"test": @"event"}];
  _endpointEventWithNilData   = [[ReplayEndpoint alloc] initWithEndpointName:@"Events" data:nil];
  
  _endpointAliasWithData      = [[ReplayEndpoint alloc] initWithEndpointName:@"Alias" data:@"Test Alias"];
  _endpointAliasWithNilData   = [[ReplayEndpoint alloc] initWithEndpointName:@"Alias" data:nil];

  _endpointUnknownWithData    = [[ReplayEndpoint alloc] initWithEndpointName:@"UnknownEndpoint" data:@{@"test": @"unknown"}];
  _endpointUnknownWithNilData = [[ReplayEndpoint alloc] initWithEndpointName:@"UnknownEndpoint" data:nil];
}

- (void)tearDown {}


#pragma mark - Endpoint Event with data

- (void)testEndPointEventWithDataHasUrl {
  XCTAssertNotNil(_endpointEventWithData.url, @"Event endpoint object should have a url");
}

- (void)testEndPointEventWithDataHasHttpMethod {
  XCTAssertEqual(_endpointEventWithData.httpMethod, @"POST", @"Event endpoint object should have HTTP method: POST");
}

- (void)testEndPointEventWithDataHasCorrectJsonData {
  
  NSDictionary* correctJson = @{@"data"     : @{@"test": @"event"},
                                @"replayKey": @"testApiKey",
                                @"clientId" : @"testClientUUID",
                                @"sessionId": @"testSessionUUID"};
  
  NSData* correctJsonData = [NSJSONSerialization dataWithJSONObject:correctJson options:0 error:nil];
  
  XCTAssertTrue([correctJsonData isEqualToData:_endpointEventWithData.jsonData], @"Event endpoint object produced incorrect jsonData");
}


#pragma mark - Endpoint Alias with data

- (void)testEndPointAliasWithDataHasUrl {
  XCTAssertNotNil(_endpointAliasWithData.url, @"Alias endpoint object should have a url");
}

- (void)testEndPointAliasWithDataHasHttpMethod {
  XCTAssertEqual(_endpointAliasWithData.httpMethod, @"POST", @"Alias endpoint object should have HTTP method: POST");
}

- (void)testEndPointAliasWithDataHasCorrectJsonData {
  
  NSDictionary* correctJson = @{@"data"     : @{@"alias": @"Test Alias"},
                                @"replayKey": @"testApiKey",
                                @"clientId" : @"testClientUUID"};
  
  NSData* correctJsonData = [NSJSONSerialization dataWithJSONObject:correctJson options:0 error:nil];
  
  XCTAssertTrue([correctJsonData isEqualToData:_endpointAliasWithData.jsonData], @"Alias endpoint object produced incorrect jsonData");
}


#pragma mark - Unknown Alias with data

- (void)testEndPointUnknownCallShouldReturnNilJSON {
  
  [_endpointUnknownWithData callWithCompletionHandler:^(id json, NSError *error) {
    XCTAssertNil(json, @"Calling unknown endpoint should return nil JSON");
  }];
}

- (void)testEndPointUnknownCallShouldProduceError {
  
  [_endpointUnknownWithData callWithCompletionHandler:^(id json, NSError *error) {
    XCTAssertEqual([error domain], ERROR_DOMAIN_REPLAY_IO, @"Calling unknown endpoint should produce an error");
  }];
}


#pragma mark - Endpoint Event with nil data

- (void)testEndPointEventWithNilDataHasUrl {
  XCTAssertNotNil(_endpointEventWithNilData.url, @"Event endpoint object should have a url");
}

- (void)testEndPointEventWithNilDataHasHttpMethod {
  XCTAssertEqual(_endpointEventWithNilData.httpMethod, @"POST", @"Event endpoint object should have HTTP method: POST");
}

- (void)testEndPointEventWithNilDataHasCorrectJsonData {
  
  NSDictionary* correctJson = @{@"data"     : [NSNull null],
                                @"replayKey": @"testApiKey",
                                @"clientId" : @"testClientUUID",
                                @"sessionId": @"testSessionUUID"};
  
  NSData* correctJsonData = [NSJSONSerialization dataWithJSONObject:correctJson options:0 error:nil];
  
  XCTAssertTrue([correctJsonData isEqualToData:_endpointEventWithNilData.jsonData], @"Event endpoint object produced incorrect jsonData");
}


#pragma mark - Endpoint Alias with nil data

- (void)testEndPointAliasWithNilDataHasUrl {
  XCTAssertNotNil(_endpointAliasWithNilData.url, @"Alias endpoint object should have a url");
}

- (void)testEndPointAliasWithNilDataHasHttpMethod {
  XCTAssertEqual(_endpointAliasWithNilData.httpMethod, @"POST", @"Alias endpoint object should have HTTP method: POST");
}

- (void)testEndPointAliasWithNilDataHasCorrectJsonData {
  
  NSDictionary* correctJson = @{@"data"     : @{@"alias": [NSNull null]},
                                @"replayKey": @"testApiKey",
                                @"clientId" : @"testClientUUID"};
  
  NSData* correctJsonData = [NSJSONSerialization dataWithJSONObject:correctJson options:0 error:nil];
  
  XCTAssertTrue([correctJsonData isEqualToData:_endpointAliasWithNilData.jsonData], @"Alias endpoint object produced incorrect jsonData");
}


#pragma mark - Unknown Alias with nil data

- (void)testEndPointUnknownWithNilDataCallShouldReturnNilJSON {
  
  [_endpointUnknownWithNilData callWithCompletionHandler:^(id json, NSError *error) {
    XCTAssertNil(json, @"Calling unknown endpoint should return nil JSON");
  }];
}

- (void)testEndPointUnknownWithNilDataCallShouldProduceError {
  
  [_endpointUnknownWithNilData callWithCompletionHandler:^(id json, NSError *error) {
    XCTAssertEqual([error domain], ERROR_DOMAIN_REPLAY_IO, @"Calling unknown endpoint should produce an error");
  }];
}

@end
