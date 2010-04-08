//
//  WikiViewController.m
//  Wikipedia Mobile
//
//  Created by Andreas Lengyel on 2/18/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "WikiViewController.h"

@implementation WikiViewController

@synthesize wikiEntryURL, webView, superView;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/


- (void)viewWillAppear:(BOOL)animated {
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	[webView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"UITexture2.png"]]];
	
	NSURLRequest *URLrequest = [NSURLRequest requestWithURL:wikiEntryURL];
	
	[webView loadRequest:URLrequest];
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO; 
	
#warning
	//[self addRecentPage:pageTitle];
}


- (void)viewWillDisappear:(BOOL)animated {
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
	[webView release];
}


@end
