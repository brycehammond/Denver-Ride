//
//  DatabaseUpdater.h
//  RTD
//
//  Created by bryce.hammond on 9/26/10.
//  Copyright 2010 Fluidvision Design. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DREncapsulatedConnection.h"

@protocol DatabaseUpdaterDelegate

- (void)databaseUpdateStarted;
- (void)databaseUpdateFinished;
- (void)newDatabaseAvailableWithFilename:(NSString *)filename andDate:(NSString *)date;

@end


@interface DRDatabaseUpdater : NSObject <EncapsulatedConnectionDelegate> {
	DREncapsulatedConnection *_updateCheckConnection;
	
	DREncapsulatedConnection *_databaseUpdateConnection;
	
	NSString *_newDatabaseFileName;
    NSString *_newDatabaseLocalFileName;
	NSString *_newUpdateDate;
	
	NSTimer *_downloadProgressTimer;
	
	id<DatabaseUpdaterDelegate> __weak delegate;
}

@property (nonatomic, weak) id<DatabaseUpdaterDelegate> delegate;

-(void)startUpdate;

@end
