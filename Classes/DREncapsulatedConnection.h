//
//  EncapsulatedConnection.h
//  RTD
//
//  Created by bryce.hammond on 10/13/09.
//  Copyright 2009 Fluidvision Design. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol EncapsulatedConnectionDelegate;

@interface DREncapsulatedConnection : NSObject {
	NSURLConnection *_connection;
	NSURLRequest *_connectionRequest;
	NSMutableData *_returnData;
	id<EncapsulatedConnectionDelegate> __weak delegate;
	NSString *_identifier;
	
	long long _totalBytesExpected;
}

- (NSString *)identifier;
- (double)downloadPercentage;
@property (weak) id<EncapsulatedConnectionDelegate> delegate;

-(id)initWithRequest:(NSURLRequest *)request delegate:(id<EncapsulatedConnectionDelegate>)del identifier:(NSString *)ident;

@end

@protocol EncapsulatedConnectionDelegate

- (void)connection:(DREncapsulatedConnection *)connection returnedWithData:(NSData *)data;
- (void)connection:(DREncapsulatedConnection *)connection returnedWithError:(NSError *)error;

@end