//
//  ReplayIO.h
//  ReplayIO
//
//  Created by Allen Wu on 3/28/14.
//  Copyright (c) 2014 Originate. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ReplayIO : NSObject

@property (nonatomic) BOOL debugMode; // NOTE: maybe getter should be something like `isDebugMode`

// ReplayIO singleton object
+ (ReplayIO *)sharedTracker;

// Instantiation
+ (void)trackWithAPIKey:(NSString *)apiKey;

// Endpoint methods
+ (void)trackEvent:(NSString *)eventName distinctId:(NSString *)distinctId properties:(NSDictionary *)properties;
+ (void)updateTraitsWithDistinctId:(NSString *)distinctId properties:(NSDictionary *)properties;

// Dispatch
+ (void)setDispatchInterval:(NSInteger)interval; // NOTE: why isn't this a property?
+ (void)dispatch;

// Enable/disable
+ (void)enable;
+ (void)disable;

+ (void)setDebugMode:(BOOL)debugMode; // NOTE: This is a property, any reason why it's also a class method?

@end
