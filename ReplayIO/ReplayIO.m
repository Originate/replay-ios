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

+ (void)trackEvent:(NSString *)eventName withProperties:(NSDictionary *)eventProperties {
  [[ReplayIO sharedTracker] trackEvent:eventName withProperties:eventProperties];
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
  NSURLRequest* request = [[ReplayAPIManager sharedManager] requestForAlias:userAlias];
  
  // TODO: queue request
  
  [NSURLConnection sendAsynchronousRequest:request
                                     queue:[NSOperationQueue mainQueue]
                         completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
    
                         }];
}

- (void)trackEvent:(NSString *)eventName withProperties:(NSDictionary *)eventProperties {
  NSURLRequest* request = [[ReplayAPIManager sharedManager] requestForEvent:eventName withData:eventProperties];
  
  // TODO: queue request
  
  [NSURLConnection sendAsynchronousRequest:request
                                     queue:[NSOperationQueue mainQueue]
                         completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                           
                         }];
}


@end
