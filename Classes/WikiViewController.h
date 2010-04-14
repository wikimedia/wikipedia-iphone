//
//  WikiViewController.h
//  Wikipedia Mobile
//
//  Created by Andreas Lengyel on 2/18/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Wikipedia_MobileAppDelegate.h"
#import "MapViewController.h"
#import "MBProgressHUD.h"

@interface WikiViewController : UIViewController <UIWebViewDelegate, UIActionSheetDelegate, MBProgressHUDDelegate> {
	Wikipedia_MobileAppDelegate *appDelegate;

	NSString *wikiEntryURL;
	UIWebView *webView;
	MapViewController *superView;
	NSString *pageTitle;
	MBProgressHUD *HUD;
	
	NSManagedObjectContext *managedObjectContext;
}

@property (nonatomic, retain) Wikipedia_MobileAppDelegate *appDelegate;

@property (nonatomic, retain) NSString *wikiEntryURL;
@property (nonatomic, retain) NSString *pageTitle;
@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (nonatomic, retain) MapViewController *superView;

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;	

- (IBAction)addBookmark;
- (IBAction)showHistory;
- (void)showLoadingHUD;
- (void)addRecentPage:(NSString *)pageName;
- (void)addBookmark:(NSString *)pageName;

@end
