//
//  ReplayIO.h
//  ReplayIO
//
//  Created by Allen Wu on 3/28/14.
//  Copyright (c) 2014 Originate. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ReplayIO : NSObject

@property (readonly, nonatomic, strong) NSString* apiKey;
@property (readonly, nonatomic, strong) NSString* userAlias;

// ReplayIO singleton object
+ (ReplayIO *)sharedTracker;

// Instantiation
+ (void)trackWithAPIKey:(NSString *)apiKey;

// Public methods
+ (void)trackEvent:(NSDictionary *)eventProperties;
+ (void)setUserAlias:(NSString *)userAlias;


@end
