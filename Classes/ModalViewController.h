//
//  ModalViewController.h
//  Wikipedia Mobile
//
//  Created by Andreas Lengyel on 2/4/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RootViewController.h"

@interface ModalViewController : UIViewController <NSFetchedResultsControllerDelegate, UIActionSheetDelegate> {
	UITableView *tableView;
	UINavigationItem *navigationBar;
	
	NSFetchedResultsController *fetchedResultsController;
	NSManagedObjectContext *managedObjectContext;
	
	BOOL isBookmark;
	UISegmentedControl *bookmarkToggle;
	UIBarButtonItem *editButton;
	
	RootViewController *returnView;
}

@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IBOutlet UINavigationItem *navigationBar;

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, retain) IBOutlet UISegmentedControl *bookmarkToggle;
@property (nonatomic, retain) UIBarButtonItem *editButton;

@property (nonatomic, retain) RootViewController *returnView;
@property (nonatomic) BOOL isBookmark;

- (IBAction)dismissModalView;
- (IBAction)enterEditMode;

- (IBAction)bookmarkToggle:(id)bookmarkToggle;

@end
