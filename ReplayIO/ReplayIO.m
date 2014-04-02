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

SYNTHESIZE_SINGLETON(ReplayIO, sharedTracker);


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
                               completionHandler:^(id json, NSError* error) {
                                 DEBUG_LOG(@"%@", error ?: json);
                               }];
}

- (void)trackEvent:(NSDictionary *)eventProperties {

  [[ReplayAPIManager sharedManager] callEndpoint:@"Events"
                                        withData:eventProperties
                               completionHandler:^(id json, NSError* error) {
                                  DEBUG_LOG(@"%@", error ?: json);
                               }];
}


@end
