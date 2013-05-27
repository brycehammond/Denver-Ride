//
//  EncapsulatedConnection.m
//  RTD
//
//  Created by bryce.hammond on 10/13/09.
//  Copyright 2009 Fluidvision Design. All rights reserved.
//

#import "DREncapsulatedConnection.h"

@implementation DREncapsulatedConnection

@synthesize delegate;

-(id)initWithRequest:(NSURLRequest *)request delegate:(id<EncapsulatedConnectionDelegate>)del identifier:(NSString *)ident
{
	if(self = [super init])
	{
		delegate = del;
		_identifier = ident;
		_connectionRequest = request;
		_returnData = [[NSMutableData alloc] init];
		_connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
		_totalBytesExpected = 0;
	}
	
	return self;
}

-(void)dealloc
{
	delegate = nil;
	_connectionRequest = nil;
	[_connection cancel];
	_connection = nil;
	_identifier = nil;
	_returnData = nil;
}

-(NSString *)identifier
{
	return _identifier;
}

- (double)downloadPercentage
{
	return (double)[_returnData length] / _totalBytesExpected;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response

{	
	_totalBytesExpected = [response expectedContentLength];
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
