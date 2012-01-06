//
//  WikiWebView.h
//  Wikipedia Mobile
//
//  Created by Patrick Reilly on 1/5/12.
//  Copyright Wikimedia Foundation 2012. All rights reserved.
//

@interface WikiWebView : UIWebView <UIWebViewDelegate> {
	id<UIWebViewDelegate>	foreignDelegate;
	NSDictionary			*customHeaders;
}

@property (nonatomic, retain) NSDictionary *customHeaders;

- (void) setDelegate:(id<UIWebViewDelegate>)aDelegate;
- (id<UIWebViewDelegate>) delegate;

@end