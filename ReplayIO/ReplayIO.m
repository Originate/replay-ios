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
#import "ReplayPersistenceController.h"


static NSString* const REPLAY_PLIST_KEY = @"ReplayIO.savedRequestQueue";

@interface ReplayIO ()

@property (nonatomic, readwrite, assign, getter = isEnabled) BOOL enabled;
@property (nonatomic, readwrite, assign, getter = isPaused) BOOL paused;
@property (nonatomic, strong) ReplayAPIManager* replayAPIManager;
@property (nonatomic, strong) ReplayRequestQueue* requestQueue;
@property (nonatomic, strong, readwrite) NSOperationQueue* networkOperationQueue;
@property (nonatomic, strong, readwrite) NSOperationQueue* persistenceOperationQueue;
@property (nonatomic, strong, readwrite) NSMutableDictionary* pendingReplayRequests;
@property (nonatomic, strong, readwrite) Reachability* reachability;

@end

@implementation ReplayIO

#pragma mark - Public Interface

#pragma mark - Lifecycle

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
    self.requestQueue = [[ReplayRequestQueue alloc] init];
    self.reachability = [Reachability reachabilityForInternetConnection];
    [self.reachability startNotifier];
    self.networkOperationQueue = [[NSOperationQueue alloc] init];
    self.persistenceOperationQueue = [[NSOperationQueue alloc] init];
  }
  return self;
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Event Tracking


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

#pragma mark - Tracker State

- (void)trackWithAPIKey:(NSString *)apiKey{
  [self.replayAPIManager setAPIKey:apiKey
                        clientUUID:[[[UIDevice currentDevice] identifierForVendor] UUIDString]
                       sessionUUID:[ReplaySessionManager sessionUUID]];
}

- (void)enable {
  DEBUG_LOG(@"Tracking = ON");
  self.enabled = YES;
  
  if(!self.isPaused){
    self.networkOperationQueue.suspended = NO;
  }
}

- (void)disable {
  DEBUG_LOG(@"Tracking = OFF");
  self.enabled = NO;
  self.networkOperationQueue.suspended = YES;
}

#pragma mark - Private Interface

- (void)setPaused:(BOOL)paused {
  if(_paused != paused){
    _paused = paused;
    if(_paused) {
      [self pause];
    }else{
      [self unpause];
    }
  }
}

- (void)addReplayOperationForRequest:(ReplayRequest*)request{
  if(!self.reachability.isReachable){ // Only queue requests if we're not reachable
    [self queueReplayRequest:request];
    return;
  }
  
  NSOperation* replayNetworkOperation = [self networkOperationForRequest:request.networkRequest completion:^(NSURLResponse *response, NSError *error) {
    if(!error){
      [self.requestQueue removeRequest:request];
     [[ReplayPersistenceController sharedPersistenceController] removeRequest:request];
    }
  }];
  
  [self.networkOperationQueue addOperation:replayNetworkOperation];
}

- (void)queueReplayRequest:(ReplayRequest*)request{
  [self.requestQueue addRequest:request];
  [[ReplayPersistenceController sharedPersistenceController] persistRequest:request onCompletion:nil];
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

#pragma mark - Network 

- (void)pause{
  self.networkOperationQueue.suspended = YES;
}

- (void)unpause{
  self.networkOperationQueue.suspended = !self.isEnabled;
}

- (NSOperation*)networkOperationForRequest:(NSURLRequest*)request completion:(void(^)(NSURLResponse* response, NSError* error))completion{
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

- (void)loadPendingEventsFromDisk{
  self.paused = YES;
  [[ReplayPersistenceController sharedPersistenceController] fetchAllRequests:^(NSArray *replayRequests) {
    [self.requestQueue addRequests:replayRequests];
    self.paused = NO;
  }];
}

- (void)reachabilityChanged:(NSNotification*)notification{
  if(self.reachability.isReachable){
    DEBUG_LOG(@"Network is reachable");
    
    for(ReplayRequest* request in self.requestQueue.requests){
      [self addReplayOperationForRequest:request];
    }
    
  }else{
    DEBUG_LOG(@"Network is unreachable");
  }
}

@end
