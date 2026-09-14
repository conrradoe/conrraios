//
//  HandlingHelper.h
//  HireMe Rider
//
//  Created by Grepix - Baij on 04/02/20.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NetworkLocationAlertView.h"
#import <CoreLocation/CoreLocation.h>
#import "HandleAlertViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface HandlingHelper : NSObject

+ (HandlingHelper *)sharedObject;
-(void)startMonitoring;

//-(void) showAlertLocationByForce;
@end

NS_ASSUME_NONNULL_END
