//
//  ReplayAPIManager.m
//  ReplayIO
//
//  Created by Allen Wu on 3/28/14.
//  Copyright (c) 2014 Originate. All rights reserved.
//

#import "ReplayAPIManager.h"
#import "ReplayConfig.h"


@interface ReplayAPIManager ()
@property (nonatomic, strong, readwrite) NSString* apiKey;
@property (nonatomic, strong, readwrite) NSString* clientUUID;
@property (nonatomic, strong, readwrite) NSString* sessionUUID;
@end

@implementation ReplayAPIManager

- (void)setAPIKey:(NSString *)apiKey
       clientUUID:(NSString *)clientUUID
      sessionUUID:(NSString *)sessionUUID
{
  self.apiKey      = apiKey;
  self.clientUUID  = clientUUID;
  self.sessionUUID = sessionUUID;
  
  DEBUG_LOG(@"Tracking with\n  { API Key:      %@,\n    Client UUID:  %@,\n    Session UUID: %@ }\n\n", apiKey, clientUUID, sessionUUID);
}

- (void)updateSessionUUID:(NSString *)sessionUUID {
  self.sessionUUID = sessionUUID;
  
  DEBUG_LOG(@"Session UUID: %@", sessionUUID);
}


#pragma mark - Public methods

- (NSURLRequest *)requestForEvent:(NSString *)eventName
                       distinctId:(NSString *)distinctId
                       properties:(NSDictionary *)properties
{
  NSDictionary* json = [self jsonForEvent:eventName
                               distinctId:distinctId
                               properties:properties];
  
  return [ReplayAPIManager postRequestTo:@"events" withBody:json];
}

- (NSURLRequest *)requestForTraitsWithDistinctId:(NSString *)distinctId
                                      properties:(NSDictionary *)properties
{
  NSDictionary* json = [self jsonForTraitsWithDistinctId:distinctId
                                              properties:properties];
  
  return [ReplayAPIManager postRequestTo:@"traits" withBody:json];
}


#pragma mark - Helper methods

+ (NSURLRequest *)postRequestTo:(NSString *)path withBody:(NSDictionary *)bodyJSON {
  NSURL* url   = [ReplayAPIManager urlWithPath:path];
  NSData* body = [ReplayAPIManager dataForDictionary:bodyJSON];
  
  NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:url];
  [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
  [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
  [request setHTTPMethod:@"POST"];
  [request setHTTPBody:body];
  
  return request;
}

+ (NSData *)dataForDictionary:(NSDictionary *)dictionary {
  if (![NSJSONSerialization isValidJSONObject:dictionary]) {
    return nil;
  }

  NSError* error = nil;
  NSData* jsonData = [NSJSONSerialization dataWithJSONObject:dictionary
                                                    options:0
                                                      error:&error];
  return jsonData;
}

+ (NSURL *)urlWithPath:(NSString *)path {
  return [NSURL URLWithString:path relativeToURL:[NSURL URLWithString:REPLAY_URL]];
}


#pragma mark - Endpoint payload definitions
- (NSDictionary *)jsonForEvent:(NSString *)eventName
                    distinctId:(NSString *)distinctId
                    properties:(NSDictionary *)properties
{
  NSDictionary* json =
    @{kReplayKey: self.apiKey,
      kClientId: self.clientUUID,
      kSessionId: self.sessionUUID,
      kDistinctId: distinctId ?: @"",
      kProperties: properties ?: @{},
      kEventName: eventName ?: @""};


  return json;
}

- (NSDictionary *)jsonForTraitsWithDistinctId:(NSString *)distinctId
                                   properties:(NSDictionary *)properties
{
  NSDictionary* json =
    @{kReplayKey: self.apiKey,
      kClientId: self.clientUUID,
      kSessionId: self.sessionUUID,
      kDistinctId: distinctId ?: @"",
      kProperties: properties ?: @{}};
  
  return json;
}


@end
