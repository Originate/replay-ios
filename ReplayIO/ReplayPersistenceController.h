//
//  ReplayPersistenceController.h
//  ReplayIO
//
//  Created by Aaron Daub on 2014-09-16.
//  Copyright (c) 2014 Originate. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ReplayRequest;

typedef void(^ReplayPersistenceControllerCompletion)();
typedef void(^ReplayPersistenceControllerDatabaseReady)(BOOL isDatabaseReady);
typedef void(^ReplayPersistentControllerRequestFetchCompletion)(NSArray* replayRequests);

@interface ReplayPersistenceController : NSObject

+ (instancetype)sharedPersistenceController;
- (void)persistRequest:(ReplayRequest*)request onCompletion:(ReplayPersistenceControllerCompletion)completionBlock;
- (void)removeRequest:(ReplayRequest*)request;
- (void)fetchAllRequests:(ReplayPersistentControllerRequestFetchCompletion)completion;
- (BOOL)deleteDatabase:(NSError*__autoreleasing*)error;
- (void)callBlockWhenDatabaseIsReady:(ReplayPersistenceControllerDatabaseReady)completionBlock;

@end
