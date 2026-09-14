//
//  TripDetailsViewController.h
//  TaxiDriver
//
//  Created by  Appicial on 30/05/17.
//  Copyright © 2023 Appicial. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TripModel.h"
#import "ConstantModel.h" 
#import "HCSStarRatingView.h"
#import "PassengerDetailsAlertView.h"
#import "FareDetailsViewController.h"
#import "BaseViewController.h"
@class  TripDetailsViewController;
@protocol TripDetailsViewControllerDelelgate <NSObject>

-(void) onCloseTripDetail;

@end
@interface TripDetailsViewController : BaseViewController

@property (strong, nonatomic) IBOutlet UILabel *lblRiderName;
@property (strong, nonatomic) IBOutlet UILabel *lblPickup;
@property (strong, nonatomic) IBOutlet UILabel *lblDrop;
@property (strong, nonatomic) IBOutlet UILabel *lblDate;
@property (strong, nonatomic) IBOutlet UILabel *lblHeader;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
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

@property (strong, nonatomic) IBOutlet UIImageView *imgCancelTrip;
@property (strong, nonatomic) IBOutlet UIView *viewHeader;
@property (weak, nonatomic) IBOutlet UIView *viewOnScroll;
@property (weak, nonatomic) IBOutlet UIImageView *viewVerticalLine;
@property (weak, nonatomic) IBOutlet UIView *viewOverlayLayer;

@property (weak, nonatomic) IBOutlet HCSStarRatingView *driverRating;
@property (weak, nonatomic) IBOutlet UILabel *lblUserRating;
@property (weak, nonatomic) IBOutlet UILabel *lbTripStatus;
@property (weak, nonatomic) IBOutlet UILabel *lblPickupLocatonText;
@property (weak, nonatomic) IBOutlet UILabel *lblDdropLocationText;
@property (weak, nonatomic) IBOutlet UIButton *btnPassengerDetail;
@property (weak, nonatomic) IBOutlet UILabel *lblAmountPaidText;
@property (weak, nonatomic) IBOutlet UILabel *lblTotalFare;
@property (weak, nonatomic) IBOutlet UIView *viewNewFare;
@property (weak, nonatomic) IBOutlet UIView *viewCostDetail;
@property (weak, nonatomic) IBOutlet UIView *viewContainer;

@property (weak, nonatomic) IBOutlet UIView *viewBottomDivider;

@property (strong, nonatomic) TripModel *trip;
@property (weak, nonatomic) id<TripDetailsViewControllerDelelgate>delegate;

- (IBAction)onCloseButtonTap:(id)sender;
@end
