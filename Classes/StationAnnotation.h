//
//  StationAnnotation.h
//  BCycle
//
//  Created by bryce.hammond on 8/13/10.
//  Copyright 2010 Fluidvision Design. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StationAnnotation : NSObject <MKAnnotation> {
	NSString *_title;
	NSString *_subtitle;
	NSString *_bikesAvailable;
	NSString *_docksAvailable;
	CLLocationCoordinate2D _location;
}

@property (nonatomic, retain) NSString *bikesAvailable;
@property (nonatomic, retain) NSString *docksAvailable;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;

@end
