//
//  DatabaseUpdater.h
//  RTD
//
//  Created by bryce.hammond on 9/26/10.
//  Copyright 2010 Fluidvision Design. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EncapsulatedConnection.h"
#import "LoadingView.h"

@protocol DatabaseUpdaterDelegate

- (void)newDatabaseAvailableWithFilename:(NSString *)filename andDate:(NSString *)date;

@end


@interface DatabaseUpdater : NSObject <EncapsulatedConnectionDelegate> {
	EncapsulatedConnection *_updateCheckConnection;
	
	EncapsulatedConnection *_databaseUpdateConnection;
	
	LoadingView *_loadingView;
	
	NSString *_newDatabaseFileName;
	NSString *_newUpdateDate;
	
	NSTimer *_downloadProgressTimer;
	
	id<DatabaseUpdaterDelegate> delegate;
}

@property (nonatomic, assign) id<DatabaseUpdaterDelegate> delegate;

-(void)startUpdate;

@end
