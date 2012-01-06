//
//  WikiViewController.m
//  Wikipedia Mobile
//
//  Created by Andreas Lengyel on 2/18/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "WikiViewController.h"
#import "ModalViewController.h"
#import "RecentPage.h"
#import "Bookmark.h"

@implementation WikiViewController

@synthesize appDelegate, wikiEntryURL, webView, superView, toolbar, backButton, forwardButton;
@synthesize pageTitle;
@synthesize managedObjectContext;

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
	
	appDelegate = (Wikipedia_MobileAppDelegate *)[[UIApplication sharedApplication] delegate];
	self.managedObjectContext = appDelegate.managedObjectContext;
	
	[webView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageWithContentsOfFile:@"UITexture2.png"]]];
        backButton.enabled = NO;
        forwardButton.enabled = NO;
	
	NSMutableURLRequest *URLrequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:wikiEntryURL]];
	
	[webView loadRequest:URLrequest];
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	
	[self showLoadingHUD];
}

- (void)webView:(UIWebView *)awebView didFailLoadWithError:(NSError *)error {
	if (error != nil) {
		NSString *errorString = [NSString stringWithFormat:@"%@", error];
		NSLog(@"%@", errorString);
		
		[UIApplication sharedApplication].networkActivityIndicatorVisible = NO; 
		[HUD hide:YES];
	}
        
        self.backButton.enabled = awebView.canGoBack;
        self.forwardButton.enabled = awebView.canGoForward;
}

- (void)webViewDidFinishLoad:(UIWebView *)awebView {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
	pageTitle = [self.webView stringByEvaluatingJavaScriptFromString:@"document.title"]; 
	
	[HUD hide:YES];
	
	if (![pageTitle isEqualToString:@"Wikipedia"] && ![pageTitle isEqualToString:nil]) {
		[self addRecentPage:pageTitle];
	}
        
        self.backButton.enabled = awebView.canGoBack;
        self.forwardButton.enabled = awebView.canGoForward;
}


- (void)viewWillDisappear:(BOOL)animated {
	[HUD hide:YES];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)addRecentPage:(NSString *)pageName {
	RecentPage *recentPage = (RecentPage *)[NSEntityDescription insertNewObjectForEntityForName:@"RecentPage" inManagedObjectContext:managedObjectContext];
	
	[recentPage setValue:[NSDate date] forKey:@"dateVisited"];
	[recentPage setValue:pageName forKey:@"pageName"];
	[recentPage setValue:[self wikiEntryURL] forKey:@"pageURL"];
	
	NSError *error;
	if (![managedObjectContext save:&error]) {
	}
}

#pragma mark toolbar 

- (IBAction)showHistory {
	ModalViewController *modalView = [[ModalViewController alloc] initWithNibName:@"ModalViewController" bundle:nil];
	modalView.managedObjectContext = appDelegate.managedObjectContext;
	modalView.isBookmark = NO;
	[self.navigationController presentModalViewController:modalView animated:YES];
	[modalView release];
	if (webView.loading) {
		[webView stopLoading];
	}
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(int)buttonIndex
{		
	if(buttonIndex == 0)
	{
		pageTitle = [self.webView stringByEvaluatingJavaScriptFromString:@"document.title"]; 
		
		if (pageTitle != nil) {
			[self addBookmark:pageTitle];
		}
	}
}


- (void)addBookmark:(NSString *)pageName {
	Bookmark *bookmark = (Bookmark *)[NSEntityDescription insertNewObjectForEntityForName:@"Bookmark" inManagedObjectContext:managedObjectContext];
	
	[bookmark setValue:pageName forKey:@"pageName"];
	[bookmark setValue:[self wikiEntryURL] forKey:@"pageURL"];
	
	NSError *error;
	if (![managedObjectContext save:&error]) {
	}
}

- (IBAction)addBookmark {
	UIActionSheet *menu = [[UIActionSheet alloc]
						   initWithTitle:nil
						   delegate:self
						   cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
						   destructiveButtonTitle:nil
						   otherButtonTitles:NSLocalizedString(@"Add Bookmark", @"Add Bookmark"), nil];
	menu.actionSheetStyle = UIActionSheetStyleDefault;
	[menu showInView:self.view];
        [menu release];
}

#pragma mark HUD

- (void)showLoadingHUD {
	HUD = [[MBProgressHUD alloc] initWithView:self.view];
	HUD.mode = MBProgressHUDModeIndeterminate;
	
	[self.view addSubview:HUD];
	HUD.delegate = self;
	
	HUD.labelText = NSLocalizedString(@"Loading...", @"Loading...");
	
	[HUD show:YES];
}

- (void)hudWasHidden:(MBProgressHUD *)aHUD {
    [aHUD removeFromSuperview];
}

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
