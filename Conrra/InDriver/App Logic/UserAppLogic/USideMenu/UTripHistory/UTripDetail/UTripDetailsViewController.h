//
//  TripDetailsViewController.h
//  TaxiDriver
//
//  Created by Appicial Taxi App Soutions on 30/05/17.
//  Copyright © 2023 Appicial Taxi App Soutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TripModel.h"
#import "ConstantModel.h"
#import "HCSStarRatingView.h"
#import "LanguageHelper.h"
#import "PassengerDetailsAlertView.h"
#import "FareDetailsViewController.h"
#import "BaseViewController.h"
@class UTripDetailsViewController;
@protocol UTripDetailsViewControllerDelegate <NSObject>

-(void) viewController:(UTripDetailsViewController *)viewController tripModel:(TripModel *) tripModel;
-(void)onDismissDetailTrip;

@end



@interface UTripDetailsViewController : BaseViewController
@property (weak, nonatomic) IBOutlet UILabel *lbTripStatus;

@property (weak, nonatomic) IBOutlet UIImageView *imgRider;
@property (strong, nonatomic) IBOutlet UILabel *lblRiderName;
@property (strong, nonatomic) IBOutlet UILabel *lblPickup;
@property (strong, nonatomic) IBOutlet UILabel *lblDrop;
@property (strong, nonatomic) IBOutlet UILabel *lblDate;


@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;


@property (weak, nonatomic) IBOutlet UIImageView *imgCancel;


@property (strong, nonatomic) IBOutlet UIView *viewHeader;

@property(strong, nonatomic) NSString *isFromUpcomingTripViewDetail;
@property (weak, nonatomic) IBOutlet UIButton *cnacelTripOutlet;

@property (weak, nonatomic) IBOutlet UILabel *categoryNamelbl;

@property (weak, nonatomic) IBOutlet UIView *costDetailView;
@property (weak, nonatomic) IBOutlet UIImageView *viewVerticalLine;
@property (weak, nonatomic) IBOutlet UILabel *ratingLbl;
@property (weak, nonatomic) IBOutlet UIView *ratingView;

@property (weak, nonatomic) IBOutlet HCSStarRatingView *starRatingView;
@property (weak, nonatomic) IBOutlet UIView *viewOnScroll;


@property (weak, nonatomic) IBOutlet UILabel *lblHeader;
@property (weak, nonatomic) IBOutlet UILabel *lblPicupLocation;
@property (weak, nonatomic) IBOutlet UILabel *lblDropLocation;

// waiting
@property (weak, nonatomic) IBOutlet UILabel *lblWaitTimeText;
@property (weak, nonatomic) IBOutlet UILabel *lblWaitTimeValue;

// waiting
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


@property (weak, nonatomic) IBOutlet UIButton *btnChat;
@property (weak, nonatomic) IBOutlet UILabel *lblTotalFare;
@property (weak, nonatomic) IBOutlet UILabel *lblTotalFareText;
@property (weak, nonatomic) IBOutlet UIView *viewnewFare;

@property (weak, nonatomic) IBOutlet UIButton *btnPassengerDetails;
@property(weak, nonatomic) id<UTripDetailsViewControllerDelegate> tripDetailDelegate;
@property (strong, nonatomic) TripModel *trip;
@property (strong,nonatomic) ConstantModel *constantModel;
@property (weak, nonatomic) IBOutlet UIView *viewBottomDivider;
@property (weak, nonatomic) IBOutlet UIView *viewContainer;

- (IBAction)btnCancelScheduleTrip:(id)sender;
@end
