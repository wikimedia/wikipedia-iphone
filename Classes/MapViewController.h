//
//  MapViewController.h
//  Wikipedia Mobile
//
//  Created by Andreas Lengyel on 2/13/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "CLController.h"
#import "WikiConnectionController.h"


@class SBJsonParser;

@interface MapViewController : UIViewController <MKMapViewDelegate, CLControllerDelegate, CLLocationManagerDelegate, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource> {
	MKMapView *mapView;
	CLController *locationController;
	NSMutableArray *annotations;
	UINavigationController *navController;
	BOOL firstLoad;
	UITableView *tableView;
	CLLocationCoordinate2D currentLocation;
	UIBarButtonItem *locationBtn;
	UISegmentedControl *mapListSwitch;
	UISearchBar *searchBar;
    SBJsonParser *parser;
}

@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (nonatomic, retain) NSMutableArray *annotations;
@property (nonatomic, retain) IBOutlet UINavigationController *navController;
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic) CLLocationCoordinate2D currentLocation;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *locationBtn;
@property (nonatomic, retain) IBOutlet UISegmentedControl *mapListSwitch;
@property (nonatomic, retain) IBOutlet UISearchBar *searchBar;
@property float latitude;
@property float longitude;

- (IBAction)toggleMapAndListView:(id)tabs;
- (IBAction)dismissModalView;
- (IBAction)centerCurrentLocation;
- (void)locationUpdate:(CLLocation *)location; 
- (void)locationError:(NSError *)error;
- (void)fetchWikiPagesWithLatitude:(float)latitude longitude:(float)longitude;
- (void)refetchWikiPagesWithLatitude:(float)latitude longitude:(float)longitude;
- (void)fetchWikiPagesAtLocation:(NSString *)location;
- (void)processWikiPagesWithLatitude:(NSMutableData*) response;
- (void)processRefetchWikiPagesWithLatitude:(NSMutableData*) response;
- (void)processFetchWikiPagesAtLocation:(NSMutableData*) response;


@end
