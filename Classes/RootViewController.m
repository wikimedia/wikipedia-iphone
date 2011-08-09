//
//  RootViewController.m
//  Wikipedia Mobile
//
//  Created by Andreas Lengyel on 2/3/10.
//  Copyright Wikimedia Foundation 2010. All rights reserved.
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

@synthesize webView, searchBar, searchResults, toolBar, backButton, forwardButton;
@synthesize appDelegate, pageTitle, shade, tableView;

@synthesize managedObjectContext;

- (void)viewWillAppear:(BOOL)animated {
	
}

- (void)loadStartPage {
	NSString *url = [NSString stringWithFormat:@"http://%@.m.wikipedia.org", [appDelegate.settings stringForKey:@"languageKey"]];
	NSURL *_url = [NSURL URLWithString:url];
	NSMutableURLRequest *URLrequest = [NSMutableURLRequest requestWithURL:_url];
	[URLrequest setValue:@"Wikipedia Mobile/2.0" forHTTPHeaderField:@"User_Agent"];
	
	[webView loadRequest:URLrequest];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	appDelegate = (Wikipedia_MobileAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	webView.scalesPageToFit = TRUE;
	webView.multipleTouchEnabled = TRUE;
	[webView setBackgroundColor:[UIColor colorWithPatternImage:
                                 [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"UITexture@2x" ofType:@"png"]]]];
	searchBar.showsScopeBar = NO;
	searchBar.frame = CGRectMake(0, 0, 320.0f, 44.0f);
	
        backButton.enabled = NO;
        forwardButton.enabled = NO;
        
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
	
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:_url];
	[request setValue:@"Wikipedia Mobile/2.0" forHTTPHeaderField:@"User_Agent"];
	
	[webView loadRequest:request];
	[request release];
}

- (void)loadWikiEntry:(NSString *)query {
	query = [query stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	
	NSString *url = [NSString stringWithFormat:@"http://%@.m.wikipedia.org/wiki?search=%@", [appDelegate.settings stringForKey:@"languageKey"], query]; 
	NSURL *_url = [NSURL URLWithString:url];
		
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:_url];
	[request setValue:@"Wikipedia Mobile/2.0" forHTTPHeaderField:@"User_Agent"];
	
	[webView loadRequest:request];
	[request release];
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	
	[self showLoadingHUD];
	
	[timer release];
	timer = [NSTimer scheduledTimerWithTimeInterval:0.05
											 target:self
										   selector:@selector(handleTimer:)
										   userInfo:nil
											repeats:YES];	
	[timer retain];
}

- (void)handleTimer:(NSTimer *)timer
{
	if (HUDvisible) {
		if (HUD.progress < 1.0f) {
			HUD.progress = HUD.progress + 0.01f;
		} else {
			HUD.progress = 0.0f;
		}
	}
}

#pragma mark WebViewDelegate

- (void)webView:(UIWebView *)awebView didFailLoadWithError:(NSError *)error {
	[timer invalidate];
	if (error != nil) {
		NSString *errorString = [NSString stringWithFormat:@"%@", error];
		NSLog(@"%@", errorString);
		
		if (error.code == -1003) {
			UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Can't find host", @"Can't find host") message:NSLocalizedString(@"Wikipedia could not be located. Please check your internet connection.", @"Wikipedia could not be located. Please check your internet connection.") delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
			[errorAlert show];
                        [errorAlert release];
		}
		
		[UIApplication sharedApplication].networkActivityIndicatorVisible = NO; 
		[HUD hide:YES];
	}

        self.backButton.enabled = awebView.canGoBack;
        self.forwardButton.enabled = awebView.canGoForward;
}

- (void)webViewDidFinishLoad:(UIWebView *)awebView {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO; 
	
	pageTitle = [self.webView stringByEvaluatingJavaScriptFromString:@"document.title"]; 
	if (![pageTitle isEqualToString:@"Wikipedia"]) {
		[searchBar setText:pageTitle];
	}
	
	[timer invalidate];
	if (HUDvisible) {
		[HUD hide:YES];
	}
	
	if (![pageTitle isEqualToString:@"Wikipedia"] && ![pageTitle isEqualToString:nil]) {
		[self addRecentPage:pageTitle];
	}
        
        self.backButton.enabled = awebView.canGoBack;
        self.forwardButton.enabled = awebView.canGoForward;
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
	shade.alpha = 0.0;
	shade.hidden = NO;
	appDelegate = (Wikipedia_MobileAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	searchBar.showsScopeBar = YES;
	searchBar.selectedScopeButtonIndex = 0;
	searchBar.scopeButtonTitles = [NSArray arrayWithObjects:[appDelegate.settings stringForKey:@"languageName"], NSLocalizedString(@"Set Language", @"Set Language"), nil];
	
	[searchBar sizeToFit];
	searchBar.frame = CGRectMake(0, 0, 320.0f, 88.0f);

	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.3];	
	shade.alpha = 0.6;
	[UIView commitAnimations];
	
	if (webView.loading) {
		[webView stopLoading];
	}
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
	searchText = [searchText stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	
	NSString *urlString = [NSString stringWithFormat:@"http://%@.wikipedia.org/w/api.php?action=opensearch&search=%@&format=json", [appDelegate.settings stringForKey:@"languageKey"], searchText];
	NSURL *url = [NSURL URLWithString:urlString];
	
	NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
	NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	[connection release];
	[request release];
	
	if ([searchText length] > 0) {
		tableView.alpha = 1.0;
		tableView.hidden = NO;
	} else {
		tableView.alpha = 0.0;
		tableView.hidden = YES;
	}
	[tableView setContentOffset:CGPointMake(0, 0) animated:YES];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data 
{
	NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	NSArray *results = [jsonString JSONValue];
        
	if (results && [results count] >= 1) {
            searchResults = [NSMutableArray arrayWithArray:[results objectAtIndex:1]];
        } else {
            searchResults = [NSMutableArray array];
        }
        [searchResults retain];
        [jsonString release];
        
       	[tableView reloadData];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	tableView.hidden = YES;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
}

- (void)searchBar:(UISearchBar *)_searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope {
	if (selectedScope == 1) {
		LanguageSwitcher *langSwitcher = [[LanguageSwitcher alloc] initWithNibName:@"LanguageSwitcher" bundle:nil];
		langSwitcher.returnView = self;
		[self.navigationController presentModalViewController:langSwitcher animated:YES];
		[langSwitcher release];
		if (webView.loading) {
			[webView stopLoading];
		}
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
	shade.alpha = 0.6;
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.2];
	shade.alpha = 0.0;
	[UIView commitAnimations];
	shade.hidden = YES;
	
	tableView.alpha = 0.0;
	tableView.hidden = YES;
	searchBar.showsScopeBar = NO;
	[searchBar sizeToFit];
	
	[searchBar resignFirstResponder];
	[self loadWikiEntry:searchBar.text];
}

- (IBAction)stopEditing {
	shade.alpha = 0.6;
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.2];
	shade.alpha = 0.0;
	[UIView commitAnimations];
	
	searchBar.showsScopeBar = NO;
	[searchBar sizeToFit];
	[searchBar resignFirstResponder];
}

#pragma mark table view

- (void)scrollViewWillBeginDragging:(UIScrollView *)_tableView {
	[searchBar resignFirstResponder];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)_tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)_tableView numberOfRowsInSection:(NSInteger)section {
	return [searchResults count];
}

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
        static NSString *CellIdentifier = @"Cell";
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
	
	cell.textLabel.text = [searchResults objectAtIndex:indexPath.row];
	
    return [cell autorelease];
}

- (void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[self loadWikiEntry:[searchResults objectAtIndex:indexPath.row]];
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	searchBar.showsScopeBar = NO;
	[searchBar setText:[searchResults objectAtIndex:indexPath.row]];
	[searchBar sizeToFit];
	[searchBar resignFirstResponder];
	
	tableView.alpha = 1.0;
	shade.alpha = 0.6;
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.2];
	shade.alpha = 0.0;
	tableView.alpha = 0.0;
	[UIView commitAnimations];
	tableView.hidden = YES;
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
						   cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
						   destructiveButtonTitle:nil
						   otherButtonTitles:NSLocalizedString(@"Add Bookmark", @"Add Bookmark"), nil];

	menu.actionSheetStyle = UIActionSheetStyleDefault;
	[menu showInView:self.view];
        [menu release];
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
	[bookmark setValue:[self currentURL] forKey:@"pageURL"];
	
	NSError *error;
	if (![managedObjectContext save:&error]) {
	}
}

- (IBAction)goBack {
	[webView goBack];
}

- (IBAction)goForward {
	[webView goForward];
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

/*
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	return UIInterfaceOrientationPortrait;
}
*/

#pragma mark HUD

- (void)showLoadingHUD {
	
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
	HUD.mode = MBProgressHUDModeDeterminate;
	
    [self.view addSubview:HUD];
	HUD.delegate = self;
	
    HUD.labelText = NSLocalizedString(@"Loading...", @"Loading...");
	
    [HUD show:YES];
	HUDvisible = YES;
	
	HUD.progress = 0.0f;
}

- (void)hudWasHidden:(MBProgressHUD *)hud {
    HUDvisible = NO;
    [hud removeFromSuperview];
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

