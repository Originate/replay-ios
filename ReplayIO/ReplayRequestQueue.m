//
//  ReplayQueue.m
//  ReplayIO
//
//  Created by Allen Wu on 4/7/14.
//  Copyright (c) 2014 Originate. All rights reserved.
//

#import "ReplayRequestQueue.h"
#import "ReplayRequest.h"
#import "ReplayConfig.h"

@interface ReplayRequestQueue ()

@property (nonatomic, readwrite, strong) NSMutableSet* requestSet;

@end


@implementation ReplayRequestQueue

+ (instancetype)requestQueueWithData:(NSData *)data{
  ReplayRequestQueue* requestQueue = [[self alloc] init];
  requestQueue.requestSet = [requestQueue validatedQueueWithData:data];
  return requestQueue;
}

- (instancetype)init{
  if(self = [super init]){
    self.requestSet = [NSMutableSet set];
  }
  return self;
}

- (NSArray*)requests{
  return [self.requestSet.allObjects sortedArrayUsingSelector:@selector(compare:)];
}

- (void)addRequest:(ReplayRequest*)request{
  [self.requestSet addObject:request];
}

- (void)addRequests:(NSArray*)requests{
  [self.requestSet addObjectsFromArray:requests];
}

- (void)removeRequest:(ReplayRequest*)request{
  [self.requestSet removeObject:request];
}

- (void)mergeWithRequestQueue:(ReplayRequestQueue*)requestQueue{
  [self.requestSet addObjectsFromArray:requestQueue.requests];
}

- (void)clearQueue{
  [self.requestSet removeAllObjects];
}

- (NSData*)serializedQueue{
  return [NSKeyedArchiver archivedDataWithRootObject:self.requestSet];
}

#pragma mark - Private Interface

- (NSMutableSet *)validatedQueueWithData:(NSData *)data {
  NSSet* queue = [NSSet set];
  
  if (data) {
    @try {
      queue = [NSKeyedUnarchiver unarchiveObjectWithData:data];
      
      // enforce correct data structure
      if (![queue isKindOfClass:[NSSet class]]) {
        return [NSMutableSet set];
      } else {  // enforce correct types in the array (NSURLRequest)
        for (id item in queue.allObjects) {
          if (![item isKindOfClass:[ReplayRequest class]]) {
            return [NSMutableSet set];
          }
        }
      }
    }
    @catch (NSException* exception) {
      queue = nil;
    }
  }
  
  return queue.mutableCopy;
}

@end
