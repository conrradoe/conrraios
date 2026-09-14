//
//  FareAmmountViewController.h
//  TaxiDriver
//
//  Created by Appicial Taxi App Soutions on 29/05/17.
//  Copyright © 2023 Appicial Taxi App Soutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TripModel.h"
#import "SAMTextView.h"
#import "ConstantModel.h"
#import "HCSStarRatingView.h"
#import "LanguageHelper.h"
#import "BaseViewController.h"
#import "PaymentMethodListViewController.h"
@interface UFareSummeryViewController : BaseViewController<PaymentMethodListViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *lbPromocodeAmount;
@property (weak, nonatomic) IBOutlet UIView *viewHeader;
@property (weak, nonatomic) IBOutlet UIView *viewAmount;
@property (weak, nonatomic) IBOutlet UILabel *lbTripFareAmount;

@property (weak, nonatomic) IBOutlet UIButton *btSubmit;
@property (weak, nonatomic) IBOutlet UIButton *btOffline;

@property (weak, nonatomic) IBOutlet UIButton *btFareReview;

@property (weak, nonatomic) IBOutlet UILabel *lbAmountToPay;

@property (weak, nonatomic) IBOutlet UIView *viewEnterPromoCode;


@property (weak, nonatomic) IBOutlet UITextField *txtPromoCode;
@property (strong, nonatomic) TripModel *curr_trip;
@property (strong, nonatomic) ConstantModel *constantModel;
//@property (strong, nonatomic) NSString *tripId;


@property (weak, nonatomic) IBOutlet UIView *viewPromoCode;

@property (weak, nonatomic) IBOutlet UIView *viewStarContainer;
@property (weak, nonatomic) IBOutlet SAMTextView *txtviewFeedback;
@property (strong, nonatomic) IBOutlet UIView *ratingBar;

@property (strong, nonatomic) IBOutlet UILabel *lblHeader;
@property (strong, nonatomic) IBOutlet UILabel *lblHireMeCard;
@property (strong, nonatomic) IBOutlet UILabel *lblAmountPayableTitle;
@property (strong, nonatomic) IBOutlet UIButton *btnSkip;
@property (strong, nonatomic) IBOutlet UIButton *btnDone;
@property (strong, nonatomic) IBOutlet UIButton *btnSubmit;
@property (strong, nonatomic) IBOutlet UIButton *btnOffline;
@property (strong, nonatomic) IBOutlet UIButton *btnFareReview;
@property (strong, nonatomic) IBOutlet UIButton *btnPromoCode;
@property (strong, nonatomic) IBOutlet UIButton *btnApply;

@property (weak, nonatomic) IBOutlet UILabel *pickUpAddressLbl;
@property (weak, nonatomic) IBOutlet UILabel *lblDistanceText;
@property (weak, nonatomic) IBOutlet UILabel *lblDurationText;

@property (weak, nonatomic) IBOutlet UILabel *dropAddressLbl;

@property (strong, nonatomic) IBOutlet UIButton *btnRatingSkip;
@property (strong, nonatomic) IBOutlet UIButton *btnratingDone;
@property (strong, nonatomic) IBOutlet UILabel *lblRateDriver;
@property (weak, nonatomic) IBOutlet UIView *viewStartBgOveryLay;
@property (weak, nonatomic) IBOutlet UIImageView *viewVerticalLine;
@property (weak, nonatomic) IBOutlet UILabel *lbDistacneVal;
@property (weak, nonatomic) IBOutlet UILabel *lbPromocode;

@property (weak, nonatomic) IBOutlet HCSStarRatingView *viewStarRating;
@property (weak, nonatomic) IBOutlet UILabel *lbDurationVal;
@property (weak, nonatomic) IBOutlet UILabel *lblPicupLocation;
@property (weak, nonatomic) IBOutlet UILabel *lblDropLocation;

@property (weak, nonatomic) IBOutlet UILabel *lblComment;

@property (weak, nonatomic) IBOutlet UILabel *lblDriverRating;
@property (weak, nonatomic) IBOutlet UIButton *btnFareDetails;

@end
