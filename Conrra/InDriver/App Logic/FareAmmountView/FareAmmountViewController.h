//
//  FareAmmountViewController.h
//  TaxiDriver
//
//  Created by  Appicial on 29/05/17.
//  Copyright © 2023 Appicial. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TripModel.h"
#import "ConstantModel.h"
#import "SAMTextView.h"
#import "FareDetailsViewController.h"
#import "LanguageHelper.h"
#import "BaseViewController.h"

@interface FareAmmountViewController : BaseViewController
//@property (strong, nonatomic) TripModel * curr_trip;
//@property (strong, nonatomic) ConstantModel *constantModel;
@property(strong,nonatomic) TripModel *curr_trip;
@property (strong, nonatomic) IBOutlet UIButton *btnFarereview;
@property (strong, nonatomic) IBOutlet UIButton *btnHome;
@property (strong, nonatomic) IBOutlet UIButton *btnOffline;
@property (strong, nonatomic) IBOutlet UIButton *btnPaymentReceived;

@property (strong, nonatomic) IBOutlet UIView *viewHeader;
@property (weak, nonatomic) IBOutlet UIView *viewRating;

@property (strong, nonatomic) IBOutlet UILabel *lblPromoAmount;
@property (strong, nonatomic) IBOutlet UILabel *lblHeader;
@property (strong, nonatomic) IBOutlet UILabel *lblHireMeCard;
@property (strong, nonatomic) IBOutlet UILabel *lblDriverAmountTitle;
@property (strong, nonatomic) IBOutlet UILabel *lblAmountCollectedTitle;
@property (strong, nonatomic) IBOutlet UILabel *lblFareAmt;
@property (strong, nonatomic) IBOutlet UILabel *lblDriverCommision;
@property (weak, nonatomic) IBOutlet UILabel *lblPickupAddress;
@property (weak, nonatomic) IBOutlet UILabel *lblDropUpAddress;
@property (weak, nonatomic) IBOutlet UIView *viewStarBgOverLay;

@property (weak, nonatomic) IBOutlet UIView *viewStarContainer;
@property (weak, nonatomic) IBOutlet UIButton *btUserRating;
@property (weak, nonatomic) IBOutlet UIView *viewRatingDone;
@property (weak, nonatomic) IBOutlet SAMTextView *txtviewFeedback;
@property (strong, nonatomic) IBOutlet UIView *ratingBar;
@property (weak, nonatomic) IBOutlet UILabel *lbDistanceVal;
@property (weak, nonatomic) IBOutlet UILabel *lbPromocode;

@property (weak, nonatomic) IBOutlet UILabel *lbDurationVal;
@property (weak, nonatomic) IBOutlet UIImageView *viewVerticalLine;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrolView;
@property (weak, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UIView *payableAmtView;
@property (weak, nonatomic) IBOutlet UILabel *lblAmtPayable;
@property (weak, nonatomic) IBOutlet UIView *tripDetailView;
@property (weak, nonatomic) IBOutlet UILabel *lblPicupLocation;

@property (weak, nonatomic) IBOutlet UILabel *lblDropLoacation;
@property (weak, nonatomic) IBOutlet UIView *costDetailView;
@property (weak, nonatomic) IBOutlet UILabel *lblDistance;
@property (weak, nonatomic) IBOutlet UILabel *lblDuration;
@property (weak, nonatomic) IBOutlet UILabel *lblComment;
@property (weak, nonatomic) IBOutlet UIImageView *imgCommentIcon;

@property (weak, nonatomic) IBOutlet UIButton *btnSkip;
@property (weak, nonatomic) IBOutlet UIButton *btnDone;

@property (weak, nonatomic) IBOutlet UILabel *lblRateRide;

@property (weak, nonatomic) IBOutlet UIButton *btnFareDetails;

@property (weak, nonatomic) IBOutlet UIButton *btnEndTheRide;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topMarginEndTheRide;

@end
