//
//  StationStopTableViewCell.h
//  RTD
//
//  Created by bryce.hammond on 8/15/09.
//  Copyright 2009 Wall Street On Demand, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Stop.h"


@interface StationStopTableViewCell : UITableViewCell {

}


-(StationStopTableViewCell *)initWithReuseIdentifier:(NSString *)cellIdentifier;

-(void)setStop:(Stop *)stop;
-(void)setEndOfLineStop:(Stop *)stop;



@end
