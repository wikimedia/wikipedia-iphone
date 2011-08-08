//
//  ModalViewController.m
//  Wikipedia Mobile
//
//  Created by Andreas Lengyel on 2/4/10.
//  Copyright 2010 Wikimedia Foundation. All rights reserved.
//

#import "ModalViewController.h"

@implementation ModalViewController

@synthesize tableView;
@synthesize fetchedResultsController, managedObjectContext;
@synthesize bookmarkToggle, navigationBar, editButton, returnView, isBookmark;

/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
    }
    return self;
}
*/

- (void)viewWillAppear:(BOOL)animated {
	if (!isBookmark) {
		navigationBar.title = NSLocalizedString(@"History", @"History");
		
		UIBarButtonItem *clearAll = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Clear", @"Clear")
																	 style:UIBarButtonItemStylePlain
																	target:self
																	action:@selector(clearHistorySheet)];
		
                [clearAll autorelease];
		[navigationBar setLeftBarButtonItem:clearAll animated:YES];
		bookmarkToggle.selectedSegmentIndex = 1;
                
	}
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	editButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Edit", @"Edit")
 											   style:UIBarButtonItemStylePlain
   											  target:self
											  action:@selector(enterEditMode)];
	
	[navigationBar setLeftBarButtonItem:editButton animated:YES];
	
	NSError *error = nil;
	if (![[self fetchedResultsController] performFetch:&error]) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	}
}

- (IBAction)dismissModalView {
	[self dismissModalViewControllerAnimated:YES];
}


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
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

#pragma mark Table view methods

- (IBAction)enterEditMode {
	UIBarButtonItem *editingButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Edit", @"Edit")
												  style:UIBarButtonItemStyleDone
												 target:self
												 action:@selector(exitEditModeWithButtonSwap)];
	
        [editingButton autorelease];
	[navigationBar setLeftBarButtonItem:editingButton animated:NO];
	
	[tableView setEditing:YES animated:YES];
}

- (void)exitEditMode {
	if (tableView.editing) {
		[tableView setEditing:NO animated:YES];
	}
}

- (void)exitEditModeWithButtonSwap {
	if (tableView.editing) {
		[tableView setEditing:NO animated:YES];
		[navigationBar setLeftBarButtonItem:editButton animated:NO];
	}
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[fetchedResultsController sections] count];
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [[fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell;
    
	if (isBookmark) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
	} else {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
	}
	
	NSManagedObject *managedObject = [fetchedResultsController objectAtIndexPath:indexPath];
	
	cell.textLabel.font = [UIFont boldSystemFontOfSize:20.0f];
	if (isBookmark) {
		cell.textLabel.text = [[managedObject valueForKey:@"pageName"] description];
	} else {
		NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
		[dateFormat setDateFormat:@"MMM dd"];
		
		NSString *formattedDate = [dateFormat stringFromDate:[managedObject valueForKey:@"dateVisited"]];
		NSString *pageTitle = [[managedObject valueForKey:@"pageName"] description];
		if (pageTitle.length > 22) {
			pageTitle = [pageTitle stringByPaddingToLength:22 withString:nil startingAtIndex:0];
			pageTitle = [pageTitle stringByAppendingString:@"..."];
		}
		cell.textLabel.text = pageTitle;
		cell.detailTextLabel.text = formattedDate;
		cell.detailTextLabel.font = [UIFont systemFontOfSize:14.0f];
                
                [dateFormat release];
	}
	
	cell.imageView.image = [UIImage imageNamed:@"UITabBarBookmarksTemplate.png"];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSManagedObject *managedObject = [fetchedResultsController objectAtIndexPath:indexPath];
	[returnView loadURL:[[managedObject valueForKey:@"pageURL"] description]];
	
	[self dismissModalViewControllerAnimated:YES];
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the managed object for the given index path
		NSManagedObjectContext *context = [fetchedResultsController managedObjectContext];
		[context deleteObject:[fetchedResultsController objectAtIndexPath:indexPath]];
		
		// Save the context.
		NSError *error = nil;
		if (![context save:&error]) {
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		}
	}   
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/



// Override to support rearranging the table view.

/*
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
	if (isBookmark) {
		return NO;
	} else {
		return NO;
	}
}


- (NSFetchedResultsController *)fetchedResultsController {    
	// Create the fetch request for the entity.
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	
	// Edit the entity name as appropriate.
	NSEntityDescription *entity;
	if (isBookmark) {
		entity = [NSEntityDescription entityForName:@"Bookmark" inManagedObjectContext:managedObjectContext];
	} else {
		entity = [NSEntityDescription entityForName:@"RecentPage" inManagedObjectContext:managedObjectContext];
	}
	
	[fetchRequest setEntity:entity];
	
	// Set the batch size to a suitable number.
	[fetchRequest setFetchBatchSize:500];
	
	// Edit the sort key as appropriate.
	NSSortDescriptor *sortDescriptor;
	if (isBookmark) {
		sortDescriptor = nil;
		//sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"pageName" ascending:YES];
	} else {
		sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"dateVisited" ascending:NO];
	}
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
	
	[fetchRequest setSortDescriptors:sortDescriptors];
	
	NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:@"Root"];
    aFetchedResultsController.delegate = self;
	self.fetchedResultsController = aFetchedResultsController;
	
	[aFetchedResultsController release];
	[fetchRequest release];
	[sortDescriptor release];
	[sortDescriptors release];
	
	return fetchedResultsController;
}    

// NSFetchedResultsControllerDelegate method to notify the delegate that all section and object changes have been processed. 
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
	if (isBookmark) {
		[self exitEditModeWithButtonSwap];
	} else {
		[self exitEditMode];
	}
	
	NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:0];
	[tableView beginUpdates];
	[tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationFade];
	[tableView endUpdates];
}


- (void)clearHistory {
	NSFetchRequest *recentPages = [[NSFetchRequest alloc] init];
	[recentPages setEntity:[NSEntityDescription entityForName:@"RecentPage" inManagedObjectContext:managedObjectContext]];
	
	NSError *error = nil;
	NSArray *_recentPages = [managedObjectContext executeFetchRequest:recentPages error:&error];
	[recentPages release];
	
	for (NSManagedObject *page in _recentPages) {
		[managedObjectContext deleteObject:page];
	}
}


- (IBAction)bookmarkToggle:(id)bookmarkToggle {
	[self exitEditMode];
	
	switch([self.bookmarkToggle selectedSegmentIndex])
	{
		case 0: {
			isBookmark = YES;
			navigationBar.title = NSLocalizedString(@"Bookmarks", @"Bookmarks");
			[navigationBar setLeftBarButtonItem:editButton animated:YES];
		}; break;
		case 1: {
			isBookmark = NO;
			navigationBar.title = NSLocalizedString(@"History", @"History");
			
			UIBarButtonItem *clearAll = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Clear", @"Clear")
														  style:UIBarButtonItemStylePlain
														 target:self
														 action:@selector(clearHistorySheet)];
			
			[clearAll autorelease];
                        [navigationBar setLeftBarButtonItem:clearAll animated:YES];
		}; break;
		default: break;
	}
	NSError *error = nil;
	if (![[self fetchedResultsController] performFetch:&error]) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	}
	NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:0];
	[tableView beginUpdates];
	[tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationFade];
	[tableView endUpdates];
	[tableView setContentOffset:CGPointMake(0, 0) animated:YES];
}

#pragma mark sheets

- (void)clearHistorySheet {
	UIActionSheet *menu = [[UIActionSheet alloc]
						   initWithTitle:nil
						   delegate:self
						   cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
						   destructiveButtonTitle:NSLocalizedString(@"Clear History", @"Clear History")
						   otherButtonTitles:nil, nil];
	menu.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
	[menu showInView:self.view];
        [menu release];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(int)buttonIndex
{		
	if(buttonIndex == 0)
	{
		[self clearHistory];
	}
}

- (void)dealloc {
	[fetchedResultsController release];
	[managedObjectContext release];
    [super dealloc];
}

#pragma mark reorder entries

@end

