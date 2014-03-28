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

+ (void)trackEvent:(NSDictionary *)eventProperties {
  [[ReplayIO sharedTracker] trackEvent:eventProperties];
}

- (void)trackEvent:(NSDictionary *)eventProperties {
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
                             NSLog(@"response = %@", response);
                             NSLog(@"data = %@", data);
                             NSLog(@"error = %@", error);
                           }];
  }
}

@end





/*
 

[ReplayIO trackWithAPIKey:@"......"];
[ReplayIO trackEvent:@{}];
 
 
*/