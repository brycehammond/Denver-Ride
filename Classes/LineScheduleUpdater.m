//
//  LineScheduleUpdater.m
//  RTD
//
//  Created by bryce.hammond on 10/13/09.
//  Copyright 2009 Fluidvision Design. All rights reserved.
//

#import "LineScheduleUpdater.h"
#import "JSON.h"

@implementation LineScheduleUpdater

-(id)initWithMainWindow:(UIWindow *)window andManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
	if(self = [super init])
	{
		_window = window;
		_managedObjectContext = managedObjectContext;
	}
	
	return self;
}

-(void)startUpdate
{
	NSURLRequest *request = [NSURLRequest requestWithURL:
		[NSURL URLWithString:@"http://www.improbabilitydrive.com/RTD/updates.txt"]];
													
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
		
		if(returnString)
		{
			NSDictionary *parsedStructure = [returnString JSONValue];
			if([parsedStructure isKindOfClass:[NSDictionary class]])
			{
				NSLog(@"updates: %@",parsedStructure);
			}
		}
	}
}

- (void)connection:(EncapsulatedConnection *)connection returnedWithError:(NSError *)error
{
	
}

@end
