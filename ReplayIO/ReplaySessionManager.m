//
//  ReplaySessionManager.m
//  ReplayIO
//
//  Created by Allen Wu on 4/5/14.
//  Copyright (c) 2014 Originate. All rights reserved.
//

#import "ReplaySessionManager.h"

#define kSessionKey @"sessionUUID"

@implementation ReplaySessionManager

+ (NSString *)sessionUUID {
  NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
  
  if (![defaults objectForKey:kSessionKey]) {
    DEBUG_LOG(@"Setting new session UUID");
    [defaults setObject:[ReplaySessionManager generateUUID] forKey:kSessionKey];
    [defaults synchronize];
  }
  
  return [defaults objectForKey:kSessionKey];
}

+ (NSString *)generateUUID {
  return [[NSUUID UUID] UUIDString];
}

+ (void)endSession {
  DEBUG_LOG(@"Session ended");
  
  NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
  [defaults removeObjectForKey:kSessionKey];
  [defaults synchronize];
}

@end
