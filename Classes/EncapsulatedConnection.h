//
//  EncapsulatedConnection.h
//  RTD
//
//  Created by bryce.hammond on 10/13/09.
//  Copyright 2009 Fluidvision Design. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol EncapsulatedConnectionDelegate;

@interface EncapsulatedConnection : NSObject {
	NSURLConnection *_connection;
	NSURLRequest *_connectionRequest;
	NSMutableData *_returnData;
	id<EncapsulatedConnectionDelegate> delegate;
	NSString *_identifier;
	
	long long _totalBytesExpected;
}

- (NSString *)identifier;
- (double)downloadPercentage;
@property (assign) id<EncapsulatedConnectionDelegate> delegate;

-(id)initWithRequest:(NSURLRequest *)request delegate:(id<EncapsulatedConnectionDelegate>)del identifier:(NSString *)ident;

@end

@protocol EncapsulatedConnectionDelegate

- (void)connection:(EncapsulatedConnection *)connection returnedWithData:(NSData *)data;
- (void)connection:(EncapsulatedConnection *)connection returnedWithError:(NSError *)error;

@end