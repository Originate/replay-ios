//
//  ReplayRequest.m
//  ReplayIO
//
//  Created by Aaron Daub on 2014-09-03.
//  Copyright (c) 2014 Originate. All rights reserved.
//

#import "ReplayRequest.h"

static NSString* const ReplayRequestRequestKey = @"requestKey";
static NSString* const ReplayRequestCreateDateKey = @"createDate";

@interface ReplayRequest()

@property (nonatomic, readwrite, copy) NSURLRequest* networkRequest;
@property (nonatomic, readwrite, strong) NSDate* createDate;

@end

@implementation ReplayRequest

+ (instancetype)requestWithURLRequest:(NSURLRequest *)request{
  return [[self alloc] initWithURLRequest:request];
}

- (instancetype)initWithURLRequest:(NSURLRequest *)request{
  return [self initWithURLRequest:request date:[NSDate date]];
}

- (instancetype)initWithURLRequest:(NSURLRequest *)request date:(NSDate*)date{
  if(self = [super init]){
    self.networkRequest = request;
    self.createDate = date;
  }
  return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
  NSURLRequest* request = [aDecoder decodeObjectForKey:ReplayRequestRequestKey];
  NSDate* createDate = [aDecoder decodeObjectForKey:ReplayRequestCreateDateKey];
  return [self initWithURLRequest:request date:createDate];
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
  [aCoder encodeObject:self.networkRequest forKey:ReplayRequestRequestKey];
  [aCoder encodeObject:self.createDate forKey:ReplayRequestCreateDateKey];
}

- (NSComparisonResult)compare:(ReplayRequest *)request{
  return [self.createDate compare:request.createDate];
}

- (NSUInteger)hash{
  return [self.createDate hash];
}

- (BOOL)isEqual:(ReplayRequest*)request{
  return [self.createDate isEqualToDate:request.createDate];
}

- (NSString*)debugDescription{
  return [NSString stringWithFormat:@"(ReplayRequest %p): %@ %@", self, self.createDate, self.networkRequest];
}

@end
