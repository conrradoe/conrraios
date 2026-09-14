//
//  SingleRequestView.h

//
//  Created by Grepix - Baij on 29/10/20.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TripModel.h"
#import <GIKit/GIKit.h>
#import "WebCallConstants.h"
#import "AppDelegate.h"
#import "DRCircularProgressView.h"
#import <MapKit/MapKit.h>
#import <SDWebImageManager.h>
#import <Conrra-Swift.h>
@class SingleRequestView;

NS_ASSUME_NONNULL_BEGIN

@protocol SingleRequestViewDelegate <NSObject>

-(void) view:(SingleRequestView *) view onAcceptTripSuccess:(TripModel *) trip;
-(void) view:(SingleRequestView *) view onRejectTripSuccess:(TripModel *) trip;
-(void) view:(SingleRequestView *) view onCloseTripRequest:(TripModel *) trip;
-(void)showAlert:(NSString *) title message:(NSString*)message;
-(void)showAlertForOfferSent:(NSString *) title message:(NSString*)message;

-(void)handleErrorApi:(NSError *) error;


@end
@interface SingleRequestView : UIView<UITextFieldDelegate,MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *lblPickupAddrees;
@property (weak, nonatomic) IBOutlet UILabel *lblDropAddress;
@property (weak, nonatomic) IBOutlet UIImageView *viewVerticalDivider;
@property (weak, nonatomic) IBOutlet UIView *viewTripInfo;
@property (weak, nonatomic) IBOutlet UILabel *lblDuration;
@property (weak, nonatomic) IBOutlet UILabel *lblDistance;
@property (weak, nonatomic) IBOutlet UILabel *lblTripFare;
@property (weak, nonatomic) IBOutlet UILabel *lblRequestTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblRequestTitle2;
@property (weak, nonatomic) IBOutlet UIButton *btnAccept;
@property(strong, nonatomic) TripModel *trip;
@property(strong, nonatomic) TripOffer *tripOffer;
@property(weak, nonatomic) id<SingleRequestViewDelegate> delegate;
//@property (strong, nonatomic) MKMapView *mapView;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UILabel *lblTollCalcuated;

@property (weak, nonatomic) IBOutlet UIView *viewTripFare;
@property (weak, nonatomic) IBOutlet DRCircularProgressView *viewProgress;
@property (weak, nonatomic) IBOutlet UIView *viewMapContainer;

@property (unsafe_unretained, nonatomic) IBOutlet UIButton *btnOffer1;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *btnOffer2;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *btnOffer3;
@property (weak, nonatomic) IBOutlet UIStackView *viewnewOfferCustomize;

@property (unsafe_unretained, nonatomic) IBOutlet UILabel *lblAccept;
@property (weak, nonatomic) IBOutlet UIButton *btnMin;

@property (weak, nonatomic) IBOutlet UIButton *btnMax;



+(SingleRequestView *)showTripRequestAcceptViewWithDelegate:(id<SingleRequestViewDelegate>)delegate parentView:(nonnull UIView *)parentView trip:(TripModel *) trip;

+(SingleRequestView *)showTripRequestAcceptViewWithDelegate:(id<SingleRequestViewDelegate>)delegate parentView:(nonnull UIView *)parentView tripIdFromRequest:(TripModel *) trip;
+(SingleRequestView *)showSentTripRequestAcceptViewWithDelegate:(id<SingleRequestViewDelegate>)delegate parentView:(nonnull UIView *)parentView tripIdFromRequest:(TripOffer *) tripOffer;

@property (unsafe_unretained, nonatomic) IBOutlet UIActivityIndicatorView *activityLoader;
+(SingleRequestView *)showTripRequestAcceptViewWithDelegate:(id<SingleRequestViewDelegate>)delegate parentView:(nonnull UIView *)parentView tripId:(NSString *) tripId;
@property (weak, nonatomic) IBOutlet UIView *viewLoadingReequestData;
@property (unsafe_unretained, nonatomic) IBOutlet UIView *viewAddress;
@property (weak, nonatomic) IBOutlet UILabel *lblOfferText;
@property (weak, nonatomic) IBOutlet UIButton *btnReject;

@property (weak, nonatomic) IBOutlet UIView *viewOfferInput;
@property (weak, nonatomic) IBOutlet UITextField *txtOfferAmt;

@property (weak, nonatomic) IBOutlet UIButton *btNewOffer1;
@property (weak, nonatomic) IBOutlet UIButton *btNewOffer2;
@property (weak, nonatomic) IBOutlet UIButton *btNewOffer3;
@property (weak, nonatomic) IBOutlet UIButton *btNewOffer4;

@property (weak, nonatomic) IBOutlet UIView *viewOfferCustomise;


@property (weak, nonatomic) IBOutlet UILabel *lblCurrency;
-(void)getForTestTripDetailsDemo:(NSString * )tripId;
-(void) showDataOnUi;
-(void)checkAndHideRequestView:(NSNotification *)notification;


@end

NS_ASSUME_NONNULL_END
