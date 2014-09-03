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
#import "ReplayRequestQueue.h"
#import "ReplayRequest.h"
#import "Reachability.h"


static NSString* const REPLAY_PLIST_KEY = @"ReplayIO.savedRequestQueue";

@interface ReplayIO ()

@property (nonatomic) BOOL enabled;
@property (nonatomic, readwrite, assign) BOOL paused;
@property (nonatomic, strong) ReplayAPIManager* replayAPIManager;
@property (nonatomic, strong) ReplayRequestQueue* replayQueue;
@property (nonatomic, strong, readwrite) NSOperationQueue* replayOperationQueue;
@property (nonatomic, strong, readwrite) NSOperationQueue* persistenceOperationQueue;
@property (nonatomic, strong, readwrite) NSMutableDictionary* pendingReplayRequests;
@property (nonatomic, strong, readwrite) Reachability* reachability;

@end

@implementation ReplayIO

+ (ReplayIO *)sharedTracker {
  static ReplayIO* sharedTracker = nil;
  static dispatch_once_t onceToken;          

  dispatch_once(&onceToken, ^{               
    sharedTracker = [[ReplayIO alloc] init];
    [sharedTracker loadPendingEventsFromDisk];
  });
  
  return sharedTracker;
}


- (instancetype)init {
  self = [super init];
  if (self) {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
    self.enabled = YES;
    self.replayAPIManager = [[ReplayAPIManager alloc] init];
    self.replayQueue = [[ReplayRequestQueue alloc] init];
    self.reachability = [[Reachability alloc] init];
    [self.reachability startNotifier];
    self.replayOperationQueue = [[NSOperationQueue alloc] init];
    self.persistenceOperationQueue = [[NSOperationQueue alloc] init];
  }
  return self;
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setPaused:(BOOL)paused {
  if(_paused != paused){
    _paused = paused;
    if(_paused) {
      self.replayOperationQueue.suspended = YES;
    }else{
      self.replayOperationQueue.suspended = !self.enabled;
    }
  }
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
}

+ (void)applicationWillEnterForeground:(NSNotification *)notification {
  [[ReplayIO sharedTracker].replayAPIManager updateSessionUUID:[ReplaySessionManager sessionUUID]];
}


#pragma mark - Convenience class methods

+ (void)trackWithAPIKey:(NSString *)apiKey {
  [[ReplayIO sharedTracker] trackWithAPIKey:apiKey];
}

+ (void)updateTraitsWithDistinctId:(NSString *)distinctId
                        properties:(NSDictionary *)properties {
  [[ReplayIO sharedTracker] updateTraitsWithDistinctId:distinctId
                                            properties:properties];
}

+ (void)trackEvent:(NSString *)eventName
        distinctId:(NSString *)distinctId
        properties:(NSDictionary *)properties {
  [[ReplayIO sharedTracker] trackEvent:eventName distinctId:distinctId properties:properties];
}

+ (void)setDebugMode:(BOOL)debugMode {
  [[ReplayIO sharedTracker] setDebugMode:debugMode];
}

+ (void)enable {
  DEBUG_LOG(@"Tracking = ON");
  [ReplayIO sharedTracker].enabled = YES;
  
  if(![ReplayIO sharedTracker].paused){
   [ReplayIO sharedTracker].replayOperationQueue.suspended = NO;
  }
}

+ (void)disable {
  DEBUG_LOG(@"Tracking = OFF");
  [ReplayIO sharedTracker].enabled = NO;
  [ReplayIO sharedTracker].replayOperationQueue.suspended = YES;
}

+ (NSOperation*)networkOperationForRequest:(NSURLRequest*)request completion:(void(^)(NSURLResponse* response, NSError* error))completion{
  return [NSBlockOperation blockOperationWithBlock:^{
    NSURLResponse* response;
    NSError* error;
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if(completion){
      [[NSOperationQueue mainQueue] addOperationWithBlock:^{
          completion(response, error);
      }];
    }
  }];
}


#pragma mark - Underlying instance methods

- (void)trackWithAPIKey:(NSString *)apiKey{
  [self.replayAPIManager setAPIKey:apiKey
                         clientUUID:[[[UIDevice currentDevice] identifierForVendor] UUIDString]
                         sessionUUID:[ReplaySessionManager sessionUUID]];
}

- (void)updateTraitsWithDistinctId:(NSString *)distinctId
                        properties:(NSDictionary *)properties{
  NSURLRequest* URLRequest = [self.replayAPIManager requestForTraitsWithDistinctId:distinctId
                                                                        properties:properties];
  [self addReplayOperationForRequest:[ReplayRequest requestWithURLRequest:URLRequest]];
}

- (void)trackEvent:(NSString *)eventName
        distinctId:(NSString *)distinctId
        properties:(NSDictionary *)properties{
  NSURLRequest* URLRequest = [self.replayAPIManager requestForEvent:eventName
                                                         distinctId:distinctId
                                                         properties:properties];
  [self addReplayOperationForRequest:[ReplayRequest requestWithURLRequest:URLRequest]];
}

- (void)addReplayOperationForRequest:(ReplayRequest*)request{
  [self.replayQueue addRequest:request];
  
  NSOperation* replayNetworkOperation = [[self class] networkOperationForRequest:request.networkRequest completion:^(NSURLResponse *response, NSError *error) {
    if(!error){
      [self.replayQueue removeRequest:request];
    }
  }];
  
  [self.replayOperationQueue addOperation:replayNetworkOperation];
}

- (void)savePendingEventsToDisk{
  self.paused = YES;
  NSData* data = [self.replayQueue serializedQueue];
  if(data){
    [self.persistenceOperationQueue addOperationWithBlock:^{
      [[NSUserDefaults standardUserDefaults] setObject:data forKey:REPLAY_PLIST_KEY];
      [[NSUserDefaults standardUserDefaults] synchronize];
      DEBUG_LOG(@"persisted events to disk");
    }];
  }else{
    self.paused = NO;
  }
}

- (void)loadPendingEventsFromDisk{
  self.paused = YES;
  [self.persistenceOperationQueue addOperationWithBlock:^{
    NSData* data = [[NSUserDefaults standardUserDefaults] objectForKey:REPLAY_PLIST_KEY];
    if(data){
      DEBUG_LOG(@"found existing queue of Replay events");
    }
    
    ReplayRequestQueue* existingQueue = [ReplayRequestQueue requestQueueWithData:data];
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
      self.replayQueue = existingQueue;
      self.paused = NO;
    }];
  }];
}

- (void)reachabilityChanged:(NSNotification*)notification{
  if(self.reachability.isReachable){
    DEBUG_LOG(@"network is reachable");

    for(ReplayRequest* request in self.replayQueue.requests){
      [self addReplayOperationForRequest:request];
    }
  }else{
    DEBUG_LOG(@"network unreachable");
  }
}

@end
