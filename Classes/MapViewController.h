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

@interface MapViewController : UIViewController <MKMapViewDelegate, CLControllerDelegate, CLLocationManagerDelegate> {
	MKMapView *mapView;
	CLController *locationController;
	NSMutableArray *annotations;
	UINavigationController *navController;
	BOOL firstLoad;
}

@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (nonatomic, retain) NSMutableArray *annotations;
@property (nonatomic, retain) IBOutlet UINavigationController *navController;

- (IBAction)dismissModalView;
- (void)locationUpdate:(CLLocation *)location; 
- (void)locationError:(NSError *)error;
- (void)fetchWikiPagesWithLatitude:(float)latitude longitude:(float)longitude;
- (void)refetchWikiPagesWithLatitude:(float)latitude longitude:(float)longitude;

@end
