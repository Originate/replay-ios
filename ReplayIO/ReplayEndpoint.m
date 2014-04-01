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
    self.jsonData   = [self jsonDataForEndpoint];
    self.url        = [self urlForEndpoint];
    self.httpMethod = [self httpMethodForEndpoint];
  }
  return self;
}

- (void)callWithCompletionHandler:(void (^)(id json, NSError* error)) handler {
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
  NSMutableDictionary* json = [self.endpointDefinition[kJSON] mutableCopy];
  
  // populate the JSON payload with values
  for (NSString* key in json.allKeys) {
    if ([json[key] isEqualToString:kContent]) {
      json[key] = self.data ?: [NSNull null];
    }
    else {
      NSString* localKey = [ReplayAPIManager mapLocalKeyFromServerKey:key];
      NSString* localVal = [[ReplayAPIManager sharedManager] valueForKey:localKey];

      json[key] = localVal ?: [NSNull null];
    }
  }
  
  NSError* error = nil;
  NSData* jsonData = [NSJSONSerialization dataWithJSONObject:json
                                                     options:NSJSONWritingPrettyPrinted
                                                       error:&error];
  
  return jsonData;
  
}

- (NSURL *)urlForEndpoint {
  NSURL* baseURL = [NSURL URLWithString:[ReplayConfig developmentURL]]; // TODO: build setting
  return [baseURL URLByAppendingPathComponent:self.endpointDefinition[kPath]];
}

- (NSString *)httpMethodForEndpoint {
  return self.endpointDefinition[kMethod];
}


@end
