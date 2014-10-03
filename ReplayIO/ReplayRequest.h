//
//  ReplayRequest.h
//  ReplayIO
//
//  Created by Aaron Daub on 2014-09-03.
//  Copyright (c) 2014 Originate. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ReplayRequest : NSObject <NSCoding>

@property (nonatomic, readonly, copy) NSURLRequest* networkRequest;

+ (instancetype)requestWithURLRequest:(NSURLRequest*)request;
- (instancetype)initWithURLRequest:(NSURLRequest*)request;

- (NSComparisonResult)compare:(ReplayRequest*)request;

@end
