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
                                                      error:&error]; // NOTE: no error handling
  return jsonData;
}

+ (NSURL *)urlWithPath:(NSString *)path {
  return [NSURL URLWithString:path relativeToURL:[NSURL URLWithString:REPLAY_URL]];
}


#pragma mark - Endpoint payload definitions
// NOTE: this doesn't return json, why not call this dictionaryForEvent:distinctId:properties: also Id should be capitalized (i.e. ID)
- (NSDictionary *)jsonForEvent:(NSString *)eventName
                    distinctId:(NSString *)distinctId
                    properties:(NSDictionary *)properties
{
  NSMutableDictionary* propertiesJson = [@{} mutableCopy];
  
  NSDictionary* json =
    @{kReplayKey   : self.apiKey,
      kClientId    : self.clientUUID,
      kSessionId   : self.sessionUUID,
      kDistinctId  : distinctId ?: @"",
      kProperties  : properties,
      @"event_name": eventName};

  // add the key-value pairs to the dictionary under json[properties]
  for (id key in properties) {
    [propertiesJson setObject:properties[key] forKey:key]; // NOTE: what does this do? We're mutating a dictionary that immediately goes out of scope
  }
  
  // NOTE: the above can be done with [propertiesJson addEntriesFromDictionary:properties]

  
  return json;
}

- (NSDictionary *)jsonForTraitsWithDistinctId:(NSString *)distinctId
                                   properties:(NSDictionary *)properties
{
  NSMutableDictionary* propertiesJson = [@{} mutableCopy];
  
  NSDictionary* json =
    @{kReplayKey : self.apiKey,
      kClientId  : self.clientUUID,
      kSessionId : self.sessionUUID,
      kDistinctId: distinctId ?: @"",
      kProperties: properties};
  
  // add the key-value pairs to the dictionary under json[properties]
  for (id key in properties) {
    [propertiesJson setObject:properties[key] forKey:key]; // NOTE: still not sure what this is doing?
  }
  
  return json;
}


@end
