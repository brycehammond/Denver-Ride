//
//  StationAnnotation.m
//  BCycle
//
//  Created by bryce.hammond on 8/13/10.
//  Copyright 2010 Fluidvision Design. All rights reserved.
//

#import "DRStationAnnotation.h"


@implementation DRStationAnnotation

@synthesize bikesAvailable = _bikesAvailable;
@synthesize docksAvailable = _docksAvailable;
@synthesize title = _title;
@synthesize subtitle = _subtitle;

- (void)setBikesAvailable:(NSString *)bikesAvailable
{
	//this is changing the subtitle too so trigger KVO notifcations
	[self willChangeValueForKey:@"bikesAvailable"];
	if(_bikesAvailable != bikesAvailable)
	{
		_bikesAvailable = bikesAvailable;
	}
	
	if([_bikesAvailable length] > 0 && [_docksAvailable length] > 0)
	{
		[self setSubtitle:[NSString stringWithFormat:
					 @"Bikes Available: %@ Docks Available: %@",
					 _bikesAvailable, _docksAvailable]];
	}
	
	[self didChangeValueForKey:@"bikesAvailable"];
}

- (void)setDocksAvailable:(NSString *)docksAvailable
{
	//this is changing the subtitle too so trigger KVO notifcations
	[self willChangeValueForKey:@"docksAvailable"];
	if(_docksAvailable != docksAvailable)
	{
		_docksAvailable = docksAvailable;
	}
	
	if([_bikesAvailable length] > 0 && [_docksAvailable length] > 0)
	{
		[self setSubtitle:[NSString stringWithFormat:
						   @"Bikes Available: %@ Docks Available: %@",
						   _bikesAvailable, _docksAvailable]];

	}

	[self didChangeValueForKey:@"docksAvailable"];
}


- (CLLocationCoordinate2D)coordinate
{
	return _location;
}

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate
{
	_location = newCoordinate;
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"%@ %@ : %@",[super description], [self title], [self subtitle]];
}


@end
