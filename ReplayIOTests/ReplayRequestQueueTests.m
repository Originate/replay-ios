//
//  ReplayQueueTests.m
//  ReplayIO
//
//  Created by Allen Wu on 4/7/14.
//  Copyright (c) 2014 Originate. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ReplayRequestQueue.h"
#import "ReplayRequest.h"

static NSString* const REPLAY_PLIST_KEY = @"ReplayIO.savedRequestQueue";
static NSUInteger numberOfItems = 100;

@interface ReplayRequestQueueTests : XCTestCase

@property (nonatomic, readwrite, strong) ReplayRequestQueue* requestQueue;

@end

@implementation ReplayRequestQueueTests

+ (void)setUp{
  [super setUp];
  
  [self populateNSUserDefaultsWithTestQueueOfSize:numberOfItems];
}

- (void)setUp {
  [super setUp];
  
  self.requestQueue = [self existingReplayQueue];
}

- (void)tearDown {
  self.requestQueue = nil;
  
  [super tearDown];
}

+ (void)tearDown{
  [[NSUserDefaults standardUserDefaults] removeObjectForKey:REPLAY_PLIST_KEY];
  [[NSUserDefaults standardUserDefaults] synchronize];
  
  [super tearDown];
}

- (void)testQueueAppending{
  for(NSUInteger i = 0; i < numberOfItems; i++){
    [self.requestQueue addRequest:[ReplayRequest requestWithURLRequest:[self sampleRequest]]];
    XCTAssertEqual(i + 1, self.requestQueue.requests.count);
  }
}

- (void)testQueueRemoval{
  [self.requestQueue removeRequest:self.requestQueue.requests.firstObject];
  XCTAssertEqual(numberOfItems - 1, self.requestQueue.requests.count, @"We couldn't remove a ReplayRequest from the queue");
}

- (void)testQueueOrdering{
  ReplayRequest* lastRequest;
  for(ReplayRequest* request in self.requestQueue.requests){
    if(!lastRequest){
      continue;
    }
    
    XCTAssertEqual(NSOrderedAscending, [lastRequest compare:request], @"Our queue isn't ordered by NSOrderedAscending");
  }
}



- (void)testQueueDeserialization{
  XCTAssertEqual(self.requestQueue.requests.count, numberOfItems, @"We didn't fully deserialize the queue");
}

- (void)testQueueSerialization{
  self.requestQueue = [[self class] testQueueOfSize:numberOfItems];
  XCTAssertNoThrow([self.requestQueue serializedQueue], @"We couldn't serialize a queue without throwing an exeption");
}

// TODO: figure out how to test the networking/async stuff

#pragma mark - Helpers

- (void)fakeSelector:(NSTimer*)timer {
  NSLog(@"Fake timer triggered");
}

+ (ReplayRequestQueue*)testQueueOfSize:(NSUInteger)size{
  ReplayRequestQueue* testQueue = [[ReplayRequestQueue alloc] init];
  
  for (int i = 0; i < size; i++) {
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"www.test-%i.com", size]];
    NSURLRequest* request = [NSURLRequest requestWithURL:url];
    [testQueue addRequest:[ReplayRequest requestWithURLRequest:request]];
  }
  return testQueue;
}

+ (void)populateNSUserDefaultsWithTestQueueOfSize:(NSUInteger)size {
  ReplayRequestQueue* testQueue = [self testQueueOfSize:size];
  NSData* testData = [testQueue serializedQueue];
  
  [[NSUserDefaults standardUserDefaults] setObject:testData forKey:REPLAY_PLIST_KEY];
  [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSURLRequest*)sampleRequest{
  NSURL* URL = [NSURL URLWithString:@"www.example.com"];
  return [NSURLRequest requestWithURL:URL];
}

- (ReplayRequestQueue*)existingReplayQueue{
  NSData* testData = [[NSUserDefaults standardUserDefaults] objectForKey:REPLAY_PLIST_KEY];
  return [ReplayRequestQueue requestQueueWithData:testData];
}

@end
