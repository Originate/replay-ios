//
//  ReplayPersistenceControllerTests.m
//  ReplayIO
//
//  Created by Aaron Daub on 2014-09-29.
//  Copyright (c) 2014 Originate. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "ReplayRequest.h"
#import "ReplayPersistenceController.h"

@interface ReplayPersistenceControllerTests : XCTestCase

@property (nonatomic, readwrite, strong) ReplayPersistenceController* persistenceController;

@end

@implementation ReplayPersistenceControllerTests

+ (void)setUp{
  [super setUp];
  
  [[[ReplayPersistenceController alloc] init] deleteDatabase:NULL];
}

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
  self.persistenceController = [[ReplayPersistenceController alloc] init];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  NSError* error;
  [self.persistenceController deleteDatabase:&error];
  [super tearDown];
}

- (void)testDatabaseSetup{
  XCTestExpectation* databaseBecomesReadyExpectation = [self expectationWithDescription:@"Database is ready"];
  [self.persistenceController callBlockWhenDatabaseIsReady:^(BOOL isDatabaseReady) {
    XCTAssertTrue(isDatabaseReady, @"Database should be ready");
    [databaseBecomesReadyExpectation fulfill];
  }];
  
  [self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
    XCTAssertNil(error, @"Expectatins should be fulfilled successfully");
  }];
}

- (void)testDeletion{
  XCTestExpectation* databaseBecomesReadyExpectation = [self expectationWithDescription:@"Database is ready"];
 
  [self.persistenceController callBlockWhenDatabaseIsReady:^(BOOL isDatabaseReady){
    XCTAssertTrue(isDatabaseReady, @"Database should be ready");
    NSError* error;
    BOOL deletedSuccessfully = [self.persistenceController deleteDatabase:&error];
    XCTAssertTrue(deletedSuccessfully, @"We should be able to delete a database");
    XCTAssertNil(error, @"We shouldn't get an error when we delete a database");
    [databaseBecomesReadyExpectation fulfill];
  }];
 
  [self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
    XCTAssertNil(error, @"Expectations should be fulfilled successfully");
  }];
}

- (void)testRequestInsertion{
  ReplayRequest* request = [self arbitraryRequest];
  
  XCTestExpectation* fetchRequestsExpectation = [self expectationWithDescription:@"Fetched requests"];
  
  [self.persistenceController callBlockWhenDatabaseIsReady:^(BOOL isDatabaseReady){
    XCTAssertTrue(isDatabaseReady, @"Database should be ready");
    [self.persistenceController persistRequest:request onCompletion:^{
      [self.persistenceController fetchAllRequests:^(NSArray *replayRequests) {
        XCTAssertEqual(replayRequests.count, 1, @"We should have one request after inserting an arbitrary request");
        [fetchRequestsExpectation fulfill];
      }];
    }];
  }];
  
  [self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
    XCTAssertNil(error, @"Expectations should be fulfilled successfully");
  }];
}

- (void)testRequestRemoval{
  ReplayRequest* request = [self arbitraryRequest];
  
  XCTestExpectation* fetchRequestsExpectation = [self expectationWithDescription:@"Fetched requests"];
  
  [self.persistenceController callBlockWhenDatabaseIsReady:^(BOOL isDatabaseReady) {
    XCTAssertTrue(isDatabaseReady, @"Database should be ready");
    [self.persistenceController persistRequest:request onCompletion:^{
      [self.persistenceController removeRequest:request];
      [self.persistenceController fetchAllRequests:^(NSArray *replayRequests) {
        XCTAssertEqual(replayRequests.count, 0, @"We shouldn't have any requests after inserting one then removing it");
        [fetchRequestsExpectation fulfill];
      }];
    }];
  }];
  
  [self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
    XCTAssertNil(error, @"Expectations should be fulfilled successfully");
  }];
}

- (void)testRequestFetching{
  NSMutableArray* requests = [NSMutableArray array];
  for(int i = 0; i < 25; i++){
    [requests addObject:[self arbitraryRequest]];
  }

  XCTestExpectation* fetchRequestsExpectation = [self expectationWithDescription:@"Fetched requests"];
  
  [self.persistenceController callBlockWhenDatabaseIsReady:^(BOOL isDatabaseReady){
    XCTAssertTrue(isDatabaseReady, @"Database should be ready");
    [self persistRequests:requests.copy finalCompletion:^{
      [self.persistenceController fetchAllRequests:^(NSArray *replayRequests) {
        XCTAssertEqual(replayRequests.count, requests.count, @"We should have as many requests as we have tried to persist");
        [fetchRequestsExpectation fulfill];
      }];
    }];
  }];
  
  [self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
    XCTAssertNil(error, @"Expectations should be fulfilled successfully");
  }];
  
}

- (void)persistRequests:(NSArray*)requests finalCompletion:(ReplayPersistenceControllerCompletion)completionBlock{
  if(requests.count == 0){
    completionBlock();
    return;
  }
  
  [self.persistenceController persistRequest:requests.firstObject onCompletion:^{
    [self persistRequests:[requests subarrayWithRange:NSMakeRange(1, requests.count - 1)] finalCompletion:completionBlock];
  }];
}

- (ReplayRequest*)arbitraryRequest{
  return [ReplayRequest requestWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://some-url%d.com", arc4random_uniform(256)]]]];
}

@end
