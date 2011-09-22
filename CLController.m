//
//  CLController.m
//  Wikipedia Mobile
//
//  Created by Andreas Lengyel on 2/16/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "CLController.h"


#pragma mark CLLocationController

@implementation CLController

@synthesize locationManager;
@synthesize delegate;

- (id) init {
	self = [super init];
	if (self != nil) {
		self.locationManager = [[[CLLocationManager alloc] init] autorelease];
		self.locationManager.delegate = self;
	}
	return self;
}

- (void)locationManager:(CLLocationManager *)manager
	didUpdateToLocation:(CLLocation *)newLocation
		   fromLocation:(CLLocation *)oldLocation
{
	[self.delegate locationUpdate:newLocation];
}


- (void)locationManager:(CLLocationManager *)manager
	   didFailWithError:(NSError *)error
{
	[self.delegate locationError:error];
}

- (void)dealloc {
	[locationManager release];
    [super dealloc];
}

@end
