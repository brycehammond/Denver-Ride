//
//  BCycleViewController.h
//  BCycle
//
//  Created by bryce.hammond on 8/13/10.
//  Copyright Fluidvision Design, Inc. 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DREncapsulatedConnection.h"

@interface BCycleViewController : UIViewController <MKMapViewDelegate, EncapsulatedConnectionDelegate> {
	MKMapView *_mapView;
	NSArray *_stations;
	DREncapsulatedConnection *_updateConnection;

	NSMutableDictionary *_stationsByName;
}

//merges new station information
- (void)updateStations:(NSArray *)stations;

//retrieves new annotations from the web
- (void)updateAnnotations;

@end

