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

static NSString* serverURL = @"http://api.replay.io";
static NSString* eventsURL = @"http://api.replay.io/events";


#define DEBUG_LOG(fmt, ...) do { \
if(self.debugMode) \
NSLog(@"[Replay.IO] " fmt, ## __VA_ARGS__); \
} while(0)


@implementation ReplayIO

+ (ReplayIO*)sharedTracker {
  static ReplayIO* sharedInstance = nil;
  static dispatch_once_t onceToken;
  
  dispatch_once(&onceToken, ^{
    sharedInstance = [[ReplayIO alloc] init];
  });
  return sharedInstance;
}

// user-facing convenience class methods

+ (void)trackWithAPIKey:(NSString *)apiKey {
  [[ReplayIO sharedTracker] trackWithAPIKey:apiKey];
}

+ (void)setUserAlias:(NSString *)userAlias {
  [[ReplayIO sharedTracker] setUserAlias:userAlias];
}

+ (void)trackEvent:(NSDictionary *)eventProperties {
  [[ReplayIO sharedTracker] trackEvent:eventProperties];
}

+ (void)setDebugMode:(BOOL)debugMode {
  [[ReplayIO sharedTracker] setDebugMode:debugMode];
}

// underlying instance methods

- (void)trackWithAPIKey:(NSString *)apiKey {
  self.apiKey = apiKey;
  
  DEBUG_LOG(@"Tracking with API Key: %@", apiKey);
}

- (void)setUserAlias:(NSString *)userAlias {
  self.userAlias = userAlias;
  
  DEBUG_LOG(@"Set user alias: %@", userAlias);
}

- (void)trackEvent:(NSDictionary *)eventProperties {
  if (!self.apiKey) {
    DEBUG_LOG(@"No API key provided");
    return;
  }
  
  NSURL* url = [NSURL URLWithString:eventsURL];
  
  NSError* error = nil;
  NSData* eventJSON = [NSJSONSerialization dataWithJSONObject:eventProperties options:NSJSONWritingPrettyPrinted error:&error];
  
  if (!error) {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:eventJSON];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                             
                             DEBUG_LOG(@"response = %@", response);
                             DEBUG_LOG(@"data     = %@", data);
                             DEBUG_LOG(@"error    = %@", error);
                           }];
  }
  else {
    DEBUG_LOG(@"Track event error: %@", error);
  }
}


@end
