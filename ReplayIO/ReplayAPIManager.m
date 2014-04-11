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
  
  DEBUG_LOG(@"Tracking with\n  { API Key:      %@,\n    Client UUID:  %@,\n    Session UUID: %@ }", apiKey, clientUUID, sessionUUID);
}

- (void)updateSessionUUID:(NSString *)sessionUUID {
  self.sessionUUID = sessionUUID;
  
  DEBUG_LOG(@"Session UUID: %@", sessionUUID);
}


#pragma mark - Public methods

- (NSURLRequest *)requestForEvent:(NSString *)eventName withData:(NSDictionary *)data {
  NSDictionary* json = [self jsonForEvent:eventName withData:data];
  return [ReplayAPIManager postRequestTo:@"events" withBody:json];
}

- (NSURLRequest *)requestForAlias:(NSString *)alias {
  NSDictionary* json = [self jsonForAlias:alias];
  return [ReplayAPIManager postRequestTo:@"aliases" withBody:json];
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

- (NSDictionary *)jsonForEvent:(NSString *)eventName withData:(NSDictionary *)data {
  NSMutableDictionary* dataJson =
    [@{@"event": eventName} mutableCopy];
  
  NSDictionary* json =
    @{kReplayKey: self.apiKey,
      kClientId : self.clientUUID,
      kSessionId: self.sessionUUID,
      kData     : dataJson};

  // add the key-value pairs to the dictionary under json[data]
  for (id key in data) {
    if ([key respondsToSelector:@selector(isEqualToString:)] && ![key isEqualToString:@"event"]) {
      [dataJson setObject:data[key] forKey:key];
    }
  }
  
  return json;
}

- (NSDictionary *)jsonForAlias:(NSString *)alias {
  NSDictionary* json =
    @{kReplayKey: self.apiKey,
      kClientId : self.clientUUID,
      @"alias"  : alias};
  
  return json;
}


@end
