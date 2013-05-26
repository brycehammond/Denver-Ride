//
//  Stop+Convenience.h
//  RTD
//
//  Created by Bryce Hammond on 5/26/13.
//  Copyright (c) 2013 Fluidvision Design. All rights reserved.
//

#import "Stop.h"

@interface Stop (Convenience)

- (NSString *)formattedTime;

- (NSComparisonResult)sortBySequence:(Stop *)otherStop;


@end
