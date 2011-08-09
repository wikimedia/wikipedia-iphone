//
//  LanguageSwitcher.m
//  Wikipedia Mobile
//
//  Created by Andreas Lengyel on 2/8/10.
//  Copyright 2010 Wikimedia Foundation. All rights reserved.
//

#import "LanguageSwitcher.h"


@implementation LanguageSwitcher

@synthesize languagesArray, tableView, markedIndexPath, returnView;

/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
    }
    return self;
}
*/


- (void)viewDidLoad {
	[super viewDidLoad];
	
	NSString *languagesPlist = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"languages.plist"];
	languagesArray = [[NSMutableArray arrayWithContentsOfFile:languagesPlist] retain];
	
	settings = [NSUserDefaults standardUserDefaults];
}

- (IBAction)dismissModalView {
	returnView.appDelegate = (Wikipedia_MobileAppDelegate *)[[UIApplication sharedApplication] delegate];
	returnView.searchBar.scopeButtonTitles = [NSArray arrayWithObjects:[returnView.appDelegate.settings stringForKey:@"languageName"], NSLocalizedString(@"Set Language", @"Set Language"), nil];
	returnView.searchBar.selectedScopeButtonIndex = 0;
	
	[self dismissModalViewControllerAnimated:YES];
	//[returnView loadStartPage];
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
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [languagesArray count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	static NSString *CellIdentifier = @"Cell";
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
	
	NSMutableDictionary *dictItem = [languagesArray objectAtIndex:indexPath.row];
	cell.textLabel.text = [dictItem valueForKey:@"language"];
	
	if ([[dictItem valueForKey:@"path"] isEqualToString:[settings stringForKey:@"languageKey"]]) {
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
	} else {
		cell.accessoryType = UITableViewCellAccessoryNone;
	}

    return [cell autorelease];
}


- (void)tableView:(UITableView *)mTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	for (int i=0; i<[languagesArray count]; i++) {
		NSIndexPath *_indexPath = [NSIndexPath indexPathForRow:i inSection:0];
		UITableViewCell *deselectedCell = [tableView cellForRowAtIndexPath:_indexPath];
		deselectedCell.accessoryType = UITableViewCellAccessoryNone;
	}
	
	UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
	
	[self toggleCheckmarkedCell:cell];
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	NSMutableDictionary *dictItem = [languagesArray objectAtIndex:indexPath.row];
	[settings setObject:[dictItem valueForKey:@"path"] forKey:@"languageKey"];
	[settings setObject:[dictItem valueForKey:@"language"] forKey:@"languageName"];
}


- (void)toggleCheckmarkedCell:(UITableViewCell *)cell {
    if (cell.accessoryType == UITableViewCellAccessoryNone) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
	} else {
        cell.accessoryType = UITableViewCellAccessoryNone;
	}
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


- (void)dealloc {
    [super dealloc];
}


@end

