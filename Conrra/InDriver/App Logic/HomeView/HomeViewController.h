//
//  HomeViewController.h
//  Store_project
//
//  Created by  Appicial on 22/05/17.
//  Copyright © 2023 Appicial. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "CategoryModel.h"
#import "TextFieldPadding.h"
#import <Firebase.h>
#import "LanguageHelper.h"
#import "PassengerDetailsAlertView.h"
#import "ShareRideTripView.h"
#import "MIBadgeButton.h"
#import "VerificationAlertView.h"
#import "BaseViewController.h"
#import "UploadDocumentViewController.h"
#import "WaitingTimerView.h"
#import "SAMTextView.h"
@interface HomeViewController : BaseViewController<MKMapViewDelegate,CLLocationManagerDelegate,UIGestureRecognizerDelegate,UITableViewDelegate,UITableViewDataSource,CurrentTripCellDelegate,VerificationAlertViewDelegate,WaitingTimerViewDelegate>
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewTopAddressView;
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property(nonatomic, strong) CLLocationManager *locationManager;
@property (strong, nonatomic) IBOutlet UIView *addressViewTop;
@property (strong, nonatomic) IBOutlet UIView *acceptDeclineView;
@property (strong, nonatomic) IBOutlet UIButton *btnAccept;
@property (strong, nonatomic) IBOutlet UIButton *btnDecline;
@property (strong, nonatomic) IBOutlet UILabel *lblAcceptTitle;
@property (strong, nonatomic) IBOutlet UIView *viewMessage;
@property (strong, nonatomic) IBOutlet SAMTextView *txtViewMessage;
@property (strong, nonatomic) IBOutlet UIView *goPopUpView;
@property (strong,nonatomic) MKPlacemark *source;
@property (strong, nonatomic) MKPlacemark *destination;
@property (strong, nonatomic) IBOutlet UIButton *btnGoPopUP;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *goPopUpViewBottomConstraints;
@property (strong, nonatomic) IBOutlet UILabel *lblAddressTop;
@property (strong, nonatomic) IBOutlet UILabel *lblLocationTitle;
@property (strong, nonatomic) IBOutlet UIButton *btnBeginTrip;
@property (strong, nonatomic) IBOutlet UIView *viewStatusBar;
@property (strong, nonatomic) IBOutlet UILabel *lblWhyNot;
@property (strong, nonatomic) IBOutlet UIButton *btnOK;
@property (strong, nonatomic) IBOutlet UIButton *btnReRoute;

@property (strong, nonatomic) IBOutlet UITableView *tableViewPendingTrips;
@property (strong, nonatomic) IBOutlet UILabel *lblTripRequests;
@property (strong, nonatomic) IBOutlet UILabel *lblNoData;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *ViewRequestToConstraints;
@property (strong, nonatomic) IBOutlet UIButton *btnGps;
@property (strong, nonatomic) IBOutlet UIView *viewRequestBg;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *mapviewHeightConstraints;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *btnGpsTopConstraints;

// Otp
@property (weak, nonatomic) IBOutlet UILabel *lblTripOtpMessage;
@property (weak, nonatomic) IBOutlet UIView *viewOtpVerify;
@property (weak, nonatomic) IBOutlet UIButton *btOtpVerify;
@property (weak, nonatomic) IBOutlet TextFieldPadding *txtTripOtp;

@property(strong,nonatomic) FIRDatabaseReference *ref;
@property (weak, nonatomic) IBOutlet UIButton *btRequests;

@property (weak, nonatomic) IBOutlet UIButton *btOnGoing;
@property (weak, nonatomic) IBOutlet UIImageView *imRiderProfile;
@property (weak, nonatomic) IBOutlet UILabel *lbRiderName;
@property (weak, nonatomic) IBOutlet UIView *viewDivider1;
@property (weak, nonatomic) IBOutlet UIView *viewUserInfo;
@property (weak, nonatomic) IBOutlet UIView *viewDivider2;
@property (weak, nonatomic) IBOutlet UISwitch *switchAvalability;
@property (weak, nonatomic) IBOutlet UIView *offLineView;
@property (weak, nonatomic) IBOutlet UILabel *lbloffLine;
@property (weak, nonatomic) IBOutlet UILabel *lblGoOnline;

@property (weak, nonatomic) IBOutlet UIButton *btnPassengerDetails;
@property (weak, nonatomic) IBOutlet UILabel *lblPassengerDetails;
@property (weak, nonatomic) IBOutlet UIView *viewPassengerDetails;
@property (weak, nonatomic) IBOutlet UILabel *lblCallMeText;
@property (weak, nonatomic) IBOutlet UIView *viewCallme;

@property (weak, nonatomic) IBOutlet UIView *requestView;

@property (weak, nonatomic) IBOutlet UIView *viewAcceptWaitTimer;
@property (weak, nonatomic) IBOutlet MIBadgeButton *btnmenu;

@property (weak, nonatomic) IBOutlet UIButton *btnShareRides;
@property (weak, nonatomic) IBOutlet UILabel *lblMessage;
@property (weak, nonatomic) IBOutlet MIBadgeButton *btnPhone;
@property (weak, nonatomic) IBOutlet UIView *viewReadMessage;
@property (weak, nonatomic) IBOutlet UILabel *lblNewMessageReceived;
@property (weak, nonatomic) IBOutlet UIButton *btnReply;
@property (assign, nonatomic) BOOL isRegireToLoadCities;
@property (weak, nonatomic) IBOutlet UIButton *btnDirection;
@property (weak, nonatomic) IBOutlet UIView *viewSentOffer;
@property (weak, nonatomic) IBOutlet UIButton *btnViewSentOffer;
@property (weak, nonatomic) IBOutlet UIView *viewRequestCount;
@property (weak, nonatomic) IBOutlet UIView *viewSentOfferCount;

@property (weak, nonatomic) IBOutlet UILabel *lblRequestsText;
@property (weak, nonatomic) IBOutlet UILabel *lblSentOffersText;

@property (weak, nonatomic) IBOutlet UILabel *lblRequestCountValue;
@property (weak, nonatomic) IBOutlet UILabel *lblSentRequestValue;
@property (weak, nonatomic) IBOutlet UILabel *lblCancelButtonText;

@property (weak, nonatomic) IBOutlet UIView *viewCancelBeforeBegin;
@property (weak, nonatomic) IBOutlet UIButton *btnSos;
@property (weak, nonatomic) IBOutlet UILabel *lblPaymentStatus;
@property (weak, nonatomic) IBOutlet UILabel *lblWalletBalanceText;

@property (weak, nonatomic) IBOutlet UIButton *btnRequestExpand;
@property (weak, nonatomic) IBOutlet UILabel *lblWalletBalanceValue;
@property (weak, nonatomic) IBOutlet UILabel *lblOnGoingCounter;

@property(assign,nonatomic)BOOL isRequiredToResfrehDriverProfile;
- (IBAction)onOpenRequestButtonTap:(id)sender;
-(void)stopLocationUpdate;
- (void)refreshTripStatusRefresh:(NSString *) tripId tripStatus:(NSString *)tripStatus;
@end
