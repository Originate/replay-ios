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
#import "ReplaySessionManager.h"

@implementation ReplayIO

SYNTHESIZE_SINGLETON(ReplayIO, sharedTracker);


#pragma mark - Framework initialization

// listen to app notifications
// http://tech.radialpoint.com/2014/02/13/ios-frameworks-initializing-yourself-in-0-lines-of-code/
+ (void)load {
  @autoreleasepool {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidEnterBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillEnterForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
  }
}

+ (void)applicationDidEnterBackground:(NSNotification *)notification {
  [ReplaySessionManager endSession];
}

+ (void)applicationWillEnterForeground:(NSNotification *)notification {
  [[ReplayAPIManager sharedManager] updateSessionUUID:[ReplaySessionManager sessionUUID]];
}


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
                                   clientUUID:[[[UIDevice currentDevice] identifierForVendor] UUIDString]
                                  sessionUUID:[ReplaySessionManager sessionUUID]];
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
