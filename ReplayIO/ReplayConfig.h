//
//  ReplayConfig.h
//  ReplayIO
//
//  Created by Allen Wu on 3/30/14.
//  Copyright (c) 2014 Originate. All rights reserved.
//

#import <Foundation/Foundation.h>


// JSON keys
#define kReplayKey  @"replay_key"
#define kClientId   @"client_id"
#define kSessionId  @"session_id"
#define kDistinctId @"distinct_id"
#define kProperties @"properties"
#define kEventName @"event_name"

// Replay.IO server url
static NSString* const REPLAY_URL  = @"http://api.replay.io/";
