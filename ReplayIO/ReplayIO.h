//
//  ReplayIO.h
//  ReplayIO
//
//  Created by Allen Wu on 3/28/14.
//  Copyright (c) 2014 Originate. All rights reserved.
//

#import <Foundation/Foundation.h>

#define DEBUG_LOG(fmt, ...) do {                 \
  if ([ReplayIO sharedTracker].debugMode) {      \
    NSLog(@"[Replay.IO] " fmt, ## __VA_ARGS__);  \
  }                                              \
} while(0)

@interface ReplayIO : NSObject

@property (nonatomic) BOOL debugMode;

// ReplayIO singleton object
+ (ReplayIO *)sharedTracker;

// Instantiation
+ (void)trackWithAPIKey:(NSString *)apiKey;

// Public methods
+ (void)trackEvent:(NSDictionary *)eventProperties;
+ (void)updateUserAlias:(NSString *)userAlias;
+ (void)setDebugMode:(BOOL)debugMode;

@end
