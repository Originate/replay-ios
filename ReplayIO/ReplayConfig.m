//
//  ReplayConfig.m
//  ReplayIO
//
//  Created by Allen Wu on 3/30/14.
//  Copyright (c) 2014 Originate. All rights reserved.
//

#import "ReplayConfig.h"

@interface ReplayConfig ()
@property (nonatomic, strong, readwrite) NSDictionary* urls;
@property (nonatomic, strong, readwrite) NSDictionary* endpoints;
@end

@implementation ReplayConfig

+ (ReplayConfig *)sharedInstance {
  static ReplayConfig* sharedInstance = nil;
  static dispatch_once_t onceToken;
  
  dispatch_once(&onceToken, ^{
    sharedInstance = [[ReplayConfig alloc] init];
  });
  return sharedInstance;
}

- (id)init {
  self = [super self];
  if (self) {
    
    self.urls =
      @{@"Development": @"http://api.replay.io/",
        @"Staging"    : @"http://api.replay.io/",
        @"Production" : @"http://api.replay.io/"};
    
    self.endpoints =
      @{@"Events": @{kPath  : @"events",
                     kMethod: @"POST",
                     kJSON  : @{@"data"   : kContent,
                                kReplayKey: @"",
                                kClientId : @"",
                                kSessionId: @""}},
        
        @"Alias": @{kPath  : @"aliases",
                    kMethod: @"POST",
                    kJSON  : @{@"alias"  : kContent,
                               kReplayKey: @"",
                               kClientId : @""}}};
  }
  return self;
}

+ (NSDictionary *)endpointDefinition:(NSString *)endpointKey {
  NSDictionary* endpointDefinition = [ReplayConfig sharedInstance].endpoints[endpointKey];
  NSAssert(endpointDefinition, @"Endpoint \"%@\" not defined!", endpointKey);
  return endpointDefinition;
}

+ (NSString *)productionURL {
  return [ReplayConfig sharedInstance].urls[@"Production"];
}

@end
