//
//  ReplaySessionManager.h
//  ReplayIO
//
//  Created by Allen Wu on 4/5/14.
//  Copyright (c) 2014 Originate. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ReplaySessionManager : NSObject

+ (NSString *)sessionUUID;
+ (void)endSession;

@end
