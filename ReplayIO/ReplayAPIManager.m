//
//  ReplayAPIManager.m
//  ReplayIO
//
//  Created by Allen Wu on 3/28/14.
//  Copyright (c) 2014 Originate. All rights reserved.
//

#import "ReplayIO.h"
#import "ReplayAPIManager.h"
#import "ReplayConfig.h"
#import "ReplayEndpoint.h"

@implementation ReplayAPIManager

+ (ReplayAPIManager *)sharedManager {
  static ReplayAPIManager* sharedInstance = nil;
  static dispatch_once_t onceToken;
  
  dispatch_once(&onceToken, ^{
    sharedInstance = [[ReplayAPIManager alloc] init];
  });
  return sharedInstance;
}

- (void)setAPIKey:(NSString *)apiKey
       clientUUID:(NSString *)clientUUID
      sessionUUID:(NSString *)sessionUUID
{
  self.apiKey   = apiKey;
  self.clientUUID = clientUUID;
  self.sessionUUID = sessionUUID;
  
  DEBUG_LOG(@"Tracking with {API Key: %@, Client UUID: %@, Session UUID: %@}", apiKey, clientUUID, sessionUUID);
}


#pragma mark - Public methods

- (void)callEndpoint:(NSString *)endpointName
            withData:(id)data
   completionHandler:(void (^)(NSURLResponse* response, NSData* data, NSError* connectionError)) handler
{
  
  if (![ReplayAPIManager sharedManager].apiKey) {
    DEBUG_LOG(@"No API key provided");
    return;
  }
  
  ReplayEndpoint* endpoint = [[ReplayEndpoint alloc] initWithEndpointName:endpointName data:data];
  [endpoint callWithCompletionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
    handler(response, data, connectionError);
  }];
}


#pragma mark -

+ (NSString *)mapLocalKeyFromServerKey:(NSString *)serverKey {
  NSDictionary* mapping = @{kReplayKey: @"apiKey",
                            kClientId : @"clientUUID",
                            kSessionId: @"sessionUUID"};
  return mapping[serverKey];
}

@end
