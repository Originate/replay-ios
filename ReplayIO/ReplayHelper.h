//
//  ReplayHelper.h
//  ReplayIO
//
//  Created by Allen Wu on 3/31/14.
//  Copyright (c) 2014 Originate. All rights reserved.
//


// Custom macros

#define DEBUG_LOG(fmt, ...) do {                 \
  if ([ReplayIO sharedTracker].debugMode) {      \
    NSLog(@"[Replay.IO] " fmt, ## __VA_ARGS__);  \
  }                                              \
} while(0)


#define SYNTHESIZE_SINGLETON(ClassName, singletonName)  \
+ (ClassName *)singletonName {                          \
  static ClassName* singletonName = nil;                \
  static dispatch_once_t onceToken;                     \
                                                        \
  dispatch_once(&onceToken, ^{                          \
    singletonName = [[ClassName alloc] init];           \
  });                                                   \
  return singletonName;                                 \
}

#define ERROR_DOMAIN_REPLAY_IO @"com.originate.replayio"
