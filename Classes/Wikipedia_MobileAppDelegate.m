//
//  Wikipedia_MobileAppDelegate.m
//  Wikipedia Mobile
//
//  Created by Andreas Lengyel on 2/3/10.
//  Copyright Wikimedia Foundation 2010. All rights reserved.
//

#import "Wikipedia_MobileAppDelegate.h"
#import "RootViewController.h"
#import "ModalViewController.h"

@implementation Wikipedia_MobileAppDelegate

@synthesize window;
@synthesize navigationController;
@synthesize settings;

#pragma mark -
#pragma mark Application lifecycle

- (void)applicationDidFinishLaunching:(UIApplication *)application {    
    settings = [NSUserDefaults standardUserDefaults];
	if ([settings stringForKey:@"languageKey"] == NULL) {
		[settings setObject:@"en" forKey:@"languageKey"];
		[settings setObject:@"English" forKey:@"languageName"];
	}
	
	[window addSubview:[navigationController view]];
	[window makeKeyAndVisible];
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSArray *languages = [defaults objectForKey:@"AppleLanguages"];
	NSString *currentLanguage = [languages objectAtIndex:0];
	NSLog(@"langSetting: %@", currentLanguage);
}

- (void)applicationWillTerminate:(UIApplication *)application {
	// Save data if appropriate
	
    NSError *error = nil;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
			NSString *errorString = [NSString stringWithFormat:@"%@ - %@", error, [error userInfo]];
			UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Database Error", @"Database Error") message:errorString delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
			[errorAlert show];
                        [errorAlert release];
        } 
    }
}

#pragma mark - 
#pragma mark Multitasking support

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
}

- (void)applicationWillResignActive:(UIApplication *)application {
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    
}

#pragma mark -
#pragma mark Memory management

- (void)dealloc {
	[navigationController release];
	[window release];
	[super dealloc];
}

#pragma mark -
#pragma mark Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *) managedObjectContext {
	
    if (managedObjectContext != nil) {
        return managedObjectContext;
    }
	
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    return managedObjectContext;
}


/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created by merging all of the models found in the application bundle.
 */
- (NSManagedObjectModel *)managedObjectModel {
	
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
	NSArray *bundles = [NSArray arrayWithObject:[NSBundle mainBundle]];
    managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:bundles] retain];    
    return managedObjectModel;
}


/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
	
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
	
    NSURL *storeUrl = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"wikipedia.sqlite"]];
	
	NSError *error = nil;
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error]) {
		NSString *errorString = [NSString stringWithFormat:@"%@ - %@", error, [error userInfo]];
		UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Database Error", @"Database Error") message:errorString delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
		[errorAlert show];
                [errorAlert release];
    }    
	
    return persistentStoreCoordinator;
}


#pragma mark -
#pragma mark Application's Documents directory

/**
 Returns the path to the application's Documents directory.
 */
- (NSString *)applicationDocumentsDirectory {
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}


@end

