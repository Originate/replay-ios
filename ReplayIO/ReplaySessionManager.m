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
    [defaults setObject:[ReplaySessionManager generateUUID] forKey:kSessionKey];
    #warning NOTE: no call to synchronize
  }
  
  return [defaults objectForKey:kSessionKey];
}

+ (NSString *)generateUUID {
  DEBUG_LOG(@"Generating new session UUID");
  
  return [[NSUUID UUID] UUIDString];
}

+ (void)endSession {
  DEBUG_LOG(@"Session ended");
  
  NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
  [defaults removeObjectForKey:kSessionKey];
  #warning NOTE: no call to synchronize
}

@end
