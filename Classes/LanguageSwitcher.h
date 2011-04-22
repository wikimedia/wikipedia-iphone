//
//  LanguageSwitcher.h
//  Wikipedia Mobile
//
//  Created by Andreas Lengyel on 2/8/10.
//  Copyright 2010 Wikimedia Foundation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RootViewController.h"

@interface LanguageSwitcher : UIViewController {
	NSMutableArray *languagesArray;
	UITableView *tableView;
	NSUserDefaults *settings;
	NSIndexPath *markedIndexPath;
	
	RootViewController *returnView;
}

@property (nonatomic, retain) NSMutableArray *languagesArray;
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) NSIndexPath *markedIndexPath;

@property (nonatomic, retain) RootViewController *returnView;

- (IBAction)dismissModalView;
- (void)toggleCheckmarkedCell:(UITableViewCell *)cell;

@end
