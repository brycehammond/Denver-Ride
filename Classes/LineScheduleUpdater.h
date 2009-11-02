//
//  LineScheduleUpdater.h
//  RTD
//
//  Created by bryce.hammond on 10/13/09.
//  Copyright 2009 Fluidvision Design. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EncapsulatedConnection.h"

@interface LineScheduleUpdater : NSObject <EncapsulatedConnectionDelegate> {
	UIWindow *_window;
	NSManagedObjectContext *_managedObjectContext;
	
	EncapsulatedConnection *_updateCheckConnection;
	
	EncapsulatedConnection *_lineUpdateConnection;
}

-(id)initWithMainWindow:(UIWindow *)window andManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
-(void)startUpdate;

@end
