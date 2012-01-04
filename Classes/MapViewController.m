//
//  MapViewController.m
//  Wikipedia Mobile
//
//  Created by Andreas Lengyel on 2/13/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "MapViewController.h"
#import "WikiViewController.h"
#import "SBJson.h"
#import "WikiConnectionController.h"

#pragma mark MKAnnotation subclass

@interface AddressAnnotation : NSObject <MKAnnotation> {
	CLLocationCoordinate2D coordinate;
	NSString *title;
	NSString *subtitle;
	NSString *mURL;
}

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
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
@synthesize latitude, longitude;

@synthesize mapView, annotations, navController, tableView, currentLocation, locationBtn, mapListSwitch, searchBar;


- (void)locationUpdate:(CLLocation *)location {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	[locationController.locationManager stopUpdatingLocation];
	
	[self fetchWikiPagesWithLatitude:location.coordinate.latitude longitude:location.coordinate.longitude];
	currentLocation.latitude = location.coordinate.latitude;
	currentLocation.longitude = location.coordinate.longitude;
}

- (void)locationError:(NSError *)error {
	UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Oops", @"Oops") message:@"Sorry, could not find your location." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
	[errorAlert show];
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	[locationController.locationManager stopUpdatingLocation];
	[errorAlert release];
}

- (void)viewWillAppear:(BOOL)animated {
}

- (void)viewDidLoad {
	navController.view.frame = CGRectMake(0, 0, 320.0f, 460.0f);
	[self.view addSubview:navController.view];
    [super viewDidLoad];
	
	mapListSwitch.enabled = NO;
	firstLoad = YES;
	locationController = [[CLController alloc] init];
	locationController.delegate = self;
	[locationController.locationManager startUpdatingLocation];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)connectionSucceeded:(NSMutableData*)data {
    NSString *response = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"Response: %@", response);
    [self processWikiPagesWithLatitude:data];
    [response release];
}
- (void)connectionFailed:(NSError*)error {
    // error contains reason for failure
}

- (void)refetchConnectionSucceeded:(NSMutableData*)data {
    NSString *response = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"Response: %@", response);
    [self processRefetchWikiPagesWithLatitude:data];
    [response release];
}
- (void)refetchConnectionFailed:(NSError*)error {
    // error contains reason for failure
}

- (void)fetchWikiPagesAtLocationConnectionSucceeded:(NSMutableData*)data {
    NSString *response = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"Response: %@", response);
    [self processFetchWikiPagesAtLocation:data];
    [response release];
}
- (void)fetchWikiPagesAtLocationConnectionFailed:(NSError*)error {
    // error contains reason for failure
}

- (void)fetchWikiPagesWithLatitude:(float)latitudeC longitude:(float)longitudeC {
    
    self.latitude = latitudeC;
    self.longitude = longitudeC;
	
	NSString *urlString = [NSString stringWithFormat:@"http://ws.geonames.net/findNearbyWikipediaJSON?formatted=true&username=wikimedia&lat=%f&lng=%f&style=full", latitudeC, longitudeC];
    NSLog(@"Loading: %@", urlString);

    id delegate = self;
    WikiConnectionController *connectionController = [[[WikiConnectionController alloc] initWithDelegate:delegate selSucceeded:@selector(connectionSucceeded:) selFailed:@selector(connectionFailed:)] autorelease];
    [connectionController startRequestForURL:[NSURL URLWithString:urlString]];
}

- (void)processWikiPagesWithLatitude:(NSMutableData*) response {
    
    NSString *jsonString = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
    parser = [[SBJsonParser alloc] init];
    
	NSMutableArray *items = [[parser objectWithString:jsonString error:nil] objectForKey:@"geonames"];
	
	MKCoordinateRegion region;
	MKCoordinateSpan span;
	span.latitudeDelta = 0.2;
	span.longitudeDelta = 0.2;
	
	CLLocationCoordinate2D location;
    location.latitude = self.latitude;
    location.longitude = self.longitude;
	region.span = span;
	region.center = location;
	
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
	 
	[mapView setRegion:region animated:TRUE];
	[mapView regionThatFits:region];
	
	[jsonString release];
	[parser release];
	firstLoad = NO;
	mapListSwitch.enabled = YES;
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

- (void)mapView:(MKMapView *)wikiMapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
	AddressAnnotation *annotation = (AddressAnnotation *)view.annotation;
	
	NSString *annotationURL = [NSString stringWithFormat:@"http://%@", annotation.mURL];
	WikiViewController *wikiViewController = [[WikiViewController alloc] initWithNibName:@"WikiViewController" bundle:nil];
	wikiViewController.wikiEntryURL = annotationURL;
	wikiViewController.title = annotation.title;
	wikiViewController.superView = self;
	[navController pushViewController:wikiViewController animated:YES];

	[wikiViewController release];
}

- (void)mapViewWillStartLoadingMap:(MKMapView *)wikiMapView {
}

- (void)mapView:(MKMapView *)wikiMapView regionWillChangeAnimated:(BOOL)animated {
	
}

- (void)mapView:(MKMapView *)wikiMapView regionDidChangeAnimated:(BOOL)animated {

#warning add region check here + NSTimer delay
	
	//[mapView removeAnnotations:annotations];
	if (!firstLoad) {
		//[self refetchWikiPagesWithLatitude:mapView.region.center.latitude longitude:mapView.region.center.longitude];
	}
}

- (void)mapViewDidFinishLoadingMap:(MKMapView *)wikiMapView {
	
}

- (void)refetchWikiPagesWithLatitude:(float)latitudeC longitude:(float)longitudeC {
    
    self.latitude = latitudeC;
    self.longitude = longitudeC;
	
	NSString *urlString = [NSString stringWithFormat:@"http://ws.geonames.net/findNearbyWikipediaJSON?formatted=true&username=wikimedia&lat=%f&lng=%f&style=full", latitudeC, longitudeC];
	NSLog(@"Loading: %@", urlString);
    
    id delegate = self;
    WikiConnectionController *connectionController = [[[WikiConnectionController alloc] initWithDelegate:delegate selSucceeded:@selector(refetchConnectionSucceeded:) selFailed:@selector(refetchConnectionFailed:)] autorelease];
    [connectionController startRequestForURL:[NSURL URLWithString:urlString]];
}

- (void)processRefetchWikiPagesWithLatitude:(NSMutableData*) response {
    
    NSString *jsonString = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
    parser = [[SBJsonParser alloc] init];
	
	NSMutableArray *items = [[parser objectWithString:jsonString error:nil] objectForKey:@"geonames"];
  
	NSLog(@"Got back %i items from geo service", [items count]);
	
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
	[parser release];
}

#pragma mark searchBar

- (void)scrollViewWillBeginDragging:(UIScrollView *)_tableView {
	[searchBar resignFirstResponder];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)_searchBar {
	[searchBar resignFirstResponder];
	[self fetchWikiPagesAtLocation:searchBar.text];
}

- (void)fetchWikiPagesAtLocation:(NSString *)locationC {
    
	NSString *urlString = [NSString stringWithFormat:@"http://ws.geonames.net/wikipediaSearchJSON?formatted=true&q=%@&maxRows=10&style=full&username=wikimedia", locationC];
	NSLog(@"Loading: %@", urlString);
    
    id delegate = self;
    WikiConnectionController *connectionController = [[[WikiConnectionController alloc] initWithDelegate:delegate selSucceeded:@selector(fetchWikiPagesAtLocationConnectionSucceeded:) selFailed:@selector(fetchWikiPagesAtLocationConnectionFailed:)] autorelease];
    [connectionController startRequestForURL:[NSURL URLWithString:urlString]];
}

- (void)processFetchWikiPagesAtLocation:(NSMutableData*) response {

    NSString *jsonString = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
    parser = [[SBJsonParser alloc] init];
	
	NSMutableArray *items = [[parser objectWithString:jsonString error:nil] objectForKey:@"geonames"];
	
	NSLog(@"Got back %i items from geo service", [items count]);
	
	annotations = [[NSMutableArray alloc] init];
	
	CLLocationCoordinate2D newCenter = CLLocationCoordinate2DMake(0,0);
	
	for (NSDictionary *item in items) {
		AddressAnnotation *annotation;
		
		CLLocationCoordinate2D pointLocation;
		pointLocation.latitude = [[item valueForKey:@"lat"] floatValue];
		pointLocation.longitude = [[item valueForKey:@"lng"] floatValue];
		
		newCenter.latitude = [[item valueForKey:@"lat"] floatValue];
		newCenter.longitude = [[item valueForKey:@"lng"] floatValue];
		
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
 	[mapView setCenterCoordinate:newCenter animated:NO];
	
	[jsonString release];
	[parser release];
	[tableView reloadData];
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

#pragma mark List View

- (IBAction)toggleMapAndListView:(id)tabs
{
	switch([tabs selectedSegmentIndex]+1)
	{
		case 1: {
			tableView.hidden = YES;
		}; break;			
		case 2: {
			[tableView reloadData];
			tableView.hidden = NO;
		}; break;
		default: break;
	}
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [annotations count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	static NSString *CellIdentifier = @"Cell";
	UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
	
	cell.textLabel.text = [[annotations objectAtIndex:indexPath.row] title];
	cell.detailTextLabel.text = [[annotations objectAtIndex:indexPath.row] subtitle];
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	return [cell autorelease];
}


- (void)tableView:(UITableView *)mTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	AddressAnnotation *annotation = [annotations objectAtIndex:indexPath.row];
	
	NSString *annotationURL = [NSString stringWithFormat:@"http://%@", annotation.mURL];
	WikiViewController *wikiViewController = [[WikiViewController alloc] initWithNibName:@"WikiViewController" bundle:nil];
	wikiViewController.wikiEntryURL = annotationURL;
	wikiViewController.title = annotation.title;
	wikiViewController.superView = self;
	[navController pushViewController:wikiViewController animated:YES];
	[wikiViewController release];
}

- (IBAction)centerCurrentLocation {
	locationBtn.style = UIBarButtonItemStyleDone;
	locationBtn.image = [UIImage imageNamed:@"location.png"];
	[mapView setRegion:MKCoordinateRegionMake(currentLocation, MKCoordinateSpanMake(0.1f, 0.1f)) animated:YES];
}

- (IBAction)dismissModalView {
	[locationController.locationManager stopUpdatingLocation];
	mapView.delegate = nil;
	[mapView release];
	[self dismissModalViewControllerAnimated:YES];
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
	mapView.delegate = nil;
	[mapView release];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
	[locationController release];
}


@end
