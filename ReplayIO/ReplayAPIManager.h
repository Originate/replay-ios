//
//  ReplayAPIManager.h
//  ReplayIO
//
//  Created by Allen Wu on 3/28/14.
//  Copyright (c) 2014 Originate. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ReplayAPIManager : NSObject

+ (NSData *)jsonDataFromDictionary:(NSDictionary *)dictionary error:(NSError *)error;
+ (void)sendJSONRequestToURL:(NSURL *)url httpMethod:(NSString *)httpMethod httpBody:(NSData *)httpBody completionHandler:(void (^)(NSURLResponse* response, NSData* data, NSError* connectionError)) handler;


@end
