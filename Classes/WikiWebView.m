//
//  WikiWebView.m
//  Wikipedia Mobile
//
//  Created by Patrick Reilly on 1/5/12.
//  Copyright Wikimedia Foundation 2012. All rights reserved.
//

#import "WikiWebView.h"


@implementation WikiWebView

@synthesize customHeaders;


- (void) _internalInit {
	super.delegate = self;
	foreignDelegate = nil;
}

- (id) initWithFrame:(CGRect)frame {
	if((self = [super initWithFrame:frame])) {
		[self _internalInit];
	}
	
	return self;
}

- (id) init {
	if((self = [super init])) {
		[self _internalInit];
	}
	
	return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder {
	if((self = [super initWithCoder:aDecoder])) {
		[self _internalInit];
	}
	return self;
}

- (void) setDelegate:(id<UIWebViewDelegate>)aDelegate {
	if(foreignDelegate == aDelegate)
		return;
	
	[foreignDelegate release];
	foreignDelegate = [aDelegate retain];

	super.delegate=self;
}

- (id<UIWebViewDelegate>) delegate {
	return foreignDelegate;
}

- (void) setCustomHeaders:(NSDictionary *)cHeaders {
	
	NSMutableDictionary *newHeaders = [NSMutableDictionary dictionary];
	for(NSString *key in [cHeaders allKeys]) {
		NSString *lowercaseKey = [key lowercaseString];
		[newHeaders setObject:[cHeaders objectForKey:key] forKey:lowercaseKey];
	}
	
	[customHeaders release];
	customHeaders = [newHeaders retain];
}

- (void) dealloc {
	[customHeaders release];
	[foreignDelegate release];
	[super dealloc];
}

#pragma mark -
#pragma mark UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)aRequest navigationType:(UIWebViewNavigationType)navigationType {	

	BOOL missingHeaders = NO;

	NSArray *currentHeaders = [[aRequest allHTTPHeaderFields] allKeys];
	NSMutableArray *lowercasedHeaders = [NSMutableArray array];
	for(NSString *key in currentHeaders) {
		[lowercasedHeaders addObject:[key lowercaseString]];
	}

	for(NSString *key in customHeaders) {
		if(![lowercasedHeaders containsObject:key]) {
			missingHeaders = YES;
			break;
		}
	}

	if(missingHeaders) {
		NSMutableURLRequest *newRequest = [aRequest mutableCopy];
		for(NSString *key in [customHeaders allKeys]) {
			[newRequest setValue:[customHeaders valueForKey:key] forHTTPHeaderField:key];
		}
		[self loadRequest:newRequest];
		[newRequest release];
		return NO;
	}
	
	if([foreignDelegate respondsToSelector:@selector(webView:shouldStartLoadWithRequest:navigationType:)]) {
		return [foreignDelegate webView:self shouldStartLoadWithRequest:aRequest navigationType:navigationType];
	}
	
	return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
	if([foreignDelegate respondsToSelector:@selector(webViewDidStartLoad:)])
		[foreignDelegate webViewDidStartLoad:self];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	if([foreignDelegate respondsToSelector:@selector(webViewDidFinishLoad:)])
		[foreignDelegate webViewDidFinishLoad:self];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
	if([foreignDelegate respondsToSelector:@selector(webView:didFailLoadWithError:)])
		[foreignDelegate webView:self didFailLoadWithError:error];
}

@end