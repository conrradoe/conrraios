//
//  RiderCancelTripViewController.h
//  Golden Moto Driver
//
//  Created by Grepix - Baij on 19/02/20.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TripModel.h"
#import "TripDetailsViewController.h"
#import "BaseViewController.h"
NS_ASSUME_NONNULL_BEGIN

@interface RiderCancelTripViewController : BaseViewController<TripDetailsViewControllerDelelgate>
@property(strong,nonatomic)NSString * tripId;
@property(strong,nonatomic)TripModel * tripModel;
@end

NS_ASSUME_NONNULL_END
