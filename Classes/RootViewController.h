//
//  RootViewController.h
//  Wikipedia Mobile
//
//  Created by Andreas Lengyel on 2/3/10.
//  Copyright Wikimedia Foundation 2010. All rights reserved.
//

#import "Wikipedia_MobileAppDelegate.h"
#import "JSON.h"
#import "MBProgressHUD.h"

@interface RootViewController : UIViewController <UISearchBarDelegate, UIWebViewDelegate, UIActionSheetDelegate, UITableViewDelegate, UITableViewDataSource, MBProgressHUDDelegate> {
	Wikipedia_MobileAppDelegate *appDelegate;
	
	UIWebView *webView;
	IBOutlet UISearchBar *searchBar;
	NSString *pageTitle;
	UIView *shade;
	UITableView *tableView;
	MBProgressHUD *HUD;
	NSTimer *timer;
	BOOL HUDvisible;
	
	NSMutableArray *searchResults;
	NSManagedObjectContext *managedObjectContext;
}

@property (nonatomic, retain) Wikipedia_MobileAppDelegate *appDelegate;

@property (nonatomic, retain) IBOutlet UIWebView *webView;
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
- (void)showLoadingHUD;
- (void)loadStartPage;
- (void)reload;
- (void)addRecentPage:(NSString *)pageName;
- (void)addBookmark:(NSString *)pageName;

@end
