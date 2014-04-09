//
//  ReplayIO.h
//  ReplayIO
//
//  Created by Allen Wu on 3/28/14.
//  Copyright (c) 2014 Originate. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ReplayIO : NSObject

@property (nonatomic) BOOL debugMode;

// ReplayIO singleton object
+ (ReplayIO *)sharedTracker;

// Instantiation
+ (void)trackWithAPIKey:(NSString *)apiKey;

// Public methods
+ (void)trackEvent:(NSString *)eventName withProperties:(NSDictionary *)eventProperties;
+ (void)updateAlias:(NSString *)userAlias;

+ (void)setDispatchInterval:(NSInteger)interval;
+ (void)dispatch;

+ (void)enable;
+ (void)disable;

+ (void)setDebugMode:(BOOL)debugMode;

@end
