//
//  ReplayConfig.h
//  ReplayIO
//
//  Created by Allen Wu on 3/30/14.
//  Copyright (c) 2014 Originate. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kContent @"kContent"

// Endpoint definition keys
#define kMethod  @"kMethod"
#define kPath    @"kPath"
#define kJSON    @"kJSON"

// Framework keys
#define kReplayKey @"replayKey"
#define kClientId  @"clientId"
#define kSessionId @"sessionId"

@interface ReplayConfig : NSObject

@property (nonatomic, strong, readonly) NSDictionary* urls;
@property (nonatomic, strong, readonly) NSDictionary* endpoints;

+ (ReplayConfig *)sharedInstance;

// convenience methods
+ (NSDictionary *)endpointDefinition:(NSString *)endpointKey;
+ (NSString *)url;

@end
