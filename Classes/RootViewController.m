//
//  RootViewController.m
//  Wikipedia Mobile
//
//  Created by Andreas Lengyel on 2/3/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "RootViewController.h"
#import "ModalViewController.h"
#import "MapViewController.h"
#import "LanguageSwitcher.h"
#import "Wikipedia_MobileAppDelegate.h"
#import "RecentPage.h"
#import "Bookmark.h"

#define debug(format, ...) CFShow([NSString stringWithFormat:format, ## __VA_ARGS__]);

@implementation RootViewController

@synthesize webView, activityIndicator, searchBar;
@synthesize appDelegate, languageButton, pageTitle;

@synthesize managedObjectContext;

- (void)viewWillAppear:(BOOL)animated {
	appDelegate = (Wikipedia_MobileAppDelegate *)[[UIApplication sharedApplication] delegate];
	languageButton.title = [[appDelegate.settings stringForKey:@"languageKey"] uppercaseString];
}

- (void)loadStartPage {
	NSString *url = [NSString stringWithFormat:@"http://%@.m.wikipedia.org", [appDelegate.settings stringForKey:@"languageKey"]];
	NSURL *_url = [NSURL URLWithString:url];
	NSURLRequest *URLrequest = [NSURLRequest requestWithURL:_url];
	
	[webView loadRequest:URLrequest];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	appDelegate = (Wikipedia_MobileAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	webView.scalesPageToFit = TRUE;
	webView.multipleTouchEnabled = TRUE;
	
	[self loadStartPage];
	
	self.managedObjectContext = appDelegate.managedObjectContext;
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"RecentPage" inManagedObjectContext:managedObjectContext];
	[request setEntity:entity];
	
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"dateVisited" ascending:NO];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
	[request setSortDescriptors:sortDescriptors];
	[sortDescriptor release];
	[sortDescriptors release];
	
	NSError *error = nil;
	NSMutableArray *mutableFetchResults = [[managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
	if (mutableFetchResults == nil) {
	}
	
	[mutableFetchResults release];
	[request release];
}

- (void)loadURL:(NSString *)url {
	NSURL *_url = [NSURL URLWithString:url];
	
	NSURLRequest *request = [[NSURLRequest alloc] initWithURL:_url];
	
	[webView loadRequest:request];
	[request release];
}

- (void)loadWikiEntry:(NSString *)query {
	query = [query stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
	
	NSString *url = [NSString stringWithFormat:@"http://%@.m.wikipedia.org/wiki?search=%@", [appDelegate.settings stringForKey:@"languageKey"], query]; 
	NSURL *_url = [NSURL URLWithString:url];
		
	NSURLRequest *request = [[NSURLRequest alloc] initWithURL:_url];
	
	[webView loadRequest:request];
	[request release];
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	
	[activityIndicator startAnimating];
	activityIndicator.hidden = NO;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
	if (error != nil) {
		NSString *errorString = [NSString stringWithFormat:@"%@", error];
		NSLog(@"%@", errorString);
		
		[UIApplication sharedApplication].networkActivityIndicatorVisible = NO; 
		[activityIndicator stopAnimating];
		activityIndicator.hidden = YES;
	}
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO; 
	
	pageTitle = [self.webView stringByEvaluatingJavaScriptFromString:@"document.title"]; 
	
	[activityIndicator stopAnimating];
	activityIndicator.hidden = YES;
	
	if (![pageTitle isEqualToString:@"Wikipedia"]) {
		[self addRecentPage:pageTitle];
	}
}

- (void)addRecentPage:(NSString *)pageName {
	RecentPage *recentPage = (RecentPage *)[NSEntityDescription insertNewObjectForEntityForName:@"RecentPage" inManagedObjectContext:managedObjectContext];
	
	[recentPage setValue:[NSDate date] forKey:@"dateVisited"];
	[recentPage setValue:pageName forKey:@"pageName"];
	
	[recentPage setValue:[self currentURL] forKey:@"pageURL"];
	
	NSError *error;
	if (![managedObjectContext save:&error]) {
	}
}

- (NSString *)currentURL {
	NSString *locationString = [webView stringByEvaluatingJavaScriptFromString:@"location.href;"];
	if(!locationString)
		return nil;
	locationString = [locationString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	return locationString;
}

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}
*/

/*
 // Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations.
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
 */

#pragma mark searchbar stuff

- (void)searchBarTextDidBeginEditing:(UISearchBar *)_searchBar {
	if (webView.loading) {
		[webView stopLoading];
	}
}

- (void)searchBarBookmarkButtonClicked:(UISearchBar *)_searchBar {
	ModalViewController *modalView = [[ModalViewController alloc] initWithNibName:@"ModalViewController" bundle:nil];
	modalView.managedObjectContext = appDelegate.managedObjectContext;
	modalView.returnView = self;
	modalView.isBookmark = YES;
	[self.navigationController presentModalViewController:modalView animated:YES];
	[modalView release];
	if (webView.loading) {
		[webView stopLoading];
	}
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)_searchBar {
	[searchBar resignFirstResponder];
	[self loadWikiEntry:searchBar.text];
}

#pragma mark toolbar

- (IBAction)showHistory {
	ModalViewController *modalView = [[ModalViewController alloc] initWithNibName:@"ModalViewController" bundle:nil];
	modalView.managedObjectContext = appDelegate.managedObjectContext;
	modalView.returnView = self;
	modalView.isBookmark = NO;
	[self.navigationController presentModalViewController:modalView animated:YES];
	[modalView release];
	if (webView.loading) {
		[webView stopLoading];
	}
}

- (IBAction)addBookmark {
	UIActionSheet *menu = [[UIActionSheet alloc]
						   initWithTitle:nil
						   delegate:self
						   cancelButtonTitle:@"Cancel"
						   destructiveButtonTitle:nil
						   otherButtonTitles:@"Add Bookmark", nil];
	menu.actionSheetStyle = UIActionSheetStyleDefault;
	[menu showInView:self.view];
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
	[actionSheet release];
}


- (void)addBookmark:(NSString *)pageName {
	Bookmark *bookmark = (Bookmark *)[NSEntityDescription insertNewObjectForEntityForName:@"Bookmark" inManagedObjectContext:managedObjectContext];
	
	[bookmark setValue:pageName forKey:@"pageName"];
	[bookmark setValue:[self currentURL] forKey:@"pageURL"];
	
	NSError *error;
	if (![managedObjectContext save:&error]) {
	}
}

- (IBAction)switchLanguage {
	LanguageSwitcher *langSwitcher = [[LanguageSwitcher alloc] initWithNibName:@"LanguageSwitcher" bundle:nil];
	langSwitcher.returnView = self;
	[self.navigationController presentModalViewController:langSwitcher animated:YES];
	[langSwitcher release];
	if (webView.loading) {
		[webView stopLoading];
	}
}

- (IBAction)goBack {
	[webView goBack];
}

- (IBAction)nearbyButton {
	MapViewController *mapView = [[MapViewController alloc] initWithNibName:@"MapViewController" bundle:nil];
	[self.navigationController presentModalViewController:mapView animated:YES];
	[mapView release];
	if (webView.loading) {
		[webView stopLoading];
	}
}

- (void)reload {
	[webView reload];
}

#pragma mark memory/unload

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release anything that can be recreated in viewDidLoad or on demand.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
	[webView release];
}


@end

