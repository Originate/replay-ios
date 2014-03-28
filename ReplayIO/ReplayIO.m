//
//  ReplayIO.m
//  ReplayIO
//
//  Created by Allen Wu on 3/28/14.
//  Copyright (c) 2014 Originate. All rights reserved.
//

#import "ReplayIO.h"

@interface ReplayIO ()
@property (readwrite, nonatomic, strong) NSString* apiKey;
@property (readwrite, nonatomic, strong) NSString* userAlias;
@end

static const NSString* serverURL = @"http://api.replay.io";

@implementation ReplayIO

+ (ReplayIO*)sharedTracker {
  static ReplayIO* sharedInstance = nil;
  static dispatch_once_t onceToken;

  dispatch_once(&onceToken, ^{
    sharedInstance = [[ReplayIO alloc] init];
  });
  return sharedInstance;
}

+ (void)trackWithAPIKey:(NSString *)apiKey {
  [ReplayIO sharedTracker].apiKey = apiKey;
}

+ (void)setUserAlias:(NSString *)userAlias {
  [ReplayIO sharedTracker].userAlias = userAlias;
}

+ (void)trackEvent:(NSDictionary *)properties {

}


@end

/*
 

[ReplayIO trackWithAPIKey:@"......"];
[ReplayIO trackEvent:@{}];
 
 
*/