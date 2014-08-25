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

// NOTE: no need to wrap this macro in do{}while
// NOTE: further a macro might not be the best idea, no real gain over having the body instead of the macro
#define CONTINUE_IF_REPLAY_IS_ENABLED {           \
  if (![ReplayIO sharedTracker].enabled) { return; } \
}


@interface ReplayIO ()
@property (nonatomic) BOOL enabled;
@property (nonatomic, strong) ReplayAPIManager* replayAPIManager;
@property (nonatomic, strong) ReplayQueue* replayQueue;
@end

@implementation ReplayIO

+ (ReplayIO *)sharedTracker {
  static ReplayIO* sharedTracker = nil;
  static dispatch_once_t onceToken;          

  dispatch_once(&onceToken, ^{               
    sharedTracker = [[ReplayIO alloc] init];
  });                                        
  return sharedTracker;
}


- (instancetype)init {
  self = [super init];
  if (self) {
    self.enabled = YES;
    self.replayAPIManager = [[ReplayAPIManager alloc] init];
    self.replayQueue = [[ReplayQueue alloc] init];
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
  [[ReplayIO sharedTracker].replayQueue saveQueueToDisk];
}

+ (void)applicationWillEnterForeground:(NSNotification *)notification {
  [[ReplayIO sharedTracker].replayAPIManager updateSessionUUID:[ReplaySessionManager sessionUUID]];
  [[ReplayIO sharedTracker].replayQueue loadQueueFromDisk];
}


#pragma mark - Convenience class methods

+ (void)trackWithAPIKey:(NSString *)apiKey {
  [[ReplayIO sharedTracker] trackWithAPIKey:apiKey];
}

+ (void)updateTraitsWithDistinctId:(NSString *)distinctId
                        properties:(NSDictionary *)properties
{
  CONTINUE_IF_REPLAY_IS_ENABLED;
  [[ReplayIO sharedTracker] updateTraitsWithDistinctId:distinctId
                                            properties:properties];
}

+ (void)trackEvent:(NSString *)eventName
        distinctId:(NSString *)distinctId
        properties:(NSDictionary *)properties
{
  CONTINUE_IF_REPLAY_IS_ENABLED;
  [[ReplayIO sharedTracker] trackEvent:eventName distinctId:distinctId properties:properties];
}

+ (void)setDebugMode:(BOOL)debugMode {
  [[ReplayIO sharedTracker] setDebugMode:debugMode];
}

+ (void)enable {
  DEBUG_LOG(@"Tracking = ON");
  [ReplayIO sharedTracker].enabled = YES;
  [[ReplayIO sharedTracker].replayQueue startTimerIfNeeded];
}

+ (void)disable {
  DEBUG_LOG(@"Tracking = OFF");
  [ReplayIO sharedTracker].enabled = NO;
  [[ReplayIO sharedTracker].replayQueue stopTimer];
}

+ (void)setDispatchInterval:(NSInteger)interval {
  [[ReplayIO sharedTracker].replayQueue setDispatchInterval:interval];
}

+ (void)dispatch {
  CONTINUE_IF_REPLAY_IS_ENABLED;
  [[ReplayIO sharedTracker].replayQueue dispatch];
}


#pragma mark - Underlying instance methods

- (void)trackWithAPIKey:(NSString *)apiKey {
  
  [self.replayAPIManager setAPIKey:apiKey
                         clientUUID:[[[UIDevice currentDevice] identifierForVendor] UUIDString]
                         sessionUUID:[ReplaySessionManager sessionUUID]];
}

- (void)updateTraitsWithDistinctId:(NSString *)distinctId
                        properties:(NSDictionary *)properties
{
  NSURLRequest* request = [self.replayAPIManager requestForTraitsWithDistinctId:distinctId
                                                                     properties:properties];
  
  [self.replayQueue enqueue:request];
}

- (void)trackEvent:(NSString *)eventName
        distinctId:(NSString *)distinctId
        properties:(NSDictionary *)properties
{
  NSURLRequest* request = [self.replayAPIManager requestForEvent:eventName
                                                      distinctId:distinctId
                                                      properties:properties];

  [self.replayQueue enqueue:request];
}


@end
