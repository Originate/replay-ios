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

// Replay.IO server url
static NSString* const REPLAY_URL  = @"http://0.0.0.0:3000/"; //@"http://10.0.60.43:3000/";
static NSString* const REPLAY_HOST = @"0.0.0.0:3000"; //@"10.0.60.43:3000";

