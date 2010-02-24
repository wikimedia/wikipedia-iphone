//
//  WikiViewController.h
//  Wikipedia Mobile
//
//  Created by Andreas Lengyel on 2/18/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface WikiViewController : UIViewController <UIWebViewDelegate> {
	NSURL *wikiEntryURL;
	UIWebView *webView;
}

@property (nonatomic, retain) NSURL *wikiEntryURL;
@property (nonatomic, retain) IBOutlet UIWebView *webView;

@end
