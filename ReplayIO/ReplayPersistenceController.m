//
//  ReplayPersistenceController.m
//  ReplayIO
//
//  Created by Aaron Daub on 2014-09-16.
//  Copyright (c) 2014 Originate. All rights reserved.
//

#import "ReplayPersistenceController.h"
#import "ReplayRequest.h"
#import <sqlite3.h>


typedef BOOL(^ReplayPersistenceControllerSQLBlock)(sqlite3* database);
const NSString* ReplayEventStoreFileName = @"replay_event_store.db";

@interface ReplayPersistenceController ()

@property (nonatomic, readwrite, strong) NSOperationQueue* persistenceQueue;
@property (nonatomic, readwrite, assign) sqlite3* database;
@property (nonatomic, readwrite, strong) NSMutableArray* databaseReadyBlocks;
@property (nonatomic, readwrite, assign, getter = isDatabaseReady) BOOL databaseReady;
@property (nonatomic, readwrite, assign) BOOL databaseWillNotBeReady;

@end

@implementation ReplayPersistenceController

#pragma mark - Lifecycle

+ (instancetype)sharedPersistenceController{
  static ReplayPersistenceController* controller;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    controller = [[self alloc] init];
  });
  
  return controller;
}

- (instancetype)init{
  if(self = [super init]){
    self.persistenceQueue = [[NSOperationQueue alloc] init];
    self.persistenceQueue.maxConcurrentOperationCount = 1;
    [self.persistenceQueue addOperationWithBlock:^{
      [self setupDatabaseConnection];
    }];
  }
  return self;
}

- (void)callBlockWhenDatabaseIsReady:(ReplayPersistenceControllerDatabaseReady)completionBlock{
  NSParameterAssert(completionBlock);
  
  if(!self.databaseReadyBlocks){
    self.databaseReadyBlocks = [NSMutableArray array];
  }
  
  if(self.isDatabaseReady){
    completionBlock(YES);
  }else if(self.databaseWillNotBeReady){
    completionBlock(NO);
  }else{
    [self.databaseReadyBlocks addObject:completionBlock];
  }
}

- (void)flushDatabaseReadyBlocks:(BOOL)isDatabaseReady{
  for(ReplayPersistenceControllerDatabaseReady completionBlock in self.databaseReadyBlocks){
    completionBlock(isDatabaseReady);
  }
}

- (void)setDatabaseReady:(BOOL)databaseReady{
  _databaseReady = databaseReady;
  if(_databaseReady){
    [self flushDatabaseReadyBlocks:YES];
  }
}

- (void)setDatabaseWillNotBeReady:(BOOL)databaseWillNotBeReady{
  _databaseWillNotBeReady = databaseWillNotBeReady;
  if(_databaseWillNotBeReady){
    [self flushDatabaseReadyBlocks:NO];
  }
}

- (void)dealloc{
  sqlite3_close(self.database);
}

#pragma mark - SQLite3 Setup

- (void)setupDatabaseConnection{
  sqlite3* databaseConnection = NULL;
  BOOL databaseExists = [[NSFileManager defaultManager] fileExistsAtPath:[self eventStoreFilePath]];
  int databaseFlags = SQLITE_OPEN_CREATE | SQLITE_OPEN_READWRITE;
  int status = sqlite3_open_v2([[self eventStoreFilePath] UTF8String], &databaseConnection, databaseFlags, NULL);
  BOOL openedSuccessfully = (status == SQLITE_OK);
  if(openedSuccessfully){
    self.database = databaseConnection;
    if(!databaseExists){
      [self setupEventTable];
    }else{
      self.databaseReady = YES;
    }
  }else{
    DEBUG_LOG(@"Failed to open database, will not persist events to disk");
    self.databaseWillNotBeReady = YES;
  }
}

- (void)setupEventTable{
  NSString* SQLQuery = @"create table events(event_id integer, event_data blob)";
  BOOL createdSuccessfully = [self performSQLQuery:SQLQuery];
  if(!createdSuccessfully){
    NSString* errorMessage = [NSString stringWithUTF8String:sqlite3_errmsg(self.database)];
    DEBUG_LOG(@"Error opening database: %@", errorMessage);
    self.databaseWillNotBeReady = YES;
  }else{
    self.databaseReady = YES;
  }
  
}

- (NSString*)eventStoreFilePath{
  NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
  return [documentsPath stringByAppendingString:[NSString stringWithFormat:@"/%@", ReplayEventStoreFileName]];
}

- (void)persistRequest:(ReplayRequest*)request onCompletion:(ReplayPersistenceControllerCompletion)completionBlock{
  NSParameterAssert(request);
  
  [self.persistenceQueue addOperationWithBlock:^{
    NSData* requestData = [NSKeyedArchiver archivedDataWithRootObject:request];
    NSUInteger requestHash = [request hash];
    const char * query = "INSERT INTO events VALUES(?, ?)";
    NSString* errorMessage;
    __block sqlite3_stmt *statement;
    
    ReplayPersistenceControllerSQLBlock prepareStatement = ^BOOL(sqlite3 *database) {
      return (sqlite3_prepare_v2(database, query, -1, &statement, NULL) == SQLITE_OK);
    };
    
    ReplayPersistenceControllerSQLBlock bindID = ^BOOL(sqlite3 *database) {
      return (sqlite3_bind_int64(statement, 1, requestHash) == SQLITE_OK);
    };
    
    ReplayPersistenceControllerSQLBlock bindData = ^BOOL(sqlite3 *database) {
      return (sqlite3_bind_blob(statement, 2, [requestData bytes], (int)[requestData length], SQLITE_STATIC) == SQLITE_OK);
    };
    
    ReplayPersistenceControllerSQLBlock execute = ^BOOL(sqlite3 *database) {
      return (sqlite3_step(statement) == SQLITE_DONE);
    };
    
    ReplayPersistenceControllerSQLBlock finish = ^BOOL(sqlite3 *database) {
      return (sqlite3_finalize(statement) == SQLITE_OK);
    };
    
    BOOL success = YES;
    NSArray* SQLOperations = @[prepareStatement, bindID, bindData, execute, finish];
    for(ReplayPersistenceControllerSQLBlock SQLOperation in SQLOperations){
      success = [self performSQLOperation:SQLOperation onDatabase:self.database errorMessage:&errorMessage];
      if(!success){
        break;
      }
    }
    
    if(success){
      if(completionBlock){
        [[NSOperationQueue mainQueue] addOperationWithBlock:completionBlock];
      }
    }
  }];
}

- (void)fetchAllRequests:(ReplayPersistentControllerRequestFetchCompletion)completion{
  NSParameterAssert(completion);
  if(!completion){
    return;
  }
  
  [self.persistenceQueue addOperationWithBlock:^{
    NSMutableArray* results = [NSMutableArray array];
    
    sqlite3_stmt* statement;
    if(sqlite3_prepare_v2(self.database, "SELECT * FROM events", -1, &statement, NULL) == SQLITE_OK){
      while(sqlite3_step(statement) == SQLITE_ROW){
        const void* blobData = sqlite3_column_blob(statement, 1);
        size_t blobSize = sqlite3_column_bytes(statement, 1);
        
        if(blobData != NULL){
          NSData* requestData = [[NSData alloc] initWithBytes:blobData length:blobSize];
          
          if(requestData){
            ReplayRequest* request = [NSKeyedUnarchiver unarchiveObjectWithData:requestData];
            BOOL requestIsValid = ([request isKindOfClass:[ReplayRequest class]]);
            
            if(requestIsValid){
              [results addObject:request];
            }
            
          }
        }
      }
      sqlite3_finalize(statement);
      NSLog(@"Fetch done");
      [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        completion(results.copy);
      }];
    }
  }];
}

- (void)removeRequest:(ReplayRequest *)request{
  NSParameterAssert(request);
  if(!request){
    return;
  }
  
  [self.persistenceQueue addOperationWithBlock:^{
    const char* query = "DELETE FROM events WHERE EVENT_ID = ?";
    sqlite3_stmt* statement;
    sqlite3_prepare_v2(self.database, query, -1, &statement, NULL);
    sqlite3_bind_int(statement, 0, (int)request.hash);
    int status = sqlite3_step(statement);
    BOOL success = status == SQLITE_DONE;
    sqlite3_finalize(statement);
    if(!success){
      NSString* errorMessage = [NSString stringWithUTF8String:sqlite3_errmsg(self.database)];
      DEBUG_LOG(@"Error removing request:\n Error: %@ | Request: %@", errorMessage, request);
    }
  }];
}

- (BOOL)deleteDatabase:(NSError* __autoreleasing *)error{
  BOOL databaseExists = [[NSFileManager defaultManager] fileExistsAtPath:[self eventStoreFilePath]];
  if(databaseExists){
    BOOL success = [[NSFileManager defaultManager] removeItemAtPath:[self eventStoreFilePath] error:error];
    self.database = NULL;
    return success;
  }
  return YES;
}

- (BOOL)performSQLQuery:(NSString*)query{
  return [self performSQLQuery:query errorMessage:NULL];
}

- (BOOL)performSQLQuery:(NSString*)query errorMessage:(NSString*__autoreleasing*)outErrorMessage{
  BOOL queryExecutedSuccessfully = sqlite3_exec(self.database, [query UTF8String], NULL, NULL, NULL) == SQLITE_OK;
  if(!queryExecutedSuccessfully){
    if(outErrorMessage){
      *outErrorMessage = [NSString stringWithUTF8String:sqlite3_errmsg(self.database)];
    }
    return NO;
  }
  return YES;
}

- (BOOL)performSQLOperation:(ReplayPersistenceControllerSQLBlock)SQLOperation onDatabase:(sqlite3*)database errorMessage:(NSString*__autoreleasing*)outErrorMessage{
  NSParameterAssert(SQLOperation);
  NSParameterAssert(database);
  if(!SQLOperation || database == NULL){
    return YES; // It's easy to do nothing...
  }
  
  BOOL success = SQLOperation(database);
  if(!success){
    const char* error = sqlite3_errmsg(database);
    if(error != NULL && outErrorMessage){
      *outErrorMessage = [NSString stringWithUTF8String:error];
    }
  }
  
  return success;
}


@end
