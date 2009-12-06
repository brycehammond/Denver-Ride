//
//  LineScheduleUpdater.m
//  RTD
//
//  Created by bryce.hammond on 10/13/09.
//  Copyright 2009 Fluidvision Design. All rights reserved.
//

#import "LineScheduleUpdater.h"
#import "JSON.h"
#import "Line.h"
#import "Station.h"
#import "LineLoader.h"
#import "RTDAppDelegate.h"

#define kBasePath @"http://www.improbabilitydrive.com/RTD/"

@interface LineScheduleUpdater (Private)
- (NSString *)currentISODate;
- (void)updateRouteForSchedule:(NSString *)route;
- (void)updateRoutesFromDict:(NSDictionary *)routes;
- (void)performUpdate;
- (void)showUpdateAlert;

- (void)showLoadingView;
- (void)hideLoadingView;
@end


@implementation LineScheduleUpdater

+(void)initialize
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSDictionary *lastUpdated = [NSDictionary dictionaryWithObjectsAndKeys:
											@"20091014" , @"C_N_H",
											@"20091014" , @"C_N_S",
											@"20091014" , @"C_N_W",
											@"20091014" , @"C_S_W",
											@"20091014" , @"D_N_H",
											@"20091014" , @"D_N_S",
											@"20091014" , @"D_N_W",
											@"20091014" , @"D_S_H",
											@"20091014" , @"D_S_S",
											@"20091014" , @"D_S_W",
											@"20091014" , @"E_N_H",
											@"20091014" , @"E_N_S",
											@"20091014" , @"E_N_W",
											@"20091014" , @"E_S_H",
											@"20091014" , @"E_S_S",
											@"20091014" , @"E_S_W",
											@"20091014" , @"F_N_W",
											@"20091014" , @"F_S_H",
											@"20091014" , @"F_S_S",
											@"20091014" , @"F_S_W",
											@"20091014" , @"H_N_H",
											@"20091014" , @"H_N_S",
											@"20091014" , @"H_N_W",
											@"20091014" , @"H_S_H",
											@"20091014" , @"H_S_S",
											@"20091014" , @"H_S_W"
											, nil];
	
    NSDictionary *appDefaults = [NSDictionary
								 dictionaryWithObjectsAndKeys:lastUpdated,@"LineUpdateDates",nil];
	
    [defaults registerDefaults:appDefaults];
}

-(id)initWithMainWindow:(UIWindow *)window andManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
	if(self = [super init])
	{
		_window = window;
		_managedObjectContext = managedObjectContext;
		_linesToRoutesToUpdate = [[NSMutableDictionary alloc] init];
		_linesByName = [[NSMutableDictionary alloc] init];
		_stationsByID = [[NSMutableDictionary alloc] init];
		_routesToNewDates = [[NSMutableDictionary alloc] init];
	}
	
	return self;
}

- (void)dealloc
{
	[_linesToRoutesToUpdate release];
	[super dealloc];
}

-(void)startUpdate
{
	NSURLRequest *request = [NSURLRequest requestWithURL:
		[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kBasePath,@"updates.txt"]]];
													
	_updateCheckConnection = [[EncapsulatedConnection alloc] initWithRequest:request delegate:self identifier:@"updateCheck"];
}


- (void)connection:(EncapsulatedConnection *)connection returnedWithData:(NSData *)data
{
	if([[connection identifier] isEqualToString:@"updateCheck"])
	{
		NSString *returnString = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
		
		if(! returnString)
		{
			returnString = [[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding] autorelease];
		}
		
		//Strategy for updating:
		// 1. Check the structure by line
		// 2. go through schedule by daytype/direction
		// 3. If the date in the structure in newer than the date in our preferences
		//    then queue up a set to be updated for that line.  Add each schedule to
		//    the set that has been updated
		// 4. Ask the user if they want to update the data for the line
		// 5. If yes, start the update by downloading the updated routes.
		// 6. Delete any current route information and load the new information
		// 7. Commit the save only after that route has been updated completely
		//
		
		if(returnString)
		{
			NSDictionary *parsedStructure = [returnString JSONValue];
			if([parsedStructure isKindOfClass:[NSDictionary class]])
			{
				
				[self updateRoutesFromDict:parsedStructure];
			}
		}
	}
	else if([[connection identifier] isEqualToString:@"LineUpdate"])
	{
		NSString *returnString = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
		
		if(! returnString)
		{
			returnString = [[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding] autorelease];
		}
		
		if(returnString)
		{
			//load the new line
			[LineLoader loadStopData:returnString 
					 withLinesByName:_linesByName 
					 andStationsByID:_stationsByID 
			  inManagedObjectContext:_managedObjectContext];
			NSError *error = nil;
			[_managedObjectContext save:&error];
			
			if(error == nil)
			{
				NSMutableDictionary *lastUpdateTimes = [[[NSUserDefaults standardUserDefaults] objectForKey:@"LineUpdateDates"] mutableCopy];
				[lastUpdateTimes setObject:[_routesToNewDates objectForKey:_currentUpdateRoute] forKey:_currentUpdateRoute];
				[[NSUserDefaults standardUserDefaults] setObject:lastUpdateTimes forKey:@"LineUpdateDates"];
				[[NSUserDefaults standardUserDefaults] synchronize];
				[lastUpdateTimes release];
			}
		}
		
		//move to the next line if the current line is done
		//otherwise just do the next update
		if(! [_linesToRoutesToUpdate objectForKey:_currentUpdateLine] || 
		   [[_linesToRoutesToUpdate objectForKey:_currentUpdateLine] count] == 0)
		{
			[_linesToRoutesToUpdate removeObjectForKey:_currentUpdateLine];
			if([_linesToRoutesToUpdate count] > 0)
			{
				[_currentUpdateLine release];
				_currentUpdateLine = [[_linesToRoutesToUpdate allKeys] objectAtIndex:0];
				[self showUpdateAlert];
			}
			else {
				//we are done so hide the loading view
				[self hideLoadingView];
			}

		}
		else 
		{
			[self performUpdate];
		}

		
	}

}

- (void)connection:(EncapsulatedConnection *)connection returnedWithError:(NSError *)error
{	
	//gracefully fail and
	//move to the next line if the current line is done
	//otherwise just do the next update
	//we will see the update next time and ask them to update
	if(! _currentUpdateLine || ! [_linesToRoutesToUpdate objectForKey:_currentUpdateLine] || 
	   [[_linesToRoutesToUpdate objectForKey:_currentUpdateLine] count] == 0)
	{
		
		if(_currentUpdateLine && [_linesToRoutesToUpdate objectForKey:_currentUpdateLine])
		{
			[_linesToRoutesToUpdate removeObjectForKey:_currentUpdateLine];
		}
		
		if([_linesToRoutesToUpdate count] > 0)
		{
			[_currentUpdateLine release];
			_currentUpdateLine = [[_linesToRoutesToUpdate allKeys] objectAtIndex:0];
			[self showUpdateAlert];
		}
	}
	else 
	{
		[self performUpdate];
	}
}

@end

@implementation LineScheduleUpdater (Private)

- (NSString *)currentISODate
{
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"yyyyMMdd"];
	NSString *currentDate = [dateFormatter stringFromDate:[NSDate date]];
	[dateFormatter release];
	
	return currentDate;
}

- (void)updateRoutesFromDict:(NSDictionary *)routes
{
	//Create a structure for routes to update for certain lines
	NSMutableDictionary *lastUpdateTimes = [[NSUserDefaults standardUserDefaults] objectForKey:@"LineUpdateDates"];
	for(NSString *line in [routes allKeys])
	{
		NSDictionary *routesToUpdate = [routes objectForKey:line];
		if([routesToUpdate isKindOfClass:[NSDictionary class]])
		{
			for(NSString *route in [routesToUpdate allKeys])
			{
				NSString *routeToUpdate = [line stringByAppendingFormat:@"_%@",route];
				if(NSOrderedDescending == [[routesToUpdate objectForKey:route] 
										  compare:[lastUpdateTimes objectForKey:routeToUpdate]])
				{
					if(! [_linesToRoutesToUpdate objectForKey:line])
					{
						[_linesToRoutesToUpdate setObject:[NSMutableArray arrayWithObject:routeToUpdate] forKey:line];
					}
					else
					{
						[[_linesToRoutesToUpdate objectForKey:line] addObject:routeToUpdate];
					}
					
					[_routesToNewDates setObject:[routesToUpdate objectForKey:route]  forKey:routeToUpdate];
				}
			}
		}
	}
	
	if([_linesToRoutesToUpdate count] > 0)
	{
		//we have something to update so let's pull the stations
		//and the lines from the database
		
		NSFetchRequest *request = [[NSFetchRequest alloc] init];
		NSEntityDescription *entity = [NSEntityDescription entityForName:@"Line" inManagedObjectContext:_managedObjectContext];
		[request setEntity:entity];
		
		// Execute the fetch -- create a mutable copy of the result.
		NSError *error = nil;
		NSMutableArray *mutableFetchResults = [[_managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
		if (mutableFetchResults == nil) {
			// Handle the error.
		}
		
		for(Line *line in mutableFetchResults)
		{
			[_linesByName setObject:line forKey:[line name]];
		}
		
		[mutableFetchResults release];
		[request release];
		
		request = [[NSFetchRequest alloc] init];
		entity = [NSEntityDescription entityForName:@"Station" inManagedObjectContext:_managedObjectContext];
		[request setEntity:entity];
		
		mutableFetchResults = [[_managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
		if (mutableFetchResults == nil) {
			// Handle the error.
		}
		
		for(Station *station in mutableFetchResults)
		{
			[_stationsByID setObject:station forKey:[station stationID]];
		}
		
		[mutableFetchResults release];
		[request release];
		
		_currentUpdateLine = [[[_linesToRoutesToUpdate allKeys] objectAtIndex:0] retain];
		[self showUpdateAlert];
	}
}

- (void)showUpdateAlert
{
	UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Update for %@ Line",_currentUpdateLine] 
														 message:[NSString stringWithFormat:@"Schedule updates are available for the %@ Line.  Would you like to update now?",_currentUpdateLine] 
													    delegate:self 
														cancelButtonTitle:@"NO" otherButtonTitles:@"YES",nil] autorelease];
	[alertView show];
}

- (void)performUpdate
{
	
	//update the first route for the current line
	if([[_linesToRoutesToUpdate objectForKey:_currentUpdateLine] count] > 0)
	{
		NSString *route = [[[_linesToRoutesToUpdate objectForKey:_currentUpdateLine] objectAtIndex:0] retain];
		[[_linesToRoutesToUpdate objectForKey:_currentUpdateLine] removeObjectAtIndex:0];
		[self updateRouteForSchedule:route];
		[route release];
	}
	else {
		[self hideLoadingView];
	}

}

- (void)updateRouteForSchedule:(NSString *)route
{
	[_currentUpdateRoute release];
	_currentUpdateRoute = [route retain];
	NSURLRequest *request = [NSURLRequest requestWithURL:
							 [NSURL URLWithString:[NSString stringWithFormat:@"%@%@.txt",kBasePath,route]]];
	
	[_lineUpdateConnection release];
	_lineUpdateConnection = [[EncapsulatedConnection alloc] initWithRequest:request delegate:self identifier:@"LineUpdate"];
	
}

#pragma mark UIAlertVie delegate methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	NSString *buttonName = [alertView buttonTitleAtIndex:buttonIndex];
	if([buttonName isEqualToString:@"YES"])
	{
		[self showLoadingView];
		[self performUpdate];	
	}
	else 
	{
		[self hideLoadingView];
		[_linesToRoutesToUpdate removeObjectForKey:_currentUpdateLine];
		if([_linesToRoutesToUpdate count] > 0)
		{
			[_currentUpdateLine release];
			_currentUpdateLine = [[_linesToRoutesToUpdate allKeys] objectAtIndex:0];
			[self showUpdateAlert];
		}
	}
}

#pragma mark LoadingView methods

- (void)showLoadingView;
{
	RTDAppDelegate *appDelegate = (RTDAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	if(! _loadingView)
	{
		_loadingView = [[LoadingView alloc] initWithFrame:[[appDelegate window] bounds]];
	}
	
	[_loadingView setMessage:[NSString stringWithFormat:@"Updating %@ line schedule",_currentUpdateLine]];
	
	if(! [_loadingView superview])
	{
		[[appDelegate window] addSubview:_loadingView];
	}
}

- (void)hideLoadingView
{
	if([_loadingView superview])
	{
		[_loadingView removeFromSuperview];
	}
}

@end

