//
//  WikiConnectionController.h
//  Wikipedia Mobile
//
//  Created by preilly on 1/4/12.
//  Copyright (c) 2012 Wikipedia Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WikiConnectionController : NSObject {
    NSMutableData* receivedData;
}

@property (nonatomic, retain) id connectionDelegate;
@property (nonatomic) SEL succeededAction;
@property (nonatomic) SEL failedAction;

- (id)initWithDelegate:(id)delegate selSucceeded:(SEL)succeeded selFailed:(SEL)failed;
- (BOOL)startRequestForURL:(NSURL*)url;

@end
