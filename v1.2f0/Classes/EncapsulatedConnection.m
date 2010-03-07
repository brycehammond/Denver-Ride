//
//  EncapsulatedConnection.m
//  RTD
//
//  Created by bryce.hammond on 10/13/09.
//  Copyright 2009 Fluidvision Design. All rights reserved.
//

#import "EncapsulatedConnection.h"

@implementation EncapsulatedConnection

@synthesize delegate;

-(id)initWithRequest:(NSURLRequest *)request delegate:(id<EncapsulatedConnectionDelegate>)del identifier:(NSString *)ident
{
	if(self = [super init])
	{
		delegate = del;
		_identifier = [ident retain];
		_connectionRequest = [request retain];
		_returnData = [[NSMutableData alloc] init];
		_connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	}
	
	return self;
}

-(void)dealloc
{
	delegate = nil;
	[_connectionRequest release];
	_connectionRequest = nil;
	[_connection cancel];
	[_connection release];
	_connection = nil;
	[_identifier release];
	_identifier = nil;
	[_returnData release];
	_returnData = nil;
	[super dealloc];
}

-(NSString *)identifier
{
	return _identifier;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response

{	
    [_returnData setLength:0];	
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data

{	
    [_returnData appendData:data];	
}

- (void)connection:(NSURLConnection *)connection

  didFailWithError:(NSError *)error

{
	[delegate connection:self returnedWithError:error];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection

{
	[delegate connection:self returnedWithData:_returnData];
}

@end
