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

SYNTHESIZE_SINGLETON(ReplayConfig, sharedInstance)


- (id)init {
  self = [super self];
  if (self) {
    
    //=============================================
    // Store Replay.IO configuration/settings here
    //=============================================
    
    self.urls =
      @{@"Development": @"http://0.0.0.0:3000/",
        @"Staging"    : @"http://0.0.0.0:3000/",
        @"Production" : @"http://0.0.0.0:3000/"};
    
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

+ (NSString *)developmentURL {
  return [ReplayConfig sharedInstance].urls[@"Development"];
}

@end
