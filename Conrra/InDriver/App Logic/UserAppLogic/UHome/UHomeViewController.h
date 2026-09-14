//
//  HomeViewController.h
//  Store_project
//
//  Created by Appicial Taxi App Soutions on 22/05/17.
//  Copyright © 2023 Appicial Taxi App Soutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h> 
#import <FirebaseDatabase.h>
#import "TextFieldPadding.h"
#import "LanguageHelper.h"
#import "UIViewController+Location.h"
#import "UFareSummeryViewController.h"
#import "AboutUsViewController.h"
#import "BaseViewController.h"
#import <Conrra-Swift.h>
#import "BookingModel.h"
#import "MIBadgeButton.h"

typedef void (^CompleteProductDetail)(NSString *stringPassengerDetail,BOOL isSkip);


@interface UHomeViewController : BaseViewController<MKMapViewDelegate,CLLocationManagerDelegate,UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imCenterPickupLocation;
@property (weak, nonatomic) IBOutlet UITextField *txtDestinationAddres;
@property (strong, nonatomic) IBOutlet UITextField *txtPickupAddress;
@property (weak, nonatomic) IBOutlet TextFieldPadding *txtPromocode;
@property (weak, nonatomic) IBOutlet UIView *viewPromocodeEnter;
@property (weak, nonatomic) IBOutlet UIButton *btPromoApply;
@property (weak, nonatomic) IBOutlet UIButton *btCouponApply;
@property (weak, nonatomic) IBOutlet UIView *viewConfirmViewShow;
@property (strong, nonatomic) IBOutlet MIBadgeButton *btnMenu;
@property (strong, nonatomic) IBOutlet UITableView *tableViewPickup;
@property (weak, nonatomic) IBOutlet UITableView *tableViewDestination;
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activtiyIndicator;
@property (weak, nonatomic) IBOutlet UILabel *lbTime;
@property (weak, nonatomic) IBOutlet UIView *viewTimeDistance;
@property (weak, nonatomic) IBOutlet UILabel *lbDriversAvailableMessage;
@property (weak, nonatomic) IBOutlet UIView *viewHeader;
@property (weak, nonatomic) IBOutlet UIView *viewRequest;

@property (weak, nonatomic) IBOutlet UIView *viewCategory;
@property (weak, nonatomic) IBOutlet UIView *viewDriverSearch;
@property (strong, nonatomic) IBOutlet UIView *ContainerView;
@property (strong, nonatomic) IBOutlet UIView *viewCategoryBg;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollViewCategory;
@property (strong, nonatomic) IBOutlet UIView *viewPickup;
@property (strong, nonatomic) IBOutlet UIView *viewDestination;
@property (strong, nonatomic) IBOutlet UIButton *btnSelectPickDrop;
@property (strong, nonatomic) IBOutlet UIButton *btnSearchDrop;
@property (strong, nonatomic) IBOutlet UIButton *btnSearchPickup;
@property (strong, nonatomic) IBOutlet UIView *viewCallout;
@property (strong, nonatomic) IBOutlet UIView *viewScheduleLater;
@property (strong, nonatomic) IBOutlet UILabel *lblPickupLocation;
@property (strong, nonatomic) IBOutlet UILabel *lblDropLocation;
@property (weak, nonatomic) IBOutlet UIButton *btRiderNow;
@property (weak, nonatomic) IBOutlet UIButton *btRiderLater;
@property (weak, nonatomic) IBOutlet UIView *viewRiderButtons;
@property (weak, nonatomic) IBOutlet UIView *showButtonOnView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *consContainerBottom;
@property (weak, nonatomic) IBOutlet UITextField *txtCity;
@property (weak, nonatomic) IBOutlet UIButton *btCity;
@property (weak, nonatomic) IBOutlet UIButton *btPickupDetail;
@property (weak, nonatomic) IBOutlet UILabel *lblHeader;
@property (weak, nonatomic) IBOutlet UILabel *lblSelectCity;
@property (weak, nonatomic) IBOutlet UILabel *lblServiceNotAvailable;
@property (weak, nonatomic) IBOutlet UIButton *btnConfirmBooking;
@property (weak, nonatomic) IBOutlet UIImageView *imShareRide;
@property (weak, nonatomic) IBOutlet UILabel *lblShareText;
@property (weak, nonatomic) IBOutlet UIView *viewShareButton;
@property (weak, nonatomic) IBOutlet UIButton *btnShare;
@property (weak, nonatomic) IBOutlet UIView *viewInputOffer;
@property (weak, nonatomic) IBOutlet UILabel *lblOfferAmount;
@property (weak, nonatomic) IBOutlet UILabel *lblExtimatedFare;
@property (weak, nonatomic) IBOutlet UILabel *lblCurrency;
@property (weak, nonatomic) IBOutlet UITextField *txtExtmatedFareAmt;
@property (weak, nonatomic) IBOutlet UIButton *btnRemovePromoCode;
@property (weak, nonatomic) IBOutlet UIView *viewEstimateFareInput;
@property (weak, nonatomic) IBOutlet UIImageView *imageCalloutBg;
@property (weak, nonatomic) IBOutlet UIButton *btnGps;
@property (weak, nonatomic) IBOutlet UIImageView *imageGps;

- (IBAction)onRequestButtonTap:(id)sender;
- (IBAction)ButtonMenuPressed:(id)sender;
- (IBAction)onShowMyLocationTap:(id)sender;

@property (weak, nonatomic) IBOutlet UIView *viewUpcommingRide;
@property (weak, nonatomic) IBOutlet UILabel *lblUpComingRides;

@property(nonatomic, retain) CLLocationManager *locationManager;
@property (strong,nonatomic) MKPlacemark *source;
@property (strong, nonatomic) MKPlacemark *destination;
@property (strong, nonatomic) CompleteProductDetail completeProductDetail;
@property (assign, nonatomic) BOOL isRegireToLoadCities;
@property (strong, nonatomic) FIRDatabaseReference *ref_TripChat;
@property(strong,nonatomic) FIRDatabaseReference *ref;
-(void)stopLocationUpdate;
@property (weak, nonatomic) IBOutlet UILabel *lblPaymentMode;
@property (weak, nonatomic) IBOutlet UIImageView *imagePaymentMode;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightPrePayment;
@property (weak, nonatomic) IBOutlet UIView *viewPrePayment;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *marginTopPrePayment;

@property (weak, nonatomic) IBOutlet UIImageView *imageMenu;
@property (weak, nonatomic) IBOutlet UILabel *viewMinOffer;
-(void) openTripRequest:(TripModel *) trip;
@end
