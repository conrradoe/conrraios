//
//  BeginTripViewController.m
//  HIREME_RIDER
//
//  Created by Appicial Taxi App Soutions on 15/06/17.
//  Copyright © 2023 Appicial Taxi App Soutions. All rights reserved.
//

#import "BeginTripViewController.h"
#import "ConrraAvisoLocal.h"
#import "AppDelegate.h"
#import "GoogleDirectionSource.h"
#import "WebCallConstants.h"
#import "UFareSummeryViewController.h"
#import <GIKit/GIKit.h>
#import "UIViewController+LGSideMenuController.h"
#import "CustomPointAnnotation.h"
#import "UIImageView+WebCache.h"
#import "Utilities.h"
#import "CategoryModel.h"
#import "UIHelper.h"
#import "UChatViewController.h"
#import "FireBaseModel.h"
#import "UIViewController+Extension.h"
#import "FirebaseUnReadChat.h"
#import "UHomeViewController.h"
#import "UIView+UpdateAutoLayoutConstraints.h"
#import "MapBearingCalculation.h"
@interface BeginTripViewController () <MKMapViewDelegate, UITextViewDelegate, AutoHideAlertDelegate>

@property (nonatomic, strong) MKMapView      *mapView;

@property (nonatomic, strong) UIView         *sheetPanel;
@property (nonatomic, strong) UIView         *dragHandle;

@property (nonatomic, strong) UILabel        *statusLabel;
@property (nonatomic, strong) UIButton       *actionButton;
@property (nonatomic, strong) UIButton       *shareButton;
@property (nonatomic, strong) UILabel        *lbTripOtp;

@property (nonatomic, strong) UIButton       *btnGps;

@property (nonatomic, strong) UIView         *driverCard;
@property (nonatomic, strong) UIImageView    *imgDriver;
@property (nonatomic, strong) UILabel        *starRatingLbl;
@property (nonatomic, strong) UILabel        *lblDriverName;
@property (nonatomic, strong) UILabel        *lbCarName;
@property (nonatomic, strong) UIImageView    *imageVehicle;
@property (nonatomic, strong) UILabel        *lblCarNumber;

@property (nonatomic, strong) UIView         *destinationCard;
@property (nonatomic, strong) UILabel        *destinationLabel;

@property (nonatomic, strong) UIView         *paymentRow;
@property (nonatomic, strong) UILabel        *paymentAmountLabel;

@property (nonatomic, strong) UIButton       *btnCancelTrip;

@property (nonatomic, strong) UIView         *viewCancelReason;
@property (nonatomic, strong) UILabel        *lblWhy;
@property (nonatomic, strong) UITextView     *txtCancelReason;
@property (nonatomic, strong) UIButton       *btnCancelReasonOk;
@property (nonatomic, strong) UIButton       *btnCancelReasonClose;

@property (nonatomic, strong) UIView         *viewDriverLicence;
@property (nonatomic, strong) UIImageView    *licenceImageView;
@property (nonatomic, strong) UIButton       *btnDriverLicance;

@property (nonatomic, strong) UIView         *viewMessage;
@property (nonatomic, strong) UIImageView    *msgAvatarView;
@property (nonatomic, strong) UILabel        *msgDriverNameLabel;
@property (nonatomic, strong) UILabel        *msgPreviewLabel;
@property (nonatomic, strong) MIBadgeButton  *btnPhone;

@property (nonatomic, strong) UIView         *riderTopBar;
@property (nonatomic, strong) UIButton       *riderTopBarMenuBtn;
@property (nonatomic, strong) UILabel        *riderTopBarTitleLabel;

@property (nonatomic, assign) CGFloat        sheetTop;

@property (nonatomic, weak) UIButton       *sosOutlet;
@property (nonatomic, weak) UIButton       *btCurrentLocation;
@property (nonatomic, weak) UIView         *viewTime;
@property (nonatomic, weak) UILabel        *lbMovingTowrdsHeading;
@property (nonatomic, weak) UILabel        *lbMovingTwordsAddress;
@property (nonatomic, weak) UIButton       *btnReply;
@property (nonatomic, weak) UILabel        *lblCarType;
@property (nonatomic, weak) UIView         *viewRating;
@property (nonatomic, weak) UILabel        *lblDetinationTitle;
@property (nonatomic, weak) UILabel        *lbDestination;
@property (nonatomic, weak) UILabel        *lbTime;
@property (nonatomic, weak) UILabel        *lblTime;
@property (nonatomic, weak) UIView         *cancelSepratorView;
@property (nonatomic, weak) NSLayoutConstraint *btncanceltripHeightconstraints;
@property (nonatomic, weak) UIImageView    *imDirverLincence;
@property (nonatomic, weak) UIImageView    *imMsgDriverProfile;
@property (nonatomic, weak) UILabel        *lblMsgDriverName;
@property (nonatomic, weak) UILabel        *lblMessage;

@end

@implementation BeginTripViewController
{
    BOOL sosApiCalled;
    BOOL isBeginTripCalled;
    BOOL isEndTripCalled;
    BOOL isArriveTripCalled;
    UIPanGestureRecognizer *panRec;
    UIPinchGestureRecognizer *pinchRec;
    BOOL isDragged, isToRemoveFirebaseHandles;
    MKPointAnnotation *userPin;
    NSTimer *tripCheckTimer;
    NSString * currentTripStatus;
    NSArray * arrayAnotations;
    CustomPointAnnotation *driverAnnotaion;
    BOOL isViewWillAppearCalled, isNotificationCame;
    NSString *statusPre;
    BOOL isFirstLoad;
    NSTimer *mapCenterTimer;
    FirebaseUnReadChat *_firebaseUnReadChat;
    NSTimer *timerBlink;
    BOOL blinkStatus;
    /** Cuantos no leidos habia la ultima vez, para avisar solo cuando sube. */
    int ultimoConteoNoLeidos;
    /** La primera lectura trae los mensajes que YA estaban sin leer: esos no se avisan. */
    BOOL primeraLecturaChat;
    NSString * driverLicensePath;
    BOOL isGoToHomeScreen;
    BOOL isBeginRouteDraw;
    BOOL isFirstRouteDraw;
    BOOL isBeginRouteCalling;
    MKAnnotationView *driverPinView;
    MapBearingCalculation * _mapBearingCalculation;
    CLLocation * pickupDriverOldLatong;
    AutoHideAlert * autoHideBeginAlert;
    AutoHideAlert * autoHideArriveAlert;
    AutoHideAlert * autoHideCancelAlert;
    DirectionModel * oldDModel;
}


-(void) cancellAllTimerWhenGoToHome{
    isGoToHomeScreen=YES;
    if(timerBlink){
        [timerBlink invalidate];
        timerBlink=nil;
    }
    if(tripCheckTimer){
        [tripCheckTimer invalidate];
        tripCheckTimer=nil;
    }
    if(mapCenterTimer){
        [mapCenterTimer invalidate];
        mapCenterTimer=nil;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.sheetTop = UIScreen.mainScreen.bounds.size.height * 0.44;
    [self setupMapView];
    [self setupSheet];
    [self setupGpsButton];
    [self setupDriverCard];
    [self setupDestinationCard];
    [self setupPaymentRow];
    [self setupCancelButton];
    [self setupCancelReasonOverlay];
    [self setupDriverLicenceOverlay];
    [self setupMessageBanner];

    [self setupRiderTopBar];

    self.navigationItem.title = @"Pide un Taxi";
    self.navigationItem.hidesBackButton = YES;

    self.sosOutlet             = self.actionButton;
    self.btCurrentLocation     = self.btnGps;
    self.lbMovingTowrdsHeading = self.statusLabel;
    self.lbMovingTwordsAddress = self.destinationLabel;
    self.lblCarType            = self.lbCarName;
    self.lbDestination         = self.destinationLabel;
    self.imDirverLincence      = self.licenceImageView;
    self.imMsgDriverProfile    = self.msgAvatarView;
    self.lblMsgDriverName      = self.msgDriverNameLabel;
    self.lblMessage            = self.msgPreviewLabel;

    self.viewTime              = self.sheetPanel;
    self.viewRating            = self.driverCard;
    self.btnReply              = self.btnPhone;
    self.lblDetinationTitle    = self.destinationLabel;
    self.cancelSepratorView    = self.btnCancelTrip;

    UILabel *etaLabel = [[UILabel alloc] init];
    etaLabel.hidden = YES;
    etaLabel.font = [UIFont fontWithName:@"NotoSans-Regular" size:11]
                    ?: [UIFont systemFontOfSize:11];
    etaLabel.textColor = [UIColor colorWithWhite:0.45 alpha:1];
    [self.sheetPanel addSubview:etaLabel];
    self.lbTime  = etaLabel;
    self.lblTime = etaLabel;

    defaults_remove(@"last_mod_time");
    _mapBearingCalculation = [[MapBearingCalculation alloc] init];
    [APP_DELEGATE setNavigationController:self.navigationController];

    if (self.constantModel == nil) {
        self.constantModel = [ConstantModel getConstantsObject];
    }

    [self setUIFiels];
    [self getAssets];
    [self setThemeConstants];

    UIImage *sosAsset = [UIImage imageNamed:@"ic_sos_button"];
    if (sosAsset) {
        [self.sosOutlet setImage:sosAsset forState:UIControlStateNormal];
        self.sosOutlet.imageView.contentMode = UIViewContentModeScaleAspectFit;
        self.sosOutlet.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    }
    [self.sosOutlet addTarget:self action:@selector(multipleTap:withEvent:)
             forControlEvents:UIControlEventTouchDownRepeat];

    [self.btnPhone setHideWhenZero:YES];
    [self.btnPhone setBadgeBackgroundColor:[UIColor clearColor]];
    [self.btnPhone setBadgeEdgeInsets:UIEdgeInsetsMake(6, 0, 0, 6)];
    [self applyTintOnButton:self.btnPhone iconName:@"ic_phone_message"];

    [self addUserInteractionChangeHandlerOnMap];

    if (_isFromrequest) {
        [self setTripData];
        [self setUpUi];
    }

    currentTripStatus = defaults_object(@"trip_status");
    if (self.currentTrip == nil) {
        [self initDummyTrip];
    } else {
        [self checkTripStatus];
    }

    [self setUpChatUnreadCount];
}


- (void)setupMapView {
    self.mapView = [[MKMapView alloc] initWithFrame:self.view.bounds];
    self.mapView.mapType = MKMapTypeMutedStandard;
    self.mapView.showsUserLocation = NO;
    self.mapView.delegate = self;
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.mapView];
    [self.view sendSubviewToBack:self.mapView];
}

- (void)setupGpsButton {
    self.btnGps = [UIButton buttonWithType:UIButtonTypeCustom];

    UIImage *gpsIcon = [UIImage imageNamed:@"ic_gps_button"];
    if (gpsIcon) {
        [self.btnGps setImage:gpsIcon forState:UIControlStateNormal];
    } else {
        if (@available(iOS 13.0, *)) {
            UIImage *sfIcon = [UIImage systemImageNamed:@"location.circle.fill"];
            [self.btnGps setImage:sfIcon forState:UIControlStateNormal];
        }
        self.btnGps.backgroundColor = UIColor.whiteColor;
        self.btnGps.layer.cornerRadius = 22.0f;
        UIColor *accentColor = [UIColor colorNamed:@"app_theame"];
        if (!accentColor) {
            accentColor = [UIColor colorWithRed:235/255.0 green:181/255.0 blue:24/255.0 alpha:1.0];
        }
        self.btnGps.tintColor = accentColor;
    }

    self.btnGps.layer.shadowColor  = UIColor.blackColor.CGColor;
    self.btnGps.layer.shadowOpacity = 0.15f;
    self.btnGps.layer.shadowRadius  = 6.0f;
    self.btnGps.layer.shadowOffset  = CGSizeMake(0, 2);

    [self.btnGps addTarget:self action:@selector(onMyLocationButtonTap:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.btnGps];
}

- (void)setupSheet {
    self.sheetPanel = [[UIView alloc] init];
    self.sheetPanel.backgroundColor = UIColor.whiteColor;
    self.sheetPanel.layer.cornerRadius = 20;
    self.sheetPanel.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
    self.sheetPanel.layer.shadowColor   = UIColor.blackColor.CGColor;
    self.sheetPanel.layer.shadowOpacity = 0.10f;
    self.sheetPanel.layer.shadowRadius  = 12;
    self.sheetPanel.layer.shadowOffset  = CGSizeMake(0, -2);
    [self.view addSubview:self.sheetPanel];

    // Drag handle pill
    self.dragHandle = [[UIView alloc] init];
    self.dragHandle.backgroundColor = [UIColor colorWithWhite:0.80 alpha:1];
    self.dragHandle.layer.cornerRadius = 2.5;
    [self.sheetPanel addSubview:self.dragHandle];

    [self setupHeaderRow];
}

- (void)setupRiderTopBar {
    self.riderTopBar = [[UIView alloc] init];
    self.riderTopBar.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.97f];
    self.riderTopBar.layer.shadowColor = [UIColor blackColor].CGColor;
    self.riderTopBar.layer.shadowOpacity = 0.08f;
    self.riderTopBar.layer.shadowRadius = 6.0f;
    self.riderTopBar.layer.shadowOffset = CGSizeMake(0, 2);
    [self.view addSubview:self.riderTopBar];

    self.riderTopBarMenuBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.riderTopBarMenuBtn.backgroundColor = [UIColor colorWithRed:0.157f green:0.157f blue:0.157f alpha:1.0f];
    self.riderTopBarMenuBtn.layer.cornerRadius = 22;
    self.riderTopBarMenuBtn.clipsToBounds = YES;
    UIImage *menuIcon = [UIImage imageNamed:@"ic_hamburger"];
    if (menuIcon) {
        [self.riderTopBarMenuBtn setImage:menuIcon forState:UIControlStateNormal];
    } else if (@available(iOS 13.0, *)) {
        UIImage *sysImg = [UIImage systemImageNamed:@"line.horizontal.3"];
        if (sysImg) {
            [self.riderTopBarMenuBtn setImage:[sysImg imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
            self.riderTopBarMenuBtn.tintColor = [UIColor whiteColor];
        }
    }
    [self.riderTopBarMenuBtn addTarget:self action:@selector(onMenuButtonTap:) forControlEvents:UIControlEventTouchUpInside];
    [self.riderTopBar addSubview:self.riderTopBarMenuBtn];

    self.riderTopBarTitleLabel = [[UILabel alloc] init];
    self.riderTopBarTitleLabel.text = @"Pide un Taxi";
    self.riderTopBarTitleLabel.font = [UIFont fontWithName:@"NotoSans-Bold" size:18] ?: [UIFont boldSystemFontOfSize:18];
    self.riderTopBarTitleLabel.textColor = [UIColor colorWithRed:0.157f green:0.157f blue:0.157f alpha:1.0f];
    self.riderTopBarTitleLabel.textAlignment = NSTextAlignmentCenter;
    [self.riderTopBar addSubview:self.riderTopBarTitleLabel];
}

- (void)setupHeaderRow {
    // Status label
    self.statusLabel = [[UILabel alloc] init];
    self.statusLabel.font = [UIFont fontWithName:@"NotoSans-Regular" size:15]
                            ?: [UIFont systemFontOfSize:15];
    self.statusLabel.textColor = [UIColor colorNamed:@"color_app_label"]
                              ?: [UIColor colorWithWhite:0.15 alpha:1];
    self.statusLabel.numberOfLines = 2;
    [self.sheetPanel addSubview:self.statusLabel];

    // OTP label (visible only on TS_BEGIN)
    self.lbTripOtp = [[UILabel alloc] init];
    self.lbTripOtp.hidden = YES;
    self.lbTripOtp.numberOfLines = 1;
    [self.sheetPanel addSubview:self.lbTripOtp];

    // Share button
    self.shareButton = [UIButton buttonWithType:UIButtonTypeSystem];
    if (@available(iOS 13.0, *)) {
        [self.shareButton setImage:[UIImage systemImageNamed:@"square.and.arrow.up"] forState:UIControlStateNormal];
    } else {
        [self.shareButton setTitle:[LanguageHelper getStringWithKey:@"k_9_s4_a1_share" defaultValue:@"Compartir"] forState:UIControlStateNormal];
        self.shareButton.titleLabel.font = [UIFont fontWithName:@"NotoSans-Regular" size:12]
                                           ?: [UIFont systemFontOfSize:12];
    }
    self.shareButton.tintColor = [UIColor colorWithWhite:0.4 alpha:1];
    [self.shareButton addTarget:self action:@selector(btnShareTripClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.sheetPanel addSubview:self.shareButton];

    // Action button (SOS or Phone — content set by updateHeaderForStatus:)
    self.actionButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.actionButton.layer.cornerRadius = 24;
    self.actionButton.clipsToBounds = YES;
    [self.sheetPanel addSubview:self.actionButton];
}

- (void)setupDriverCard {
    self.driverCard = [[UIView alloc] init];
    self.driverCard.backgroundColor = UIColor.whiteColor;
    self.driverCard.layer.cornerRadius = 12;
    self.driverCard.layer.shadowColor   = UIColor.blackColor.CGColor;
    self.driverCard.layer.shadowOpacity = 0.08f;
    self.driverCard.layer.shadowRadius  = 10;
    self.driverCard.layer.shadowOffset  = CGSizeMake(0, 2);
    [self.sheetPanel addSubview:self.driverCard];

    // Avatar
    self.imgDriver = [[UIImageView alloc] init];
    self.imgDriver.contentMode = UIViewContentModeScaleAspectFill;
    self.imgDriver.clipsToBounds = YES;
    self.imgDriver.backgroundColor = [UIColor colorWithWhite:0.92 alpha:1];
    [self.driverCard addSubview:self.imgDriver];

    // Rating
    self.starRatingLbl = [[UILabel alloc] init];
    self.starRatingLbl.font = [UIFont fontWithName:@"NotoSans-Regular" size:13]
                              ?: [UIFont systemFontOfSize:13];
    self.starRatingLbl.textColor = [UIColor colorWithWhite:0.45 alpha:1];
    [self.driverCard addSubview:self.starRatingLbl];

    // Driver name
    self.lblDriverName = [[UILabel alloc] init];
    self.lblDriverName.font = [UIFont fontWithName:@"NotoSans-Bold" size:16]
                              ?: [UIFont boldSystemFontOfSize:16];
    self.lblDriverName.textColor = [UIColor colorNamed:@"color_app_label"]
                                   ?: [UIColor colorWithRed:40/255.0 green:40/255.0 blue:40/255.0 alpha:1];
    [self.driverCard addSubview:self.lblDriverName];

    // Car name/model
    self.lbCarName = [[UILabel alloc] init];
    self.lbCarName.font = [UIFont fontWithName:@"NotoSans-Regular" size:13]
                          ?: [UIFont systemFontOfSize:13];
    self.lbCarName.textColor = [UIColor colorWithWhite:0.45 alpha:1];
    [self.driverCard addSubview:self.lbCarName];

    // Car image
    self.imageVehicle = [[UIImageView alloc] init];
    self.imageVehicle.contentMode = UIViewContentModeScaleAspectFit;
    self.imageVehicle.clipsToBounds = YES;
    [self.driverCard addSubview:self.imageVehicle];

    // Plate number
    self.lblCarNumber = [[UILabel alloc] init];
    self.lblCarNumber.font = [UIFont fontWithName:@"NotoSans-Regular" size:11]
                             ?: [UIFont systemFontOfSize:11];
    self.lblCarNumber.textColor = [UIColor colorWithWhite:0.45 alpha:1];
    self.lblCarNumber.textAlignment = NSTextAlignmentRight;
    [self.driverCard addSubview:self.lblCarNumber];
}

- (void)setupDestinationCard {
    self.destinationCard = [[UIView alloc] init];
    self.destinationCard.backgroundColor = UIColor.whiteColor;
    self.destinationCard.layer.cornerRadius = 12;
    self.destinationCard.layer.shadowColor   = UIColor.blackColor.CGColor;
    self.destinationCard.layer.shadowOpacity = 0.08f;
    self.destinationCard.layer.shadowRadius  = 10;
    self.destinationCard.layer.shadowOffset  = CGSizeMake(0, 2);
    [self.sheetPanel addSubview:self.destinationCard];

    self.destinationLabel = [[UILabel alloc] init];
    self.destinationLabel.font = [UIFont fontWithName:@"NotoSans-Regular" size:15]
                                 ?: [UIFont systemFontOfSize:15];
    self.destinationLabel.textColor = [UIColor colorNamed:@"color_app_label"]
                                      ?: [UIColor colorWithWhite:0.2 alpha:1];
    self.destinationLabel.numberOfLines = 0;
    [self.destinationCard addSubview:self.destinationLabel];

    UIButton *pinBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    if (@available(iOS 13.0, *)) {
        [pinBtn setImage:[UIImage systemImageNamed:@"mappin.circle.fill"] forState:UIControlStateNormal];
    } else {
        [pinBtn setTitle:@"📍" forState:UIControlStateNormal];
    }
    pinBtn.tintColor = [UIColor colorWithWhite:0.55 alpha:1];
    pinBtn.userInteractionEnabled = NO;
    pinBtn.tag = 901;
    [self.destinationCard addSubview:pinBtn];
}

- (void)setupPaymentRow {
    self.paymentRow = [[UIView alloc] init];
    self.paymentRow.backgroundColor = [UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1];
    [self.sheetPanel addSubview:self.paymentRow];

    UILabel *payLabel = [[UILabel alloc] init];
    payLabel.text = @"Monto a pagar:";
    payLabel.font = [UIFont fontWithName:@"NotoSans-Regular" size:15]
                    ?: [UIFont systemFontOfSize:15];
    payLabel.textColor = [UIColor colorWithWhite:0.45 alpha:1];
    payLabel.tag = 902;
    [self.paymentRow addSubview:payLabel];

    self.paymentAmountLabel = [[UILabel alloc] init];
    self.paymentAmountLabel.font = [UIFont fontWithName:@"NotoSans-Bold" size:22]
                                   ?: [UIFont boldSystemFontOfSize:22];
    self.paymentAmountLabel.textColor = [UIColor colorNamed:@"color_app_label"]
                                        ?: [UIColor colorWithRed:40/255.0 green:40/255.0 blue:40/255.0 alpha:1];
    self.paymentAmountLabel.textAlignment = NSTextAlignmentRight;
    [self.paymentRow addSubview:self.paymentAmountLabel];
}

- (void)setupCancelButton {
    self.btnCancelTrip = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.btnCancelTrip setTitle:@"Cancelar recorrido" forState:UIControlStateNormal];
    self.btnCancelTrip.titleLabel.font = [UIFont fontWithName:@"NotoSans-Bold" size:17]
                                         ?: [UIFont boldSystemFontOfSize:17];
    [self.btnCancelTrip setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    self.btnCancelTrip.backgroundColor = [UIColor colorWithRed:232/255.0 green:232/255.0 blue:232/255.0 alpha:1];
    self.btnCancelTrip.layer.cornerRadius = 14;
    self.btnCancelTrip.clipsToBounds = YES;
    [self.btnCancelTrip addTarget:self action:@selector(CancelTripCalled) forControlEvents:UIControlEventTouchUpInside];
    [self.sheetPanel addSubview:self.btnCancelTrip];
}

- (void)setupCancelReasonOverlay {
    self.viewCancelReason = [[UIView alloc] initWithFrame:self.view.bounds];
    self.viewCancelReason.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.viewCancelReason.backgroundColor = UIColor.whiteColor;
    self.viewCancelReason.hidden = YES;
    [self.view addSubview:self.viewCancelReason];

    self.lblWhy = [[UILabel alloc] init];
    self.lblWhy.font = [UIFont fontWithName:@"NotoSans-Bold" size:17]
                       ?: [UIFont boldSystemFontOfSize:17];
    self.lblWhy.textColor = [UIColor colorNamed:@"color_app_label"]
                            ?: [UIColor colorWithWhite:0.15 alpha:1];
    self.lblWhy.textAlignment = NSTextAlignmentCenter;
    self.lblWhy.numberOfLines = 0;
    [self.viewCancelReason addSubview:self.lblWhy];

    self.txtCancelReason = [[UITextView alloc] init];
    self.txtCancelReason.font = [UIFont fontWithName:@"NotoSans-Regular" size:15]
                                ?: [UIFont systemFontOfSize:15];
    self.txtCancelReason.layer.borderColor   = [UIColor colorWithWhite:0.8 alpha:1].CGColor;
    self.txtCancelReason.layer.borderWidth   = 1;
    self.txtCancelReason.layer.cornerRadius  = 8;
    self.txtCancelReason.delegate = self;
    [self.viewCancelReason addSubview:self.txtCancelReason];

    UIColor *yellow = [UIColor colorNamed:@"app_theame"]
                      ?: [UIColor colorWithRed:235/255.0 green:181/255.0 blue:24/255.0 alpha:1];

    self.btnCancelReasonOk = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.btnCancelReasonOk setTitle:@"OK" forState:UIControlStateNormal];
    [self.btnCancelReasonOk setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    self.btnCancelReasonOk.titleLabel.font = [UIFont fontWithName:@"NotoSans-Bold" size:17]
                                             ?: [UIFont boldSystemFontOfSize:17];
    self.btnCancelReasonOk.backgroundColor = yellow;
    self.btnCancelReasonOk.layer.cornerRadius = 14;
    self.btnCancelReasonOk.clipsToBounds = YES;
    [self.btnCancelReasonOk addTarget:self action:@selector(onCancelReasonOk:) forControlEvents:UIControlEventTouchUpInside];
    [self.viewCancelReason addSubview:self.btnCancelReasonOk];

    self.btnCancelReasonClose = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.btnCancelReasonClose setTitle:[LanguageHelper getStringWithKey:@"k_18_s4_Ok" defaultValue:@"Cerrar"] forState:UIControlStateNormal];
    [self.btnCancelReasonClose setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    self.btnCancelReasonClose.titleLabel.font = [UIFont fontWithName:@"NotoSans-Bold" size:17]
                                                ?: [UIFont boldSystemFontOfSize:17];
    self.btnCancelReasonClose.backgroundColor = [UIColor colorWithRed:232/255.0 green:232/255.0 blue:232/255.0 alpha:1];
    self.btnCancelReasonClose.layer.cornerRadius = 14;
    self.btnCancelReasonClose.clipsToBounds = YES;
    [self.btnCancelReasonClose addTarget:self action:@selector(onCancelReasonClose:) forControlEvents:UIControlEventTouchUpInside];
    [self.viewCancelReason addSubview:self.btnCancelReasonClose];
}

- (void)setupDriverLicenceOverlay {
    self.viewDriverLicence = [[UIView alloc] initWithFrame:self.view.bounds];
    self.viewDriverLicence.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.viewDriverLicence.backgroundColor = [UIColor colorWithWhite:0 alpha:0.75];
    self.viewDriverLicence.hidden = YES;
    [self.view addSubview:self.viewDriverLicence];

    self.licenceImageView = [[UIImageView alloc] init];
    self.licenceImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.licenceImageView.clipsToBounds = YES;
    [self.viewDriverLicence addSubview:self.licenceImageView];

    self.btnDriverLicance = [UIButton buttonWithType:UIButtonTypeSystem];
    if (@available(iOS 13.0, *)) {
        [self.btnDriverLicance setImage:[UIImage systemImageNamed:@"xmark.circle.fill"] forState:UIControlStateNormal];
    } else {
        [self.btnDriverLicance setTitle:@"✕" forState:UIControlStateNormal];
    }
    self.btnDriverLicance.tintColor = UIColor.whiteColor;
    [self.btnDriverLicance addTarget:self action:@selector(onLincenceCloseButtonTap:) forControlEvents:UIControlEventTouchUpInside];
    [self.viewDriverLicence addSubview:self.btnDriverLicance];
}

- (void)setupMessageBanner {
    self.viewMessage = [[UIView alloc] init];
    self.viewMessage.backgroundColor = UIColor.whiteColor;
    self.viewMessage.layer.cornerRadius = 12;
    self.viewMessage.layer.shadowColor   = UIColor.blackColor.CGColor;
    self.viewMessage.layer.shadowOpacity = 0.10f;
    self.viewMessage.layer.shadowRadius  = 8;
    self.viewMessage.layer.shadowOffset  = CGSizeMake(0, 2);
    self.viewMessage.hidden = YES;
    [self.sheetPanel addSubview:self.viewMessage];

    self.msgAvatarView = [[UIImageView alloc] init];
    self.msgAvatarView.contentMode = UIViewContentModeScaleAspectFill;
    self.msgAvatarView.clipsToBounds = YES;
    self.msgAvatarView.backgroundColor = [UIColor colorWithWhite:0.92 alpha:1];
    [self.viewMessage addSubview:self.msgAvatarView];

    self.msgDriverNameLabel = [[UILabel alloc] init];
    self.msgDriverNameLabel.font = [UIFont fontWithName:@"NotoSans-Bold" size:13]
                                   ?: [UIFont boldSystemFontOfSize:13];
    self.msgDriverNameLabel.textColor = [UIColor colorNamed:@"color_app_label"]
                                        ?: [UIColor colorWithWhite:0.2 alpha:1];
    [self.viewMessage addSubview:self.msgDriverNameLabel];

    self.msgPreviewLabel = [[UILabel alloc] init];
    self.msgPreviewLabel.font = [UIFont fontWithName:@"NotoSans-Regular" size:12]
                                ?: [UIFont systemFontOfSize:12];
    self.msgPreviewLabel.textColor = [UIColor colorWithWhite:0.45 alpha:1];
    self.msgPreviewLabel.numberOfLines = 1;
    [self.viewMessage addSubview:self.msgPreviewLabel];

    self.btnPhone = [[MIBadgeButton alloc] init];
    if (@available(iOS 13.0, *)) {
        [self.btnPhone setImage:[UIImage systemImageNamed:@"bubble.left.fill"] forState:UIControlStateNormal];
    } else {
        [self.btnPhone setTitle:@"Chat" forState:UIControlStateNormal];
    }
    self.btnPhone.tintColor = [UIColor colorNamed:@"app_theame"]
                              ?: [UIColor colorWithRed:235/255.0 green:181/255.0 blue:24/255.0 alpha:1];
    [self.btnPhone addTarget:self action:@selector(ButtonMakeCall:) forControlEvents:UIControlEventTouchUpInside];
    [self.viewMessage addSubview:self.btnPhone];
}

-(void) setUIFiels{
    [self updateHeaderForStatus:self.currentTrip.trip_Status];
    self.destinationLabel.text = isEmpty(self.currentTrip.trip_drop_loc);
    
    //     self.rideStatusLbl.text = [LanguageHelper getStringWithKey:@"k_r3_s8_driver_arrive_in"];
    [self.btnCancelTrip setTitle: [LanguageHelper getStringWithKey:@"k_r2_s8_cancel_ride"]   forState:UIControlStateNormal];
    [self.btnReply setTitle:[LanguageHelper getStringWithKey:@"k_s11_reply"] forState:UIControlStateNormal];
    self.lblWhy.text=[LanguageHelper getStringWithKey:@"k_26_s3_write_reason"];
    [self.btnCancelReasonOk setTitle:Localise(@"k_18_s4_Ok") forState:(UIControlStateNormal)];
}



-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateUnReadCount) name:@"message_count_un_read" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotificationReceived:) name:AppNotificationName.USER_ACCEPT_NOTIFICATION object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appDidEnterForeground)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    
    if (isViewWillAppearCalled) {
        
        [self checkTripStatus];
    }
    isViewWillAppearCalled=NO;
    isNotificationCame =NO;
    isEndTripCalled =NO;
    isBeginTripCalled=NO;
    isArriveTripCalled =NO;
    [self setUpChatUnreadCount];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    //Firebase
    //    [self firebase_checkIfChatCameWhenAppNotRunning];
    //Firebase
    
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    isViewWillAppearCalled=YES;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if(tripCheckTimer)
    {
        [tripCheckTimer invalidate];
        tripCheckTimer=nil;
    }
    if(timerBlink)
    {
        [timerBlink invalidate];
        timerBlink=nil;
    }
    /// Firebase
    //    [self firebase_removeObservers];
    //Firebase
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)appDidEnterForeground{
    [self checkTripStatus];
    isViewWillAppearCalled=NO;
    isNotificationCame =NO;
    isEndTripCalled =NO;
}


-(void)getBeginRouteFormtripDataWithOutLoader{
    if(self.currentTrip.is_share){
        CLLocation * userLoc=[[CLLocation alloc]   initWithLatitude:self.currentTrip.driver.lat  longitude:self.currentTrip.driver.lng ];
        CLLocation * driverLoc=[[CLLocation alloc]  initWithLatitude:[self.currentTrip.trip_drop_lat doubleValue] longitude:[self.currentTrip.trip_drop_long doubleValue]];
        [self.mapView removeOverlays:self.mapView.overlays];
        GoogleDirectionSource * userDriverLocationRoute=[[GoogleDirectionSource alloc]  initWithSource:userLoc destination:driverLoc];
        [self addMapAnnotationsWith:userDriverLocationRoute];
        
        return;
    }
    [self getBeginRouteFormtripData:NO];
}

-(void)getBeginRouteFormtripData{
    [self getBeginRouteFormtripData:YES];
}

-(void) getBeginRouteFormtripData:(BOOL ) isShowLoader{
    if(isBeginRouteCalling){
        return;
    }
    isBeginRouteCalling=YES;
    NSMutableDictionary * dict=[[NSMutableDictionary alloc] init];
    [dict setObject:[NSString stringWithFormat:@"%@",self.currentTrip.trip_Id] forKey:@"trip_id"];
    NSString * lastModDate=defaults_object(@"last_mod_time");
    if(lastModDate){
        [dict setObject:lastModDate forKey:@"last_mod_time"];
    }else{
        [dict setObject:self.currentTrip.trip_created forKey:@"last_mod_time"];
    }
    CLLocation * userLoc=[[CLLocation alloc]   initWithLatitude:self.currentTrip.driver.lat  longitude:self.currentTrip.driver.lng ];
    CLLocation * driverLoc=[[CLLocation alloc]  initWithLatitude:[self.currentTrip.trip_drop_lat doubleValue] longitude:[self.currentTrip.trip_drop_long doubleValue]];
    if(isShowLoader){
        [UtilityClass setLH:NO wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
    }
    if(!isBeginRouteDraw){
        [self.mapView removeOverlays:self.mapView.overlays];
    }
    GoogleDirectionSource * userDriverLocationRoute=[[GoogleDirectionSource alloc]  initWithSource:userLoc destination:driverLoc];
    [GIC mkwerwu:GET_ROUTE  d:dict    cb:^(id results, NSError *error) {
        self->isBeginRouteCalling=NO;
        if(isShowLoader){
            [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
        }
        //        if(error==nil){
        if(![[results objectForKey:P_RESPONSE] isKindOfClass:[NSArray class]]) {
            return;
        }
        NSArray *tripData=[results objectForKey:P_RESPONSE];
        if(tripData.count==0)  {
            return;
        }
        NSString* route_data=[[tripData  objectAtIndex:0] objectForKey:@"temp_route_data"];
        if(route_data.length<2){
            return;
        }
        NSArray *arrayPath=  [userDriverLocationRoute decodePoints:route_data];
        if(arrayPath.count>0){
            defaults_set_object(@"last_mod_time", [Utilities getStringFromDate:[NSDate date]]);
            [self.mapView removeOverlays:self.mapView.overlays];
            MKPolyline *polyline=[self getPolyline:arrayPath];
            [self.mapView addOverlay:polyline];
            [self addMapAnnotationsWith:userDriverLocationRoute];
            //            [self.mapView setVisibleMapRect:[polyline boundingMapRect] edgePadding:UIEdgeInsetsMake(40.0, 60.0, 40.0, 60.0) animated:YES];
            //            self.mapBottonMargin.constant=-((self.mapView.frame.size.height/2)*80/100.0);
            [self updateDriverAnotation:userLoc];
            self->isBeginRouteDraw=YES;
        }else{
            //                    [self showPickAndDropAnnotaion];
        }
        //        }
        
        //        [self invalidateTripBeginRouteCheckTimer];
        //        if(!self->isViewWillAppearCalled){
        //            dispatch_async(dispatch_get_main_queue(), ^{
        //                if(!self->isGoToHomeScreen){
        //                    self->tripBeginRouteCheckTimer = [NSTimer scheduledTimerWithTimeInterval:TIMER_DURATION_BEGIN_ROUTE_REFRESH target: self
        //                                                                                    selector: @selector(getBeginRouteFormtripDataWithOutLoader) userInfo: nil repeats: NO];
        //                    [[NSRunLoop currentRunLoop] addTimer:self->tripBeginRouteCheckTimer forMode:NSRunLoopCommonModes];
        //                }
        //            });
        //        }
    }];
}


-(MKPolyline *) getPolyline:(NSArray *)array{
    CLLocationCoordinate2D coords[array.count];
    for (int i = 0; i <array.count; i++) {
        CLLocation *p=[array  objectAtIndex:i];
        coords[i] = CLLocationCoordinate2DMake(p.coordinate.latitude,p.coordinate.longitude);
    }
    //    [self .mapView removeAnnotations:arrayAnotations];
    //    [self.mapView removeAnnotation:pickUpPin];
    //    [self.mapView removeAnnotation:dropPin];
    //    CustomPointAnnotation * pickUpPin=[[CustomPointAnnotation alloc]  initWithType:@"pick"];
    
    //    CLLocation *pPickup=[array  objectAtIndex:0];
    
    //    pickUpPin.coordinate =CLLocationCoordinate2DMake(pPickup.coordinate.latitude,pPickup.coordinate.longitude);
    //    [self.mapView addAnnotation:pickUpPin];
    //    CustomPointAnnotation *   dropPin=[[CustomPointAnnotation alloc]  initWithType:@"drop"];
    //    CLLocation *drop=[array  objectAtIndex:array.count-1];
    //    dropPin.coordinate=CLLocationCoordinate2DMake(drop.coordinate.latitude,drop.coordinate.longitude);
    //    [self.mapView addAnnotation:dropPin];
    //    [self.mapView removeAnnotations:arrayAnotations];
    //    arrayAnotations=@[pPickup,drop];
    
    return   [MKPolyline polylineWithCoordinates:coords count:array.count];
}

-(void)setTripData{
    if(  self.currentTrip.driver.d_fname==nil||self.currentTrip.driver.d_fname.length==0){
        self->isFirstLoad =NO;
    }
    [self showTripOtpOnUi];
    self.lblCarType.text = self.currentTrip.driver.carname;
    self.lblCarNumber.text = self.currentTrip.driver.car_registration_no;
    self.lbCarName.text =[NSString stringWithFormat:@"%@(%@)",isEmpty( self.currentTrip.driver.car_name),isEmpty( self.currentTrip.driver.car_model)];
    
    NSString *profile= self.currentTrip.driver.d_profile_image_path;
    if([profile isKindOfClass:[NSNull class]]){
        [_imgDriver  setImage:[UIImage imageNamed:@"Profile Icon Crop Image"]];
    }else{
        if (profile.length>0) {
            [_imgDriver sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",url_base_images, profile]] placeholderImage:[UIImage imageNamed:@"Profile Icon Crop Image"]];
        }else {
            [_imgDriver  setImage:[UIImage imageNamed:@"Profile Icon Crop Image"]];
        }
    }
    
    _lblDriverName.text=[NSString stringWithFormat:@"%@ %@", isEmpty(self.currentTrip.driver.d_fname),isEmpty(self.currentTrip.driver.d_lname)];
    
    [self updateHeaderForStatus:self.currentTrip.trip_Status];
    self.destinationLabel.text = isEmpty(self.currentTrip.trip_drop_loc);

    float rating=self.currentTrip.driver.rating;
    int result = (int)roundf(rating);
    _starRatingLbl.text=[NSString stringWithFormat:@"%d",result];
    if(result<=0){
        self.viewRating.hidden=YES;
    }else{
        self.viewRating.hidden=NO;
    }
//    if (self.isFromrequest) {
//        NSDictionary *dictEstimate = defaults_object(@"estimate");
//        if (dictEstimate) {
//            _lblDistance.text = [dictEstimate objectForKey:@"distance"];
//            _lblEstimatedAmount.text = [dictEstimate objectForKey:@"estimate"];
//            int time=[[dictEstimate objectForKey:@"time"] intValue];
//            _lblTime.text = [NSString stringWithFormat:@" %@ - %d %@",[LanguageHelper getStringWithKey:@"k_r3_s8_driver_arrive_in"] , time,[LanguageHelper getStringWithKey:time<=1?@"k_17_s4_min":@"k_17_s4_mins"]];
//        }
//        [self getEstimateDetails];
//    }
//    else{
//
//        [self getEstimateDetails];
//    }
//    if (_isFromrequest) {
//        [self setTripData];
//        [self setUpUi];
//    }
    if([self.currentTrip.trip_Status isEqualToString:TS_ACCEPTED]){
        [self getEstimateDetails];
    }else{
//        if(self.currentTrip.is_driver_busy){
//            self.lblTime.text=[LanguageHelper getStringWithKey:@"k_r3_s8_drvr_arv_in_bsy"];
//        }else{
            if([self.currentTrip.trip_Status isEqualToString:TS_BEGIN]){
                self.lblTime.text = [LanguageHelper getStringWithKey:@"k_r5_s8_on_ride"];
            }else{
                self.lblTime.text = [LanguageHelper getStringWithKey:@"k_r6_s8_driver_arrived"];
            }
//        }
        CLLocation * pickup=[[CLLocation alloc]   initWithLatitude:self.currentTrip.driver.lat  longitude:self.currentTrip.driver.lng];
        pickupDriverOldLatong = pickup;
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(pickup.coordinate, 600, 600);
        [self mapRegion:region mapView:self.mapView];
        [self updateDriverAnotation:pickup];
    }
    [self.imageVehicle sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",url_base_images, self.currentTrip.driver.d_car_image_path]]];

    // Populate payment amount label
    if (self.currentTrip.trip_fare.length > 0) {
        CityModel *cityModel = [CityModel getCityByCityId:self.currentTrip.city_id];
        NSString *formattedFare = [Utilities formatAmountAndCurrency:[self.currentTrip.trip_fare floatValue]
                                                            currency:cityModel.city_cur];
        self.paymentAmountLabel.text = formattedFare ?: self.currentTrip.trip_fare;
    }
}



-(void)setThemeConstants{
    [_lblDetinationTitle setFont:FONTS_THEME_REGULAR(18)];
    [_lbTime setFont:FONTS_THEME_REGULAR(11)];
    [_lbDestination setFont:FONTS_THEME_REGULAR(13)];
    // Removed: font set in setupCancelButton

}
-(void) initDummyTrip
{
    self.currentTrip=[[TripModel alloc]  init];
    self.currentTrip.trip_Id=@"128";
    [self.currentTrip refreshTripModelWithCompletionBlock:^(id results, NSError *error) {
        [self setUpUi];
        [self checkTripStatus];
    } isShowLoader:YES];
}

-(void)initMapView
{
}

-(void )onNotificationReceived:(NSNotification *) notification
{
    //     NSDictionary *dict = notification.userInfo;
    BOOL isCancelHandled=NO;
    //    AppDelegate * delegate=APP_DELEGATE;
    //    self.currentTrip.trip_Status=delegate.trip_status;
    //    currentTripStatus=delegate.trip_status;
    NSDictionary * dict=  notification.userInfo;
    NSMutableDictionary *dicAps=[dict valueForKey:@"aps"];
    NSString *status=[dicAps objectForKey:@"trip_status"];
    //    NSString *trip_id=[dicAps objectForKey:@"trip_id"];
    currentTripStatus=status;
    self.currentTrip.trip_Status=status;
    defaults_set_object(@"trip_status",self.currentTrip.trip_Status);
    
    if([self.currentTrip.trip_Status isEqualToString:TS_ARRIVE] )
    {
        [self showTripOtpOnUi];
        [self arriveTripCalled];
    }
    else if([self.currentTrip.trip_Status isEqualToString:TS_BEGIN]||[self.currentTrip.trip_Status isEqualToString:TS_PICKED])
    {
        [self showTripOtpOnUi];
        [self beginTripCalled];
    }
    else if([self.currentTrip.trip_Status isEqualToString:TS_END])
    {
        [self endtripCalled];
        
    }else if([self.currentTrip.trip_Status isEqualToString:TS_DRIVER_CANCEL_AT_PICKUP]){
        [self handelTripCancelCondition:TS_DRIVER_CANCEL_AT_PICKUP];
        isCancelHandled=YES;
    }
    else if([self.currentTrip.trip_Status isEqualToString:TS_DRIVER_CANCEL_AT_DROP]){
        [self handelTripCancelCondition:TS_DRIVER_CANCEL_AT_DROP];
        isCancelHandled=YES;
    }
    
    
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"FareAmountViewController"]) {
        
        isNotificationCame = YES;
        UFareSummeryViewController *fareView =(UFareSummeryViewController *)[segue destinationViewController];
        fareView.curr_trip =self.currentTrip;
        if (self.constantModel==nil) {
            self.constantModel =[ConstantModel getConstantsObject];
        }
        fareView.constantModel =self.constantModel;
        fareView.curr_trip = self.currentTrip;
        defaults_remove(@"estimate");
        
    }
    
}

-(void) checkTripStatus{
    if(self.currentTrip) {
        BOOL isDriverHas = NO;
        if([self.currentTrip.driver.driverId intValue]>0){
            isDriverHas=YES;
        }
        [self.currentTrip refreshTripModelWithCompletionBlock:^(id results, NSError *error) {
            if ([[[results objectForKey:P_STATUS] uppercaseString] isEqualToString:@"OK"]) {
                [self showTripOtpOnUi];
                if (!self->isFirstLoad) {
                    self->isFirstLoad =YES;
                    [self setTripData];
                    [self setUpUi];
                }else{
                    if(isDriverHas==NO){
                        [self setTripData];
                        [self setUpUi];
                    }
                }
                BOOL isCancelHandled=NO;
                
                if ([self.currentTrip.trip_Status isEqualToString:TS_BEGIN]||[self.currentTrip.trip_Status isEqualToString:TS_PICKED]||[self.currentTrip.trip_Status isEqualToString:TS_END]) {
                    self.btnCancelTrip.hidden=YES;
                    //self.btnPhone.hidden=YES;
                    [self.btnCancelTrip setConstraintConstant:0 forAttribute:(NSLayoutAttributeHeight)];
                    self.btncanceltripHeightconstraints.constant =0;
                    self.lbMovingTwordsAddress.text=self.currentTrip.trip_drop_loc;
                    [self removeDriverView];
                }
                
                
                if([self.currentTrip.trip_Status isEqualToString:TS_ACCEPTED]||[self.currentTrip.trip_Status isEqualToString:TS_ARRIVE]||[self.currentTrip.trip_Status isEqualToString:TS_BEGIN]||[self.currentTrip.trip_Status isEqualToString:TS_PICKED])  {
                    [self updateHeaderForStatus:self.currentTrip.trip_Status];
                    self.destinationLabel.text = isEmpty(self.currentTrip.trip_drop_loc);
                    if([self.currentTrip.trip_Status isEqualToString:TS_BEGIN]||[self.currentTrip.trip_Status isEqualToString:TS_PICKED]) {
                        self.sosOutlet.hidden=NO;
                    }else {
                        self.btnPhone.hidden=NO;
                        self.sosOutlet.hidden=NO;
                    }
//                    CLLocation  *driverLoc=[[CLLocation alloc]  initWithLatitude:self.currentTrip.driver.lat longitude:self.currentTrip.driver.lng];
//                    [self updateDriverAnotation:driverLoc];
                    if([self.currentTrip.trip_Status isEqualToString:TS_ACCEPTED]){
                        [self getEstimateDetails];
                    }
                    [self resetTripCheckTimer];
                }
                if([self.currentTrip.trip_Status isEqualToString:TS_END])
                {
                    [self endtripCalled];
                    return ;
                    
                    
                }
                
                if ([self.currentTrip.trip_Status isEqualToString:TS_BEGIN]||[self.currentTrip.trip_Status isEqualToString:TS_PICKED]){
                    [self beginTripCalled];
                    return;
                }
                
                if ([self.currentTrip.trip_Status isEqualToString:TS_ARRIVE]){
                    
                    [self arriveTripCalled];
                    return;
                }
                if([self.currentTrip.trip_Status isEqualToString:TS_RIDER_CANCEL]){
                    [self handelTripRiderCancelCondition:TS_RIDER_CANCEL];
                    isCancelHandled=YES;
                }
                if([self.currentTrip.trip_Status isEqualToString:TS_DRIVER_CANCEL_AT_PICKUP]){
                    [self handelTripCancelCondition:TS_DRIVER_CANCEL_AT_PICKUP];
                    isCancelHandled=YES;
                }
                
                if([self.currentTrip.trip_Status isEqualToString:TS_DRIVER_CANCEL_AT_DROP]){
                    [self handelTripCancelCondition:TS_DRIVER_CANCEL_AT_DROP];
                    isCancelHandled=YES;
                }
                
                else{
                    
                }
                
            }
            else{
                [self resetTripCheckTimer];
            }
        } isShowLoader:NO];
    }else{
        // if trip id  is aved then   getTrip data
        NSString *savedTripId=defaults_object(TRIP_ID);
        if(savedTripId!=nil)
        {
            self.currentTrip=[[TripModel alloc]  init];
            self.currentTrip.trip_Id=savedTripId;
            [self checkTripStatus];
        }
    }
}


-(void)resetTripCheckTimer{
    [self invalidateTripCheckTimer];
    if(!isGoToHomeScreen){
        if([[ConstantModel getConstantsObject] is_demo ]){
            self->tripCheckTimer = [NSTimer scheduledTimerWithTimeInterval: 5.0 target: self
                                                                  selector: @selector(checkTripStatus) userInfo: nil repeats: NO];
        }else{
            self->tripCheckTimer = [NSTimer scheduledTimerWithTimeInterval: TRIP_TIMER_DURATION target: self
                                                                  selector: @selector(checkTripStatus) userInfo: nil repeats: NO];
        }
        
        
    }
}


-(void)invalidateTripCheckTimer{
    if(tripCheckTimer){
        [tripCheckTimer invalidate];
        tripCheckTimer=nil;
    }
}


-(void) handelTripCancelCondition:(NSString *)status
{
    
    [self invalidateTripCheckTimer];
    currentTripStatus=self.currentTrip.trip_Status;
    
    //    appDelegate.trip_status=self.currentTrip.trip_Status;
    defaults_set_object(@"trip_status", self.currentTrip.trip_Status);
    [self showAlertWhenDriverCancelRequest:status cancelReason: self.currentTrip.trip_cancel_reason];
}

-(void) handelTripRiderCancelCondition:(NSString *)status
{
    [self invalidateTripCheckTimer];
    currentTripStatus=status;
    [self navigateTOHomeScreen];
}


-(void) showAlertWhenDriverCancelRequest:(NSString *) status cancelReason:(NSString * )cancelReson
{
    NSString *msg;
    
    if ([status isEqualToString:TS_DRIVER_CANCEL_AT_PICKUP]) {
        msg = [LanguageHelper getStringWithKey:@"k_5_s14_trip_cancelled_by_driver"]/*MESSAGE_DRIVER_CANCEL*/;
    }
    else{
        msg =[LanguageHelper getStringWithKey:@"k_2_s14_trip_conplete"]/*MESSAGE_END*/;
    }
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[LanguageHelper getStringWithKey:@"k_com_s_18_trip_status"]
                                                                             message:[NSString stringWithFormat:@"%@",msg]
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *actionOk = [UIAlertAction actionWithTitle:[LanguageHelper getStringWithKey:@"k_18_s4_Ok"]
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {
        [self->autoHideCancelAlert performAction];
    }]; //You can use a block here to handle a press on this button
    
    [alertController addAction:actionOk];
    [self presentViewController:alertController animated:YES completion:nil];
    
    autoHideCancelAlert =[[AutoHideAlert alloc] init];
    autoHideCancelAlert.delegate=self;
    [autoHideCancelAlert handle:alertController];
    autoHideCancelAlert.tripStatus = status;
}


-(void) setUpUi{
    [self updateHeaderForStatus:self.currentTrip.trip_Status ?: currentTripStatus];
    [self showTripOtpOnUi];
    self.destinationLabel.text = isEmpty(self.currentTrip.trip_drop_loc);
    if([self.currentTrip.trip_Status isEqualToString:TS_ACCEPTED]||[self.currentTrip.trip_Status isEqualToString:TS_ARRIVE])  {
//        [self.mapView removeOverlays:self.mapView.overlays];
        // user consider like destination
//        CLLocation * userLoc=[[CLLocation alloc]   initWithLatitude:[self.currentTrip.trip_pick_lat doubleValue] longitude:[self.currentTrip.trip_pick_long doubleValue]];
//
//        // user consider like source
//        CLLocation * driverLoc=[[CLLocation alloc]  initWithLatitude:self.currentTrip.driver.lat longitude:self.currentTrip.driver.lng];
//
//        [UtilityClass setLH:NO wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
//        GoogleDirectionSource * userDriverLocationRoute=[[GoogleDirectionSource alloc]  initWithSource:driverLoc destination:userLoc];
//        [userDriverLocationRoute  findDirection_isInTrip:YES WithCompletionBlock:^(id results, NSError *error) {
//            [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
//            if([results isKindOfClass:[DirectionModel class]])
//            {
//                DirectionModel * dModel=(DirectionModel *)results;
//                [self setTripTime:dModel.duration];
//                [self addMapAnnotationsWith:userDriverLocationRoute];
//                [self->_mapView addOverlay:[ dModel getPolyline] level:MKOverlayLevelAboveRoads];
//
//            }
//        }];
        
        [self getEstimateDetails];
        
    }else  if([self.currentTrip.trip_Status isEqualToString:TS_BEGIN]){
        [self.mapView removeOverlays:self.mapView.overlays];
//        CLLocation * userLoc=[[CLLocation alloc]   initWithLatitude:[self.currentTrip.trip_pick_lat doubleValue] longitude:[self.currentTrip.trip_pick_long doubleValue]];
//        CLLocation * driverLoc=[[CLLocation alloc]  initWithLatitude:[self.currentTrip.trip_drop_lat doubleValue] longitude:[self.currentTrip.trip_drop_long doubleValue]];
        [self getBeginRouteFormtripDataWithOutLoader];
        //        CLLocation * userLoc=[[CLLocation alloc]   initWithLatitude:[self.currentTrip.trip_pick_lat doubleValue] longitude:[self.currentTrip.trip_pick_long doubleValue]];
        //        CLLocation * driverLoc=[[CLLocation alloc]  initWithLatitude:[self.currentTrip.trip_drop_lat doubleValue] longitude:[self.currentTrip.trip_drop_long doubleValue]];
        //        [UtilityClass setLH:NO wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
        //        GoogleDirectionSource * userDriverLocationRoute=[[GoogleDirectionSource alloc]  initWithSource:userLoc destination:driverLoc];
        //        [userDriverLocationRoute  findDirection_isInTrip:YES WithCompletionBlock:^(id results, NSError *error) {
        //            [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
        //            if([results isKindOfClass:[DirectionModel class]])
        //            {
        //                [self addMapAnnotationsWith:userDriverLocationRoute];
        //                [self.lbDestination  setText:isEmpty(self->_currentTrip.trip_drop_loc)];
        //                DirectionModel * dModel=(DirectionModel *)results;
        //                [self setTripTime:dModel.duration];
        //                [self->_mapView addOverlay:[ dModel getPolyline] level:MKOverlayLevelAboveRoads];
        //            }
        //        }];
        
        [self removeDriverView];
    }
}



-(void)showTripOtpOnUi{
    NSString *otpNumber = _currentTrip.otp ?: @"";
    BOOL showOtp = NO;
    if(otpNumber.length > 0){
        if(self.constantModel.otp_start) {
            if(![_currentTrip.trip_Status isEqualToString:TS_BEGIN]){
                showOtp = YES;
            }else{
                if(self.constantModel.otp_end){
                    showOtp = YES;
                }
            }
        }else if(self.constantModel.otp_end){
            showOtp = YES;
        }
    }
    if(showOtp){
        self.statusLabel.text = [LanguageHelper getStringWithKey:@"k_r8_s8_give_number_to_driver" defaultValue:@"Dale este número a tu conductor"];
        self.statusLabel.font = [UIFont fontWithName:@"NotoSans-Regular" size:13]
                                ?: [UIFont systemFontOfSize:13];
        NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] init];
        NSDictionary *grayAttrs = @{
            NSFontAttributeName: ([UIFont fontWithName:@"NotoSans-Regular" size:15] ?: [UIFont systemFontOfSize:15]),
            NSForegroundColorAttributeName: [UIColor colorWithWhite:0.45 alpha:1]
        };
        [attr appendAttributedString:[[NSAttributedString alloc] initWithString:@"OTP: " attributes:grayAttrs]];
        NSDictionary *blueAttrs = @{
            NSFontAttributeName: ([UIFont fontWithName:@"NotoSans-Bold" size:22] ?: [UIFont boldSystemFontOfSize:22]),
            NSForegroundColorAttributeName: [UIColor colorWithRed:21/255.0 green:101/255.0 blue:192/255.0 alpha:1]
        };
        [attr appendAttributedString:[[NSAttributedString alloc] initWithString:otpNumber attributes:blueAttrs]];
        self.lbTripOtp.attributedText = attr;
        self.lbTripOtp.numberOfLines = 1;
        self.lbTripOtp.hidden = NO;
        [self.view setNeedsLayout];
    }else{
        self.statusLabel.text = [LanguageHelper getStringWithKey:@"k_r6_s8_driver_arrived" defaultValue:@"Ya estás en camino…"];
        self.statusLabel.font = [UIFont fontWithName:@"NotoSans-Regular" size:15]
                                ?: [UIFont systemFontOfSize:15];
        self.lbTripOtp.attributedText = nil;
        self.lbTripOtp.text = @"";
        self.lbTripOtp.hidden = YES;
        [self.view setNeedsLayout];
    }
}


-(void)removeDriverView{
    self.lblTime.text = [LanguageHelper getStringWithKey:@"k_r5_s8_on_ride"];
    _cancelSepratorView.hidden = YES;
}





-(void) doSimpleNativeCall{
    NSString * numberWithCode=[NSString stringWithFormat:@"%@%@",self.currentTrip.driver.c_code,self.currentTrip.driver.phone];
    NSURL *phoneUrl = [NSURL URLWithString:[@"telprompt://"stringByAppendingString:numberWithCode]];
    NSURL *phoneFallbackUrl = [NSURL URLWithString:[@"tel://" stringByAppendingString:numberWithCode]];
    if ([UIApplication.sharedApplication canOpenURL:phoneUrl]) {
        [[UIApplication sharedApplication] openURL:phoneUrl options:@{} completionHandler:^(BOOL success) {
            
        }];
    } else if ([UIApplication.sharedApplication canOpenURL:phoneFallbackUrl ]) {
        [UIApplication.sharedApplication openURL:phoneFallbackUrl options:@{} completionHandler:^(BOOL success) {
            
        }];
    } else {
        [UtilityClass swa:nil
                        m:[LanguageHelper getStringWithKey:@"k_r33_s8_no_call_facility"]
                      cbt:@"Ok"
                      obt:nil vc:self];
    }
}

- (IBAction)ButtonMakeCall:(id)sender {
    
    
    
    UIAlertController *alertViewcontroller=[UIAlertController alertControllerWithTitle:[LanguageHelper getStringWithKey:@"k_s4_contact"defaultValue:@"Contact"] message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *actionCall=[UIAlertAction actionWithTitle:[LanguageHelper getStringWithKey:@"k_r1_s8_call_driver"defaultValue:@"Call Driver"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
            [self doSimpleNativeCall];
       
    }];
    [actionCall setValue:[UIColor colorNamed:@"app_theame"] forKey:@"titleTextColor"];
    [alertViewcontroller addAction:actionCall];
    
    if([[ConstantModel getConstantsObject] getCValueFK:ckey_ech]==YES){
        UIAlertAction *actionChat= [UIAlertAction actionWithTitle:[LanguageHelper getStringWithKey:@"k_r1_s8_chat_with_driver"defaultValue:@"Chat with Driver"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self openChatViewController];
        }];
        [actionChat setValue:[UIColor colorNamed:@"app_theame"] forKey:@"titleTextColor"];
        [alertViewcontroller addAction:actionChat];
    }
   UIAlertAction *actionCancel= [UIAlertAction actionWithTitle:[LanguageHelper getStringWithKey:@"k_30_s6_cancel_j"defaultValue:@"Cancel"] style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
   }];
    [actionCancel setValue:[UIColor colorNamed:@"app_theame"] forKey:@"titleTextColor"];
    [alertViewcontroller addAction:actionCancel];
    [self.navigationController presentViewController:alertViewcontroller animated:YES completion:^{
        
    }];
    
    
}



-(void) setTripTime:(int) duration
{
    int hours=(int)duration/60;
    int min=(int)duration%60;
    if(hours==0)
    {
        [self.lbTime setText:[NSString stringWithFormat:@"%d\nmin",duration]];
    }
    else
    {
        [self.lbTime setText:[NSString stringWithFormat:@"%dh\n%dmin",hours, min]];
    }
}



#pragma mark - Location Manager  methods

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    if([self isCheckLocationFailedScreen]){
        AppDelegate *appdelegate =APP_DELEGATE;
        ConstantModel * conns=[ConstantModel getConstantsObject];
        
        appdelegate.currLoc =conns.def_location;
        //        [self ButtonGpsPressed:nil];
        if(![self canConsiderDriverIsFree]){
            [self locatonGetFailedScreen:manager isBackHidden:YES];
        }
    }else{
        
    }
}


-(BOOL) canConsiderDriverIsFree{
    NSString *status =defaults_object(DRIVER_STATUS);
    if ( status ==nil ||[status isEqualToString:TS_WAITING] || [status isEqualToString:TS_REQUEST] || [status isEqualToString:TS_END] || [status isEqualToString:TS_DRIVER_CANCEL_AT_PICKUP] || [status isEqualToString:TS_DRIVER_CANCEL_AT_DROP]) {
        return YES;
    }
    return NO;
}

#pragma mark - MKMapViewDelegate methods

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    AppDelegate *appdelegate= APP_DELEGATE;
    appdelegate.currLoc = userLocation.location;
    NSDictionary * dict =[[NSDictionary alloc]initWithObjectsAndKeys:[NSString stringWithFormat:@"%f",appdelegate.currLoc.coordinate.latitude],@"lat",[NSString stringWithFormat:@"%f",appdelegate.currLoc.coordinate.longitude ],@"lng", nil];
    defaults_set_object(@"curr_loc", dict);
}


- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
}

-(MKAnnotationView *)mapView:(MKMapView *)mV viewForAnnotation:(id <MKAnnotation>)annotation
{
    
    
    MKAnnotationView *pinView = nil;
    if(annotation != self.mapView.userLocation) {
        static NSString *defaultPinID = @"com.user.pin";
        pinView = (MKAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:defaultPinID];
        if ( pinView == nil )
            pinView = [[MKAnnotationView alloc]
                       initWithAnnotation:annotation reuseIdentifier:defaultPinID];
        if([annotation isKindOfClass:[CustomPointAnnotation class]])   {
            CustomPointAnnotation  *mAnno=(CustomPointAnnotation *) annotation;
            if([mAnno.type isEqualToString:PIN_START])  {
                static UIImage *startDot = nil;
                if (!startDot) {
                    CGFloat s = 20.0;
                    UIGraphicsImageRenderer *ir = [[UIGraphicsImageRenderer alloc] initWithSize:CGSizeMake(s, s)];
                    startDot = [ir imageWithActions:^(UIGraphicsImageRendererContext *c) {
                        [[UIColor whiteColor] setFill];
                        [[UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, s, s)] fill];
                        [[UIColor colorNamed:@"app_theame"] setFill];
                        [[UIBezierPath bezierPathWithOvalInRect:CGRectMake(3, 3, s-6, s-6)] fill];
                    }];
                }
                pinView.image = startDot;
                pinView.layer.anchorPoint = CGPointMake(0.5f, 0.5f);
            }
            else if ([mAnno.type isEqualToString:@"driver-pin"]){
                self->driverPinView = pinView;
                NSArray * arrCateResponse=defaults_object(@"categoryResponse");
                
                if(arrCateResponse)
                {
                    NSArray *    arrayCagetgory = [CategoryModel parseResponse:arrCateResponse];
                    NSString * imageName=@"car_icon";
                    for (CategoryModel * category in arrayCagetgory) {
                        if(category.categoryId==self.currentTrip.driver.category_id)
                        {
                            imageName=category.cat_map_icon_path;
                            break;
                        }
                    }
                    pinView.image=nil;
                    NSURL *url = [NSURL URLWithString:imageName];
                    SDWebImageManager *manager = [SDWebImageManager sharedManager];
                    [manager loadImageWithURL:url options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
                        
                    } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
                        if (image) {
                            pinView.image=[UIHelper imageForMapWithImage:image];
                        }else{
                            pinView.image=[UIHelper imageForMapWithImage:[UIImage imageNamed:@"icon_car_new"]];
                        }
                    }];
                    
                }else{
                    pinView.image=nil;
                }
            }
            else{
                pinView.image = [UIImage imageNamed:@"map_pin_drop"];
                pinView.layer.anchorPoint = CGPointMake(0.5f, 0.5f);
            }
        }
        if ([annotation isKindOfClass:[CustomPointAnnotation class]]) {
            CustomPointAnnotation *a = (CustomPointAnnotation *)annotation;
            if (![a.type isEqualToString:PIN_START] && ![a.type isEqualToString:PIN_DROP]) {
                pinView.layer.anchorPoint = CGPointMake(0.5f, 1.0f);
                if ([a.type isEqualToString:@"driver-pin"]) {
                    pinView.transform = CGAffineTransformMakeRotation(a.degree + M_PI);
                }
            }
        } else {
            pinView.layer.anchorPoint = CGPointMake(0.5f, 1.0f);
        }
    }
    else {
        [self.mapView.userLocation setTitle:@"I am here"];
        
        //        [self.mapView.userLocation setTitle:@"I am here"];
    }
    return pinView;
}
- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithPolyline:(MKPolyline *)overlay];
    renderer.strokeColor = [UIColor colorNamed:@"app_theame"];
    renderer.lineWidth = 4.0;
    renderer.lineJoin = kCGLineJoinRound;
    renderer.lineCap = kCGLineCapRound;
    return renderer;
}
//- (void)addMapAnnotationsWith:(GoogleDirectionSource * )directionSource {
//
//    [self .mapView removeAnnotations:arrayAnotations];
//    CustomPointAnnotation *pickUp = [[CustomPointAnnotation alloc]initWithType:PIN_START];
//    pickUp.coordinate = directionSource.source.coordinate;
//    [self.mapView addAnnotation:pickUp];
//
//    CustomPointAnnotation *pickDrop = [[CustomPointAnnotation alloc] initWithType:PIN_DROP];
//    pickDrop.coordinate = directionSource.destination.coordinate;
//    [self.mapView addAnnotation:pickDrop];
//
//
//    arrayAnotations=@[pickUp,pickDrop];
//
//    NSArray *arrAnn = [[NSArray alloc]initWithObjects:directionSource.northeast,directionSource.southwest, nil];
//    CLLocationCoordinate2D topLeftCoord;
//    topLeftCoord.latitude =  -90;
//    topLeftCoord.longitude = 180;
//    CLLocationCoordinate2D bottomRightCoord;
//    bottomRightCoord.latitude = 90;
//    bottomRightCoord.longitude = -180;
//
//    for (id <MKAnnotation> annotation in arrAnn) {
//        topLeftCoord.longitude = fmin(topLeftCoord.longitude, annotation.coordinate.longitude);
//        topLeftCoord.latitude = fmax(topLeftCoord.latitude, annotation.coordinate.latitude);
//
//        bottomRightCoord.longitude = fmax(bottomRightCoord.longitude, annotation.coordinate.longitude);
//        bottomRightCoord.latitude = fmin(bottomRightCoord.latitude, annotation.coordinate.latitude);
//    }
//
//    MKCoordinateRegion region;
//    region.center.latitude = topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) * 0.5;
//    region.center.longitude = topLeftCoord.longitude + (bottomRightCoord.longitude - topLeftCoord.longitude) * 0.5;
//    region.span.latitudeDelta = fabs(topLeftCoord.latitude - bottomRightCoord.latitude) * 1.8; // Add a little extra space on the sides //1.1
//    region.span.longitudeDelta = fabs(bottomRightCoord.longitude - topLeftCoord.longitude) * 1.8; // Add a little extra space on the sides //1.1
//    @try {
//        [self mapRegion:region mapView:self.mapView];
//    } @catch (NSException *exception) {
//    } @finally {
//
//    }
//}

- (IBAction)onMenuButtonTap:(id)sender {
    [self.sideMenuController showLeftViewAnimated:YES completionHandler:nil];
}

- (IBAction)onMyLocationButtonTap:(id)sender {
    
    AppDelegate *delegate = APP_DELEGATE;
    isDragged=YES;
    
    [self invalidateTimer];
    
    mapCenterTimer = [NSTimer scheduledTimerWithTimeInterval: 30.0 target: self selector: @selector(startCenterMap) userInfo: nil repeats: NO];
    
    if ([Utilities isValidLocation:delegate.currLoc.coordinate]) {
        
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(delegate.currLoc.coordinate, 600, 600);
        [self mapRegion:region mapView:self.mapView];
        
    }
}


-(void)sendtoFareView{
    if([self.navigationController.topViewController isKindOfClass:[FareAmmountViewController class]]) {
        return;
    }
    UFareSummeryViewController *fareView = (UFareSummeryViewController *)[StoryBoardUtiles viewContollerInUserWithIdentifier:StoryBoardUtiles.UFARE_SUMMERY_VC];
    fareView.curr_trip =self.currentTrip;
    if (self.constantModel==nil) {
        self.constantModel =[ConstantModel getConstantsObject];
    }
    fareView.constantModel =self.constantModel;
    defaults_remove(@"estimate");
    
    NSMutableArray *arrcontrollers = self.navigationController.viewControllers.mutableCopy;
    if(arrcontrollers.count==1){
        [arrcontrollers addObject:fareView];
        [self.navigationController setViewControllers:arrcontrollers animated:YES];
    }
    else if ([[arrcontrollers objectAtIndex:arrcontrollers.count-1] isKindOfClass:[FareAmmountViewController class]]) {
        [arrcontrollers removeLastObject];
        [arrcontrollers addObject:fareView];
        [self.navigationController setViewControllers:arrcontrollers animated:NO];
    }
    else{
        [arrcontrollers addObject:fareView];
        [self.navigationController setViewControllers:arrcontrollers animated:YES];
    }
}

-(void)startCenterMap{
    
    [self invalidateTimer];
    isDragged =NO;
}

-(void)invalidateTimer{
    
    [mapCenterTimer invalidate];
    mapCenterTimer = nil;
}

- (void) CenterMapRegionForShot :(CLLocation *)loc{
    
    if (!isDragged) {
        _mapView.camera.centerCoordinate = loc.coordinate;
        if (!isFirstLoad) {
            isFirstLoad=YES;
            MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(loc.coordinate, 600, 600);
            _mapView.region =region;
        }
        
        [self.mapView setCamera:self.mapView.camera];
    }
}
-(CGFloat) DegreesToRadians:(CGFloat )degrees{
    return degrees * M_PI / 180;
}

-(void)updateDriverAnotation:(CLLocation *)driverLoc{
    
    if(driverAnnotaion==nil)  {
        driverAnnotaion =[[CustomPointAnnotation alloc]  initWithType:@"driver-pin"];
        driverAnnotaion.degree = [self DegreesToRadians:self.currentTrip.driver.d_degree];
        
        driverAnnotaion.coordinate = driverLoc.coordinate;
        [self.mapView addAnnotation:driverAnnotaion];
    }
    CLLocationCoordinate2D  preLocation= driverAnnotaion.coordinate;
    [UIView animateWithDuration:0.2f
                     animations:^{
        self->driverAnnotaion.coordinate =  driverLoc.coordinate;
        if([self->_mapBearingCalculation isAngleChanged:driverLoc.coordinate]){
            float headding= [self->_mapBearingCalculation getBearing:preLocation currentLocation:driverLoc.coordinate];
            if(headding>=-10000) {
                self->driverPinView.transform = CGAffineTransformMakeRotation([self DegreesToRadians:(360-self.mapView.camera.heading)]+headding+M_PI);
            }
        }
    }];
    [self CenterMapRegionForShot:driverLoc];
    
}

- (void)addUserInteractionChangeHandlerOnMap {
    panRec =
    [[UIPanGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(didDragMap:)];
    [panRec setDelegate:self];
    [self.mapView addGestureRecognizer:panRec];
    
    pinchRec =
    [[UIPinchGestureRecognizer alloc] initWithTarget:self
                                              action:@selector(didDragMap:)];
    [pinchRec setDelegate:self];
    [self.mapView addGestureRecognizer:pinchRec];
    [self.mapView setUserInteractionEnabled:YES];
    
    
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}
- (void)didDragMap:(UIGestureRecognizer *)gestureRecognizer {
    isDragged=YES;
    
    if ( gestureRecognizer.state == UIGestureRecognizerStateEnded )
    {
        [self invalidateTimer];
        mapCenterTimer = [NSTimer scheduledTimerWithTimeInterval: 25.0 target: self selector: @selector(startCenterMap) userInfo: nil repeats: NO];
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    CGFloat w   = self.view.bounds.size.width;
    CGFloat h   = self.view.bounds.size.height;
    CGFloat pad = 16;

    // Map fills full view (autoresizingMask handles resizing, but keep frame synced)
    self.mapView.frame = self.view.bounds;

    // Rider top bar: same style as rider home (menu + title)
    if (self.riderTopBar) {
        CGFloat statusH = self.view.safeAreaInsets.top;
        CGFloat topBarH = statusH + 52.0;
        self.riderTopBar.frame = CGRectMake(0, 0, w, topBarH);
        self.riderTopBarMenuBtn.frame = CGRectMake(16, statusH + (52.0 - 44.0) / 2.0, 44, 44);
        CGFloat titleY = statusH + (52.0 - 22.0) / 2.0;
        self.riderTopBarTitleLabel.frame = CGRectMake(74, titleY, w - 148, 22);
        [self.view bringSubviewToFront:self.riderTopBar];
    }
    if (self.btnGps) {
        [self.view bringSubviewToFront:self.btnGps];
    }

    // GPS button: 44x44 above sheet, 16pt from right, 12pt above sheet top
    CGFloat gpsSize = 44;
    self.btnGps.frame = CGRectMake(w - pad - gpsSize,
                                   self.sheetTop - 12 - gpsSize,
                                   gpsSize, gpsSize);
    self.btnGps.layer.cornerRadius = gpsSize / 2;

    // Sheet panel
    self.sheetPanel.frame = CGRectMake(0, self.sheetTop, w, h - self.sheetTop);

    // Drag handle: 36x5, centered, 10pt from sheet top
    self.dragHandle.frame = CGRectMake((w - 36) / 2, 10, 36, 5);

    // --- Header row ---
    CGFloat headerY  = 28;
    CGFloat btnSize  = 48;
    CGFloat shareSz  = 36;
    CGFloat actionX  = w - pad - btnSize;
    CGFloat shareX   = actionX - shareSz - 8;
    CGFloat labelW   = shareX - pad - 8;

    self.actionButton.frame = CGRectMake(actionX, headerY, btnSize, btnSize);
    self.shareButton.frame  = CGRectMake(shareX, headerY + (btnSize - shareSz) / 2, shareSz, shareSz);
    self.statusLabel.frame  = CGRectMake(pad, headerY, labelW, 44);
    // OTP sits below the full button row with a clear gap
    CGFloat otpH  = 30;
    CGFloat otpGap = 8;
    self.lbTripOtp.frame = CGRectMake(pad, headerY + btnSize + otpGap, labelW, otpH);

    // --- Driver card ---
    BOOL otpVisible = !self.lbTripOtp.isHidden;
    CGFloat cardY = headerY + btnSize + (otpVisible ? otpGap + otpH + 10 : 16);
    CGFloat driverCardH = 88;
    CGFloat cardW       = w - pad * 2;
    self.driverCard.frame = CGRectMake(pad, cardY, cardW, driverCardH);

    // Driver card subviews
    CGFloat avatarSz = 52;
    self.imgDriver.frame = CGRectMake(12, (driverCardH - avatarSz) / 2, avatarSz, avatarSz);
    self.imgDriver.layer.cornerRadius = avatarSz / 2;

    CGFloat carImgW = 64, carImgH = 40;
    CGFloat carImgX = cardW - 12 - carImgW;
    self.imageVehicle.frame = CGRectMake(carImgX, (driverCardH - carImgH) / 2 - 4, carImgW, carImgH);
    self.lblCarNumber.frame = CGRectMake(carImgX, self.imageVehicle.frame.origin.y + carImgH + 2, carImgW, 14);

    CGFloat statsX = 12 + avatarSz + 10;
    CGFloat statsW = carImgX - statsX - 6;
    self.starRatingLbl.frame = CGRectMake(statsX, 14, statsW, 16);
    self.lblDriverName.frame = CGRectMake(statsX, CGRectGetMaxY(self.starRatingLbl.frame) + 4, statsW, 20);
    self.lbCarName.frame     = CGRectMake(statsX, CGRectGetMaxY(self.lblDriverName.frame) + 3, statsW, 16);

    // --- Destination card ---
    CGFloat destY = CGRectGetMaxY(self.driverCard.frame) + 12;
    CGFloat destH = 64;
    self.destinationCard.frame = CGRectMake(pad, destY, cardW, destH);

    CGFloat pinSz = 28;
    UIView *pinBtn = [self.destinationCard viewWithTag:901];
    pinBtn.frame = CGRectMake(cardW - 12 - pinSz, (destH - pinSz) / 2, pinSz, pinSz);
    self.destinationLabel.frame = CGRectMake(12, 0, cardW - 12 - pinSz - 8 - 12, destH);

    // --- Payment row ---
    CGFloat payY = CGRectGetMaxY(self.destinationCard.frame) + 12;
    CGFloat payH = 52;
    self.paymentRow.frame = CGRectMake(0, payY, w, payH);

    UIView *payLabel = [self.paymentRow viewWithTag:902];
    payLabel.frame = CGRectMake(pad, 0, 160, payH);
    self.paymentAmountLabel.frame = CGRectMake(w - pad - 160, 0, 160, payH);

    // --- Cancel button ---
    CGFloat cancelY = CGRectGetMaxY(self.paymentRow.frame) + 16;
    self.btnCancelTrip.frame = CGRectMake(pad, cancelY, w - pad * 2, 56);

    // --- Message banner (floats inside sheet, near top, hidden by default) ---
    CGFloat bannerH = 64;
    CGFloat bannerW = w - pad * 2;
    self.viewMessage.frame = CGRectMake(pad, headerY + btnSize + 8, bannerW, bannerH);
    CGFloat msgAvatarSz = 40;
    self.msgAvatarView.frame = CGRectMake(12, (bannerH - msgAvatarSz) / 2, msgAvatarSz, msgAvatarSz);
    self.msgAvatarView.layer.cornerRadius = msgAvatarSz / 2;
    CGFloat msgTextX = 12 + msgAvatarSz + 8;
    CGFloat msgTextW = bannerW - msgTextX - 48;
    self.msgDriverNameLabel.frame = CGRectMake(msgTextX, 12, msgTextW, 18);
    self.msgPreviewLabel.frame    = CGRectMake(msgTextX, CGRectGetMaxY(self.msgDriverNameLabel.frame) + 4, msgTextW, 16);
    CGFloat phoneSz = 36;
    self.btnPhone.frame = CGRectMake(bannerW - 12 - phoneSz, (bannerH - phoneSz) / 2, phoneSz, phoneSz);

    // --- Overlays (full screen) ---
    self.viewCancelReason.frame  = self.view.bounds;
    self.viewDriverLicence.frame = self.view.bounds;

    // Cancel reason subviews
    CGFloat orW = self.view.bounds.size.width;
    self.lblWhy.frame               = CGRectMake(pad, 80, orW - pad * 2, 50);
    self.txtCancelReason.frame      = CGRectMake(pad, 148, orW - pad * 2, 120);
    self.btnCancelReasonOk.frame    = CGRectMake(pad, 286, orW - pad * 2, 52);
    self.btnCancelReasonClose.frame = CGRectMake(pad, 350, orW - pad * 2, 52);

    // Driver licence subviews
    CGFloat licW = self.view.bounds.size.width;
    CGFloat licH = self.view.bounds.size.height;
    self.licenceImageView.frame = CGRectMake(pad, 100, licW - pad * 2, licH - 200);
    self.btnDriverLicance.frame = CGRectMake(licW - 52, 44, 44, 44);
}

- (void)updateHeaderForStatus:(NSString *)status {
    UIColor *yellow = [UIColor colorNamed:@"app_theame"]
                      ?: [UIColor colorWithRed:235/255.0 green:181/255.0 blue:24/255.0 alpha:1];

    [self.actionButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [self.actionButton.gestureRecognizers enumerateObjectsUsingBlock:^(UIGestureRecognizer *gr, NSUInteger idx, BOOL *stop) {
        [self.actionButton removeGestureRecognizer:gr];
    }];

    if ([status isEqualToString:TS_BEGIN]||[status isEqualToString:TS_PICKED]) {
        // Trip started / rider picked up — show drop leg: SOS button, no OTP, no cancel
        self.statusLabel.text = [LanguageHelper getStringWithKey:@"k_r6_s8_driver_arrived" defaultValue:@"Ya estás en camino…"];
        self.statusLabel.font = [UIFont fontWithName:@"NotoSans-Regular" size:15]
                                ?: [UIFont systemFontOfSize:15];
        self.actionButton.backgroundColor = [UIColor colorWithRed:0xFF/255.0 green:0xE1/255.0 blue:0xDE/255.0 alpha:1];
        self.actionButton.layer.cornerRadius = 24;
        UIImage *sosAsset = [UIImage imageNamed:@"ic_sos_button"];
        if (sosAsset) {
            [self.actionButton setImage:sosAsset forState:UIControlStateNormal];
            self.actionButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
            self.actionButton.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
        }
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(btnSosClickedDouble)];
        doubleTap.numberOfTapsRequired = 2;
        [self.actionButton addGestureRecognizer:doubleTap];
        self.btnCancelTrip.hidden = YES;
        self.lbTripOtp.hidden = YES;
    } else {
        // Driver on the way / arrived — showTripOtpOnUi will set the correct statusLabel text
        self.statusLabel.text = [LanguageHelper getStringWithKey:@"k_r8_s8_give_number_to_driver" defaultValue:@"Dale este número a tu conductor"];
        self.statusLabel.font = [UIFont fontWithName:@"NotoSans-Regular" size:13]
                                ?: [UIFont systemFontOfSize:13];
        self.actionButton.backgroundColor = yellow;
        if (@available(iOS 13.0, *)) {
            [self.actionButton setImage:[UIImage systemImageNamed:@"phone.fill"] forState:UIControlStateNormal];
        }
        self.actionButton.tintColor = UIColor.blackColor;
        [self.actionButton addTarget:self action:@selector(ButtonMakeCall:) forControlEvents:UIControlEventTouchUpInside];
        self.btnCancelTrip.hidden = NO;
        // lbTripOtp visibility is controlled by showTripOtpOnUi (otp_start/otp_end flags)
    }
}

- (IBAction)ButtonCancelTrip:(id)sender {
    
    [self CancelTripCalled];
}

-(void)getEstimateDetails{
    if (self.constantModel==nil) {
        self.constantModel =[ConstantModel getConstantsObject];
    }
    CLLocation * pickup=[[CLLocation alloc]   initWithLatitude:self.currentTrip.driver.lat  longitude:self.currentTrip.driver.lng];
    CLLocation * drop=[[CLLocation alloc]   initWithLatitude:[self.currentTrip.trip_pick_lat doubleValue] longitude:[self.currentTrip.trip_pick_long doubleValue]];
    GoogleDirectionSource * userDriverLocationRoute=[[GoogleDirectionSource alloc]  initWithSource:pickup destination:drop];
    if(oldDModel){
        if([self.currentTrip.trip_Status isEqualToString:TS_ACCEPTED]){
            if([pickup distanceFromLocation:pickupDriverOldLatong]<100){
                MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(pickup.coordinate, 600, 600);
                [self mapRegion:region mapView:self.mapView];
                [self addMapAnnotationsWith:userDriverLocationRoute];
                [self updateDriverAnotation:pickup];
                return;
            }
        }
    }
    pickupDriverOldLatong = pickup;

    if ([pickup distanceFromLocation:drop]<80){
        self.lblTime.text = [LanguageHelper getStringWithKey:@"k_r6_s8_driver_arrived"];
        [self.mapView removeAnnotations:self->arrayAnotations];
        [self.mapView removeOverlays:[self.mapView overlays]];
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(pickup.coordinate, 600, 600);
        [self mapRegion:region mapView:self.mapView];
        [self addMapAnnotationsWith:userDriverLocationRoute];
        [self updateDriverAnotation:pickup];
        return;
    }
    
    if(![self.currentTrip.trip_Status isEqualToString:TS_ACCEPTED]){
       
        self.lblTime.text = [LanguageHelper getStringWithKey:@"k_r6_s8_driver_arrived"];
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(pickup.coordinate, 600, 600);
        [self mapRegion:region mapView:self.mapView];
        [self updateDriverAnotation:pickup];
        [self addMapAnnotationsWith:userDriverLocationRoute];
        return;
    }
 
    [userDriverLocationRoute  findDirection_isInTrip:NO WithCompletionBlock:^(id results, NSError *error) {
        if([results isKindOfClass:[DirectionModel class]])   {
            DirectionModel * dModel=(DirectionModel *)results;
            oldDModel = dModel;
            NSString *dis;
            NSString *tripDis;
            float distance1=0.0;
            CityModel * cModel=[CityModel getCityByCityId:self.currentTrip.city_id];
            if (isDistanceUnitKm(cModel.city_dist_unit)/*[[self.constantModel.constant_distance capitalizedString] isEqualToString:@"Km"]*/) {
                dis =cModel.city_dist_unit;
                tripDis =[Utilities formatDistance:dModel.distance];
                distance1 =dModel.distance;
            }
            else{
                dis =cModel.city_dist_unit;
                float miles = dModel.distance*0.621371192;
                tripDis = [Utilities formatDistance:miles];
                distance1 = dModel.distance*0.621371192;
            }
            [self.mapView removeAnnotations:self->arrayAnotations];
            [self.mapView removeOverlays:[self.mapView overlays]];
            if(self->isFirstRouteDraw==NO){
                self->isFirstRouteDraw = YES;
                [self addMapAnnotationsWith:userDriverLocationRoute isMapZoomRest:YES];
            }else{
                [self addMapAnnotationsWith:userDriverLocationRoute isMapZoomRest:NO];
                
            }
            [self->_mapView addOverlay:[ dModel getPolyline] level:MKOverlayLevelAboveRoads];
            int time = (int)dModel.duration;
            CLLocation  *driverLoc=[[CLLocation alloc]  initWithLatitude:self.currentTrip.driver.lat longitude:self.currentTrip.driver.lng];
            [self updateDriverAnotation:driverLoc];
//            if(self.currentTrip.is_driver_busy){
//                self.lblTime.text=[[LanguageHelper getStringWithKey:@"k_r3_s8_drvr_arv_in_bsy"];
//            }else{
                if(![self.currentTrip.trip_Status isEqualToString:TS_ACCEPTED]){
                    if([self.currentTrip.trip_Status isEqualToString:TS_ARRIVE]){
                        self.lblTime.text = [LanguageHelper getStringWithKey:@"k_r6_s8_driver_arrived"];
                    }else{
                        self.lblTime.text = [LanguageHelper getStringWithKey:@"k_r5_s8_on_ride"];
                    }
                }else{
                    if(time<=0){
                        time=1;
                        self.lblTime.text = [LanguageHelper getStringWithKey:@"k_r6_s8_driver_arrived"];
                    }else{
                        self.lblTime.text = [NSString stringWithFormat:@" %@ - %i %@",[LanguageHelper getStringWithKey:@"k_r3_s8_driver_arrive_in"],time,[LanguageHelper getStringWithKey:time<=1?@"k_17_s4_min":@"k_17_s4_mins"]];
                    }
                }
//            }
        }
    }];
}
- (void)addMapAnnotationsWith:(GoogleDirectionSource * )directionSource  {
    [self addMapAnnotationsWith:directionSource isMapZoomRest:NO];
}
- (void)addMapAnnotationsWith:(GoogleDirectionSource * )directionSource  isMapZoomRest:(BOOL) isMapZoomRest {
    
    [self .mapView removeAnnotations:arrayAnotations];
    CustomPointAnnotation *pickUp = [[CustomPointAnnotation alloc]initWithType:PIN_START];
    pickUp.coordinate = directionSource.source.coordinate;
    [self.mapView addAnnotation:pickUp];
    
    CustomPointAnnotation *pickDrop = [[CustomPointAnnotation alloc] initWithType:PIN_DROP];
//    if([_currentTrip.trip_type isEqualToString:P_TRIP_RENTAL]){
//        CLLocation * driverLoc=[[CLLocation alloc] initWithLatitude:self.currentTrip.driver.lat longitude:self.currentTrip.driver.lng];
//        pickDrop.coordinate = driverLoc.coordinate;
//    }else{
        pickDrop.coordinate = directionSource.destination.coordinate;
//    }
    [self.mapView addAnnotation:pickDrop];
    
    
    arrayAnotations=@[pickUp,pickDrop];
    
    NSArray *arrAnn = [[NSArray alloc]initWithObjects:directionSource.northeast,directionSource.southwest, nil];
    CLLocationCoordinate2D topLeftCoord;
    topLeftCoord.latitude =  -90;
    topLeftCoord.longitude = 180;
    CLLocationCoordinate2D bottomRightCoord;
    bottomRightCoord.latitude = 90;
    bottomRightCoord.longitude = -180;
    
    for (id <MKAnnotation> annotation in arrAnn) {
        topLeftCoord.longitude = fmin(topLeftCoord.longitude, annotation.coordinate.longitude);
        topLeftCoord.latitude = fmax(topLeftCoord.latitude, annotation.coordinate.latitude);
        
        bottomRightCoord.longitude = fmax(bottomRightCoord.longitude, annotation.coordinate.longitude);
        bottomRightCoord.latitude = fmin(bottomRightCoord.latitude, annotation.coordinate.latitude);
    }
    
    MKCoordinateRegion region;
    region.center.latitude = topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) * 0.5;
    region.center.longitude = topLeftCoord.longitude + (bottomRightCoord.longitude - topLeftCoord.longitude) * 0.5;
    region.span.latitudeDelta = fabs(topLeftCoord.latitude - bottomRightCoord.latitude) * 1.8; // Add a little extra space on the sides //1.1
    region.span.longitudeDelta = fabs(bottomRightCoord.longitude - topLeftCoord.longitude) * 1.8; // Add a little extra space on the sides //1.1
    @try {
        [self mapRegion:region mapView:self.mapView];
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
    
    
    
}

//-(void)getEstimateDetails{
//    if (self.constantModel==nil) {
//        self.constantModel =[ConstantModel getConstantsObject];
//    }
//
//    //    CLLocation * pickup=[[CLLocation alloc]   initWithLatitude:[self.currentTrip.trip_pick_lat doubleValue] longitude:[self.currentTrip.trip_pick_long doubleValue]];
//    //
//    //    CLLocation * drop=[[CLLocation alloc]  initWithLatitude:[self.currentTrip.trip_drop_lat doubleValue] longitude:[self.currentTrip.trip_drop_long doubleValue]];
//    //
//    CLLocation * pickup=[[CLLocation alloc]   initWithLatitude:self.currentTrip.driver.lat  longitude:self.currentTrip.driver.lng];
//    CLLocation * drop=[[CLLocation alloc]   initWithLatitude:[self.currentTrip.trip_pick_lat doubleValue] longitude:[self.currentTrip.trip_pick_long doubleValue]];
//    GoogleDirectionSource * userDriverLocationRoute=[[GoogleDirectionSource alloc]  initWithSource:pickup destination:drop];
//    [userDriverLocationRoute  findDirection_isInTrip:NO WithCompletionBlock:^(id results, NSError *error) {
//        if([results isKindOfClass:[DirectionModel class]])
//        {
//            DirectionModel * dModel=(DirectionModel *)results;
//
//            NSString *dis;
//            NSString *tripDis;
//            float distance1=0.0;
//            CityModel * cModel=[CityModel getCityByCityId:self.currentTrip.city_id];
//            if (isDistanceUnitKm(cModel.city_dist_unit)/*[[self.constantModel.constant_distance capitalizedString] isEqualToString:@"Km"]*/) {
//                dis =cModel.city_dist_unit;
//                tripDis =[Utilities formatDistance:dModel.distance];
//                distance1 =dModel.distance;
//
//            }
//            else{
//
//                dis =cModel.city_dist_unit;
//                float miles = dModel.distance*0.621371192;
//                tripDis = [Utilities formatDistance:miles];
//                distance1 = dModel.distance*0.621371192;
//            }
//            self.lblDistance.text = [NSString stringWithFormat:@"%@ %@",tripDis,dis];
//            CityModel * cityModel=[CityModel getCityByCityId:self.currentTrip.city_id];
//            CategoryModel *carCategory=[CategoryModel getCategoryByid:[self.currentTrip.category_id intValue]];
//            NSDictionary *dictFare  = [carCategory calculatePriceDict:distance1 time:dModel.duration city_id:self.currentTrip.city_id pormoCode:nil];
//            float estFare=[[dictFare objectForKey:TOTAL_AMT] floatValue];
//            self.lblEstimatedAmount.text =[Utilities formatAmountAndCurrency:estFare currency:cityModel.city_cur] ;
//            int time = (int)dModel.duration;
//            if(time<=0){
//                time=1;
//            }
//            self.lblTime.text = [NSString stringWithFormat:@" %@ - %i%@",[LanguageHelper getStringWithKey:@"k_r3_s8_driver_arrive_in"],time,[LanguageHelper getStringWithKey:time<=1?@"k_17_s4_min":@"k_17_s4_mins"]];
//        }
//    }];
//
//
//}




-(void)endtripCalled{
    
    if (!isEndTripCalled) {
        isEndTripCalled =YES;
        
        [self invalidateTripCheckTimer];
        
        [self sendtoFareView];
    }
    [self stopChatUnreadCount];
}


-(void)beginTripCalled{
    if (!isBeginTripCalled) {
        NSString *message=[LanguageHelper getStringWithKey:@"k_4_s14_trip_started"];
        statusPre =TS_BEGIN;
        _btnCancelTrip.hidden=YES;
        _btncanceltripHeightconstraints.constant =0;
        if ([self isShowAlert]) {
            isBeginTripCalled =YES;
           UIAlertController * alertForHide =  [self showAlertWithOk:[LanguageHelper getStringWithKey:@"k_com_s_18_trip_status"] message:message handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            autoHideBeginAlert =[[AutoHideAlert alloc] init];
            autoHideBeginAlert.delegate=self;
            [autoHideBeginAlert handle:alertForHide];
            
        }
        [self removeDriverView];
        //        [self.mapView removeOverlays:self.mapView.overlays];
        //
        //        CLLocation * userLoc=[[CLLocation alloc]   initWithLatitude:[self.currentTrip.trip_pick_lat doubleValue] longitude:[self.currentTrip.trip_pick_long doubleValue]];
        //
        //        CLLocation * driverLoc=[[CLLocation alloc]  initWithLatitude:[self.currentTrip.trip_drop_lat doubleValue] longitude:[self.currentTrip.trip_drop_long doubleValue]];
        //        GoogleDirectionSource * userDriverLocationRoute=[[GoogleDirectionSource alloc]  initWithSource:userLoc destination:driverLoc];
        //        [userDriverLocationRoute  findDirection_isInTrip:NO WithCompletionBlock:^(id results, NSError *error) {
        //            if([results isKindOfClass:[DirectionModel class]])
        //            {
        //                DirectionModel * dModel=(DirectionModel *)results;
        //                if (dModel.arrDirectionLatLng.count>0) {
        //                    [self.lbDestination  setText:isEmpty(self.currentTrip.trip_drop_loc)];
        //                    [self addMapAnnotationsWith:userDriverLocationRoute];
        //
        //                    [self.lbTime setText:[NSString stringWithFormat:@"%d\nmin",(int)dModel.duration]];
        //                    [self.mapView addOverlay:[ dModel getPolyline] level:MKOverlayLevelAboveRoads];
        //
        //                }
        //            }
        //        }];
    }
    [self getBeginRouteFormtripDataWithOutLoader];
}

-(void)onAutoHide:(AutoHideAlert *)autoHideAlertHelper{
    if (autoHideAlertHelper==autoHideCancelAlert){
        if([autoHideAlertHelper.tripStatus isEqualToString:TS_DRIVER_CANCEL_AT_DROP])  {
//            if ( !self->isNot=ificationCame) {
                self->isNotificationCame =YES;
                [self sendtoFareView];
//            }
        }
        else{
            [self navigateTOHomeScreen];
            //                                                             [self.navigationController popToRootViewControllerAnimated:YES];
            
        }
    }
}

-(void)arriveTripCalled{
    [self avisarConductorEnSitio];

    if (!isArriveTripCalled) {
        
        NSString *message= [LanguageHelper getStringWithKey:@"k_3_s14_arrive_soon"];
        statusPre =TS_ARRIVE;
//        self.lblTime.text =[LanguageHelper getStringWithKey:@"k_r6_s8_driver_arrived"];
//        _lblTime.hidden = YES;/
        if ([self isShowAlert]) {
            isArriveTripCalled =YES;
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[LanguageHelper getStringWithKey:@"k_com_s_18_trip_status"]
                                                             
                                                                                     message:message
                                                                              preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *actionOk = [UIAlertAction actionWithTitle:[LanguageHelper getStringWithKey:@"k_18_s4_Ok"]
                                                               style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * _Nonnull action) {
            }];
            [alertController addAction:actionOk];
            [self presentViewController:alertController animated:YES completion:nil];
            
            autoHideArriveAlert =[[AutoHideAlert alloc] init];
            autoHideArriveAlert.delegate=self;
            [autoHideArriveAlert handle:alertController];
        }
    }
    
}


//-(void)CancelTripCalled{
//    [self cancelTripBeforeBeginTrip:self.currentTrip completionBlock:^(id  _Nonnull results, NSError * _Nonnull error) {
//        if ([[results objectForKey:P_STATUS] isEqualToString:@"OK"]) {
//            [self navigateTOHomeScreen];
//        }
//    } isShowLoader:YES isSendNotification:YES withDelegate:self isFromBeginTrip:YES];
//}
-(BOOL) isJobCancelBeforeTimer{
    CategoryModel *category = [CategoryModel getCategoryByid:[self.currentTrip.category_id  intValue]];
    int totalSeconds=category.r_can_free_min;
    NSDate *animateStartTime;
    if(self.currentTrip.tm_acc.length>0){
        NSString *startStr =  [Utilities GetGMTDatetoLocalTZ:self.currentTrip.tm_acc :@"yyyy-MM-dd HH:mm:ss"];
        animateStartTime =  [self convertStringToDate:startStr fromFormat:@"yyyy-MM-dd HH:mm:ss"];
        if(animateStartTime==nil){
            animateStartTime=[NSDate date];
        }
    }else{
        animateStartTime=[NSDate date];
    }
    int diff=[[NSDate date] timeIntervalSince1970]-[animateStartTime timeIntervalSince1970];
    if(diff<totalSeconds){
        return YES;
    }
    return NO;
}

-(NSDate *)convertStringToDate:(NSString *)strDate fromFormat:(NSString *)strFromFormat
{
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = strFromFormat;
    return [dateFormatter dateFromString:strDate];
}

-(void)CancelTripCalled{
    if([self isJobCancelBeforeTimer]){
        // cancel trip after accept driver or assign  with before rider free time in category
        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle: [LanguageHelper getStringWithKey:@"k_33_s7_alert"]
                                     message:[LanguageHelper getStringWithKey:@"k_r16_s8_cancel_trip_now"]
                                     preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* yesButton = [UIAlertAction
                                    actionWithTitle:[LanguageHelper getStringWithKey:@"k_21_s4_yes"]
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action) {
            
            self.viewCancelReason.hidden=NO;
            [self.txtCancelReason becomeFirstResponder];
        }];
        
        UIAlertAction* noButton = [UIAlertAction
                                   actionWithTitle:[LanguageHelper getStringWithKey:@"k_22_s4_no"]
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action) {
        }];
        [alert addAction:yesButton];
        [alert addAction:noButton];
        [self presentViewController:alert animated:YES completion:nil];

        
    }else{
        // cancel trip after accept driver or assign with after rider free time in category then cancelation fee my be apply
//        [self cancelTripBeforeBeginTrip:self.currentTrip completionBlock:^(id  _Nonnull results, NSError * _Nonnull error) {
//
//               if ([[results objectForKey:P_STATUS] isEqualToString:@"OK"]) {
//                   [self stopOldLocationUpdate];
//                   HomeViewController * vcHome=(HomeViewController *)[StoryBoardUtiles viewContollerInMainWithIdentifier:StoryBoardUtiles.HOME_VC];
//                   [self.navigationController setViewControllers:@[vcHome] animated:YES];
//               }
//
//           } isShowLoader:YES isSendNotification:YES withDelegate:self isFromBeginTrip:YES];
        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle: [LanguageHelper getStringWithKey:@"k_33_s7_alert"]
                                     message:[LanguageHelper getStringWithKey:@"ride_later_cancel_confirmation_text"]
                                     preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* yesButton = [UIAlertAction
                                    actionWithTitle:[LanguageHelper getStringWithKey:@"k_21_s4_yes"]
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action) {
//            [self onCancelMayApplyChargeWithServiewByRiderWithTripModel:self.currentTrip completionBlock:^(id results, NSError *error) {
//
//            } isShowLoader:YES isSendNotification:YES];
            self.viewCancelReason.hidden=NO;
            [self.txtCancelReason becomeFirstResponder];
        }];
        
        UIAlertAction* noButton = [UIAlertAction
                                   actionWithTitle:[LanguageHelper getStringWithKey:@"k_22_s4_no"]
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action) {
        }];
        [alert addAction:yesButton];
        [alert addAction:noButton];
        [self presentViewController:alert animated:YES completion:nil];
    }
}
    - (void)onCancelMayApplyChargeWithServiewByRiderWithTripModel:(TripModel *) tripModel completionBlock:(void (^)(id results, NSError *error))block isShowLoader:(BOOL)isShowLoader isSendNotification:(BOOL)isSendNotification
    {
        [self onCancelMayApplyChargeWithServiewByRiderWithTripModel:tripModel completionBlock:block isShowLoader:isShowLoader isSendNotification:isSendNotification reason:@""];
    }
    - (void)onCancelMayApplyChargeWithServiewByRiderWithTripModel:(TripModel *) tripModel completionBlock:(void (^)(id results, NSError *error))block isShowLoader:(BOOL)isShowLoader isSendNotification:(BOOL)isSendNotification reason:(NSString*)reason{
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]  init];
    [dict setObject: [NSString stringWithFormat:@"%@",tripModel.trip_Id] forKey:TRIP_ID];
    [dict setObject:TS_USER_CANCEL forKey:TRIP_STATUS];
    [dict setObject:@"1" forKey:@"is_cancelled"];
    [dict setObject:@"1" forKey:@"is_return_details"];
    [dict setObject:@"r" forKey:@"can_fee_by"];
        if(reason.length>0){
            [dict setObject:reason forKey:TRIP_REASON];
        }
    [tripModel updateTripModelWith:dict completionBlock:^(id results, NSError *error) {
        if ([[results objectForKey:P_STATUS] isEqualToString:@"OK"]) {
            [self stopOldLocationUpdate];
            if([tripModel.trip_Status isEqualToString:TS_RIDER_CANCEL]){
                [self sendtoFareView];
            }else{
//                UHomeViewController * vcHome=(UHomeViewController *)[StoryBoardUtiles viewContollerInUserWithIdentifier:StoryBoardUtiles.UHOME_VC];
//                [self.navigationController setViewControllers:@[vcHome] animated:YES];
//                NSMutableArray *arrayVcs=[self.navigationController.viewControllers mutableCopy];
//                [arrayVcs insertObject:vcHome atIndex:0];
//                [self.navigationController setViewControllers:arrayVcs animated:NO];
//                [self.navigationController popToRootViewControllerAnimated:YES];
                [self navigateTOHomeScreen];
            }
            if([[results objectForKey:P_RESPONSE] isKindOfClass:[NSDictionary class]])  {
                if(isSendNotification){
                    [self sendCancelTripNotification:tripModel];
                }
            }
            else{
                if([[results objectForKey:P_RESPONSE] intValue]==1) {
                    if(isSendNotification){
                        [self sendCancelTripNotification:tripModel];
                    }
                }
            }
        }
    } isShowLoader:YES isSendNotification:NO];
}

-(void)navigateTOHomeScreen{
    defaults_remove(TRIP_ID);
    defaults_remove(TRIP_STATUS);
    [self stopOldLocationUpdate];
    [self loadUserHomeViewController];
}

-(void)sendCancelTripNotification:(TripModel *) tripModel{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{
        
        @"message"       :[[LanguageHelper sharedInstance] getStringWithKey:@"k_53_s4_rider_has_cancelled_trip" currentLanguage:tripModel.driver.d_lang],
        TRIP_STATUS      :TS_USER_CANCEL,
        TRIP_ID          :[NSString stringWithFormat:@"%@",tripModel.trip_Id],
        @"content-available":@"1",
        
    }];
    [dict setObject:@"driver_cancel.caf" forKey:@"sound"];
    [dict addEntriesFromDictionary:[tripModel.driver deviceTypeAndToken]];
    if (isTokenEmpty(dict)) {
        return;
    }
    if(tripModel.is_share){
        [dict setObject:@"1" forKey:@"is_share"];
    }
    [dict setObject:@"driver" forKey:@"to"];
    [GIC mk:url_notification to:send_driver_notification   d:dict  isa:NO cb:^(id results, NSError *error) {
        if ([[results objectForKey:P_STATUS] isEqualToString:@"OK"]) {
        }
    }];
}




-(void)goToFareSummeryScreenWhenTripCancelByRider:(TripModel *)tripModel{
    [self sendtoFareView];
}

/**
 Aviso del sistema cuando entra un mensaje nuevo del conductor.

 Portado de avisarMensajeNuevo de Android (riderapp/FragmentRouteNavigation.java). Aqui ya
 existia el contador de no leidos y el distintivo rojo sobre el boton del telefono, pero
 nada sonaba ni salia del app: con la pantalla apagada el mensaje del conductor no llegaba
 a ninguna parte.

 Tres frenos, los mismos que Android:
   - solo cuando el numero de no leidos SUBE, no en cada refresco del observador;
   - nunca en la primera lectura, que trae los que ya estaban sin leer de antes;
   - nunca si el pasajero ya tiene el chat delante.
 */
-(void)avisarMensajeNuevoSiToca:(int)conteo texto:(NSString *)texto {
    if (primeraLecturaChat == NO) {
        primeraLecturaChat = YES;
        ultimoConteoNoLeidos = conteo;
        return;
    }
    if (conteo <= ultimoConteoNoLeidos) {
        ultimoConteoNoLeidos = conteo;
        return;
    }
    ultimoConteoNoLeidos = conteo;

    // Si ya esta leyendo el chat no tiene sentido avisarle.
    if ([self.presentedViewController isKindOfClass:[UChatViewController class]]
        || [self.navigationController.topViewController isKindOfClass:[UChatViewController class]]) {
        return;
    }

    NSString *nombre = self.currentTrip.driver.d_fname;
    if (nombre.length == 0) {
        nombre = [LanguageHelper getStringWithKey:@"k_s10_tu_conductor" defaultValue:@"Tu conductor"];
    }

    // Sin clave unica: cada mensaje nuevo es un aviso nuevo, a diferencia de la llegada.
    [ConrraAvisoLocal mostrarConClaveUnica:nil
                                    titulo:nombre
                                     texto:isEmpty(texto)
                                    sonido:nil];
    [ConrraAvisoLocal vibrar];
}


/**
 Aviso del sistema cuando el conductor llega al punto de recogida.

 Portado de avisarConductorEnSitio de Android (riderapp/FragmentRouteNavigation.java).

 POR QUE NO BASTABA CON LO QUE HABIA. arriveTripCalled solo enseñaba una alerta dentro de
 la app, y ademas solo si isShowAlert devuelve YES -- que exige que el viaje se haya
 modificado hace menos de 20 segundos. Con el telefono bloqueado, o con la app detras, el
 pasajero no se enteraba de nada. El push tampoco ayudaba: salia por notif.conrra.com, que
 devuelve 500 en todas las llamadas.

 Se manda UNA sola vez por viaje, con la misma clave que usa Android
 ("aviso_llegada_<trip_id>"): el estado del viaje se sondea cada pocos segundos y sin la
 marca volveria a avisar en cada vuelta.
 */
-(void)avisarConductorEnSitio {
    if (self.currentTrip == nil || self.currentTrip.trip_Id.length == 0) {
        return;
    }

    NSString *nombre = self.currentTrip.driver.d_fname;
    if (nombre.length == 0) {
        nombre = [LanguageHelper getStringWithKey:@"k_s10_tu_conductor" defaultValue:@"Tu conductor"];
    }

    // El otp puede venir con el prefijo "OTP:" pegado delante; Android lo recorta igual.
    NSString *otp = self.currentTrip.otp ?: @"";
    if ([[otp uppercaseString] hasPrefix:@"OTP:"]) {
        otp = [[otp substringFromIndex:4] stringByTrimmingCharactersInSet:
               [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }
    otp = [otp stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    NSString *texto;
    if (otp.length == 0 || [otp caseInsensitiveCompare:@"null"] == NSOrderedSame) {
        texto = [NSString stringWithFormat:
                 [LanguageHelper getStringWithKey:@"k_s10_conductor_en_sitio"
                                     defaultValue:@"%@ ya está en el punto de recogida."], nombre];
    } else {
        texto = [NSString stringWithFormat:
                 [LanguageHelper getStringWithKey:@"k_s10_conductor_en_sitio_otp"
                                     defaultValue:@"%@ ya está en el punto de recogida. Dale este código: %@"],
                 nombre, otp];
    }

    [ConrraAvisoLocal mostrarConClaveUnica:[NSString stringWithFormat:@"aviso_llegada_%@", self.currentTrip.trip_Id]
                                    titulo:[LanguageHelper getStringWithKey:@"k_s10_conductor_llego"
                                                               defaultValue:@"Tu conductor llegó"]
                                     texto:texto
                                    sonido:@"cab_arrive.caf"];
    [ConrraAvisoLocal vibrar];
}


-(BOOL)isShowAlert{
    BOOL isShow= NO;
    NSDate *date1 = [Utilities GetGMTDatetoLocalTZ1:self.currentTrip.trip_modified_time];
    NSDate *date2 = [Utilities GetGMTDatetoLocalTZ1:[Utilities getStringFromDate:[NSDate date]]];
    
    NSTimeInterval secondsBetween = [date2 timeIntervalSinceDate:date1];
    
    if (secondsBetween<20.0) {
        isShow=YES;
    }
    return isShow;
}

- (void)btnSosClickedDouble {
    if(sosApiCalled){
        return;
    }
    sosApiCalled=YES;
    NSDictionary *dictUser=defaults_object(P_USER_DICT_LOGGED);
    AppDelegate *delegate=APP_DELEGATE;
    NSMutableDictionary *dictApi=[[NSMutableDictionary alloc] init];
    NSString * contactNumber1=    [dictUser objectForKey:@"emergency_contact_1"];
    NSString * contactNumber2=    [dictUser  objectForKey:@"emergency_contact_2"];
    
    NSString * contactNumber3=    [dictUser  objectForKey:@"emergency_contact_3"];
    NSString * contactNumber4=    [dictUser  objectForKey:@"emergency_contact_4"];
    NSString * contactNumber5=    [dictUser  objectForKey:@"emergency_contact_5"];
    NSMutableArray *arrayContact=[[NSMutableArray alloc] init];
    if(contactNumber1.length>0){
        NSArray * array=[contactNumber1 componentsSeparatedByString:@"|"];
        if(array.count>1){
            
            if(array.count>2){
                NSString *code=[NSString stringWithFormat:@"%@%@",[array objectAtIndex:2],[array objectAtIndex:0]];
                [arrayContact addObject:code];
            }else{
                NSString *phone = [array objectAtIndex:0];
                if(phone.length>0){
                    [arrayContact addObject:phone];
                }
            }
        }
    }
    
    if(contactNumber2.length>0){
        NSArray * array=[contactNumber2 componentsSeparatedByString:@"|"];
        if(array.count>1){
            if(array.count>2){
                NSString *code=[NSString stringWithFormat:@"%@%@",[array objectAtIndex:2],[array objectAtIndex:0]];
                [arrayContact addObject:code];
            }else{
                NSString *phone = [array objectAtIndex:0];
                if(phone.length>0){
                    [arrayContact addObject:phone];
                }
            }
        }
    }
    
    if(contactNumber3.length>0){
        NSArray * array=[contactNumber3 componentsSeparatedByString:@"|"];
        if(array.count>1){
            if(array.count>2){
                NSString *code=[NSString stringWithFormat:@"%@%@",[array objectAtIndex:2],[array objectAtIndex:0]];
                [arrayContact addObject:code];
            }else{
                NSString *phone = [array objectAtIndex:0];
                if(phone.length>0){
                    [arrayContact addObject:phone];
                }
            }
        }
    }
    if(contactNumber4.length>0){
        NSArray * array=[contactNumber4 componentsSeparatedByString:@"|"];
        if(array.count>1){
            if(array.count>2){
                NSString *code=[NSString stringWithFormat:@"%@%@",[array objectAtIndex:2],[array objectAtIndex:0]];
                [arrayContact addObject:code];
            }else{
                NSString *phone = [array objectAtIndex:0];
                if(phone.length>0){
                    [arrayContact addObject:phone];
                }
            }
        }
    }
    if(contactNumber5.length>0){
        NSArray * array=[contactNumber5 componentsSeparatedByString:@"|"];
        if(array.count>1){
            if(array.count>2){
                NSString *code=[NSString stringWithFormat:@"%@%@",[array objectAtIndex:2],[array objectAtIndex:0]];
                [arrayContact addObject:code];
            }else{
                NSString *phone = [array objectAtIndex:0];
                if(phone.length>0){
                    [arrayContact addObject:phone];
                }
            }
        }
    }
    
    [dictApi setObject:[dictUser objectForKey:P_USER_ID] forKey:P_USER_ID];
    [dictApi setObject:[NSString stringWithFormat:@"%f",delegate.currLoc.coordinate.latitude]  forKey:P_USER_LAT];
    [dictApi setObject:[NSString stringWithFormat:@"%f",delegate.currLoc.coordinate.longitude] forKey:P_USER_LNG];
    [dictApi setObject:[arrayContact componentsJoinedByString:@"|"] forKey:@"num"];
    [dictApi setObject:isEmpty([dictUser objectForKey:@"u_name"]) forKey:@"u_name"];
    [dictApi setObject:isEmpty([dictUser objectForKey:@"u_phone"]) forKey:@"u_phone"];
    [dictApi setObject:isEmpty([dictUser objectForKey:@"c_code"]) forKey:@"c_code"];
    [self showPleaseWaitLoader];
    [GIC mkwerwu:API_SEND_SOS  d:dictApi cb:^(id results, NSError *error) {
        self-> sosApiCalled=NO;
        [self hidePleaseWaitLoader];
        if(isStatusOk(results)) {
            [self showAlert:@"" message:[LanguageHelper getStringWithKey:@"k_4_s14_sos_sus_alert"]];
        }else if(isStatusError(results)){
            [self showAlert:@"" message:[LanguageHelper getStringWithKey:errorMessage(results)]];
        }else{
            [Utilities handleError:error viewController:self defaultMessage:@""];
        }
    }];
}



-(IBAction)multipleTap:(id)sender withEvent:(UIEvent*)event {
    UITouch* touch = [[event allTouches] anyObject];
    if (touch.tapCount == 2) {
        [self btnSosClickedDouble];
    }
}




- (IBAction)btnShareTripClicked:(id)sender {
    NSString *textToShare = [NSString stringWithFormat:@"%@?trip=%@",SHARE_TRIP_URL,self.currentTrip.trip_Id];
    NSArray *objectsToShare = @[textToShare];
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
    
    NSArray *excludeActivities = @[UIActivityTypeAirDrop,
                                   UIActivityTypePrint,
                                   UIActivityTypeAssignToContact,
                                   UIActivityTypeSaveToCameraRoll,
                                   UIActivityTypeAddToReadingList,
                                   UIActivityTypePostToFlickr,
                                   UIActivityTypePostToVimeo];
    
    activityVC.excludedActivityTypes = excludeActivities;
    
    [self presentViewController:activityVC animated:YES completion:nil];
}



-(void) openChatViewController{
    UChatViewController *vc = (UChatViewController*)[StoryBoardUtiles viewContollerInUserWithIdentifier:StoryBoardUtiles.UCHAT_VC];
    vc.tripID=[NSString stringWithFormat:@"%@",self.currentTrip.trip_Id];
    [self.navigationController pushViewController:vc animated:YES];
}


- (IBAction)onChatButtonTap:(id)sender {
    [self openChatViewController];
}



- (IBAction)onViewDriverLicence:(id)sender {
    [self.viewDriverLicence setHidden:NO];
    NSString * license_image_path=[NSString stringWithFormat:@"%@%@",url_base_images,driverLicensePath];
    [self.imDirverLincence sd_setImageWithURL:[NSURL URLWithString:license_image_path] placeholderImage:nil];
}


- (IBAction)onLincenceCloseButtonTap:(id)sender {
    [self.viewDriverLicence setHidden:YES];
}



-(void) setUpChatUnreadCount{
    if([[ConstantModel getConstantsObject] getCValueFK:ckey_ech]==YES){
        if(_firebaseUnReadChat) {
            [_firebaseUnReadChat stopObserverForCount];
            _firebaseUnReadChat=nil;
        }
        if(self.currentTrip==nil) {
            return;
        }
        _firebaseUnReadChat=[[FirebaseUnReadChat alloc] initWithChannId:[NSString stringWithFormat:@"%@",self.currentTrip.trip_Id]];
        [_firebaseUnReadChat startObserverForCount];
    }
}

-(void) updateUnReadCount{
    if([[ConstantModel getConstantsObject] getCValueFK:ckey_ech]==YES){
        if([_firebaseUnReadChat messageCount]>0) {
            [self.viewMessage setHidden:NO];
            self.lblMsgDriverName.text=[NSString stringWithFormat:@"%@ %@",self.currentTrip.driver.d_fname,self.currentTrip.driver.d_lname];
            self.lblMessage.text=[_firebaseUnReadChat lastMessagText];
            NSString *profile= self.currentTrip.driver.d_profile_image_path;
            if (profile.length>0) {
                [self.imMsgDriverProfile sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",url_base_images, profile]] placeholderImage:[UIImage imageNamed:@"Profile Icon Crop Image"]];
            }else  {
                [self.imMsgDriverProfile  setImage:[UIImage imageNamed:@"Profile Icon Crop Image"]];
            }
            [self.btnPhone setBadgeString:[NSString stringWithFormat:@"%d",[_firebaseUnReadChat messageCount]]];
            [self.btnPhone setBadgeBackgroundColor:[UIColor redColor]];
            [self avisarMensajeNuevoSiToca:[_firebaseUnReadChat messageCount]
                                     texto:[_firebaseUnReadChat lastMessagText]];
            if(timerBlink) {
                [timerBlink invalidate];
                timerBlink=nil;
            }
            timerBlink = [NSTimer
                          scheduledTimerWithTimeInterval:(NSTimeInterval)(1.0)
                          target:self
                          selector:@selector(blink)
                          userInfo:nil
                          repeats:TRUE];
            blinkStatus = NO;
        }else{
            if(timerBlink) {
                [timerBlink invalidate];
                timerBlink=nil;
            }
            [self.viewMessage setHidden:YES];
            [self.btnPhone setBadgeString:@""];
            [self.btnPhone hideWhenZero];
            [self.btnPhone setBadgeBackgroundColor:[UIColor clearColor]];
        }
    }
}

-(void) stopChatUnreadCount{
    if ([[ConstantModel getConstantsObject] getCValueFK:ckey_ech]==YES){
        if(_firebaseUnReadChat){
            [_firebaseUnReadChat stopObserverForCount];
            _firebaseUnReadChat=nil;
        }
    }
}

- (IBAction)onChatReplyButtonTap:(id)sender {
    [self openChatViewController];
}


-(void)blink{
    if(blinkStatus == NO){
        _viewMessage.backgroundColor = UIColor.whiteColor;

        blinkStatus = YES;
    }else {
        _viewMessage.backgroundColor =  RGB(255, 192, 0 );
        blinkStatus = NO;
    }
}


- (IBAction)onVehicleImageButTap:(id)sender {
    self.viewDriverLicence.hidden=NO;
    self.imDirverLincence.image=nil;
    [self.imDirverLincence sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",url_base_images, self.currentTrip.driver.d_car_image_path]]];
}


-(void) getAssets{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    [dict setObject:[NSString stringWithFormat:@"%@",self.currentTrip.driver.driverId] forKey:P_DRIVER_ID];
    [GIC mkwu:GET_DRIVER_ASSET  d:dict   isa:NO  cb:^(id results, NSError *error) {
        if ([[results objectForKey:P_RESPONSE] isKindOfClass:[NSArray class]])  {
            NSArray *arrayAssets=[results objectForKey:P_RESPONSE];
            for (NSDictionary *  uploadDocs in arrayAssets) {
                if([[uploadDocs objectForKey:@"asset_type"]isEqualToString:@"LICENSE"]) {
                    self->driverLicensePath=[uploadDocs objectForKey:@"img_path"];
                    self.btnDriverLicance.hidden=NO;
                    break;
                }
            }
        }
    }];
}


-(void)stopLocationUpdate{
    [self.mapView removeFromSuperview];
    self.mapView=nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self cancellAllTimerWhenGoToHome];
    if(self.locationManager){
        [self.locationManager stopUpdatingLocation];
        [self.locationManager stopUpdatingHeading];
        self.locationManager=nil;
    }
    [self purgeMapMemory];
}
- (void)purgeMapMemory
{
    // Switching map types causes cache purging, so switch to a different map type
    self.mapView.mapType = MKMapTypeStandard;
    [self.mapView removeFromSuperview];
    self.mapView = nil;
}

- (IBAction)onCancelReasonOk:(id)sender {
    [self.view endEditing:YES];
    NSString *message = [self.txtCancelReason.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];;
    NSString *trimmedString = [message stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    NSString *reasonString = [trimmedString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    if (reasonString.length==0) {
        [self showWarningWithMessgae:[LanguageHelper getStringWithKey:@"k_26_s3_write_reason"]];
    }
    else{
        self.viewCancelReason.hidden=YES;
        [self onCancelMayApplyChargeWithServiewByRiderWithTripModel:self.currentTrip completionBlock:^(id results, NSError *error) {
            
        } isShowLoader:YES isSendNotification:YES reason:reasonString];
    }
}

- (IBAction)onCancelReasonClose:(id)sender {
    self.txtCancelReason.text = @"";
    self.viewCancelReason.hidden=YES;
    [self.view endEditing:YES];
}


@end
