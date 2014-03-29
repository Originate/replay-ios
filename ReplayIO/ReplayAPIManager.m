//
//  ReplayAPIManager.m
//  ReplayIO
//
//  Created by Allen Wu on 3/28/14.
//  Copyright (c) 2014 Originate. All rights reserved.
//

#import "ReplayAPIManager.h"


@implementation ReplayAPIManager

+ (ReplayAPIManager *)sharedManager {
  static ReplayAPIManager* sharedInstance = nil;
  static dispatch_once_t onceToken;
  
  dispatch_once(&onceToken, ^{
    sharedInstance = [[ReplayAPIManager alloc] init];
  });
  return sharedInstance;
}

- (id)init {
  self = [super init];
  if (self) {
    NSString* configPlistPath = [[NSBundle mainBundle] pathForResource:@"Config" ofType:@"plist"];
    self.configPlist = [[NSDictionary alloc] initWithContentsOfFile:configPlistPath];
  }
  return self;
}

- (void)setAPIKey:(NSString *)apiKey
       clientUUID:(NSString *)clientUUID
      sessionUUID:(NSString *)sessionUUID {
  self.apiKey   = apiKey;
  self.clientUUID = clientUUID;
  self.sessionUUID = sessionUUID;
  
}


#pragma mark - NSURLConnection helpers

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


#pragma mark - Endpoint methods

- (void)callEndpoint:(NSString *)endpoint
            withData:(id)data
   completionHandler:(void (^)(NSURLResponse* response, NSData* data, NSError* connectionError)) handler
{
  NSData* jsonData = [self jsonDataForEndpoint:endpoint data:data];
  NSURL* url = [self urlForEndpoint:endpoint];
  NSString* httpMethod = [self httpMethodForEndpoint:endpoint];
  
  NSLog(@"data to be sent = %@", data);
  NSLog(@"url = %@", url);
  NSLog(@"httpMethod = %@", httpMethod);
  
  [ReplayAPIManager sendJSONRequestToURL:url
                              httpMethod:httpMethod
                                httpBody:jsonData
                       completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                         handler(response, data, connectionError);
                       }];
}

#pragma mark - Get JSON

- (NSData *)jsonDataForEndpoint:(NSString *)endpoint data:(id)data {
  NSDictionary* endpointDefinition = [self.configPlist[@"Endpoints"] valueForKey:endpoint];
  
  NSLog(@"endpointDefinition = %@", endpointDefinition);
  
  if (endpointDefinition) {
    NSMutableDictionary* json = [endpointDefinition[@"JSON"] copy];
    [json enumerateKeysAndObjectsUsingBlock:^(id key, id val, BOOL *stop) {
      if (val) {
        val = data;
      }
      else {
        NSString* localKey = [ReplayAPIManager mapLocalKeyFromServerKey:key];
        NSString* localVal = [self valueForKey:localKey];
        
        val = localVal;
      }
    }];
    
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
  else {
    NSAssert(@"Unable to create JSON object for endpoint: \"%@\"", endpoint);
    return nil;
  }
}

- (NSURL *)urlForEndpoint:(NSString *)endpoint {
  NSDictionary* endpointDefinition = [self.configPlist[@"Endpoints"] valueForKey:endpoint];
  NSString* baseURL = self.configPlist[@"Production URL"];
  return [NSURL URLWithString:[baseURL stringByAppendingString:endpointDefinition[@"Path"]]];
}

- (NSString *)httpMethodForEndpoint:(NSString *)endpoint {
  NSDictionary* endpointDefinition = [self.configPlist[@"Endpoints"] valueForKey:endpoint];
  return endpointDefinition[@"HTTP Method"];
}

+ (NSString *)mapLocalKeyFromServerKey:(NSString *)serverKey {
  NSDictionary* mapping = @{@"replayKey" : @"apiKey",
                            @"clientId"  : @"clientUUID",
                            @"sessionId" : @"sessionUUID"};
  return mapping[serverKey];
}


@end
