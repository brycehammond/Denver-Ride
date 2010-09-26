//
//  NSDate+gzip.h
//  RTD
//
//  Created by bryce.hammond on 9/26/10.
//  Copyright 2010 Fluidvision Design. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSData (gzip)
- (NSData *) gzipInflate;
- (NSData *) gzipDeflate;
@end
