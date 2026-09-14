//
//  FareChangeViewController.h
//  InRider
//
//  Created by Grepix on 08/07/21.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import "BaseViewController.h"
NS_ASSUME_NONNULL_BEGIN
@class  FareChangeViewController;
@protocol FareChangeViewControllerDelegate <NSObject>

-(void)viewController:(FareChangeViewController *) contorller onDoneButtonTap:(nullable id)sender dictFare:(NSDictionary *) dict;

@end

@interface FareChangeViewController : BaseViewController
@property(strong,nonatomic) NSDate *tripDate;
@property(strong,nonatomic) NSString * passengerDetails;
@property(assign,nonatomic) BOOL isRideLater;
@property(weak,nonatomic) id<FareChangeViewControllerDelegate> delegate;
@property(assign,nonatomic) BOOL isPromoCodeApplied;
@property(assign,nonatomic)NSDictionary * dictFareEstimate;
@end

NS_ASSUME_NONNULL_END
