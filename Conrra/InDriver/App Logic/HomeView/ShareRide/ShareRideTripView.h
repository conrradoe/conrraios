//
//  NetworkLocationAlertView.h
//  HireMe Rider
//
//  Created by Grepix - Baij on 04/02/20.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageView+WebCache.h"
#import "PendingTripCell.h"
#import "TripModel.h"
#import "UIView+UpdateAutoLayoutConstraints.h"
#import <GIKit/GIKit.h>
#import "CurrentTripCell.h"
NS_ASSUME_NONNULL_BEGIN

@interface ShareRideTripView : UIView<UITableViewDelegate,UITableViewDataSource,CurrentTripCellDelegate>
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *btnCurrentTrip;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *btnTripRequest;
@property (unsafe_unretained, nonatomic) IBOutlet UIView *viewCurrentTrip;
@property (unsafe_unretained, nonatomic) IBOutlet UIView *viewTripRequest;
@property (unsafe_unretained, nonatomic) IBOutlet UITableView *tableview;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *lblNoTrips;
@property(strong,nonatomic) id<CurrentTripCellDelegate> delegate;
@property(strong,nonatomic) NSMutableArray * arrayCurrentTrip;
@property(strong,nonatomic) TripModel  * tripModel;

+(void) showShareRide:(UIView *)view tripModel:(TripModel  *) tripModel delegate:(id<CurrentTripCellDelegate>) delegate ;
@end

NS_ASSUME_NONNULL_END
