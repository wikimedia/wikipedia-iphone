//
//  WikiConnectionController.m
//  Wikipedia Mobile
//
//  Created by preilly on 1/4/12.
//  Copyright (c) 2012 Wikipedia Mobile. All rights reserved.
//

#import "WikiConnectionController.h"

@implementation WikiConnectionController

@synthesize connectionDelegate;
@synthesize succeededAction;
@synthesize failedAction;

- (id)initWithDelegate:(id)delegate selSucceeded:(SEL)succeeded selFailed:(SEL)failed {
    if ((self = [super init])) {
        self.connectionDelegate = delegate;
        self.succeededAction = succeeded;
        self.failedAction = failed;
    }
    return self;
}

-(void)dealloc {
    [connectionDelegate release];
    [super dealloc];
}

- (BOOL)startRequestForURL:(NSURL*)url {
    NSMutableURLRequest* urlRequest = [NSMutableURLRequest requestWithURL:url];
    // cache and policy handling could go here
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setHTTPShouldHandleCookies:YES];
    NSURLConnection* connectionResponse = [[[NSURLConnection alloc] initWithRequest:urlRequest delegate:self] autorelease];
    if (!connectionResponse)
    {
        // possibly handle the error?
        return NO;
    } else {
        receivedData = [[NSMutableData data] retain];
    }
    return YES;
}

- (void)connection:(NSURLConnection*)connection didReceiveResponse:(NSURLResponse*)response {
    [receivedData setLength:0];
}

- (void)connection:(NSURLConnection*)connection didReceiveData:(NSData*)data {
    [receivedData appendData:data];
}

- (void)connection:(NSURLConnection*)connection didFailWithError:(NSError*)error {
    [connectionDelegate performSelector:failedAction withObject:error];
    [receivedData release];
}

- (void)connectionDidFinishLoading:(NSURLConnection*)connection {
    [connectionDelegate performSelector:succeededAction withObject:receivedData];
    [receivedData release];
}

@end