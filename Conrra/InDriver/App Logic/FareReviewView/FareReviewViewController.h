//
//  FareReviewViewController.h
//  TaxiDriver
//
//  Created by  Appicial on 29/05/17.
//  Copyright © 2023 Appicial. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TripModel.h"
#import "HCSStarRatingView.h"
#import "LanguageHelper.h"
#import "FareDetailsViewController.h"
#import "BaseViewController.h"

@interface FareReviewViewController : BaseViewController

@property (strong, nonatomic) IBOutlet UILabel *lblPickupLocation;
@property (strong, nonatomic) IBOutlet UILabel *lblDropLocation;

@property (weak, nonatomic) IBOutlet UILabel *lbCarCategoryName;

@property (strong, nonatomic) IBOutlet UIImageView *imgUser;
@property (strong, nonatomic) IBOutlet UILabel *lblUserName;
@property (strong, nonatomic) IBOutlet UILabel *lblHeader;
@property (weak, nonatomic) IBOutlet UILabel *starRating;
@property (weak, nonatomic) IBOutlet UIImageView *viewVerticalLine;
@property (weak, nonatomic) IBOutlet UIView *viewOnScroll;
@property (weak, nonatomic) IBOutlet UIView *viewOverlayLayer;
@property (weak, nonatomic) IBOutlet HCSStarRatingView *viewRating;


@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIButton *btnBack;

@property (weak, nonatomic) IBOutlet UIView *viewOverlay;
@property (weak, nonatomic) IBOutlet UIView *fareView;

@property (weak, nonatomic) IBOutlet UIView *profileView;
@property (weak, nonatomic) IBOutlet UIImageView *imgRating;
@property (weak, nonatomic) IBOutlet UIView *tripDriveView;


@property (weak, nonatomic) IBOutlet UIView *tripDetailView;
@property (weak, nonatomic) IBOutlet UILabel *lblPicUp;
@property (weak, nonatomic) IBOutlet UILabel *lblDrop;
@property (weak, nonatomic) IBOutlet UIView *costDetailView;


//TripId
@property (strong, nonatomic) IBOutlet UILabel *lblTripIdText;
@property (strong, nonatomic) IBOutlet UILabel *lblTripIdValue;
//Driver Id
@property (strong, nonatomic) IBOutlet UILabel *lblDriverIdText;
@property (strong, nonatomic) IBOutlet UILabel *lblDriverIdValue;

// waiting
@property (weak, nonatomic) IBOutlet UILabel *lblWaitTimeText;
@property (weak, nonatomic) IBOutlet UILabel *lblWaitTimeValue;
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

@property (weak, nonatomic) IBOutlet UILabel *lblAmountPaid;
@property (weak, nonatomic) IBOutlet UILabel *lblTotalFare;
@property (weak, nonatomic) IBOutlet UIView *viewNewFare;

@property (weak, nonatomic) IBOutlet UIView *viewBottomDivider;
@property (weak, nonatomic) IBOutlet UIButton *btnCancel;
@property (strong, nonatomic)  TripModel *cur_trip;
- (IBAction)onBackButtonTap:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *viewContainer;

@end
