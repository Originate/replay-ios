//
//  ReplayIO.m
//  ReplayIO
//
//  Created by Allen Wu on 3/28/14.
//  Copyright (c) 2014 Originate. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ReplayIO.h"
#import "ReplayAPIManager.h"


@implementation ReplayIO

+ (ReplayIO*)sharedTracker {
  static ReplayIO* sharedInstance = nil;
  static dispatch_once_t onceToken;
  
  dispatch_once(&onceToken, ^{
    sharedInstance = [[ReplayIO alloc] init];
  });
  return sharedInstance;
}


#pragma mark - Convenience class methods

+ (void)trackWithAPIKey:(NSString *)apiKey {
  [[ReplayIO sharedTracker] trackWithAPIKey:apiKey];
}

+ (void)updateUserAlias:(NSString *)userAlias {
  [[ReplayIO sharedTracker] updateUserAlias:userAlias];
}

+ (void)trackEvent:(NSDictionary *)eventProperties {
  [[ReplayIO sharedTracker] trackEvent:eventProperties];
}

+ (void)setDebugMode:(BOOL)debugMode {
  [[ReplayIO sharedTracker] setDebugMode:debugMode];
}


#pragma mark - Underlying instance methods

- (void)trackWithAPIKey:(NSString *)apiKey {
  
  [[ReplayAPIManager sharedManager] setAPIKey:apiKey
                                   clientUUID:[[[UIDevice currentDevice] identifierForVendor ] UUIDString]
                                  sessionUUID:@"sessionID"];
}

- (void)updateUserAlias:(NSString *)userAlias {
  
  [[ReplayAPIManager sharedManager] callEndpoint:@"Alias"
                                        withData:userAlias
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                                 DEBUG_LOG(@"Updated user alais");
                               }];
}

- (void)trackEvent:(NSDictionary *)eventProperties {

  [[ReplayAPIManager sharedManager] callEndpoint:@"Events"
                                        withData:eventProperties
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                                 DEBUG_LOG(@"Tracked event");
                               }];
}


@end
