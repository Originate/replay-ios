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
#import "ReplayQueue.h"


#define CONTINUE_IF_REPLAY_IS_ENABLED do {           \
  if (![ReplayIO sharedTracker].enabled) { return; } \
} while(0)


@interface ReplayIO ()
@property (nonatomic, setter = isEnabled:) BOOL enabled;
@end

@implementation ReplayIO

SYNTHESIZE_SINGLETON(ReplayIO, sharedTracker);

- (instancetype)init {
  self = [super init];
  if (self) {
    self.enabled = YES;
  }
  return self;
}


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
  [[ReplayQueue sharedQueue] saveQueueToDisk];
}

+ (void)applicationWillEnterForeground:(NSNotification *)notification {
  [[ReplayAPIManager sharedManager] updateSessionUUID:[ReplaySessionManager sessionUUID]];
  [[ReplayQueue sharedQueue] loadQueueFromDisk];
}


#pragma mark - Convenience class methods

+ (void)trackWithAPIKey:(NSString *)apiKey {
  [[ReplayIO sharedTracker] trackWithAPIKey:apiKey];
}

+ (void)updateAlias:(NSString *)userAlias {
  CONTINUE_IF_REPLAY_IS_ENABLED;
  [[ReplayIO sharedTracker] updateAlias:userAlias];
}

+ (void)trackEvent:(NSString *)eventName withProperties:(NSDictionary *)eventProperties {
  CONTINUE_IF_REPLAY_IS_ENABLED;
  [[ReplayIO sharedTracker] trackEvent:eventName withProperties:eventProperties];
}

+ (void)setDebugMode:(BOOL)debugMode {
  [[ReplayIO sharedTracker] setDebugMode:debugMode];
}

+ (void)enable {
  [ReplayIO sharedTracker].enabled = YES;
  [[ReplayQueue sharedQueue] startTimer];
}

+ (void)disable {
  [ReplayIO sharedTracker].enabled = NO;
  [[ReplayQueue sharedQueue] stopTimer];
}

+ (void)setDispatchInterval:(NSInteger)interval {
  CONTINUE_IF_REPLAY_IS_ENABLED;
  [[ReplayQueue sharedQueue] setDispatchInterval:interval];
}

+ (void)dispatch {
  CONTINUE_IF_REPLAY_IS_ENABLED;
  [[ReplayQueue sharedQueue] dispatch];
}


#pragma mark - Underlying instance methods

- (void)trackWithAPIKey:(NSString *)apiKey {
  
  [[ReplayAPIManager sharedManager] setAPIKey:apiKey
                                   clientUUID:[[[UIDevice currentDevice] identifierForVendor] UUIDString]
                                  sessionUUID:[ReplaySessionManager sessionUUID]];
}

- (void)updateAlias:(NSString *)userAlias {
  NSURLRequest* request = [[ReplayAPIManager sharedManager] requestForAlias:userAlias];
  
  [[ReplayQueue sharedQueue] enqueue:request];
}

- (void)trackEvent:(NSString *)eventName withProperties:(NSDictionary *)eventProperties {
  NSURLRequest* request = [[ReplayAPIManager sharedManager] requestForEvent:eventName withData:eventProperties];

  [[ReplayQueue sharedQueue] enqueue:request];
}


@end
