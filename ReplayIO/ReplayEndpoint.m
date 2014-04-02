//
//  ReplayEndpoint.m
//  ReplayIO
//
//  Created by Allen Wu on 3/30/14.
//  Copyright (c) 2014 Originate. All rights reserved.
//

#import "ReplayEndpoint.h"
#import "ReplayIO.h"
#import "ReplayConfig.h"
#import "ReplayAPIManager.h"

@interface ReplayEndpoint ()
@property (nonatomic, strong, readwrite) NSData* jsonData;
@property (nonatomic, strong, readwrite) NSURL* url;
@property (nonatomic, strong, readwrite) NSString* httpMethod;

@property (nonatomic, strong) NSString* endpointName;
@property (nonatomic, strong) id data;
@property (nonatomic, strong) NSDictionary* endpointDefinition;
@end

@implementation ReplayEndpoint

- (instancetype)initWithEndpointName:(NSString *)endpointName data:(id)data {
  self = [super init];
  if (self) {
    // set internal properties
    self.data = data;
    self.endpointName = endpointName;
    self.endpointDefinition = [ReplayConfig endpointDefinition:endpointName];
    
    // set public properties
    if (self.endpointDefinition) {
      self.jsonData   = [self jsonDataForEndpoint];
      self.url        = [self urlForEndpoint];
      self.httpMethod = [self httpMethodForEndpoint];
    }
  }
  return self;
}

- (void)callWithCompletionHandler:(void (^)(id json, NSError* error)) handler {
  if (!(self.jsonData && self.url && self.httpMethod)) {
    NSError* unknownEndpointError = [NSError errorWithDomain:ERROR_DOMAIN_REPLAY_IO code:0 userInfo:nil];
    handler(nil, unknownEndpointError);
  }
  
  DEBUG_LOG(@"Calling \"%@\" with object %@", self.endpointName, self.data);
  
  NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:self.url];
  [request setHTTPMethod:self.httpMethod];
  [request setHTTPBody:self.jsonData];
  [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
  [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];

  [NSURLConnection sendAsynchronousRequest:request
                                     queue:[NSOperationQueue mainQueue]
                         completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                           
                           // serialize data to JSON
                           id json = nil;
                           if (!error) {
                             NSError* jsonError = nil;
                             json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
                             error = jsonError;
                           }
                           
                           handler(json, error);
                         }];
}


#pragma mark - Helper methods (retrieve data from endpoint definitions)

- (NSData *)jsonDataForEndpoint {
  NSDictionary* json = [ReplayEndpoint populatedJson:self.endpointDefinition[kJSON] withData:self.data];

  if ([NSJSONSerialization isValidJSONObject:json]) {
    NSError* error = nil;
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:json
                                                     options:0
                                                       error:&error];
    return jsonData;
  }
  else {
    return nil;
  }
}

// populates the JSON payload with values
+ (NSDictionary *)populatedJson:(NSDictionary *)unpopulatedJson withData:(id)data {
  NSMutableDictionary* json = [unpopulatedJson mutableCopy];
  
  for (NSString* key in json.allKeys) {
    NSString* localKey = [ReplayAPIManager mapLocalKeyFromServerKey:key];
    id newValue = [NSNull null];
    
    // local key exists (replace the value with the corresponding property stored in the ReplayAPIManager)
    // for the keys: {apiKey, clientUUID, sessionUUID}
    if (localKey) {
      if ([[ReplayAPIManager sharedManager] respondsToSelector:NSSelectorFromString(localKey)]) {
        newValue = [[ReplayAPIManager sharedManager] valueForKey:localKey];
      }
      else {
        NSAssert(NO, @"Missing property \"%@\" in ReplayAPIManager", localKey);
      }
    }
    else if ([json[key] respondsToSelector:@selector(isEqualToString:)]) {
      if ([json[key] isEqualToString:kContent]) {
        newValue = data;
      }
    }
    else if ([json[key] isKindOfClass:[NSDictionary class]]) {
      newValue = [ReplayEndpoint populatedJson:json[key] withData:data];
    }
    
    json[key] = newValue ?: [NSNull null];
  }
  
  return json;
}

- (NSURL *)urlForEndpoint {
  NSURL* baseURL = [NSURL URLWithString:[ReplayConfig developmentURL]]; // TODO: build setting
  return [baseURL URLByAppendingPathComponent:self.endpointDefinition[kPath]];
}

- (NSString *)httpMethodForEndpoint {
  return self.endpointDefinition[kMethod];
}


@end
