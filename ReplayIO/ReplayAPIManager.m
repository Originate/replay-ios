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
      sessionUUID:(NSString *)sessionUUID {
  self.apiKey   = apiKey;
  self.clientUUID = clientUUID;
  self.sessionUUID = sessionUUID;
  
  DEBUG_LOG(@"Tracking with {API Key: %@, Client UUID: %@, Session UUID: %@}", apiKey, clientUUID, sessionUUID);
}


#pragma mark - Public methods

- (void)callEndpoint:(NSString *)endpoint
            withData:(id)data
   completionHandler:(void (^)(NSURLResponse* response, NSData* data, NSError* connectionError)) handler
{
  
  if (![ReplayAPIManager sharedManager].apiKey) {
    DEBUG_LOG(@"No API key provided");
    return;
  }
  
  DEBUG_LOG(@"Calling \"%@\" with object %@", endpoint, data);
  
  NSData* jsonData     = [self jsonDataForEndpoint:endpoint data:data];
  NSURL* url           = [self urlForEndpoint:endpoint];
  NSString* httpMethod = [self httpMethodForEndpoint:endpoint];
  
  [ReplayAPIManager sendJSONRequestToURL:url
                              httpMethod:httpMethod
                                httpBody:jsonData
                       completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                         handler(response, data, connectionError);
                       }];
}


#pragma mark - Endpoint helper methods

- (NSData *)jsonDataForEndpoint:(NSString *)endpoint data:(id)data {
  NSDictionary* endpointDefinition = [ReplayConfig endpointDefinition:endpoint];
  
  NSMutableDictionary* json = [endpointDefinition[kJSON] mutableCopy];
  
  for (NSString* key in json.allKeys) {
    if ([json[key] isEqualToString:kContent]) {
      json[key] = data;
    }
    else {
      NSString* localKey = [ReplayAPIManager mapLocalKeyFromServerKey:key];
      NSString* localVal = [self valueForKey:localKey];
      
      json[key] = localVal;
    }
  }
  
  NSError* error = nil;
  NSData* jsonData = [NSJSONSerialization dataWithJSONObject:json
                                                     options:NSJSONWritingPrettyPrinted
                                                       error:&error];
  
  if (error) {
    // something went wrong
    NSLog(@"something went wrong");
  }
  
  return jsonData;

}

- (NSURL *)urlForEndpoint:(NSString *)endpoint {
  NSDictionary* endpointDefinition = [ReplayConfig endpointDefinition:endpoint];
  NSURL* baseURL = [NSURL URLWithString:[ReplayConfig productionURL]];
  return [baseURL URLByAppendingPathComponent:endpointDefinition[kPath]];
}

- (NSString *)httpMethodForEndpoint:(NSString *)endpoint {
  return [ReplayConfig endpointDefinition:endpoint][kMethod];
}


#pragma mark - NSURLConnection helper methods

+ (void)sendJSONRequestToURL:(NSURL *)url
                  httpMethod:(NSString *)httpMethod
                    httpBody:(NSData *)httpBody
           completionHandler:(void (^)(NSURLResponse* response, NSData* data, NSError* connectionError)) handler
{
  NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
  [request setHTTPMethod:httpMethod];
  [request setHTTPBody:httpBody];
  [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
  [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
  
  [NSURLConnection sendAsynchronousRequest:request
                                     queue:[NSOperationQueue mainQueue]
                         completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                           handler(response, data, error);
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
