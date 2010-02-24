//
//  MapViewController.m
//  Wikipedia Mobile
//
//  Created by Andreas Lengyel on 2/13/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "MapViewController.h"
#import "WikiViewController.h"
#import "JSON.h"

#pragma mark MKAnnotation subclass

@interface AddressAnnotation : NSObject <MKAnnotation> {
	CLLocationCoordinate2D coordinate;
	NSString *title;
	NSString *subtitle;
	NSString *mURL;
}

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *subtitle;
@property (nonatomic, retain) NSString *mURL;

@end

@implementation AddressAnnotation

@synthesize coordinate, title, subtitle, mURL;

- (NSString *)mURL {
	return mURL;
}

- (NSString *)subtitle {
	return subtitle;
}

- (NSString *)title {
	return title;
}

- (id)initWithCoordinate:(CLLocationCoordinate2D)coords {
	coordinate = coords;
	return self;
}

@end

#pragma mark MapViewController

@implementation MapViewController

@protocol AddressAnnotation;

@synthesize mapView, annotations, navController;


- (void)locationUpdate:(CLLocation *)location {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	[locationController.locationManager stopUpdatingLocation];
	
	[self fetchWikiPagesWithLatitude:location.coordinate.latitude longitude:location.coordinate.longitude];
}

- (void)locationError:(NSError *)error {
	UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error description] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[errorAlert show];
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	[locationController.locationManager stopUpdatingLocation];
	[errorAlert release];
}

- (void)viewWillAppear:(BOOL)animated {
	//[navController setToolbarHidden:NO animated:NO];
}

- (void)viewDidLoad {
	navController.view.frame = CGRectMake(0, 0, 320.0f, 460.0f);
	[self.view addSubview:navController.view];
    [super viewDidLoad];
	
	firstLoad = YES;
	locationController = [[CLController alloc] init];
	locationController.delegate = self;
	[locationController.locationManager startUpdatingLocation];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)viewDidAppear:(BOOL)animated {
}

- (void)fetchWikiPagesWithLatitude:(float)latitude longitude:(float)longitude {
	SBJSON *parser = [[SBJSON alloc] init];
	
	NSString *urlString = [NSString stringWithFormat:@"http://ws.geonames.org/findNearbyWikipediaJSON?formatted=true&lat=%f&lng=%f&style=full", latitude, longitude];
	
	NSURL *url = [NSURL URLWithString:urlString];
	NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
	
	NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
	NSString *jsonString = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
	
	NSMutableArray *items = [[parser objectWithString:jsonString error:nil] objectForKey:@"geonames"];
	
	MKCoordinateRegion region;
	MKCoordinateSpan span;
	span.latitudeDelta = 0.2;
	span.longitudeDelta = 0.2;
	
	CLLocationCoordinate2D location;
    location.latitude = latitude;
    location.longitude = longitude;
	region.span = span;
	region.center = location;
	
	annotations = [[NSMutableArray alloc] init];
	
	for (NSDictionary *item in items)
	{
		AddressAnnotation *annotation;
		
		CLLocationCoordinate2D pointLocation;
		pointLocation.latitude = [[item valueForKey:@"lat"] floatValue];
		pointLocation.longitude = [[item valueForKey:@"lng"] floatValue];
		
		NSString *title = [item valueForKey:@"title"];
		NSString *subtitle = [item valueForKey:@"summary"];
		NSString *url = [item valueForKey:@"wikipediaUrl"];
		
		annotation = [[AddressAnnotation alloc] initWithCoordinate:pointLocation];
		annotation.title = title;
		annotation.subtitle = subtitle;
		annotation.mURL = url;
		[annotations addObject:annotation];
		[annotation release];
	}
	[mapView addAnnotations:annotations];
	 
	[mapView setRegion:region animated:TRUE];
	[mapView regionThatFits:region];
	
	[jsonString release];
	[request release];
	[parser release];
	firstLoad = NO;
}

- (MKAnnotationView *)mapView:(MKMapView *)wikiMapView viewForAnnotation:(id <MKAnnotation>)annotation {
    MKPinAnnotationView *annotationView = nil;
	if (annotation != mapView.userLocation) {
		annotationView = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"currentloc"] autorelease];
		annotationView.pinColor = MKPinAnnotationColorPurple;
		annotationView.animatesDrop = YES;
		annotationView.canShowCallout = YES;
		annotationView.calloutOffset = CGPointMake(-5, 5);
		
		UIButton *disclosureButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
		
		annotationView.rightCalloutAccessoryView = disclosureButton;
	} else {
		CLLocation *location;
		location = [[CLLocation alloc] 
								initWithLatitude:annotation.coordinate.latitude
								longitude:annotation.coordinate.longitude];
		[location release];
	}
    return annotationView;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
	AddressAnnotation *annotation = (AddressAnnotation *)view.annotation;
	
	NSString *annotationURL = [NSString stringWithFormat:@"http://%@", annotation.mURL];
	WikiViewController *wikiViewController = [[WikiViewController alloc] initWithNibName:@"WikiViewController" bundle:nil];
	wikiViewController.wikiEntryURL = [NSURL URLWithString:annotationURL];
	wikiViewController.title = annotation.title;
	[navController pushViewController:wikiViewController animated:YES];
	[wikiViewController release];
}

- (void)mapViewWillStartLoadingMap:(MKMapView *)wikiMapView {
	[mapView removeAnnotations:annotations];
}

- (void)mapViewDidFinishLoadingMap:(MKMapView *)wikiMapView {
	if (!firstLoad) {
		[self refetchWikiPagesWithLatitude:mapView.region.center.latitude longitude:mapView.region.center.longitude];
	}
}

- (void)refetchWikiPagesWithLatitude:(float)latitude longitude:(float)longitude {
	SBJSON *parser = [[SBJSON alloc] init];
	
	NSString *urlString = [NSString stringWithFormat:@"http://ws.geonames.org/findNearbyWikipediaJSON?formatted=true&lat=%f&lng=%f&style=full", latitude, longitude];
	
	NSURL *url = [NSURL URLWithString:urlString];
	NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
	
	NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
	NSString *jsonString = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
	
	NSMutableArray *items = [[parser objectWithString:jsonString error:nil] objectForKey:@"geonames"];
	
	annotations = [[NSMutableArray alloc] init];
	
	for (NSDictionary *item in items) {
		AddressAnnotation *annotation;
		
		CLLocationCoordinate2D pointLocation;
		pointLocation.latitude = [[item valueForKey:@"lat"] floatValue];
		pointLocation.longitude = [[item valueForKey:@"lng"] floatValue];
		
		NSString *title = [item valueForKey:@"title"];
		NSString *subtitle = [item valueForKey:@"summary"];
		NSString *url = [item valueForKey:@"wikipediaUrl"];
		
		annotation = [[AddressAnnotation alloc] initWithCoordinate:pointLocation];
		annotation.title = title;
		annotation.subtitle = subtitle;
		annotation.mURL = url;
		[annotations addObject:annotation];
		[annotation release];
	}
	
	[mapView addAnnotations:annotations];
	
	[jsonString release];
	[request release];
	[parser release];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (IBAction)dismissModalView {
	[self dismissModalViewControllerAnimated:YES];
	
	[locationController.locationManager stopUpdatingLocation];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
	[mapView release];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
	[locationController release];
}


@end
