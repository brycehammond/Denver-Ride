//
//  DatabaseUpdater.m
//  RTD
//
//  Created by bryce.hammond on 9/26/10.
//  Copyright 2010 Fluidvision Design. All rights reserved.
//

#import "DatabaseUpdater.h"
#import "Constants.h"
#import "JSON.h"
#import "RTDAppDelegate.h"
#import "FlurryAPI.h"
#import "NSData+gzip.h"

@interface DatabaseUpdater (Private)
- (void)showUpdateAlert;
- (void)performUpdate;

- (void)showLoadingView;
- (void)hideLoadingView;
@end

@implementation DatabaseUpdater

@synthesize delegate;

+ (void)initialize
{
    if(nil == [[NSUserDefaults standardUserDefaults]
               stringForKey:kLastUpdateDateKey])
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"20110216" forKey:kLastUpdateDateKey];
    }
    
}

-(void)startUpdate
{
	NSURLRequest *request = [NSURLRequest requestWithURL:
							 [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kBasePath,@"updates.txt"]]];
    
    if(nil == _updateCheckConnection)
    {
        _updateCheckConnection = [[EncapsulatedConnection alloc] initWithRequest:request delegate:self identifier:@"updateCheck"];
    }
}

- (void)showUpdateAlert
{
	UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"Updates Available"
														 message:@"Schedule updates are available  Would you like to update now?"
													    delegate:self 
											   cancelButtonTitle:@"NO" otherButtonTitles:@"YES",nil] autorelease];
	[alertView show];
}

- (void)dealloc
{
    [_updateCheckConnection release];
	[_databaseUpdateConnection release];
	[_loadingView release];
	[_newDatabaseFileName release];
    [_newDatabaseLocalFileName release];
	[_newUpdateDate release];
    [super dealloc];
}

#pragma mark EncapsulatedConnectionDelegate methods

- (void)connection:(EncapsulatedConnection *)connection returnedWithData:(NSData *)data
{
	@try 
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
					NSString *date = [parsedStructure objectForKey:@"updateDate"];
					NSString *file = [parsedStructure objectForKey:@"updateFile"];
					
					if(date && file)
					{
						NSString *currentDate = [[NSUserDefaults standardUserDefaults]
												 stringForKey:kLastUpdateDateKey];
						if(NSOrderedDescending == [date compare:currentDate])
						{
							_newDatabaseFileName = [file retain];
                            _newDatabaseLocalFileName = [[file stringByReplacingOccurrencesOfString:@".gz" withString:@""] retain];
							_newUpdateDate = [date retain];
							[self showUpdateAlert];
						}
					}
					
				}
			}
            
            [_updateCheckConnection release];
            _updateCheckConnection = nil;
		}
		else if([[connection identifier] isEqualToString:@"DatabaseUpdate"])
		{
			RTDAppDelegate *appDelegate = (RTDAppDelegate *)[[UIApplication sharedApplication] delegate];
			
            if([_newDatabaseFileName hasSuffix:@".gz"])
            {
                //we should decompress the data
                data = [data gzipInflate];
            }
            
            
			[data writeToFile:[[appDelegate applicationDocumentsDirectory] stringByAppendingPathComponent:
							   _newDatabaseLocalFileName] atomically:YES];
			
			
			[_downloadProgressTimer invalidate];
			[_downloadProgressTimer release];
			_downloadProgressTimer = nil;
			
			[delegate newDatabaseAvailableWithFilename:_newDatabaseLocalFileName andDate:_newUpdateDate];
            
            [delegate databaseUpdateFinished];
            
            [self hideLoadingView];
            [_loadingView setDownloadProgress:0];
            
            [_databaseUpdateConnection release];
            _databaseUpdateConnection = nil;
		}
		
	}
	@catch (NSException * e) 
	{
		[FlurryAPI logError:@"Uncaught Exception" message:@"exception thrown during update" error:nil];
	}
}

- (void)connection:(EncapsulatedConnection *)connection returnedWithError:(NSError *)error
{
    if([[connection identifier] isEqualToString:@"updateCheck"])
    {
        [_updateCheckConnection release];
        _updateCheckConnection = nil;
    }
    else 
    {
        [_databaseUpdateConnection release];
        _databaseUpdateConnection = nil;
    }
    
	[_downloadProgressTimer invalidate];
	[_downloadProgressTimer release];
	_downloadProgressTimer = nil;
}

#pragma mark UIAlertView delegate methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	NSString *buttonName = [alertView buttonTitleAtIndex:buttonIndex];
	if([buttonName isEqualToString:@"YES"])
	{
        [delegate databaseUpdateStarted];
		[self showLoadingView];
		NSURLRequest *request = [NSURLRequest requestWithURL:
								 [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kBasePath,_newDatabaseFileName]]];
		
		_databaseUpdateConnection = [[EncapsulatedConnection alloc] initWithRequest:request delegate:self identifier:@"DatabaseUpdate"];	
	
		_downloadProgressTimer = [[NSTimer scheduledTimerWithTimeInterval:1.0 target:self
																 selector:@selector(updateProgress:)
																 userInfo:nil
																  repeats:YES] retain];
	}
	else 
	{
		[self hideLoadingView];
	}
}

- (void)updateProgress:(NSTimer *)timer
{
	[_loadingView setDownloadProgress:[_databaseUpdateConnection downloadPercentage]];
}
								  
#pragma mark LoadingView methods

- (void)showLoadingView;
{
	RTDAppDelegate *appDelegate = (RTDAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	if(! _loadingView)
	{
		_loadingView = [[LoadingView alloc] initWithFrame:[[appDelegate window] bounds]];
	}
	
	[_loadingView setMessage:@"Updating schedules"];
	
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
