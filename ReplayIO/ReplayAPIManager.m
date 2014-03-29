//
//  ReplayAPIManager.m
//  ReplayIO
//
//  Created by Allen Wu on 3/28/14.
//  Copyright (c) 2014 Originate. All rights reserved.
//

#import "ReplayAPIManager.h"

@implementation ReplayAPIManager

+ (NSData *)jsonDataFromDictionary:(NSDictionary *)dictionary error:(NSError *)error {
  return [NSJSONSerialization dataWithJSONObject:dictionary
                                         options:NSJSONWritingPrettyPrinted
                                           error:&error];
}

#pragma mark - NSURLConnection helper

+ (void)sendJSONRequestToURL:(NSURL *)url httpMethod:(NSString *)httpMethod httpBody:(NSData *)httpBody completionHandler:(void (^)(NSURLResponse* response, NSData* data, NSError* connectionError)) handler {
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

#pragma mark - API Endpoints



@end
