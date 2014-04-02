//
//  ReplayEndpointTests.h
//  ReplayIO
//
//  Created by Allen Wu on 4/1/14.
//  Copyright (c) 2014 Originate. All rights reserved.
//

#import <XCTest/XCTest.h>

@class ReplayEndpoint;

@interface ReplayEndpointTests : XCTestCase {
  ReplayEndpoint* _endpointEventWithData;
  ReplayEndpoint* _endpointEventWithNilData;
  
  ReplayEndpoint* _endpointAliasWithData;
  ReplayEndpoint* _endpointAliasWithNilData;
  
  ReplayEndpoint* _endpointUnknownWithData;
  ReplayEndpoint* _endpointUnknownWithNilData;
}

@end
