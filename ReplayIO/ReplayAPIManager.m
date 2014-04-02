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

SYNTHESIZE_SINGLETON(ReplayAPIManager, sharedManager);


- (void)setAPIKey:(NSString *)apiKey
       clientUUID:(NSString *)clientUUID
      sessionUUID:(NSString *)sessionUUID
{
  self.apiKey   = apiKey;
  self.clientUUID = clientUUID;
  self.sessionUUID = sessionUUID;
  
  DEBUG_LOG(@"Tracking with\n  { API Key:      %@,\n    Client UUID:  %@,\n    Session UUID: %@ }", apiKey, clientUUID, sessionUUID);
}


#pragma mark - Public methods

- (void)callEndpoint:(NSString *)endpointName
            withData:(id)data
   completionHandler:(void (^)(id json, NSError* error)) handler
{
  
  ReplayEndpoint* endpoint = [[ReplayEndpoint alloc] initWithEndpointName:endpointName data:data];
  [endpoint callWithCompletionHandler:^(id json, NSError* error) {
    handler(json, error);
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
