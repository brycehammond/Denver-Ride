//
//  LineScheduleUpdater.h
//  RTD
//
//  Created by bryce.hammond on 10/13/09.
//  Copyright 2009 Fluidvision Design. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EncapsulatedConnection.h"
#import "LoadingView.h"

@interface LineScheduleUpdater : NSObject <EncapsulatedConnectionDelegate, UIAlertViewDelegate> {
	UIWindow *_window;
	NSManagedObjectContext *_managedObjectContext;
	
	EncapsulatedConnection *_updateCheckConnection;
	
	EncapsulatedConnection *_lineUpdateConnection;
	
	NSMutableDictionary *_linesToRoutesToUpdate;
	
	NSString *_currentUpdateLine;
	NSString *_currentUpdateRoute;
	
	NSMutableDictionary *_routesToNewDates;
	NSMutableDictionary *_linesByName;
	NSMutableDictionary *_stationsByID;
	
	LoadingView *_loadingView;
}

-(id)initWithMainWindow:(UIWindow *)window andManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
-(void)startUpdate;

@end
