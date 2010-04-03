//
//  RootViewController.h
//  Wikipedia Mobile
//
//  Created by Andreas Lengyel on 2/3/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "Wikipedia_MobileAppDelegate.h"
#import "JSON.h"
#import "WPToolbar.h"

@interface RootViewController : UIViewController <UISearchBarDelegate, UIWebViewDelegate, UIActionSheetDelegate, UITableViewDelegate, UITableViewDataSource> {
	Wikipedia_MobileAppDelegate *appDelegate;
	
	UIWebView *webView;
	UIActivityIndicatorView *activityIndicator;
	IBOutlet UISearchBar *searchBar;
	NSString *pageTitle;
	UIView *shade;
	UITableView *tableView;
	
	NSMutableArray *searchResults;
	NSManagedObjectContext *managedObjectContext;
}

@property (nonatomic, retain) Wikipedia_MobileAppDelegate *appDelegate;

@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, retain) UISearchBar *searchBar;
@property (nonatomic, retain) NSString *pageTitle;
@property (nonatomic, retain) IBOutlet UIView *shade;
@property (nonatomic, retain) IBOutlet UITableView *tableView;

@property (nonatomic, retain) NSMutableArray *searchResults;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;	

- (void)loadWikiEntry:(NSString *)url;
- (void)loadURL:(NSString *)url;
- (NSString *)currentURL;
- (IBAction)goBack;
- (IBAction)goForward;
- (IBAction)nearbyButton;
- (IBAction)addBookmark;
- (IBAction)showHistory;
- (IBAction)stopEditing;
- (void)loadStartPage;
- (void)reload;
- (void)addRecentPage:(NSString *)pageName;
- (void)addBookmark:(NSString *)pageName;

@end
