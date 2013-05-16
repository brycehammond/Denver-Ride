//
//  BCycleViewController.m
//  BCycle
//
//  Created by bryce.hammond on 8/13/10.
//  Copyright Fluidvision Design, Inc. 2010. All rights reserved.
//

#import "BCycleViewController.h"
#import "StationAnnotation.h"
#import "Flurry.h"

#define kStationInfoKey @"StationInfoKey"

@interface BCycleViewController (Private)

- (void)loadStationsFromString:(NSString *)string stale:(BOOL)stale;

@end


@implementation BCycleViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	if((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]))
	{
		_stationsByName = [[NSMutableDictionary alloc] init];
	}
	
	return self;
}

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	[super loadView];
	
	[[self view] setFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [DenverRideConstants tallContainerHeight])];
	
	_mapView = [[MKMapView alloc] initWithFrame:[[self view] bounds]];
	[[self view] addSubview:_mapView];
	
	// Set the map type such as Standard, Satellite, Hybrid
	_mapView.mapType = MKMapTypeStandard;
	
	// Config user interactions
	_mapView.zoomEnabled = YES;
	_mapView.scrollEnabled = YES;
	
	// Set the region and zoom level
	MKCoordinateRegion region;
	MKCoordinateSpan span;
	CLLocationCoordinate2D location;
	location.latitude = 39.744154;
	location.longitude = -104.975739;
	span.latitudeDelta = 0.08;
	span.longitudeDelta = 0.08;
	region.span = span;
	region.center = location;
	// Set to that region with an animated effect
	[_mapView setRegion:region animated:TRUE];
	// Lastly, set the MKMapViewDelegate
	_mapView.delegate = self;
    
	_mapView.showsUserLocation = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [Flurry logEvent:@"BCycle View shown"];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self updateAnnotations];
}

- (void)updateStations:(NSArray *)stations;
{
	
	//if we don't have any stations yet,
	//set grab them and throw them into the map view
	if(nil == _stations)
	{
		
		_stations = stations;
		[_mapView addAnnotations:stations];
		for(StationAnnotation *station in _stations)
		{
			_stationsByName[[station title]] = station;
		}
	}
	else 
	{
		//go through and update the stations
		for(StationAnnotation *station in stations)
		{
			StationAnnotation *existingStation = _stationsByName[[station title]];
			if(existingStation)
			{
				[existingStation setBikesAvailable:[station bikesAvailable]];
				[existingStation setDocksAvailable:[station docksAvailable]];
				[existingStation setSubtitle:[station subtitle]];
			}
			else 
			{
				//don't have this station yet so add it
				_stationsByName[[station title]] = station;
				[_mapView addAnnotation:station];
			}

		}
		
	}
	
	[[NSNotificationCenter defaultCenter] postNotification:
	 [NSNotification notificationWithName:MKAnnotationCalloutInfoDidChangeNotification
								   object:nil]];
}

- (void)updateAnnotations
{
	NSString *stationConfig = [[NSUserDefaults standardUserDefaults] stringForKey:kStationInfoKey];
	if(nil == stationConfig)
	{
		NSError *error = nil;
		stationConfig = [NSString stringWithContentsOfFile:
						 [[NSBundle mainBundle] pathForResource:@"bcycle_stations" ofType:@"txt"]
												  encoding:NSUTF8StringEncoding
													 error:&error];
	}
	
	//load what we have in cache
	[self loadStationsFromString:stationConfig stale:YES];
	
	//load new data from the server
	NSURLRequest *request = [[NSURLRequest alloc] initWithURL:
							 [NSURL URLWithString:@"http://bcycle.semanticchickens.com/stations.txt"]];
	
	[_updateConnection setDelegate:nil];
	_updateConnection = [[EncapsulatedConnection alloc] initWithRequest:request delegate:self identifier:@"StationUpdate"];
	
}



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



#pragma mark MKMapViewDelegate methods

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
	// If it's the user location, just return nil.
	if ([annotation isKindOfClass:[MKUserLocation class]])
		return nil;
	
	// If it is our StationAnnotation, we create and return its view
	if ([annotation isKindOfClass:[StationAnnotation class]]) {
		// try to dequeue an existing pin view first
		static NSString* stationAnnotationIdentifier = @"StationAnnotationIdentifier";
		MKPinAnnotationView* pinView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:stationAnnotationIdentifier ];
		if (! pinView) 
		{
			// If an existing pin view was not available, create one
			MKPinAnnotationView* pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:stationAnnotationIdentifier];
			pinView.pinColor = MKPinAnnotationColorRed;
			pinView.animatesDrop = NO;
			pinView.canShowCallout = YES;
		} 
		else 
		{
			pinView.annotation = annotation;
		}
		
		return pinView;
	}
	
	return nil;
}

#pragma mark EncapsulatedConnectionDelegate methods

- (void)connection:(EncapsulatedConnection *)connection returnedWithData:(NSData *)data
{
	if(nil != data)
	{
		NSString *stationDataString = [[NSString alloc] initWithData:data
															encoding:NSUTF8StringEncoding];
		[self loadStationsFromString:stationDataString stale:NO];
	}
}

- (void)connection:(EncapsulatedConnection *)connection returnedWithError:(NSError *)error
{
	
}

@end

@implementation BCycleViewController (Private)


- (void)loadStationsFromString:(NSString *)string stale:(BOOL)stale
{
	NSMutableArray *newStations = [[NSMutableArray alloc] init];
						
	//Load up the station config into an array
	NSArray *lines = [string componentsSeparatedByString:@"\n"];
	for(NSString *line in lines)
	{
		NSArray *elements = [line componentsSeparatedByString:@"\t"];
		if([elements count] > 2)
		{
			StationAnnotation *station = [[StationAnnotation alloc] init];
			
			CLLocationCoordinate2D coordinate;
			coordinate.latitude = [elements[0] doubleValue];
			coordinate.longitude = [elements[1] doubleValue];
			
			[station setCoordinate:coordinate];
			
			[station setTitle:elements[2]];
			
			//If this isn't stale data and we have bike/dock available
			//data then populate it
			if(NO == stale && [elements count] > 4)
			{
				[station setBikesAvailable:elements[3]];
				[station setDocksAvailable:elements[4]];
			}
			
			[newStations addObject:station];
		}
	}
	
	if([newStations count] > 10) //make sure we have a decent amount before we save
	{
		[[NSUserDefaults standardUserDefaults] setObject:string forKey:kStationInfoKey];
		[self updateStations:newStations];
	}
	
}

@end
