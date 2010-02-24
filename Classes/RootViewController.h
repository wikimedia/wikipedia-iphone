//
//  RootViewController.h
//  Wikipedia Mobile
//
//  Created by Andreas Lengyel on 2/3/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "Wikipedia_MobileAppDelegate.h"

@interface RootViewController : UIViewController <UISearchBarDelegate, UIWebViewDelegate, UIActionSheetDelegate> {
	Wikipedia_MobileAppDelegate *appDelegate;
	
	UIWebView *webView;
	UIActivityIndicatorView *activityIndicator;
	IBOutlet UISearchBar *searchBar;
	UIBarButtonItem *languageButton;
	NSString *pageTitle;
	
	NSManagedObjectContext *managedObjectContext;
}

@property (nonatomic, retain) Wikipedia_MobileAppDelegate *appDelegate;

@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, retain) UISearchBar *searchBar;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *languageButton;
@property (nonatomic, retain) NSString *pageTitle;

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;	

- (void)loadWikiEntry:(NSString *)url;
- (void)loadURL:(NSString *)url;
- (NSString *)currentURL;
- (IBAction)switchLanguage;
- (IBAction)goBack;
- (IBAction)nearbyButton;
- (IBAction)addBookmark;
- (IBAction)showHistory;
- (void)loadStartPage;
- (void)reload;
- (void)addRecentPage:(NSString *)pageName;
- (void)addBookmark:(NSString *)pageName;

@end
