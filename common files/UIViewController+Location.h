//
//  UIViewController+Location.h
//  HireMe Rider
//
//  Created by Grepix - Baij on 24/02/20.
//  Copyright © 2023 Grepixit. All rights reserved.
//


#import <CoreLocation/CoreLocation.h>
#import "HandleAlertViewController.h"
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (Location)

-(BOOL)checkLocationServiceEnabled;

-(void)locatonGetFailedScreen:(CLLocationManager *)manager isBackHidden:(BOOL) isBackHidden;
-(BOOL)isCheckLocationFailedScreen;
@end

NS_ASSUME_NONNULL_END
