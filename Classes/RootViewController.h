//
//  RootViewController.h
//  Wikipedia Mobile
//
//  Created by Andreas Lengyel on 2/3/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

@interface RootViewController : UIViewController {
	NSString *url;
	UIWebView *webView;
	UIActivityIndicatorView *spinner;
}

@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (nonatomic, retain) NSString *url;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *spinner;

@end
