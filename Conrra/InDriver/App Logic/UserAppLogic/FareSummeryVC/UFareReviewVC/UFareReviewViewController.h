//
//  FareReviewViewController.h
//  TaxiDriver
//
//  Created by Appicial Taxi App Soutions on 29/05/17.
//  Copyright © 2023 Appicial Taxi App Soutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TripModel.h"
#import "HCSStarRatingView.h"
#import "LanguageHelper.h"
#import "FareDetailsViewController.h"
#import "BaseViewController.h"

@interface UFareReviewViewController : BaseViewController


@property (strong, nonatomic) IBOutlet UILabel *lblPickupLocation;
@property (strong, nonatomic) IBOutlet UILabel *lblDropLocation;
@property (weak, nonatomic) IBOutlet UILabel *lbCarCategoryName;
@property (strong, nonatomic) IBOutlet UIImageView *imgDriver;
@property (strong, nonatomic) IBOutlet UILabel *lblDriverName;
@property (strong, nonatomic) IBOutlet UILabel *lblHeader;
@property (weak, nonatomic) IBOutlet UILabel *starRatingLbl;
@property (weak, nonatomic) IBOutlet UIImageView *viewVerticalLine;
@property (weak, nonatomic) IBOutlet UIView *viewOnScroll;
@property (weak, nonatomic) IBOutlet HCSStarRatingView *viewStarRating;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIButton *btnBack;
@property (weak, nonatomic) IBOutlet UILabel *lblPicupLocation;
@property (weak, nonatomic) IBOutlet UILabel *lblDroplocationText;

//TripId
@property (strong, nonatomic) IBOutlet UILabel *lblTripIdText;
@property (strong, nonatomic) IBOutlet UILabel *lblTripIdValue;
//Driver Id
@property (strong, nonatomic) IBOutlet UILabel *lblDriverIdText;
@property (strong, nonatomic) IBOutlet UILabel *lblDriverIdValue;

// waiting
@property (weak, nonatomic) IBOutlet UILabel *lblWaitTimeText;
@property (weak, nonatomic) IBOutlet UILabel *lblWaitTimeValue;
// cashback
@property (weak, nonatomic) IBOutlet UILabel *lblCashbackText;
@property (weak, nonatomic) IBOutlet UILabel *lblCashbackValue;
// promo
@property (weak, nonatomic) IBOutlet UILabel *lblPromoText;
@property (weak, nonatomic) IBOutlet UILabel *lblPromoValue;
// Distance
@property (weak, nonatomic) IBOutlet UILabel *lblDistanceText;
@property (strong, nonatomic) IBOutlet UILabel *lblDistanceValue;
//tax
@property (weak, nonatomic) IBOutlet UILabel *lblTaxText;
@property (strong, nonatomic) IBOutlet UILabel *lblTaxValue;
// RideCost
@property (weak, nonatomic) IBOutlet UILabel *lblRideCostText;
@property (strong, nonatomic) IBOutlet UILabel *lblRideCostValue;

// Total Fare
@property (weak, nonatomic) IBOutlet UILabel *lblAmountPaid;
@property (weak, nonatomic) IBOutlet UILabel *lblTotalFare;
@property (weak, nonatomic) IBOutlet UIView *viewNewFare;
@property (weak, nonatomic) IBOutlet UIView *viewBottomDivider;

@property (weak, nonatomic) IBOutlet UIView *viewContainer;

@property (weak, nonatomic) IBOutlet UIView *viewCostDetails;

@property (strong, nonatomic)  TripModel *cur_trip;
- (IBAction)onBackButtonTap:(id)sender;
@end
