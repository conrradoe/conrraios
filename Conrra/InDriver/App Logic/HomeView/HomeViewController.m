//
//  HomeViewController.m
//  Store_project
//
//  Created by  Appicial on 22/05/17.
//  Copyright © 2023 Appicial. All rights reserved.
//

#import <GIKit/GIKit.h>
#import "HomeViewController.h"
#import "LGSideMenuController.h"
#import "UIViewController+LGSideMenuController.h"
#import "MainViewController.h"
#import "WebCallConstants.h"
#import "AppDelegate.h" 
#import "TripModel.h"
#import "AFHTTPRequestOperationManager.h"
#import "FareAmmountViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>
#import "UpdateUserCurrentLocation.h"
#import "GoogleDirectionSource.h"
#import "PickupDetailViewController.h"
#import "DirectionModel.h"
#import "ConstantModel.h"
#import "CategoryModel.h"
#import <CoreMotion/CoreMotion.h>
#import "CustomPointAnnotation.h"
#import "Utilities.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#include <math.h>
#import "LeftViewController.h"
#import <MessageUI/MFMailComposeViewController.h>
//Firebase
#import "TripModel+Helper.h"
#import "ChatViewController.h"
#import <Firebase.h>
#import "FireBaseModel.h"
#import "PendingTripCell.h"
#import "RequestCardCell.h"
#import "UIView+UpdateAutoLayoutConstraints.h"
#import "SuggestedLocationDataSource.h"
#import "RouteDestinationLess.h"
#import "FireAnonymousSigupHelper.h"
#import "PromoCodeModel.h"
#import "MapBearingCalculation.h"
#import "UIViewController+Location.h"
#import <objc/runtime.h>
#import "UIHelper.h"
#import "VerificationAlertView.h"
#import "DataBase.h"
#import "DataUploadHelper.h"
#import "FirebaseUnReadChat.h"
#import "ConrraRadioDeReparto.h"
#import "ConrraVoyEnCamino.h"
#import "ConrraSolicitudesPersistentes.h"
#import "HomeDataModel.h"
#import "LocationDataHelper.h"
#import "SingleRequestView.h"
#import "SentOfferDetailsViewController.h"
#import "EditProfileViewController.h"
#import "UIImage+GIF.h"
#import "AskTripOtpVC.h"
#import "UserProfile.h"
#import "UpcommingTripCell.h"
#import "OfferCardCell.h"
#import <Conrra-Swift.h>
@interface HomeViewController ()<FIRMessagingDelegate,TripRequestDelegate,MFMailComposeViewControllerDelegate,SingleRequestViewDelegate,DTripOffersViewContollerDelegate,SentOfferDetailsViewControllerDelegate,OfferCardCellDelegate,UITextFieldDelegate,AutoHideAlertDelegate,AskTripOtpVCDelegate,UpcommingTripCellDelegate,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property (strong, nonatomic) FIRDatabaseReference *ref_TripChat;

@end

@implementation HomeViewController
{
    BOOL sosApiCalled;
    PromoCodeModel *  promoCode;
    BOOL isRiderCancelCalled;
    BOOL isDropSelected, localSingleMode;
    NSString *singlePickUplocationAddress;
    GoogleDirectionSource *direction;
    CLLocationCoordinate2D centerCoordinate;
    DirectionModel  *dModelOldRoute;
    UIPanGestureRecognizer *panRec;
    UIPinchGestureRecognizer *pinchRec;
    BOOL isMapDraged,  isToRemoveFirebaseHandles, isChatVCCalled;;
    double angle;
    AVAudioPlayer *audioPlayer;
    MKPointAnnotation *driverPin;
    MKPointAnnotation *driverPinStart;
    NSTimer* timerGetTripDetail,*mapCenterTimer;
    NSString *driverStatus;
    NSTimer* timerWatingTime;
    NSString *reasonString;
    NSString *reasonStringType;
    WaitingTimerView* _waitingTimerView;
    
    NSString *distance;
    BOOL isFirstLoad;
    CLLocation *lastLoc;
    NSArray * arrayAnotations;
    int apiCallAttempt, apiCounter;//, count;
    NSMutableArray *arrayCagetgory;
    BOOL StartLocationTaken;
    CLLocation *StartLocation,*OldLocation, *currentLocationAfterVaildate;;
    float TotalM,TotalTripDIstance;
    NSString *_activtiyNameDetactor;
    BOOL isFirstDis;
    float currentHeading;
    CLLocation *prevLocation;
    float distancePickDrop;
    CLLocation * sourcePoint;
    CLLocation * destPoint;
    BOOL isDiverted,ispickFirst,isBeginFirst;
    CustomPointAnnotation * pickUpPin;
    CustomPointAnnotation * dropPin;
    MKAnnotationView *driverPinView;
    NSMutableArray *arrPendingTrips;
    NSMutableArray *arrPendingTripsonGoing;
    NSTimer* timerPendingRequest;
    BOOL isFirstLoadDetails;
    RouteDestinationLess * routeDestinationLess;
    NSString *actualDropLocationAddress;
    NSString *actualPickupLocationAddress;
    NSMutableArray *arrColleclectedPointsOrignal;
    BOOL isDrwaingReRouting;
    BOOL isDrwaingReRouting2;
    MapBearingCalculation * _mapBearingCalculation;
    BOOL isRequestViewOpen;
    DataUploadHelper *dataUploadHelper;
    FirebaseUnReadChat *_firebaseUnReadChat;
    NSTimer *timerBlink ;
    BOOL blinkStatus;
    VerificationAlertView *_verificationAlertView;
    HomeDataModel * homeDataModel;
    BOOL isFirstTime;
    LocationDataHelper *_locationDataHelper;
    SingleRequestView* singleRequestView;
    BOOL isRiderCancelCalledNoti;
    UIButton *buttonRequest;
    NSMutableArray *arrayRouteForSave;
    BOOL isSavingRoute;
    BOOL isTrackRouteSaved;
    NSDate * dateForReRouteRequest;
    NSDate * dateForRoutSaveRequest;
    int heightOfRequestView;
    DTripOffersViewContoller *vcOffers;
    AutoHideAlert * autoHideCancelAlert;
    AskTripOtpVC *askOtpVc;
    BOOL isGetTripAppicalled;
    BOOL isCloseAcceptView;
    NSTimer *timerForRefreshNotificationCount;

    UIView   *_ndStatusPillContainer;
    UIView   *_ndStatusDotView;
    UILabel  *_ndStatusTextLabel;
    UIView   *_ndOfflinePanel;
    UISwitch *_ndPanelSwitch;

    UIView          *_ndTabContainerView;
    UIButton        *_ndTabSolicitudesBtn;
    UIButton        *_ndTabOfertasBtn;
    UIView          *_ndTabIndicator;
    UILabel         *_ndBadgeLabel;
    UILabel         *_ndOfertasBadgeLabel;
    UICollectionView *_ndCollectionView;
    BOOL             _ndShowingSolicitudes;
    NSMutableArray   *_ndSentOffers;
    NSString         *_ndPendingNotificationTripId;
    /// El aviso que se saca desde el push, para poder cerrarlo si resulta que no hay nada.
    UIAlertController *_ndAvisoDeSolicitudDelPush;

    UIView   *_ndTripInfoCard;
    UIView   *_ndTripAvatarView;
    UILabel  *_ndTripNameLbl;
    UILabel  *_ndTripInfoLbl;
    UIButton *_ndTripCancelBtn;
    BOOL      _ndTripKvoAdded;

    UIView   *_ndOnTripPanel;
    UIView   *_ndOnTripAvatarWrap;
    UILabel  *_ndOnTripNameLbl;
    UILabel  *_ndOnTripInfoLbl;
    UILabel  *_ndOnTripFareLbl;
    UILabel  *_ndOnTripPayMethodLbl;
    UILabel  *_ndOnTripPickupLbl;
    UILabel  *_ndOnTripDropLbl;

}


-(void)setupTextField:(UITextField*)textField{
    [self setTextFieldPlaceholderColor:textField];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.lblOnGoingCounter.hidden = YES;
    self.lblOnGoingCounter.layer.cornerRadius  = 10;
    [self.lblOnGoingCounter setClipsToBounds:YES];
    self.lblWalletBalanceText.text=@"";
    self.lblWalletBalanceValue.text=@"";
    self.viewCancelBeforeBegin.hidden=YES;
    [Utilities applyTintOnButton:self.btnGps color:[UIColor colorNamed:@"color_icon_tint"] name:@"gps_blue"];
    [self.btnmenu setHideWhenZero:YES];
    [self.btnmenu setBadgeBackgroundColor:[UIColor clearColor]];
    [self.btnmenu setBadgeEdgeInsets:UIEdgeInsetsMake(18,-7, -6,8)];
    if([[ConstantModel getConstantsObject] getCValueFK:ckey_rdl]==NO){
        self.requestView.hidden = YES;
        [self.requestView setConstraintConstant:0 forAttribute:(NSLayoutAttributeHeight)];
    }
    //       [self.btnGps.layer setCornerRadius:4];
    //       [self.btnGps.layer setBorderWidth:1];
    //       [self.btnGps.layer setBorderColor:[UIColor colorNamed:@"color_app_gray"].CGColor];
    
    [self updateRquestCounter];
    heightOfRequestView=SCREEN_HEIGHT/2.6;
    self.btnDirection.hidden=YES;
    _locationDataHelper=[[LocationDataHelper alloc] init];
    homeDataModel=[[HomeDataModel alloc] init];
    self.txtViewMessage.layer.borderWidth=1;
    self.txtViewMessage.layer.borderColor = [UIColor colorNamed:@"app_border_color"].CGColor;
    self.txtViewMessage.textColor = [UIColor colorNamed:@"color_app_label"];
    [self setupTextField:self.txtTripOtp];
    [self setUIFiels];
    [_switchAvalability setOnTintColor:[UIColor greenColor]];
    
    [self.btRequests  setTitleColor:[UIColor colorNamed:@"app_theame"] forState:UIControlStateNormal];
    [self.btRequests  setTitleColor:[UIColor colorNamed:@"app_theame"] forState:UIControlStateSelected];
    [self.btOnGoing  setTitleColor:[UIColor colorNamed:@"color_bt_un_select_text"] forState:UIControlStateNormal];
    [self.btOnGoing  setTitleColor:[UIColor colorNamed:@"color_bt_un_select_text"] forState:UIControlStateSelected];
    [self.viewDivider2 setBackgroundColor:[UIColor clearColor]];
    [self.viewDivider1 setBackgroundColor:[UIColor colorNamed:@"app_theame"]];
    _mapBearingCalculation=[[MapBearingCalculation  alloc] init];
    [self.imRiderProfile.layer setCornerRadius:28];
    [self.viewUserInfo setConstraintConstant:0 forAttribute:NSLayoutAttributeHeight];
    [self.imRiderProfile setClipsToBounds:YES];
    [APP_DELEGATE setNavigationController:self.navigationController];
    [self.viewOtpVerify setHidden:YES];
    [self.txtTripOtp.layer setCornerRadius:2];
    [self.txtTripOtp.layer setBorderWidth:1];
    [self.txtTripOtp.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [self.txtTripOtp setClipsToBounds:YES];
    self.txtTripOtp.delegate=self;
    [self.btOtpVerify.layer setCornerRadius:2];
    [self.btOtpVerify setClipsToBounds:YES];
    
    NSDictionary *dict1 = [[NSUserDefaults standardUserDefaults]objectForKey:P_USER_DICT];
    if([[ConstantModel getConstantsObject] getCValueFK:ckey_ech]==YES){
        [FireAnonymousSigupHelper  checkFireIdAndUpdateInProfileWithComBlock:dict1 comBlock:^(id result, NSError *error) {
            [self updateFireProfile];
        }];
    }
    dataUploadHelper=[[DataUploadHelper alloc] init];
    
    
    
    
    [self setThemeConstants];
    [self.tableViewPendingTrips registerNib:[UINib nibWithNibName:@"UpcommingTripCell" bundle:nil]
                     forCellReuseIdentifier:@"UpcommingTripCell"];
    [self.tableViewPendingTrips registerNib:[UINib nibWithNibName:@"PendingTripCell" bundle:nil] forCellReuseIdentifier:@"PendingTripCell"];
    
    arrPendingTrips =[[NSMutableArray alloc]init];
    apiCallAttempt=0;
    apiCounter =0;
    
    TotalTripDIstance=0.0;
    TotalM =0.0;
    
    lastLoc =  [[CLLocation alloc]initWithLatitude:0.0 longitude:0.0];
    arrayCagetgory =[[NSMutableArray alloc]init];
    
    NSString *dis =defaults_object(@"total_travelled_distance");
    if (dis) {
        TotalM = [dis floatValue]*1000;
        TotalTripDIstance = [dis floatValue];
    }
    
    NSDictionary *dict =defaults_object(@"curr_loc");
    CLLocation *locTemp ;
    if(dict){
        locTemp=[[CLLocation alloc] initWithLatitude:[[dict objectForKey:@"lat"] floatValue] longitude: [[dict objectForKey:@"lng"] floatValue]];
    }else{
        ConstantModel *cModel=[ConstantModel getConstantsObject];
        locTemp=cModel.def_location;
        NSDateFormatter * dfForSave=[[NSDateFormatter alloc] init];
        [dfForSave setDateFormat:SAVE_DATE_FORMAT];
        NSString * dateLastLocation=[dfForSave  stringFromDate:[NSDate date]];
        dict =[[NSDictionary alloc]initWithObjectsAndKeys:[NSString stringWithFormat:@"%f",locTemp.coordinate.latitude],@"lat",[NSString stringWithFormat:@"%f",locTemp.coordinate.longitude ],@"lng",dateLastLocation,@"date", nil];
    }
    if ([Utilities isValidLocation:locTemp.coordinate]) {
        OldLocation = [[CLLocation alloc] initWithLatitude:[[dict objectForKey:@"lat"] floatValue] longitude: [[dict objectForKey:@"lng"] floatValue]];
        StartLocationTaken = TRUE;
    }
    UITapGestureRecognizer *tap =[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction)];
    tap.delegate=self;
    tap.numberOfTouchesRequired=1;
    [_viewMessage  addGestureRecognizer:tap];
    [self initMapView];
    [self getCategoryFormServer];
    [self getTaxiConstant];
    [self addUserInteractionChangeHandlerOnMap];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(OrientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onLeftSwicthChnage) name:@"change_switch_home" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(changeCategoryOnUploadDocument) name:@"change_category_notification" object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateUnReadCount) name:@"message_count_un_read" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(checkAndHideRequestView:) name:AppNotificationName.USER_OFFER_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(checkAndHideRequestViewAccepted:) name:AppNotificationName.USER_DECLINE_Alert_NOTIFICATION object:nil];
    
    [self.btnPhone setHideWhenZero:YES];
    [self.btnPhone setBadgeBackgroundColor:[UIColor clearColor]];
    [self.btnPhone setBadgeEdgeInsets:UIEdgeInsetsMake( 6,0, 0, 6)];
    [self viewShadow];
    [APP_DELEGATE handleNotificationIfHasData];
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource: @"sos" ofType: @"gif"];
    [self.btnSos addTarget:self action:@selector(multipleTap:withEvent:)
          forControlEvents:UIControlEventTouchDownRepeat];
    NSData *gifData = [NSData dataWithContentsOfFile: filePath];
    [self.btnSos setImage:[UIImage sd_imageWithGIFData:gifData] forState:UIControlStateNormal];
    if(self.isRequiredToResfrehDriverProfile){
        [self refreshUserProfile];
    }
    [self setupNewDesign];
}


-(void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    [self viewShadow];
}

- (void)ndCollapseRequestBgIfNewDesignOnline {
    if (!_ndTabContainerView || ![self isAvailablityOn]) return;
    UIView *v = self.viewRequestBg;
    if (!v) return;
    v.hidden = YES;
    for (NSLayoutConstraint *c in v.superview.constraints) {
        if ((c.firstItem == v || c.secondItem == v) && (c.firstAttribute == NSLayoutAttributeHeight || c.secondAttribute == NSLayoutAttributeHeight)) {
            c.constant = 0;
            break;
        }
    }
    for (NSLayoutConstraint *c in v.constraints) {
        if (c.firstAttribute == NSLayoutAttributeHeight && c.firstItem == v) {
            c.constant = 0;
            break;
        }
    }
}

-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self ndCollapseRequestBgIfNewDesignOnline];
    if (self.btnGps && self.btnGps.superview == self.view) {
        const CGFloat trailingInset = 15.0;
        const CGFloat gpsSize = 52.0;
        CGFloat safeTop = 0;
        if (@available(iOS 11.0, *)) { safeTop = self.view.safeAreaInsets.top; }
        CGFloat gpsY = safeTop + 64.0 + 60.0;
        self.btnGps.frame = CGRectMake(self.view.bounds.size.width - trailingInset - gpsSize, gpsY, gpsSize, gpsSize);
    }
}


-(void) requestGetButton{
#if TARGET_OS_SIMULATOR
    buttonRequest=[[UIButton alloc] initWithFrame:CGRectMake(0, 100 ,40, 40)];
    buttonRequest.backgroundColor=[UIColor redColor];
    [buttonRequest addTarget:self action:@selector(requestGetButtonTap:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:buttonRequest];
#else
    buttonRequest=[[UIButton alloc] initWithFrame:CGRectMake(0, 100 ,40, 40)];
    buttonRequest.backgroundColor=[UIColor redColor];
    [buttonRequest addTarget:self action:@selector(requestGetButtonTap:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:buttonRequest];
#endif
}

-(void)requestGetButtonTap:(UIButton *)button{
    if(self->singleRequestView==nil)  {
        //        self->singleRequestView=[SingleRequestView showTripRequestAcceptViewWithDelegate:self parentView:self.view trip:[arrtemp1 firstObject]];
        self->singleRequestView=[SingleRequestView showTripRequestAcceptViewWithDelegate:self parentView:self.view tripIdFromRequest:nil];
        self->singleRequestView.delegate=self;
    }
}

-(void)requestGetButtonTapWithTrip:(TripModel *)trip{
    if(self->singleRequestView==nil)  {
        self->singleRequestView=[SingleRequestView showTripRequestAcceptViewWithDelegate:self parentView:self.view tripIdFromRequest:trip];
        self->singleRequestView.delegate=self;
        _ndStatusPillContainer.hidden = YES;
    }
}

-(void)viewShadow{
    self.viewReadMessage.layer.shadowRadius  = 1.5f;
    self.viewReadMessage.layer.shadowColor   = RGB(220, 220, 220).CGColor; /*[UIColor colorWithRed:176.f/255.f green:199.f/255.f blue:226.f/255.f alpha:1.f].CGColor;*/
    self.viewReadMessage.layer.shadowOffset  = CGSizeMake(0.0f, 0.0f);
    self.viewReadMessage.layer.shadowOpacity = 0.9f;
    self.viewReadMessage.layer.masksToBounds = NO;
    UIEdgeInsets shadowInsets     = UIEdgeInsetsMake(0, 0, -1.5f, 0);
    UIBezierPath *shadowPath      = [UIBezierPath bezierPathWithRect:UIEdgeInsetsInsetRect(self.viewReadMessage.bounds, shadowInsets)];
    self.viewReadMessage.layer.shadowPath    = shadowPath.CGPath;
}



-(void) setUIFiels{
    self.lblWalletBalanceText.text =[LanguageHelper getStringWithKey:@"k_2_s10_current_bal"];
    self.lblTripRequests.text =[LanguageHelper getStringWithKey:@"k_29_s4_trip_requests"];
    
    if(self.btOnGoing.isSelected){
        self.lblNoData.text =[LanguageHelper getStringWithKey:@"k_17_s10_no_trips_scheduled"];
    }else{
        self.lblNoData.text =[LanguageHelper getStringWithKey:@"k_52_s4_waiting_new_ride_req"];
    }
        self.lblNewMessageReceived.text =[LanguageHelper getStringWithKey:@"k_s11_new_message_received"];
    [self.btnReply setTitle:[LanguageHelper getStringWithKey:@"k_s11_reply"] forState:UIControlStateNormal];
    if ([driverStatus isEqualToString:TS_ARRIVE]) {
        [self.btnBeginTrip setTitle: [LanguageHelper getStringWithKey:@"k_31_s4_begin_ride"]   forState:UIControlStateNormal];
    }else if ([driverStatus isEqualToString:TS_BEGIN]) {
        [self.btnBeginTrip setTitle: [LanguageHelper getStringWithKey:@"k_34_s4_end_ride"]   forState:UIControlStateNormal];
    }
    else  {
        [self.btnBeginTrip setTitle: [LanguageHelper getStringWithKey:@"k_31_s4_begin_ride"]   forState:UIControlStateNormal];
    }
    [self handleAddressTopFixed];
    
    [self.btnAccept setTitle:[LanguageHelper getStringWithKey:@"k_21_s4_yes"] forState:UIControlStateNormal];
    [self.btnDecline setTitle:[LanguageHelper getStringWithKey:@"k_22_s4_no"] forState:UIControlStateNormal];
    [self.btnOK setTitle:[LanguageHelper getStringWithKey:@"k_18_s4_otp_apply"] forState:UIControlStateNormal];
    self.lblCancelButtonText.text=[LanguageHelper getStringWithKey:@"k_r2_s8_cancel_ride"];
    
    /*
     Con el viaje en TS_ARRIVE el conductor YA dijo que va en camino, asi que el boton tiene
     que ofrecer el paso siguiente: "He llegado!".

     Estaba al reves: solo ponia "He llegado!" si DRIVER_STATUS_TEMP valia TS_PICKED, y esa
     bandera significa lo contrario -- que el pasajero YA subio (la pone
     ButtonAcceptPressed) --, momento en el que este boton ni se enseña, porque se esconde
     goPopUpView y sale btnBeginTrip en su lugar.

     De ahi el sintoma: el conductor tocaba "Voy en camino!", el boton cambiaba, y el primer
     refresco de textos lo devolvia a "Voy en camino!". El segundo toque si avanzaba, porque
     ButtonGoPressed mira driverStatus y no el rotulo. O sea que el viaje avanzaba bien y lo
     unico roto era lo que el conductor leia, que es justo lo que le hace dudar.

     El camino del sondeo -- cuando el TS_ARRIVE llega del servidor -- siempre lo tuvo bien.
     Esto lo iguala.
     */
    /*
     Tres rotulos, uno por paso, como updateTripStatusUI en Android:

       arrive                    -> "Recoger Cliente"
       accept + ya aviso         -> "He llegado!"
       accept                    -> "Voy en camino!"

     El del medio sale de la marca del aviso, no del estado del viaje, porque el paso "voy en
     camino" a proposito NO cambia el estado: si se leyera de ahi, el boton volveria al
     principio en el primer refresco de textos.
     */
    NSString *idDelViajeEnCurso = isEmpty(self->homeDataModel.trip.trip_Id);
    if([self->homeDataModel.trip.trip_Status isEqualToString:TS_ARRIVE]){
        [self.btnGoPopUP setTitle:[LanguageHelper getStringWithKey:@"k_20_s4_pick" defaultValue:@"Recoger Cliente"] forState:UIControlStateNormal];
        [self.btnGoPopUP setImage:nil forState:UIControlStateNormal];
        self.btnGoPopUP.semanticContentAttribute = UISemanticContentAttributeUnspecified;
    }else if([ConrraVoyEnCamino yaAvisoEnElViaje:idDelViajeEnCurso]){
        // La clave y el texto son los de Android (k_driver_arrived): "Estoy llegando!", no
        // "He llegado!". Es el boton que se pulsa AL llegar, no despues.
        [self.btnGoPopUP setTitle:[LanguageHelper getStringWithKey:@"k_driver_arrived" defaultValue:@"Estoy llegando!"] forState:UIControlStateNormal];
        UIImage *msgIcon = [UIImage imageNamed:@"ic_message_bubble"];
        if (msgIcon) {
            [self.btnGoPopUP setImage:[msgIcon imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
            self.btnGoPopUP.semanticContentAttribute = UISemanticContentAttributeForceRightToLeft;
        }
    }else{
        [self.btnGoPopUP setTitle:[LanguageHelper getStringWithKey:@"k_driver_on_the_way" defaultValue:@"Voy en camino!"] forState:UIControlStateNormal];
        [self.btnGoPopUP setImage:nil forState:UIControlStateNormal];
        self.btnGoPopUP.semanticContentAttribute = UISemanticContentAttributeUnspecified;
    }
    self.lblPassengerDetails.text =[LanguageHelper getStringWithKey:@"k_s3_passenger_details"];
    self.lblCallMeText.text =[LanguageHelper getStringWithKey:@"s_2_s10_call_me"];
    
    self.lblWhyNot.text = [LanguageHelper getStringWithKey:@"k_25_s4_why_not"];
    NSString *offlineES = @"Estás desconectado. Conéctate en línea para empezar a recibir solicitudes de viajes";
    NSString *offlineEN = @"You're offline. Connect online to start receiving trip requests";
    NSString *langCode = [LanguageHelper sharedInstance].cunnrentLanguage ?: @"";
    BOOL isES = [langCode hasPrefix:@"es"];
    self.lbloffLine.text = [LanguageHelper getStringWithKey:@"k_1_s14_you_are_offline" defaultValue:(isES ? offlineES : offlineEN)];
    self.lblGoOnline.text = [LanguageHelper getStringWithKey:@"k_2_s14_go_online_accept_ride"];
    [self.btRequests setTitle: [LanguageHelper getStringWithKey:@"k_62_s4_request"]   forState:UIControlStateNormal];
    [self.btOnGoing setTitle: [LanguageHelper getStringWithKey:@"k_6_s4_a1_upcmng_rides"]   forState:UIControlStateNormal];
    // Otp
    self.txtTripOtp.placeholder =[LanguageHelper getStringWithKey:@"k_18_s4_plz_enter_otp"];
    [self.btOtpVerify setTitle: [LanguageHelper getStringWithKey:@"k_18_s4_otp_apply"]   forState:UIControlStateNormal];
    self.lblTripOtpMessage.text = [Utilities stringByStrippingHTML:[LanguageHelper getStringWithKey:@"k_18_s4_plz_ask_psngr_fr_otp"]];
    
    
    if([vcOffers.view isHidden]==NO){
        [self onSendOffer:nil];
    }else{
        [self onRequestsView:nil];
    }
}









-(void)OrientationDidChange:(NSNotification*)notification{
    if ([driverStatus isEqualToString:TS_BEGIN]||[driverStatus isEqualToString:@"Picked"]||[driverStatus isEqualToString:@"arrive"]) {
        UIDeviceOrientation Orientation=[[UIDevice currentDevice]orientation];
        float angleAnnotaion=0;
        if(Orientation==UIDeviceOrientationLandscapeLeft ){
            angleAnnotaion=90;
        }else if( Orientation==UIDeviceOrientationLandscapeRight){
            angleAnnotaion=270;
        }
        else if(Orientation==UIDeviceOrientationPortraitUpsideDown)  {
            angleAnnotaion=180;
        }
        else if(Orientation==UIDeviceOrientationPortrait) {
            angleAnnotaion=0;
        }
    }
}


-(CGFloat) DegreesToRadians:(CGFloat )degrees{
    return degrees * M_PI / 180;
}


-(CGFloat) RadiansToDegrees:(CGFloat) radians{
    return radians * 180 / M_PI;
}


-(void)  updateFireProfile{
    NSDictionary *dictUser = [[NSUserDefaults standardUserDefaults]objectForKey:P_USER_DICT];
    NSString *fId=[dictUser objectForKey:P_FIRE_ID];
    if(fId.length>0){
        self.ref = [[FIRDatabase database] reference];
        self.ref_TripChat = [[self.ref child:@"user_details"] child:fId];
        [self setDataOnFireProfile:fId key:@"w"];
    }
}



-(void) setDataOnFireProfile:(NSString *) fireId key:(NSString *)key {
    NSString * deviceToken=[[NSUserDefaults standardUserDefaults] objectForKey:P_DEVICE_TOKEN];
    [[self.ref_TripChat   child:@"device_token"] setValue:isEmpty(deviceToken)];
    [[self.ref_TripChat    child:@"device_type"] setValue:IOS];
    NSDictionary *dictUser = [[NSUserDefaults standardUserDefaults]objectForKey:P_USER_DICT];
    [[self.ref_TripChat    child:@"domery_user_id"] setValue:[dictUser objectForKey:P_DRIVER_ID]];
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [[self.ref_TripChat    child:@"time"] setValue:[dateFormatter stringFromDate:[NSDate date]]];
    [[self.ref_TripChat    child:@"user_id"] setValue:fireId];
    [[self.ref_TripChat    child:@"is_user"] setValue:@(NO)];
    
}



-(void) configureSingleModeUI{
    if (!_ndTabContainerView) {
        [self.viewRequestBg setHidden:NO];
        if(!isRequestViewOpen)  {
            [_viewRequestBg setConstraintConstant:heightOfRequestView forAttribute:NSLayoutAttributeHeight];
        }
    }
    driverStatus = defaults_object(DRIVER_STATUS);
    if(![driverStatus isEqualToString:TS_WAITING]){
        [self.viewRequestBg hideByHeight:YES];
    }
}



-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [Utilities applyTintOnButton:self.btnDirection color:[UIColor colorNamed:@"color_app_label"] name:@"ic_menu_map"];
    [self setUIFiels];
    [self showWalletBalance];
    [self.tableViewPendingTrips reloadData];
    if (_ndCollectionView) { dispatch_async(dispatch_get_main_queue(), ^{ [self->_ndCollectionView reloadData]; NSInteger _ndCount = self->arrPendingTrips.count; self->_ndBadgeLabel.hidden = (_ndCount == 0); self->_ndBadgeLabel.text = [NSString stringWithFormat:@"%ld", (long)_ndCount]; }); }
    [self configureSingleModeUI];
    apiCallAttempt = 0;
    [self startUpdatingLoc];
    [self ButtonGpsPressed:nil];
    //Firebase
    isChatVCCalled = NO;
    [self checkAndShowAlertWith];
    [self onLeftSwicthChnage];
    [self hideAndShowOffLineMessageView];
    //Firebase
    NSDictionary *dictUser = [[NSUserDefaults standardUserDefaults]objectForKey:P_USER_DICT];
    if([[dictUser objectForKey:P_DRIVER_VERIFIED] boolValue]==NO)  {
        [_verificationAlertView removeFromSuperview];
        _verificationAlertView=nil;
        _verificationAlertView= [VerificationAlertView showView:self.view];
        _verificationAlertView.delegate=self;
    }else{
        [_verificationAlertView removeFromSuperview];
        _verificationAlertView=nil;
    }
    int authorizationStatus=[CLLocationManager authorizationStatus];
    if(authorizationStatus==0){
        [_locationManager requestAlwaysAuthorization];
    }
    [self getNotificationCount];
    //    [self checkDemoAndTripDemo];
    //    if([[ConstantModel getConstantsObject] is_demo ]){
    //        NSDictionary * dictUser=defaults_object(P_USER_DICT);
    //        if([[dictUser objectForKey:P_DRIVER_VERIFIED] intValue]==1){
    //            NSString *tripId = defaults_object(@"trip_id");
    //            if(tripId==nil) {
    //                if(((NSString *)[dictUser objectForKey:P_EMAIL]).length == 0 || ((NSString *)[dictUser objectForKey:P_MOBILE]).length == 0 ){
    //                    [self showInCompleteProfilePop];
    //                }else{
    //                    BOOL isAvailibityOn = [[dictUser objectForKey:@"d_is_available"] boolValue];
    //                    if (isAvailibityOn==NO){
    //                        if([self.navigationController.topViewController isKindOfClass:[HomeViewController class]]){
    //                            [self showInAvalibityOnPop];
    //                        }
    //                    }
    //                }
    //            }
    //        }
    //    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.btnmenu && self.btnmenu.superview) {
        UIView *container = self.btnmenu.superview.superview ?: self.btnmenu.superview;
        [self.view bringSubviewToFront:container];
        self.btnmenu.userInteractionEnabled = YES;
    }
    if (_ndStatusPillContainer) {
        [self.view bringSubviewToFront:_ndStatusPillContainer];
    }
    if (_ndOfflinePanel != nil) {
        [self hideAndShowOffLineMessageView];
    }
}

-(void) checkDemoAndTripDemo{
    if([[ConstantModel getConstantsObject] is_demo ]){
        NSDictionary * dictUser=defaults_object(P_USER_DICT);
        if([[dictUser objectForKey:P_DRIVER_VERIFIED] intValue]==1){
            NSString *tripId = defaults_object(@"trip_id");
            if(tripId==nil) {
                if(((NSString *)[dictUser objectForKey:P_EMAIL]).length == 0 || ((NSString *)[dictUser objectForKey:P_MOBILE]).length == 0 ){
                    [self showInCompleteProfilePop];
                }else{
                    BOOL isAvailibityOn = [[dictUser objectForKey:@"d_is_available"] boolValue];
                    if (isAvailibityOn==NO){
                        if([self.navigationController.topViewController isKindOfClass:[HomeViewController class]]){
                            if(self.view.window!=nil){
                                if([homeDataModel.trip.trip_Id intValue]==0){
                                    
                                    [self showInAvalibityOnPop];
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}


//-(void)updateTimeWhenTrip{
//    if(homeDataModel.trip==nil) {
//        return;
//    }
//    if([homeDataModel.trip.trip_Status isEqualToString:TS_BEGIN]){
//        CityModel *cModel=[CityModel getCityByCityId:homeDataModel.trip.city_id];
//        NSString *dist;
//        NSString *tripDis;
//        float  totalTripDIstanceCal=0;
//        if(routeDestinationLess) {
//            totalTripDIstanceCal=[routeDestinationLess getTotalTripDIstanceCal];
//        }else {
//            totalTripDIstanceCal=TotalTripDIstance;
//        }
//        if (isDistanceUnitKm(cModel.city_dist_unit)/*[[constantModel.constant_distance capitalizedString] isEqualToString:@"Km"]*/) {
//            dist =cModel.city_dist_unit;
//            tripDis = [Utilities formatDistance:totalTripDIstanceCal];;
//        }
//        else{
//            dist =cModel.city_dist_unit;
//            float miles =KM_TO_MI(totalTripDIstanceCal);
//            tripDis = [Utilities formatDistance:miles];
//        }
//        NSString *startStr =  [Utilities GetGMTDatetoLocalTZ:homeDataModel.trip.trip_pickup_time :@"yyyy-MM-dd HH:mm:ss"];
//        NSDate *startTime =  [self convertStringToDate:startStr fromFormat:@"yyyy-MM-dd HH:mm:ss"];
//        float fareCal=[self->homeDataModel.category  calculatePrice:[tripDis floatValue]  time:[self  calculateDurationInMin:startTime secondDate: [NSDate date]] waitingTime:[self getTotalWaitTimeLeftFree]];
//        _lblExpectedTime.text = [NSString stringWithFormat:@"%@%@",cModel.city_cur,[Utilities formatCurrencyFloat:fareCal]];
//        NSString * durationStr = [self calculateDuration:startTime secondDate: [NSDate date]];
//        _lblExpArrivaltime.text =[NSString stringWithFormat:@"%@",durationStr];
//    }
//}



-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if (_ndTripKvoAdded) {
        @try { [self.viewCancelBeforeBegin removeObserver:self forKeyPath:@"hidden"]; } @catch (...) {}
        _ndTripKvoAdded = NO;
    }
    [self stopMusic];
    [self invalidatePendingTripTimer];
    NSString *status =defaults_object(DRIVER_STATUS);
    if ( status ==nil ||[status isEqualToString:TS_WAITING] || [status isEqualToString:TS_REQUEST] || [status isEqualToString:TS_END] || [status isEqualToString:TS_DRIVER_CANCEL_AT_PICKUP] || [status isEqualToString:TS_DRIVER_CANCEL_AT_DROP]){
    }
    else {
        
    }
    if (timerBlink)  {
        [timerBlink invalidate];
        timerBlink=nil;
    }
}




-(void)appDidEnterForeground{
    if (self.navigationController.topViewController ==self) {
        [self startUpdatingLoc];
        [self ndCollapseRequestBgIfNewDesignOnline];
        [self.view setNeedsLayout];
        [self.view layoutIfNeeded];
        __weak typeof(self) wself = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [wself ndCollapseRequestBgIfNewDesignOnline];
            [wself.view setNeedsLayout];
            [wself.view layoutIfNeeded];
        });
    }
    [self checkAndShowAlertWith];
    int authorizationStatus=[CLLocationManager authorizationStatus];
    if(authorizationStatus==0){
        [_locationManager requestAlwaysAuthorization];
    }
    [self checkDemoAndTripDemo];
    [self setTimerForRefresNotificationCount];
    //    if([[ConstantModel getConstantsObject] is_demo ]){
    //        NSString *tripId = defaults_object(@"trip_id");
    //        NSDictionary * dictUser=defaults_object(P_USER_DICT);
    //        if([[dictUser objectForKey:P_DRIVER_VERIFIED] intValue]==1){
    //            if(tripId==nil) {
    //                if(((NSString *)[dictUser objectForKey:P_EMAIL]).length == 0 || ((NSString *)[dictUser objectForKey:P_MOBILE]).length == 0 ){
    //                    [self showInCompleteProfilePop];
    //                }else{
    //                    BOOL isAvailibityOn = [[dictUser objectForKey:@"d_is_available"] boolValue];
    //                    if (isAvailibityOn==NO){
    //                        if([self.navigationController.topViewController isKindOfClass:[HomeViewController class]]){
    //                            if([homeDataModel.trip.trip_Id intValue]>0){
    //                                [self showInAvalibityOnPop];
    //                            }
    //                        }
    //                    }
    //                }
    //            }
    //        }
    //    }
}



-(void)startUpdatingLoc{
    
    if ( [self canConsiderDriverIsFree]) {
        if([self isAvailablityOn]){
            [self hideAndShowReqestView:YES];
            [self getAllPendingTrips:!isFirstLoadDetails];
        }else{
            [self hideAndShowReqestView:NO];
        }
        
        
        isFirstLoadDetails =YES;
        
        driverStatus = defaults_object(DRIVER_STATUS);
        if(![driverStatus isEqualToString:TS_WAITING])  {
            NSString *tripId = defaults_object(@"trip_id");
            if(tripId!=nil) {
                [self.viewRequestBg hideByHeight:YES];
            }
        }
    }
    else {
    }
    [[UpdateUserCurrentLocation sharedInstance] startUpdateCurrentLocation];
}






-(void)setThemeConstants{
    [_lblLocationTitle setFont:FONTS_THEME_REGULAR(17)];
    [_lblAddressTop setFont:FONTS_THEME_REGULAR(17)];
    [_lblAcceptTitle setFont:FONTS_THEME_REGULAR(17)];
    [_btnDecline.titleLabel setFont:FONTS_THEME_REGULAR(17)];
    [_lblWhyNot setFont:FONTS_THEME_REGULAR(17)];
    [_txtViewMessage setFont:FONTS_THEME_REGULAR(15)];
    [_btnOK.titleLabel setFont:FONTS_THEME_REGULAR(15)];
    [_lbloffLine setFont:FONTS_THEME_REGULAR(17)];
    [_lblGoOnline setFont:FONTS_THEME_REGULAR(17)];
    _lblGoOnline.textColor = [UIColor colorNamed:@"color_app_label"];
    _lbloffLine.textColor = [UIColor colorNamed:@"color_app_label"];
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




#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:StoryBoardUtiles.FARE_AMOUNT_VC]) {
        FareAmmountViewController *fareView =(FareAmmountViewController *)[segue destinationViewController];
        fareView.curr_trip = homeDataModel.trip;
        [[UpdateUserCurrentLocation sharedInstance] stopUpdateCurrentLocation];
        arrPendingTrips =[[NSMutableArray alloc]init];
        [self.tableViewPendingTrips reloadData];
        if (_ndCollectionView) { dispatch_async(dispatch_get_main_queue(), ^{ [self->_ndCollectionView reloadData]; NSInteger _ndCount = self->arrPendingTrips.count; self->_ndBadgeLabel.hidden = (_ndCount == 0); self->_ndBadgeLabel.text = [NSString stringWithFormat:@"%ld", (long)_ndCount]; }); }
    }

}




#pragma Buttons Action

- (IBAction)ButtonMenuPressed:(id)sender {
    LGSideMenuController *menu = [self effectiveSideMenuController];
    if (!menu) return;

    // Ensure menu's view has valid bounds (fixes zero-height when shown before first layout)
    [menu.view setNeedsLayout];
    [menu.view layoutIfNeeded];

    // If driver menu (MainViewController) has no left view or it's disabled, re-apply type 12 setup
    if ([menu isKindOfClass:[MainViewController class]]) {
        MainViewController *mainMenu = (MainViewController *)menu;
        if (!menu.leftView || menu.isLeftViewDisabled) {
            [mainMenu setupWithType:12];
        }
    }

    [menu showLeftViewAnimated:YES completionHandler:nil];

    if (menu.leftViewContainer && menu.leftViewContainer.superview) {
        [menu.view bringSubviewToFront:menu.leftViewContainer];
    }
    if (self.btnmenu && self.btnmenu.superview) {
        UIView *container = self.btnmenu.superview.superview ?: self.btnmenu.superview;
        [self.view bringSubviewToFront:container];
    }
}

/// Resolves the LGSideMenuController to use for showing the driver side menu. Tries AppDelegate ref first (set in openDriverHomeScreen), then view's window, category lookup, then key/windows fallbacks.
- (LGSideMenuController *)effectiveSideMenuController {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    // 1) AppDelegate's driver side menu — most reliable; set when openDriverHomeScreen runs and cleared when switching to rider
    if ([appDelegate respondsToSelector:@selector(driverSideMenuController)]) {
        LGSideMenuController *ref = appDelegate.driverSideMenuController;
        if (ref) return ref;
    }
    // 2) View's window root (when this VC is on screen)
    UIWindow *window = self.view.window;
    if (!window && [appDelegate respondsToSelector:@selector(window)] && appDelegate.window) {
        window = appDelegate.window;
    }
    if (window && [window.rootViewController isKindOfClass:[LGSideMenuController class]]) {
        return (LGSideMenuController *)window.rootViewController;
    }
    // 3) Category lookup (parent/nav chain + associated object)
    LGSideMenuController *menu = self.sideMenuController;
    if (menu) return menu;
    // 4) keyWindow / first window (iOS 13+ keyWindow can be nil)
    UIApplication *app = [UIApplication sharedApplication];
    window = app.keyWindow;
    if (!window && app.windows.count > 0) window = app.windows.firstObject;
    if (window && [window.rootViewController isKindOfClass:[LGSideMenuController class]]) {
        return (LGSideMenuController *)window.rootViewController;
    }
    return nil;
}


- (IBAction)ButtonGpsPressed:(id)sender{
    AppDelegate *appdelegate =APP_DELEGATE;
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(appdelegate.currLoc.coordinate, 600, 600);
    CLLocation *loc = [[CLLocation alloc] initWithLatitude:appdelegate.currLoc.coordinate.latitude longitude:appdelegate.currLoc.coordinate.longitude];
    isMapDraged =NO;
    
    [self setDriverPin:loc];
    
    if(currentHeading>0) {
        _mapView.camera.heading=currentHeading;
        [self.mapView setCamera:_mapView.camera animated:NO];
    }
    [self mapRegion:region mapView:self.mapView];
    
}




- (IBAction)ButtonAcceptPressed:(UIButton *)sender {
    if ([driverStatus isEqualToString:TS_ARRIVE]) {
        driverStatus = TS_PICKED;
        defaults_set_object(DRIVER_STATUS, driverStatus);
        defaults_set_object(DRIVER_STATUS_TEMP,TS_PICKED);
        _acceptDeclineView.hidden=YES;
        _btnBeginTrip.hidden=NO;
        _goPopUpView.hidden=YES;

        if([ConstantModel getConstantsObject].otp_start) {
            [self openAskOtpScreen];
        }
        [self handleAddressTopFixed];
        isBeginFirst =NO;
        [self drawroute:NO isAccept:NO isDivert:NO];
    }
    else{
        if([ConstantModel getConstantsObject].otp_end) {
            _acceptDeclineView.hidden=YES;
            [self.viewOtpVerify setHidden:NO];
            [self.txtTripOtp becomeFirstResponder];
        }else{
            [self fatechActualDropLocation];
        }
    }
}




- (IBAction)ButtonDeclinePressed:(UIButton *)sender {
    [self.viewOtpVerify setHidden:YES];
    self.txtViewMessage.text=@"";
    if ([driverStatus isEqualToString:TS_ARRIVE]) {
        if([self isJobCancelBeforeTimer]){
            _acceptDeclineView.hidden=YES;
            self.goPopUpView.hidden=NO;
            [self onCancelButtonTap];
            return;
        }
    }
    isCloseAcceptView = YES;
    _acceptDeclineView.hidden=YES;
    _viewMessage.hidden=NO;
    // Re-show on-trip panel if driver declined ending trip during TS_BEGIN/TS_PICKED
    if ([driverStatus isEqualToString:TS_BEGIN] || [driverStatus isEqualToString:TS_PICKED]) {
        if (_ndOnTripPanel) {
            _ndOnTripPanel.hidden = NO;
        }
    }
}




- (IBAction)ButtonMessageOKPressed:(id)sender {
    isCloseAcceptView = NO;
    reasonString = [_txtViewMessage.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (reasonString.length==0) {
        [self showWarningWithMessgae:[LanguageHelper getStringWithKey:@"k_26_s3_write_reason"]];
    }
    else{
        if ([self->homeDataModel.trip.trip_Status isEqualToString:TS_ARRIVE]) {
            [self updateTripStatus:TS_DRIVER_CANCEL_AT_PICKUP];
        }
        else if ([self->homeDataModel.trip.trip_Status isEqualToString:TS_BEGIN]){
            [self fatechActualDropLocationOnCancel ];
        }
    }
}




- (IBAction)btnVerifyOtpTap:(id)sender {
    [self.view endEditing:YES];
    if(self.txtTripOtp.text.length==0){
        [self showAlertWithMessgae:[LanguageHelper getStringWithKey:@"k_45_s4_plz_enter_otp_ask_frm_driver"]];
        return;
    }
    NSString * last4DigitElseOfUser=homeDataModel.trip.otp;
    if(homeDataModel.trip.trip_customer_details.length>0){
        NSDictionary *dict=[Utilities idFormJsonString:homeDataModel.trip.trip_customer_details];
        if(dict){
            NSString *p_phone=[dict objectForKey:@"p_phone"];
            last4DigitElseOfUser=[p_phone substringFromIndex:p_phone.length-4];
        }
    }
    NSString * last4DigitOfUser=homeDataModel.trip.otp;
    if(homeDataModel.trip.user.u_phone){
        NSString *p_phone=homeDataModel.trip.user.u_phone;
        last4DigitOfUser=[p_phone substringFromIndex:p_phone.length-4];
    }
    //     last 4 digit of user mobile number and in case booking for some else the last 4 digit of user
    if(!([self.txtTripOtp.text isEqualToString:homeDataModel.trip.otp]||[self.txtTripOtp.text isEqualToString:last4DigitOfUser]||[self.txtTripOtp.text isEqualToString:last4DigitElseOfUser])){
        [self showAlertWithMessgae:[LanguageHelper getStringWithKey:@"k_44_s4_plz_enter_valid_otp"]];
        return;
    }
    self.txtTripOtp.text=@"";
    [self.viewOtpVerify setHidden:YES];
    [self.view endEditing:YES];
    NSString *str1 = [LanguageHelper getStringWithKey:@"k_31_s4_begin_ride"];
    if ([self.btnBeginTrip.titleLabel.text isEqualToString:str1]) {
        [self fatechActualPickUpLocation];
    }
    else{
        [self fatechActualDropLocation ];
    }
}



-(void)openAskOtpScreen{
    if(askOtpVc){
        askOtpVc=nil;
    }
    AskTripOtpVC *vc=[AskTripOtpVC openWith:homeDataModel.trip viewController:self];
    askOtpVc =vc;
    vc.delegate=self;
}

- (void)onOtpEnteredForBegin:(NSString *)strOtp viewController:(AskTripOtpVC *)viewController{
    NSString * last4DigitElseOfUser=homeDataModel.trip.otp;
    if(homeDataModel.trip.trip_customer_details.length>0){
        NSDictionary *dict=[Utilities idFormJsonString:homeDataModel.trip.trip_customer_details];
        if(dict){
            NSString *p_phone=[dict objectForKey:@"p_phone"];
            last4DigitElseOfUser=[p_phone substringFromIndex:p_phone.length-4];
        }
    }
    NSString * last4DigitOfUser=homeDataModel.trip.otp;
    if(homeDataModel.trip.user.u_phone){
        NSString *p_phone=homeDataModel.trip.user.u_phone;
        last4DigitOfUser=[p_phone substringFromIndex:p_phone.length-4];
    }
    if(!([strOtp isEqualToString:homeDataModel.trip.otp]||[strOtp isEqualToString:last4DigitOfUser]||[strOtp isEqualToString:last4DigitElseOfUser])){
        //        [self showAlertWithMessgae:[LanguageHelper getStringWithKey:@"k_44_s4_plz_enter_valid_otp"]];
        [self showAlertWithButtonTitle:[LanguageHelper getStringWithKey:@"k_18_s4_Ok"] title:@"" message:[LanguageHelper getStringWithKey:@"k_44_s4_plz_enter_valid_otp"] handler:^(UIAlertAction * _Nonnull action) {
            [viewController openAgainKeyboard:NO];
        }];
        [viewController openAgainKeyboard:YES];
        return;
    }
    [self.view endEditing:YES];
    [self dismissViewControllerAnimated:YES completion:^{
        self->askOtpVc = nil;
        NSString *str1 = [LanguageHelper getStringWithKey:@"k_31_s4_begin_ride"];
        if ([self.btnBeginTrip.titleLabel.text isEqualToString:str1]) {
            [self fatechActualPickUpLocation];
        }
        else{
            [self fatechActualDropLocation ];
        }
    }];
}

-(void)closeAskOtpScreen{
    askOtpVc = nil;
}

- (IBAction)btnBeginTripPressed:(UIButton *)sender {
    NSString *str1 = [LanguageHelper getStringWithKey:@"k_31_s4_begin_ride"];
    if ([sender.titleLabel.text isEqualToString:str1]) {
        if(homeDataModel.trip.is_share) {
            // in case ride share skip otp on beginn trip
            [self fatechActualPickUpLocation];
        }else {
            if([ConstantModel getConstantsObject].otp_start) {
                //                    [self.viewOtpVerify setHidden:NO];
                //                    [self.txtTripOtp becomeFirstResponder];
                _goPopUpView.hidden = YES;
                [self openAskOtpScreen];
            }else  {
                [self fatechActualPickUpLocation];
            }
        }
    }
    else{
        //                if(constantTaxiModel.otp_end)  {
        //                    [self openAskOtpScreen];
        //                }else {
        //                    [self fatechActualDropLocation ];
        //                }
        _btnBeginTrip.hidden =YES;
        _lblAcceptTitle.text = [LanguageHelper getStringWithKey:@"k_24_s4_client_reached_dest"];
        _acceptDeclineView.hidden=NO;
    }
    
}




-(void)tapAction{
    [_txtViewMessage resignFirstResponder];
}



-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"refresh_location"
     object:nil];
    if(isFirstTime) {
        if([self isCheckLocationFailedScreen]){
            ConstantModel *consts=[ConstantModel getConstantsObject];
            AppDelegate *appdelegate =APP_DELEGATE;
            appdelegate.currLoc =consts.def_location;
            [self ButtonGpsPressed:nil];
            [[UpdateUserCurrentLocation sharedInstance]  updateDriverAvailablity:@"0"];
            if(![self canConsiderDriverIsFree]){
                [self locatonGetFailedScreen:manager isBackHidden:YES];
            }
        }else{
            
        }
    }
    isFirstTime=YES;
}


- (void)locationManagerDidChangeAuthorization:(CLLocationManager *)manager API_AVAILABLE(ios(14.0), macos(11.0), watchos(7.0), tvos(14.0)){
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"refresh_location"
     object:nil];
    if(isFirstTime){
        if([self isCheckLocationFailedScreen]){
            ConstantModel *consts=[ConstantModel getConstantsObject];
            AppDelegate *appdelegate =APP_DELEGATE;
            appdelegate.currLoc =consts.def_location;
            [self ButtonGpsPressed:nil];
            [[UpdateUserCurrentLocation sharedInstance]  updateDriverAvailablity:@"0"];
            if(![self canConsiderDriverIsFree]){
                [self locatonGetFailedScreen:manager isBackHidden:YES];
            }
        }else{
            
        }
    }
    isFirstTime=YES;
}



-(void)initMapView{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDriverLogout) name:@"driver_logout" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getNewOrderRequest:) name:AppNotificationName.DRIVER_ACCEPT_NOTIFICATION object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideAlertNotificationHandle:) name:AppNotificationName.DRIVER_HIDE_ALERT_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appDidEnterForeground)
                                                 name:UIApplicationDidBecomeActiveNotification/*UIApplicationWillEnterForegroundNotification*/
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getNewNotificationSound:) name:@"noti_refresh" object:nil];
    self.mapView.delegate = self;
    self.mapView.showsUserLocation = YES;
    AppDelegate *appdelegate =APP_DELEGATE;
    NSDictionary *lastloc = defaults_object(@"curr_loc");
    CLLocation *location=[[CLLocation alloc] initWithLatitude:[[lastloc objectForKey:@"lat"] floatValue] longitude:[[lastloc objectForKey:@"lng"] floatValue]];
    if(lastloc){
        location= [[CLLocation alloc] initWithLatitude:[[lastloc objectForKey:@"lat"] floatValue] longitude: [[lastloc objectForKey:@"lng"] floatValue]];
    }else{
        ConstantModel *cModel=[ConstantModel getConstantsObject];
        location=cModel.def_location;
        NSDateFormatter * dfForSave=[[NSDateFormatter alloc] init];
        [dfForSave setDateFormat:SAVE_DATE_FORMAT];
        NSString * dateLastLocation=[dfForSave  stringFromDate:[NSDate date]];
        lastloc =[[NSDictionary alloc]initWithObjectsAndKeys:[NSString stringWithFormat:@"%f",location.coordinate.latitude],@"lat",[NSString stringWithFormat:@"%f",location.coordinate.longitude ],@"lng",dateLastLocation,@"date", nil];
    }
    
    if (lastloc != nil && [Utilities isValidLocation:location.coordinate]) {
        appdelegate.currLoc=location;
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(appdelegate.currLoc.coordinate, 600, 600);
        [self mapRegion:region mapView:self.mapView];
    }
    
    
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    _locationManager.distanceFilter = kCLDistanceFilterNone;
    [_locationManager requestAlwaysAuthorization];
    //    [_locationManager allowsBackgroundLocationUpdates];
    //    [self.locationManager setAllowsBackgroundLocationUpdates:YES];
    //    if (@available(iOS 11.0, *)) {
    //        [self.locationManager setShowsBackgroundLocationIndicator:YES];
    //    } else {
    //        // Fallback on earlier versions
    //    }
    NSString *isAvailabilityLocalOn=defaults_object(is_availability_on);
    if([isAvailabilityLocalOn boolValue]){
        [self.locationManager setAllowsBackgroundLocationUpdates:YES];
        if (@available(iOS 11.0, *)) {
            [self.locationManager setShowsBackgroundLocationIndicator:YES];
        } else {
            // Fallback on earlier versions
        }
    }
    [_locationManager setPausesLocationUpdatesAutomatically:NO];
    [_locationManager startUpdatingLocation];
    
    self.mapView.showsUserLocation = YES;
    self.mapView.userTrackingMode = MKUserTrackingModeFollow;
    self.mapView.showsCompass = YES;
    /*
     Mapa NORMAL, no el apagado.

     Estaba en MKMapTypeMutedStandard -- el estilo que Apple hizo para que el mapa se quite
     de en medio y luzcan tus capas -- y ademas con TODOS los puntos de interes
     desactivados. De ahi que se viera palido y sin nada: ni comercios, ni plazas, ni
     referencias. Justo lo que un pasajero usa para reconocer donde esta.

     Android usa Google Maps con sus POIs puestos. Esto es lo mas cerca que llega MapKit:
     el estilo estandar y sin filtro de puntos de interes.
     */
    self.mapView.mapType = MKMapTypeStandard;
    self.mapView.showsTraffic = NO;
    if (@available(iOS 13.0, *)) {
        self.mapView.pointOfInterestFilter = nil;
    }
    if ([CLLocationManager headingAvailable]) {
        _locationManager.headingFilter = 5;
        [_locationManager startUpdatingHeading];
    }
    [self settoInitialState];
    NSString *status =defaults_object(DRIVER_STATUS);
    if ( status ==nil ||[status isEqualToString:TS_WAITING] || [status isEqualToString:TS_REQUEST]  || [status isEqualToString:TS_DRIVER_CANCEL_AT_PICKUP] ) {
        
        if (appdelegate.isFromInactive){
            appdelegate.isFromInactive =NO;
            driverStatus =TS_WAITING;
            [self getAllPendingTrips:YES];
        }
        driverStatus =TS_WAITING;
        defaults_set_object(DRIVER_STATUS, driverStatus);
    }
    else{
        driverStatus=status;
    }
    self.btnShareRides.hidden=YES;
    [self gettripDetails:status];
    
    
    //    let points = [
    //           HeatmapPoint(coordinate: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), intensity: 0.8),
    //           HeatmapPoint(coordinate: CLLocationCoordinate2D(latitude: 37.7849, longitude: -122.4094), intensity: 0.6),
    //           HeatmapPoint(coordinate: CLLocationCoordinate2D(latitude: 37.7649, longitude: -122.4294), intensity: 0.4),
    //       ]
    
}



-(void)settoInitialState{

    // La marca del aviso se guarda por viaje, asi que no se arrastra al siguiente. Se borra
    // igual al cerrar, para no dejar una clave por cada viaje en los defaults.
    [ConrraVoyEnCamino olvidarElViaje:isEmpty(homeDataModel.trip.trip_Id)];
    // Y las solicitudes que se estaban aguantando: son de antes de este viaje.
    [ConrraSolicitudesPersistentes olvidarTodas];

    ispickFirst =NO;
    [self removeTripDetailsTimer];
    [self stopMusic];
    [self handleAddressTopFixed:YES];
    _goPopUpView.hidden=YES;
    _btnBeginTrip.hidden=YES;
    [self clearMapView:YES];
    NSString *str = [LanguageHelper getStringWithKey:@"k_21_s4_yes"];
    [_btnAccept setTitle:str forState:UIControlStateNormal];
    NSString *str1 = [LanguageHelper getStringWithKey:@"k_22_s4_no"];
    [_btnDecline setTitle:str1 forState:UIControlStateNormal];
    NSString *str2 = [LanguageHelper getStringWithKey:@"k_31_s4_begin_ride"];
    [_btnBeginTrip setTitle:str2 forState:UIControlStateNormal];
    [self.btnGoPopUP setTitle:[LanguageHelper getStringWithKey:@"k_driver_on_the_way" defaultValue:@"Voy en camino!"] forState:UIControlStateNormal];
    [self.btnGoPopUP setImage:nil forState:UIControlStateNormal];
    self.btnGoPopUP.semanticContentAttribute = UISemanticContentAttributeUnspecified;
}



#pragma mark - CLLocationManager Delegate

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
    if (newHeading.headingAccuracy < 0)
        return;
    CLLocationDirection  theHeading = ((newHeading.trueHeading > 0) ?
                                       newHeading.trueHeading : newHeading.magneticHeading);
    if(newHeading.trueHeading > 0){
        self.mapView.camera.heading=newHeading.magneticHeading;
        [self.mapView setCamera:self.mapView.camera animated:NO];
        
        if ([driverStatus isEqualToString:TS_BEGIN]||[driverStatus isEqualToString:@"Picked"]||[driverStatus isEqualToString:@"arrive"]) {
            
        }
    }
    currentHeading = newHeading.magneticHeading;
}



-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    CLLocation *loc = locations.lastObject;
    //    CurrentLocation = loc;
    AppDelegate * appdelegate=APP_DELEGATE;
    CLLocationCoordinate2D preLocation=appdelegate.currLoc.coordinate;
    
    [self setDriverPin:loc];
    
}


-(void)showWaitingTimer{
    [self removerWatTimer];
    //    ConstantModel *constantModel=[ConstantModel getConstantsObject];1
    //    int totalSeconds=constantModel.d_timer;
    //    NSDate *animateStartTime;
    //    if(currTrip.tm_arr.length>0){
    //        NSString *startStr =  [Utilities GetGMTDatetoLocalTZ:currTrip.tm_arr :@"yyyy-MM-dd HH:mm:ss"];
    //        animateStartTime =  [self convertStringToDate:startStr fromFormat:@"yyyy-MM-dd HH:mm:ss"];
    //        if(animateStartTime==nil){
    //            animateStartTime=[NSDate date];
    //        }
    //    }else{
    //        animateStartTime=[NSDate date];
    //    }
    //    int diff=[[NSDate date] timeIntervalSince1970]-[animateStartTime timeIntervalSince1970];
    if([self isJobCancelBeforeTimer]){
        _waitingTimerView = [[WaitingTimerView alloc] initFromNib];
        _waitingTimerView.category=[CategoryModel getCategoryByid:[homeDataModel.trip.category_id intValue]];
        _waitingTimerView.delegate=self;
        _waitingTimerView.frame = CGRectMake(0,0, SCREEN_WIDTH, 70);
        [self.viewAcceptWaitTimer addSubview:_waitingTimerView];
        [_waitingTimerView setUpView:homeDataModel.trip.tm_arr];
        self.viewAcceptWaitTimer.hidden=NO;
    }
}

-(void) removerWatTimer{
    self.viewAcceptWaitTimer.hidden=YES;
    if(_waitingTimerView){
        self.viewAcceptWaitTimer.hidden=YES;
        [_waitingTimerView stopTimer];
        [_waitingTimerView removeFromSuperview];
        if([self isJobCancelBeforeTimer]==NO){
            self.viewCancelBeforeBegin.hidden=NO;
        }else{
            self.viewCancelBeforeBegin.hidden=YES;
        }
        _waitingTimerView=nil;
    }
}


-(void)onTimeWaitCompleted{
    [self removerWatTimer];
}

-(BOOL) isJobCancelBeforeTimer{
    ConstantModel *constantModel=[ConstantModel getConstantsObject];
    CategoryModel *category = [CategoryModel getCategoryByid:[homeDataModel.trip.category_id  intValue]];
    int totalSeconds=category.d_can_free_min;
    NSDate *animateStartTime;
    if(homeDataModel.trip.tm_arr.length>0){
        NSString *startStr =  [Utilities GetGMTDatetoLocalTZ:homeDataModel.trip.tm_arr :@"yyyy-MM-dd HH:mm:ss"];
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


/**
 handle and make condition for show cancel button
 */

-(void) manageCancelRideButton{
    if([homeDataModel.trip.trip_Status isEqualToString:TS_ACCEPTED]){
        //
        self.viewCancelBeforeBegin.hidden=NO;
    }else if([homeDataModel.trip.trip_Status isEqualToString:TS_ARRIVE]){
        if([self isJobCancelBeforeTimer]==NO){
            if([homeDataModel.trip isPickedLocal]){
                self.viewCancelBeforeBegin.hidden=NO;
            }else{
                self.viewCancelBeforeBegin.hidden=NO;
            }
        }else{
            self.viewCancelBeforeBegin.hidden=YES;
        }
        
    }
    else if([homeDataModel.trip.trip_Status isEqualToString:TS_BEGIN]){
        self.viewCancelBeforeBegin.hidden=YES;
    }else{
        self.viewCancelBeforeBegin.hidden=YES;
    }
    
}
- (IBAction)onCancelButtonTap:(id)sender {
    if([homeDataModel.trip.trip_Status isEqualToString:TS_ACCEPTED]){
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@""
                                                                                 message:[LanguageHelper getStringWithKey:@"k_67_s4_cncl_at_pkup_title_drv"]
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *actionOk = [UIAlertAction actionWithTitle:[LanguageHelper getStringWithKey:@"k_21_s4_yes"]
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * _Nonnull action) {
            //            if([self isJobCancelBeforeTimer]){
            self->reasonStringType=@"d";
            self->reasonString = @"";
            //                if ([self->driverStatus isEqualToString:TS_ARRIVE]) {
            [self updateTripStatusCancelAtPickUp];
            //                }
            //            }else{
            //                [self ButtonDeclinePressed:nil];
            //            }
        }];
        [alertController addAction:actionOk];
        UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:[LanguageHelper getStringWithKey:@"k_22_s4_no"]
                                                               style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * _Nonnull action) {
            if([self->homeDataModel.trip.trip_Status isEqualToString:TS_ARRIVE]){
                [self showWaitingTimer];
            }
        }];
        [alertController addAction:actionCancel];
        [self presentViewController:alertController animated:YES completion:nil];
    }else{
        [self ButtonDeclinePressed:self.btnDecline];
    }
}

-(void)onCancelButtonTap{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[LanguageHelper getStringWithKey:@"k_67_s4_cncl_at_pkup_title_drv"]
                                                                             message:[LanguageHelper getStringWithKey:@"k_67_s4_cncl_at_pkup_msg_drv"]
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *actionOk = [UIAlertAction actionWithTitle:[LanguageHelper getStringWithKey:@"k_21_s4_yes"]
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {
        if([self isJobCancelBeforeTimer]){
            self->reasonStringType=@"d";
            self->reasonString = @"";
            if ([self->driverStatus isEqualToString:TS_ARRIVE]) {
                [self updateTripStatusCancelAtPickUp];
            }
        }else{
            [self ButtonDeclinePressed:nil];
        }
    }];
    [alertController addAction:actionOk];
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:[LanguageHelper getStringWithKey:@"k_22_s4_no"]
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * _Nonnull action) {
        if ([self->driverStatus isEqualToString:TS_ARRIVE]) {
            [self showWaitingTimer];
        }
    }];
    [alertController addAction:actionCancel];
    [self presentViewController:alertController animated:YES completion:nil];
}

-(void) updateTripStatusCancelAtPickUp{
    NSString * cancelAt = [NSString stringWithFormat:@"%@",[Utilities getStringFromDate:[NSDate date]]];
    [self saveTripLogFor:TS_DRIVER_CANCEL_AT_PICKUP timeAt:cancelAt];
    
    [self saveRouteWhenCancelTrip:self->homeDataModel.trip.trip_Id completionBlock:^(id results, NSError *error) {
        if ([[[results objectForKey:P_STATUS] uppercaseString] isEqualToString:@"OK"]) {
            [self updateTripStatus:TS_DRIVER_CANCEL_AT_PICKUP];
        }else{
            if(results!=nil){
                [self showAlertWithMessgae:[results objectForKey:P_MESSAGE]];
            }else{
                [Utilities handleError:error viewController:self defaultMessage:@""];
            }
        }
    }];
    
}

-(void) saveRouteWhenCancelTrip:(NSString *) tripId completionBlock:(void (^)(id results, NSError *error))block {
    [dataUploadHelper saveLogDataWithTripId:tripId completionBlock:block isShowLoader:YES onlySave:NO];
}

-(void) saveTripLogFor:(NSString *)status timeAt:(NSString *)timeAt{
    AppDelegate *delegate= APP_DELEGATE;
    [[DataBase shareDataBase] insertTripLogDataTripID:self->homeDataModel.trip.trip_Id ulat:self->homeDataModel.trip.user.lat ulng:self->homeDataModel.trip.user.lng dlat:delegate.currLoc.coordinate.latitude dlng:delegate.currLoc.coordinate.longitude tripStatus:status timeAt:timeAt key1:@"" key2:@"" key3:@"" key4:@"" ];
}


/**
 Save Last valid Location  in nsuser deefaults
 */

-(void) saveLatLongInDefaults:(CLLocation *)loc{
    
    //    if(![Utilities isValidLocation:loc.coordinate]){
    //        ConstantModel *cModel=[ConstantModel getConstantsObject];
    //        loc=cModel.def_location;
    //    }
    NSDateFormatter * dfForSave=[[NSDateFormatter alloc] init];
    [dfForSave setDateFormat:SAVE_DATE_FORMAT];
    NSString * dateLastLocation=[dfForSave  stringFromDate:[NSDate date]];
    NSDictionary * dict =[[NSDictionary alloc]initWithObjectsAndKeys:[NSString stringWithFormat:@"%f",loc.coordinate.latitude],@"lat",[NSString stringWithFormat:@"%f",loc.coordinate.longitude ],@"lng",dateLastLocation,@"date", nil];
    defaults_set_object(@"curr_loc", dict);
}

/**
 check device is moving or not
 */

-(BOOL) isDeviceNotWalking{
    BOOL b = [CMMotionActivityManager isActivityAvailable];
    if(b) {
        if([_activtiyNameDetactor isEqualToString:@"Not Walking"] || [_activtiyNameDetactor isEqualToString:@"stationary"]){
            return YES;
        }
    }
    return NO;
}

/**
 check location accurecy
 */
-(BOOL) isAccurecyValidForApp:(CLLocation *)loc{
    if(loc.horizontalAccuracy<0){
        return NO;
    }
    if(loc.horizontalAccuracy>20){
        return NO;
    }
    return YES;
}

-(void)addOrUpdateDriverPinLocation:(CLLocation *)loc{
    CLLocationCoordinate2D  preLocation= loc.coordinate;
    if(driverPin==nil){
        driverPin = [[MKPointAnnotation alloc] init];
        driverPin.coordinate = loc.coordinate;
        [self.mapView addAnnotation:driverPin];
    }
    else {
        if(![self isDeviceNotWalking]){
            [UIView animateWithDuration:0.2f
                             animations:^{
                self->driverPin.coordinate =  loc.coordinate;
                if([self->_mapBearingCalculation isAngleChanged:loc.coordinate]){
                    float headding= [self->_mapBearingCalculation getBearing:preLocation currentLocation:loc.coordinate];
                    if(headding>=-10000) {
                        self->driverPinView.transform = CGAffineTransformMakeRotation(headding+M_PI);
                        [[UpdateUserCurrentLocation sharedInstance] setDriverDegree:[self RadiansToDegrees:headding]];
                    }
                }
            }];
            //            }
        }
    }
    [self CenterMapRegionForShot];
}


-(void)setDriverPin:(CLLocation *)loc{
    
    
    if(![self isAccurecyValidForApp:loc]){
        if ([driverStatus isEqualToString:TS_ACCEPTED]||[driverStatus isEqualToString:TS_ARRIVE]||[driverStatus isEqualToString:TS_BEGIN]||[driverStatus isEqualToString:@"Picked"]) {
            
        }else{
            AppDelegate *appdelegate= APP_DELEGATE;
            appdelegate.currLoc = loc;
            [self saveLatLongInDefaults:loc];
            [self addOrUpdateDriverPinLocation:loc];
        }
        return;
    }
    
    AppDelegate *appdelegate= APP_DELEGATE;
    CLLocationCoordinate2D  preLocation= appdelegate.currLoc.coordinate;
    appdelegate.currLoc = loc;
    [self saveLatLongInDefaults:loc];
    
    [self CenterMapRegionForShot];
    if(driverPin==nil) {
        driverPin = [[MKPointAnnotation alloc] init];
        driverPin.coordinate = appdelegate.currLoc.coordinate;
        [self.mapView addAnnotation:driverPin];
    }
    else{
        [UIView animateWithDuration:0.3f
                         animations:^{
            self->driverPin.coordinate =  appdelegate.currLoc.coordinate;
            if([self->_mapBearingCalculation isAngleChanged:appdelegate.currLoc.coordinate]){
                float headding= [self->_mapBearingCalculation getBearing:preLocation currentLocation:appdelegate.currLoc.coordinate];
                if(headding>=-10000)   {
                    self->driverPinView.transform = CGAffineTransformMakeRotation(headding+M_PI);
                    [[UpdateUserCurrentLocation sharedInstance] setDriverDegree:[self RadiansToDegrees:headding]];
                }
            }
        }];
    }
    if (!isFirstLoad) {
        isFirstLoad =YES;
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(loc.coordinate, 600, 600);
        [self mapRegion:region mapView:self.mapView];
    }
    
    if([self isDeviceNotWalking]){
        return;
    }
    
    //if ([driverStatus isEqualToString:TS_BEGIN ]) {
    if (StartLocationTaken == FALSE && [Utilities isValidLocation:loc.coordinate]) {
        StartLocationTaken = TRUE;
        StartLocation = [[CLLocation alloc] initWithLatitude:loc.coordinate.latitude longitude:loc.coordinate.longitude];
        OldLocation = [[CLLocation alloc] init];
        OldLocation = StartLocation;
        if(arrColleclectedPointsOrignal==nil) {
            arrColleclectedPointsOrignal=[[NSMutableArray alloc]  init];
        }
        [arrColleclectedPointsOrignal removeAllObjects];
    }
    else{
        if ([driverStatus isEqualToString:TS_BEGIN]) {
            float distanceOldAndCurrentLatlong =0.0;
            if ([Utilities isValidLocation:OldLocation.coordinate] && [Utilities isValidLocation:loc.coordinate]) {
                distanceOldAndCurrentLatlong = [loc distanceFromLocation:OldLocation];
            }
            if(![homeDataModel.trip isTripDropLocationOptional]){
                [self checkAndCallReRoute:loc];
            }
            
            if (distanceOldAndCurrentLatlong >20 ) {
                TotalM = TotalM+distanceOldAndCurrentLatlong;
                TotalTripDIstance = (TotalM / 1000.0); //Converting Meters to KM
                NSString *dist =[NSString stringWithFormat:@"%f",TotalTripDIstance];
                defaults_set_object(@"total_travelled_distance",dist );
                OldLocation = loc;
                [[DataBase shareDataBase] insertRouteLatLngForTripID:homeDataModel.trip.trip_Id lat:loc.coordinate.latitude lng:loc.coordinate.longitude];
            }
            
            if([homeDataModel.trip isTripDropLocationOptional]){
                if(routeDestinationLess==nil) {
                    routeDestinationLess=[[RouteDestinationLess alloc] initWithMap:_mapView];
                    [routeDestinationLess setDriverCurrentLocation:loc];
                }
                [routeDestinationLess setDriverPin:loc];
                [self CenterMapRegionForShot];
                CLLocation * locC=[routeDestinationLess getCurrentLocationLast];
                if(driverPin==nil) {
                    driverPin = [[MKPointAnnotation alloc] init];
                    driverPin.coordinate = appdelegate.currLoc.coordinate;
                    [self.mapView addAnnotation:driverPin];
                }
                
                [UIView animateWithDuration:0.3f
                                 animations:^{
                    self->driverPin.coordinate = [self->routeDestinationLess getCurrentLocationLast].coordinate;
                    if([self->_mapBearingCalculation isAngleChanged:appdelegate.currLoc.coordinate])   {
                        float headding= [self->_mapBearingCalculation getBearing:preLocation currentLocation:appdelegate.currLoc.coordinate];
                        if(headding>=-10000)  {
                            self->driverPinView.transform = CGAffineTransformMakeRotation(headding+M_PI);
                            [[UpdateUserCurrentLocation sharedInstance] setDriverDegree:[self RadiansToDegrees:headding]];
                        }
                    }
                }];
                if(driverPinStart==nil) {
                    CLLocation * statLoc=[routeDestinationLess  getCurrentLocationFirst];
                    if(statLoc){
                        driverPinStart=[[CustomPointAnnotation alloc]  initWithType:PIN_START];
                        driverPinStart.coordinate =self.mapView.userLocation.location.coordinate;
                        [self.mapView addAnnotation:driverPinStart];
                    }
                }
            }
            if(arrayRouteForSave!=nil&&arrayRouteForSave.count>0){
                if(![dataUploadHelper isRouteDataUploaded]){
                    if(self->dModelOldRoute!=nil){
                        [self uploadeBeginRouteOrRouteDataIsSendNotification:NO];
                    }
                }
            }
        }else{
            if ([driverStatus isEqualToString:TS_ACCEPTED]||[driverStatus isEqualToString:TS_ARRIVE]||[driverStatus isEqualToString:@"Picked"]) {
                if(![homeDataModel.trip isTripDropLocationOptional]){
                    NSString *localTripStatus=defaults_object(DRIVER_STATUS_TEMP);
                    if(localTripStatus!=nil &&[localTripStatus isEqualToString:TS_PICKED]) {
                    }else{
                        if([driverStatus isEqualToString:TS_ACCEPTED]){
                            [self checkAndCallReRoute:loc];
                        }
                    }
                }
            }
        }
    }
}


-(void) checkAndCallReRoute:(CLLocation *)loc{
    //this code is commented in the Rocab no need to redraw route the route
    [self checkCurrentLocationOutSideRouteOnValiddate:loc];
    BOOL isValid=[_locationDataHelper isOnValidRoute];
    if([self checkCurrentLocationOutSideRoute:loc ]==YES||isValid==NO){
        [self drawNewRouteOffline:loc ];
    }else{
        
    }
    if(isValid){
        int index=[_locationDataHelper lastValidIndex];
        if(index>=10&&index<dModelOldRoute.arrDirectionLatLngSimplifiedChecked.count-1){
            [dModelOldRoute.arrDirectionLatLngSimplifiedChecked removeObjectsInRange:(NSRange){0, index+1-10}];
            [_locationDataHelper removeOldObjectWhenReRoute];
        }
    }
}


-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    if([self isCheckLocationFailedScreen]){
        AppDelegate *appdelegate =APP_DELEGATE;
        ConstantModel * conns=[ConstantModel getConstantsObject];
        
        appdelegate.currLoc =conns.def_location;
        [self ButtonGpsPressed:nil];
        if(![self canConsiderDriverIsFree]){
            [self locatonGetFailedScreen:manager isBackHidden:YES];
        }
    }else{
        
    }
}





-(NSDate *)convertStringToDate:(NSString *)strDate fromFormat:(NSString *)strFromFormat
{
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = strFromFormat;
    return [dateFormatter dateFromString:strDate];
}




- (NSString *)calculateDuration:(NSDate *)oldTime secondDate:(NSDate *)currentTime
{
    NSDate *date1 = oldTime;
    NSDate *date2 = currentTime;
    NSTimeInterval secondsBetween = [date2 timeIntervalSinceDate:date1];
    if(secondsBetween<0)
    {
        secondsBetween=0;
    }
    //    int hh = secondsBetween / (60*60);
    //    double rem = fmod(secondsBetween, (60*60));
    int mm = secondsBetween / 60;
    // rem = fmod(rem, 60);
    //  int ss = rem;
    if(mm<1)
    {
        NSString *str = [NSString stringWithFormat:@"%i %@",(int)secondsBetween,[LanguageHelper getStringWithKey:@"k_52_s3_sec"]];
        return str;
    }
    NSString *str = [NSString stringWithFormat:@"%i%@",mm,[LanguageHelper getStringWithKey:mm<=1?@"k_17_s4_min":@"k_17_s4_mins"]];
    return str;
}
- (long)calculateDurationInMin:(NSDate *)oldTime secondDate:(NSDate *)currentTime
{
    NSDate *date1 = oldTime;
    NSDate *date2 = currentTime;
    NSTimeInterval secondsBetween = [date2 timeIntervalSinceDate:date1];
    if(secondsBetween<0)
    {
        secondsBetween=0;
    }
    //    int hh = secondsBetween / (60*60);
    //    double rem = fmod(secondsBetween, (60*60));
    int mm = secondsBetween / 60;
    int mmReminder = ((long)secondsBetween)%60;
    if(mmReminder>0)
    {
        mm= mm+1;
    }
    // rem = fmod(rem, 60);
    //  int ss = rem;
    //    if(mm<1)
    //    {
    //        NSString *str = [NSString stringWithFormat:@"%i sec",(int)secondsBetween];
    //        return str;
    //    }
    //    NSString *str = [NSString stringWithFormat:@"%i mn",mm];
    return mm;
}


#pragma mark checkDistacneOfRoute



-(void) drawNewRouteOffline:(CLLocation *) locationSrc{
    if([homeDataModel.trip.trip_Status isEqualToString:TS_BEGIN]||[homeDataModel.trip.trip_Status isEqualToString:TS_ARRIVE]){
        if([homeDataModel.trip isTripDropLocationOptional]){
            [self clearMapView:YES];
            return;
        }
    }
    CLLocation *  destPoint=[[CLLocation alloc]  initWithLatitude:[homeDataModel.trip.trip_drop_lat doubleValue] longitude:[homeDataModel.trip.trip_drop_long doubleValue]];
    if([homeDataModel.trip.trip_Status isEqualToString:TS_BEGIN]||[homeDataModel.trip.trip_Status isEqualToString:TS_ARRIVE]){
        NSString *localTripStatus=defaults_object(DRIVER_STATUS_TEMP);
        if([homeDataModel.trip.trip_Status isEqualToString:TS_ARRIVE]){
            if(localTripStatus!=nil &&[localTripStatus isEqualToString:TS_PICKED]) {
                destPoint=[[CLLocation alloc]  initWithLatitude:[homeDataModel.trip.trip_drop_lat doubleValue] longitude:[homeDataModel.trip.trip_drop_long doubleValue]];
            }else{
                destPoint=[[CLLocation alloc]  initWithLatitude:[homeDataModel.trip.trip_pick_lat doubleValue] longitude:[homeDataModel.trip.trip_pick_long doubleValue]];
            }
        }else{
            destPoint=[[CLLocation alloc]  initWithLatitude:[homeDataModel.trip.trip_drop_lat doubleValue] longitude:[homeDataModel.trip.trip_drop_long doubleValue]];
        }
    }else{
        destPoint=[[CLLocation alloc]  initWithLatitude:[homeDataModel.trip.trip_pick_lat doubleValue] longitude:[homeDataModel.trip.trip_pick_long doubleValue]];
    }
    
    if(![Utilities isValidLocation:destPoint.coordinate]){
        return;
    }
    
    float distance=[destPoint distanceFromLocation:locationSrc];
    if(distance<100){
        return;
    }
    if([homeDataModel.trip.trip_Status isEqualToString:TS_BEGIN]||[homeDataModel.trip.trip_Status isEqualToString:TS_ARRIVE]){
        if([homeDataModel.trip isTripDropLocationOptional]){
            [self clearMapView:YES];
            return;
        }else{
            [self clearMapView:NO];
        }
    }else{
        [self clearMapView:NO];
    }
    if(isDrwaingReRouting) {
        return;
    }
    isDrwaingReRouting=YES;
    GoogleDirectionSource * userDriverLocationRoute=[[GoogleDirectionSource alloc]  initWithSource:locationSrc destination:destPoint];
    [userDriverLocationRoute findDirection_isInTrip:NO WithCompletionBlock:^(id results, NSError *error) {
        self->isDrwaingReRouting=NO;
        if([results isKindOfClass:[DirectionModel class]])  {
            DirectionModel  *dModel=(DirectionModel *)results;
            if(self->dModelOldRoute==nil)  {
                self->dModelOldRoute=[[DirectionModel alloc] init];
            }
            self->dModelOldRoute=dModel;
            [_locationDataHelper removeOldObjectWhenReRoute];
            for(id<MKOverlay> overlay in [self.mapView overlays])  {
                if(![overlay.title isEqualToString:@"cv"])   {
                    [self.mapView  removeOverlay:overlay];
                }
            }
            [self zoomToFitMapAnnotationsWith:userDriverLocationRoute isDiverted:NO];
            //            [self.mapView  removeOverlays:[self.mapView overlays]];
            [self.mapView addOverlay:[dModel getPolyline] level:MKOverlayLevelAboveRoads];
            [self uploadeBeginRouteOrRouteData:dModel.arrDirectionLatLng isSendNotification:YES];
        }
        else {
            
        }
    }];
}

-(void) uploadeBeginRouteOrRouteDataIsSendNotification:(BOOL)isSendNotification{
    if(isSavingRoute){
        return;
    }
    if(self->isTrackRouteSaved){
        return;
    }
    if(!isSendNotification){
        if(dateForRoutSaveRequest==nil)  {
            dateForRoutSaveRequest= [NSDate date];
        }else{
            int diff = [[NSDate date] timeIntervalSince1970] -[dateForRoutSaveRequest timeIntervalSince1970];
            if (diff<20){
                return;
            }
            dateForRoutSaveRequest= [NSDate date];
        }
        
    }
    if(homeDataModel.trip.trip_Id==nil){
        return;
    }
    isSavingRoute=YES;
    [dataUploadHelper saveCoverRouteOnServerForTripIdBegin:homeDataModel.trip.trip_Id userId:[NSString stringWithFormat:@"%d",homeDataModel.trip.user.userId] routeArray:arrayRouteForSave completionBlock:^(id  _Nonnull results, NSError * _Nonnull error) {
        self->isSavingRoute=NO;
        if(error==nil)  {
            self->arrayRouteForSave=nil;
            if(isSendNotification){
                //                [self sendNotification:@"route"];
            }
        }
    }];
}



-(void) uploadeBeginRouteOrRouteData:(NSMutableArray *)arrayRoute isSendNotification:(BOOL)isSendNotification{
    arrayRouteForSave=[[NSMutableArray alloc] initWithArray:arrayRoute];
    [self uploadeBeginRouteOrRouteDataIsSendNotification:isSendNotification];
}

-(BOOL) checkDistacneOfRoute
{
    if(arrColleclectedPointsOrignal.count<2)
    {
        return NO;
    }
    double distance=0;
    CLLocation *location=[arrColleclectedPointsOrignal  firstObject];
    for(int i=1;i<arrColleclectedPointsOrignal.count;i++)
    {
        location=[arrColleclectedPointsOrignal  objectAtIndex:i-1];
        CLLocation *locationRoute=[arrColleclectedPointsOrignal objectAtIndex:i];
        distance+= [locationRoute distanceFromLocation:location];
        
    }
    if(distance>100)
    {
        return YES;
    }
    return NO;
}

-(BOOL) checkCurrentLocationOutSideRoute:(CLLocation *) location{
    //    NSDictionary *dict=[self findLocationAndIndex :location];
    //    if(dict){
    //        int index=[[dict objectForKey:@"index"] intValue];
    //        return NO;
    //    }else{
    //        if([self isNearMenueverEnd:location distanceRange:120]){
    //            [self removeNextPointLess:location distance:50];
    //            return NO;
    //        }
    //    }
    //    if(dModelOldRoute.arrDirectionLatLngSimplifiedChecked.count>0){
    //        CLLocation *locationRoute=[dModelOldRoute.arrDirectionLatLngSimplifiedChecked objectAtIndex:0];
    //        double distance= [locationRoute distanceFromLocation:location];
    //        if(distance<130){
    //            NSLog(@"--- distance %f %ld",distance,0);
    ////            [self removeNextPointLess:location distance:15];
    //            return NO;
    //        }
    //    }
    long routeArrayCount=dModelOldRoute.arrDirectionLatLngSimplifiedChecked.count;
    for(long i=0;i<routeArrayCount;i++){
        CLLocation *locationRoute=[dModelOldRoute.arrDirectionLatLngSimplifiedChecked objectAtIndex:i];
        double distance= [locationRoute distanceFromLocation:location];
        if(distance<80){
            NSLog(@"--- distance %f %ld",distance,routeArrayCount);
            //            [self removeNextPointLess:location distance:15];
            //            routeArrayCount=dModelOldRoute.arrDirectionLatLngSimplifiedChecked.count;
            return NO;
        }else{
            //            NSLog(@"--- distance YES %f %ld",distance,routeArrayCount);
            //            if([self isNearMenueverEnd:location distanceRange:100]){
            //                [self removeNextPointLess:location distance:50];
            //                return NO;
            //            }
            //            return YES;
        }
    }
    return YES;
}




-(BOOL) checkCurrentLocationOutSideRouteOnValiddate:(CLLocation *) location{
    long routeArrayCount=dModelOldRoute.arrDirectionLatLngSimplifiedChecked.count;
    for(long i=0;i<routeArrayCount;i++){
        CLLocation *locationRoute=[dModelOldRoute.arrDirectionLatLngSimplifiedChecked objectAtIndex:i];
        double distance= [locationRoute distanceFromLocation:location];
        if(distance<80){
            [_locationDataHelper addObject:locationRoute index:i];
            return NO;
        }
    }
    return YES;
}




#pragma mark mapview delegates


- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    //    CLLocation *loc = [[CLLocation alloc] initWithLatitude:userLocation.coordinate.latitude longitude:userLocation.coordinate.longitude];
    //    CurrentLocation = loc;
    AppDelegate * appdelegate=APP_DELEGATE;
    //    CLLocationCoordinate2D preLocation=appdelegate.currLoc;
    
}


- (void)zoomToFitMapAnnotationsWith:(GoogleDirectionSource * )directionSource isDiverted:(BOOL)isDiverted1 {
    
    pickUpPin=[[CustomPointAnnotation alloc]  initWithType:PIN_START];
    
    //    if (isDiverted1 && arrFilteredWayPoints.count>0) {
    //        CLLocation *loc =[arrFilteredWayPoints objectAtIndex:0];
    //        pickUpPin.coordinate= loc.coordinate;
    //    }
    //    else{
    //
    pickUpPin.coordinate= directionSource.source.coordinate;
    //    }
    [self.mapView addAnnotation:pickUpPin];
    
    
    dropPin=[[CustomPointAnnotation alloc]  initWithType:PIN_DROP];
    dropPin.coordinate= directionSource.destination.coordinate;
    [self.mapView addAnnotation:dropPin];
    
    arrayAnotations=@[pickUpPin,dropPin];
    
}


//-(void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading{
//
//    if (newHeading.headingAccuracy < 0){
//        return;
//    }
//
//    AppDelegate *delegate = APP_DELEGATE;
//    angle = (double)newHeading.magneticHeading;
//    delegate.driver_angle = angle;
//
//
//}




- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    centerCoordinate= mapView.centerCoordinate;
    
}

-(MKAnnotationView *)mapView:(MKMapView *)mV viewForAnnotation:(id <MKAnnotation>)annotation{
    MKAnnotationView *pinView = nil;
    if(annotation != self.mapView.userLocation) {
        static NSString *defaultPinID = @"com.driver.pin";
        pinView = (MKAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:defaultPinID];
        if ( pinView == nil )
            pinView = [[MKAnnotationView alloc]
                       initWithAnnotation:annotation reuseIdentifier:defaultPinID];
        pinView.transform = CGAffineTransformIdentity;

        if (annotation == driverPin) {
            pinView.image = [UIHelper imageForMapWithImage:[UIImage imageNamed:@"map_car_icon"]];
            
            //            pinView.layer.anchorPoint = CGPointMake(0.5f, 1.0f);
            [UIView animateWithDuration:2
                             animations:^{
                self->driverPinView =pinView;
            }];
        }
        else if([annotation isKindOfClass:[CustomPointAnnotation class]])
        {
            CustomPointAnnotation  *mAnno=(CustomPointAnnotation *) annotation;
            if([mAnno.type isEqualToString:PIN_START])
            {
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
            else{
                pinView.image = [UIImage imageNamed:@"map_pin_drop"];
                pinView.layer.anchorPoint = CGPointMake(0.5f, 0.5f);
            }
            
        }
    }
    else {
        
        [self.mapView.userLocation setTitle:@"I am here"];
    }
    return pinView;
}



-(void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
    
    MKAnnotationView *ulv = [mapView viewForAnnotation:mapView.userLocation];
    ulv.hidden = YES;
}

#pragma api calls

-(void)hideAlertNotificationHandle:(NSNotification *) notificationData {
    [APP_DELEGATE stopRequestSound];
    if(singleRequestView){
        [self->singleRequestView removeFromSuperview];
        self->singleRequestView=nil;
        _ndStatusPillContainer.hidden = NO;
    }
    [arrPendingTrips removeAllObjects];
    [self.tableViewPendingTrips reloadData];
    if (_ndCollectionView) { dispatch_async(dispatch_get_main_queue(), ^{ [self->_ndCollectionView reloadData]; NSInteger _ndCount = self->arrPendingTrips.count; self->_ndBadgeLabel.hidden = (_ndCount == 0); self->_ndBadgeLabel.text = [NSString stringWithFormat:@"%ld", (long)_ndCount]; }); }
    [self getAllPendingTrips:YES];
    [vcOffers runTimedCodeForGetTripOffers];
}

-(void)getNewOrderRequest:(NSNotification *) notificationData {
    
    
    NSDictionary * dict=  notificationData.userInfo;
    NSMutableDictionary *dicAps=[dict valueForKey:@"aps"];
    NSString *status=[dicAps objectForKey:@"trip_status"];
    NSString *trip_id=[dicAps objectForKey:@"trip_id"];
    NSString *message=@"";
    message=[dicAps objectForKey:@"alert"];
    if(message==nil||message.length==0)  {
        message=@"m";
    }
    defaults_set_object(TRIP_ID, trip_id);
    
    driverStatus = defaults_object(DRIVER_STATUS);
    if([[dicAps objectForKey:@"trip_status"] isEqualToString:TS_REQUEST] ||[[dicAps objectForKey:@"trip_status"] isEqualToString:@"hide_alert"]){
        if(![self.navigationController.topViewController isKindOfClass:[HomeViewController class]]){
            //            [self.navigationController popToRootViewControllerAnimated:YES];
            //            [self stopLocationUpdate];
            //            HomeViewController * vcHome=[self.storyboard instantiateViewControllerWithIdentifier:@"HomeViewController"];
            //            [[NSUserDefaults standardUserDefaults] setObject:@(NO)  forKey:P_IS_SINGLE_MODE];
            //            [[NSUserDefaults standardUserDefaults]synchronize];
            //            [self.navigationController setViewControllers:@[vcHome] animated:YES];
            //            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
            [self handleNewRequestNotification:[dicAps objectForKey:@"trip_id"] message:[dicAps objectForKey:@"alert"]];
        }else{
            NSDictionary *dictDriver =defaults_object(P_USER_DICT);
            int availabil=[[dictDriver objectForKey:P_DRIVER_AVAILAILITY] intValue];
            if(availabil==1){
                // No loader on notification arrival — let the trip card silently pop in
                [self getAllPendingTrips:NO];
            }
        }
    }
    else if([[dicAps objectForKey:@"trip_status"] isEqualToString:@"missed"]||[[dicAps objectForKey:@"trip_status"] isEqualToString:@"hide_alert"]){
        [APP_DELEGATE stopRequestSound];
        if(singleRequestView){
            [self->singleRequestView removeFromSuperview];
            self->singleRequestView=nil;
        }
        [self showAlert:@"" message:message];
    }
    else if ([status isEqualToString:TS_RIDER_CANCEL]||[status isEqualToString:TS_RIDER_CANCEL_CANCEL]){
        //        [self riderCancelAtPickup];
        [APP_DELEGATE stopRequestSound];
        [self showAlertWithOk:@"" message:message handler:^(UIAlertAction * _Nonnull action) {
            [self riderCancelAtPickup:YES];
            //            self.btnViewSentOffer.hidden=NO;
            //            self.hidden=NO;
            [self removerWatTimer];
            [self removeTripDetailsTimer ];
            self->isRiderCancelCalledNoti=YES;
            [self.offLineView setHidden:YES];
            [self->singleRequestView removeFromSuperview];
            self->singleRequestView=nil;
            //            [self stopLocationUpdate];
            //            HomeViewController * vcHome=[self.storyboard instantiateViewControllerWithIdentifier:@"HomeViewController"];
            //            [[NSUserDefaults standardUserDefaults] setObject:@(NO)  forKey:P_IS_SINGLE_MODE];
            //            [[NSUserDefaults standardUserDefaults]synchronize];
            //            [self.navigationController setViewControllers:@[vcHome] animated:YES];
        }];
    }else if ([status isEqualToString:TS_ACCEPTED]){
        if(homeDataModel==nil){
            homeDataModel=[[HomeDataModel alloc] init];
        }
        TripModel * currTrip=[[TripModel alloc] init];
        currTrip.trip_Id=[dicAps objectForKey:@"trip_id"];
        homeDataModel.trip=currTrip;
        [self.navigationController popToRootViewControllerAnimated:YES];
        [self gettripDetails:status];
    }
}

-(void)  getTripOnNotification :(NSDictionary *) dict  isShowLoderErrorAlert:(BOOL) isShowLoderErrorAlert
{
    
    [GIC mkwu:TRIP_GETTRIP
            d:dict
          isa:isShowLoderErrorAlert
           cb:^(id results, NSError *error) {
        self->apiCallAttempt++;
        if ([[[results objectForKey:P_STATUS] uppercaseString] isEqualToString:@"OK"] && [[results objectForKey:P_RESPONSE] isKindOfClass:[NSArray class]]) {
            // success
            
            TripModel *trip = [[TripModel alloc] initItemWithDict:[[results objectForKey:P_RESPONSE]objectAtIndex:0]];
            [self->homeDataModel setTripModel:trip];
            
            if([self->homeDataModel.trip.trip_Status isEqualToString:TS_REQUEST])
            {
                [self.navigationController popToRootViewControllerAnimated:NO];
            }
            
        }
        else{
            if(self->apiCallAttempt<3)
            {
                [self getTripOnNotification:dict isShowLoderErrorAlert:self->apiCallAttempt==2];
            }
        }
    }];
}


/**
 Calla la alarma y cierra el aviso cuando la lista confirmada viene vacia.

 POR QUE HACE FALTA. El push no lo decide el servidor: la app del pasajero le pasa los tokens
 y el servidor se limita a mandarlos. Y la app del pasajero elige con la lista de cercanos,
 que el servidor calcula contra una coordenada que puede no ser la del conductor: en
 DriverModel::getNearByDriverList se llama a override() ANTES de medir, y override() copia
 u_lat/u_lng encima de d_lat/d_lng. Mientras la app del conductor manda posicion las dos
 columnas van iguales, pero si deja de mandarla y sigue marcado disponible, u_lat se queda con
 lo ultimo que escribio el lado pasajero -- incluido el pin de recogida, que graba ese mismo
 endpoint. Medido el 2026-09-24: el conductor 816, disponible y verificado, con las dos
 columnas a 21,49 km una de otra.

 Desde la app del pasajero eso no se puede ver: recibe la coordenada ya sustituida. Pero AQUI
 si, porque getrevisedtrips se mide desde el lat/lng que manda esta misma app, o sea la
 posicion de verdad. La lista propia es fiable; el push no. Asi que manda la lista.

 No se puede quitar el globo del sistema cuando el telefono esta en segundo plano -- eso lo
 pinta iOS con lo que trae el push y no hay como retirarlo desde aqui. Lo que si se quita es
 la alarma dentro de la app y el aviso con el boton Ver, que es lo que el conductor tiene
 delante mientras trabaja.
 */
- (void)callarSiNoHaySolicitudes {
    if (arrPendingTrips.count > 0) {
        return;
    }
    [APP_DELEGATE stopRequestSound];
    if (_ndAvisoDeSolicitudDelPush != nil) {
        UIAlertController *aviso = _ndAvisoDeSolicitudDelPush;
        _ndAvisoDeSolicitudDelPush = nil;
        NSLog(@"[RadioDeReparto] llego un push de solicitud y la lista propia vino vacia: "
              @"ninguna recogida esta dentro del tope. Se calla la alarma.");
        dispatch_async(dispatch_get_main_queue(), ^{
            [aviso dismissViewControllerAnimated:YES completion:nil];
        });
    }
}

-(void ) handleNewRequestNotification:(NSString *)tripId message:(NSString *)message{
    __weak typeof(self) wselfAviso = self;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@""
                                                                             message:isEmpty(message)                                                                         preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *actionOkCancel = [UIAlertAction actionWithTitle:[LanguageHelper getStringWithKey:@"k_30_s6_cancel_j"]
                                                             style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * _Nonnull action) {
        [APP_DELEGATE stopRequestSound];
        [wselfAviso limpiarElAvisoDelPush];
    }];
    [alertController addAction:actionOkCancel];
    _ndAvisoDeSolicitudDelPush = alertController;
    __weak typeof(self) wself = self;
    UIAlertAction *actionOk = [UIAlertAction actionWithTitle:NSLocalizedString(@"View", @"")
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {
        [wself stopLocationUpdate];
        [APP_DELEGATE stopRequestSound];
        [wself limpiarElAvisoDelPush];
        HomeViewController *home = wself;
        if (!home) return;
        UINavigationController *nav = home.navigationController;
        NSArray *stack = nav.viewControllers;
        HomeViewController *existingHome = nil;
        for (UIViewController *vc in stack) {
            if ([vc isKindOfClass:[HomeViewController class]]) {
                existingHome = (HomeViewController *)vc;
                break;
            }
        }
        if (existingHome && existingHome != home) {
            existingHome->_ndPendingNotificationTripId = [tripId copy];
            [nav popToViewController:existingHome animated:YES];
            [existingHome getAllPendingTrips:NO];
        } else if (existingHome == home) {
            _ndPendingNotificationTripId = [tripId copy];
            [nav popToViewController:home animated:YES];
            [home getAllPendingTrips:NO];
        } else {
            HomeViewController *vcHome = [home.storyboard instantiateViewControllerWithIdentifier:@"HomeViewController"];
            vcHome->_ndPendingNotificationTripId = [tripId copy];
            [[NSUserDefaults standardUserDefaults] setObject:@(NO) forKey:P_IS_SINGLE_MODE];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [nav setViewControllers:@[vcHome] animated:YES];
            [vcHome getAllPendingTrips:NO];
        }
    }];
    [alertController addAction:actionOk];
    UIViewController * viewController=[self.navigationController topViewController];
    if(![viewController isKindOfClass:[HomeViewController class]]) {
        [self.navigationController.topViewController presentViewController:alertController animated:YES completion:^{
            /*
             La lista se pide una vez el aviso ya esta en pantalla, no antes: si se pidiera
             primero y contestara rapido, la respuesta llegaria cuando todavia no hay nada que
             cerrar y el aviso se quedaria puesto.

             El push no dice donde es la recogida, asi que esto es lo unico que lo comprueba:
             getrevisedtrips se mide desde la posicion que manda esta misma app.
             */
            [self getAllPendingTrips:NO];
        }];
    }
}

/// Suelta el aviso del push cuando el conductor ya ha decidido, para no cerrar uno ajeno luego.
- (void)limpiarElAvisoDelPush {
    _ndAvisoDeSolicitudDelPush = nil;
}
- (void)refreshTripStatusRefresh:(NSString *) tripId tripStatus:(NSString *)tripStatus{
    [self gettripDetails:driverStatus];
}

-(void)gettripDetails:(NSString *)status{
    NSDictionary *dict1 = [[NSUserDefaults standardUserDefaults]objectForKey:P_USER_DICT];
    if(dict1==nil){
        return;
    }
    NSString *driverId=[dict1 objectForKey:P_DRIVER_ID];
    if([driverId intValue]==0){
        return;
    }
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{
        P_DRIVER_ID          :[dict1 objectForKey:P_DRIVER_ID],
    }];
    [UtilityClass setLH:NO wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
    [GIC mkwerwu:GET_PENDING_TRIP
               d:dict
              cb:^(id results, NSError *error) {
        self->apiCounter++;
        self->isGetTripAppicalled=YES;
        [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
        if([[results objectForKey:@"status"] isEqualToString:@"OK"]){
            if ([[results objectForKey:P_RESPONSE] isKindOfClass:[NSArray class]]) {
                NSArray * tripArray = [results objectForKey:P_RESPONSE];
                if (tripArray.count>0) {
                    NSDictionary * dictForTrip=nil;
                    NSString * tripIdOld=defaults_object(TRIP_ID);
                    if(tripIdOld!=nil) {
                        for (NSDictionary *dictTrip in tripArray) {
                            if(![[dictTrip objectForKey:TRIP_STATUS] isEqualToString:TS_RIDER_CANCEL_CANCEL]) {
                                self->isRiderCancelCalledNoti=NO;
                                if([tripIdOld isEqualToString:[dictTrip objectForKey:@"trip_id"]]) {
                                    dictForTrip=dictTrip;
                                    break;
                                }
                            }
                        }
                    }
                    
                    if(dictForTrip==nil) {
                        for (NSDictionary *dictTrip in tripArray) {
                            if(![[dictTrip objectForKey:TRIP_STATUS] isEqualToString:TS_RIDER_CANCEL_CANCEL]) {
                                self->isRiderCancelCalledNoti=NO;
                                dictForTrip=dictTrip;
                                break;
                            }
                        }
                    }
                    if(dictForTrip== nil) {
                        self.btnShareRides.hidden=YES;
                        defaults_remove(M_TRIP_ID);
                        defaults_remove(TRIP_ID);
                        [self onLeftSwicthChnage];
                        homeDataModel.trip=nil;
                        [self checkDemoAndTripDemo];
                        return ;
                    }
                    TripModel *trip = [[TripModel alloc] initItemWithDict:[dictForTrip mutableCopy]];
                    [self->homeDataModel setTripModel:trip];
                    defaults_set_object(TRIP_ID, self->homeDataModel.trip.trip_Id);
                    if(self->homeDataModel.trip.is_share){
                        if(self->homeDataModel.trip.m_trip_id){
                            defaults_set_object(M_TRIP_ID, self->homeDataModel.trip.m_trip_id);
                            [self getMasterTrip];
                        }
                    }
                    self.btnGpsTopConstraints.constant =SCREEN_HEIGHT -200;
                    [self.viewRequestBg hideByHeight:YES];
                    [self manageUiWhenDriverAvailablityOFF ];
                    if ([self->homeDataModel.trip.trip_Status isEqualToString:TS_ACCEPTED]) {
                        self.offLineView.hidden=YES;
                        self.viewSentOffer.hidden = NO;
                        self.btnDirection.hidden=NO;
                        if(self->homeDataModel.trip.is_share){
                            self.btnShareRides.hidden=NO;
                            [[UpdateUserCurrentLocation sharedInstance]  updateDriverAvailablity:@"2"];
                        }else {
                            self.btnShareRides.hidden=YES;
                            [[UpdateUserCurrentLocation sharedInstance]  updateDriverAvailablity:@"0"];
                        }
                        defaults_remove(@"wait_time_start");
                        [[DataBase shareDataBase] deleteWatingForAllTripID];
                        [self startMotionDetection];
                        self->driverStatus =TS_ACCEPTED;
                        self.goPopUpView.hidden=NO;
                        defaults_set_object(DRIVER_STATUS, self->driverStatus);
                        [self handleAddressTopFixed];
                        self.goPopUpView.hidden=NO;
                        [self drawroute:YES isAccept:NO isDivert:NO];
                        self->isRiderCancelCalled =NO;
                        [self getTripDetails];
                        [self showAndSetDataOnUiForUserInfo];
                    }
                    else if([self->homeDataModel.trip.trip_Status isEqualToString:TS_ARRIVE]){
                        self.viewSentOffer.hidden = NO;
                        self.offLineView.hidden=YES;
                        self.btnDirection.hidden=NO;
                        if(self->homeDataModel.trip.is_share){
                            self.btnShareRides.hidden=NO;
                            [[UpdateUserCurrentLocation sharedInstance]  updateDriverAvailablity:@"2"];
                        }else {
                            self.btnShareRides.hidden=YES;
                            [[UpdateUserCurrentLocation sharedInstance]  updateDriverAvailablity:@"0"];
                        }
                        defaults_remove(@"wait_time_start");
                        self->driverStatus = TS_ARRIVE;
                        defaults_set_object(DRIVER_STATUS, self->driverStatus);
                        NSString *localTripStatus=defaults_object(DRIVER_STATUS_TEMP);
                        if(localTripStatus!=nil &&[localTripStatus isEqualToString:TS_PICKED])  {
                            [self startMotionDetection];
                            self->driverStatus = TS_PICKED;
                            defaults_set_object(DRIVER_STATUS, self->driverStatus);
                            self.acceptDeclineView.hidden=YES;
                            self.btnBeginTrip.hidden=NO;
                            [self.btnAccept setTitle:[LanguageHelper getStringWithKey:@"k_21_s4_yes"] forState:UIControlStateNormal];
                            [self.btnDecline setTitle:[LanguageHelper getStringWithKey:@"k_22_s4_no"] forState:UIControlStateNormal];
                            self.lblAcceptTitle.text =[LanguageHelper getStringWithKey:@"k_23_s4_client_picked_up"];
                            [self drawroute:NO isAccept:NO isDivert:NO];
                            [self removerWatTimer];
                        }else {
                            if(self->homeDataModel.trip.is_share){
                                self.btnShareRides.hidden=NO;
                            }else{
                                self.btnShareRides.hidden=YES;
                            }
                            [self startMotionDetection];
                            self.goPopUpView.hidden=NO;
                            [self.btnGoPopUP setTitle:[LanguageHelper getStringWithKey:@"k_19_s4_arrived" defaultValue:@"He llegado!"] forState:UIControlStateNormal];
                            UIImage *msgIcon = [UIImage imageNamed:@"ic_message_bubble"];
                            if (msgIcon) {
                                [self.btnGoPopUP setImage:[msgIcon imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
                                self.btnGoPopUP.semanticContentAttribute = UISemanticContentAttributeForceRightToLeft;
                            }
                            [self drawroute:YES isAccept:NO isDivert:NO];
                            self->isRiderCancelCalled =NO;
                            [self getTripDetails];
                            [self showAndSetDataOnUiForUserInfo];
                            [self showWaitingTimer];
                        }
                        [self handleAddressTopFixed];
                        //Firebase
                    }
                    else if ([self->homeDataModel.trip.trip_Status isEqualToString:TS_BEGIN]){
                        self.offLineView.hidden=YES;
                        self.viewSentOffer.hidden = NO;
                        self.btnDirection.hidden=NO;
                        if(self->homeDataModel.trip.is_share){
                            self.btnShareRides.hidden=NO;
                            [[UpdateUserCurrentLocation sharedInstance]  updateDriverAvailablity:@"2"];
                        }else
                        {
                            self.btnShareRides.hidden=YES;
                            [[UpdateUserCurrentLocation sharedInstance]  updateDriverAvailablity:@"0"];
                        }
                        [self startMotionDetection];
                        self->driverStatus = TS_BEGIN;
                        defaults_set_object(DRIVER_STATUS, self->driverStatus);
                        [self.btnBeginTrip setTitle:[LanguageHelper getStringWithKey:@"k_34_s4_end_ride"] forState:UIControlStateNormal]; NSString *str1 = [LanguageHelper getStringWithKey:@"k_34_s4_end_ride"];
                        [self.btnBeginTrip setTitle:str1 forState:UIControlStateNormal];
                        self.btnBeginTrip.hidden=NO;
                        [self.btnAccept setTitle:[LanguageHelper getStringWithKey:@"k_21_s4_yes"] forState:UIControlStateNormal];
                        [self.btnDecline setTitle:[LanguageHelper getStringWithKey:@"k_22_s4_no"] forState:UIControlStateNormal];
                        self.lblAcceptTitle.text =[LanguageHelper getStringWithKey:@"k_24_s4_client_reached_dest"];
                        [self drawroute:NO isAccept:NO isDivert:NO];
                        [self hideUserInfo];
                        [self handleAddressTopFixed];
                        [self removerWatTimer];
                        self.btnBeginTrip.hidden = YES;
                        [self ndShowOnTripPanel];
                    }
                    else if ([self->homeDataModel.trip.trip_Status isEqualToString:TS_END]) {
                        self.viewSentOffer.hidden=YES;
                        self.btnDirection.hidden=YES;
                        self.btnShareRides.hidden=YES;
                        defaults_remove(@"wait_time_start");
                        defaults_remove(@"cal_wait_time");
                        defaults_remove(DRIVER_STATUS_TEMP);
                        self.viewOtpVerify.hidden=YES;
                        [self performSegueWithIdentifier:StoryBoardUtiles.FARE_AMOUNT_VC sender:nil];
                        [self removerWatTimer];
                    }
                    else if ([self->homeDataModel.trip.trip_Status isEqualToString:TS_RIDER_CANCEL] || [self->homeDataModel.trip.trip_Status isEqualToString:TS_EXPIRED]||[self->homeDataModel.trip.trip_Status isEqualToString:TS_RIDER_CANCEL_CANCEL] ||[self->homeDataModel.trip.trip_Status isEqualToString:TS_DRIVER_CANCEL_AT_PICKUP]||[self->homeDataModel.trip.trip_Status isEqualToString:TS_DRIVER_CANCEL_AT_DROP] ){
                        [self handleGetPendingsErrorOrEmptyTripWithOnavailableOn];
                    }else{
                        [self handleGetPendingsErrorOrEmptyTripWithOnavailableOn];
                    }
                    
                }else
                {
                    [self handleGetPendingsErrorOrEmptyTripWithOnavailableOn];
                }
                [self manageCancelRideButton];
            }else
            {
                defaults_remove(TRIP_ID);
                [self handleGetPendingsErrorOrEmptyTripWithOnavailableOn];
            }
        }
        else{
            if(error == nil){
                [self hideAndShowReqestView];
                [self clearAllTripReleatedData];
                [self hideAndShowOffLineMessageView];
            }else {
                if (self->apiCounter<3) {
                    [self gettripDetails:status];
                }
                else{
                    [self hideAndShowReqestView];
                    [self clearAllTripReleatedData];
                    [self hideAndShowOffLineMessageView];
                }
            }
        }
    }];
}






-(void) showAndSetDataOnUiForUserInfo
{
    
    
    
    
    
    [self setUpChatUnreadCount];
    NSString *profile=  self->homeDataModel.trip.user.u_profile_image_path;
    
    if (profile.length>0) {
        
        [self.imRiderProfile sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",url_base_images, profile]] placeholderImage:[UIImage imageNamed:@"Profile Icon Crop Image"]];
    }else
    {
        [self.imRiderProfile  setImage:[UIImage imageNamed:@"Profile Icon Crop Image"]];
    }
    
    self.lbRiderName.text=[NSString stringWithFormat:@"%@ %@", self->homeDataModel.trip.user.u_fname,self->homeDataModel.trip.user.u_lname];
    //    if(self->homeDataModel.trip.user.rating_count==0)
    //    {
    //        self.lbRating.text=[NSString stringWithFormat:@"%d",self->homeDataModel.trip.user.rating_count];
    //        [self.viewRatingContainer  setHidden:NO];
    //    }else
    //    {
    //        [self.viewRatingContainer  setHidden:YES];
    //    }
    
    if(homeDataModel.trip.trip_customer_details.length>0) {
        self.viewPassengerDetails.hidden=NO;
    }else
    {
        self.viewPassengerDetails.hidden=YES;
    }
    [self.viewUserInfo setConstraintConstant:80 forAttribute:NSLayoutAttributeHeight];

    if (_ndTripInfoCard) {
        [self ndUpdateTripInfoCard];
        _ndTripInfoCard.hidden = NO;
        [self.view bringSubviewToFront:_ndTripInfoCard];
        if (self.btnmenu.superview.superview) [self.view bringSubviewToFront:self.btnmenu.superview.superview];
        if (_ndStatusPillContainer) [self.view bringSubviewToFront:_ndStatusPillContainer];
        // Suppress old storyboard views that re-show during trip state changes
        self.viewPassengerDetails.hidden = YES;
        self.lblPaymentStatus.hidden = YES;
        self.viewUserInfo.hidden = YES;
        self.addressViewTop.hidden = YES;
    }
    
    if([[ConstantModel getConstantsObject] getCValueFK:ckey_epp]){
        BOOL isPrePaid = [homeDataModel.trip.trip_pay_mode isEqualToString:CARD]&&homeDataModel.trip.payment_card_id.length>0;
        if(isPrePaid){
            [self.lblPaymentStatus setText:[LanguageHelper getStringWithKey:@"k_4_s21_paid"]  ];
            self.lblPaymentStatus.backgroundColor = [UIColor colorNamed:@"color_trip_paid"];
        }else{
            [self.lblPaymentStatus setText:[LanguageHelper getStringWithKey:@"k_4_s21_not_paid"]  ];
            self.lblPaymentStatus.backgroundColor = [UIColor colorNamed:@"color_trip_not_paid"];
        }
        self.lblPaymentStatus.layer.cornerRadius = 15;
        self.lblPaymentStatus.clipsToBounds = YES;
        self.lblPaymentStatus.hidden = NO;
    }else{
        self.lblPaymentStatus.hidden = YES;
    }
}


-(void) hideUserInfo
{
    [ _firebaseUnReadChat stopObserverForCount];
    _firebaseUnReadChat=nil;
    [self.viewUserInfo setConstraintConstant:0 forAttribute:NSLayoutAttributeHeight];

    if (_ndTripInfoCard) {
        _ndTripInfoCard.hidden = YES;
    }

    if (_ndOnTripPanel) {
        _ndOnTripPanel.hidden = YES;
    }
}




-(void)drawroute:(BOOL)isPick isAccept:(BOOL)accept isDivert:(BOOL)isDivert{
    AppDelegate *appdelegate =APP_DELEGATE;
    sourcePoint=[[CLLocation alloc]   initWithLatitude:appdelegate.currLoc.coordinate.latitude  longitude:appdelegate.currLoc.coordinate.longitude];
    
    if([homeDataModel.trip.trip_Status isEqualToString:TS_BEGIN]||[homeDataModel.trip.trip_Status isEqualToString:TS_ARRIVE]){
        NSString *localTripStatus=defaults_object(DRIVER_STATUS_TEMP);
        if([homeDataModel.trip.trip_Status isEqualToString:TS_ARRIVE]){
            if(localTripStatus!=nil &&[localTripStatus isEqualToString:TS_PICKED]) {
                destPoint=[[CLLocation alloc]  initWithLatitude:[homeDataModel.trip.trip_drop_lat doubleValue] longitude:[homeDataModel.trip.trip_drop_long doubleValue]];
            }else{
                destPoint=[[CLLocation alloc]  initWithLatitude:[homeDataModel.trip.trip_pick_lat doubleValue] longitude:[homeDataModel.trip.trip_pick_long doubleValue]];
            }
        }else{
            destPoint=[[CLLocation alloc]  initWithLatitude:[homeDataModel.trip.trip_drop_lat doubleValue] longitude:[homeDataModel.trip.trip_drop_long doubleValue]];
        }
        
        if([homeDataModel.trip isTripDropLocationOptional]){
            [self clearMapView:YES];
            return;
        }else{
            [self clearMapView:NO];
        }
    }else{
        [self clearMapView:NO];
        destPoint=[[CLLocation alloc]  initWithLatitude:[homeDataModel.trip.trip_pick_lat doubleValue] longitude:[homeDataModel.trip.trip_pick_long doubleValue]];
    }
    
    
    GoogleDirectionSource * userDriverLocationRoute=[[GoogleDirectionSource alloc]  initWithSource:sourcePoint destination:destPoint];
    float distance=[destPoint distanceFromLocation:[APP_DELEGATE currLoc]];
    if(distance<=100){
        [self zoomToFitMapAnnotationsWith:userDriverLocationRoute isDiverted:isDivert];
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance([APP_DELEGATE currLoc].coordinate, 600, 600);
        CLLocation *loc = [[CLLocation alloc] initWithLatitude:appdelegate.currLoc.coordinate.latitude longitude:appdelegate.currLoc.coordinate.longitude];
        [self setDriverPin:loc];
        if(currentHeading>0) {
            _mapView.camera.heading=currentHeading;
            [self.mapView setCamera:_mapView.camera animated:NO];
        }
        [self mapRegion:region mapView:self.mapView];
        return;
    }
    [userDriverLocationRoute findDirection_isInTrip:NO WithCompletionBlock:^(id results, NSError *error) {
        if([results isKindOfClass:[DirectionModel class]])  {
            DirectionModel  *dModel=(DirectionModel *)results;
            self->dModelOldRoute=dModel;
            if (isPick) {
                CityModel * cModel=[CityModel getCityByCityId:self->homeDataModel.trip.city_id];
                NSString *dis;
                NSString *tripDis;
                if (isDistanceUnitKm(cModel.city_dist_unit)/*[[constantModel.constant_distance capitalizedString] isEqualToString:@"Km"]*/) {
                    dis =cModel.city_dist_unit;
                    tripDis = [NSString stringWithFormat:@"%.1f",dModel.distance];
                }
                else{
                    dis =cModel.city_dist_unit;
                    float miles = KM_TO_MI(dModel.distance) ;
                    tripDis = [NSString stringWithFormat:@"%.1f", miles];
                }
            }
            [self.mapView addOverlay:[dModel getPolyline] level:MKOverlayLevelAboveRoads];
            self->isDiverted =NO;
            MKPointAnnotation *point1 = [[MKPointAnnotation alloc]init];
            point1.coordinate = dModel.northeast.coordinate;
            MKPointAnnotation *point2 = [[MKPointAnnotation alloc]init];
            point2.coordinate = dModel.southwest.coordinate;
            NSMutableArray *arrAnn = [[NSMutableArray alloc]initWithObjects:point1,point2, nil];
            [self zoomToFitMapAnnotations:arrAnn];
            [self zoomToFitMapAnnotationsWith:userDriverLocationRoute isDiverted:isDivert];
            if([self->homeDataModel.trip.trip_Status isEqualToString:TS_BEGIN]||[self->homeDataModel.trip.trip_Status isEqualToString:TS_ARRIVE]){
                NSString *localTripStatus=defaults_object(DRIVER_STATUS_TEMP);
                if([self->homeDataModel.trip.trip_Status isEqualToString:TS_ARRIVE]){
                    if(localTripStatus!=nil &&[localTripStatus isEqualToString:TS_PICKED]) {
                        self->destPoint=[[CLLocation alloc]  initWithLatitude:[self->homeDataModel.trip.trip_drop_lat doubleValue] longitude:[self->homeDataModel.trip.trip_drop_long doubleValue]];
                    }else{
                        [self uploadeBeginRouteOrRouteData:dModel.arrDirectionLatLng isSendNotification:NO];
                    }
                }else{
                    [self uploadeBeginRouteOrRouteData:dModel.arrDirectionLatLng isSendNotification:NO];
                }
            }
        }
        else {
            
        }
    }];
}




#pragma -mark  implenent the code for the update actual pickup location


-(void) fatechActualPickUpLocation
{
    
    [UtilityClass setLH:NO wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
    AppDelegate *appdelegate=APP_DELEGATE;
    CLLocation    *sourcePoint=[[CLLocation alloc]   initWithLatitude:appdelegate.currLoc.coordinate.latitude  longitude:appdelegate.currLoc.coordinate.longitude];
    [Utilities getAddressStrinByLat:sourcePoint.coordinate.latitude longitude:sourcePoint.coordinate.longitude withcompletionHandler:^(NSString *locAddress, NSString *country) {
        [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
        if (locAddress.length) {
            self->actualPickupLocationAddress=locAddress;
            self->StartLocationTaken=FALSE;
            [self updateTripStatus:TS_BEGIN];
        }else
        {
            self->StartLocationTaken=FALSE;
            [self updateTripStatus:TS_BEGIN];
        }
    }];
}

-(void) fatechActualDropLocation
{
    
    [UtilityClass setLH:NO wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
    AppDelegate *appdelegate=APP_DELEGATE;
    CLLocation    *sourcePoint=[[CLLocation alloc]   initWithLatitude:appdelegate.currLoc.coordinate.latitude  longitude:appdelegate.currLoc.coordinate.longitude];
    [Utilities getAddressStrinByLat:sourcePoint.coordinate.latitude longitude:sourcePoint.coordinate.longitude withcompletionHandler:^(NSString *locAddress, NSString *country) {
        [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
        if (locAddress) {
            self->actualDropLocationAddress=locAddress;
            CLLocation    *pickPoint=[[CLLocation alloc]   initWithLatitude:self->homeDataModel.trip.trip_actual_pick_lat  longitude:self->homeDataModel.trip.trip_actual_pick_lng];
            [self calculateDistacneBetweenSourceAndDestination:pickPoint locationDestination:sourcePoint completionBlock:^(id results, NSError *error) {
                NSMutableDictionary * dict=(NSMutableDictionary *)results;
                float distanceDistance=[[dict objectForKey:@"cal_distacne" ] floatValue];
                
                if(self->actualDropLocationAddress.length>0)
                {
                    self->homeDataModel.trip.actual_to_loc=self->actualDropLocationAddress;
                    
                }
                if(self->TotalTripDIstance<distanceDistance)
                {
                    self->TotalTripDIstance=distanceDistance;
                }
                [self updateTripStatusEnd];
            } isShowLoader:YES];
        }else
        {
            [self updateTripStatusEnd];
        }
    }];
    
    
    
    
}




-(void) updateTripStatusEnd{
    NSString * dropTime = [NSString stringWithFormat:@"%@",[Utilities getStringFromDate:[NSDate date]]];
    [self saveTripLogFor:TS_END timeAt:dropTime];
    [dataUploadHelper saveCoverRouteOnServerForTripId:homeDataModel.trip.trip_Id completionBlock:^(id  _Nonnull results, NSError * _Nonnull error) {
        if(error!=nil){
            [Utilities handleError:error viewController:self defaultMessage:@""];
            return;
        }
        [self updateTripStatus:TS_END];
    }];
}



-(void) fatechActualDropLocationOnCancel
{
    
    [UtilityClass setLH:NO wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
    AppDelegate *appdelegate=APP_DELEGATE;
    CLLocation    *sourcePoint=[[CLLocation alloc]   initWithLatitude:appdelegate.currLoc.coordinate.latitude  longitude:appdelegate.currLoc.coordinate.longitude];
    [Utilities getAddressStrinByLat:sourcePoint.coordinate.latitude longitude:sourcePoint.coordinate.longitude withcompletionHandler:^(NSString *locAddress, NSString *country) {
        [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
        if (locAddress.length>0) {
            self->actualDropLocationAddress=locAddress;
            CLLocation    *pickPoint=[[CLLocation alloc]   initWithLatitude:self->homeDataModel.trip.trip_actual_pick_lat  longitude:self->homeDataModel.trip.trip_actual_pick_lng];
            [self calculateDistacneBetweenSourceAndDestination:pickPoint locationDestination:sourcePoint completionBlock:^(id results, NSError *error) {
                [results objectForKey:@"cal_distacne"];
                NSMutableDictionary * dict=(NSMutableDictionary *)results;
                float distanceDistance=[[dict objectForKey:@"cal_distacne" ] floatValue];
                if(self->TotalTripDIstance<distanceDistance)
                {
                    self->TotalTripDIstance=distanceDistance;
                }
                [self updateTripStatusCancelAtDrop];
            } isShowLoader:YES];
        }else
        {
            [self updateTripStatusCancelAtDrop];
        }
    }];
}



-(void) updateTripStatusCancelAtDrop{
    // wait data save with coverRoute data
    NSString * dropTime = [NSString stringWithFormat:@"%@",[Utilities getStringFromDate:[NSDate date]]];
    [self saveTripLogFor:TS_DRIVER_CANCEL_AT_DROP timeAt:dropTime];
    [dataUploadHelper saveCoverRouteOnServerForTripId:self->homeDataModel.trip.trip_Id completionBlock:^(id  _Nonnull results, NSError * _Nonnull error) {
        if(error!=nil){
            [Utilities handleError:error viewController:self defaultMessage:@""];
            return;
        }
        [self updateTripStatus:TS_DRIVER_CANCEL_AT_DROP];
    }];
    
}

-(void)updateTripStatus:(NSString *)status{
    NSDictionary *dict1 = [[NSUserDefaults standardUserDefaults]objectForKey:P_USER_DICT];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{
        P_DRIVER_ID         : isEmpty([dict1 objectForKey:P_DRIVER_ID]),
        TRIP_STATUS         : status ?: @"",
        TRIP_ID             : isEmpty(homeDataModel.trip.trip_Id),
    }];
    if ([status isEqualToString:TS_DRIVER_CANCEL_AT_DROP] ) {
        [dict setObject:reasonString forKey:TRIP_REASON];
        NSMutableDictionary *dictEnd= [homeDataModel prepareDataForEnd:actualDropLocationAddress TotalTripDIstance:TotalTripDIstance promoCode:promoCode];
        [dict addEntriesFromDictionary:dictEnd];
        [dict setObject:@"Drop" forKey:@"trip_cancel"];
    }
    else if ([status isEqualToString:TS_DRIVER_CANCEL_AT_PICKUP]){
        NSMutableDictionary *dictEnd= [homeDataModel prepareDataForDriverCancelAtPickUp:reasonString ];
        [dict addEntriesFromDictionary:dictEnd];
        if(reasonStringType){
            [dict setObject:isEmpty(reasonStringType) forKey:@"can_fee_by"];
        }else{
            [dict setObject:@"r" forKey:@"can_fee_by"];
        }
        [dict setObject:@"Pick" forKey:@"trip_cancel"];
    }
    else if ([status isEqualToString:TS_END]){
        NSMutableDictionary *dictEnd= [homeDataModel prepareDataForEnd:actualDropLocationAddress TotalTripDIstance:TotalTripDIstance promoCode:promoCode];
        [dict addEntriesFromDictionary:dictEnd];
    }
    else if ([status isEqualToString:TS_BEGIN]) {
        NSMutableDictionary *dictBegin=[homeDataModel prepareDataForBegin:actualPickupLocationAddress];
        [dict addEntriesFromDictionary:dictBegin];
    }
    if([ConstantModel getConstantsObject].otp_start){
        if([status isEqualToString:TS_ARRIVE]){
            //            [dict  setObject:[self getRandomPINString:5] forKey:@"otp"];
        }
    }
    if([status isEqualToString:TS_ARRIVE]){
        NSString *tm_arr = [NSString stringWithFormat:@"%@",[Utilities getStringFromDate:[NSDate date]]];
        [dict  setObject:tm_arr forKey:@"tm_arr"];
    }
    
    [UtilityClass setLH:NO wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
    [GIC mkwerwu:TRIP_UPDATE d:dict
              cb:^(id results, NSError *error) {
        if(error!=nil){
            [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
            [Utilities handleError:error viewController:self defaultMessage:@"Internet Error"];
            return;
        }
        if ([[[results objectForKey:P_STATUS] uppercaseString] isEqualToString:@"OK"]) {
            
            if ([status isEqualToString:TS_ARRIVE]) {
                [self saveTripLogFor:TS_ARRIVE timeAt:[dict objectForKey:@"tm_arr"]];
                [self->homeDataModel.trip setTm_arr:[dict objectForKey:@"tm_arr"]];
                [self handleArriveNowState];
                [self showAndSetDataOnUiForUserInfo];
                [self showWaitingTimer];
            }
            else if ([status isEqualToString:TS_BEGIN]){
                [self->homeDataModel updateLocalAfterUpdateBegin:dict];
                self->homeDataModel.trip.trip_Status=TS_BEGIN;
                self->driverStatus = TS_BEGIN;
                defaults_set_object(DRIVER_STATUS, self->driverStatus);
                NSString *str1 = [LanguageHelper getStringWithKey:@"k_34_s4_end_ride"];
                [self.btnBeginTrip setTitle:str1 forState:UIControlStateNormal];
                defaults_set_object(@"begin_date", [NSDate date]);
                [self->homeDataModel sendNotification:TS_BEGIN];
                [self handleAddressTopFixed];
                //                [self hideUserInfo];
                [self removerWatTimer];
                [self drawroute:NO isAccept:NO isDivert:NO];
                [self ndShowOnTripPanel];
            }
            else if ([status isEqualToString:TS_END]){
                defaults_remove(@"wait_time_start");
                defaults_remove(@"cal_wait_time");
                defaults_remove(DRIVER_STATUS_TEMP);
                [self->homeDataModel updateLocalAfterUpdateEnd:dict];
                [self handleEndTrip];
                [self removerWatTimer];
            }
            
            else if ([status isEqualToString:TS_DRIVER_CANCEL_AT_PICKUP]){
                defaults_remove(@"wait_time_start");
                defaults_remove(@"cal_wait_time");
                defaults_remove(DRIVER_STATUS_TEMP);
                self->homeDataModel.trip.trip_Status=TS_DRIVER_CANCEL_AT_PICKUP;
                [[UpdateUserCurrentLocation sharedInstance]  updateDriverAvailablity:@"1"];
                [self handleDriverCancel:status];
                
                [self->arrPendingTrips removeAllObjects];
                [self.tableViewPendingTrips reloadData];
                if (_ndCollectionView) { dispatch_async(dispatch_get_main_queue(), ^{ [self->_ndCollectionView reloadData]; NSInteger _ndCount = self->arrPendingTrips.count; self->_ndBadgeLabel.hidden = (_ndCount == 0); self->_ndBadgeLabel.text = [NSString stringWithFormat:@"%ld", (long)_ndCount]; }); }
                [self getAllPendingTrips:YES];
                [self removerWatTimer];
                //Firebase
                
            }
            else if ([status isEqualToString:TS_DRIVER_CANCEL_AT_DROP]){
                defaults_remove(@"wait_time_start");
                defaults_remove(DRIVER_STATUS_TEMP);
                self->homeDataModel.trip.trip_Status=TS_DRIVER_CANCEL_AT_DROP;
                [self->homeDataModel updateLocalAfterUpdateEnd:dict];
                [self handleDriverCancel:status];
                [self removerWatTimer];
            }else{
                self->homeDataModel.trip.trip_Status=status;
                
            }
            [self manageCancelRideButton];
            [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
        }
        else {
            
            [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
            [self showAlertWithMessgae:[results objectForKey:P_MESSAGE]];
        }
        
        
        
    }];
}


-(long) getTotalWaitTimeLeftFree
{
    
    long watiTime=0;
    
    NSString *startTimeString=defaults_object(@"wait_time_start");
    if(startTimeString)
    {
        NSDateFormatter * df=[[NSDateFormatter alloc] init];
        [df setDateFormat:SAVE_DATE_FORMAT];
        NSDate * dateStart=[df dateFromString:startTimeString];
        NSDate * currentDate=[NSDate date];
        long diff=[currentDate timeIntervalSince1970]-[dateStart timeIntervalSince1970];
        long watiTimeTemp=0;
        NSString *calTime=defaults_object(@"cal_wait_time");
        if(calTime!=nil)
        {
            watiTimeTemp= [calTime intValue];
        }
        if(diff%60>0)
        {
            watiTime= 1+watiTimeTemp+diff/60;
        }else
        {
            watiTime= watiTimeTemp+diff/60;
        }
        
    }else
    {
        NSString *calTime=defaults_object(@"cal_wait_time");
        if(calTime!=nil)
        {
            watiTime= [calTime intValue];
        }
    }
    
    if(watiTime>homeDataModel.category.wait_free_min)
    {
        watiTime=watiTime-homeDataModel.category.wait_free_min;
    }else
    {
        watiTime=0;
    }
    
    return watiTime;
}


#pragma API CALLS

-(UIImage *)localVehicleIconImage {
    NSDictionary *dict1 = [[NSUserDefaults standardUserDefaults] objectForKey:P_USER_DICT];
    CategoryModel *category = [CategoryModel getCategoryByid:[[dict1 objectForKey:P_CATEGORY_ID] intValue]];
    NSString *name = [category.cat_name lowercaseString] ?: @"";
    NSString *assetName = [name containsString:@"moto"] ? @"ic_vehicle_moto" : @"ic_vehicle_car";
    return [UIImage imageNamed:assetName] ?: [UIImage imageNamed:@"icon_car_new"];
}

-(void)getCategoryFormServer{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    NSDictionary *dict1 = [[NSUserDefaults standardUserDefaults]objectForKey:P_USER_DICT];
    [dict setObject:@([UserProfile shared].cityID) forKey:P_CITY_ID];
    [GIC mkwu:CAR_GETCATEGORY
            d:dict
          isa:NO
           cb:^(id results, NSError *error) {
        self->apiCallAttempt++;
        if([[[results objectForKey:P_STATUS] uppercaseString]isEqualToString:@"OK"]){
            if([[results objectForKey:P_RESPONSE] isKindOfClass:[NSArray class]]){
                NSMutableArray *arrCat = [[NSMutableArray alloc]initWithArray:[results objectForKey:P_RESPONSE]];
                defaults_set_object(@"categoryResponse", arrCat);
                self->arrayCagetgory=[CategoryModel parseResponse:arrCat];
                CategoryModel *category=  [CategoryModel getCategoryByid:[[dict1 objectForKey:P_CATEGORY_ID] intValue]];
                if(category)  {
                    self->driverPinView.image=[UIHelper imageForMapWithImage:[UIImage imageNamed:@"map_car_icon"]];
                }else{
                    self->driverPinView.image=[UIHelper imageForMapWithImage:[UIImage imageNamed:@"map_car_icon"]];
                }
            }
        }
        else{
            if(self->apiCallAttempt<3){
                [self getCategoryFormServer];
            }
        }
    }];
}


-(void)changeCategoryOnUploadDocument{
    NSDictionary *dict1 = [[NSUserDefaults standardUserDefaults]objectForKey:P_USER_DICT];
    CategoryModel *category=  [CategoryModel getCategoryByid:[[dict1 objectForKey:P_CATEGORY_ID] intValue]];
    self->driverPinView.image=[UIHelper imageForMapWithImage:[UIImage imageNamed:@"map_car_icon"]];
}

-(void)getMasterTrip
{
    NSString * stringMarterTripId= defaults_object(M_TRIP_ID);
    if(stringMarterTripId==nil)
    {
        return;
    }
    [GIC mkwerwu:TRIP_GET_MASTER_TRIP
               d:@{@"is_detail":@"0",@"m_trip_id":stringMarterTripId}
              cb:^(id results, NSError *error) {
        if([[[results objectForKey:P_STATUS] uppercaseString] isEqualToString:@"OK"])
        {
            NSDictionary * masterDict=[results objectForKey:P_RESPONSE];
            if([masterDict isKindOfClass:[NSDictionary class]])
            {
                BOOL isRideShare=[[masterDict objectForKey:@"is_share"] boolValue];
                if(isRideShare)
                {
                    
                    int maxSeat=[[masterDict objectForKey:@"max_seat"] intValue];
                    int n_seat=[[masterDict objectForKey:@"n_seat"] intValue];
                    if(n_seat<maxSeat)
                    {
                        [[UpdateUserCurrentLocation sharedInstance]  updateDriverAvailablity:@"2"];
                    }else
                    {
                        [[UpdateUserCurrentLocation sharedInstance]  updateDriverAvailablity:@"0"];
                    }
                }
            }
        }
    }];
    
}



-(void)getTaxiConstant
{
    defaults_set_object(@"google_key_server", isEmpty([ConstantModel getConstantsObject].gKey));
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"constant_api_called"
     object:nil];
    [self checkAndShowAlertWith];
}







/**
 El boton del ciclo, con los tres pasos que tiene Android.

 ANTES ERAN DOS Y EL PRIMERO SOBRABA UN PASO. El primer toque llamaba ya a
 updateTripStatus:TS_ARRIVE, asi que el conductor decia "voy en camino" y al pasajero le
 constaba que YA HABIA LLEGADO -- con su sonido de cab_arrive -- cuando el coche acababa de
 arrancar. No era el rotulo: era el estado del viaje, adelantado.

 Ahora, igual que fullButtonClickListener en SlideMainActivity:

   1. "Voy en camino!"  el estado NO se toca. Se avisa al pasajero (push + mensaje de chat
                        con el coche y la placa) y el boton pasa al paso siguiente.
   2. "He llegado!"     updateTripStatus:TS_ARRIVE, que es cuando el viaje avanza de verdad.
   3. "Recoger Cliente" handlePick, con el OTP si esta activado.

 El paso 1 se reconoce por su marca, guardada por viaje: sin ella el boton volveria al
 principio en cuanto la pantalla se reconstruyera, que es el sintoma que ya se corrigio una
 vez por el lado del rotulo.
 */
- (IBAction)ButtonGoPressed:(UIButton *)sender {
    NSString *localTripStatus = defaults_object(DRIVER_STATUS_TEMP);
    BOOL isPickedUp = (localTripStatus != nil && [localTripStatus isEqualToString:TS_PICKED]);
    BOOL hasArrived = [driverStatus isEqualToString:TS_ARRIVE] ||
                      [homeDataModel.trip.trip_Status isEqualToString:TS_ARRIVE];
    if (isPickedUp || hasArrived) {
        [self removerWatTimer];
        [self handlePick];
        return;
    }

    NSString *tripId = isEmpty(homeDataModel.trip.trip_Id);
    if (![ConrraVoyEnCamino yaAvisoEnElViaje:tripId]) {
        [ConrraVoyEnCamino avisarDesdeElViaje:homeDataModel.trip];
        [self setUIFiels];
        return;
    }
    [self updateTripStatus:TS_ARRIVE];
}





#pragma mark - MKMapViewDelegate methods

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithPolyline:overlay];
    renderer.strokeColor = [UIColor colorNamed:@"app_theame"];
    renderer.lineWidth = 4.0;
    renderer.lineJoin = kCGLineJoinRound;
    renderer.lineCap = kCGLineCapRound;
    return renderer;
}


#pragma handle driver states

-(void)handleDriverCancel:(NSString *)status{
    
    
    _txtViewMessage.text=@"";
    _viewMessage.hidden=YES;
    
    if ([status isEqualToString:TS_DRIVER_CANCEL_AT_PICKUP]) {
        
        driverStatus = TS_WAITING;
        defaults_set_object(DRIVER_STATUS, driverStatus);
        defaults_remove(TRIP_ID);
        defaults_remove(DRIVER_STATUS_TEMP);
        [self->homeDataModel sendNotification:TS_DRIVER_CANCEL_AT_PICKUP];
        [self.navigationController popViewControllerAnimated:YES];
    }
    else{
        driverStatus = status;
        defaults_set_object(DRIVER_STATUS, driverStatus);
        
        [self->homeDataModel sendNotification:TS_DRIVER_CANCEL_AT_DROP];
        [self performSegueWithIdentifier:StoryBoardUtiles.FARE_AMOUNT_VC sender:nil];
    }
    
    
    [self settoInitialState];
    [self setDriverFree];
    
}

-(void)handlePick{
    _goPopUpView.hidden=YES;
    if ([P_IS_SHOW_EXTRA_POPUP isEqualToString:@"No"]) {
        driverStatus = TS_PICKED;
        defaults_set_object(DRIVER_STATUS, driverStatus);
        _acceptDeclineView.hidden=YES;
        _btnBeginTrip.hidden=YES;
        [self handleAddressTopFixed];
        isBeginFirst =NO;
        // Historically the "Pick" action opened the OTP modal for the pickup confirmation flow.
        // Some deployments may skip the accept/decline popup (P_IS_SHOW_EXTRA_POPUP == "No"),
        // so we must open the OTP modal here when otp_start is enabled.
        if([ConstantModel getConstantsObject].otp_start){
            if(homeDataModel.trip.is_share){
                // Shared rides skip pickup OTP.
                [self fatechActualPickUpLocation];
            }else{
                [self openAskOtpScreen];
            }
        }
        [self ndShowOnTripPanel];
    }
    else{
        [_btnAccept setTitle:[LanguageHelper getStringWithKey:@"k_21_s4_yes"]  forState:UIControlStateNormal];
        [_btnDecline setTitle:[LanguageHelper getStringWithKey:@"k_22_s4_no"] forState:UIControlStateNormal];
        _lblAcceptTitle.text = [LanguageHelper getStringWithKey:@"k_23_s4_client_picked_up"];
        _acceptDeclineView.hidden =NO;
    }
}



-(void)handleEndTrip{
    [self->homeDataModel sendNotification:TS_END];
    driverStatus = TS_END;
    defaults_set_object(DRIVER_STATUS, driverStatus);
    [self removeTripDetailsTimer];
    
    _btnBeginTrip.hidden =YES;
    [self settoInitialState];
    TotalM = 0.0;
    TotalTripDIstance =0.0;
    defaults_remove(DRIVER_STATUS_TEMP);
    defaults_remove(@"total_travelled_distance");
    [self performSegueWithIdentifier:StoryBoardUtiles.FARE_AMOUNT_VC sender:nil];
}




-(void)handleArriveNowState{
    driverStatus = TS_ARRIVE;
    self->homeDataModel.trip.trip_Status=TS_ARRIVE;
    defaults_set_object(DRIVER_STATUS, driverStatus);
    [self handleAddressTopFixed];
    [_btnGoPopUP setTitle:[LanguageHelper getStringWithKey:@"k_19_s4_arrived" defaultValue:@"He llegado!"] forState:UIControlStateNormal];
    UIImage *msgIcon = [UIImage imageNamed:@"ic_message_bubble"];
    if (msgIcon) {
        [_btnGoPopUP setImage:[msgIcon imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
        _btnGoPopUP.semanticContentAttribute = UISemanticContentAttributeForceRightToLeft;
    }
    [self->homeDataModel sendNotification:TS_ARRIVE];
    if ([P_IS_SHOW_EXTRA_POPUP isEqualToString:@"No"]) {
        
        [self handlePick];
    }
    
}

-(void) handleAddressTopFixed{
    [self handleAddressTopFixed:NO];
}

-(void) handleAddressTopFixed:(BOOL) isHideAddress{
    // New design: always keep addressViewTop hidden — address is shown in the trip info card
    if (_ndTripInfoCard) {
        self.addressViewTop.hidden = YES;
        [self.addressViewTop setConstraintConstant:0 forAttribute:NSLayoutAttributeHeight];
        return;
    }
    NSString * titleAddress = @"";
    NSString * textAddress = @"";
    NSString *status =defaults_object(DRIVER_STATUS);
    if ( status ==nil ||[status isEqualToString:TS_WAITING]){
        isHideAddress=YES;
    }
    if(isHideAddress){
        [self.addressViewTop setConstraintConstant:0 forAttribute:NSLayoutAttributeHeight];
        self.addressViewTop.hidden=YES;
        self.lblLocationTitle.text=titleAddress;
        self.lblAddressTop.text=textAddress;
        return;
    }
    self.addressViewTop.hidden=NO;
    if([homeDataModel.trip.trip_Status isEqualToString:TS_BEGIN]||[homeDataModel.trip.trip_Status isEqualToString:TS_ARRIVE]){
        if([homeDataModel.trip.trip_Status isEqualToString:TS_ARRIVE]){
            NSString *localTripStatus=defaults_object(DRIVER_STATUS_TEMP);
            if(localTripStatus!=nil &&[localTripStatus isEqualToString:TS_PICKED]) {
                titleAddress=[LanguageHelper getStringWithKey:@"k_11_s8_search_drop_location"];
                textAddress=self->homeDataModel.trip.trip_drop_loc;
            }else{
                titleAddress=[LanguageHelper getStringWithKey:@"k_1_s11_pickup_n_loc"];
                textAddress = self->homeDataModel.trip.trip_pick_loc;
            }
        }else{
            titleAddress=[LanguageHelper getStringWithKey:@"k_11_s8_search_drop_location"];
            textAddress=self->homeDataModel.trip.trip_drop_loc;
        }
    }else{
        titleAddress=[LanguageHelper getStringWithKey:@"k_1_s11_pickup_n_loc"];
        textAddress = self->homeDataModel.trip.trip_pick_loc;
    }
    if(textAddress.length==0){
        self.addressViewTop.hidden=YES;
        [self.addressViewTop setConstraintConstant:0 forAttribute:NSLayoutAttributeHeight];
        return;
    }
    int heightTitle=[Utilities getLabelHeight:CGSizeMake(SCREEN_WIDTH-40, 200) forText:titleAddress withFont:FONTS_THEME_REGULAR(17)];
    int height=[Utilities getLabelHeight:CGSizeMake(SCREEN_WIDTH-40, 200) forText:textAddress withFont:FONTS_THEME_REGULAR(17)];
    [self.addressViewTop setConstraintConstant:height+20+heightTitle forAttribute:NSLayoutAttributeHeight];
    self.lblLocationTitle.text=titleAddress;
    self.lblAddressTop.text=textAddress;
}



- (void)startMotionDetection {
    BOOL b = [CMMotionActivityManager isActivityAvailable];
    if (!b) {
        return;
    }
    CMMotionActivityManager *motionActivityManager =
    [[CMMotionActivityManager alloc] init];
    [motionActivityManager
     startActivityUpdatesToQueue:[NSOperationQueue mainQueue]
     withHandler:^(CMMotionActivity *activity) {
        if (activity.unknown) {
            self->_activtiyNameDetactor=@"Not walking";
            
        }
        else if (activity.stationary)
        {
            self->_activtiyNameDetactor=@"stationary";
            
        }
        
        else if (activity.walking)
        {
            self->_activtiyNameDetactor=@"Walking";
            
        }
        
        else if (activity.running)
        {
            self->_activtiyNameDetactor=@"Run";
            
        }
        
        else if (activity.cycling)
        {
            self->_activtiyNameDetactor=@"Cycling";
            
        }
        
        else if (activity.automotive)
        {
            self->_activtiyNameDetactor=@"automotive";
            
        }
        
    }];
}



-(MKPolyline *) getPolylineFromArray:(NSMutableArray *)arrDirection
{
    CLLocationCoordinate2D coords[arrDirection.count];
    
    for (int i = 0; i < arrDirection.count; i++) {
        CLLocation *location = [arrDirection objectAtIndex:i];
        coords[i] = CLLocationCoordinate2DMake(location.coordinate.latitude,location.coordinate.longitude);
    }
    
    return   [MKPolyline polylineWithCoordinates:coords count:arrDirection.count];
}

-(float)kilometersfromPlace:(CLLocationCoordinate2D)from andToPlace:(CLLocationCoordinate2D)to  {
    
    CLLocation *userloc = [[CLLocation alloc]initWithLatitude:from.latitude longitude:from.longitude];
    CLLocation *dest = [[CLLocation alloc]initWithLatitude:to.latitude longitude:to.longitude];
    
    CLLocationDistance dist = [userloc distanceFromLocation:dest];
    
    NSString *distance2 = [NSString stringWithFormat:@"%f",dist];
    
    return [distance2 floatValue];
    
}

-(void)setDriverFree{
    self.btnDirection.hidden=YES;
    isRiderCancelCalledNoti=NO;
    isRequestViewOpen=NO;
    TotalM = 0.0;
    TotalTripDIstance =0.0;
    apiCallAttempt =0;
    defaults_remove(TRIP_ID);
    defaults_remove(DRIVER_STATUS_TEMP);
    [self getAllPendingTrips:YES];
    defaults_remove(@"total_travelled_distance");
    [self removeTripDetailsTimer];
    [self hideAndShowReqestView];
    [self ButtonGpsPressed:nil];
    driverPinStart=nil;
    routeDestinationLess=nil;
    [self hideUserInfo];
    self.viewSentOffer.hidden=NO;
    [self updateNewDesignTabsVisibilityForActiveTrip:NO];
    if(vcOffers==nil){
        vcOffers = [[UIStoryboard storyboardWithName:@"Taxi" bundle:nil] instantiateViewControllerWithIdentifier:@"DTripOffersViewContoller"];
        vcOffers.delegate=self;
        [self addChildViewController:vcOffers];
        int topArea=0;
        if (@available(iOS 11.0, *)) {
            UIWindow *window = UIApplication.sharedApplication.windows.firstObject;
            topArea = window.safeAreaInsets.top;
            CGFloat bottomPadding = window.safeAreaInsets.bottom;
            topArea=bottomPadding ;
        }
        topArea=topArea+46;
        [vcOffers.view setFrame:CGRectMake(0.0f, 0.0f, SCREEN_WIDTH, SCREEN_HEIGHT-topArea)];
        [self.view addSubview:vcOffers.view];
        [vcOffers didMoveToParentViewController:self];
        [vcOffers.view setHidden:YES];
    }
    [self onRequestsView:nil];
    [self manageCancelRideButton];
}

- (void)stopMusic{
    [audioPlayer stop];
}


- (void)startMusic
{
    
    
    
    NSString *path =[[NSBundle mainBundle] pathForResource:@"final tone" ofType:@"mp3"];
    
    NSURL * url = [NSURL fileURLWithPath:path];
    audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:NULL];
    [audioPlayer setVolume:1.0];
    audioPlayer.numberOfLoops = -1;
    [audioPlayer play];
    
}


-(void)clearMapView:(BOOL) isMakeCenter{
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self.mapView removeOverlays:self.mapView.overlays];
    driverPin=nil;
    if(isMakeCenter){
        [self ButtonGpsPressed:nil];
    }
}



- (void) CenterMapRegionForShot {
    
    if (!isMapDraged) {
        
        AppDelegate *delegate = APP_DELEGATE;
        
        CLLocation *myLocation = [[CLLocation alloc]initWithLatitude:delegate.currLoc.coordinate.latitude longitude:delegate.currLoc.coordinate.longitude];
        
        self.mapView.camera.centerCoordinate = myLocation.coordinate;
        
        [self.mapView setCamera:self.mapView.camera];
        if(currentHeading>0)
        {
            _mapView.camera.heading=currentHeading;
            [self.mapView setCamera:_mapView.camera animated:YES];
        }
    }
}



- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}
- (void)didDragMap:(UIGestureRecognizer *)gestureRecognizer {
    isMapDraged=YES;
    
    if (gestureRecognizer.state ==UIGestureRecognizerStateEnded) {
        [self invalidateMapCentertimer];
        
        mapCenterTimer = [NSTimer scheduledTimerWithTimeInterval: 25.0 target: self selector: @selector(startCenterMap) userInfo: nil repeats: NO];
    }
}

-(void)startCenterMap{
    
    [self invalidateMapCentertimer];
    
    isMapDraged=NO;
    [self CenterMapRegionForShot];
}

-(void)invalidateMapCentertimer{
    
    [mapCenterTimer invalidate];
    mapCenterTimer = nil;
    
}

#pragma mark - Map + User Method


-(void)getTripDetails{
    if (homeDataModel.trip == nil) {
        return;
    }
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
        [self removeTripDetailsTimer ];
        self->timerGetTripDetail=[NSTimer scheduledTimerWithTimeInterval: TRIP_TIMER_DURATION target: self selector: @selector(getTripDetails) userInfo: nil repeats: NO];
        return;
    }
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{
        @"trip_id" :homeDataModel.trip.trip_Id
    }];
    [GIC mkwu:TRIP_GETTRIP
            d:dict
          isa:NO
           cb:^(id results, NSError *error) {
        if ([[[results objectForKey:P_STATUS] uppercaseString] isEqualToString:@"OK"]) {
            self->homeDataModel.trip = [[TripModel alloc] initItemWithDict:[[results objectForKey:P_RESPONSE]objectAtIndex:0]];
            if ([self->homeDataModel.trip.trip_Status isEqualToString:TS_RIDER_CANCEL]||[self->homeDataModel.trip.trip_Status isEqualToString:TS_RIDER_CANCEL_CANCEL]) {
                [self riderCancelAtPickup:NO];
            }
            else{
                self.offLineView.hidden=YES;
                
                [self removeTripDetailsTimer ];
                self->timerGetTripDetail=[NSTimer scheduledTimerWithTimeInterval: TRIP_TIMER_DURATION target: self selector: @selector(getTripDetails) userInfo: nil repeats: NO];
            }
        }
        else{
            self.offLineView.hidden=YES;
            [self removeTripDetailsTimer ];
            self->timerGetTripDetail=[NSTimer scheduledTimerWithTimeInterval: TRIP_TIMER_DURATION target: self selector: @selector(getTripDetails) userInfo: nil repeats: NO];
        }
    }];
}



-(void)riderCancelAtPickup:(BOOL)riderCancelAtPickup{
    
    if (!isRiderCancelCalled) {
        [[UpdateUserCurrentLocation sharedInstance]  updateDriverAvailablity:@"1"];
        defaults_remove(DRIVER_STATUS_TEMP);
        defaults_remove(@"cal_wait_time");
        defaults_remove(@"wait_time_start");
        self.addressViewTop.hidden=YES;
        if (isChatVCCalled) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"TripCancelled" object:nil];
        }
        //Firebase
        
        
        isRiderCancelCalled =YES;
        
        arrPendingTrips = [[NSMutableArray alloc]init];
        [self.tableViewPendingTrips reloadData];
        if (_ndCollectionView) { dispatch_async(dispatch_get_main_queue(), ^{ [self->_ndCollectionView reloadData]; NSInteger _ndCount = self->arrPendingTrips.count; self->_ndBadgeLabel.hidden = (_ndCount == 0); self->_ndBadgeLabel.text = [NSString stringWithFormat:@"%ld", (long)_ndCount]; }); }

        driverStatus = TS_WAITING;
        [self settoInitialState];
        self.viewOtpVerify.hidden=YES;
        [self.view endEditing:YES];
        [self setDriverFree];
        
        
        defaults_set_object(DRIVER_STATUS, driverStatus);
        
        self.switchAvalability.hidden=NO;
        [self.offLineView setHidden:YES];
        defaults_remove(@"IsManualPickupStarted");
        defaults_remove(@"begin_date");
        [self removerWatTimer];
        if (!self->_ndTabContainerView) {
            self.viewRequestBg.hidden = NO;
            [_viewRequestBg setConstraintConstant:heightOfRequestView forAttribute:NSLayoutAttributeHeight];
        }
        if(riderCancelAtPickup==NO){
            NSString *tripId= defaults_object(TRIP_ID);
            if([tripId intValue]>0){
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[LanguageHelper getStringWithKey:@"k_33_s7_alert"]
                                                                                         message:[LanguageHelper getStringWithKey:@"k_60_s4_trip_cancelled_by_rider"]
                                                                                  preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *actionOk = [UIAlertAction actionWithTitle:[LanguageHelper getStringWithKey:@"k_18_s4_Ok"]
                                                                   style:UIAlertActionStyleDefault
                                                                 handler:^(UIAlertAction * action) {
                    [self->autoHideCancelAlert performAction];
                }];
                
                [alertController addAction:actionOk];
                [self presentViewController:alertController animated:YES completion:nil];
                autoHideCancelAlert =[[AutoHideAlert alloc] init];
                autoHideCancelAlert.delegate = self;
                [autoHideCancelAlert handle:alertController];
                
            }
        }
        defaults_remove(TRIP_ID);
    }
}

-(void)onAutoHide:(AutoHideAlert *)autoHideAlertHelper{
    if(autoHideAlertHelper ==autoHideCancelAlert ){
        [self stopLocationUpdate];
        [self.navigationController popToRootViewControllerAnimated:NO];
        HomeViewController * vcHome=[self.storyboard instantiateViewControllerWithIdentifier:@"HomeViewController"];
        [[NSUserDefaults standardUserDefaults] setObject:@(NO)  forKey:P_IS_SINGLE_MODE];
        [[NSUserDefaults standardUserDefaults]synchronize];
        [self.navigationController setViewControllers:@[vcHome] animated:YES];
    }
}

-(void)zoomToFitMapAnnotations:(NSMutableArray *) arrayAnotations1
{
    CLLocationCoordinate2D topLeftCoord;
    topLeftCoord.latitude = -90;
    topLeftCoord.longitude = 180;
    CLLocationCoordinate2D bottomRightCoord;
    bottomRightCoord.latitude = 90;
    bottomRightCoord.longitude = -180;
    
    for (id <MKAnnotation> annotation in arrayAnotations1) {
        topLeftCoord.longitude = fmin(topLeftCoord.longitude, annotation.coordinate.longitude);
        topLeftCoord.latitude = fmax(topLeftCoord.latitude, annotation.coordinate.latitude);
        
        bottomRightCoord.longitude = fmax(bottomRightCoord.longitude, annotation.coordinate.longitude);
        bottomRightCoord.latitude = fmin(bottomRightCoord.latitude, annotation.coordinate.latitude);
    }
    
    MKCoordinateRegion region;
    region.center.latitude = topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) * 0.5;
    region.center.longitude = topLeftCoord.longitude + (bottomRightCoord.longitude - topLeftCoord.longitude) * 0.5;
    region.span.latitudeDelta = fabs(topLeftCoord.latitude - bottomRightCoord.latitude) * 1.5;
    region.span.longitudeDelta = fabs(bottomRightCoord.longitude - topLeftCoord.longitude) * 1.5;
    [self mapRegion:region mapView:self.mapView];
}

-(void)removeTripDetailsTimer{
    if (timerGetTripDetail) {
        [timerGetTripDetail invalidate];
        timerGetTripDetail =nil;
    }
}









-(NSString *)getHoursAndMinutes:(NSInteger)minutes{
    
    NSString *tmpStr;
    int min = (int)minutes%60;
    int hours =(int) (minutes - min)/60;
    
    if (hours>0) {
        
        tmpStr =[NSString stringWithFormat:@"%dh %d%@", hours, min,[LanguageHelper getStringWithKey:min<=1?@"k_17_s4_min":@"k_17_s4_mins"]];
        
    }
    else{
        
        tmpStr =[NSString stringWithFormat:@"%d%@", min,[LanguageHelper getStringWithKey:min<=1?@"k_17_s4_min":@"k_17_s4_mins"]];
    }
    
    return tmpStr;
    
}



-(void)getAllPendingTrips:(BOOL)isShowLoader{
    [self invalidatePendingTripTimer];
    AppDelegate *appdelegate =APP_DELEGATE;
    NSDictionary *dict1 = [[NSUserDefaults standardUserDefaults]objectForKey:P_USER_DICT];
    if(dict1==nil){
        if (isShowLoader) {
            [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
        }
        return;
    }
    if([[dict1 objectForKey:P_DRIVER_ID] intValue]==0){
        return ;
    }
    if(self.btOnGoing.isSelected){
        [self getOnGoingTripsWithTimer:isShowLoader];
        return;
    }
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{
    }];
    [dict setObject:TS_REQUEST forKey:TRIP_STATUS];
    [dict setObject:[dict1 objectForKey:P_DRIVER_ID] forKey:P_DRIVER_ID];
    [dict setObject:@PENDING_HOURS forKey:@"hours"];
    [dict setObject:[dict1 objectForKey:P_CATEGORY_ID] forKey:P_CATEGORY_ID];
    [dict setObject:[NSString stringWithFormat:@"%f", appdelegate.currLoc.coordinate.latitude] forKey:@"lat"];
    [dict setObject:[NSString stringWithFormat:@"%f", appdelegate.currLoc.coordinate.longitude] forKey:@"lng"];
    // Se guarda el punto con el que se consulta para volver a medir con EL MISMO al contestar.
    CLLocationCoordinate2D puntoDeLaConsulta = appdelegate.currLoc.coordinate;
    if ([ConstantModel getConstantsObject].constant_driver_radius ==0.0) {
        [dict setObject:@"4" forKey:@"miles"];
    }
    else{
        [dict setObject:[NSString stringWithFormat:@"%.1f",[ConstantModel getConstantsObject].constant_driver_radius] forKey:@"miles"];
    }
    /*
     rl_miles, que no se mandaba nunca.

     getRevisedTrips usa UN radio u OTRO segun el viaje: para is_ride_later = 1 coge
     $rlMiles, y si no llega se queda en null. Y en PHP `$distancia <= null` convierte el
     null a 0, asi que la condicion solo se cumple con distancia cero: los viajes
     RESERVADOS se estaban descartando TODOS en el servidor, y el conductor de iOS no los
     veia nunca.

     El respaldo de 100 es el mismo que usa Android cuando la constante no esta puesta.
     */
    double radioProgramado = [[[ConstantModel valorDeConstantePorClave:@"rl_driver_radius"]
                               stringByReplacingOccurrencesOfString:@"," withString:@"."] doubleValue];
    if (radioProgramado <= 0) {
        radioProgramado = 100.0;
    }
    [dict setObject:[NSString stringWithFormat:@"%.1f", radioProgramado] forKey:@"rl_miles"];

    if (isShowLoader) {
        [UtilityClass setLH:NO wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
    }
    [self getOnGoingTripsWithTimer:NO];
    [GIC mkwu:self.btOnGoing.isSelected?TRIP_GETTRIP:GET_REVISED_TRIPS
            d:dict   isa:NO    cb:^(id results, NSError *error) {
        self->apiCallAttempt++;
        if ([[[results objectForKey:P_STATUS]  uppercaseString]isEqualToString:@"OK"] && [[results objectForKey:P_RESPONSE] isKindOfClass:[NSArray class]]) {
            NSArray *arrTemp = [results objectForKey:P_RESPONSE];
            NSMutableArray *arrtemp1 =[[NSMutableArray alloc]init];
            
            for (NSMutableDictionary *dict in arrTemp) {
                TripModel  *trip = [[TripModel alloc] initItemWithDict:dict];
                [arrtemp1 addObject:trip];
            }
            /*
             El tope se vuelve a medir aqui.

             Se mide desde el MISMO punto con el que se pidio la lista -- el de arriba, no la
             posicion de ahora -- para que el telefono y el servidor esten comparando lo
             mismo: si el conductor se movio mientras la llamada iba y venia, medir desde el
             sitio nuevo daria un resultado distinto al que dio el servidor.

             Ver ConrraRadioDeReparto para el porque: el servidor compara MILLAS contra el
             radio salvo que distance_paramiter valga exactamente "km".
             */
            NSUInteger antes = arrtemp1.count;
            NSArray *dentroDelRadio = [ConrraRadioDeReparto filtrar:arrtemp1 desde:puntoDeLaConsulta];
            if (dentroDelRadio.count < antes) {
                NSLog(@"[RadioDeReparto] el servidor mando %lu solicitudes y %lu quedaron fuera del tope",
                      (unsigned long)antes, (unsigned long)(antes - dentroDelRadio.count));
                // El sonido de solicitud ya sono al llegar el push. Si lo que lo provoco cae
                // fuera, se calla: una alarma que no lleva a ninguna tarjeta solo desconcierta.
                if (dentroDelRadio.count == 0) {
                    [APP_DELEGATE stopRequestSound];
                }
            }
            /*
             Las que el servidor no trajo esta vez se aguantan unos ciclos.

             La respuesta parpadea: la misma solicitud desaparece en un sondeo y vuelve en el
             siguiente, porque el filtro de distancia se evalua contra la posicion del
             conductor -- que cambia mientras conduce -- y en el borde del radio entra y sale
             sola. Sin esto la tarjeta se borra y reaparece, y si el conductor iba a tocarla ya
             no esta. Ver ConrraSolicitudesPersistentes.
             */
            NSArray *conLasQueAguantan = [ConrraSolicitudesPersistentes fusionar:dentroDelRadio
                                                                     conPantalla:self->arrPendingTrips];
            self->arrPendingTrips = [NSMutableArray arrayWithArray:conLasQueAguantan];
            [self invalidatePendingTripTimer];
            [self resetPendingTripTimer];
            [self updateRquestCounter];
        }
        else{
            if(error!=nil)  {
                if(self->apiCallAttempt<3) {
                    if (isShowLoader) {
                        [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
                    }
                    [self getPending];
                }
                else{
                    self->apiCallAttempt=0;
                    self->arrPendingTrips = [[NSMutableArray alloc]init];
                    [self resetPendingTripTimer];
                }
            }else{
                self->apiCallAttempt=0;
                self->arrPendingTrips = [[NSMutableArray alloc]init];
                [self resetPendingTripTimer];
                
            }
            [self updateRquestCounter];
        }
        
        [self.tableViewPendingTrips reloadData];
        [self callarSiNoHaySolicitudes];

        NSString *_pendingNotiId = self->_ndPendingNotificationTripId.length ? [self->_ndPendingNotificationTripId copy] : nil;
        if (_pendingNotiId) self->_ndPendingNotificationTripId = nil;

        if (self->arrPendingTrips.count>0) {
            self.lblNoData.hidden=YES;
            defaults_remove(TRIP_ID);
        }
        else{
            self.lblNoData.hidden =NO;
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            if (self->_ndCollectionView) {
                [self->_ndCollectionView reloadData];
                NSInteger _ndCount = self->arrPendingTrips.count;
                self->_ndBadgeLabel.hidden = (_ndCount == 0);
                self->_ndBadgeLabel.text = [NSString stringWithFormat:@"%ld", (long)_ndCount];
            }
            if (isShowLoader) {
                [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
            }
            if (_pendingNotiId.length) {
                for (TripModel *t in self->arrPendingTrips) {
                    if ([t.trip_Id isEqualToString:_pendingNotiId]) {
                        [self requestGetButtonTapWithTrip:t];
                        break;
                    }
                }
            }
        });
    }];
}

-(void)getOnGoingTripsWithTimer:(BOOL)isShowLoader{
    NSDictionary *dict1 = [[NSUserDefaults standardUserDefaults]objectForKey:P_USER_DICT];
    if(dict1==nil){
        if (isShowLoader) {
            [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
        }
        return;
    }
    if([[dict1 objectForKey:P_DRIVER_ID] intValue]==0){
        return ;
    }
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{
    }];
    [dict setObject:TS_ASSIGNED forKey:TRIP_STATUS];
    [dict setObject:[dict1 objectForKey:P_DRIVER_ID] forKey:P_DRIVER_ID];
    if (isShowLoader) {
        [UtilityClass setLH:NO wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
    }
    [GIC mkwu:TRIP_GETTRIP  d:dict   isa:NO    cb:^(id results, NSError *error) {
        self->apiCallAttempt++;
        if ([[[results objectForKey:P_STATUS]  uppercaseString]isEqualToString:@"OK"] && [[results objectForKey:P_RESPONSE] isKindOfClass:[NSArray class]]) {
            NSArray *arrTemp = [results objectForKey:P_RESPONSE];
            NSMutableArray *arrtemp1 =[[NSMutableArray alloc]init];
            for (NSMutableDictionary *dict in arrTemp) {
                TripModel  *trip1 = [[TripModel alloc] initItemWithDict:dict];
                [arrtemp1 addObject:trip1];
            }
            self->arrPendingTripsonGoing = [[NSMutableArray alloc] initWithArray:arrtemp1];
            [self updateOnGoingCounter];
        }
        else{
            [self updateOnGoingCounter];
        }
        if(self.btOnGoing.isSelected){
            self->arrPendingTrips = [[NSMutableArray alloc] initWithArray:self->arrPendingTripsonGoing];
            if (self->arrPendingTripsonGoing.count>0) {
                self.lblNoData.hidden=YES;
            }
            else{
                self.lblNoData.hidden =NO;
            }
        }
        [self.tableViewPendingTrips reloadData];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self->_ndCollectionView) {
                [self->_ndCollectionView reloadData];
                NSInteger _ndCount = self->arrPendingTrips.count;
                self->_ndBadgeLabel.hidden = (_ndCount == 0);
                self->_ndBadgeLabel.text = [NSString stringWithFormat:@"%ld", (long)_ndCount];
            }
            if (isShowLoader) {
                [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
            }
        });
    }];
}

-(void)getPending{
    [self getAllPendingTrips:NO];
    
}

-(void) resetPendingTripTimer{
    [self invalidatePendingTripTimer];
    NSDictionary *dict1 = [[NSUserDefaults standardUserDefaults]objectForKey:P_USER_DICT];
    if([[dict1 objectForKey:P_DRIVER_ID] intValue]>0){
        self->timerPendingRequest = [NSTimer scheduledTimerWithTimeInterval: 30.0 target: self
                                                                   selector: @selector(getPending) userInfo: nil repeats: NO];
    }
}

-(void)invalidatePendingTripTimer{
    [timerPendingRequest invalidate];
    timerPendingRequest = nil;
}



-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(self.btOnGoing.isSelected){
        return arrPendingTripsonGoing.count;
    }
    return arrPendingTrips.count;
    
}



- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(self.btOnGoing.isSelected){
        static NSString *cellIdentifier = @"UpcommingTripCell";
        UpcommingTripCell *cell =
        [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        cell.selectionStyle =UITableViewCellSelectionStyleNone;
        cell.backgroundColor=[UIColor clearColor];
        [cell setdataWithTripModel:[arrPendingTripsonGoing objectAtIndex:indexPath.row]];
        TripModel * tripModel = [arrPendingTripsonGoing objectAtIndex:indexPath.row];
        NSString *trip_pick_loc=tripModel.pickupLocationApp;
        CGFloat pickHeight = [UtilityClass gTH:CGSizeMake(SCREEN_WIDTH-80, 300) forText:  trip_pick_loc  withFont:FONTS_THEME_REGULAR_NO_SCALE(16)];
        [cell.viewVerticalLine setConstraintConstant:pickHeight+25 forAttribute:NSLayoutAttributeHeight];
        cell.isUpcommingRide = YES;
        cell.delegate= self;
        return  cell;
    }
    static NSString *cellIdentifier = @"PendingTripCell";
    PendingTripCell *cell =
    [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        cell = [[PendingTripCell alloc] initWithStyle:UITableViewCellStyleValue1
                                      reuseIdentifier:cellIdentifier];
    }
    UIColor *lightGray = RGBA(0.0, 0.0, 0.0, 0.1);
    cell.selectionStyle =UITableViewCellSelectionStyleNone;
    cell.backgroundColor=[UIColor clearColor];
    
    cell.delegate = self;
    
    [cell setdataWithTripModel:[arrPendingTrips objectAtIndex:indexPath.row]];
    TripModel * tripModel = [arrPendingTrips objectAtIndex:indexPath.row];
    NSString * stringPickup=tripModel.trip_pick_loc;
    if(tripModel.pickup_notes.length>0){
        stringPickup=[NSString stringWithFormat:@"%@\n\n%@ %@",tripModel.trip_pick_loc,[LanguageHelper getStringWithKey:@"k_1_s8_special_notes"],tripModel.pickup_notes];
    }
    CGFloat pickHeight = [UtilityClass gTH:CGSizeMake(SCREEN_WIDTH-95, 300) forText:  stringPickup  withFont:FONTS_THEME_REGULAR_NO_SCALE(16)];
    [cell.viewVerticalLine setConstraintConstant:pickHeight+25 forAttribute:NSLayoutAttributeHeight];
    return cell;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.btOnGoing.isSelected){
        TripModel * tripModel = [arrPendingTripsonGoing objectAtIndex:indexPath.row];
        NSString * stringPickup=tripModel.trip_pick_loc;
        if(tripModel.pickup_notes.length>0){
            stringPickup=[NSString stringWithFormat:@"%@\n\n%@ %@",tripModel.trip_pick_loc,[LanguageHelper getStringWithKey:@"k_1_s8_special_notes"],tripModel.pickup_notes];
        }
        CGFloat pickHeight = [UtilityClass gTH:CGSizeMake(SCREEN_WIDTH-95, 300) forText:  stringPickup  withFont:FONTS_THEME_REGULAR_NO_SCALE(16)];
        CGFloat dropHeight = [UtilityClass gTH:CGSizeMake(SCREEN_WIDTH-95, 300) forText: tripModel.trip_drop_loc withFont:FONTS_THEME_REGULAR_NO_SCALE(16)];
        CGFloat finalHeight = 10 + dropHeight;
        return 128 + pickHeight + finalHeight+15+40;
    }
    TripModel * tripModel = [arrPendingTrips objectAtIndex:indexPath.row];
    NSString * stringPickup=tripModel.trip_pick_loc;
    if(tripModel.pickup_notes.length>0){
        stringPickup=[NSString stringWithFormat:@"%@\n\n%@ %@",tripModel.trip_pick_loc,[LanguageHelper getStringWithKey:@"k_1_s8_special_notes"],tripModel.pickup_notes];
    }
    CGFloat pickHeight = [UtilityClass gTH:CGSizeMake(SCREEN_WIDTH-95, 300) forText:  stringPickup  withFont:FONTS_THEME_REGULAR_NO_SCALE(16)];
    CGFloat dropHeight = [UtilityClass gTH:CGSizeMake(SCREEN_WIDTH-95, 300) forText: tripModel.trip_drop_loc withFont:FONTS_THEME_REGULAR_NO_SCALE(16)];
    CGFloat finalHeight = 10 + dropHeight;
    return 128 + pickHeight + finalHeight+15;
}


- (IBAction)ButtonExpandPressed:(UIButton *)sender {
    if (!sender.isSelected) {
        int topArea=0;
        if (@available(iOS 11.0, *)) {
            UIWindow *window = UIApplication.sharedApplication.windows.firstObject;
            topArea = window.safeAreaInsets.top;
            CGFloat bottomPadding = window.safeAreaInsets.bottom;
            topArea=topArea+bottomPadding;
        }
        topArea=topArea+50;
        [self.viewRequestBg setConstraintConstant:SCREEN_HEIGHT- (topArea) forAttribute:NSLayoutAttributeHeight];
        isRequestViewOpen =YES;
        [UIView animateWithDuration:0.6f animations:^{
            [sender setSelected:YES];
            self.btnGps.hidden=YES;
            [self.view layoutIfNeeded];
        }];
    }
    else{
        isRequestViewOpen =NO;
        [_viewRequestBg setConstraintConstant:heightOfRequestView forAttribute:NSLayoutAttributeHeight];
        [UIView animateWithDuration:0.6f animations:^{
            self.btnGps.hidden=NO;
            [sender setSelected:NO];
            [self.view layoutIfNeeded];
        }];
    }
}

-(void)showAlert:(NSString *)title message:(NSString *)msg{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                             message:msg                                                                         preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *actionOk = [UIAlertAction actionWithTitle:[LanguageHelper getStringWithKey:@"k_18_s4_Ok"]
                                                       style:UIAlertActionStyleDefault
                                                     handler:nil];
    [alertController addAction:actionOk];
    [self presentViewController:alertController animated:YES completion:nil];
    
}


-(void)refreshOnAcceptOnGoingTrip:(TripModel *)trip{
    //    NSString *tripId=[NSString stringWithFormat:@"%@",trip.trip_Id];
    //    defaults_set_object(TRIP_ID,tripId);
    //    [self loadHomeViewController];
    [self refreshOnAcceptTrip:trip];
}

-(void)refreshOnAcceptTrip:(TripModel *)trip{
    self.btnDirection.hidden=NO;
    self.viewSentOffer.hidden = NO;
    [self updateNewDesignTabsVisibilityForActiveTrip:YES];
    [self.viewRequestBg hideByHeight:YES];
    self.mapviewHeightConstraints.constant = SCREEN_HEIGHT - 80;
    self.btnGpsTopConstraints.constant =SCREEN_HEIGHT -heightOfRequestView;
    [homeDataModel setTripModel:trip];
    NSString * cancelAt = [NSString stringWithFormat:@"%@",[Utilities getStringFromDate:[NSDate date]]];
    [self saveTripLogFor:TS_ACCEPTED timeAt:cancelAt];
    [self drawroute:YES isAccept:YES isDivert:NO];
    
    
    NSString *driverAvailability =@"0";
    if(trip.is_share)
    {
        driverAvailability=@"2";
    }
    [[UpdateUserCurrentLocation sharedInstance]  updateDriverAvailablity:driverAvailability];
    driverStatus = TS_ACCEPTED;
    _goPopUpView.hidden=NO;
    defaults_set_object(TRIP_ID, trip.trip_Id);
    defaults_set_object(DRIVER_STATUS, driverStatus);
    [self->homeDataModel sendNotification:TS_ACCEPTED];
    isRiderCancelCalled =NO;
    [self getTripDetails];
    [self invalidatePendingTripTimer];
    [self handleAddressTopFixed];
    if(trip.is_share)  {
        self.btnShareRides.hidden=NO;
    }else{
        self.btnShareRides.hidden=YES;
    }
    [self manageCancelRideButton];
    [self showAndSetDataOnUiForUserInfo];
    if(vcOffers!=nil){
        [vcOffers stopAndRemove];
        vcOffers=nil;
    }
}


-(void)refreshONRejectTripGoingTrip:(TripModel *)trip{
    TripModel * tripRemove;
    for (TripModel *tripModelTemp in self->arrPendingTripsonGoing) {
        if(tripModelTemp.trip_Id==trip.trip_Id)   {
            tripRemove = tripModelTemp;
            break;
        }
    }
    if(tripRemove){
        [arrPendingTripsonGoing removeObject:tripRemove];
    }
    if (self->arrPendingTripsonGoing.count ==0) {
        self.lblNoData.hidden =NO;
    }
    else{
        self.lblNoData.hidden=YES;
    }
    [self updateOnGoingCounter];
    [self.tableViewPendingTrips reloadData];
    if (_ndCollectionView) { dispatch_async(dispatch_get_main_queue(), ^{ [self->_ndCollectionView reloadData]; NSInteger _ndCount = self->arrPendingTrips.count; self->_ndBadgeLabel.hidden = (_ndCount == 0); self->_ndBadgeLabel.text = [NSString stringWithFormat:@"%ld", (long)_ndCount]; }); }
}
-(void)refreshONRejectTrip:(TripModel *)trip{
    NSDictionary *dict1 = [[NSUserDefaults standardUserDefaults]objectForKey:P_USER_DICT];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{
        P_DRIVER_ID         :[dict1 objectForKey:P_DRIVER_ID],
        @"status"         :TS_REJECT,
        TRIP_ID             :trip.trip_Id,
    }];
    [UtilityClass setLH:NO wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
    [GIC mkwu:trip_reject d:dict cb:^(id results, NSError *error) {
        [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
        if ([[results objectForKey:P_STATUS] isEqualToString:@"OK"]) {
            // El conductor ya decidio: la solicitud no se aguanta ni un ciclo mas. Sin esto
            // una rechazada seguiria en la lista hasta un minuto.
            [ConrraSolicitudesPersistentes olvidar:trip.trip_Id];
            [self getAllPendingTrips:YES];
            for (TripModel *tripModelTemp in self->arrPendingTrips) {
                if(tripModelTemp.trip_Id==trip.trip_Id)   {
                    if (self->arrPendingTrips.count ==0) {
                        self.lblNoData.hidden =NO;
                    }
                    else{
                        self.lblNoData.hidden=YES;
                    }
                    [self.tableViewPendingTrips reloadData];
                    if (_ndCollectionView) { dispatch_async(dispatch_get_main_queue(), ^{ [self->_ndCollectionView reloadData]; NSInteger _ndCount = self->arrPendingTrips.count; self->_ndBadgeLabel.hidden = (_ndCount == 0); self->_ndBadgeLabel.text = [NSString stringWithFormat:@"%ld", (long)_ndCount]; }); }
                    break;
                }
            }
        }
        else  if (error != nil) {
            [Utilities handleError:error viewController:self defaultMessage:NSLocalizedString(@"too_late", @"")];
        }
    }];
}








-(void) getCurrentLocationAddress
{
    [UtilityClass setLH:NO wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
    AppDelegate *appdelegate=APP_DELEGATE;
    CLLocation    *sourcePoint=[[CLLocation alloc]   initWithLatitude:appdelegate.currLoc.coordinate.latitude  longitude:appdelegate.currLoc.coordinate.longitude];
    [Utilities getAddressStrinByLat:sourcePoint.coordinate.latitude longitude:sourcePoint.coordinate.longitude withcompletionHandler:^(NSString *locAddress, NSString *country) {
        [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
        if (locAddress.length>0) {
            self->singlePickUplocationAddress=locAddress;
        }
    }];
}





-(void) getLocationFromAddressString: (NSString*) addressStr withcompletionHandler : (void(^)(CLLocationCoordinate2D loc))completionHandler {
    double latitude = 0, longitude = 0;
    NSString *esc_addr =  [addressStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
    NSString *req = [NSString stringWithFormat:@"https://maps.google.com/maps/api/geocode/json?key=%@&sensor=false&address=%@",[APP_DELEGATE getGoogleKey], esc_addr];
    NSString *result = [NSString stringWithContentsOfURL:[NSURL URLWithString:req] encoding:NSUTF8StringEncoding error:NULL];
    if (result) {
        NSScanner *scanner = [NSScanner scannerWithString:result];
        if ([scanner scanUpToString:@"\"lat\" :" intoString:nil] && [scanner scanString:@"\"lat\" :" intoString:nil]) {
            [scanner scanDouble:&latitude];
            if ([scanner scanUpToString:@"\"lng\" :" intoString:nil] && [scanner scanString:@"\"lng\" :" intoString:nil]) {
                [scanner scanDouble:&longitude];
            }
        }
    }
    
    CLLocationCoordinate2D center;
    center.latitude=latitude;
    center.longitude = longitude;
    completionHandler(center);
    
}
-(void) openChatViewController
{
    ChatViewController *vc = (ChatViewController*)[StoryBoardUtiles viewContollerInMainWithIdentifier:StoryBoardUtiles.CHAT_VC];
    vc.tripID=homeDataModel.trip.trip_Id;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)onCloseAcceptViewButTap:(id)sender {
    [self.acceptDeclineView setHidden:YES];
    if([homeDataModel.trip.trip_Status isEqualToString:TS_BEGIN])
    {
        [self.btnBeginTrip setHidden:NO];
    } else {
        if([self isJobCancelBeforeTimer]){
            [self showWaitingTimer];
        }
        [self.goPopUpView setHidden:NO];
    }
    
}
- (IBAction)onClosePopupButTap:(id)sender {
    [self.viewMessage setHidden:YES];
    self.txtViewMessage.text=@"";
    if([homeDataModel.trip.trip_Status isEqualToString:TS_BEGIN])
    {
        [self.btnBeginTrip setHidden:NO];
    }else{
        self.goPopUpView.hidden = NO;
    }
    
    if(isCloseAcceptView){
        
    }else{
        [self.acceptDeclineView setHidden:NO];
    }
}

-(void) calculateDistacneBetweenSourceAndDestination:(CLLocation *)locationSource locationDestination:(CLLocation *)locationDestination completionBlock:(void (^)(id results, NSError *error))block isShowLoader:(BOOL)isShowLoader;
{
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    NSString *googleKey = [APP_DELEGATE getGoogleKey];
    NSMutableString *urlString = [NSMutableString stringWithFormat:
                                  @"%@?origins=%f,%f&destinations=%f,%f&sensor=true&key=%@",
                                  @"https://maps.googleapis.com/maps/api/distancematrix/json",
                                  locationSource.coordinate.latitude,
                                  locationSource.coordinate.longitude,
                                  locationDestination.coordinate.latitude,
                                  locationDestination.coordinate.longitude,
                                  googleKey];
    
    NSString *encoded = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
    if(isShowLoader)
    {
        [UtilityClass setLH:NO wt:[LanguageHelper getStringWithKey:@"k_53_s3_please_wait"]];
    }
    [manager GET:encoded parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(isShowLoader)   {
            [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_53_s3_please_wait"]];
        }
        NSDictionary *response = [[NSDictionary alloc] initWithDictionary:responseObject];
        if([[[response  objectForKey:@"status"] uppercaseString] isEqualToString:@"OK"])  {
            float returnDistacne=  [self getDistanceFromResponseDict:response];
            NSMutableDictionary * dict=[[NSMutableDictionary alloc] init];
            [dict setObject:@(returnDistacne) forKey:@"cal_distacne"];
            block(dict,nil);
        }
        else  {
            block(nil,nil);
            [self showAlertWithMessgae:[response objectForKey:@"error_message"]];
            
        }
    }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        if(isShowLoader)  {
            [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_53_s3_please_wait"]];
        }
        block(nil,error);
        NSString *dataSerializationResponse=[error.userInfo objectForKey:@"NSLocalizedDescription"];
        NSHTTPURLResponse *dataErrorResponse=[error.userInfo objectForKey:AppKeysName.ERROR_RESPONSE];
        if(dataErrorResponse!=nil&&dataSerializationResponse!=nil){
            [self showAlertWithMessgae:[NSString stringWithFormat:@"%ld - %@",(long)dataErrorResponse.statusCode,dataSerializationResponse] ];
        }else{
            if(dataSerializationResponse!=nil){
                [self showAlertWithMessgae:isEmpty(dataSerializationResponse) ];
            }else{
                [self showAlertWithMessgae:Localise(@"k_38_s4_internet_connection_failed") ];
            }
        }
    }];
}


-(float) getDistanceFromResponseDict:(NSDictionary *) dict
{
    float totalDistanceInMeter=0;
    NSArray *arrRos=[dict objectForKey:@"rows"];
    for (NSDictionary * dictElements in arrRos) {
        NSArray *arrElements=[dictElements objectForKey:@"elements"];
        for (NSDictionary * dictDistance in arrElements) {
            totalDistanceInMeter+=  [[[dictDistance  objectForKey:@"distance"] objectForKey:@"value"] floatValue];
        }
    }
    return totalDistanceInMeter/1000.0/*  covert meter to km*/;
}




- (IBAction)onTripRequestButTap:(id)sender {
    self.btRequests.selected=YES;
    self.btOnGoing.selected=NO;
    [self.btRequests  setTitleColor:[UIColor colorNamed:@"app_theame"] forState:UIControlStateSelected];
    [self.btRequests  setTitleColor:[UIColor colorNamed:@"app_theame"] forState:UIControlStateNormal];
    [self.btOnGoing  setTitleColor:[UIColor colorNamed:@"color_bt_un_select_text"] forState:UIControlStateNormal];
    [self.btOnGoing  setTitleColor:[UIColor colorNamed:@"color_bt_un_select_text"] forState:UIControlStateSelected];
    [self.viewDivider2 setBackgroundColor:[UIColor clearColor]];
    [self.viewDivider1 setBackgroundColor:[UIColor colorNamed:@"app_theame"]];
    self.lblNoData.text = [LanguageHelper getStringWithKey:@"k_52_s4_waiting_new_ride_req"];
    [self getAllPendingTrips:YES];
}



- (IBAction)onTripOnGoingButTap:(id)sender {
    self.btRequests.selected=NO;
    self.btOnGoing.selected=YES;
    [self.btRequests  setTitleColor:[UIColor colorNamed:@"color_bt_un_select_text"] forState:UIControlStateNormal];
    [self.btOnGoing  setTitleColor:[UIColor colorNamed:@"app_theame"] forState:UIControlStateNormal];
    [self.btRequests  setTitleColor:[UIColor colorNamed:@"color_bt_un_select_text"] forState:UIControlStateSelected];
    [self.btOnGoing  setTitleColor:[UIColor colorNamed:@"app_theame"] forState:UIControlStateSelected];
    self.lblNoData.text = [LanguageHelper getStringWithKey:@"k_17_s10_no_trips_scheduled"];
    [self.viewDivider1 setBackgroundColor:[UIColor clearColor]];
    [self.viewDivider2 setBackgroundColor:[UIColor colorNamed:@"app_theame"]];
//    [self getAllPendingTrips:YES];
    [self getOnGoingTripsWithTimer:YES];
}

-(void)refreshOnAssginedTrip:(TripModel *)tripModel{
    
    TripModel * tModelForDelete=nil;
    for (TripModel * tModel in arrPendingTrips) {
        if([tModel.trip_Id isEqualToString:tripModel.trip_Id])
        {
            tModelForDelete=tModel;
            break;
        }
    }
    if(tModelForDelete!=nil)
    {
        [arrPendingTrips removeObject:tModelForDelete];
    }
    if (arrPendingTrips.count ==0 ) {
        self.lblNoData.hidden =NO;
    }
    else{
        self.lblNoData.hidden =YES;
    }
    
    [self.tableViewPendingTrips reloadData];
    if (_ndCollectionView) { dispatch_async(dispatch_get_main_queue(), ^{ [self->_ndCollectionView reloadData]; NSInteger _ndCount = self->arrPendingTrips.count; self->_ndBadgeLabel.hidden = (_ndCount == 0); self->_ndBadgeLabel.text = [NSString stringWithFormat:@"%ld", (long)_ndCount]; }); }

}

-(void)onPickupLocationButonTap:(TripModel *)tripModel
{
    PickupDetailViewController * vc=(PickupDetailViewController *)[StoryBoardUtiles viewContollerInMainWithIdentifier:StoryBoardUtiles.PICKUP_DETAIL_VC];
    vc.isPickup=YES;
    vc.tripModel=tripModel;
    [self.navigationController pushViewController:vc animated:YES];
}


-(void)onDropLocationButonTap:(TripModel *)tripModel
{
    PickupDetailViewController * vc=(PickupDetailViewController *)[StoryBoardUtiles viewContollerInMainWithIdentifier:StoryBoardUtiles.PICKUP_DETAIL_VC];
    vc.isPickup=NO;
    vc.tripModel=tripModel;
    [self.navigationController pushViewController:vc animated:YES];
    
}

-(void) doSimpleNativeCall:(TripModel *)trip
{
    
    NSString  * phoneWithCode=[Utilities numeroParaLlamarConCodigo:trip.user.c_code numero:trip.user.u_phone];
    NSURL *phoneUrl = [NSURL URLWithString:[@"telprompt://"stringByAppendingString:phoneWithCode]];
    NSURL *phoneFallbackUrl = [NSURL URLWithString:[@"tel://" stringByAppendingString:phoneWithCode]];
    
    
    // Sin numero la URL se queda en "telprompt://" y abriria el marcador en blanco. Cayendo
    // al else sale el aviso de que no se puede llamar, que es lo que el usuario necesita oir.
    if (phoneWithCode.length > 0 && [UIApplication.sharedApplication canOpenURL:phoneUrl]) {
        [[UIApplication sharedApplication] openURL:phoneUrl options:@{} completionHandler:nil];
    } else if (phoneWithCode.length > 0 && [UIApplication.sharedApplication canOpenURL:phoneFallbackUrl]) {
        [UIApplication.sharedApplication openURL:phoneFallbackUrl options:@{} completionHandler:nil];
    } else {
        [UtilityClass swa:nil
                               m:[LanguageHelper getStringWithKey:@"k_r33_s8_no_call_facility"]
                     cbt:@"Ok"
                      obt:nil vc:self];
    }
}

-(void)onCallToRiderButonTap:(TripModel *)trip{
    UIAlertController *alertViewcontroller=[UIAlertController alertControllerWithTitle:[LanguageHelper getStringWithKey:@"k_s4_contact"] message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction * actionCall=[UIAlertAction actionWithTitle:[LanguageHelper getStringWithKey:@"k_s5_call_rider"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self doSimpleNativeCall:trip ];
        
    }];
    [actionCall setValue:[UIColor colorNamed:@"app_theame"] forKey:@"titleTextColor"];
    [alertViewcontroller addAction:actionCall];
    if([[ConstantModel getConstantsObject] getCValueFK:ckey_ech]==YES){
        UIAlertAction * actionChat=[UIAlertAction actionWithTitle:[LanguageHelper getStringWithKey:@"k_s5_chat_with_rider"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self openChatViewController];
        }];
        [actionChat setValue:[UIColor colorNamed:@"app_theame"] forKey:@"titleTextColor"];
        [alertViewcontroller addAction:actionChat];
    }
    UIAlertAction *actionCancel=  [UIAlertAction actionWithTitle:[LanguageHelper getStringWithKey:@"k_30_s6_cancel_j"] style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [actionCancel setValue:[UIColor colorNamed:@"app_theame"] forKey:@"titleTextColor"];

    [alertViewcontroller addAction:actionCancel];
    [self.navigationController presentViewController:alertViewcontroller animated:YES completion:^{
        
    }];
    
}





-(void) onAcceptTripStatusInitForTrip:(TripModel *) tripModel{
    
    UIAlertController *alertViewController=[UIAlertController alertControllerWithTitle:@"Trip" message:@"Do you want to continue your current trip?" preferredStyle:UIAlertControllerStyleAlert];
    [alertViewController addAction:[UIAlertAction actionWithTitle:@"NO" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self->driverStatus = TS_ACCEPTED;
        defaults_set_object(TRIP_ID, tripModel.trip_Id);
        defaults_set_object(DRIVER_STATUS,self->driverStatus);
        [self stopLocationUpdate];
        HomeViewController * vcHome=[self.storyboard instantiateViewControllerWithIdentifier:@"HomeViewController"];
        [self.navigationController setViewControllers:@[vcHome] animated:NO];
    }]];
    [alertViewController addAction:[UIAlertAction actionWithTitle:@"YES" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    [self.navigationController presentViewController:alertViewController animated:YES completion:^{
        
    }];
}


-(void) onPickUpTripStatusInitForTrip:(TripModel *) tripModel{
    driverStatus = @"arrive";
    defaults_set_object(TRIP_ID, tripModel.trip_Id);
    defaults_set_object(DRIVER_STATUS, driverStatus);
    AppDelegate *appdelegate = APP_DELEGATE;
    [self stopLocationUpdate];
    HomeViewController * vcHome=[self.storyboard instantiateViewControllerWithIdentifier:@"HomeViewController"];
    [self.navigationController setViewControllers:@[vcHome] animated:NO];
}


-(void) onArrivedTripStatusInitForTrip:(TripModel *) tripModel{
    driverStatus = @"arrive";
    defaults_set_object(TRIP_ID, tripModel.trip_Id);
    defaults_set_object(DRIVER_STATUS, driverStatus);
    [self stopLocationUpdate];
    HomeViewController * vcHome=[self.storyboard instantiateViewControllerWithIdentifier:@"HomeViewController"];
    [self.navigationController setViewControllers:@[vcHome] animated:NO];
}



-(void) onBeginTripStatusInitForTrip:(TripModel *) tripModel
{
    driverStatus = TS_BEGIN;
    defaults_set_object(TRIP_ID, tripModel.trip_Id);
    defaults_set_object(DRIVER_STATUS, driverStatus);
    [self stopLocationUpdate];
    HomeViewController * vcHome=[self.storyboard instantiateViewControllerWithIdentifier:@"HomeViewController"];
    [self.navigationController setViewControllers:@[vcHome] animated:NO];
}






- (IBAction)ButtonMakeCall:(id)sender {
    UIAlertController *alertViewcontroller=[UIAlertController alertControllerWithTitle:[LanguageHelper getStringWithKey:@"k_s4_contact"] message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *actionCall=[UIAlertAction actionWithTitle:[LanguageHelper getStringWithKey:@"k_s5_call_rider"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
            [self doSimpleNativeCall:self->homeDataModel.trip];
       
    }];
    [actionCall setValue:[UIColor colorNamed:@"app_theame"] forKey:@"titleTextColor"];
    [alertViewcontroller addAction:actionCall];
    if([[ConstantModel getConstantsObject] getCValueFK:ckey_ech]==YES){
        UIAlertAction *actionChat=[UIAlertAction actionWithTitle:[LanguageHelper getStringWithKey:@"k_s5_chat_with_rider"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self openChatViewController];
        }];
        [actionChat setValue:[UIColor colorNamed:@"app_theame"] forKey:@"titleTextColor"];
        [alertViewcontroller addAction:actionChat];
    }
    UIAlertAction *actionCancel=[UIAlertAction actionWithTitle:[LanguageHelper getStringWithKey:@"k_30_s6_cancel_j"] style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [actionCancel setValue:[UIColor colorNamed:@"app_theame"] forKey:@"titleTextColor"];
    [alertViewcontroller addAction:actionCancel];
    [self.navigationController presentViewController:alertViewcontroller animated:YES completion:^{
        
    }];
}


-(void) onLeftSwicthChnage{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"change_switch1" object:nil];
    int  availaitity=[[[[NSUserDefaults standardUserDefaults]  objectForKey:P_USER_DICT] objectForKey:P_DRIVER_AVAILAILITY] intValue];
    BOOL isAvailable=NO;
    if(availaitity ==1)  {
        isAvailable=YES;
    }
    if(isAvailable)  {
        [self.locationManager setAllowsBackgroundLocationUpdates:YES];
        if (@available(iOS 11.0, *)) {
            [self.locationManager setShowsBackgroundLocationIndicator:YES];
        } else {
            // Fallback on earlier versions
        }
        [self.locationManager stopUpdatingLocation];
        [self.locationManager startUpdatingLocation];
        defaults_set_object(is_availability_on, @"1");
        [[UpdateUserCurrentLocation sharedInstance] startUpdateCurrentLocation];
        [self manageUiWhenDriverAvailablityON ];
    }else
    {
        NSString * tripID=defaults_object(TRIP_ID);
        if(tripID!=nil&&[tripID intValue]>0)  {
            [self.locationManager setAllowsBackgroundLocationUpdates:YES];
            if (@available(iOS 11.0, *)) {
                [self.locationManager setShowsBackgroundLocationIndicator:YES];
            } else {
                // Fallback on earlier versions
            }
        }else{
            [self.locationManager setAllowsBackgroundLocationUpdates:NO];
            if (@available(iOS 11.0, *)) {
                [self.locationManager setShowsBackgroundLocationIndicator:NO];
            } else {
                // Fallback on earlier versions
            }
        }
        [self.locationManager stopUpdatingLocation];
        [self.locationManager startUpdatingLocation];
        [[UpdateUserCurrentLocation sharedInstance] stopUpdateCurrentLocation];
        defaults_set_object(is_availability_on, @"0");
        [self manageUiWhenDriverAvailablityOFF ];
    }
    NSString * tripID=defaults_object(TRIP_ID);
    if (tripID != nil && [tripID intValue] > 0) {
        if ([driverStatus isEqualToString:TS_WAITING]) {
            self.switchAvalability.hidden = NO;
            self.offLineView.hidden = YES;
            if (_ndOfflinePanel) _ndOfflinePanel.hidden = YES;
        } else {
            self.switchAvalability.hidden = YES;
            self.offLineView.hidden = YES;
            if (_ndOfflinePanel) _ndOfflinePanel.hidden = YES;
        }
    } else {
        self.switchAvalability.hidden = NO;
        self.offLineView.hidden = YES;
        if (_ndOfflinePanel) _ndOfflinePanel.hidden = isAvailable;
    }
}

- (IBAction)swtchAction:(UISwitch *)sender {
    if (sender == _ndPanelSwitch) {
        self.switchAvalability.on = sender.isOn;
    } else if (sender == self.switchAvalability) {
        _ndPanelSwitch.on = sender.isOn;
    }

    [UtilityClass setLH:NO wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
    [[UpdateUserCurrentLocation sharedInstance]  updateDriverActivityLogAvailablity:sender.isOn?@"1":@"0" type:sender.isOn?@"Login":@"Logout" completionBlock:^(id results, NSError *error) {
        [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
        if(error==nil)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"change_switch1" object:nil];
            BOOL turnOn = sender.isOn;
            if (turnOn) {
                [self.locationManager setAllowsBackgroundLocationUpdates:YES];
                if (@available(iOS 11.0, *)) {
                    [self.locationManager setShowsBackgroundLocationIndicator:YES];
                } else {
                    // Fallback on earlier versions
                }
                [self.locationManager stopUpdatingLocation];
                [self.locationManager startUpdatingLocation];
                defaults_set_object(is_availability_on, @"1");
                [[UpdateUserCurrentLocation sharedInstance] startUpdateCurrentLocation];
                [self manageUiWhenDriverAvailablityON ];
            }
            else{
                [self.locationManager setAllowsBackgroundLocationUpdates:NO];
                if (@available(iOS 11.0, *)) {
                    [self.locationManager setShowsBackgroundLocationIndicator:NO];
                } else {
                    // Fallback on earlier versions
                }
                [self.locationManager stopUpdatingLocation];
                [self.locationManager startUpdatingLocation];
                [[UpdateUserCurrentLocation sharedInstance] stopUpdateCurrentLocation];
                defaults_set_object(is_availability_on, @"0");
                [self manageUiWhenDriverAvailablityOFF ];
            }
        }
    }];
    
}

-(void) manageUiWhenDriverAvailablityON
{
    self.switchAvalability.tintColor = [UIColor greenColor];
    [self.switchAvalability setTintColor:[UIColor greenColor]];
    self.switchAvalability.backgroundColor = [UIColor clearColor];
    [self.switchAvalability setBackgroundColor:[UIColor clearColor]];
    self.offLineView.hidden = YES;
    if (_ndOfflinePanel) _ndOfflinePanel.hidden = YES;
    if (!_ndTabContainerView) {
        [self.viewRequestBg setHidden:NO];
        if (!isRequestViewOpen)
            [self.viewRequestBg setConstraintConstant:heightOfRequestView forAttribute:NSLayoutAttributeHeight];
    }
    self.switchAvalability.on = YES;
    if (_ndPanelSwitch) _ndPanelSwitch.on = YES;
    [self updateStatusPill:YES];
    BOOL hasActiveTrip = (defaults_object(TRIP_ID) != nil && [defaults_object(TRIP_ID) length] > 0);
    [self updateNewDesignTabsVisibilityForActiveTrip:hasActiveTrip];
}

-(void) manageUiWhenDriverAvailablityOFF
{
    isRequestViewOpen = NO;
    self.btnRequestExpand.selected = NO;
    [self updateStatusPill:NO];
    NSString *tripId = defaults_object(TRIP_ID);
    BOOL hasTrip = [tripId isKindOfClass:[NSString class]] && [tripId intValue] > 0;
    self.offLineView.hidden = YES;
    if (_ndOfflinePanel) {
        _ndOfflinePanel.hidden = hasTrip;
        if (!hasTrip) {
            [self.view bringSubviewToFront:_ndOfflinePanel];
            if (self.btnmenu.superview.superview) [self.view bringSubviewToFront:self.btnmenu.superview.superview];
            if (self.btnGps) [self.view bringSubviewToFront:self.btnGps];
        }
    }
    if (_ndTabContainerView) _ndTabContainerView.hidden = YES;
    if (_ndCollectionView) _ndCollectionView.hidden = YES;
    if ([tripId intValue] > 0) {
        [self.viewRequestBg setHidden:YES];
        [self.viewRequestBg setConstraintConstant:0 forAttribute:NSLayoutAttributeHeight];
    } else {
        self.switchAvalability.on = NO;
        if (_ndPanelSwitch) _ndPanelSwitch.on = NO;
        [self.viewRequestBg setHidden:YES];
        [self.viewRequestBg setConstraintConstant:0 forAttribute:NSLayoutAttributeHeight];
    }
    self.switchAvalability.layer.cornerRadius = 15;
    self.switchAvalability.clipsToBounds = YES;
    self.switchAvalability.backgroundColor = [UIColor redColor];
    [self.switchAvalability setBackgroundColor:[UIColor redColor]];
    self.switchAvalability.tintColor = [UIColor redColor];
    [self.switchAvalability setTintColor:[UIColor redColor]];
    if (vcOffers != nil) {
        [vcOffers stopAndRemove];
        vcOffers = nil;
    }
    [self.viewRequestCount setBackgroundColor:[UIColor colorNamed:@"Color_Badge"]];
    [self.viewSentOfferCount setBackgroundColor:[UIColor colorNamed:@"color_app_label"]];
//    if([self isDarkMode]){
//        [self.lblSentOffersText setTextColor:UIColor.blackColor];
//    }else{
//        [self.lblSentOffersText setTextColor:UIColor.whiteColor];
//    }
    [self.lblSentOffersText setTextColor:[UIColor colorNamed:@"color_app_reguest_btbg"]];
    
    [self.lblRequestsText setTextColor:[UIColor colorNamed:@"app_theame"]];
    
    [self.lblRequestCountValue setBackgroundColor:[UIColor colorNamed:@"color_app_label"]];
    [self.lblSentRequestValue setBackgroundColor:UIColor.whiteColor];
    self.lblRequestCountValue.layer.cornerRadius  = 10;
    [self.lblRequestCountValue setClipsToBounds:YES];
    
    self.lblSentRequestValue.layer.cornerRadius  = 10;
    [self.lblSentRequestValue setClipsToBounds:YES];
    
    NSAttributedString * attributedStringPart1=[[NSAttributedString alloc] initWithString:[LanguageHelper getStringWithKey:@"k_63_s4_reqs"]
                                                                               attributes:@{
        NSFontAttributeName:FONTS_THEME_BOLD_NO_SCALE(20),NSForegroundColorAttributeName:[UIColor colorNamed:@"color_app_label"],NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle),NSUnderlineColorAttributeName:[UIColor colorNamed:@"color_app_label"]}];
    
    NSAttributedString * attributedStringPart2=[[NSAttributedString alloc] initWithString:[LanguageHelper getStringWithKey:@"k_63_s4_view_ofrs"]
                                                                               attributes:@{
        NSFontAttributeName:FONTS_THEME_REGULAR_NO_SCALE(20),NSForegroundColorAttributeName:[UIColor colorNamed:@"color_app_reguest_btbg"]/*[self isDarkMode]?[UIColor blackColor]:[UIColor whiteColor]*/}
    ];
    
    [self.lblRequestsText setAttributedText:attributedStringPart1];
    [self.lblSentOffersText setAttributedText:attributedStringPart2];
    
    [self.lblRequestCountValue setTextColor:[UIColor colorNamed:@"color_app_bg"]];
    [self.lblSentRequestValue setTextColor:[UIColor colorNamed:@"color_app_label"]];
    
    self.lblRequestCountValue.layer.cornerRadius  = 10;
    [self.lblRequestCountValue setClipsToBounds:YES];
}

- (IBAction)onPassengerDetailsButtonTap:(id)sender {
    
    [PassengerDetailsAlertView showPessangeDetails: self.view withData:homeDataModel.trip.trip_customer_details];
}



-(void)onPassengerDetailsButonTap:(TripModel *)trip{
    [PassengerDetailsAlertView showPessangeDetails: self.view withData:trip.trip_customer_details];
}

- (IBAction)onShareRidesButtonTap:(id)sender {
    [ShareRideTripView showShareRide:self.view tripModel:homeDataModel.trip delegate:self];
}

- (IBAction)onRefreshButtonTap:(id)sender {
    NSDictionary *dictUser = [[NSUserDefaults standardUserDefaults]objectForKey:P_USER_DICT];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{
        P_API_KEY :[dictUser objectForKey:P_API_KEY],
    }];
    [UtilityClass setLH:NO wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
    [GIC mkwu:GET_DRIVER_PROFILE
                  d:dict
      isa:NO
           cb:^(id results, NSError *error) {
        [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
        if ([[results objectForKey:P_STATUS] isEqualToString:@"OK"]) {
            NSDictionary * dictDriver;
            if([[results objectForKey:P_RESPONSE] isKindOfClass:[NSDictionary class ]])  {
                dictDriver = [results objectForKey:P_RESPONSE];
            }else   {
                dictDriver = [[results objectForKey:P_RESPONSE]objectAtIndex:0];
            }
            BOOL isVerified=[[dictDriver objectForKey:P_DRIVER_VERIFIED] boolValue];
            defaults_set_object(P_USER_DICT, dictDriver);
            if(isVerified){
                [self getAllPendingTrips:YES];
            }else{
                
            }
        }
    }];
}



-(void) onRefreshDriverVerified{
    [self getAllPendingTrips:YES];
}



-(void)openUpdateDocument{
    
    UploadDocumentViewController *vc =(UploadDocumentViewController *)[StoryBoardUtiles viewContollerWithIdentifier:StoryBoardUtiles.UPLOAD_DOCUMENT name:StoryBoardUtiles.STORYBOARD_SIGNUP];
    vc.isfromProfile=YES;
    [self.navigationController pushViewController:vc animated:YES];
}




-(void)openMailComposer{
    if([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mailCont = [[MFMailComposeViewController alloc] init];
        mailCont.mailComposeDelegate = self;
        ConstantModel *  constantModel =[ConstantModel getConstantsObject];;
        NSString * supportEmail = isEmpty(constantModel.support_email);
        NSMutableArray  *arrayEmails=[[NSMutableArray alloc]  init];
        [arrayEmails addObject:supportEmail];
        [mailCont setToRecipients:arrayEmails];
        [self presentViewController:mailCont animated:YES completion:nil];
    }else if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"googlegmail://"]]){
        NSString * supportEmail = isEmpty([ConstantModel getConstantsObject].support_email);
        NSString *to = supportEmail;
        NSString *subject = [LanguageHelper getStringWithKey:@"k_9_s5_support_subject"];
        NSString *gmailURLString = [NSString stringWithFormat:@"googlegmail:///co?to=%@&subject=%@",
                                    [to stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]],
                                    [subject stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
        
        NSURL *gmailURL = [NSURL URLWithString:gmailURLString];
        
        // Open the URL
        [[UIApplication sharedApplication] openURL:gmailURL options:@{} completionHandler:^(BOOL success) {
            if (!success) {
                NSLog(@"Failed to open Gmail app");
            }
        }];
    }
    else  {
        [UtilityClass swa:@"Whoops!" m:[LanguageHelper getStringWithKey:@"k_65_s4_config_mail"] cbt:[LanguageHelper getStringWithKey:@"k_18_s4_Ok"] obt:nil vc:self];
    }
}


-(void)backToRider{
    [APP_DELEGATE onDriverSwitchButtonTap:nil];
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    if(error!= nil) {
        [self showWarningWithMessgae:[NSString stringWithFormat:@" ERROR %@",error]];
        return;
    }
    [controller dismissViewControllerAnimated:YES completion:nil];
}




-(void) setUpChatUnreadCount{
    if([[ConstantModel getConstantsObject] getCValueFK:ckey_ech]==YES)
    {
        if(_firebaseUnReadChat)  {
            [_firebaseUnReadChat stopObserverForCount];
            _firebaseUnReadChat=nil;
        }
        if(homeDataModel.trip==nil)  {
            return;
        }
        _firebaseUnReadChat=[[FirebaseUnReadChat alloc] initWithChannId:homeDataModel.trip.trip_Id];
        [_firebaseUnReadChat startObserverForCount];
    }
}



-(void) updateUnReadCount{
    if([[ConstantModel getConstantsObject] getCValueFK:ckey_ech]==YES){
        
        if([_firebaseUnReadChat messageCount]>0) {
            self.viewReadMessage.hidden=NO;
            self.lblMessage.text=[_firebaseUnReadChat lastMessagText];
            [self.btnPhone setBadgeString:[NSString stringWithFormat:@"%d",[_firebaseUnReadChat messageCount]]];
            
            [self.btnPhone setBadgeBackgroundColor:[UIColor redColor]];
            if (timerBlink) {
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
            
            
        }else  {
            if (timerBlink)  {
                [timerBlink invalidate];
                timerBlink=nil;
            }
            self.viewReadMessage.hidden=YES;
            [self.btnPhone setBadgeString:@""];
            [self.btnPhone hideWhenZero];
            [self.btnPhone setBadgeBackgroundColor:[UIColor clearColor]];
        }
        
    }
}




- (IBAction)onChatViewOpenTap:(id)sender {
    [self openChatViewController];
}




-(void)blink{
    if(blinkStatus == NO){
        _viewReadMessage.backgroundColor = [UIColor colorNamed:@"color_app_bg"];
        
        blinkStatus = YES;
    }else {
        _viewReadMessage.backgroundColor = RGB(255, 192, 0 );
        blinkStatus = NO;
    }
}


#pragma  -mark  Single trip requst handle


-(void) view:(SingleRequestView *) view onAcceptTripSuccess:(TripModel *) trip{
    [view removeFromSuperview];
    defaults_set_object(TRIP_ID, trip.trip_Id);
    singleRequestView=nil;
    // Pill stays hidden — driver now has an active trip (no header-based home screen)
    [self refreshOnAcceptTrip:trip];

}


-(void) view:(SingleRequestView *) view onRejectTripSuccess:(TripModel *) trip{
    [view removeFromSuperview];
    singleRequestView=nil;
    _ndStatusPillContainer.hidden = NO;
    [self refreshONRejectTrip:trip];
}


-(void) view:(SingleRequestView *) view onCloseTripRequest:(TripModel *) trip{
    [view removeFromSuperview];
    singleRequestView=nil;
    _ndStatusPillContainer.hidden = NO;
    homeDataModel.trip=nil;
    [self getAllPendingTrips:NO];
    [self ndRefreshFloatingOffersList];
}


- (void)handleErrorApi:(NSError *)error{
    [Utilities handleError:error viewController:self defaultMessage:@""];
}
/**
 
 */

-(BOOL) canConsiderDriverIsFree{
    NSString *status =defaults_object(DRIVER_STATUS);
    if ( status ==nil ||[status isEqualToString:TS_WAITING] || [status isEqualToString:TS_REQUEST] || [status isEqualToString:TS_END] || [status isEqualToString:TS_DRIVER_CANCEL_AT_PICKUP] || [status isEqualToString:TS_DRIVER_CANCEL_AT_DROP]) {
        return YES;
    }
    return NO;
}


- (IBAction)onDirectionButtonTap:(id)sender {
    
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:[LanguageHelper getStringWithKey:@"k_70_s4_nav"]
                                 message:nil
                                 preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction* yesButton = [UIAlertAction
                                actionWithTitle:[LanguageHelper getStringWithKey:@"k_69_s4_google_maps"]
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action) {
        CLLocation *locationSource;
        if ([self->homeDataModel.trip.trip_Status isEqualToString:TS_BEGIN]) {
            locationSource=[[CLLocation alloc]  initWithLatitude:[self->homeDataModel.trip.trip_drop_lat doubleValue] longitude:[self->homeDataModel.trip.trip_drop_long doubleValue]];
        }
        else{
            locationSource=[[CLLocation alloc]   initWithLatitude:[self->homeDataModel.trip.trip_pick_lat doubleValue]  longitude:[self->homeDataModel.trip.trip_pick_long doubleValue]];
        }
        NSURL *testURL = [NSURL URLWithString:@"comgooglemaps://"];
        NSString *directionsRequest = @"comgooglemaps://?daddr=%f,%f&x-success=sourceapp://?resume=true&x-source=AirApp";
        directionsRequest=[NSString stringWithFormat:directionsRequest,locationSource.coordinate.latitude,locationSource.coordinate.longitude];
        if ([[UIApplication sharedApplication] canOpenURL:testURL]) {
            NSURL *directionsURL = [NSURL URLWithString:directionsRequest];
            [[UIApplication sharedApplication] openURL:directionsURL options:@{}completionHandler:^(BOOL success) {
                
            }];
        } else {
            NSString * string=[NSString stringWithFormat:@"https://www.google.com/maps/@%f,%f",locationSource.coordinate.latitude,locationSource.coordinate.longitude];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:string] options:@{}completionHandler:^(BOOL success) {
                
            }];
        }
    }];
    [yesButton setValue:[UIColor colorNamed:@"app_theame"] forKey:@"titleTextColor"];
    [alert addAction:yesButton];
    
    NSURL *wazeURL = [NSURL URLWithString:@"waze://"];
    if([[UIApplication sharedApplication] canOpenURL:wazeURL]){
        UIAlertAction* wazeButton = [UIAlertAction
                                     actionWithTitle:[LanguageHelper getStringWithKey:@"k_68_s4_waze"]
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction * action) {
            NSString *bundleIdentifier = NSBundle.mainBundle.bundleIdentifier;
            CLLocation *locationSource;
            if ([self->homeDataModel.trip.trip_Status isEqualToString:TS_BEGIN]) {
                locationSource=[[CLLocation alloc]  initWithLatitude:[self->homeDataModel.trip.trip_drop_lat doubleValue] longitude:[self->homeDataModel.trip.trip_drop_long doubleValue]];
            }
            else{
                locationSource=[[CLLocation alloc]   initWithLatitude:[self->homeDataModel.trip.trip_pick_lat doubleValue]  longitude:[self->homeDataModel.trip.trip_pick_long doubleValue]];
            }
            NSString *urlStr =
            [NSString stringWithFormat:@"https://waze.com/ul?ll=%f,%f&navigate=yes&utm_source=%@",
             locationSource.coordinate.latitude, locationSource.coordinate.longitude, bundleIdentifier];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlStr] options:@{}completionHandler:^(BOOL success) {
                
            }];
        }];
        [wazeButton setValue:[UIColor colorNamed:@"app_theame"] forKey:@"titleTextColor"];
        [alert addAction:wazeButton];
    }
    
    UIAlertAction* cancel = [UIAlertAction
                             actionWithTitle:[LanguageHelper getStringWithKey:@"k_30_s6_cancel_j"]
                             style:UIAlertActionStyleCancel
                             handler:^(UIAlertAction * action) {
    }];
    [cancel setValue:[UIColor colorNamed:@"app_theame"] forKey:@"titleTextColor"];
    [alert addAction:cancel];
    
    [self presentViewController:alert animated:YES completion:nil];
}

/**
   make driver free if any pending trip not found
 */

-(void) handleGetPendingsErrorOrEmptyTripWithOnavailableOn{
    [self.view endEditing:YES];
    self.viewOtpVerify.hidden=YES;
    self.btnShareRides.hidden=YES;
    [[DataBase shareDataBase] deleteWatingForAllTripID];
    if([self isAvailablityOn]){
        [[UpdateUserCurrentLocation sharedInstance]  updateDriverAvailablity:@"1"];
    }else{
        NSString * trip_id = defaults_object(TRIP_ID);
        BOOL hasTrip = [trip_id isKindOfClass:[NSString class]] && [trip_id intValue]>0;
        self.offLineView.hidden = YES;
        _ndOfflinePanel.hidden = hasTrip;
    }
    [self clearAllTripReleatedData];
    [self setDriverFree];
}



/**
  clear all local  data in  releated to trip and set driver status   waiting
 */

-(void) clearAllTripReleatedData{
    defaults_remove(TRIP_ID);
    defaults_set_object(DRIVER_STATUS,TS_WAITING);
    defaults_remove(@"wait_time_start");
    defaults_remove(@"cal_wait_time");
}

/**
  hide and show offline message
 */

-(void) hideAndShowOffLineMessageView{
    if ([self isAvailablityOn]) {
        self.offLineView.hidden = YES;
        if (_ndOfflinePanel) _ndOfflinePanel.hidden = YES;
        [self updateStatusPill:YES];
        BOOL hasActiveTrip = (defaults_object(TRIP_ID) != nil && [defaults_object(TRIP_ID) length] > 0);
        [self updateNewDesignTabsVisibilityForActiveTrip:hasActiveTrip];
    } else {
        NSString *trip_id = defaults_object(TRIP_ID);
        BOOL hasTripId = [trip_id isKindOfClass:[NSString class]] && [trip_id intValue] > 0;
        self.offLineView.hidden = YES;
        if (_ndOfflinePanel) {
            _ndOfflinePanel.hidden = hasTripId;
            if (!hasTripId) {
                [self.view bringSubviewToFront:_ndOfflinePanel];
                if (self.btnmenu.superview.superview) [self.view bringSubviewToFront:self.btnmenu.superview.superview];
                if (self.btnGps) [self.view bringSubviewToFront:self.btnGps];
            }
        }
        [self updateStatusPill:NO];
        if (_ndTabContainerView) _ndTabContainerView.hidden = YES;
        if (_ndCollectionView) _ndCollectionView.hidden = YES;
    }
}



/**
   Handle  request view open and hide
 */
-(void) hideAndShowReqestView{
    [self hideAndShowReqestView:[self isAvailablityOn]];
}
-(void) hideAndShowReqestView:(BOOL) isHide{
    if(isHide){
        if (!_ndTabContainerView) {
            self.viewRequestBg.hidden = NO;
            if(!isRequestViewOpen){
                [_viewRequestBg setConstraintConstant:heightOfRequestView forAttribute:NSLayoutAttributeHeight];
            }
        }
    }else{
        self.viewRequestBg.hidden = YES;
        [_viewRequestBg setConstraintConstant:0 forAttribute:NSLayoutAttributeHeight];
    }
}


/**
  check driver availablity  return yes if driver availbale
 */

-(BOOL) isAvailablityOn{
    NSDictionary * dictUser=defaults_object(P_USER_DICT);
    int isAvailable=0;
    if(dictUser!=nil ){
        isAvailable= [[dictUser objectForKey:P_DRIVER_AVAILAILITY]intValue];
    }
    if(isAvailable>0){
        return YES;
    }
    return NO;
}


/**
  this method is called by  notification when driver logout form app
 */

-(void)onDriverLogout{
    [[UpdateUserCurrentLocation sharedInstance] stopUpdateCurrentLocation];
    [self stopLocationUpdate];
    
}



/**
  stop all timer and   remove register notification observer and location manager
 */
-(void)stopLocationUpdate{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.mapView removeFromSuperview];
    self.mapView=nil;
    [self invalidateMapCentertimer];
    [self invalidatePendingTripTimer];
    if(self.locationManager){
        [self.locationManager stopUpdatingLocation];
        [self.locationManager stopUpdatingHeading];
        self.locationManager=nil;
    }
    [self purgeMapMemory];
    if(vcOffers!=nil){
        [vcOffers stopAndRemove];
        vcOffers=nil;
    }
    [self stopTimerForRefresNotificationCount];
    [APP_DELEGATE setNavigationController:nil];
}
- (void)purgeMapMemory
{
    // Switching map types causes cache purging, so switch to a different map type
    self.mapView.mapType = MKMapTypeStandard;
    [self.mapView removeFromSuperview];
    self.mapView = nil;
}

- (IBAction)onOpenRequestButtonTap:(id)sender {
    DTripOffersViewContoller *vc = [[UIStoryboard storyboardWithName:@"Taxi" bundle:nil] instantiateViewControllerWithIdentifier:@"DTripOffersViewContoller"];
    vc.delegate=self;
    [self.navigationController pushViewController:vc animated:YES];
}


-(void)openOfferTripDetail1WithTripOffer:(TripOffer *)tripOffer{
//    [self.navigationController popToRootViewControllerAnimated:NO];
//    if(self->singleRequestView==nil)  {
//        self->singleRequestView=[SingleRequestView showTripRequestAcceptViewWithDelegate:self parentView:self.view tripIdFromRequest:tripOffer.trip];
//        self->singleRequestView.delegate=self;
//    }
    SentOfferDetailsViewController *vc=[[UIStoryboard storyboardWithName:@"ExtraFeature" bundle:nil] instantiateViewControllerWithIdentifier:@"SentOfferDetailsViewController"];
    vc.trip=tripOffer;
    vc.delegate=self;
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)onUserOfferAcceptedByDriver:(SentOfferDetailsViewController *)viewController{
    [self onTripOfferAcceptedByRiderWithTrip:viewController.trip.trip];
}

-(void)onTripOfferAcceptedByRiderWithTrip:(TripModel *)trip{
    NSString * cancelAt = [NSString stringWithFormat:@"%@",[Utilities getStringFromDate:[NSDate date]]];
    [self saveTripLogFor:TS_ACCEPTED timeAt:cancelAt];
    [self.navigationController popToRootViewControllerAnimated:NO];
    self.viewRequestBg.hidden=YES;
    [self refreshOnAcceptTrip:trip];
}

-(void)replaceWithOfferTripDetail1WithTripOffer:(TripOffer *)tripOffer{
    [self.navigationController popToRootViewControllerAnimated:NO];
    self.viewRequestBg.hidden=YES;
    [_viewRequestBg setConstraintConstant:0 forAttribute:NSLayoutAttributeHeight];
    [self refreshOnAcceptTrip:tripOffer.trip];
}

-(void)onTripOfferAcceptedByRiderApiWithTrip:(TripModel *)trip{
    [self.navigationController popToRootViewControllerAnimated:NO];
    self.viewRequestBg.hidden=YES;
    [_viewRequestBg setConstraintConstant:0 forAttribute:NSLayoutAttributeHeight];
    [self refreshOnAcceptTrip:trip];
}

-(void)handleAfterTripRequestExpiredOrCancelWithIsShowAlert:(BOOL)isShowAlert{
    [self.navigationController popToRootViewControllerAnimated:NO];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (textField ==self.txtTripOtp && textField.text.length >= 4&& range.length == 0){
        return NO;
    }
    else{
        return YES;
    }
}

- (IBAction)onSendOffer:(id)sender {
    if(vcOffers==nil){
        vcOffers = [[UIStoryboard storyboardWithName:@"Taxi" bundle:nil] instantiateViewControllerWithIdentifier:@"DTripOffersViewContoller"];
        vcOffers.delegate=self;
        [self addChildViewController:vcOffers];
        int topArea=0;
        if (@available(iOS 11.0, *)) {
            UIWindow *window = UIApplication.sharedApplication.windows.firstObject;
            topArea = window.safeAreaInsets.top;
            CGFloat bottomPadding = window.safeAreaInsets.bottom;
            topArea=bottomPadding ;
        }
        topArea=topArea+46;
        [vcOffers.view setFrame:CGRectMake(0.0f, 0.0f, SCREEN_WIDTH, SCREEN_HEIGHT-topArea)];
        [self.view addSubview:vcOffers.view];
        [vcOffers didMoveToParentViewController:self];
        [vcOffers.view setHidden:YES];
    }else{
        if (!_ndShowingSolicitudes) {
            [vcOffers refloadData];
        }
    }
    [self.viewSentOfferCount setBackgroundColor:[UIColor colorNamed:@"Color_Badge"]];
    [self.viewRequestCount  setBackgroundColor:[UIColor colorNamed:@"color_app_label"]];
//    [self.viewRequestCount setBackgroundColor:[UIColor colorNamed:@"app_theame"]];
//    [self.viewSentOfferCount setBackgroundColor:[UIColor colorNamed:@"app_theame"]];
    [self.lblRequestsText setTextColor:[UIColor colorNamed:@"color_app_label"]];
    [self.lblSentOffersText setTextColor:[UIColor colorNamed:@"app_theame"]];
    
    
    
    
    [self.lblRequestCountValue setBackgroundColor:[UIColor colorNamed:@"color_app_bg"]];
    [self.lblSentRequestValue setBackgroundColor:[UIColor colorNamed:@"color_app_label"]];
    
    [self.lblRequestCountValue setTextColor:[UIColor colorNamed:@"color_app_label"]];
    [self.lblSentRequestValue setTextColor:[UIColor colorNamed:@"color_app_bg"]];
    
    
    self.lblRequestCountValue.layer.cornerRadius  = 10;
    [self.lblRequestCountValue setClipsToBounds:YES];
    self.lblSentRequestValue.layer.cornerRadius  = 10;
    [self.lblSentRequestValue setClipsToBounds:YES];
    
    NSAttributedString * attributedStringPart1=[[NSAttributedString alloc] initWithString:[LanguageHelper getStringWithKey:@"k_63_s4_reqs"]
                                                                               attributes:@{
        NSFontAttributeName:FONTS_THEME_REGULAR_NO_SCALE(20),NSForegroundColorAttributeName:[UIColor colorNamed:@"color_app_bg"]}];
    
    NSAttributedString * attributedStringPart2=[[NSAttributedString alloc] initWithString:[LanguageHelper getStringWithKey:@"k_63_s4_view_ofrs"]
                                                                               attributes:@{
        NSFontAttributeName:FONTS_THEME_BOLD_NO_SCALE(20),NSForegroundColorAttributeName:[UIColor colorNamed:@"color_app_label"],NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle),NSUnderlineColorAttributeName:[UIColor colorNamed:@"color_app_label"]}
    ];
    [self.lblRequestsText setAttributedText:attributedStringPart1];
    [self.lblSentOffersText setAttributedText:attributedStringPart2];
    
}


-(void)menuButtonTaped{
    [self ButtonMenuPressed:nil];
   
}

- (IBAction)onRequestsView:(id)sender {
    [vcOffers.view setHidden:YES];
    if(sender!=nil){
        [self getAllPendingTrips:NO];
    }
    [self.viewRequestCount setBackgroundColor:[UIColor colorNamed:@"Color_Badge"]];
    [self.viewSentOfferCount setBackgroundColor:[UIColor colorNamed:@"color_app_label"]];
    
//    [self.viewRequestCount setBackgroundColor:[UIColor colorNamed:@"app_theame"]];
//    [self.viewSentOfferCount setBackgroundColor:[UIColor colorNamed:@"app_theame"]];
//
//    if([self isDarkMode]){
//        [self.lblSentOffersText setTextColor:UIColor.blackColor];
//    }else{
//        [self.lblSentOffersText setTextColor:UIColor.whiteColor];
//    }
    [self.lblSentOffersText setTextColor:[UIColor colorNamed:@"color_app_reguest_btbg"]];
    
    
    [self.lblRequestsText setTextColor:[UIColor colorNamed:@"app_theame"]];
    
    [self.lblRequestCountValue setBackgroundColor:[UIColor colorNamed:@"color_app_label"]];
    if([self isDarkMode]){
        [self.lblSentRequestValue setBackgroundColor:[UIColor blackColor]];
    }else{
        [self.lblSentRequestValue setBackgroundColor:[UIColor whiteColor]];
    }
    self.lblRequestCountValue.layer.cornerRadius  = 10;
    [self.lblRequestCountValue setClipsToBounds:YES];
    
    self.lblSentRequestValue.layer.cornerRadius  = 10;
    [self.lblSentRequestValue setClipsToBounds:YES];
    
    NSAttributedString * attributedStringPart1=[[NSAttributedString alloc] initWithString:[LanguageHelper getStringWithKey:@"k_63_s4_reqs"]
                                                                               attributes:@{
        NSFontAttributeName:FONTS_THEME_BOLD_NO_SCALE(20),NSForegroundColorAttributeName:[UIColor colorNamed:@"color_app_label"],NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle),NSUnderlineColorAttributeName:[UIColor colorNamed:@"color_app_label"]}];
    
    NSAttributedString * attributedStringPart2=[[NSAttributedString alloc] initWithString:[LanguageHelper getStringWithKey:@"k_63_s4_view_ofrs"]
                                                                               attributes:@{
        NSFontAttributeName:FONTS_THEME_REGULAR_NO_SCALE(20),NSForegroundColorAttributeName:[UIColor colorNamed:@"color_app_reguest_btbg"]/*[self isDarkMode]?[UIColor blackColor]:[UIColor whiteColor]*/}
    ];
    [self.lblRequestsText setAttributedText:attributedStringPart1];
    [self.lblSentOffersText setAttributedText:attributedStringPart2];
    
    [self.lblRequestCountValue setTextColor:[UIColor colorNamed:@"color_app_bg"]];
    [self.lblSentRequestValue setTextColor:[UIColor colorNamed:@"color_app_label"]];
    
    self.lblRequestCountValue.layer.cornerRadius  = 10;
    [self.lblRequestCountValue setClipsToBounds:YES];
}
-(void) updateOnGoingCounter{
    if(self->arrPendingTripsonGoing.count>0){
        self.lblOnGoingCounter.text = [NSString stringWithFormat:@"%lu", (unsigned long)self->arrPendingTripsonGoing.count];
        self.lblOnGoingCounter.hidden=NO;
    }else{
        self.lblOnGoingCounter.text = @"0";
        self.lblOnGoingCounter.hidden=YES;
    }
}
-(void) updateRquestCounter{
    if(self->arrPendingTrips.count>0){
        self.lblRequestCountValue.text = [NSString stringWithFormat:@"%lu", (unsigned long)self->arrPendingTrips.count];
        self.lblRequestCountValue.hidden=NO;
    }else{
        self.lblRequestCountValue.text = @"0"; 
        self.lblRequestCountValue.hidden=YES;
    }
}
-(BOOL)canShowAlertForOfferWithDict:(NSDictionary *)dict{
    
    if(vcOffers.view.isHidden||(![self.navigationController.topViewController isKindOfClass:[HomeViewController class]])){
        NSString * alert =[dict objectForKey:@"alert"];
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@""
                                                                                 message:alert                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *actionOk = [UIAlertAction actionWithTitle:[LanguageHelper getStringWithKey:@"k_30_s6_cancel_j"]
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * _Nonnull action) {
           
        }];
        [alertController addAction:actionOk];
        UIAlertAction *actionViewOffers = [UIAlertAction actionWithTitle:[LanguageHelper getStringWithKey:@"k_63_s4_view_ofrs"]
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * _Nonnull action) {
            [self.navigationController popToRootViewControllerAnimated:NO];
            [self onSendOffer:nil];
        }];
        [alertController addAction:actionViewOffers];
        [self presentViewController:alertController animated:YES completion:nil];
    }
    return vcOffers.view.isHidden;
}

-(void)updateSentOfferCounterWithCount:(NSInteger)count{
    if(count > 0){
        self.lblSentRequestValue.text = [NSString stringWithFormat:@"%ld", (long)count];
        self.lblSentRequestValue.hidden=NO;
        if (_ndOfertasBadgeLabel) {
            _ndOfertasBadgeLabel.text = [NSString stringWithFormat:@"%ld", (long)count];
            _ndOfertasBadgeLabel.hidden = NO;
        }
    }else{
        self.lblSentRequestValue.text = @"0";
        self.lblSentRequestValue.hidden=YES;
        if (_ndOfertasBadgeLabel) {
            _ndOfertasBadgeLabel.text = @"0";
            _ndOfertasBadgeLabel.hidden = YES;
        }
    }
}


-(void)checkAndHideRequestView:(NSNotification *)notification{
    if (singleRequestView){
        [singleRequestView  checkAndHideRequestView:notification];
    }
}
-(void)checkAndHideRequestViewAccepted:(NSNotification *)notification{
    [self showAlert:@"" message:[LanguageHelper getStringWithKey:@"k_31_s8_another_driver_accepted"]];
}

-(void)showAlertForOfferSent:(NSString *)title message:(NSString *)message{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@""
                                                                             message:message                                                                         preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *actionOk = [UIAlertAction actionWithTitle:[LanguageHelper getStringWithKey:@"k_18_s4_Ok"]
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {
       
    }];
    [alertController addAction:actionOk];
    UIAlertAction *actionViewOffers = [UIAlertAction actionWithTitle:[LanguageHelper getStringWithKey:@"k_63_s4_view_ofrs"]
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {
      
        [self onSendOffer:nil];
    }];
    [alertController addAction:actionViewOffers];
    [self presentViewController:alertController animated:YES completion:nil];
}

-(void)showInCompleteProfilePop{
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"" message:[LanguageHelper getStringWithKey:@"k_s4_ncmplt_prfl"] preferredStyle:(UIAlertControllerStyleAlert)];
    [alert addAction:[UIAlertAction actionWithTitle:[LanguageHelper getStringWithKey:@"k_30_s6_cancel_j"] style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:[LanguageHelper getStringWithKey:@"k_18_s4_Ok"] style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        EditProfileViewController * vc = (EditProfileViewController *)[StoryBoardUtiles viewContollerWithIdentifier:StoryBoardUtiles.EDIT_PROFILE name:StoryBoardUtiles.STORYBOARD_SIGNUP];
        [self.navigationController pushViewController:vc animated:YES];
    }]];
    [self presentViewController:alert animated:YES completion:^{
        
    }];
}

-(void)showInAvalibityOnPop{
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"" message:[LanguageHelper getStringWithKey:@"k_s4_plz_mk_drvr_avlbl"] preferredStyle:(UIAlertControllerStyleAlert)];
    [alert addAction:[UIAlertAction actionWithTitle:[LanguageHelper getStringWithKey:@"k_30_s6_cancel_j"] style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
     
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:[LanguageHelper getStringWithKey:@"k_18_s4_Ok"] style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        
        [self onForceAvailablity];
    }]];
    [self presentViewController:alert animated:YES completion:^{
        
    }];
}


-(void) onForceAvailablity{
    [UtilityClass setLH:NO wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
    [[UpdateUserCurrentLocation sharedInstance]  updateDriverActivityLogAvailablity:@"1" type:@"Login" completionBlock:^(id results, NSError *error) {
        [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
        if ([[results objectForKey:P_STATUS] isEqualToString:@"OK"]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"change_switch1" object:nil];
            [self.locationManager setAllowsBackgroundLocationUpdates:YES];
            if (@available(iOS 11.0, *)) {
                [self.locationManager setShowsBackgroundLocationIndicator:YES];
            } else {
                // Fallback on earlier versions
            }
            [self.locationManager stopUpdatingLocation];
            [self.locationManager startUpdatingLocation];
            defaults_set_object(is_availability_on, @"1");
            [[UpdateUserCurrentLocation sharedInstance] startUpdateCurrentLocation];
            [self manageUiWhenDriverAvailablityON ];
        }
    }];
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
    
    [UtilityClass setLH:NO wt:[LanguageHelper getStringWithKey:@"k_r16_s3_plz_wait"]];
    [GIC mkwerwu:API_SEND_SOS
               d:dictApi       cb:^(id results, NSError *error) {
        self-> sosApiCalled=NO;
        [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_r16_s3_plz_wait"]];
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

-(void)showWalletBalance{
    // New design shows online/offline pill instead of balance — skip
    if (_ndStatusPillContainer != nil) return;
    // Driver dict uses P_DRIVER_WAlLET_AMOUNT (d_wallet), not P_USER_WAlLET_AMOUNT (u_wallet)
    NSDictionary *WalletAmtDict = [[NSUserDefaults standardUserDefaults]objectForKey:P_USER_DICT];
    float walletAmt = [[WalletAmtDict objectForKey:P_DRIVER_WAlLET_AMOUNT] floatValue];
    if(walletAmt < 0) {
        self.lblWalletBalanceValue.textColor=[UIColor redColor];
    }else  {
        self.lblWalletBalanceValue.textColor=RGB(34,139,34);
    }
    CityModel * cityModel=[CityModel getCityByDriverCityId];
    if([cityModel isOnlinePaymentEnabled]==NO){
        self.lblWalletBalanceValue.hidden =YES;
        self.lblWalletBalanceText.hidden =YES;
        self.btnViewSentOffer.hidden =YES;
    }else{
        if(walletAmt == 0){
            self.lblWalletBalanceValue.text = [Utilities formatAmountAndCurrencyZero:walletAmt currency:isEmpty(cityModel.city_cur)];
        }else{
            self.lblWalletBalanceValue.text = [Utilities formatAmountAndCurrency:walletAmt currency:isEmpty(cityModel.city_cur)];
        }
    }

}
-(void)refreshUserProfile{
    NSDictionary * dictUser=defaults_object(P_USER_DICT_LOGGED);
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{
        P_API_KEY :[dictUser objectForKey:P_API_KEY],
    }];
    [GIC mkwerwu:GET_USER_PROFILE     d:dict  cb:^(id results, NSError *error) {
        if ([[results objectForKey:P_STATUS] isEqualToString:@"OK"]) {
            NSDictionary * userDict;
            if([[results objectForKey:P_RESPONSE] isKindOfClass:[NSDictionary class ]]){
                userDict=[results objectForKey:P_RESPONSE];
                defaults_set_object(P_USER_DICT_LOGGED, [results objectForKey:P_RESPONSE]);
            }else {
                if([[results objectForKey:P_RESPONSE] isKindOfClass:[NSArray class ]]) {
                    NSArray *arra=[results objectForKey:P_RESPONSE];
                    if(arra.count>0){
                        defaults_set_object(P_USER_DICT_LOGGED, [arra firstObject]);
                    }
                    
                }
            }
            [self showWalletBalance];
        }
        else{
            
        }
    }];
}


-(void)getNewNotificationSound:(NSNotification *) notificationData {
    [self getNotificationCount];
}
-(void)getNotificationCount{
    NSDictionary * dictDriver=defaults_object(P_USER_DICT);
    if(dictDriver==nil){
        [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
        return;
    }
    BOOL is_login_as_user = [defaults_object(P_IS_USER_LOGIN) boolValue];
    if(is_login_as_user){
        return;
    }
    int dId = [[dictDriver objectForKey:P_DRIVER_ID] intValue];
    if(dId==0){
        return;
    }
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{
        P_API_KEY: isEmpty([dictDriver objectForKey:P_API_KEY]),
        P_DRIVER_ID:isEmpty([dictDriver objectForKey:P_DRIVER_ID])
    }];

    [self stopTimerForRefresNotificationCount];
    [GIC mkwerwu:GET_DRIVER_PROFILE   d:dict     cb:^(id results, NSError *error) {
        [self setTimerForRefresNotificationCount];
        if ([[[results objectForKey:P_STATUS]uppercaseString] isEqualToString:@"OK"]) {
            if ([[results objectForKey:P_RESPONSE] isKindOfClass:[NSArray class]]) {
                NSArray * array=[results objectForKey:P_RESPONSE];
                if(array.count>0){
                    NSDictionary * dictStats=[array objectAtIndex:0];
                    int count=[[dictStats objectForKey:@"unread_count"] intValue]; 
                    if(count==0) {
                        [APP_DELEGATE setNotificationCount:0];
                        [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
                        [self.btnmenu setBadgeString:@""];
                        [self.btnmenu setBadgeBackgroundColor:[UIColor clearColor]];
                        [self.btnmenu setHidden:NO];
                    }else{
                        [APP_DELEGATE setNotificationCount:count];
                        [UIApplication sharedApplication].applicationIconBadgeNumber = count;
                        [self.btnmenu setHidden:NO];
                        [self.btnmenu setBadgeString:@""];
                        [self.btnmenu setBadgeBackgroundColor:[UIColor redColor]];
                    }
                }else{
                    [APP_DELEGATE setNotificationCount:0];
                    [self.btnmenu setHidden:NO];
                    [self.btnmenu setBadgeString:@""];
                }
            }else{
                [APP_DELEGATE setNotificationCount:0];
                [self.btnmenu setHidden:NO];
                [self.btnmenu setBadgeString:@""];
            }
        }else{
            [APP_DELEGATE setNotificationCount:0];
            [self.btnmenu setHidden:NO];
            [self.btnmenu setBadgeString:@""];
            [self.btnmenu setBadgeBackgroundColor:[UIColor redColor]];
        }
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"constant_api_called"
         object:nil];
    }];
}
-(void)setTimerForRefresNotificationCount{
    [self stopTimerForRefresNotificationCount];
    timerForRefreshNotificationCount = [NSTimer scheduledTimerWithTimeInterval: 5*60 target: self
                                                       selector: @selector(timerForRefresNotificationCount) userInfo: nil repeats: NO];
}

-(void)stopTimerForRefresNotificationCount{
    if(timerForRefreshNotificationCount){
        [timerForRefreshNotificationCount invalidate];
        timerForRefreshNotificationCount=nil;
    }
}
-(void)timerForRefresNotificationCount{
    [self getNotificationCount];
}

#pragma mark - New Design (driver home)

/// Builds the Solicitudes / Ofertas tab bar pinned at the bottom of the header (below menu/status row).
- (void)buildTabRow {
    // White container bar
    _ndTabContainerView = [[UIView alloc] init];
    _ndTabContainerView.translatesAutoresizingMaskIntoConstraints = NO;
    _ndTabContainerView.backgroundColor = UIColor.whiteColor;
    [self.view addSubview:_ndTabContainerView];

    UIView *headerStack = self.viewSentOffer.superview;
    if (headerStack) {
        [NSLayoutConstraint activateConstraints:@[
            [_ndTabContainerView.topAnchor constraintEqualToAnchor:headerStack.bottomAnchor],
            [_ndTabContainerView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
            [_ndTabContainerView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
            [_ndTabContainerView.heightAnchor constraintEqualToConstant:46],
        ]];
    } else {
        UILayoutGuide *safe = self.view.safeAreaLayoutGuide;
        [NSLayoutConstraint activateConstraints:@[
            [_ndTabContainerView.topAnchor constraintEqualToAnchor:safe.topAnchor],
            [_ndTabContainerView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
            [_ndTabContainerView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
            [_ndTabContainerView.heightAnchor constraintEqualToConstant:46],
        ]];
    }

    _ndTabSolicitudesBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [_ndTabSolicitudesBtn setTitle:[LanguageHelper getStringWithKey:@"k_63_s4_reqs" defaultValue:@"Solicitudes"] forState:UIControlStateNormal];
    _ndTabSolicitudesBtn.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [_ndTabSolicitudesBtn setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    _ndTabSolicitudesBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [_ndTabSolicitudesBtn addTarget:self action:@selector(ndSolicitudesTabTap:) forControlEvents:UIControlEventTouchUpInside];

    _ndTabOfertasBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [_ndTabOfertasBtn setTitle:[LanguageHelper getStringWithKey:@"k_63_s4_view_ofrs" defaultValue:@"Ofertas"] forState:UIControlStateNormal];
    _ndTabOfertasBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [_ndTabOfertasBtn setTitleColor:[UIColor colorWithWhite:0.5 alpha:1] forState:UIControlStateNormal];
    _ndTabOfertasBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [_ndTabOfertasBtn addTarget:self action:@selector(ndOfertasTabTap:) forControlEvents:UIControlEventTouchUpInside];

    // Badge circle on Solicitudes
    _ndBadgeLabel = [[UILabel alloc] init];
    _ndBadgeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _ndBadgeLabel.text = @"0";
    _ndBadgeLabel.font = [UIFont boldSystemFontOfSize:11];
    _ndBadgeLabel.textColor = UIColor.whiteColor;
    _ndBadgeLabel.backgroundColor = UIColor.blackColor;
    _ndBadgeLabel.textAlignment = NSTextAlignmentCenter;
    _ndBadgeLabel.layer.cornerRadius = 11;
    _ndBadgeLabel.layer.masksToBounds = YES;
    _ndBadgeLabel.hidden = YES;

    // Badge circle on Ofertas (sent offers count)
    _ndOfertasBadgeLabel = [[UILabel alloc] init];
    _ndOfertasBadgeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _ndOfertasBadgeLabel.text = @"0";
    _ndOfertasBadgeLabel.font = [UIFont boldSystemFontOfSize:11];
    _ndOfertasBadgeLabel.textColor = UIColor.whiteColor;
    _ndOfertasBadgeLabel.backgroundColor = UIColor.blackColor;
    _ndOfertasBadgeLabel.textAlignment = NSTextAlignmentCenter;
    _ndOfertasBadgeLabel.layer.cornerRadius = 11;
    _ndOfertasBadgeLabel.layer.masksToBounds = YES;
    _ndOfertasBadgeLabel.hidden = YES;

    // Tab row stack
    UIStackView *tabStack = [[UIStackView alloc] initWithArrangedSubviews:@[_ndTabSolicitudesBtn, _ndTabOfertasBtn]];
    tabStack.translatesAutoresizingMaskIntoConstraints = NO;
    tabStack.axis = UILayoutConstraintAxisHorizontal;
    tabStack.distribution = UIStackViewDistributionFillEqually;
    tabStack.alignment = UIStackViewAlignmentFill;
    [_ndTabContainerView addSubview:tabStack];
    [_ndTabContainerView addSubview:_ndBadgeLabel];
    [_ndTabContainerView addSubview:_ndOfertasBadgeLabel];

    [NSLayoutConstraint activateConstraints:@[
        [tabStack.leadingAnchor constraintEqualToAnchor:_ndTabContainerView.leadingAnchor],
        [tabStack.trailingAnchor constraintEqualToAnchor:_ndTabContainerView.trailingAnchor],
        [tabStack.bottomAnchor constraintEqualToAnchor:_ndTabContainerView.bottomAnchor constant:-3],
        [tabStack.heightAnchor constraintEqualToConstant:40],
        [_ndBadgeLabel.leadingAnchor constraintEqualToAnchor:_ndTabSolicitudesBtn.trailingAnchor constant:-28],
        [_ndBadgeLabel.centerYAnchor constraintEqualToAnchor:_ndTabSolicitudesBtn.centerYAnchor],
        [_ndBadgeLabel.widthAnchor constraintEqualToConstant:22],
        [_ndBadgeLabel.heightAnchor constraintEqualToConstant:22],
        [_ndOfertasBadgeLabel.leadingAnchor constraintEqualToAnchor:_ndTabOfertasBtn.trailingAnchor constant:-28],
        [_ndOfertasBadgeLabel.centerYAnchor constraintEqualToAnchor:_ndTabOfertasBtn.centerYAnchor],
        [_ndOfertasBadgeLabel.widthAnchor constraintEqualToConstant:22],
        [_ndOfertasBadgeLabel.heightAnchor constraintEqualToConstant:22],
    ]];

    _ndTabIndicator = [[UIView alloc] init];
    _ndTabIndicator.translatesAutoresizingMaskIntoConstraints = NO;
    _ndTabIndicator.backgroundColor = [UIColor colorNamed:@"app_theame"];
    _ndTabIndicator.layer.cornerRadius = 1.5;
    [_ndTabContainerView addSubview:_ndTabIndicator];
    [NSLayoutConstraint activateConstraints:@[
        [_ndTabIndicator.bottomAnchor constraintEqualToAnchor:_ndTabContainerView.bottomAnchor],
        [_ndTabIndicator.heightAnchor constraintEqualToConstant:3],
        [_ndTabIndicator.leadingAnchor constraintEqualToAnchor:_ndTabSolicitudesBtn.leadingAnchor],
        [_ndTabIndicator.widthAnchor constraintEqualToAnchor:_ndTabSolicitudesBtn.widthAnchor],
    ]];

    // Bottom separator line
    UIView *sep = [[UIView alloc] init];
    sep.translatesAutoresizingMaskIntoConstraints = NO;
    sep.backgroundColor = [UIColor colorWithWhite:0.88 alpha:1];
    [_ndTabContainerView addSubview:sep];
    [NSLayoutConstraint activateConstraints:@[
        [sep.bottomAnchor constraintEqualToAnchor:_ndTabContainerView.bottomAnchor],
        [sep.leadingAnchor constraintEqualToAnchor:_ndTabContainerView.leadingAnchor],
        [sep.trailingAnchor constraintEqualToAnchor:_ndTabContainerView.trailingAnchor],
        [sep.heightAnchor constraintEqualToConstant:1],
    ]];

    _ndShowingSolicitudes = YES;
}

- (void)updateNewDesignTabsVisibilityForActiveTrip:(BOOL)hasActiveTrip {
    if (!_ndTabContainerView && !_ndCollectionView) return;
    BOOL hideTabs = hasActiveTrip || ![self isAvailablityOn];
    _ndTabContainerView.hidden = hideTabs;
    _ndCollectionView.hidden = hideTabs;
    if (_ndStatusPillContainer) {
        _ndStatusPillContainer.hidden = NO;
    }
}

- (void)buildRequestsCollectionView {
    if (!_ndSentOffers) _ndSentOffers = [NSMutableArray array];
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.minimumLineSpacing = 12;

    _ndCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    _ndCollectionView.translatesAutoresizingMaskIntoConstraints = NO;
    _ndCollectionView.backgroundColor = UIColor.clearColor;
    _ndCollectionView.contentInset = UIEdgeInsetsMake(16, 0, 80, 0);
    _ndCollectionView.showsVerticalScrollIndicator = NO;
    _ndCollectionView.delegate   = self;
    _ndCollectionView.dataSource = self;
    [_ndCollectionView registerClass:[RequestCardCell class] forCellWithReuseIdentifier:@"RequestCardCell"];
    [_ndCollectionView registerClass:[OfferCardCell class] forCellWithReuseIdentifier:@"OfferCardCell"];
    [self.view addSubview:_ndCollectionView];

    [NSLayoutConstraint activateConstraints:@[
        [_ndCollectionView.topAnchor constraintEqualToAnchor:_ndTabContainerView.bottomAnchor],
        [_ndCollectionView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [_ndCollectionView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [_ndCollectionView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
    ]];

    if (!vcOffers) {
        vcOffers = [[UIStoryboard storyboardWithName:@"Taxi" bundle:nil] instantiateViewControllerWithIdentifier:@"DTripOffersViewContoller"];
        vcOffers.delegate = self;
        (void)[vcOffers view];
    }
}

#pragma mark - UICollectionView DataSource / Delegate (Ride Requests)

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (_ndShowingSolicitudes)
        return (NSInteger)arrPendingTrips.count;
    return (NSInteger)_ndSentOffers.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (_ndShowingSolicitudes) {
        RequestCardCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"RequestCardCell" forIndexPath:indexPath];
        TripModel *trip = arrPendingTrips[indexPath.item];
        [cell configureWithTrip:trip];
        return cell;
    }
    OfferCardCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"OfferCardCell" forIndexPath:indexPath];
    TripOffer *offer = _ndSentOffers[indexPath.item];
    cell.delegate = self;
    [cell configureWithOffer:offer];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (_ndShowingSolicitudes) {
        TripModel *trip = arrPendingTrips[indexPath.item];
        [self requestGetButtonTapWithTrip:trip];
        return;
    }
    TripOffer *offer = _ndSentOffers[indexPath.item];
    [self openOfferTripDetail1WithTripOffer:offer];
}

- (void)offerCardCellDidSelectOffer:(TripOffer *)offer {
    [self openOfferTripDetail1WithTripOffer:offer];
}

- (void)offerCardCellDidRequestCancelOffer:(TripOffer *)offer {
    if (!offer || !vcOffers) return;
    __weak typeof(self) wself = self;
    [vcOffers cancelDriverOfferWithOffer:offer completion:^(BOOL success) {
        typeof(self) sself = wself;
        if (!sself || !success) return;
        NSMutableArray *offers = sself->_ndSentOffers;
        for (NSInteger i = 0; i < (NSInteger)offers.count; i++) {
            TripOffer *o = offers[i];
            if (o.trip_request_id && offer.trip_request_id && [o.trip_request_id isEqualToString:offer.trip_request_id]) {
                [offers removeObjectAtIndex:(NSUInteger)i];
                break;
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [sself->_ndCollectionView reloadData];
            [sself updateSentOfferCounterWithCount:sself->_ndSentOffers.count];
        });
    }];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat w = collectionView.bounds.size.width;
    if (w < 100) w = UIScreen.mainScreen.bounds.size.width;
    if (_ndShowingSolicitudes)
        return CGSizeMake(w, 295);
    return CGSizeMake(w, 295);
}

#pragma mark - Tab switching (Solicitudes / Ofertas)

- (void)ndSolicitudesTabTap:(id)sender {
    if (_ndShowingSolicitudes) return;
    _ndShowingSolicitudes = YES;

    [UIView animateWithDuration:0.22 animations:^{
        self->_ndTabIndicator.transform = CGAffineTransformIdentity;
    }];

    _ndTabSolicitudesBtn.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [_ndTabSolicitudesBtn setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    _ndTabOfertasBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [_ndTabOfertasBtn setTitleColor:[UIColor colorWithWhite:0.5 alpha:1] forState:UIControlStateNormal];

    _ndCollectionView.hidden = NO;
    [_ndCollectionView reloadData];
    [self getAllPendingTrips:NO];
}

- (void)ndRefreshFloatingOffersList {
    if (!vcOffers) {
        vcOffers = [[UIStoryboard storyboardWithName:@"Taxi" bundle:nil] instantiateViewControllerWithIdentifier:@"DTripOffersViewContoller"];
        vcOffers.delegate = self;
    }
    (void)[vcOffers view];
    __weak typeof(self) wself = self;
    [vcOffers fetchDriverOffersWithCompletion:^(NSArray<TripOffer *> * _Nonnull offers) {
        typeof(self) sself = wself;
        if (!sself) return;
        dispatch_async(dispatch_get_main_queue(), ^{
            sself->_ndSentOffers = [NSMutableArray arrayWithArray:offers];
            [sself->_ndCollectionView reloadData];
            [sself updateSentOfferCounterWithCount:offers.count];
        });
    }];
}

- (void)ndOfertasTabTap:(id)sender {
    if (!_ndShowingSolicitudes) return;
    _ndShowingSolicitudes = NO;

    CGFloat tabWidth = _ndTabContainerView.bounds.size.width / 2.0;
    [UIView animateWithDuration:0.22 animations:^{
        self->_ndTabIndicator.transform = CGAffineTransformMakeTranslation(tabWidth, 0);
    }];

    _ndTabOfertasBtn.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [_ndTabOfertasBtn setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    _ndTabSolicitudesBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [_ndTabSolicitudesBtn setTitleColor:[UIColor colorWithWhite:0.5 alpha:1] forState:UIControlStateNormal];

    _ndCollectionView.hidden = NO;
    [_ndCollectionView reloadData];
    [self ndRefreshFloatingOffersList];
}

-(void)setupNewDesign {
    self.navigationItem.title = @"Pide un Taxi";

    self.addressViewTop.hidden = YES;
    self.lblWalletBalanceText.hidden  = YES;
    self.lblWalletBalanceValue.hidden = YES;

    self.btnmenu.hidden = NO;
    self.btnmenu.userInteractionEnabled = YES;
    self.btnmenu.backgroundColor = [UIColor colorWithRed:28/255.0 green:28/255.0 blue:30/255.0 alpha:1.0];
    self.btnmenu.layer.cornerRadius = 24;
    self.btnmenu.layer.masksToBounds = YES;
    self.btnmenu.clipsToBounds = YES;
    self.btnmenu.tintColor = UIColor.whiteColor;
    if (@available(iOS 13, *)) {
        UIImageSymbolConfiguration *cfg = [UIImageSymbolConfiguration configurationWithWeight:UIImageSymbolWeightMedium];
        UIImage *menuImg = [UIImage systemImageNamed:@"line.3.horizontal" withConfiguration:cfg];
        [self.btnmenu setImage:menuImg forState:UIControlStateNormal];
    } else {
        [self.btnmenu setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    }
    for (NSLayoutConstraint *c in self.btnmenu.constraints) {
        if (c.firstAttribute == NSLayoutAttributeWidth || c.firstAttribute == NSLayoutAttributeHeight)
            c.constant = 48;
    }
    UIView *menuSup = self.btnmenu.superview;
    if (menuSup) {
        for (NSLayoutConstraint *c in menuSup.constraints) {
            if ((c.firstAttribute == NSLayoutAttributeWidth || c.firstAttribute == NSLayoutAttributeHeight) && c.firstItem == self.btnmenu)
                c.constant = 48;
        }
    }
    [self.btnmenu addTarget:self action:@selector(ButtonMenuPressed:) forControlEvents:UIControlEventTouchUpInside];

    [self applyDriverHeaderSpacing];

    UIView *pillContainer = [[UIView alloc] init];
    pillContainer.translatesAutoresizingMaskIntoConstraints = NO;
    pillContainer.backgroundColor = [UIColor colorWithWhite:0.91 alpha:1];
    pillContainer.layer.cornerRadius = 16;
    pillContainer.layer.masksToBounds = YES;
    pillContainer.clipsToBounds = YES;
    _ndStatusPillContainer = pillContainer;

    UIView *dotView = [[UIView alloc] init];
    dotView.translatesAutoresizingMaskIntoConstraints = NO;
    dotView.backgroundColor = [UIColor colorWithWhite:0.5 alpha:1];
    dotView.layer.cornerRadius = 4;
    dotView.clipsToBounds = YES;
    [pillContainer addSubview:dotView];
    _ndStatusDotView = dotView;

    UILabel *statusLbl = [[UILabel alloc] init];
    statusLbl.translatesAutoresizingMaskIntoConstraints = NO;
    statusLbl.text = [LanguageHelper getStringWithKey:@"k_s10_offline" defaultValue:@"Offline"];
    statusLbl.font = [UIFont systemFontOfSize:13 weight:UIFontWeightSemibold];
    statusLbl.textColor = [UIColor colorWithWhite:0.38 alpha:1];
    [pillContainer addSubview:statusLbl];
    _ndStatusTextLabel = statusLbl;

    [NSLayoutConstraint activateConstraints:@[
        [dotView.widthAnchor constraintEqualToConstant:8],
        [dotView.heightAnchor constraintEqualToConstant:8],
        [dotView.leadingAnchor constraintEqualToAnchor:pillContainer.leadingAnchor constant:12],
        [dotView.centerYAnchor constraintEqualToAnchor:pillContainer.centerYAnchor],
        [statusLbl.leadingAnchor constraintEqualToAnchor:dotView.trailingAnchor constant:6],
        [statusLbl.trailingAnchor constraintEqualToAnchor:pillContainer.trailingAnchor constant:-12],
        [statusLbl.centerYAnchor constraintEqualToAnchor:pillContainer.centerYAnchor],
        [pillContainer.heightAnchor constraintEqualToConstant:32],
    ]];

    // Add pill directly to view, top-right of safe area, same vertical band as menu button
    UILayoutGuide *safe = self.view.safeAreaLayoutGuide;
    [self.view addSubview:pillContainer];
    [NSLayoutConstraint activateConstraints:@[
        [pillContainer.trailingAnchor constraintEqualToAnchor:safe.trailingAnchor constant:-16],
        [pillContainer.topAnchor constraintEqualToAnchor:safe.topAnchor constant:12],
    ]];

    [self buildOfflinePanelView];

    // Apply offline/online visibility: when offline show panel and hide tabs; when online hide panel and show tabs (if no trip)
    [self hideAndShowOffLineMessageView];

    [self styleGpsButtonLikeRider];
    [self applyGpsButtonTrailingSpacing];

    [self.view bringSubviewToFront:self.btnmenu.superview.superview];

    self.viewRequestBg.hidden        = YES;
    self.tableViewPendingTrips.hidden = YES;
    self.btRequests.hidden           = YES;
    self.btOnGoing.hidden            = YES;
    self.viewDivider1.hidden         = YES;
    self.viewDivider2.hidden         = YES;
    self.lblNoData.hidden            = YES;
    self.lblTripRequests.hidden      = YES;
    // self.viewSentOffer is the container row that holds btnmenu — must NOT be hidden
    self.btnViewSentOffer.hidden     = YES;
    self.btnRequestExpand.hidden     = YES;
    self.lblRequestsText.hidden      = YES;
    self.lblSentOffersText.hidden    = YES;
    self.viewRequestCount.hidden     = YES;
    self.viewSentOfferCount.hidden   = YES;

    self.mapviewHeightConstraints.constant = SCREEN_HEIGHT;

    [self buildTabRow];
    [self buildRequestsCollectionView];

    [self buildTripPanelNewDesign];

    [self buildOnTripPanel];

    [self styleAcceptDeclineViewLikeDesign];

    // GPS sits below the request cards so the price label is always tappable
    if (self.btnGps) {
        [self.view bringSubviewToFront:self.btnGps];
    }
    if (_ndTabContainerView) [self.view bringSubviewToFront:_ndTabContainerView];
    if (_ndCollectionView)   [self.view bringSubviewToFront:_ndCollectionView];

    // Re-apply offline/online so tabs are hidden when driver is offline (tabs didn't exist on first hideAndShowOffLineMessageView)
    [self hideAndShowOffLineMessageView];

    // Bring pill above map and any other overlapping views
    if (_ndStatusPillContainer) {
        _ndStatusPillContainer.layer.zPosition = 999;
        [self.view bringSubviewToFront:_ndStatusPillContainer];
    }

    // Force layout so constraint changes (header full width, GPS 15pt right) take effect
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];
}

-(void)applyDriverHeaderSpacing {
    UIView *menuContainer = self.viewSentOffer ?: self.btnmenu.superview;
    if (!menuContainer) return;
    const CGFloat menuInset = 8.0;
    const CGFloat headerHorizontal = 20.0;
    const CGFloat headerHeight = 48.0 + menuInset * 2;

    for (NSLayoutConstraint *c in menuContainer.constraints) {
        if (c.firstAttribute == NSLayoutAttributeHeight && c.firstItem == menuContainer)
            c.constant = headerHeight;
    }
    UIView *stackView = menuContainer.superview;
    if (stackView) {
        for (NSLayoutConstraint *c in stackView.constraints) {
            if (c.firstItem == menuContainer && c.firstAttribute == NSLayoutAttributeHeight)
                c.constant = headerHeight;
        }
    }

    for (NSLayoutConstraint *c in menuContainer.constraints) {
        if (c.secondItem == self.btnmenu && c.secondAttribute == NSLayoutAttributeBottom) {
            c.active = NO;
            break;
        }
    }
    [NSLayoutConstraint activateConstraints:@[
        [self.btnmenu.topAnchor constraintEqualToAnchor:menuContainer.topAnchor constant:menuInset],
    ]];

    if (!stackView || stackView.superview != self.view) return;
    id layoutGuide = nil;
    if (@available(iOS 11.0, *)) {
        layoutGuide = self.view.safeAreaLayoutGuide;
    }
    if (!layoutGuide) return;

    NSMutableArray<NSLayoutConstraint *> *toDeactivate = [NSMutableArray array];
    UIView *owner = self.view;
    for (NSLayoutConstraint *c in owner.constraints) {
        BOOL involvesStack = (c.firstItem == stackView || c.secondItem == stackView);
        BOOL isLeading = (c.firstAttribute == NSLayoutAttributeLeading || c.secondAttribute == NSLayoutAttributeLeading);
        BOOL isTrailing = (c.firstAttribute == NSLayoutAttributeTrailing || c.secondAttribute == NSLayoutAttributeTrailing);
        if (involvesStack && (isLeading || isTrailing))
            [toDeactivate addObject:c];
    }
    [NSLayoutConstraint deactivateConstraints:toDeactivate];

    const CGFloat headerInset = headerHorizontal;
    NSLayoutConstraint *leadingNew = [stackView.leadingAnchor constraintEqualToAnchor:[layoutGuide leadingAnchor] constant:headerInset];
    NSLayoutConstraint *trailingNew = [self.view.safeAreaLayoutGuide.trailingAnchor constraintEqualToAnchor:stackView.trailingAnchor constant:headerInset];
    [NSLayoutConstraint activateConstraints:@[ leadingNew, trailingNew ]];
}

-(void)applyGpsButtonTrailingSpacing {
    if (!self.btnGps) return;
    const CGFloat trailingInset = 15.0;
    const CGFloat gpsSize = 52.0;

    [self.btnGps removeFromSuperview];
    self.btnGps.translatesAutoresizingMaskIntoConstraints = YES;
    CGFloat sw = self.view.bounds.size.width;
    CGFloat safeTop = 0;
    if (@available(iOS 11.0, *)) {
        safeTop = self.view.safeAreaInsets.top;
    }
    CGFloat gpsY = safeTop + 64.0 + 60.0;
    self.btnGps.frame = CGRectMake(sw - trailingInset - gpsSize, gpsY, gpsSize, gpsSize);
    [self.view addSubview:self.btnGps];

    [self.view bringSubviewToFront:self.btnmenu.superview.superview];
    [self.view bringSubviewToFront:self.btnGps];
    if (_ndTabContainerView) [self.view bringSubviewToFront:_ndTabContainerView];
    if (_ndCollectionView)   [self.view bringSubviewToFront:_ndCollectionView];
}

-(void)buildOfflinePanelView {
    self.offLineView.hidden = YES;

    CGFloat pad = 20.0;

    _ndOfflinePanel = [[UIView alloc] init];
    _ndOfflinePanel.backgroundColor = UIColor.whiteColor;
    _ndOfflinePanel.translatesAutoresizingMaskIntoConstraints = NO;
    _ndOfflinePanel.hidden = YES;
    [self.view addSubview:_ndOfflinePanel];

    // Status description label
    UILabel *statusLbl = [[UILabel alloc] init];
    NSString *offlineES = @"Estás desconectado. Conéctate en línea para empezar a recibir solicitudes de viajes";
    NSString *offlineEN = @"You're offline. Connect online to start receiving trip requests";
    NSString *langCode = [LanguageHelper sharedInstance].cunnrentLanguage ?: @"";
    BOOL isES = [langCode hasPrefix:@"es"];
    statusLbl.text = [LanguageHelper getStringWithKey:@"k_1_s14_you_are_offline" defaultValue:(isES ? offlineES : offlineEN)];
    statusLbl.numberOfLines = 2;
    statusLbl.textAlignment = NSTextAlignmentCenter;
    statusLbl.textColor = [UIColor colorWithWhite:0.5 alpha:1];
    statusLbl.font = [UIFont fontWithName:@"NotoSans-Regular" size:14] ?: [UIFont systemFontOfSize:14];
    statusLbl.translatesAutoresizingMaskIntoConstraints = NO;
    [_ndOfflinePanel addSubview:statusLbl];

    // Activity toggle row
    UIView *activityRow = [[UIView alloc] init];
    activityRow.backgroundColor = [UIColor colorWithWhite:0.94 alpha:1];
    activityRow.layer.cornerRadius = 14;
    activityRow.layer.masksToBounds = YES;
    activityRow.translatesAutoresizingMaskIntoConstraints = NO;
    [_ndOfflinePanel addSubview:activityRow];

    UILabel *activityLbl = [[UILabel alloc] init];
    activityLbl.text = [LanguageHelper getStringWithKey:@"k_2_s14_go_online_accept_ride" defaultValue:@"Iniciar actividad"];
    activityLbl.textColor = [UIColor colorWithWhite:0.1 alpha:1];
    activityLbl.font = [UIFont fontWithName:@"NotoSans-Bold" size:16] ?: [UIFont boldSystemFontOfSize:16];
    activityLbl.translatesAutoresizingMaskIntoConstraints = NO;
    [activityRow addSubview:activityLbl];

    UISwitch *sw = [[UISwitch alloc] init];
    sw.onTintColor = [UIColor colorWithRed:0.18 green:0.6 blue:0.28 alpha:1];
    [sw addTarget:self action:@selector(swtchAction:) forControlEvents:UIControlEventValueChanged];
    sw.translatesAutoresizingMaskIntoConstraints = NO;
    _ndPanelSwitch = sw;
    [activityRow addSubview:sw];

    // Panel constraints: full width, pinned to bottom, minimum height so panel is visible when shown
    [NSLayoutConstraint activateConstraints:@[
        [_ndOfflinePanel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [_ndOfflinePanel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [_ndOfflinePanel.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
        [_ndOfflinePanel.heightAnchor constraintGreaterThanOrEqualToConstant:140],
    ]];

    // Activity row bottom — use safe area
    NSLayoutConstraint *rowBottom;
    if (@available(iOS 11, *)) {
        rowBottom = [activityRow.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor constant:-(pad + 15)];
    } else {
        rowBottom = [activityRow.bottomAnchor constraintEqualToAnchor:_ndOfflinePanel.bottomAnchor constant:-(pad + 31)];
    }

    [NSLayoutConstraint activateConstraints:@[
        // Status label
        [statusLbl.topAnchor constraintEqualToAnchor:_ndOfflinePanel.topAnchor constant:20],
        [statusLbl.leadingAnchor constraintEqualToAnchor:_ndOfflinePanel.leadingAnchor constant:pad],
        [statusLbl.trailingAnchor constraintEqualToAnchor:_ndOfflinePanel.trailingAnchor constant:-pad],
        // Activity row
        [activityRow.topAnchor constraintEqualToAnchor:statusLbl.bottomAnchor constant:32],
        [activityRow.leadingAnchor constraintEqualToAnchor:_ndOfflinePanel.leadingAnchor constant:pad],
        [activityRow.trailingAnchor constraintEqualToAnchor:_ndOfflinePanel.trailingAnchor constant:-pad],
        [activityRow.heightAnchor constraintEqualToConstant:56],
        rowBottom,
        // Activity label
        [activityLbl.leadingAnchor constraintEqualToAnchor:activityRow.leadingAnchor constant:16],
        [activityLbl.centerYAnchor constraintEqualToAnchor:activityRow.centerYAnchor],
        // Switch
        [sw.trailingAnchor constraintEqualToAnchor:activityRow.trailingAnchor constant:-16],
        [sw.centerYAnchor constraintEqualToAnchor:activityRow.centerYAnchor],
    ]];
}

-(void)updateStatusPill:(BOOL)isOnline {
    if (_ndStatusPillContainer == nil) return;

    // Backend may mark driver availability as "Offline" even while the driver is on an active trip.
    // When TRIP_ID is present, always show "En Viaje" on the pill.
    NSString *tripId = defaults_object(TRIP_ID);
    BOOL hasActiveTrip = (tripId != nil && [tripId isKindOfClass:[NSString class]] && [tripId intValue] > 0);
    if (hasActiveTrip) {
        NSString *langCode = [LanguageHelper sharedInstance].cunnrentLanguage ?: @"";
        BOOL isES = [langCode hasPrefix:@"es"];
        NSString *defaultTripText = isES ? @"Ocupado" : @"Busy";
        _ndStatusTextLabel.text = [LanguageHelper getStringWithKey:@"k_s10_in_trip" defaultValue:defaultTripText];
        _ndStatusTextLabel.textColor = [UIColor colorWithRed:0.02 green:0.62 blue:0.42 alpha:1];
        _ndStatusDotView.backgroundColor = [UIColor colorWithRed:0.02 green:0.62 blue:0.42 alpha:1];
        _ndStatusPillContainer.backgroundColor = [UIColor colorWithRed:0.87 green:0.97 blue:0.91 alpha:1];
        return;
    }

    if (isOnline) {
        _ndStatusTextLabel.text      = [LanguageHelper getStringWithKey:@"k_s10_online" defaultValue:@"Online"];
        _ndStatusTextLabel.textColor = [UIColor colorWithRed:0.02 green:0.62 blue:0.42 alpha:1];
        _ndStatusDotView.backgroundColor = [UIColor colorWithRed:0.02 green:0.62 blue:0.42 alpha:1];
        _ndStatusPillContainer.backgroundColor = [UIColor colorWithRed:0.87 green:0.97 blue:0.91 alpha:1];
    } else {
        _ndStatusTextLabel.text      = [LanguageHelper getStringWithKey:@"k_s10_offline" defaultValue:@"Offline"];
        _ndStatusTextLabel.textColor = [UIColor colorWithWhite:0.45 alpha:1];
        _ndStatusDotView.backgroundColor = [UIColor colorWithWhite:0.55 alpha:1];
        _ndStatusPillContainer.backgroundColor = [UIColor colorWithWhite:0.91 alpha:1];
    }
}

-(void)styleGpsButtonLikeRider {
    if (!self.btnGps) return;
    CGFloat gpsSize = 52.0;
    self.btnGps.backgroundColor = [UIColor whiteColor];
    self.btnGps.layer.cornerRadius = gpsSize / 2.0;
    self.btnGps.clipsToBounds = NO;
    self.btnGps.layer.shadowColor = [UIColor blackColor].CGColor;
    self.btnGps.layer.shadowOpacity = 0.12f;
    self.btnGps.layer.shadowRadius = 8.0f;
    self.btnGps.layer.shadowOffset = CGSizeMake(0, 3);
    UIImage *gpsImg = [UIImage imageNamed:@"ic_gps_button"];
    if (gpsImg) {
        [self.btnGps setImage:[gpsImg imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
    } else if (@available(iOS 13, *)) {
        UIImage *sysImg = [UIImage systemImageNamed:@"location.fill"];
        [self.btnGps setImage:[sysImg imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        self.btnGps.tintColor = [UIColor colorNamed:@"app_theame"];
    }
    for (NSLayoutConstraint *c in self.btnGps.constraints) {
        if ((c.firstAttribute == NSLayoutAttributeWidth || c.firstAttribute == NSLayoutAttributeHeight) && c.firstItem == self.btnGps)
            c.constant = gpsSize;
    }
    UIView *sup = self.btnGps.superview;
    if (sup) {
        for (NSLayoutConstraint *c in sup.constraints) {
            if ((c.firstAttribute == NSLayoutAttributeWidth || c.firstAttribute == NSLayoutAttributeHeight) && c.firstItem == self.btnGps)
                c.constant = gpsSize;
        }
    }
    if (self.btnGps.constraints.count == 0 && (!sup || sup.constraints.count == 0)) {
        [NSLayoutConstraint activateConstraints:@[
            [self.btnGps.widthAnchor constraintEqualToConstant:gpsSize],
            [self.btnGps.heightAnchor constraintEqualToConstant:gpsSize],
        ]];
    }
}


- (void)styleAcceptDeclineViewLikeDesign {
    if (!self.acceptDeclineView || !self.lblAcceptTitle || !self.btnAccept || !self.btnDecline) return;

    UIColor *darkGrey = [UIColor colorWithWhite:0.25 alpha:1];
    UIColor *lightGrey = [UIColor colorWithWhite:0.93 alpha:1];
    UIColor *yellow = [UIColor colorNamed:@"app_theame"] ?: [UIColor colorWithRed:235/255.0 green:181/255.0 blue:24/255.0 alpha:1.0];
    UIFont *mediumFont = [UIFont fontWithName:@"NotoSans-Medium" size:17] ?: [UIFont systemFontOfSize:17 weight:UIFontWeightMedium];

    self.lblAcceptTitle.text = [LanguageHelper getStringWithKey:@"k_23_s4_client_picked_up"];
    self.lblAcceptTitle.font = mediumFont;
    self.lblAcceptTitle.textColor = darkGrey;
    self.lblAcceptTitle.textAlignment = NSTextAlignmentCenter;

    self.btnDecline.translatesAutoresizingMaskIntoConstraints = NO;
    self.btnAccept.translatesAutoresizingMaskIntoConstraints = NO;
    NSMutableArray *toDeactivate = [NSMutableArray array];
    for (NSLayoutConstraint *c in self.acceptDeclineView.constraints) {
        BOOL involvesDecline = (c.firstItem == self.btnDecline || c.secondItem == self.btnDecline);
        BOOL involvesAccept = (c.firstItem == self.btnAccept || c.secondItem == self.btnAccept);
        BOOL involvesLabel = (c.firstItem == self.lblAcceptTitle || c.secondItem == self.lblAcceptTitle);
        if (involvesDecline || involvesAccept || involvesLabel)
            [toDeactivate addObject:c];
    }
    for (NSLayoutConstraint *c in self.btnDecline.constraints) {
        if (c.firstAttribute == NSLayoutAttributeHeight) [toDeactivate addObject:c];
    }
    for (NSLayoutConstraint *c in self.btnAccept.constraints) {
        if (c.firstAttribute == NSLayoutAttributeHeight) [toDeactivate addObject:c];
    }
    [NSLayoutConstraint deactivateConstraints:toDeactivate];

    self.btnDecline.backgroundColor = lightGrey;
    [self.btnDecline setTitle:[LanguageHelper getStringWithKey:@"k_22_s4_no" defaultValue:@"No"] forState:UIControlStateNormal];
    [self.btnDecline setTitleColor:darkGrey forState:UIControlStateNormal];
    self.btnDecline.titleLabel.font = mediumFont;
    self.btnDecline.layer.cornerRadius = 14;
    self.btnDecline.clipsToBounds = YES;
    if (@available(iOS 13.0, *)) {
        UIImage *xImg = [UIImage systemImageNamed:@"xmark"];
        if (xImg) [self.btnDecline setImage:[xImg imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        self.btnDecline.tintColor = darkGrey;
    }
    self.btnDecline.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    self.btnDecline.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 6);
    self.btnDecline.titleEdgeInsets = UIEdgeInsetsMake(0, 6, 0, 0);

    self.btnAccept.backgroundColor = yellow;
    [self.btnAccept setTitle:[LanguageHelper getStringWithKey:@"k_21_s4_yes" defaultValue:@"Sí"] forState:UIControlStateNormal];
    [self.btnAccept setTitleColor:darkGrey forState:UIControlStateNormal];
    self.btnAccept.titleLabel.font = mediumFont;
    self.btnAccept.layer.cornerRadius = 14;
    self.btnAccept.clipsToBounds = YES;
    if (@available(iOS 13.0, *)) {
        UIImage *checkImg = [UIImage systemImageNamed:@"checkmark"];
        if (checkImg) [self.btnAccept setImage:[checkImg imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        self.btnAccept.tintColor = darkGrey;
    }
    self.btnAccept.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    self.btnAccept.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 6);
    self.btnAccept.titleEdgeInsets = UIEdgeInsetsMake(0, 6, 0, 0);

    const CGFloat btnH = 56;
    const CGFloat pad = 20;
    const CGFloat gap = 12;
    [NSLayoutConstraint activateConstraints:@[
        [self.lblAcceptTitle.topAnchor constraintEqualToAnchor:self.acceptDeclineView.topAnchor constant:20],
        [self.lblAcceptTitle.leadingAnchor constraintEqualToAnchor:self.acceptDeclineView.leadingAnchor constant:pad],
        [self.acceptDeclineView.trailingAnchor constraintEqualToAnchor:self.lblAcceptTitle.trailingAnchor constant:pad],
        [self.btnDecline.topAnchor constraintEqualToAnchor:self.lblAcceptTitle.bottomAnchor constant:20],
        [self.btnDecline.leadingAnchor constraintEqualToAnchor:self.acceptDeclineView.leadingAnchor constant:pad],
        [self.btnDecline.heightAnchor constraintEqualToConstant:btnH],
        [self.btnAccept.topAnchor constraintEqualToAnchor:self.btnDecline.topAnchor],
        [self.btnAccept.leadingAnchor constraintEqualToAnchor:self.btnDecline.trailingAnchor constant:gap],
        [self.acceptDeclineView.trailingAnchor constraintEqualToAnchor:self.btnAccept.trailingAnchor constant:pad],
        [self.btnAccept.widthAnchor constraintEqualToAnchor:self.btnDecline.widthAnchor],
        [self.btnAccept.heightAnchor constraintEqualToConstant:btnH],
    ]];
}


-(void)buildTripPanelNewDesign {
    UIColor *yellow = [UIColor colorNamed:@"app_theame"] ?: [UIColor colorWithRed:235/255.0 green:181/255.0 blue:24/255.0 alpha:1.0];

    UIButton *actionBtn = self.btnGoPopUP;
    actionBtn.backgroundColor = yellow;
    [actionBtn setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    actionBtn.layer.cornerRadius = 16;
    actionBtn.layer.masksToBounds = YES;
    UIFont *boldFont = [UIFont fontWithName:@"NotoSans-Bold" size:17] ?: [UIFont boldSystemFontOfSize:17];
    actionBtn.titleLabel.font = boldFont;
    actionBtn.translatesAutoresizingMaskIntoConstraints = NO;
    actionBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    actionBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 0);
    actionBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 8);

    // Widen action button to fill goPopUpView with 16pt insets
    NSMutableArray *toDeactivate = [NSMutableArray array];
    if (actionBtn.superview) {
        for (NSLayoutConstraint *c in actionBtn.superview.constraints) {
            if ((c.firstItem == actionBtn || c.secondItem == actionBtn) &&
                (c.firstAttribute == NSLayoutAttributeWidth || c.secondAttribute == NSLayoutAttributeWidth ||
                 c.firstAttribute == NSLayoutAttributeLeading || c.secondAttribute == NSLayoutAttributeLeading ||
                 c.firstAttribute == NSLayoutAttributeTrailing || c.secondAttribute == NSLayoutAttributeTrailing))
                [toDeactivate addObject:c];
        }
    }
    if (actionBtn.superview) {
        for (NSLayoutConstraint *c in actionBtn.superview.constraints) {
            if ((c.firstItem == actionBtn || c.secondItem == actionBtn) &&
                (c.firstAttribute == NSLayoutAttributeHeight || c.secondAttribute == NSLayoutAttributeHeight))
                [toDeactivate addObject:c];
        }
    }
    for (NSLayoutConstraint *c in actionBtn.constraints) {
        if (c.firstAttribute == NSLayoutAttributeWidth || c.firstAttribute == NSLayoutAttributeHeight)
            [toDeactivate addObject:c];
    }
    [NSLayoutConstraint deactivateConstraints:toDeactivate];
    if (actionBtn.superview) {
        [NSLayoutConstraint activateConstraints:@[
            [actionBtn.leadingAnchor constraintEqualToAnchor:actionBtn.superview.leadingAnchor constant:16],
            [actionBtn.trailingAnchor constraintEqualToAnchor:actionBtn.superview.trailingAnchor constant:-16],
            [actionBtn.centerYAnchor constraintEqualToAnchor:actionBtn.superview.centerYAnchor],
            [actionBtn.heightAnchor constraintEqualToConstant:56],
        ]];
    }
    UIView *goPopUp = self.goPopUpView;
    if (goPopUp) {
        for (NSLayoutConstraint *c in goPopUp.constraints) {
            if (c.firstItem == goPopUp && c.firstAttribute == NSLayoutAttributeHeight) {
                c.constant = 72;
                break;
            }
        }
    }

    UIView *card = [[UIView alloc] init];
    card.translatesAutoresizingMaskIntoConstraints = NO;
    card.backgroundColor = UIColor.whiteColor;
    card.layer.cornerRadius = 0;
    card.layer.masksToBounds = NO;
    card.layer.shadowColor = [UIColor blackColor].CGColor;
    card.layer.shadowOpacity = 0.09;
    card.layer.shadowRadius = 8;
    card.layer.shadowOffset = CGSizeMake(0, 4);
    card.hidden = YES;
    _ndTripInfoCard = card;
    [self.view addSubview:card];
    // btnmenu is 48pt tall with 8pt top inset → bottom is at safeArea.top + 56, add 8pt gap = +64
    NSLayoutYAxisAnchor *topRef = self.btnmenu ? self.btnmenu.bottomAnchor : self.view.safeAreaLayoutGuide.topAnchor;
    CGFloat topOffset = self.btnmenu ? 8.0 : 64.0;
    [NSLayoutConstraint activateConstraints:@[
        [card.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [card.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [card.topAnchor constraintEqualToAnchor:topRef constant:topOffset],
    ]];

    UIView *avatarWrap = [[UIView alloc] init];
    avatarWrap.translatesAutoresizingMaskIntoConstraints = NO;
    avatarWrap.layer.cornerRadius = 30;
    avatarWrap.clipsToBounds = YES;
    avatarWrap.backgroundColor = [UIColor colorWithWhite:0.88 alpha:1];
    _ndTripAvatarView = avatarWrap;
    [card addSubview:avatarWrap];

    UIImageView *avatarImg = [[UIImageView alloc] init];
    avatarImg.translatesAutoresizingMaskIntoConstraints = NO;
    avatarImg.contentMode = UIViewContentModeScaleAspectFill;
    avatarImg.clipsToBounds = YES;
    avatarImg.tag = 9951;
    [avatarWrap addSubview:avatarImg];
    [NSLayoutConstraint activateConstraints:@[
        [avatarImg.leadingAnchor constraintEqualToAnchor:avatarWrap.leadingAnchor],
        [avatarImg.trailingAnchor constraintEqualToAnchor:avatarWrap.trailingAnchor],
        [avatarImg.topAnchor constraintEqualToAnchor:avatarWrap.topAnchor],
        [avatarImg.bottomAnchor constraintEqualToAnchor:avatarWrap.bottomAnchor],
    ]];
    [NSLayoutConstraint activateConstraints:@[
        [avatarWrap.leadingAnchor constraintEqualToAnchor:card.leadingAnchor constant:16],
        [avatarWrap.topAnchor constraintEqualToAnchor:card.topAnchor constant:16],
        [avatarWrap.widthAnchor constraintEqualToConstant:60],
        [avatarWrap.heightAnchor constraintEqualToConstant:60],
    ]];

    UILabel *nameLbl = [[UILabel alloc] init];
    nameLbl.translatesAutoresizingMaskIntoConstraints = NO;
    nameLbl.font = [UIFont fontWithName:@"NotoSans-Bold" size:15] ?: [UIFont boldSystemFontOfSize:15];
    nameLbl.textColor = [UIColor colorNamed:@"color_app_label"] ?: UIColor.blackColor;
    nameLbl.text = [LanguageHelper getStringWithKey:@"k_s3_passenger_name" defaultValue:@"Pasajero"];
    _ndTripNameLbl = nameLbl;
    [card addSubview:nameLbl];

    UILabel *infoLbl = [[UILabel alloc] init];
    infoLbl.translatesAutoresizingMaskIntoConstraints = NO;
    infoLbl.font = [UIFont fontWithName:@"NotoSans-Regular" size:13] ?: [UIFont systemFontOfSize:13];
    infoLbl.textColor = [UIColor colorWithWhite:0.5 alpha:1];
    infoLbl.text = @"★ 0.0 (0)  •  0.00 km";
    _ndTripInfoLbl = infoLbl;
    [card addSubview:infoLbl];

    [NSLayoutConstraint activateConstraints:@[
        [nameLbl.leadingAnchor constraintEqualToAnchor:avatarWrap.trailingAnchor constant:12],
        [nameLbl.topAnchor constraintEqualToAnchor:avatarWrap.topAnchor constant:6],
        [infoLbl.leadingAnchor constraintEqualToAnchor:nameLbl.leadingAnchor],
        [infoLbl.topAnchor constraintEqualToAnchor:nameLbl.bottomAnchor constant:4],
    ]];

    UIButton *optBtn = [[UIButton alloc] init];
    optBtn.translatesAutoresizingMaskIntoConstraints = NO;
    optBtn.backgroundColor = [UIColor colorWithWhite:0.93 alpha:1];
    optBtn.layer.cornerRadius = 20;
    optBtn.clipsToBounds = YES;
    if (@available(iOS 13, *)) {
        UIImageSymbolConfiguration *cfg = [UIImageSymbolConfiguration configurationWithWeight:UIImageSymbolWeightMedium];
        [optBtn setImage:[UIImage systemImageNamed:@"ellipsis" withConfiguration:cfg] forState:UIControlStateNormal];
        optBtn.tintColor = [UIColor colorWithWhite:0.4 alpha:1];
    } else {
        [optBtn setTitle:@"•••" forState:UIControlStateNormal];
        [optBtn setTitleColor:[UIColor colorWithWhite:0.4 alpha:1] forState:UIControlStateNormal];
    }
    [optBtn addTarget:self action:@selector(onDirectionButtonTap:) forControlEvents:UIControlEventTouchUpInside];
    [card addSubview:optBtn];
    [NSLayoutConstraint activateConstraints:@[
        [optBtn.trailingAnchor constraintEqualToAnchor:card.trailingAnchor constant:-16],
        [optBtn.centerYAnchor constraintEqualToAnchor:avatarWrap.centerYAnchor],
        [optBtn.widthAnchor constraintEqualToConstant:40],
        [optBtn.heightAnchor constraintEqualToConstant:40],
        [nameLbl.trailingAnchor constraintLessThanOrEqualToAnchor:optBtn.leadingAnchor constant:-8],
        [infoLbl.trailingAnchor constraintLessThanOrEqualToAnchor:optBtn.leadingAnchor constant:-8],
    ]];

    UIView *divider = [[UIView alloc] init];
    divider.translatesAutoresizingMaskIntoConstraints = NO;
    divider.backgroundColor = [UIColor colorWithWhite:0.92 alpha:1];
    [card addSubview:divider];
    [NSLayoutConstraint activateConstraints:@[
        [divider.leadingAnchor constraintEqualToAnchor:card.leadingAnchor constant:16],
        [divider.trailingAnchor constraintEqualToAnchor:card.trailingAnchor constant:-16],
        [divider.topAnchor constraintEqualToAnchor:avatarWrap.bottomAnchor constant:16],
        [divider.heightAnchor constraintEqualToConstant:1],
    ]];

    UIButton *cancelBtn = [[UIButton alloc] init];
    cancelBtn.translatesAutoresizingMaskIntoConstraints = NO;
    cancelBtn.backgroundColor = [UIColor colorWithRed:255/255.0 green:225/255.0 blue:222/255.0 alpha:1.0];
    cancelBtn.layer.cornerRadius = 14;
    cancelBtn.clipsToBounds = YES;
    [cancelBtn setTitle:[LanguageHelper getStringWithKey:@"k_r2_s8_cancel_ride" defaultValue:@"Cancelar Viaje"] forState:UIControlStateNormal];
    [cancelBtn setTitleColor:[UIColor colorWithRed:220/255.0 green:53/255.0 blue:69/255.0 alpha:1.0] forState:UIControlStateNormal];
    cancelBtn.titleLabel.font = [UIFont fontWithName:@"NotoSans-Bold" size:15] ?: [UIFont boldSystemFontOfSize:15];
    [cancelBtn addTarget:self action:@selector(onCancelButtonTap:) forControlEvents:UIControlEventTouchUpInside];
    _ndTripCancelBtn = cancelBtn;
    [card addSubview:cancelBtn];
    [NSLayoutConstraint activateConstraints:@[
        [cancelBtn.leadingAnchor constraintEqualToAnchor:card.leadingAnchor constant:16],
        [cancelBtn.trailingAnchor constraintEqualToAnchor:card.trailingAnchor constant:-16],
        [cancelBtn.topAnchor constraintEqualToAnchor:divider.bottomAnchor constant:12],
        [cancelBtn.heightAnchor constraintEqualToConstant:56],
        [cancelBtn.bottomAnchor constraintEqualToAnchor:card.bottomAnchor constant:-16],
    ]];

    self.viewCancelBeforeBegin.alpha = 0;
    self.viewUserInfo.hidden = YES;

    [self.viewCancelBeforeBegin addObserver:self forKeyPath:@"hidden" options:NSKeyValueObservingOptionNew context:NULL];
    _ndTripKvoAdded = YES;
}

-(void)ndUpdateTripInfoCard {
    if (!_ndTripInfoCard) return;

    // Avatar
    UIImageView *avatarImg = (UIImageView *)[_ndTripAvatarView viewWithTag:9951];
    NSString *profile = homeDataModel.trip.user.u_profile_image_path;
    if (avatarImg) {
        if (profile.length > 0) {
            [avatarImg sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", url_base_images, profile]]
                         placeholderImage:[UIImage imageNamed:@"Profile Icon Crop Image"]];
        } else {
            avatarImg.image = [UIImage imageNamed:@"Profile Icon Crop Image"];
        }
    }

    // Name
    _ndTripNameLbl.text = [NSString stringWithFormat:@"%@ %@",
                           homeDataModel.trip.user.u_fname, homeDataModel.trip.user.u_lname];

    // Rating + distance to pickup
    CGFloat rating = homeDataModel.trip.user.rating;
    NSInteger ratingCount = homeDataModel.trip.user.rating_count;
    AppDelegate *appDel = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    CLLocation *curr = appDel.currLoc;
    CLLocation *pickup = [[CLLocation alloc] initWithLatitude:[homeDataModel.trip.trip_pick_lat doubleValue]
                                                    longitude:[homeDataModel.trip.trip_pick_long doubleValue]];
    double distKm = (curr && pickup) ? ([curr distanceFromLocation:pickup] / 1000.0) : 0.0;
    _ndTripInfoLbl.text = [NSString stringWithFormat:@"★ %.1f (%ld)  •  %.2f km", rating, (long)ratingCount, distKm];

    // Sync cancel button initial visibility
    _ndTripCancelBtn.hidden = self.viewCancelBeforeBegin.isHidden;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"hidden"] && object == self.viewCancelBeforeBegin) {
        BOOL isHidden = [change[NSKeyValueChangeNewKey] boolValue];
        dispatch_async(dispatch_get_main_queue(), ^{
            self->_ndTripCancelBtn.hidden = isHidden;
        });
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}


- (void)buildOnTripPanel {
    UIColor *yellow  = [UIColor colorNamed:@"app_theame"] ?: [UIColor colorWithRed:235/255.0 green:181/255.0 blue:24/255.0 alpha:1.0];
    UIColor *darkLbl = [UIColor colorNamed:@"color_app_label"] ?: [UIColor colorWithWhite:0.12 alpha:1];
    UIColor *gray    = [UIColor colorWithWhite:0.52 alpha:1];

    UIView *panel = [[UIView alloc] init];
    panel.translatesAutoresizingMaskIntoConstraints = NO;
    panel.backgroundColor = [UIColor colorWithRed:247/255.0 green:247/255.0 blue:247/255.0 alpha:1.0];
    panel.layer.cornerRadius = 20;
    panel.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
    panel.layer.masksToBounds = NO;
    panel.layer.shadowColor   = [UIColor blackColor].CGColor;
    panel.layer.shadowOpacity = 0.10;
    panel.layer.shadowRadius  = 12;
    panel.layer.shadowOffset  = CGSizeMake(0, -2);
    panel.hidden = YES;
    _ndOnTripPanel = panel;
    [self.view addSubview:panel];
    [NSLayoutConstraint activateConstraints:@[
        [panel.leadingAnchor  constraintEqualToAnchor:self.view.leadingAnchor],
        [panel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [panel.bottomAnchor   constraintEqualToAnchor:self.view.bottomAnchor],
    ]];

    // Drag handle
    UIView *pill = [[UIView alloc] init];
    pill.translatesAutoresizingMaskIntoConstraints = NO;
    pill.backgroundColor = [UIColor colorWithWhite:0.78 alpha:1];
    pill.layer.cornerRadius = 2.5;
    [panel addSubview:pill];
    [NSLayoutConstraint activateConstraints:@[
        [pill.centerXAnchor constraintEqualToAnchor:panel.centerXAnchor],
        [pill.topAnchor     constraintEqualToAnchor:panel.topAnchor constant:10],
        [pill.widthAnchor   constraintEqualToConstant:36],
        [pill.heightAnchor  constraintEqualToConstant:5],
    ]];

    UIButton * (^circleBtn)(NSString *, UIColor *) = ^(NSString *assetName, UIColor *bg) {
        UIButton *b = [UIButton buttonWithType:UIButtonTypeCustom];
        b.translatesAutoresizingMaskIntoConstraints = NO;
        b.backgroundColor = bg;
        b.layer.cornerRadius = 22;
        b.clipsToBounds = YES;
        UIImage *img = [UIImage imageNamed:assetName];
        [b setImage:img forState:UIControlStateNormal];
        [NSLayoutConstraint activateConstraints:@[
            [b.widthAnchor  constraintEqualToConstant:44],
            [b.heightAnchor constraintEqualToConstant:44],
        ]];
        return b;
    };

    UIView * (^makeCard)(void) = ^UIView * {
        UIView *c = [[UIView alloc] init];
        c.translatesAutoresizingMaskIntoConstraints = NO;
        c.backgroundColor = UIColor.whiteColor;
        c.layer.cornerRadius = 14;
        c.layer.masksToBounds = NO;
        c.layer.shadowColor   = [UIColor blackColor].CGColor;
        c.layer.shadowOpacity = 0.06;
        c.layer.shadowRadius  = 6;
        c.layer.shadowOffset  = CGSizeMake(0, 2);
        return c;
    };

    UIView *riderCard = makeCard();
    [panel addSubview:riderCard];
    [NSLayoutConstraint activateConstraints:@[
        [riderCard.topAnchor     constraintEqualToAnchor:pill.bottomAnchor constant:14],
        [riderCard.leadingAnchor constraintEqualToAnchor:panel.leadingAnchor  constant:16],
        [riderCard.trailingAnchor constraintEqualToAnchor:panel.trailingAnchor constant:-16],
    ]];

    // Avatar
    UIView *avatarWrap = [[UIView alloc] init];
    avatarWrap.translatesAutoresizingMaskIntoConstraints = NO;
    avatarWrap.layer.cornerRadius = 26;
    avatarWrap.clipsToBounds = YES;
    avatarWrap.backgroundColor = [UIColor colorWithWhite:0.88 alpha:1];
    _ndOnTripAvatarWrap = avatarWrap;
    [riderCard addSubview:avatarWrap];
    UIImageView *avatarImg = [[UIImageView alloc] init];
    avatarImg.translatesAutoresizingMaskIntoConstraints = NO;
    avatarImg.contentMode = UIViewContentModeScaleAspectFill;
    avatarImg.clipsToBounds = YES;
    avatarImg.tag = 9961;
    [avatarWrap addSubview:avatarImg];
    [NSLayoutConstraint activateConstraints:@[
        [avatarImg.leadingAnchor  constraintEqualToAnchor:avatarWrap.leadingAnchor],
        [avatarImg.trailingAnchor constraintEqualToAnchor:avatarWrap.trailingAnchor],
        [avatarImg.topAnchor      constraintEqualToAnchor:avatarWrap.topAnchor],
        [avatarImg.bottomAnchor   constraintEqualToAnchor:avatarWrap.bottomAnchor],
        [avatarWrap.leadingAnchor constraintEqualToAnchor:riderCard.leadingAnchor constant:14],
        [avatarWrap.centerYAnchor constraintEqualToAnchor:riderCard.centerYAnchor],
        [avatarWrap.widthAnchor   constraintEqualToConstant:52],
        [avatarWrap.heightAnchor  constraintEqualToConstant:52],
        [avatarWrap.topAnchor     constraintGreaterThanOrEqualToAnchor:riderCard.topAnchor constant:14],
        [avatarWrap.bottomAnchor  constraintLessThanOrEqualToAnchor:riderCard.bottomAnchor constant:-14],
    ]];

    // Name label
    UILabel *nameLbl = [[UILabel alloc] init];
    nameLbl.translatesAutoresizingMaskIntoConstraints = NO;
    nameLbl.font = [UIFont fontWithName:@"NotoSans-Bold" size:15] ?: [UIFont boldSystemFontOfSize:15];
    nameLbl.textColor = darkLbl;
    nameLbl.text = [LanguageHelper getStringWithKey:@"k_s3_passenger_name" defaultValue:@"Pasajero"];
    _ndOnTripNameLbl = nameLbl;
    [riderCard addSubview:nameLbl];

    // Info label (rating + distance)
    UILabel *infoLbl = [[UILabel alloc] init];
    infoLbl.translatesAutoresizingMaskIntoConstraints = NO;
    infoLbl.font = [UIFont fontWithName:@"NotoSans-Regular" size:13] ?: [UIFont systemFontOfSize:13];
    infoLbl.textColor = gray;
    infoLbl.text = @"★ 0.0 (0)  •  0.00 km";
    _ndOnTripInfoLbl = infoLbl;
    [riderCard addSubview:infoLbl];

    [NSLayoutConstraint activateConstraints:@[
        [nameLbl.leadingAnchor constraintEqualToAnchor:avatarWrap.trailingAnchor constant:12],
        [nameLbl.topAnchor     constraintEqualToAnchor:avatarWrap.topAnchor constant:4],
        [infoLbl.leadingAnchor constraintEqualToAnchor:nameLbl.leadingAnchor],
        [infoLbl.topAnchor     constraintEqualToAnchor:nameLbl.bottomAnchor constant:4],
        [infoLbl.bottomAnchor  constraintLessThanOrEqualToAnchor:riderCard.bottomAnchor constant:-14],
    ]];

    // Action buttons (right side): chat, call
    UIColor *grayBg  = [UIColor colorWithWhite:0.93 alpha:1];

    UIButton *chatBtn = circleBtn(@"ic_trip_chat", grayBg);
    [chatBtn addTarget:self action:@selector(onNdOnTripChatTapped:) forControlEvents:UIControlEventTouchUpInside];
    [riderCard addSubview:chatBtn];

    UIButton *callBtn = circleBtn(@"ic_trip_call", grayBg);
    [callBtn addTarget:self action:@selector(ButtonMakeCall:) forControlEvents:UIControlEventTouchUpInside];
    [riderCard addSubview:callBtn];

    [NSLayoutConstraint activateConstraints:@[
        [callBtn.trailingAnchor constraintEqualToAnchor:riderCard.trailingAnchor  constant:-12],
        [callBtn.centerYAnchor  constraintEqualToAnchor:riderCard.centerYAnchor],
        [chatBtn.trailingAnchor constraintEqualToAnchor:callBtn.leadingAnchor     constant:-8],
        [chatBtn.centerYAnchor  constraintEqualToAnchor:riderCard.centerYAnchor],
        [nameLbl.trailingAnchor constraintLessThanOrEqualToAnchor:chatBtn.leadingAnchor constant:-8],
        [infoLbl.trailingAnchor constraintLessThanOrEqualToAnchor:chatBtn.leadingAnchor constant:-8],
        [riderCard.heightAnchor constraintEqualToConstant:80],
    ]];

    UIView *payCard = makeCard();
    [panel addSubview:payCard];
    [NSLayoutConstraint activateConstraints:@[
        [payCard.topAnchor     constraintEqualToAnchor:riderCard.bottomAnchor constant:10],
        [payCard.leadingAnchor constraintEqualToAnchor:panel.leadingAnchor  constant:16],
        [payCard.trailingAnchor constraintEqualToAnchor:panel.trailingAnchor constant:-16],
        [payCard.heightAnchor  constraintEqualToConstant:56],
    ]];

    // Cash icon
    UIImageView *cashIcon = [[UIImageView alloc] init];
    cashIcon.translatesAutoresizingMaskIntoConstraints = NO;
    cashIcon.contentMode = UIViewContentModeScaleAspectFit;
    cashIcon.image = [UIImage imageNamed:@"ic_trip_cash"];
    [payCard addSubview:cashIcon];
    [NSLayoutConstraint activateConstraints:@[
        [cashIcon.leadingAnchor  constraintEqualToAnchor:payCard.leadingAnchor constant:14],
        [cashIcon.centerYAnchor  constraintEqualToAnchor:payCard.centerYAnchor],
        [cashIcon.widthAnchor    constraintEqualToConstant:26],
        [cashIcon.heightAnchor   constraintEqualToConstant:26],
    ]];

    UILabel *payMethodLbl = [[UILabel alloc] init];
    payMethodLbl.translatesAutoresizingMaskIntoConstraints = NO;
    payMethodLbl.font = [UIFont fontWithName:@"NotoSans-Regular" size:14] ?: [UIFont systemFontOfSize:14];
    payMethodLbl.textColor = gray;
    payMethodLbl.text = [LanguageHelper getStringWithKey:@"k_r39_s9_cash" defaultValue:@"Paga en Efectivo"];
    _ndOnTripPayMethodLbl = payMethodLbl;
    [payCard addSubview:payMethodLbl];
    [NSLayoutConstraint activateConstraints:@[
        [payMethodLbl.leadingAnchor  constraintEqualToAnchor:cashIcon.trailingAnchor constant:10],
        [payMethodLbl.centerYAnchor  constraintEqualToAnchor:payCard.centerYAnchor],
    ]];

    UILabel *fareLbl = [[UILabel alloc] init];
    fareLbl.translatesAutoresizingMaskIntoConstraints = NO;
    fareLbl.font = [UIFont fontWithName:@"NotoSans-Bold" size:18] ?: [UIFont boldSystemFontOfSize:18];
    fareLbl.textColor = darkLbl;
    fareLbl.textAlignment = NSTextAlignmentRight;
    fareLbl.text = @"--";
    _ndOnTripFareLbl = fareLbl;
    [payCard addSubview:fareLbl];
    [NSLayoutConstraint activateConstraints:@[
        [fareLbl.trailingAnchor  constraintEqualToAnchor:payCard.trailingAnchor constant:-14],
        [fareLbl.centerYAnchor   constraintEqualToAnchor:payCard.centerYAnchor],
        [fareLbl.leadingAnchor   constraintGreaterThanOrEqualToAnchor:payMethodLbl.trailingAnchor constant:8],
    ]];

    UIView *routeCard = makeCard();
    [panel addSubview:routeCard];
    [NSLayoutConstraint activateConstraints:@[
        [routeCard.topAnchor      constraintEqualToAnchor:payCard.bottomAnchor constant:10],
        [routeCard.leadingAnchor  constraintEqualToAnchor:panel.leadingAnchor  constant:16],
        [routeCard.trailingAnchor constraintEqualToAnchor:panel.trailingAnchor constant:-16],
    ]];

    // Pickup icon
    UIImageView *pickIcon = [[UIImageView alloc] init];
    pickIcon.translatesAutoresizingMaskIntoConstraints = NO;
    pickIcon.contentMode = UIViewContentModeScaleAspectFit;
    pickIcon.image = [UIImage imageNamed:@"ic_trip_pickup"];
    [routeCard addSubview:pickIcon];

    UILabel *pickupLbl = [[UILabel alloc] init];
    pickupLbl.translatesAutoresizingMaskIntoConstraints = NO;
    pickupLbl.font = [UIFont fontWithName:@"NotoSans-Bold" size:13] ?: [UIFont boldSystemFontOfSize:13];
    pickupLbl.textColor = darkLbl;
    pickupLbl.numberOfLines = 2;
    pickupLbl.text = [LanguageHelper getStringWithKey:@"k_1_s11_pickup_n_loc" defaultValue:@"Origen"];
    _ndOnTripPickupLbl = pickupLbl;
    [routeCard addSubview:pickupLbl];

    // Dashed vertical connector
    UIView *dashLine = [[UIView alloc] init];
    dashLine.translatesAutoresizingMaskIntoConstraints = NO;
    dashLine.backgroundColor = [UIColor colorWithWhite:0.80 alpha:1];
    [routeCard addSubview:dashLine];

    // Drop icon
    UIImageView *dropIcon = [[UIImageView alloc] init];
    dropIcon.translatesAutoresizingMaskIntoConstraints = NO;
    dropIcon.contentMode = UIViewContentModeScaleAspectFit;
    dropIcon.image = [UIImage imageNamed:@"ic_trip_drop"];
    [routeCard addSubview:dropIcon];

    UILabel *dropLbl = [[UILabel alloc] init];
    dropLbl.translatesAutoresizingMaskIntoConstraints = NO;
    dropLbl.font = [UIFont fontWithName:@"NotoSans-Bold" size:13] ?: [UIFont boldSystemFontOfSize:13];
    dropLbl.textColor = darkLbl;
    dropLbl.numberOfLines = 2;
    dropLbl.text = [LanguageHelper getStringWithKey:@"k_11_s8_search_drop_location" defaultValue:@"Destino"];
    _ndOnTripDropLbl = dropLbl;
    [routeCard addSubview:dropLbl];

    CGFloat iconSz = 20;
    [NSLayoutConstraint activateConstraints:@[
        // pickup icon + label
        [pickIcon.leadingAnchor  constraintEqualToAnchor:routeCard.leadingAnchor constant:16],
        [pickIcon.topAnchor      constraintEqualToAnchor:routeCard.topAnchor constant:16],
        [pickIcon.widthAnchor    constraintEqualToConstant:iconSz],
        [pickIcon.heightAnchor   constraintEqualToConstant:iconSz],
        [pickupLbl.leadingAnchor constraintEqualToAnchor:pickIcon.trailingAnchor constant:12],
        [pickupLbl.trailingAnchor constraintEqualToAnchor:routeCard.trailingAnchor constant:-14],
        [pickupLbl.centerYAnchor constraintEqualToAnchor:pickIcon.centerYAnchor],
        // dashed line
        [dashLine.centerXAnchor constraintEqualToAnchor:pickIcon.centerXAnchor],
        [dashLine.topAnchor     constraintEqualToAnchor:pickIcon.bottomAnchor constant:4],
        [dashLine.widthAnchor   constraintEqualToConstant:2],
        [dashLine.heightAnchor  constraintEqualToConstant:20],
        // drop icon + label
        [dropIcon.leadingAnchor  constraintEqualToAnchor:routeCard.leadingAnchor constant:16],
        [dropIcon.topAnchor      constraintEqualToAnchor:dashLine.bottomAnchor constant:4],
        [dropIcon.widthAnchor    constraintEqualToConstant:iconSz],
        [dropIcon.heightAnchor   constraintEqualToConstant:iconSz],
        [dropLbl.leadingAnchor  constraintEqualToAnchor:dropIcon.trailingAnchor constant:12],
        [dropLbl.trailingAnchor constraintEqualToAnchor:routeCard.trailingAnchor constant:-14],
        [dropLbl.centerYAnchor  constraintEqualToAnchor:dropIcon.centerYAnchor],
        [routeCard.bottomAnchor constraintEqualToAnchor:dropIcon.bottomAnchor constant:16],
    ]];

    UIButton *endBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    endBtn.translatesAutoresizingMaskIntoConstraints = NO;
    endBtn.backgroundColor = yellow;
    endBtn.layer.cornerRadius = 14;
    endBtn.clipsToBounds = YES;
    endBtn.titleLabel.font = [UIFont fontWithName:@"NotoSans-Bold" size:17] ?: [UIFont boldSystemFontOfSize:17];
    [endBtn setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    [endBtn setTitle:[LanguageHelper getStringWithKey:@"k_34_s4_end_ride" defaultValue:@"Fin del viaje"] forState:UIControlStateNormal];
    UIImage *endIcon = [UIImage imageNamed:@"ic_trip_end"];
    if (endIcon) {
        [endBtn setImage:endIcon forState:UIControlStateNormal];
        endBtn.semanticContentAttribute = UISemanticContentAttributeForceRightToLeft;
        endBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
        endBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 10);
    }
    [endBtn addTarget:self action:@selector(ndOnTripFinDelViajeTapped:) forControlEvents:UIControlEventTouchUpInside];
    [panel addSubview:endBtn];

    NSLayoutYAxisAnchor *safeBottom = self.view.safeAreaLayoutGuide.bottomAnchor;
    [NSLayoutConstraint activateConstraints:@[
        [endBtn.topAnchor      constraintEqualToAnchor:routeCard.bottomAnchor constant:12],
        [endBtn.leadingAnchor  constraintEqualToAnchor:panel.leadingAnchor  constant:16],
        [endBtn.trailingAnchor constraintEqualToAnchor:panel.trailingAnchor constant:-16],
        [endBtn.heightAnchor   constraintEqualToConstant:56],
        [endBtn.bottomAnchor   constraintEqualToAnchor:safeBottom constant:-16],
    ]];
}

- (void)ndShowOnTripPanel {
    if (!_ndOnTripPanel) return;
    [self ndUpdateOnTripPanel];
    if (_ndTripInfoCard) _ndTripInfoCard.hidden = YES;
    _goPopUpView.hidden = YES;
    _btnBeginTrip.hidden = YES;
    _ndOnTripPanel.hidden = NO;
    [self.view bringSubviewToFront:_ndOnTripPanel];
    if (self.btnmenu.superview) [self.view bringSubviewToFront:self.btnmenu.superview];
    if (_ndStatusPillContainer) [self.view bringSubviewToFront:_ndStatusPillContainer];
}

- (void)ndUpdateOnTripPanel {
    if (!_ndOnTripPanel) return;

    // Avatar
    UIImageView *avatarImg = (UIImageView *)[_ndOnTripAvatarWrap viewWithTag:9961];
    NSString *profile = homeDataModel.trip.user.u_profile_image_path;
    if (avatarImg) {
        if (profile.length > 0) {
            [avatarImg sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", url_base_images, profile]]
                         placeholderImage:[UIImage imageNamed:@"Profile Icon Crop Image"]];
        } else {
            avatarImg.image = [UIImage imageNamed:@"Profile Icon Crop Image"];
        }
    }

    // Name
    _ndOnTripNameLbl.text = [NSString stringWithFormat:@"%@ %@",
                             homeDataModel.trip.user.u_fname ?: @"",
                             homeDataModel.trip.user.u_lname ?: @""];

    // Rating + distance
    CGFloat rating = homeDataModel.trip.user.rating;
    NSInteger ratingCount = homeDataModel.trip.user.rating_count;
    AppDelegate *appDel = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    CLLocation *curr   = appDel.currLoc;
    CLLocation *pickup = [[CLLocation alloc] initWithLatitude:[homeDataModel.trip.trip_pick_lat doubleValue]
                                                    longitude:[homeDataModel.trip.trip_pick_long doubleValue]];
    double distKm = (curr && pickup) ? ([curr distanceFromLocation:pickup] / 1000.0) : 0.0;
    _ndOnTripInfoLbl.text = [NSString stringWithFormat:@"★ %.1f (%ld)  •  %.2f km", rating, (long)ratingCount, distKm];

    // Payment method
    BOOL isCard = [[homeDataModel.trip.trip_pay_mode lowercaseString] isEqualToString:@"card"] &&
                  homeDataModel.trip.payment_card_id.length > 0;
    _ndOnTripPayMethodLbl.text = isCard ? [LanguageHelper getStringWithKey:@"k_r39_s9_prepaid" defaultValue:@"Prepagado"] : [LanguageHelper getStringWithKey:@"k_r39_s9_cash" defaultValue:@"Paga en Efectivo"];

    // Fare amount
    NSString *fare = homeDataModel.trip.trip_fare;
    if (fare.length > 0) {
        CityModel *cityModel = [CityModel getCityByCityId:homeDataModel.trip.city_id];
        NSString *formatted  = [Utilities formatAmountAndCurrency:[fare floatValue] currency:cityModel.city_cur];
        _ndOnTripFareLbl.text = formatted ?: fare;
    } else {
        _ndOnTripFareLbl.text = @"--";
    }

    // Addresses
    _ndOnTripPickupLbl.text = homeDataModel.trip.trip_pick_loc ?: [LanguageHelper getStringWithKey:@"k_1_s11_pickup_n_loc" defaultValue:@"Origen"];
    _ndOnTripDropLbl.text   = homeDataModel.trip.trip_drop_loc ?: [LanguageHelper getStringWithKey:@"k_11_s8_search_drop_location" defaultValue:@"Destino"];
}

- (IBAction)ndOnTripFinDelViajeTapped:(UIButton *)sender {
    _ndOnTripPanel.hidden = YES;
    _btnBeginTrip.hidden  = YES;
    _lblAcceptTitle.text  = [LanguageHelper getStringWithKey:@"k_24_s4_client_reached_dest"];
    _acceptDeclineView.hidden = NO;
}

- (IBAction)onNdOnTripChatTapped:(UIButton *)sender {
    [self openChatViewController];
}

@end


