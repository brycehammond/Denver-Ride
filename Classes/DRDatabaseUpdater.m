//
//  DatabaseUpdater.m
//  RTD
//
//  Created by bryce.hammond on 9/26/10.
//  Copyright 2010 Fluidvision Design. All rights reserved.
//

#import "DRDatabaseUpdater.h"
#import "RTDAppDelegate.h"
#import "Flurry.h"
#import "NSData+gzip.h"
#import "SVProgressHUD.h"

@interface DRDatabaseUpdater (Private)
- (void)showUpdateAlert;
- (void)performUpdate;

- (void)showLoadingView;
- (void)hideLoadingView;
@end

@implementation DRDatabaseUpdater

@synthesize delegate;

+ (void)initialize
{
    if(nil == [[NSUserDefaults standardUserDefaults]
               stringForKey:kLastUpdateDateKey])
    {
        [[NSUserDefaults standardUserDefaults] setObject:kLastUpdateDate forKey:kLastUpdateDateKey];
    }
    
}

-(void)startUpdate
{
	NSURLRequest *request = [NSURLRequest requestWithURL:
							 [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kBasePath,@"updates.txt"]]];
    
    if(nil == _updateCheckConnection)
    {
        _updateCheckConnection = [[DREncapsulatedConnection alloc] initWithRequest:request delegate:self identifier:@"updateCheck"];
    }
}

- (void)showUpdateAlert
{
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Updates Available"
														 message:@"Schedule updates are available  Would you like to update now?"
													    delegate:self 
											   cancelButtonTitle:@"NO" otherButtonTitles:@"YES",nil];
	[alertView show];
}


#pragma mark EncapsulatedConnectionDelegate methods

- (void)connection:(DREncapsulatedConnection *)connection returnedWithData:(NSData *)data
{
	@try 
	{
		
		if([[connection identifier] isEqualToString:@"updateCheck"])
		{
            NSDictionary *parsedStructure = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            if([parsedStructure isKindOfClass:[NSDictionary class]])
            {
                NSString *date = parsedStructure[@"updateDate"];
                NSString *file = parsedStructure[@"updateFile"];
                
                if(date && file)
                {
                    NSString *currentDate = [[NSUserDefaults standardUserDefaults]
                                             stringForKey:kLastUpdateDateKey];
                    if(NSOrderedDescending == [date compare:currentDate])
                    {
                        _newDatabaseFileName = file;
                        _newDatabaseLocalFileName = [file stringByReplacingOccurrencesOfString:@".gz" withString:@""];
                        _newUpdateDate = date;
                        [self showUpdateAlert];
                    }
                }

			}
            
            //Schedule a timer to release the database update connection
            //as we don't want to have it fire multiple times in case the activation callback goes through
            [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(releaseUpdateCheckConnection:) userInfo:nil repeats:NO];
             
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
			_downloadProgressTimer = nil;
			
			[delegate newDatabaseAvailableWithFilename:_newDatabaseLocalFileName andDate:_newUpdateDate];
            
            [delegate databaseUpdateFinished];
            
            [self hideLoadingView];
            
            _databaseUpdateConnection = nil;
            
            
		}
		
	}
	@catch (NSException * e) 
	{
		[Flurry logError:@"Uncaught Exception" message:@"exception thrown during update" error:nil];
	}
}

- (void)releaseUpdateCheckConnection:(NSTimer *)timer
{
    _updateCheckConnection = nil;
    
}

- (void)connection:(DREncapsulatedConnection *)connection returnedWithError:(NSError *)error
{
    if([[connection identifier] isEqualToString:@"updateCheck"])
    {
        _updateCheckConnection = nil;
    }
    else 
    {
        _databaseUpdateConnection = nil;
    }
    
	[_downloadProgressTimer invalidate];
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
		
		_databaseUpdateConnection = [[DREncapsulatedConnection alloc] initWithRequest:request delegate:self identifier:@"DatabaseUpdate"];	
	
		_downloadProgressTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self
																 selector:@selector(updateProgress:)
																 userInfo:nil
																  repeats:YES];
	}
	else 
	{
		[self hideLoadingView];
	}
}

- (void)updateProgress:(NSTimer *)timer
{
    [SVProgressHUD showProgress:[_databaseUpdateConnection downloadPercentage] status:@"Updating Schedules"];
}
								  
#pragma mark LoadingView methods

- (void)showLoadingView
{
    [SVProgressHUD showProgress:0.0 status:@"Updating Schedules"];
}

- (void)hideLoadingView
{
    [SVProgressHUD dismiss];
}

@end
