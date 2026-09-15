////
//  HomeViewController.m
//  Store_project
//
//  Created by Appicial Taxi App Soutions on 22/05/17.
//  Copyright © 2023 Appicial Taxi App Soutions. All rights reserved.
//

#import "UHomeViewController.h"
#import "ConrraDestinoDePlan.h"
#import "UIViewController+LGSideMenuController.h"
#import "UIView+UpdateAutoLayoutConstraints.h"
#import "NIDropDown.h"
#import <GIKit/GIKit.h>
#import "WebCallConstants.h"
#import "AppDelegate.h"
#import "UIHelper.h"
#import "TripModel.h"
#import "SuggestedLocationCell.h"
#import "SuggestedLocationDataSource.h"
#import "GoogleDirectionSource.h"
#import "DriverModel.h"
#import "UserModel.h"
#import "NearByDriverHandler.h"
#import "BeginTripViewController.h"
#import "CategoryModel.h"
#import "CustomPointAnnotation.h"
#import "UserPinAnnotationView.h"
#import "RadarAnimationView.h"
#import "UpdateUserCurrentLocation.h"
#import "ConstantModel.h"
#import "CategoryCell.h"
#import "Utilities.h"
#import "AboutUsViewController.h"
#import "UIImageView+WebCache.h"
#import <Firebase.h>
#import "FireBaseModel.h"
#import <Conrra-Swift.h>
#import "UIButton+WebCache.h"
#import "FireAnonymousSigupHelper.h"
#import "PromoCodeModel.h"
#import "CityModel.h"
#import <objc/runtime.h>
#import <IQKeyboardManager.h>
#import "MainViewController.h"
#import "UIViewController+Extension.h"
#import "FareChangeViewController.h"
#import "DataUploadHelper.h"
#import "PassengerViewController.h"
#import "UPickupDetailViewController.h"
#import "AskForPassengerVC.h"
#import "DatePickerViewController.h"
#import "EstimateFareInfoViewController.h"
#define DROP_LOCATION @"drop_loc"
#define PICK_LOCATION @"pickup"
#import "HomePaymentViewModel.h"
#import "PaymentMethodListViewController.h"
#import "PaymentMethodViewController.h"
#import <ReactiveObjC/ReactiveObjC.h>
#import "UWalletViewController.h"
#import "UTripHistoryViewController.h"
#import <MessageUI/MFMailComposeViewController.h>
#import "URouteInputViewController.h"
#import "UFareOfferViewController.h"
@interface UHomeViewController ()<SuggestedLocationDataSourceDelegate,NearByDriverHandlerDelegate,NIDropDownDelegate,UIGestureRecognizerDelegate,FIRMessagingDelegate,UITextFieldDelegate,TripOffersViewContollerDelegate,FareChangeViewControllerDelegate,AskForPassengerVCDelegate,DatePickerViewControllerDelegate,CategoryCellDelegate,EstimateFareInfoViewControllerDelegate,PaymentMethodListViewControllerDelegate,PaymentMethodViewControllerDelegate,UTripHistoryViewControllerDelegate,MFMailComposeViewControllerDelegate,URouteInputDelegate,UFareOfferDelegate>
{
    BOOL isDragged;
    double angle;
    NSArray *driversArray;
    MKPointAnnotation *userPin;
    TripModel *currTrip;
    NSString *driverStatus;
    NSMutableArray *arrayCagetgory;
    ConstantModel *constantTaxiModel;
    NSString *userAvailability;
    GoogleDirectionSource * direction;
    UIButton * selectedButton;
    UIImageView *selectedCatImage;
    NearByDriverHandler * nearByDriverHandler;
    NSString * currentTripStatus;
    SuggestedLocationDataSource * locationDataSourcePickup, * locationDataSourceDrop;
    
    float  tripDistance, sharePrice, tripDistanceConvertedInUnit;
    int tripTime;
    NSMutableArray * arrAnotation,* arrayDriversAnnotation,*arrayFakeDriversAnnotation;
    
    BOOL isMapRouteMake,isMapDraged, isCarEstimatePrice;
    UIPanGestureRecognizer *panRec;
    UIPinchGestureRecognizer *pinchRec;
    CLLocationCoordinate2D centerCoordinate;
    NSMutableArray *arrButtons;
    NSMutableArray *arrButtonsImages;
    NSMutableArray *arrFareInfoButtons;
    //    NSMutableArray *arrCategory;
    BOOL isHome,isShowFareView;
    
    int apiCallAttempt, apiCounter;
    CLLocationCoordinate2D emptyLoc;
    NSString *btnPickupState;
    NSString *btnDropState;
    BOOL isPickupSelected,isDropSelected, isAcceptNotCalled;
    
    CustomPointAnnotation * pickUpPin,* dropPin;
    UIAlertController *PickerAlertView;
    NSMutableArray *arrayBoundryCoordinates;
    
    MKPolygon *polygonFirst;
    MKPolygon *polygonSecond;
    MKPolygon *polygonThird;
    MKPolygon *polygonPickup;
    NSTimer *tripStatusTimer;
    PromoCodeModel *promoCode ;
    DirectionModel * directionModel;
    NIDropDown *dropDown;
    CityModel *cityModel;
    CategoryModel * Selectedcategory;
    NSTimer *tripCheckTimerForMyLocation;
    
    BOOL isShwoPickUpLocationOnLoad;
    /// Para no lanzar dos geocodificaciones de la recogida a la vez.
    BOOL resolviendoRecogida;
    BOOL isRideLaterButtonTap;
    BOOL isShareRideButtonTap;
    BOOL isShowFarePolicyButtonTap;
    NSDate * selectedRideLaterDate;
    BOOL isFirstTime;
    BOOL isGoToHomeScreen;
    BookingModel *_bookingModel;
    BOOL isFareCalculated;
    NSString *pickupNotes;
    /** "Pago con $20, necesito vuelto en Bs." Solo cuando se paga en efectivo. */
    NSString *instruccionesDeEfectivo;
    /** "Cash|Mascotas|3 Pasajero(s)": lo que se configuro al pedir, no lo que se escribio. */
    NSString *configDelViaje;
    BOOL sosApiCalled;
    NSTimer *timerForResetPickDrop;
    HomePaymentViewModel * paymentViewModel;
    NSTimer *timerForRefreshNotificationCount;
    NSMutableArray *arrayUpCommingRides;
    NSTimer *timerForStartAnimation;
    NSMutableArray * arrayAllFakeDrivers;

    // Map reskin
    CustomPointAnnotation *userLocationAnnotation;
    RadarAnimationView    *radarView;
    UIView                *mapDimOverlay;

    // Home screen redesign
    BOOL      isSheetSetup;
    BOOL      isReturningFromRouteInput; // prevents viewWillAppear reset when popping Screen 2
    BOOL      isReturningFromFareOffer;  // prevents viewWillAppear reset when dismissing Screen 3
    BOOL      pendingScreen3Presentation; // present Screen 3 once fare API returns
    UIView   *homeBottomSheet;
    UIView   *homeTopBar;
    CGFloat   sheetCollapsedY;
    CGFloat   sheetExpandedY;
    /** Fila de categorias del servidor. Antes eran dos tarjetas fijas. */
    UIScrollView *vehicleCardsScroll;
    /** "2,6 km - 9 min" sobre el mapa mientras se elige la tarifa. */
    UILabel *pildoraRuta;
    NSMutableArray<UIView *> *vehicleCards;
    NSInteger selectedVehicleIndex;
    UILabel  *homeAvailabilityLabel;
    UFareOfferViewController *currentFareOfferVC;
}

//@property (nonatomic, strong) DateTimePickerView *dateTimePicker;

/// Recoge el destino que la seccion Sitios dejo preparado. Se declara aqui porque se
/// llama a si misma desde un bloque, sobre una referencia debil tipada.
-(void)aplicarDestinoDePlanSiHay:(NSInteger)intentosRestantes;

@end

@implementation UHomeViewController

-(void)setupTextField:(UITextField*)textField{
    [self setTextFieldPlaceholderColor:textField];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    if([[ConstantModel getConstantsObject] getCValueFK:ckey_epp]==NO){
        self.heightPrePayment.constant = 0;
        self.viewPrePayment.hidden=YES;
        self.marginTopPrePayment.constant = 0;
    }
    paymentViewModel = [[HomePaymentViewModel alloc] init:1];
    [self.btnMenu setHidden:YES];
    [self.btnMenu setHideWhenZero:YES];
    [self.btnMenu setBadgeBackgroundColor:[UIColor clearColor]];
    [self.btnMenu setBadgeEdgeInsets:UIEdgeInsetsMake( 18,-19, 2,5)];
    self.viewUpcommingRide.hidden =YES;
    [self.viewUpcommingRide setConstraintConstant:0 forAttribute:(NSLayoutAttributeHeight)];
    self.lblUpComingRides.text=@"";
    RAC(self.lblPaymentMode,text) = RACObserve(paymentViewModel, paymentModeText);
    RAC(self.imagePaymentMode,image) = RACObserve(paymentViewModel, paymentModeImage);
    RAC(_bookingModel,pay_intent) = RACObserve(paymentViewModel, paymentMethod);
    [self setTextFieldPlaceholderColor:self.txtExtmatedFareAmt];
    self.btCouponApply.hidden=YES;
    self.txtExtmatedFareAmt.delegate=self;
    UIImage * image= [self.imageMenu.image imageWithRenderingMode:(UIImageRenderingModeAlwaysTemplate)];
    self.imageMenu.tintColor=[UIColor colorNamed:@"color_app_label"];
    self.imageMenu.image=image;
    self.showButtonOnView.hidden = YES;
    [Utilities applyGrayTintOnImageView:self.imageGps color:[UIColor colorNamed:@"color_icon_tint"]];
    [self.btnGps.layer setCornerRadius:4];
    [self.btnGps.layer setBorderWidth:1];
    [self.btnGps.layer setBorderColor:[UIColor colorNamed:@"color_app_gray"].CGColor];
    
    [self.btnRemovePromoCode setConstraintConstant:0 forAttribute:NSLayoutAttributeWidth];
    self.lblServiceNotAvailable.hidden=YES;
    [APP_DELEGATE setNavigationController:self.navigationController];
    [self setUIFiels];
    isRideLaterButtonTap=NO;
    _viewRequest.hidden = YES;
    _viewScheduleLater.hidden = YES;
    [self.txtPromocode.layer setCornerRadius:2];
    [self.txtPromocode setClipsToBounds:YES];
    self.txtPromocode.layer.borderWidth=.5;
    self.txtPromocode.layer.borderColor=[UIColor lightGrayColor].CGColor;
    [self setupTextField:self.txtPromocode];
    [self.btPromoApply.layer setCornerRadius:2];
    [self.btPromoApply setClipsToBounds:YES];
    [self setTextFieldPlaceholderColor:self.txtCity];
    NSDictionary *dict1 = [[NSUserDefaults standardUserDefaults]objectForKey:P_USER_DICT];
    if([[ConstantModel getConstantsObject] getCValueFK:ckey_ech]==YES){
        [FireAnonymousSigupHelper  checkFireIdAndUpdateInProfileWithComBlock:dict1 comBlock:^(id result, NSError *error) {
            [self updateFireProfile];
        }];
    }
    //Firebase Messaging
    
    [self applyTintOnImageView:self.imageCalloutBg];
    
    self.viewInputOffer.layer.cornerRadius =5;
    self.viewInputOffer.layer.borderWidth =.5;
    self.viewInputOffer.layer.borderColor =[UIColor colorNamed:@"app_border_color"].CGColor;
    self.viewInputOffer.clipsToBounds=YES;
    _btnSelectPickDrop.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _btnSelectPickDrop.titleLabel.numberOfLines = 2;
    [self setTitleForPickDrop:PICK_LOCATION];
    emptyLoc =CLLocationCoordinate2DMake(0.0, 0.0);
    arrButtons =[[NSMutableArray alloc]init];
    
    constantTaxiModel=[ConstantModel getConstantsObject];
    [self setThemeConstants];
    
    tripTime=0;
    isMapDraged=NO;
    tripDistance=0;
    tripDistanceConvertedInUnit=0;
    [self setTextFieldPlaceholderColor:self.txtPickupAddress color:[UIColor grayColor]];
    [self setTextFieldPlaceholderColor:self.txtDestinationAddres color:[UIColor grayColor]];
    arrAnotation=[[NSMutableArray alloc]  init];
    arrayDriversAnnotation=[[NSMutableArray alloc]  init];
    [self.viewRequest.layer setCornerRadius:15];
    [self.viewRequest.layer setBorderWidth:1];
    [self.viewRequest.layer setBorderColor:[UIColor whiteColor].CGColor];
    [self.viewRequest setClipsToBounds:YES];
    
    [self.viewScheduleLater.layer setCornerRadius:15];
    [self.viewScheduleLater.layer setBorderWidth:1];
    [self.viewScheduleLater.layer setBorderColor:[UIColor whiteColor].CGColor];
    [self.viewScheduleLater setClipsToBounds:YES];
    
    direction=[[GoogleDirectionSource alloc]  init];
    direction.isEstimate=YES;
    locationDataSourcePickup=[[SuggestedLocationDataSource alloc]  initWithTableView:self.tableViewPickup textFiled:self.txtPickupAddress];
    locationDataSourceDrop=[[SuggestedLocationDataSource alloc]  initWithTableView:self.tableViewDestination textFiled:self.txtDestinationAddres];
    locationDataSourcePickup.delegate=self;
    locationDataSourceDrop.delegate=self;
    driversArray  =[[NSArray alloc]init];
    [self initMapView];
    nearByDriverHandler=[[NearByDriverHandler alloc]  init];
    nearByDriverHandler.city_id=[NSString stringWithFormat:@"%d", cityModel.city_id];
    nearByDriverHandler.delegate=self;
    apiCallAttempt =0;
    [self getTaxiConstant];
    [[UpdateUserCurrentLocation sharedInstance] startUpdateCurrentLocation];
    // [self addUserInteractionChangeHandlerOnMap ]; // drag-to-select location disabled
    [self checkFor5sScreen];
    [APP_DELEGATE handleNotificationIfHasData];
}

-(void)applyTintOnImageView:(UIImageView*)imageview{
    UIImage *img = [imageview.image imageWithRenderingMode:(UIImageRenderingModeAlwaysTemplate)];
    imageview.tintColor = [UIColor colorNamed:@"color_white_tint"];
    imageview.image = img;
}

-(void)setupTextFieldPassenger:(UITextField*)textField{
    textField.delegate=self;
    [self setTextFieldPlaceholderColor:textField];
}



-(void) setUIFiels{
    self.lblHeader.text = [LanguageHelper getStringWithKey:@"k_r4_s3_book_rride"];
    self.lblSelectCity.text = [LanguageHelper getStringWithKey:@"k_r30_s5_select_city"];
    self.lblPickupLocation.text = [LanguageHelper getStringWithKey:@"k_1_s11_pickup_n_loc"];
    self.txtPickupAddress.placeholder=[LanguageHelper getStringWithKey:@"k_r7_s3_enter_pickup_loc"];
    self.lblOfferAmount.text=[LanguageHelper getStringWithKey:@"k_s3_offer_amt"];
    self.lblDropLocation.text = [LanguageHelper getStringWithKey:@"k_11_s8_search_drop_location"];
    self.txtDestinationAddres.placeholder=[LanguageHelper getStringWithKey:@"k_r8_s3_enter_dest_loc"];
    self.lblServiceNotAvailable.text = [LanguageHelper getStringWithKey:@"k_r51_s3_service_nt_avail"];
    self.txtPromocode.placeholder=[LanguageHelper getStringWithKey:@"k_r49_s3_enter_valid_promo_code"];
    [self.btRiderNow setTitle: [LanguageHelper getStringWithKey:@"k_r18_s3_a1_ride_now"]   forState:UIControlStateNormal];
    [self.btnConfirmBooking setTitle: [LanguageHelper getStringWithKey:@"k_r71_s3_confirm_booking"]   forState:UIControlStateNormal];
    [self.btCouponApply setTitle: [LanguageHelper getStringWithKey:@"k_r45_s3_apply_coupon"]   forState:UIControlStateNormal];
    self.btCouponApply.titleLabel.font=FONTS_THEME_REGULAR_NO_SCALE(15);
    int width = [Utilities widthOfString:[LanguageHelper getStringWithKey:@"k_r45_s3_apply_coupon"] withFont:FONTS_THEME_REGULAR_NO_SCALE(15)];
    [self.btCouponApply setConstraintConstant:width+10 forAttribute:NSLayoutAttributeWidth];
    [self.btPromoApply setTitle: [LanguageHelper getStringWithKey:@"k_r45_s3_apply"]   forState:UIControlStateNormal];
    [self.btPickupDetail setTitle: [NSString stringWithFormat:@"+%@",[LanguageHelper getStringWithKey:@"k_1_s8_note"]]   forState:UIControlStateNormal];
    self.txtExtmatedFareAmt.placeholder = [LanguageHelper getStringWithKey:@"k_3_s5_amount"];
    if ([ConstantModel getConstantsObject].max_decimal_allowed>0){
        self.txtExtmatedFareAmt.keyboardType = UIKeyboardTypeDecimalPad;
    }else{
        self.txtExtmatedFareAmt.keyboardType = UIKeyboardTypeNumberPad;
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // Restore bottom sheet and GPS button whenever we reappear (e.g. after popping Screen 2)
    if (isSheetSetup) {
        homeBottomSheet.hidden = NO;
        self.btnGps.hidden     = NO;
    }
    // Returning from URouteInputViewController — don't reset direction/state.
    // GPS source + any picked data must be preserved so drawRoute works correctly.
    if (isReturningFromRouteInput) {
        isReturningFromRouteInput = NO;
        [self.navigationController setNavigationBarHidden:YES animated:NO];
        return;
    }
    if (isReturningFromFareOffer) {
        isReturningFromFareOffer = NO;
        return;
    }
    /*
     Con la pantalla de tarifa viva NO se reinicia nada.

     El reset de aqui abajo tira `direction` entera y la sustituye por una vacia, que
     es lo correcto al entrar al home de nuevo pero no mientras se esta montando un
     viaje. Cualquier pantalla que se presente en modo FullScreen por encima -- la hoja
     de metodos de pago, sin ir mas lejos -- hace reaparecer el home al cerrarse y
     disparaba este reset a media composicion.

     Arreglar solo la hoja de pago dejaria la trampa puesta para la siguiente pantalla
     que alguien presente igual, asi que la condicion se pone aqui.
     */
    if (currentFareOfferVC != nil) {
        [self.navigationController setNavigationBarHidden:YES animated:NO];
        return;
    }
    if(isShowFarePolicyButtonTap){
        isShowFarePolicyButtonTap=NO;
        if(direction) {
            if (direction.source.coordinate.latitude!=0){
                return;
            }
        }
    }
    [self setUIFiels];
    driversArray  =[[NSArray alloc]init];
    direction=[[GoogleDirectionSource alloc]  init];
    direction.isEstimate=YES;
    [self reset:nil];
    // In the 3-screen flow these legacy views must stay hidden on Screen 1
    // (reset: un-hides viewInputOffer; the others can bleed through too)
    if (isSheetSetup) {
        [self ocultarRestosDelDisenoViejo];
    }
    // El reset acaba de dejar la recogida sin direccion. Se vuelve a resolver en vez
    // de esperar a un aviso del GPS que ya no va a pedir nada.
    [self asegurarDireccionDeRecogida];

    isMapDraged=NO;
    isMapRouteMake=NO;
    isPickupSelected =NO;
    isDropSelected =NO;
    btnPickupState =@"search";
    btnDropState =@"search";
    direction.source =[[CLLocation alloc]initWithLatitude:emptyLoc.latitude longitude:emptyLoc.longitude];
    direction.destination =[[CLLocation alloc]initWithLatitude:emptyLoc.latitude longitude:emptyLoc.longitude];;
    
    NSString *savedTripId=defaults_object(TRIP_ID);
    isHome =YES;
    if(savedTripId!=nil)
    {
        currTrip =[[TripModel alloc]init];
        currTrip.trip_Id = savedTripId ;
        [self checkTripStatus];
        //        [self getPendingTripFromServer];
    }
    else{
        if(nearByDriverHandler)
        {
            [nearByDriverHandler stopGetNearByDriver];
            nearByDriverHandler=nil;
        }
        nearByDriverHandler=[[NearByDriverHandler alloc]  init];
        nearByDriverHandler.delegate=self;
        nearByDriverHandler.city_id=[NSString stringWithFormat:@"%d",cityModel.city_id];
        
        [self.imCenterPickupLocation setHidden:NO];
        [self.viewCallout setHidden:NO];
        [self clearMapView];
        [self.txtDestinationAddres setText:@""];
        [self setUserAnnotation];
        [self getPendingTripFromServerWithLoader:NO];
    }
    
    [nearByDriverHandler  startGettingNearByDriver];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getNewNotificationSound:) name:@"noti_refresh" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDriverLogout) name:@"driver_logout" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setUIFiels) name:@"NotificationOnLanguageChanged" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getNotificationDetails:) name:AppNotificationName.USER_ACCEPT_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkTripStatusForAcceptedNotification:) name:AppNotificationName.USER_ON_ACCEPT_NOTIFICATION object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appDidEnterForeground)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    isShwoPickUpLocationOnLoad=NO;
    [self checkAndShowAlertWith];
    int authorizationStatus=[CLLocationManager authorizationStatus];
    if(authorizationStatus==0){
        [_locationManager requestAlwaysAuthorization];
    }
    [self getNotificationCount];
    [self getUpcomingTrips:NO];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self aplicarDestinoDePlanSiHay:15];
}

/**
 Recoge el destino que la seccion Sitios dejo preparado.

 POR QUE SE REINTENTA. Al volver de Sitios, viewWillAppear vuelve a poner direction.source
 en emptyLoc y el origen real llega despues, por GPS. Aplicar el destino antes de eso deja
 un destino escrito y ninguna ruta calculada, que es peor que tardar medio segundo mas. Se
 reintenta un rato corto -- 15 x 0,4 s -- y se abandona: quedarse esperando para siempre
 solo serviria para que el destino apareciera solo diez minutos despues, cuando ya no viene
 a cuento.

 NO SE PIDE EL VIAJE SOLO, a proposito. Se deja el destino puesto y la tarifa a la vista, y
 el pasajero decide. Lanzar una solicitud desde un anuncio seria pedir un taxi en nombre de
 alguien que solo estaba mirando.
 */
-(void)aplicarDestinoDePlanSiHay:(NSInteger)intentosRestantes {
    if (![ConrraDestinoDePlan hayPendiente]) {
        return;
    }

    BOOL hayOrigen = (direction != nil && direction.source != nil
                      && direction.source.coordinate.latitude != emptyLoc.latitude);
    if (!hayOrigen) {
        if (intentosRestantes > 0) {
            __weak typeof(self) debil = self;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)),
                           dispatch_get_main_queue(), ^{
                [debil aplicarDestinoDePlanSiHay:(intentosRestantes - 1)];
            });
        } else {
            // Se suelta el buzon: si se quedara lleno, el destino saltaria en la siguiente
            // vuelta a esta pantalla, sin que nadie hubiera pedido nada.
            NSLog(@"[Planes] destino descartado: nunca hubo origen");
            [ConrraDestinoDePlan consumir];
        }
        return;
    }

    NSString *sitio = [ConrraDestinoDePlan sitio];
    CLLocationDegrees lat = [ConrraDestinoDePlan lat];
    CLLocationDegrees lng = [ConrraDestinoDePlan lng];
    [ConrraDestinoDePlan consumir];

    if (sitio.length == 0) {
        return;
    }
    NSLog(@"[Planes] destino desde Sitios: %@ (%f,%f)", sitio, lat, lng);
    [self fijarDestinoEn:CLLocationCoordinate2DMake(lat, lng) nombre:sitio];
}

/**
 Fija un destino del que ya se sabe la coordenada.

 El camino normal -- las sugerencias de Google -- llega con un place_id y hay que
 resolverlo antes. Hay dos sitios que no pasan por ahi y ya traen el punto hecho: el
 boton IR de Sitios y el selector de mapa. Los dos acaban aqui.

 Sin pais: ninguno de los dos trae terminos de Google. Android hace lo mismo (setDropData
 no pasa pais) y este fichero ya deja dropCountry en "" en otros caminos de reinicio.
 */
-(void)fijarDestinoEn:(CLLocationCoordinate2D)coordenada nombre:(NSString *)nombre {
    if (nombre.length == 0) {
        return;
    }
    CLLocation *destino = [[CLLocation alloc] initWithLatitude:coordenada.latitude
                                                     longitude:coordenada.longitude];
    if ([direction.source distanceFromLocation:destino] < 100) {
        [self showAlertWithOk:@""
                      message:[LanguageHelper getStringWithKey:@"k_76_s4_cnt_slct_sm_lctn"]
                      handler:^(UIAlertAction *action) { }];
        return;
    }

    pendingScreen3Presentation = YES;   // enseñar la tarifa en cuanto responda el API
    btnDropState = @"cross";
    [self.btnSearchDrop setImage:[UIImage imageNamed:@"remove"] forState:UIControlStateNormal];

    self.txtDestinationAddres.text = nombre;
    direction.destination = destino;
    direction.dropAddress = nombre;
    direction.dropCountry = @"";

    [self zoomToDestination];
    [self addMapAnnotationsWith:direction type:@"destination"];
    [UtilityClass setLH:NO wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
    [self drawRoute];
    [self resetResetPickDrop];
}


-(void) getPendingTripFromServer {
    [self getPendingTripFromServerWithLoader:YES];
}

-(void) getPendingTripFromServerWithLoader:(BOOL)showLoader {
    if (showLoader) {
        [UtilityClass setLH:NO wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
    }
    NSDictionary *dict1 = [[NSUserDefaults standardUserDefaults]objectForKey:P_USER_DICT];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{
        P_USER_ID          :[dict1 objectForKey:P_USER_ID],
    }];
    [GIC mkwerwu:TRIP_GET_PENDTING_TRIP  d:dict     cb:^(id results, NSError *error) {
        if (showLoader) {
            [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
        }
        if ([[[results objectForKey:P_STATUS] uppercaseString] isEqualToString:@"OK"]) {
            
            if([[results objectForKey:P_RESPONSE] isKindOfClass:[NSArray class]])
            {
                NSArray * tripArray = [results objectForKey:P_RESPONSE];
                if (tripArray.count>0) {
                    self->currTrip = [[TripModel alloc] initItemWithDict:[[results objectForKey:P_RESPONSE]objectAtIndex:0]];
                    NSString * tripId=[NSString stringWithFormat:@"%@",self->currTrip.trip_Id];
                    defaults_set_object(TRIP_ID, tripId );
                    [self stopSearchNearbyDriver];
                    [self checkTripStatus];
                }
            }
        }else{
        }
    }];
}

-(void)getNotificationDetails:(NSNotification *) notification{
    NSString *savedTripId=defaults_object(TRIP_ID);
    if(savedTripId!=nil&&![savedTripId isEqualToString:@"0"]){
        if ([[self.navigationController topViewController] isKindOfClass:[BeginTripViewController class]]||[[self.navigationController topViewController] isKindOfClass:[UFareSummeryViewController class]]) {
            
        }else{
            currTrip=[[TripModel alloc]  init];
            currTrip.trip_Id=savedTripId  ;
            [self checkTripStatus];
        }
    }
}

-(void)navigateHome{
    
    [self loadHomeViewController];
    
}



-(void)  updateFireProfile{
    NSDictionary *dictUser = [[NSUserDefaults standardUserDefaults]objectForKey:P_USER_DICT];
    NSString *fId=[dictUser objectForKey:P_FIRE_ID];
    if(fId.length>0)    {
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
    [[self.ref_TripChat    child:@"domery_user_id"] setValue:[dictUser objectForKey:P_USER_ID]];
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [[self.ref_TripChat    child:@"time"] setValue:isEmpty([dateFormatter stringFromDate:[NSDate date]])];
    [[self.ref_TripChat    child:@"user_id"] setValue:fireId];
    [[self.ref_TripChat    child:@"is_user"] setValue:@(YES)];
}

 



-(void) viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    isHome =NO;
    [self hideRadarAnimation];
    [nearByDriverHandler stopGetNearByDriver];
    // [[NSNotificationCenter defaultCenter]  removeObserver:self];
    [[UpdateUserCurrentLocation sharedInstance] stopUpdateCurrentLocation];
}

-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if (!isSheetSetup) {
        isSheetSetup = YES;
        [self setupHomeLayout];
    }
}

-(void)appDidEnterForeground{
    int authorizationStatus=[CLLocationManager authorizationStatus];
    if(authorizationStatus==0){
        [_locationManager requestAlwaysAuthorization];
    }
    isHome =YES;
    if([currTrip.trip_Status isEqualToString:TS_ACCEPTED]||[currTrip.trip_Status isEqualToString:TS_ARRIVE]||[currTrip.trip_Status isEqualToString:TS_BEGIN]||[currTrip.trip_Status isEqualToString:TS_PICKED])
    {
        
    }else{
        [nearByDriverHandler  startGettingNearByDriver];
    }
    [self checkAndShowAlertWith];
    [[UpdateUserCurrentLocation sharedInstance] startUpdateCurrentLocation];
    [self setTimerForRefresNotificationCount];
    //    NSString *savedTripId=defaults_object(TRIP_ID);
    //    if(savedTripId!=nil)
    //    {
    //        currTrip =[[TripModel alloc]init];
    //        currTrip.trip_Id = savedTripId;
    //        [self checkTripStatus];
    //    }
}

-(void)setThemeConstants{
    [_lbTime setFont:FONTS_THEME_REGULAR((23))];
    [_lbDriversAvailableMessage setFont:FONTS_THEME_REGULAR(17)];
}

/* DRAG-TO-SELECT LOCATION DISABLED
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
    isMapDraged = YES;
    isDragged = YES;
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        CLLocation * userLoc=[[CLLocation alloc]  initWithCoordinate:centerCoordinate altitude:0 horizontalAccuracy:5 verticalAccuracy:5 timestamp:[NSDate date]];
        if (!isPickupSelected) {
            [nearByDriverHandler changePickUpLocation:userLoc];
        }
        if (self.txtPickupAddress.text.length==0||direction.pickAddress.length==0) {
            nearByDriverHandler.categoryId=[NSString stringWithFormat:@"%d",Selectedcategory.categoryId];
            nearByDriverHandler.city_id=[NSString stringWithFormat:@"%d",cityModel.city_id];
            [self checkLocationInsieCityMatch:centerCoordinate];
        }
    }
}
*/

-(void)checkLocationInsieCityMatch:(CLLocationCoordinate2D ) locCoordinate{
    CityModel * cModel=[CityModel checkLocationInsieCityMatchFinal:locCoordinate];
    if(cModel){
        if(cityModel.city_id != cModel.city_id) {
            cityModel=cModel;
            [self.btCity setTitle:@"" forState:UIControlStateNormal];
            [self.txtCity setText:[NSString stringWithFormat:@"%@",cityModel.city_name]];
            NSLog(@"%@",cModel.city_name);
            [self getCategoryFormServer];
        }
        self.lblServiceNotAvailable.hidden=YES;
        self.scrollViewCategory.hidden=NO;
        if(nearByDriverHandler==nil){
            [self startSearchNearbyDriver];
        }
    }else{
        cityModel=nil;
        Selectedcategory=nil;
        [self stopSearchNearbyDriver  ];
        [self.txtCity setText:[NSString stringWithFormat:@"%@",@"-Select"]];
        self.scrollViewCategory.hidden=YES;
        self.lblServiceNotAvailable.hidden=NO;
        [self.mapView removeAnnotations:arrayFakeDriversAnnotation];
        [arrayFakeDriversAnnotation removeAllObjects];
        arrayFakeDriversAnnotation = nil;
        if(timerForStartAnimation){
            [timerForStartAnimation invalidate];
            timerForStartAnimation= nil;
        }
    }
}

-(void) showDebugBoundryOfCityOnMap:(CityModel *) cityM
{
    //    [self.mapView removeOverlay:polyLineForDebug];
    //    CLLocationCoordinate2D coords[cityM.geofenceArray.count];
    //
    //       for (int i = 0; i < cityM.geofenceArray.count; i++) {
    //           CLLocation *location = [cityM.geofenceArray objectAtIndex:i];
    //           coords[i] = CLLocationCoordinate2DMake(location.coordinate.latitude,location.coordinate.longitude);
    //       }
    //
    //      polyLineForDebug=   [MKPolyline polylineWithCoordinates:coords count:cityM.geofenceArray.count];
    //
    //    [self.mapView addOverlay:polyLineForDebug];
    
}



-(void)initMapView
{
    self.mapView.delegate = self;
    AppDelegate *appdelegate =APP_DELEGATE;
    NSDictionary *lastloc = defaults_object(@"curr_loc");
    CLLocationCoordinate2D coordinate ;
    if(lastloc){
        coordinate = CLLocationCoordinate2DMake([[lastloc objectForKey:@"lat"] floatValue], [[lastloc objectForKey:@"lng"] floatValue]);
    }else{
        ConstantModel *cModel=[ConstantModel getConstantsObject];
        coordinate=cModel.def_location.coordinate;
        NSDateFormatter * dfForSave=[[NSDateFormatter alloc] init];
        [dfForSave setDateFormat:SAVE_DATE_FORMAT];
        NSString * dateLastLocation=[dfForSave  stringFromDate:[NSDate date]];
        lastloc =[[NSDictionary alloc]initWithObjectsAndKeys:[NSString stringWithFormat:@"%f",coordinate.latitude],@"lat",[NSString stringWithFormat:@"%f",coordinate.longitude ],@"lng",dateLastLocation,@"date", nil];
    }
    
    
    appdelegate.currLoc=[[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    span.latitudeDelta=0.9;
    span.longitudeDelta=0.9;
    region.span=span;
    region.center=coordinate;
    [self mapRegion:region mapView:self.mapView];
    
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    _locationManager.distanceFilter = kCLDistanceFilterNone;
    // [_locationManager requestWhenInUseAuthorization];
    [_locationManager requestAlwaysAuthorization];
    [_locationManager allowsBackgroundLocationUpdates];
    [_locationManager setPausesLocationUpdatesAutomatically:NO];
    [_locationManager startUpdatingLocation];
    
    self.mapView.showsUserLocation = NO;
    self.mapView.userTrackingMode = MKUserTrackingModeFollow ;
    self.mapView.mapType = MKMapTypeMutedStandard;
    self.mapView.showsCompass = YES;
    self.mapView.showsTraffic = NO;
    if (@available(iOS 13.0, *)) {
        self.mapView.pointOfInterestFilter = [MKPointOfInterestFilter filterExcludingAllCategories];
    }
    //[self setBoundry];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    //  Get the new view controller using [segue destinationViewController].
    //  Pass the selected object to the new view controller.
    
    
    if (constantTaxiModel==nil) {
        constantTaxiModel =[ConstantModel getConstantsObject];
    }
    
    if ([segue.identifier isEqualToString:@"FareAmountViewController"]) {
        [self stopLocationUpdate];
        UFareSummeryViewController *fareView =(UFareSummeryViewController *)[segue destinationViewController];
        fareView.curr_trip = currTrip;
        fareView.constantModel =constantTaxiModel;
        
    }
    else if([segue.identifier isEqualToString:@"BeginTripViewController"])
    {
        [self stopLocationUpdate];
        BeginTripViewController *vc=(BeginTripViewController *) segue.destinationViewController;
        vc.currentTrip=currTrip;
        vc.constantModel = constantTaxiModel;
        vc.isFromrequest =YES;
        [self reset:nil];
    }
}




#pragma mark - RequestViewController Delegate

-(void)onTripRequestCompletion:(TripModel *)tripModel
{
    //    if([tripModel.trip_Status isEqualToString:TS_ACCEPTED])
    //  {
    currTrip=tripModel;
    NSString *tripId=[NSString stringWithFormat:@"%@",tripModel.trip_Id];
    defaults_set_object(TRIP_ID,tripId);
    
    // }
    
}


#pragma mark - Check trip Status Trip status

-(void) checkTripStatus
{
    if(currTrip)
    {
        
        [currTrip refreshTripModelWithCompletionBlock:^(id results, NSError *error) {
            self->apiCounter++;
            if ([[results objectForKey:P_RESPONSE] isKindOfClass:[NSArray class]]) {
                if([self->currTrip.trip_Status isEqualToString:TS_ASSIGNED])
                {
                    //                    [UtilityClass showWarningAlert:@"Trip Assign" message:[NSString stringWithFormat:@"Your trip is assigned to driver %@ %@",currTrip.driver.d_fname,currTrip.driver.d_lname] cancelButtonTitle:@"ok" otherButtonTitle:nil viewController:self];
                }
                else if([self->currTrip.trip_Status isEqualToString:TS_ACCEPTED]||[self->currTrip.trip_Status isEqualToString:TS_ARRIVE]||[self->currTrip.trip_Status isEqualToString:TS_BEGIN]||[self->currTrip.trip_Status isEqualToString:TS_PICKED])
                {
                    [self->nearByDriverHandler stopGetNearByDriver];
                    self->nearByDriverHandler=nil;
                    if(![self.navigationController.topViewController isKindOfClass:[BeginTripViewController class]])
                    {
                        if(!self->isGoToHomeScreen){
                            [self loadBeginViewContoller:self->currTrip];
                        }
                    }
                }
                else if([self->currTrip.trip_Status isEqualToString:TS_END]||[self->currTrip.trip_Status isEqualToString:TS_RIDER_CANCEL_CANCEL]) {
                    if(![self.navigationController.topViewController isKindOfClass:[FareAmmountViewController class]]) {
                        if(!self->isGoToHomeScreen){
                            [self loadUFareSummeryViewContoller:self->currTrip];
                        }
                    }
                    return ;
                }
                else if([self->currTrip.trip_Status isEqualToString:TS_END]||[self->currTrip.trip_Status isEqualToString:TS_DRIVER_CANCEL_AT_DROP]) {
                    if(![self.navigationController.topViewController isKindOfClass:[FareAmmountViewController class]]) {
                        if(!self->isGoToHomeScreen){
                            [self loadUFareSummeryViewContoller:self->currTrip];
                        }
                    }
                    return ;
                }
                else if([self->currTrip.trip_Status isEqualToString:TS_USER_CANCEL]){
                    [self handleAfterTripRequestExpired:NO];
                    return ;
                }
                else if ([self->currTrip.trip_Status isEqualToString:TS_REQUEST]){
                    if(!self->isGoToHomeScreen){
                        //                        self.lblPickAddress.text = self->currTrip.trip_pick_loc;
                        //                        self.lblDropAddress.text = self->currTrip.trip_drop_loc;
                        //                        CGFloat pickHeight = [UtilityClass gTH:CGSizeMake(SCREEN_WIDTH-80, 300) forText:self.lblPickAddress.text  withFont:self.lblPickAddress.font];
                        //                        [self.imageRequestLine setConstraintConstant:pickHeight+20 forAttribute:NSLayoutAttributeHeight];
                        //                    self.ViewRequestBg.hidden =NO;
                        [self  openTripRequest:self->currTrip];
                        //                    self->linerProgressBar =[[LinearProgressBar alloc]initWithFrame:CGRectMake(0, 0, self.viewProgressBg.frame.size.width, self.viewProgressBg.frame.size.height)];
                        //                    self->linerProgressBar.backgroundColor = [UIColor whiteColor];
                        //                    [self.viewProgressBg addSubview:self->linerProgressBar];
                    }
                    // this method is commented  for InDriver App
                    //                    [self checkTripStatusForAccept];
                }else if([self->currTrip.trip_Status isEqualToString:TS_EXPIRED]){
                    [self handleAfterTripRequestExpired];
                }
            }
            else{
                if (self->apiCounter<3) {
                    [self checkTripStatus];
                }
            }
        } isShowLoader:NO];
    }else{
        // if trip id  is aved then   getTrip data
        NSString *savedTripId=defaults_object(TRIP_ID);
        if(savedTripId!=nil&&![savedTripId isEqualToString:@"0"])
        {
            currTrip=[[TripModel alloc]  init];
            currTrip.trip_Id=defaults_object(TRIP_ID);
            [self checkTripStatus];
        }
    }
}




-(void)updateTripStatusExpire:(NSString *)tripId completionBlock:(void (^)(id results, NSError *error))block{
    if(!self->isGoToHomeScreen){
        NSMutableDictionary *dict=[[NSMutableDictionary alloc]  init];
        [dict setObject:tripId forKey:TRIP_ID];
        [dict setObject:TS_EXPIRED forKey:TRIP_STATUS];
        [currTrip updateTripModelWith:dict completionBlock:^(id results, NSError *error) {
            
            if((![[results objectForKey:P_RESPONSE] isKindOfClass:[NSDictionary class]])&&[[results objectForKey:P_RESPONSE] boolValue]==1)
            {
                [self getUpcomingTrips:NO];
                block(results,nil);
            }else{
                block(results,error);
            }
            
        } isShowLoader:YES isSendNotification:NO];
    }
}

#pragma mark -suggested location method
-(void) onAddressStartEditingsource:(SuggestedLocationDataSource *)soure
{
    
    if (soure.textField == self.txtPickupAddress) {
        
        [self.btnSearchPickup setImage:[UIImage imageNamed:@"remove"] forState:UIControlStateNormal];
        
        [self setTitleForPickDrop:PICK_LOCATION];
        btnPickupState =@"cross";
        
    }
    else{
        if (direction.source.coordinate.latitude==0)
        {
            [self.txtPickupAddress becomeFirstResponder];
            [Utilities showAlertwithTilte:[LanguageHelper getStringWithKey:@"k_33_s7_alert"] message:[LanguageHelper getStringWithKey:@"k_r50_s3_plz_sel_pickup_loc"] viewController:self];
            
            return;
        }
        
        btnDropState =@"cross";
        [self.btnSearchDrop setImage:[UIImage imageNamed:@"remove"] forState:UIControlStateNormal];
        
        [self setTitleForPickDrop:DROP_LOCATION];
    }
}
-(void) onAddressEndEditingsource:(SuggestedLocationDataSource *)soure
{
    if(soure.dictLocationSelected==nil)
    {
        if(soure==locationDataSourcePickup) {
            if(![self.txtPickupAddress.text isEqualToString:direction.pickAddress]) {
                soure.textField.text=@"";
                [self ButtonDropDownPressed:self.btnSearchPickup];
            }
        }else if(soure==locationDataSourceDrop) {
            if(![self.txtDestinationAddres.text isEqualToString:direction.dropAddress])   {
                soure.textField.text=@"";
                [self ButtonDropDownPressed:self.btnSearchDrop];
            }
        }
        return;
    }
    if (_txtDestinationAddres.text.length ==0 && direction.dropAddress.length ==0) {
        
        if (_txtPickupAddress.text.length ==0 && direction.pickAddress.length ==0) {
            [self setTitleForPickDrop:PICK_LOCATION];
        }else{
            [self setTitleForPickDrop:DROP_LOCATION];
        }
        
    }
    if (_txtPickupAddress.text.length == 0 || direction.pickAddress.length == 0) {
        [self.btnSearchPickup setImage:[UIImage imageNamed:@"add"] forState:UIControlStateNormal];
    }
    if (_txtDestinationAddres.text.length == 0 || direction.dropAddress.length == 0) {
        [self.btnSearchDrop setImage:[UIImage imageNamed:@"add"] forState:UIControlStateNormal];
    }
}



-(void)source:(SuggestedLocationDataSource *)soure onSelectLocation:(NSDictionary *)dictLocation{
    [self.view endEditing:YES];
    
    if(soure.textField==self.txtPickupAddress)
    {
        
        
        [self.btnSearchPickup setImage:[UIImage imageNamed:@"remove"] forState:UIControlStateNormal];
        btnPickupState =@"cross";
        direction.source = [[CLLocation alloc]initWithLatitude:emptyLoc.latitude longitude:emptyLoc.longitude] ;
        NSString  *stringPickup=[dictLocation  objectForKey:@"description"];
        NSString  *stringPlaceId=[dictLocation  objectForKey:@"place_id"];
        
        NSArray *arrTerms = [dictLocation  objectForKey:@"terms"];
        
        NSString * country = [[arrTerms objectAtIndex:arrTerms.count-1]objectForKey:@"value"];
        
        [Utilities getLocationFromAddressStringPlaceId:stringPlaceId withcompletionHandler:^(CLLocationCoordinate2D loc) {
            
            self->direction.source= [[CLLocation alloc]initWithLatitude:loc.latitude longitude:loc.longitude] ;
            [self checkLocationInsieCityMatch:loc];
            self->direction.pickAddress=stringPickup;
            [self ZoomToPickupLocation];
            [self->nearByDriverHandler changePickUpLocation:self->direction.source];
            [self addMapAnnotationsWith:self->direction type:@"source"];
            self->direction.pickCountry = country;
            self->isPickupSelected =YES;
            self.btPickupDetail.hidden=NO;
            [self setTitleForPickDrop:DROP_LOCATION];
            self->btnDropState=@"cross";
            if (self->direction.destination.coordinate.latitude != self->emptyLoc.latitude && self->direction.source.coordinate.latitude != self->emptyLoc.latitude) {
                
                [UtilityClass setLH:NO wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
                
                [self drawRoute];
                //}
            }
            
            
        }];
        
        
    }
    else{
        if((self.txtPickupAddress.text.length==0 ||direction.pickAddress.length==0)||[direction isSourceEmpty])
        {
            
            [UtilityClass swa:@"" m:[LanguageHelper getStringWithKey:@"k_r7_s3_enter_pickup_loc"] cbt:[LanguageHelper getStringWithKey:@"k_18_s4_Ok"] obt:nil vc:self];
            [self.txtPickupAddress becomeFirstResponder];
            self.txtDestinationAddres.text=@"";
            [self setTitleForPickDrop :PICK_LOCATION];
            locationDataSourceDrop.tablview.hidden=YES;
            
            return;
        }
        
        [self.btnSearchDrop setImage:[UIImage imageNamed:@"remove"] forState:UIControlStateNormal];
        btnDropState =@"cross";
        NSString  *stringDestinationAddress=[dictLocation  objectForKey:@"description"];
        NSArray *arrTerms = [dictLocation  objectForKey:@"terms"];
        NSString * country = [[arrTerms objectAtIndex:arrTerms.count-1]objectForKey:@"value"];
        direction.destination= [[CLLocation alloc]initWithLatitude:emptyLoc.latitude longitude:emptyLoc.longitude]  ;
        NSString  *stringPlaceId=[dictLocation  objectForKey:@"place_id"];
        [Utilities getLocationFromAddressStringPlaceId:stringPlaceId withcompletionHandler:^(CLLocationCoordinate2D loc) {
            CLLocation *location=[[CLLocation alloc]initWithLatitude:loc.latitude longitude:loc.longitude];
            if([self->direction.source distanceFromLocation:location]<100){
                [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
                [self showAlertWithOk:@"" message:[LanguageHelper getStringWithKey:@"k_76_s4_cnt_slct_sm_lctn"] handler:^(UIAlertAction * _Nonnull action) {
                    //                    self.drop.text=@"";
                    [self ButtonDropDownPressed:self.btnSearchDrop];
                }];
                return;
            }
            self->direction.destination= [[CLLocation alloc]initWithLatitude:loc.latitude longitude:loc.longitude]  ;
            self->direction.dropAddress=stringDestinationAddress;
            self->direction.dropCountry =country;
            
            
            if (self->direction.destination.coordinate.longitude != self->emptyLoc.latitude && self->direction.source.coordinate.latitude != self->emptyLoc.latitude) {
                
                [self zoomToDestination];
                [self addMapAnnotationsWith:self->direction type:@"destination"];
                
                [UtilityClass setLH:NO wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
                [self drawRoute];
                [self resetResetPickDrop];
                //}
            }
            else{
                
                
                if (self->_txtPickupAddress.text.length == 0) {
                    
                    // CLLocation *  source=[[CLLocation alloc]  initWithCoordinate:centerCoordinate altitude:0 horizontalAccuracy:5 verticalAccuracy:5 timestamp:[NSDate date]];
                    self->direction.source=[[CLLocation alloc]initWithLatitude:self->centerCoordinate.latitude longitude:self->centerCoordinate.longitude];
                    [Utilities getAddressStrinByLat:self->centerCoordinate.latitude longitude:self->centerCoordinate.longitude withcompletionHandler:^(NSString *locAddress, NSString *country) {
                        if (locAddress == nil ||locAddress.length==0) {
                            self.btPickupDetail.hidden=YES;
                            self->isPickupSelected =NO;
                        }
                        else{
                            self.btPickupDetail.hidden=NO;
                            self->isPickupSelected =YES;
                        }
                        
                        if (locAddress.length>0) {
                            self->direction.pickAddress = locAddress;
                            self->direction.pickCountry = country;
                            
                            [self zoomToDestination];
                            [self addMapAnnotationsWith:self->direction type:@"destination"];
                            
                            if (self->direction.destination.coordinate.latitude !=self->emptyLoc.latitude && self->direction.source.coordinate.latitude !=self->emptyLoc.latitude) {
                                [UtilityClass setLH:NO wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
                                [self drawRoute];
                                [self resetResetPickDrop];
                            }
                            else{
                            }
                        }
                    }];
                }
            }
            
        }];
        
    }
}

//-(void) getLocationFromAddressString: (NSString*) addressStr withcompletionHandler : (void(^)(CLLocationCoordinate2D loc))completionHandler {
//    double latitude = 0, longitude = 0;
//    NSString *esc_addr =  [addressStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
//    NSString *req = [NSString stringWithFormat:@"https://maps.google.com/maps/api/geocode/json?key=%@&sensor=false&address=%@",[APP_DELEGATE getGoogleKey], esc_addr];
//    NSString *result = [NSString stringWithContentsOfURL:[NSURL URLWithString:req] encoding:NSUTF8StringEncoding error:NULL];
//    if (result) {
//        NSScanner *scanner = [NSScanner scannerWithString:result];
//        if ([scanner scanUpToString:@"\"lat\" :" intoString:nil] && [scanner scanString:@"\"lat\" :" intoString:nil]) {
//            [scanner scanDouble:&latitude];
//            if ([scanner scanUpToString:@"\"lng\" :" intoString:nil] && [scanner scanString:@"\"lng\" :" intoString:nil]) {
//                [scanner scanDouble:&longitude];
//            }
//        }
//    }
//
//    CLLocationCoordinate2D center;
//    center.latitude=latitude;
//    center.longitude = longitude;
//    completionHandler(center);
//
//}






-(NSString *) addressFromPlacemark:(CLPlacemark *)place{
    
    NSMutableString *addressString = [NSMutableString string];
    for (NSString* str in [place.addressDictionary objectForKey:@"FormattedAddressLines"]) {
        if (addressString.length > 0)
            [addressString appendString:@","];
        
        [addressString appendFormat:@"%@",str];
    }
    return addressString;
}

-(void) makeRouteOnMap
{
    [self clearMapView];
    [direction  findDirection_isInTrip:NO WithCompletionBlock:^(id results, NSError *error) {
        if([results  isKindOfClass:[DirectionModel class]])
        {
            DirectionModel * dModel=(DirectionModel *)results;
            self->directionModel=dModel;
            if ([dModel.arrDirectionLatLng count]==0) {
                
                [UtilityClass swa:@"" m:[LanguageHelper getStringWithKey:@"k_r20_s1_unmatch_country"] cbt:[LanguageHelper getStringWithKey:@"k_18_s4_Ok"] obt:nil vc:self];
                [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
                
                [self reset:nil];
                return;
            }
            
            [self.imCenterPickupLocation setHidden:YES];
            [self.viewCallout setHidden:YES];
            
            self->tripTime=dModel.duration;
            self->tripDistance=dModel.distance;
            
            self->isMapDraged=YES;
            self->isMapRouteMake=YES;
            [self addMapAnnotationsWith:self->direction type:@"source"];
            [self addMapAnnotationsWith:self->direction type:@"destination"];
            [self->_mapView addOverlay:[ dModel getPolyline] level:MKOverlayLevelAboveRoads];
            
            
            MKPointAnnotation *point1 = [[MKPointAnnotation alloc]init];
            point1.coordinate = dModel.northeast.coordinate;
            MKPointAnnotation *point2 = [[MKPointAnnotation alloc]init];
            point2.coordinate = dModel.southwest.coordinate;
            
            NSMutableArray *arrAnn = [[NSMutableArray alloc]initWithObjects:point1,point2, nil];
            
            [self zoomToFitMapAnnotations:arrAnn];
            
            self->isShowFareView =NO;
            int duration11=(int)((dModel.duration*110)/100.0);
            int duration15=(int)((dModel.duration*150)/100.0);
            
            [self setfareDetails:[ dModel distance] isFrom:NO];
        }
        else {
            //[self reset:nil];
        }
        [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
    }];
}



#pragma  mark -mapview delegates


- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    AppDelegate *appdelegate= APP_DELEGATE;
    
    appdelegate.currLoc = userLocation.location;

    NSDictionary * dict =[[NSDictionary alloc]initWithObjectsAndKeys:[NSString stringWithFormat:@"%f",appdelegate.currLoc.coordinate.latitude],@"lat",[NSString stringWithFormat:@"%f",appdelegate.currLoc.coordinate.longitude ],@"lng", nil];
    defaults_set_object(@"curr_loc", dict);
    
    // [self CenterMapRegionForShot];
    //    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 800, 800);
    //    [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
}


-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{

    CLLocation *loc = locations.lastObject;
    AppDelegate *appdelegate= APP_DELEGATE;
    appdelegate.currLoc = loc;
    // Update / add squircle user location pin
    if (userLocationAnnotation == nil) {
        userLocationAnnotation = [[CustomPointAnnotation alloc] initWithType:PIN_USER_LOCATION];
        userLocationAnnotation.coordinate = loc.coordinate;
        [self.mapView addAnnotation:userLocationAnnotation];
    } else {
        userLocationAnnotation.coordinate = loc.coordinate;
    }
    // [self CenterMapRegionForShot];
    NSDictionary * dict =[[NSDictionary alloc]initWithObjectsAndKeys:[NSString stringWithFormat:@"%f",appdelegate.currLoc.coordinate.latitude],@"lat",[NSString stringWithFormat:@"%f",appdelegate.currLoc.coordinate.longitude ],@"lng", nil];
    defaults_set_object(@"curr_loc", dict);
    if(isShwoPickUpLocationOnLoad==NO)  {
        [self setupPickupDropAddressWhenLoadApp:loc];
        isShwoPickUpLocationOnLoad=YES;
    }
    if(cityModel==nil)  {
        if(isPickupSelected==NO){
            [ self checkLocationInsieCityMatch:loc.coordinate];
        }else{
            if(direction){
                [ self checkLocationInsieCityMatch:direction.source.coordinate];
            }
        }
    }
}



-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    //    if([self isCheckLocationFailedScreen]){
    //        AppDelegate *appdelegate =APP_DELEGATE;
    //        ConstantModel * conns=[ConstantModel getConstantsObject];
    //
    //        appdelegate.currLoc =conns.def_location;
    //        if(![self canConsiderDriverIsFree]){
    //            [self locatonGetFailedScreen:manager isBackHidden:YES];
    //        }
    //    }else{
    //
    //    }
}



-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    
    //    [[NSNotificationCenter defaultCenter]
    //     postNotificationName:@"refresh_location"
    //     object:nil];
    if(isFirstTime) {
        //        if([self isCheckLocationFailedScreen]){
        //            ConstantModel *consts=[ConstantModel getConstantsObject];
        //            AppDelegate *appdelegate =APP_DELEGATE;
        //            appdelegate.currLoc =consts.def_location;
        //            [[UpdateUserCurrentLocation sharedInstance]  updateDriverAvailablity:@"0"];
        //            if(![self canConsiderDriverIsFree]){
        //                [self locatonGetFailedScreen:manager isBackHidden:YES];
        //            }
        //        }else{
        //
        //        }
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
            [[UpdateUserCurrentLocation sharedInstance]  updateDriverAvailablity:@"0"];
            if(![self canConsiderDriverIsFree]){
                [self locatonGetFailedScreen:manager isBackHidden:YES];
            }
        }else{
            
        }
    }
    isFirstTime=YES;
}

-(BOOL) canConsiderDriverIsFree{
    NSString *status =defaults_object(DRIVER_STATUS);
    if ( status ==nil ||[status isEqualToString:TS_WAITING] || [status isEqualToString:TS_REQUEST] || [status isEqualToString:TS_END] || [status isEqualToString:TS_DRIVER_CANCEL_AT_PICKUP] || [status isEqualToString:TS_DRIVER_CANCEL_AT_DROP]) {
        return YES;
    }
    return NO;
}

- (void)addMapAnnotationsWith:(GoogleDirectionSource * )directionSource {
    
    [self.mapView removeAnnotation:userPin];
    [self.mapView removeAnnotations:arrAnotation];
    [arrAnotation  removeAllObjects];
    CustomPointAnnotation * pickUp=[[CustomPointAnnotation alloc]  initWithType:PIN_START];
    pickUp.coordinate = directionSource.source.coordinate;
    [self.mapView addAnnotation:pickUp];
    CustomPointAnnotation * dropAno=[[CustomPointAnnotation alloc]  initWithType:PIN_DROP];
    dropAno.coordinate = directionSource.destination.coordinate;
    [self.mapView addAnnotation:dropAno];
    [arrAnotation addObject:pickUp];
    [arrAnotation addObject:dropAno];
}

-(void)zoomToFitMapAnnotations:(NSMutableArray *) arrayAnotations
{
    CLLocationCoordinate2D topLeftCoord;
    topLeftCoord.latitude = -90;
    topLeftCoord.longitude = 180;
    CLLocationCoordinate2D bottomRightCoord;
    bottomRightCoord.latitude = 90;
    bottomRightCoord.longitude = -180;
    
    for (id <MKAnnotation> annotation in arrayAnotations) {
        topLeftCoord.longitude = fmin(topLeftCoord.longitude, annotation.coordinate.longitude);
        topLeftCoord.latitude = fmax(topLeftCoord.latitude, annotation.coordinate.latitude);
        
        bottomRightCoord.longitude = fmax(bottomRightCoord.longitude, annotation.coordinate.longitude);
        bottomRightCoord.latitude = fmin(bottomRightCoord.latitude, annotation.coordinate.latitude);
    }
    
    MKCoordinateRegion region;
    region.center.latitude = topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) * 0.7;
    region.center.longitude = topLeftCoord.longitude + (bottomRightCoord.longitude - topLeftCoord.longitude) * 0.7;
    region.span.latitudeDelta = fabs(topLeftCoord.latitude - bottomRightCoord.latitude) * 1.6; // Add a little extra space on the sides
    region.span.longitudeDelta = fabs(bottomRightCoord.longitude - topLeftCoord.longitude) * 1.6; // Add a little extra space on the sides
    
    
    [self mapRegion:region mapView:self.mapView];
}

-(void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading{
    
    angle = (double)newHeading.magneticHeading;
    self.mapView.camera.heading = angle;
    [self.mapView setCamera:self.mapView.camera];
}

-(void)getLocation:(CLLocation *)locations withcompletionHandler : (void(^)(NSArray *arr))completionHandler{
    CLGeocoder *geocoder = [CLGeocoder new];
    [geocoder reverseGeocodeLocation:locations completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks,
                                                                   NSError * _Nullable error) {
        completionHandler(placemarks);
    }];
    
}



-(void)showAllDrivers:(NSArray *)arrDrivers
{
    if (arrDrivers.count==0) {
        [self.mapView  removeAnnotations:arrayDriversAnnotation];
        return;
    }
    //    [self setUserAnnotation];
    [self.mapView removeAnnotations:arrayDriversAnnotation];
    [arrayDriversAnnotation removeAllObjects];
    for(int i = 0; i < arrDrivers.count; i++)
    {
        DriverModel * driver=[arrDrivers  objectAtIndex:i];
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(driver.lat, driver.lng);
        CustomPointAnnotation * driverpin=[[CustomPointAnnotation alloc]  initWithType:@"driver-pin"];
        driverpin.degree = driver.d_degree;
        driverpin.coordinate = coordinate;
        [self.mapView addAnnotation:driverpin];
        
        [arrayDriversAnnotation addObject:driverpin];
    }
    if(!isMapDraged)
    {
        //[self zoomToFitMapAnnotations:arrayDriversAnnotation ];   // test
    }
}

-(void)setUserAnnotation{
    AppDelegate *appdelegate =APP_DELEGATE;
    if(appdelegate.currLoc.coordinate.latitude !=0)
    {
        if(userPin)
        {
            [self.mapView removeAnnotation:userPin];
        }
        userPin = [[MKPointAnnotation alloc] init];
        
        userPin.coordinate = appdelegate.currLoc.coordinate;
        // driverPin=YES;
        //        [self.mapView addAnnotation:userPin];
        
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(appdelegate.currLoc.coordinate, 800, 800);
        
        [self mapRegion:region mapView:self.mapView];
    }
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    // centerCoordinate= mapView.centerCoordinate; // drag-to-select location disabled
    [self updateRadarPosition];
}

#pragma mark - Radar Animation

-(void)showRadarAnimation {
    if (!radarView) {
        CGRect f = self.mapView.bounds;
        radarView = [[RadarAnimationView alloc] initWithFrame:f];
        radarView.userInteractionEnabled = NO;
        [self.mapView addSubview:radarView];

        mapDimOverlay = [[UIView alloc] initWithFrame:f];
        mapDimOverlay.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.10];
        mapDimOverlay.userInteractionEnabled = NO;
        [self.mapView addSubview:mapDimOverlay];
    }
    radarView.frame    = self.mapView.bounds;
    mapDimOverlay.frame = self.mapView.bounds;
    radarView.hidden    = NO;
    mapDimOverlay.hidden = NO;
    [radarView startAnimating];
    [self updateRadarPosition];
}

-(void)hideRadarAnimation {
    [radarView stopAnimating];
    radarView.hidden     = YES;
    mapDimOverlay.hidden = YES;
}

-(void)updateRadarPosition {
    if (radarView.hidden) {
        return;
    }
    CLLocationCoordinate2D centro = [self coordenadaDeRecogida];
    if (!CLLocationCoordinate2DIsValid(centro)) {
        return;
    }
    CGPoint pt = [self.mapView convertCoordinate:centro toPointToView:self.mapView];
    radarView.center = pt;
}

/**
 Donde late el radar: el punto de recogida DEL VIAJE.

 Antes seguia a userLocationAnnotation, que es el GPS del telefono. Casi siempre son
 lo mismo, pero no cuando el pasajero movio la recogida a otro sitio -- y justo ahi
 el radar latia donde no va a pasar nada. Android usa trip_scheduled_pick_lat, que es
 este mismo punto.
 */
-(CLLocationCoordinate2D)coordenadaDeRecogida {
    CLLocationCoordinate2D origen = direction.source.coordinate;
    if (CLLocationCoordinate2DIsValid(origen) && !(origen.latitude == 0 && origen.longitude == 0)) {
        return origen;
    }
    if (userLocationAnnotation) {
        return userLocationAnnotation.coordinate;
    }
    return kCLLocationCoordinate2DInvalid;
}

/**
 Centra la recogida en el trozo de mapa que SE VE.

 La hoja de la espera se superpone al mapa, asi que centrar contra la vista entera
 dejaba la recogida detras de ella -- y con ella el radar. El alto lo manda la propia
 hoja (tripOffersDidLayoutSheet:), porque cambia con la publicidad y con el largo de
 las direcciones: darlo por supuesto aqui seria acertar un dia y fallar al siguiente.
 */
-(void)centrarEnRecogidaDejandoHuecoAbajo:(CGFloat)hueco {
    CLLocationCoordinate2D centro = [self coordenadaDeRecogida];
    if (!CLLocationCoordinate2DIsValid(centro)) {
        return;
    }

    // Un cuadro de 1,2 km de lado alrededor del punto: lo bastante cerca para
    // reconocer la calle y lo bastante ancho para ver por donde vendria el conductor.
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(centro, 1200, 1200);
    CLLocationCoordinate2D esquinaA = CLLocationCoordinate2DMake(
        centro.latitude + region.span.latitudeDelta / 2.0,
        centro.longitude - region.span.longitudeDelta / 2.0);
    CLLocationCoordinate2D esquinaB = CLLocationCoordinate2DMake(
        centro.latitude - region.span.latitudeDelta / 2.0,
        centro.longitude + region.span.longitudeDelta / 2.0);
    MKMapPoint a = MKMapPointForCoordinate(esquinaA);
    MKMapPoint b = MKMapPointForCoordinate(esquinaB);
    MKMapRect rect = MKMapRectMake(MIN(a.x, b.x), MIN(a.y, b.y),
                                   fabs(a.x - b.x), fabs(a.y - b.y));
    if (MKMapRectIsNull(rect) || rect.size.width == 0) {
        return;
    }

    // Tope de seguridad: dejar siempre un tercio de mapa util, como Android.
    CGFloat alto = self.view.bounds.size.height;
    if (hueco > alto * 0.66f) {
        hueco = alto * 0.66f;
    }
    // Arriba se deja sitio para la cabecera flotante de la espera.
    UIEdgeInsets margenes = UIEdgeInsetsMake(120, 40, hueco + 24, 40);
    [self.mapView setVisibleMapRect:rect edgePadding:margenes animated:YES];
}

// TripOffersViewContollerDelegate
-(void)tripOffersDidLayoutSheetWithHeight:(CGFloat)height {
    [self centrarEnRecogidaDejandoHuecoAbajo:height];
    [self updateRadarPosition];
}

-(MKAnnotationView *)mapView:(MKMapView *)mV viewForAnnotation:(id <MKAnnotation>)annotation
{
    // userLocation: return nil → default blue dot
    if (annotation == self.mapView.userLocation) {
        [self.mapView.userLocation setTitle:@"I am here"];
        return nil;
    }

    // PIN_USER_LOCATION (squircle) must be handled before the shared pool dequeue
    // to avoid orphaning a @"com.user.pin" view for this annotation.
    if ([annotation isKindOfClass:[CustomPointAnnotation class]]) {
        CustomPointAnnotation *check = (CustomPointAnnotation *)annotation;
        if ([check.type isEqualToString:PIN_USER_LOCATION]) {
            static NSString *userPinID = @"com.user.location.pin";
            UserPinAnnotationView *upv = (UserPinAnnotationView *)
                [self.mapView dequeueReusableAnnotationViewWithIdentifier:userPinID];
            if (!upv) {
                upv = [[UserPinAnnotationView alloc] initWithAnnotation:annotation
                                                        reuseIdentifier:userPinID];
                NSDictionary *userDict = [[NSUserDefaults standardUserDefaults]
                                         objectForKey:P_USER_DICT];
                NSString *photoUrl = userDict[@"user_profile_image"];
                if (photoUrl.length > 0) {
                    [[SDWebImageManager sharedManager]
                        loadImageWithURL:[NSURL URLWithString:photoUrl]
                                 options:0
                                progress:nil
                               completed:^(UIImage *img, NSData *d, NSError *e,
                                           SDImageCacheType ct, BOOL fin, NSURL *u) {
                        if (img) dispatch_async(dispatch_get_main_queue(), ^{
                            [upv setAvatarImage:img];
                        });
                    }];
                }
            }
            return upv;
        }
    }

    MKAnnotationView *pinView = nil;
    {
        static NSString *defaultPinID = @"com.user.pin";
        pinView = (MKAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:defaultPinID];
        if ( pinView == nil )
            pinView = [[MKAnnotationView alloc]
                       initWithAnnotation:annotation reuseIdentifier:defaultPinID];
        // Reset transform so recycled car-pin views don't taint other types
        pinView.transform = CGAffineTransformIdentity;

        if([annotation isKindOfClass:[CustomPointAnnotation class]])
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
            else if ([mAnno.type isEqualToString:@"driver-pin"]){
                pinView.image = [UIHelper imageForMapWithImage:[UIImage imageNamed:@"map_car_icon"]];
                pinView.transform = CGAffineTransformMakeRotation([self DegreesToRadians:mAnno.degree] + M_PI);
            } else if ([mAnno.type isEqualToString:@"driver-pin-fake"]){
                pinView.image = [UIHelper imageForMapWithImage:[UIImage imageNamed:@"map_car_icon"]];
                pinView.transform = CGAffineTransformMakeRotation([self DegreesToRadians:mAnno.degree] + M_PI);
                pinView.layer.anchorPoint = CGPointMake(0.5f, 0.5f);
            }
            else{
                pinView.image = [UIImage imageNamed:@"map_pin_drop"];
                pinView.layer.anchorPoint = CGPointMake(0.5f, 0.5f);
            }
        }
    }

    return pinView;
}

//- (void)startRotatingAnnotation:(MKAnnotationView *)annotationView {
//    [NSTimer scheduledTimerWithTimeInterval:10.0 repeats:YES block:^(NSTimer * _Nonnull timer) {
//        annotationView.layer.anchorPoint = CGPointMake(0.5f, 0.5f);
//        [self rotateAnnotationViewToRandomAngle:annotationView];
//    }];
//}

-(void) startAnimationForMoveFake{
    if(timerForStartAnimation){
        [timerForStartAnimation invalidate];
        timerForStartAnimation= nil;
    }
    timerForStartAnimation = [NSTimer scheduledTimerWithTimeInterval:10 repeats:YES block:^(NSTimer * _Nonnull timer) {
        int removeAndAddNewDrivers = 2;
        NSMutableArray *arrayOldAnotations = [[NSMutableArray alloc]initWithArray:self->arrayFakeDriversAnnotation];
        NSUInteger removeCount = MIN(removeAndAddNewDrivers, arrayOldAnotations.count);
        for (NSUInteger i = arrayOldAnotations.count - 1; i > 0; i--) {
            NSUInteger j = arc4random_uniform((uint32_t)(i + 1));
            [arrayOldAnotations exchangeObjectAtIndex:i withObjectAtIndex:j];
        }
        for (int i = 0; i<removeCount; i++) {
            CustomPointAnnotation * point = [arrayOldAnotations objectAtIndex:i];
            [self->arrayFakeDriversAnnotation removeObject:point];
            [self.mapView removeAnnotation:point];
        }
        NSTimeInterval delayInSeconds = 0.7 + drand48();
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self addNewAnnotation:removeAndAddNewDrivers];
        });
       
        for (int i = 0; i< self->arrayFakeDriversAnnotation.count; i++) {
            CGFloat getIndex = arc4random_uniform((int)self->arrayFakeDriversAnnotation.count); // Generate random angle between 0-359
            CustomPointAnnotation * point = [self->arrayFakeDriversAnnotation objectAtIndex:getIndex];
            CLLocationCoordinate2D newCoordinate = [self randomCoordinateNear:point.coordinate withMaxDistance:50];
            CGFloat randomDelay = ((arc4random() % 801) / 100.0);
            NSLog(@"randomDelay: %f",randomDelay);
            BOOL isApplyRotation = arc4random_uniform(2);
            if(isApplyRotation){
                [UIView animateWithDuration:1.0 delay:randomDelay options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    point.coordinate = newCoordinate;
                } completion:nil];
            }else{
                MKAnnotationView *annotationView = [self.mapView viewForAnnotation:point];
                if (annotationView) {
                    [self rotateAnnotationViewToRandomAngle:annotationView delay:randomDelay];
                } else {
                    [UIView animateWithDuration:0.6 delay:randomDelay options:UIViewAnimationOptionCurveEaseInOut animations:^{
                        point.coordinate = newCoordinate;
                    } completion:nil];
                }
            }
        }
    }];
}

- (void)rotateAnnotationViewToRandomAngle:(MKAnnotationView *)annotationView delay:(float)delay {
    CGFloat randomAngle = arc4random_uniform(359); // Generate random angle between 0-359
    [UIView animateWithDuration:0.6 delay:delay options:UIViewAnimationOptionCurveEaseInOut animations:^{
        annotationView.transform = CGAffineTransformMakeRotation((randomAngle * M_PI / 180.0));
    } completion:nil];
}

- (NSInteger)randomPlusOrMinus {
    return arc4random_uniform(2) == 0 ? -1 : 1;
}
- (CLLocationCoordinate2D)randomCoordinateNear:(CLLocationCoordinate2D)coordinate withMaxDistance:(double)meters {
    double earthRadius = 6371000.0; // Earth radius in meters
    double maxOffset = meters / earthRadius; // Convert meters to degrees
    
    double randomAngle = arc4random_uniform(360) * M_PI / 180.0; // Random direction
    double randomDistance = ((double)arc4random_uniform(meters)) / earthRadius; // Random distance up to 150m
    
    double newLat = coordinate.latitude + (randomDistance * cos(randomAngle)) * (180.0 / M_PI);
    double newLon = coordinate.longitude + (randomDistance * sin(randomAngle)) * (180.0 / M_PI) / cos(coordinate.latitude * M_PI / 180.0);
    
    return CLLocationCoordinate2DMake(newLat, newLon);
}
- (CLLocationCoordinate2D)getCurrentCoordinate:(MKAnnotationView *)annotationView {
    if ([annotationView.annotation conformsToProtocol:@protocol(MKAnnotation)]) {
        return annotationView.annotation.coordinate;
    }
    return kCLLocationCoordinate2DInvalid; // Return invalid coordinate if not found
}
-(CGFloat) DegreesToRadians:(CGFloat )degrees
{
    return degrees * M_PI / 180;
}

-(CGFloat) RadiansToDegrees:(CGFloat) radians
{
    return radians * 180 / M_PI;
}

#pragma api calls

-(void)getNewOrderRequest:(NSNotification *) notification{
    NSDictionary * dict=  notification.userInfo;
    NSMutableDictionary *dicAps=[dict valueForKey:@"aps"];
    NSString *status=[dicAps objectForKey:@"trip_status"];
    NSString *trip_id=[dicAps objectForKey:@"trip_id"];
    defaults_set_object(TRIP_ID, trip_id);
    if(currTrip==nil)
    {
        currTrip=[[TripModel alloc]  init];
        currTrip.trip_Id=trip_id;
    }
    [self checkTripStatus];
}


#pragma mark - Near By Drivers

-(void)onStartRefreshing
{
    [self.activtiyIndicator setHidden:NO];
    [self.activtiyIndicator startAnimating];
    [self.viewTimeDistance setHidden:YES];
}


 

-(BOOL) isAlreadyHas:(CLLocationCoordinate2D)coordinate{
    for (CustomPointAnnotation * point in arrayFakeDriversAnnotation) {
        if(point.coordinate.latitude == coordinate.latitude && point.coordinate.longitude == coordinate.longitude){
            return YES;
        }
    }
    return NO;
}
-(void) addNewAnnotation:(int)limit{
    NSMutableArray *  array = [[NSMutableArray alloc] initWithArray:arrayAllFakeDrivers];
    NSUInteger count = limit;
    if (count > array.count) {
        count = array.count;
    }
    for (NSUInteger i = array.count - 1; i > 0; i--) {
        NSUInteger j = arc4random_uniform((uint32_t)(i + 1));
        [array exchangeObjectAtIndex:i withObjectAtIndex:j];
    }
    NSMutableArray * randomObjects = [[NSMutableArray alloc] init];
    int indexCount = 0;
    for(int i = 0; i < array.count; i++)   {
        if(indexCount<count){
            NSDictionary * driver=[array objectAtIndex:i];
            CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([[driver objectForKey:@"lat"] floatValue], [[driver objectForKey:@"lng"] floatValue]);
            if([self isAlreadyHas:coordinate]==NO){
                [randomObjects addObject:driver];
                indexCount = indexCount + 1;
            }
        }else{
            break;
        }
    }
//    NSArray *randomObjects = [array subarrayWithRange:NSMakeRange(0, count)];
    for(int i = 0; i < randomObjects.count; i++)   {
        NSDictionary  * driver=[randomObjects  objectAtIndex:i];
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([[driver objectForKey:@"lat"] floatValue], [[driver objectForKey:@"lng"] floatValue]);
        CustomPointAnnotation * driverpin=[[CustomPointAnnotation alloc]  initWithType:@"driver-pin-fake"];
        driverpin.degree = [self randomFloatBetween:0 and:360];
        CategoryModel * cModel = [self getSelectectCategoryByRider];
        driverpin.iconPath = cModel.cat_map_icon_path;
        driverpin.coordinate = coordinate;
        [self.mapView addAnnotation:driverpin];
        [arrayFakeDriversAnnotation addObject:driverpin];
    }
}
- (CGFloat)randomFloatBetween:(CGFloat)min and:(CGFloat)max {
    return ((CGFloat)arc4random() / UINT32_MAX) * (max - min) + min;
}


-(void)onRefreshNearByDriver:(NSMutableArray *)arrayDrivers
{
    driversArray =[[NSMutableArray alloc]init];
    
    [self.activtiyIndicator stopAnimating];
    [self.activtiyIndicator setHidden:YES];
    [self.viewTimeDistance setHidden:NO];
    
    if((arrayDrivers.count+arrayAllFakeDrivers.count)==0)
    {
        
        if (selectedButton.tag==4) {
            if(arrayCagetgory.count==1)
            {
                [self.lbDriversAvailableMessage setText:[NSString stringWithFormat:@"- %@",[LanguageHelper getStringWithKey:@"k_r36_s3_no_veh_avail"]]];
            }else{
                [self.lbDriversAvailableMessage setText:[NSString stringWithFormat:@"- %@",[LanguageHelper getStringWithKey:@"k_r36_s3_no_veh_avail"]]];
            }
        }
        else{
            
            [self.lbDriversAvailableMessage setText:[NSString stringWithFormat:@"- %@",[LanguageHelper getStringWithKey:@"k_r36_s3_no_veh_avail"]]];
        }
        [_lbTime setText:@""];
    }
    else{
        //        if (!isPickupSelected) {
        
        
        int arrvingTime=0;
        BOOL isFirst=NO;
        AppDelegate *delegate=APP_DELEGATE;
        CLLocation * locationPick;
        if(isPickupSelected)
        {
            locationPick=nearByDriverHandler.pickUpLocation;
        }else{
            //             locationPick=[[CLLocation alloc] initWithLatitude:delegate.currLoc.latitude longitude:delegate.currLoc.longitude];
            //             locationPick=[[CLLocation alloc] initWithLatitude:centerCoordinate.latitude longitude:centerCoordinate.longitude];
            if(centerCoordinate.latitude!=0)
            {
                locationPick=[[CLLocation alloc] initWithLatitude:centerCoordinate.latitude longitude:centerCoordinate.longitude];
            }else{
                locationPick=[[CLLocation alloc] initWithLatitude:delegate.currLoc.coordinate.latitude longitude:delegate.currLoc.coordinate.longitude];
            }
            
        }
        
        // find nearest driver time
        for (DriverModel *dModel in arrayDrivers) {
            CLLocation * driverLoc=[[CLLocation alloc] initWithLatitude:dModel.lat longitude:dModel.lng];
            float distance=[locationPick distanceFromLocation:driverLoc]/1000.0;
            //                driverLoc
            int arrvingTimeTemp=(int)(distance*60/15.0);
            
            if (!isFirst) {
                isFirst =YES;
                arrvingTime = arrvingTimeTemp;
            }
            if(arrvingTimeTemp<=arrvingTime)
            {
                arrvingTime=arrvingTimeTemp;
            }
            
        }
        if(arrvingTime<=1)
        {
            arrvingTime=1;
        }
        
        [_lbTime setText:[NSString stringWithFormat:@"%d%@",arrvingTime,[LanguageHelper getStringWithKey:arrvingTime<=1?@"k_17_s4_min":@"k_17_s4_mins"]]];
        //        }
        if (selectedButton.tag==4) {
            
            [self.lbDriversAvailableMessage setText:[NSString stringWithFormat:@"- %@",[LanguageHelper getStringWithKey:@"k_r59_s3_veh_avail"]]];
        }
        else{
            
            [self.lbDriversAvailableMessage setText:[NSString stringWithFormat:@"- %@",[LanguageHelper getStringWithKey:@"k_r59_s3_veh_avail"]]];
        }
    }
    
    driversArray=arrayDrivers;
    [self showAllDrivers:driversArray];
    [self refreshHomeAvailabilityLabel];
}


-(void) shwoArrivingTime
{
    int arrvingTime=0;
    BOOL isFirst=NO;
    AppDelegate *delegate=APP_DELEGATE;
    CLLocation * locationPick;
    if(isPickupSelected)
    {
        locationPick=nearByDriverHandler.pickUpLocation;
    }else{
        //        locationPick=[[CLLocation alloc] initWithLatitude:delegate.currLoc.latitude longitude:delegate.currLoc.longitude];
        if(centerCoordinate.latitude!=0)
        {
            locationPick=[[CLLocation alloc] initWithLatitude:centerCoordinate.latitude longitude:centerCoordinate.longitude];
        }else{
            locationPick=[[CLLocation alloc] initWithLatitude:delegate.currLoc.coordinate.latitude longitude:delegate.currLoc.coordinate.longitude];
        }
    }
    
    // find nearest driver time
    for (DriverModel *dModel in driversArray) {
        CLLocation * driverLoc=[[CLLocation alloc] initWithLatitude:dModel.lat longitude:dModel.lng];
        float distance=[locationPick distanceFromLocation:driverLoc]/1000.0;
        //                driverLoc
        int arrvingTimeTemp=(int)(distance*60/15.0);
        
        if (!isFirst) {
            isFirst =YES;
            arrvingTime = arrvingTimeTemp;
        }
        if(arrvingTimeTemp<=arrvingTime)
        {
            arrvingTime=arrvingTimeTemp;
        }
        
    }
    if(arrvingTime<=1)
    {
        arrvingTime=1;
    }
    
    [_lbTime setText:[NSString stringWithFormat:@"%d%@",arrvingTime,[LanguageHelper getStringWithKey:arrvingTime<=1?@"k_17_s4_min":@"k_17_s4_mins"]]];
}



-(void)setCategoryViews:(NSArray *)arrCategory{
    if(arrCategory.count==0) {
        self.scrollViewCategory.hidden=YES;
    }else{
        self.scrollViewCategory.hidden=NO;
    }
    [_viewCategoryBg setTranslatesAutoresizingMaskIntoConstraints:YES];
    for (UIView *view in [_viewCategoryBg subviews]){
        [view removeFromSuperview];
    }
    [arrButtons removeAllObjects];
    float cellWidth = self.view.frame.size.width/3;
    //_categoryBgWidthConstraints.constant = cellWidth*(arrCategory.count+4);
    _viewCategoryBg.frame =CGRectMake(0, 0, cellWidth*arrCategory.count, 100);
    _viewCategoryBg.backgroundColor =[UIColor clearColor];
    for (int i=0; i<arrCategory.count; i++) {
        CategoryCell *catCell = [[CategoryCell alloc] initFromNib];
        catCell.frame = CGRectMake(i*cellWidth,0 , cellWidth, 100);
        catCell.btnFareInfo.frame = CGRectMake(cellWidth - 50, 20, 30  , 30);
        catCell.lblCategoryName.frame = CGRectMake(0, 5, cellWidth+1, 22);
        [catCell.lblCategoryName setFont:FONTS_THEME_REGULAR(16)];
        [catCell.lblCategoryName setTextColor: [UIColor colorNamed:@"color_app_label"]];
        [catCell.lblCategoryName setTranslatesAutoresizingMaskIntoConstraints:YES];
        catCell.backgroundColor =[UIColor clearColor];
        CategoryModel *catModel=[arrCategory objectAtIndex:i];
        NSString * stringNSLocalizedStringKey=[NSString stringWithFormat:@"%@",catModel.cat_name];
        catCell.lblCategoryName.text = stringNSLocalizedStringKey;
        [_viewCategoryBg addSubview:catCell];
        catCell.indexFareinfo = i;
        catCell.deleate =self;
    }
    arrButtonsImages=[[NSMutableArray alloc] init];
    arrFareInfoButtons=[[NSMutableArray alloc] init];
    int heightOfCatImage=70;
    int widthOfCatImage=85;
    int top=25.0;
    for (int i=0; i<arrCategory.count; i++) {
        UIButton *btnCat = [[UIButton alloc]initWithFrame:CGRectMake( i*cellWidth+cellWidth/2-widthOfCatImage/2.0,top  ,widthOfCatImage , heightOfCatImage)];
        [btnCat setImageEdgeInsets:UIEdgeInsetsMake(4, 4, 4, 4)];
        [btnCat setContentMode:UIViewContentModeCenter];
        [[btnCat imageView] setContentMode: UIViewContentModeScaleAspectFit];
        [btnCat addTarget:self action:@selector(onCatgoryButtonTap:) forControlEvents:UIControlEventTouchUpInside];
        UIImageView *catImage = [[UIImageView alloc] initWithFrame: CGRectMake(i*cellWidth+cellWidth/2-widthOfCatImage/2.0,top  ,widthOfCatImage , heightOfCatImage)];
        catImage.clipsToBounds=YES;
        CategoryModel * category = [arrCategory  objectAtIndex:i];
        [catImage  sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",category.cat_image_path]]];
        catImage.contentMode=UIViewContentModeScaleAspectFill;
        [arrButtons addObject:btnCat];
        [arrButtonsImages addObject:catImage];
        CategoryModel * cateModel=[arrCategory objectAtIndex:i];
        btnCat.tag = cateModel.categoryId;
        [_viewCategoryBg addSubview:catImage];
        [_viewCategoryBg addSubview:btnCat];
        UIButton *btnCatInfo = [[UIButton alloc]initWithFrame:CGRectMake( i*cellWidth+cellWidth/2-widthOfCatImage/2.0+60,top - 4 ,30 , 30)];
        [btnCatInfo setImageEdgeInsets:UIEdgeInsetsMake(8, 8, 8, 8)];
        [btnCatInfo setImage:[UIImage imageNamed:@"ic_information"] forState:(UIControlStateNormal)];
        [_viewCategoryBg addSubview:btnCatInfo];
        btnCatInfo.hidden=YES;
        [btnCatInfo addTarget:self action:@selector(onFareInfoButtonTaped:) forControlEvents:UIControlEventTouchUpInside];
        btnCatInfo.tag = i;
        [arrFareInfoButtons addObject:btnCatInfo];
    }
    
    //    NSTimeInterval delayInSeconds = 0.4;
    //    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    //    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
    [self onCatgoryButtonTap:[arrButtons objectAtIndex:0]];
    //    });
    [_scrollViewCategory setContentSize:CGSizeMake(cellWidth*(arrCategory.count), 100)];

    // La fila que ve el pasajero es la nueva; esta de arriba es la del template
    // viejo, que sigue viva pero oculta. Repintar aqui es el unico enganche que hace
    // falta: getCategoryFormServer ya llama a este metodo cuando llegan las categorias.
    [self rebuildVehicleCards];
}


-(void)onFareInfoButtonTaped:(UIButton *)sender{
    CategoryModel * category=[arrayCagetgory objectAtIndex:sender.tag];
    EstimatedFare *estimatedFare=[_bookingModel getEstimateFareForCategory:category.categoryId];
    EstimateFareInfoViewController *vc = (EstimateFareInfoViewController *)[StoryBoardUtiles viewContollerWithIdentifier:@"EstimateFareInfoViewController" name:StoryBoardUtiles.STORYBOARD_EXTRA_FEATURE];
    vc.modalPresentationStyle=UIModalPresentationOverCurrentContext;
    vc.modalTransitionStyle=UIModalTransitionStyleCrossDissolve;
    BookingModel *bookingModel=[[BookingModel alloc] init];
    bookingModel.cityModel=cityModel;
    bookingModel.category=category;
    bookingModel.totalTime=tripTime;
    bookingModel.totalDistance=tripDistance;
    bookingModel.directionModel=directionModel;
    bookingModel.isRiderSahre = isShareRideButtonTap;
    vc.bookingModel=bookingModel;
    bookingModel.fareEstimated=[estimatedFare.distReponse mutableCopy];
    vc.delegate=self;
    [self presentViewController:vc animated:YES completion:^{
        
    }];
}

- (IBAction)onCatgoryButtonTap:(UIButton *)sender {
    [selectedButton setImage:nil forState:UIControlStateNormal];
    selectedButton = sender;
    int selectedIndex=0;
    for (int i=0; i<arrButtons.count; i++) {
        if([arrButtons objectAtIndex:i]==selectedButton) {
            selectedIndex=i;
        }
    }
    self.imShareRide.image=[UIImage imageNamed:@"icon_unchecked"];
    self.btnShare.selected=NO;
    isShareRideButtonTap=NO;
    for (int i=0; i<arrButtons.count; i++) {
        UIButton * btn=[arrButtons objectAtIndex:i];
        if(selectedIndex==i){
            btn.layer.borderWidth = 0.5;
            
            if (@available(iOS 13.0, *)) {
                if (UITraitCollection.currentTraitCollection.userInterfaceStyle == UIUserInterfaceStyleLight) {
                    btn.layer.borderColor = [UIColor blackColor].CGColor;
                } else {
                    btn.layer.borderColor = [UIColor whiteColor].CGColor;
                }
            } else {
                btn.layer.borderColor = [UIColor blackColor].CGColor;
            }
            
            //            btn.layer.borderWidth = 0.5;
            [btn setBackgroundColor:[UIColor clearColor]];
            [btn.layer setCornerRadius: 5 ];
            //            [btn.layer setCornerRadius: btn.frame.size.width / 2 ];
            for (CategoryModel * category in arrayCagetgory) {
                if(category.categoryId==selectedButton.tag){
                    if(category.is_share)  {
                        if([constantTaxiModel getCValueFK:ckey_srd]) {
                            self.viewShareButton.hidden=NO;
                        }
                    }else{
                        self.viewShareButton.hidden=YES;
                    }
                    break;
                }
            }
        }else  {
            [btn setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
            btn.layer.borderColor = [UIColor colorNamed:@"color_app_label"].CGColor;
            btn.layer.borderWidth = 0;
            [btn setBackgroundColor:[UIColor clearColor]];
            [btn.layer setCornerRadius: 5 ];
        }
    }
    for (CategoryModel * category in arrayCagetgory) {
        if(category.categoryId==selectedButton.tag)
        {
            Selectedcategory=category;
            break;
        }
    }
    [nearByDriverHandler changeCategoryId:Selectedcategory.categoryId city_id:[NSString stringWithFormat:@"%d",cityModel.city_id]];
    if (isMapRouteMake) {
        [self showFareInfoForCategory];
    }
}





#pragma mark - MKMapViewDelegate methods

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    if ([overlay isKindOfClass:[MKPolygon class]])
    {
        __weak id<MKOverlay> weakOverlay=overlay;
        MKPolygonRenderer *renderer = [[MKPolygonRenderer alloc] initWithPolygon:(MKPolygon *)weakOverlay];
        
        //        renderer.fillColor   = [[UIColor cyanColor] colorWithAlphaComponent:0.2];
        if([self isDarkMode]){
            renderer.fillColor = [UIColor whiteColor];
            renderer.strokeColor = [UIColor whiteColor];
        }else{
            renderer.fillColor = [UIColor blackColor];
            renderer.strokeColor = [UIColor blackColor];
        }
        // renderer.strokeColor = [[UIColor blueColor] colorWithAlphaComponent:0.7];
        renderer.lineWidth   = 1;
        
        return renderer;
    }
    else{
        MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithPolyline:(MKPolyline *)overlay];
        renderer.strokeColor = [UIColor colorNamed:@"app_theame"];
        renderer.lineWidth = 4.0;
        renderer.lineJoin = kCGLineJoinRound;
        renderer.lineCap = kCGLineCapRound;
        return renderer;
    }
}
#pragma -mark promocode

- (IBAction)onConfirmBookingButTap:(id)sender {
    if(self.txtPickupAddress.text.length==0 ||direction.pickAddress.length==0){
        [self showAlert:@"" message:[LanguageHelper getStringWithKey:@"k_r7_s3_enter_pickup_loc"]];
        return;
    }
    if(![constantTaxiModel getCValueFK:ckey_eod]) {
        if(self.txtDestinationAddres.text.length==0 ||direction.dropAddress.length==0)  {
            [self showAlert:@"" message:[LanguageHelper getStringWithKey:@"k_r57_s3_plz_sel_drp_loc"]];
            return;
        }
    }
    
    if((driversArray.count+arrayAllFakeDrivers.count)==0&&isRideLaterButtonTap==NO){
        [self showAlert:@"" message:[LanguageHelper getStringWithKey:@"k_r40_s3_driver_nt_avail"]];
    }
    else{
        
        // Sin metodo de pago no se pide el viaje. Android lo bloquea igual
        // (MainScreenActivity: "else if (payMode.isEmpty()) { showPaymentOptions() }").
        // Sin esto el viaje sale con trip_pay_mode vacio y ni el conductor sabe como le
        // van a pagar ni la fila de metodo de pago tiene nada que enseñar.
        if (paymentViewModel.paymentMode < 0 || paymentViewModel.tripPayMode.length == 0) {
            [self fareOfferVCDidTapPayment:currentFareOfferVC];
            return;
        }

        NSDictionary *WalletAmtDict = [[NSUserDefaults standardUserDefaults]objectForKey:P_USER_DICT];
        float walletamount=[[WalletAmtDict objectForKey: P_USER_WAlLET_AMOUNT] floatValue];
        if(walletamount<0) {
            [self showAddMoneyAlert];
            return;
        }
        // Con la billetera elegida hay que volver a mirar el saldo: se comprobo al
        // elegirla, pero la tarifa puede haber subido despues -- el recargo por
        // pasajeros, sin ir mas lejos. Android tiene esta misma comprobacion aqui.
        if (paymentViewModel.paymentMode == 1) {
            float tarifa = [self.txtExtmatedFareAmt.text floatValue];
            if (tarifa > 0 && walletamount < tarifa) {
                [self showAddMoneyAlert];
                return;
            }
        }
        if(isRideLaterButtonTap)   {
            if(selectedRideLaterDate==nil)  {
                [self showAlert:@"" message:[LanguageHelper getStringWithKey:@"k_r53_s3_plz_sel_ride_time"]];
            }else  {
                [self createTrip:selectedRideLaterDate];
            }
        }else{
            [self createTrip];
        }
    }
}

- (IBAction)onApplyCouponButTap:(id)sender {
    if(promoCode==nil){
        self.viewMinOffer.hidden=YES;
        [self.btnRemovePromoCode setConstraintConstant:0 forAttribute:NSLayoutAttributeWidth];
        //[self.showButtonOnView setConstraintConstant:70 forAttribute:NSLayoutAttributeHeight];
        [self.viewPromocodeEnter setHidden:NO];
        [self.txtPromocode becomeFirstResponder];
    }else{
        
    }
}

- (IBAction)onCouponCancelButTap:(id)sender {
    if(promoCode==nil)     {
        [self.viewConfirmViewShow setHidden:YES];
    }
    [self.btCouponApply setTitle:[LanguageHelper getStringWithKey:@"k_r45_s3_apply_coupon"] forState:UIControlStateNormal];
    self.btCouponApply.titleLabel.font=FONTS_THEME_REGULAR_NO_SCALE(15);
    int width = [Utilities widthOfString:[LanguageHelper getStringWithKey:@"k_r45_s3_apply_coupon"] withFont:FONTS_THEME_REGULAR_NO_SCALE(15)];
    [self.btCouponApply setConstraintConstant:width+10 forAttribute:NSLayoutAttributeWidth];
    //    [self.viewConfirmViewShow setHidden:NO];
    BOOL isCouponApplied=NO;
    if(promoCode){
        isCouponApplied=YES;
    }
    promoCode=nil;
    self.txtPromocode.text=@"";
    if(isCouponApplied){
        [self calCalculateFare:YES];
    }
}


- (IBAction)onPromoEnterCancelButTap:(id)sender {
    [self.view endEditing:YES];
    self.viewMinOffer.hidden=NO;
    //[self.showButtonOnView setConstraintConstant:90 forAttribute:NSLayoutAttributeHeight];
    [self.viewPromocodeEnter setHidden:YES];
    self.txtPromocode.text=@"";
    self.viewEstimateFareInput.hidden=NO;
}

- (IBAction)onRemoveAppliedPromoCode:(id)sender {
    self.viewMinOffer.hidden=NO;
    [self onCouponCancelButTap:sender];
}


- (IBAction)onRequestButtonTap:(id)sender {
    if([self isCheckLocationFailedScreen]){
        [self locatonGetFailedScreen:self.locationManager isBackHidden:YES];
        return;
    }
    if(cityModel==nil)  {
        [self showAlert:@"" message:[LanguageHelper getStringWithKey:@"k_r51_s3_service_nt_avail"]];
        return;
    }
    
    
    if(self.txtPickupAddress.text.length==0 ||direction.pickAddress.length==0)  {
        [self showAlert:@"" message:[LanguageHelper getStringWithKey:@"k_r7_s3_enter_pickup_loc"]];
        return;
    }
    if([direction isSourceEmpty])  {
        [self showAlert:@"" message:[LanguageHelper getStringWithKey:@"k_r7_s3_enter_pickup_loc"]];
        return;
    }
    if(![constantTaxiModel getCValueFK:ckey_eod]) {
        if(self.txtDestinationAddres.text.length==0 ||direction.dropAddress.length==0)    {
            [self showAlert:@"" message:[LanguageHelper getStringWithKey:@"k_r57_s3_plz_sel_drp_loc"]];
            return;
        }
        if([direction isDestinationEmpty])   {
            [self showAlert:@"" message:[LanguageHelper getStringWithKey:@"k_r57_s3_plz_sel_drp_loc"]];
            return;
        }
    }
    
    
    if([self.txtExtmatedFareAmt.text floatValue]<=0){
        [self showAlertWithMessgae:[LanguageHelper getStringWithKey:@"k_r1_s6_please_enter_amount"]];
        return;
    }
    
    if([_bookingModel.category isAllowToCheckMaxMin]){
        float estmateFare = [self getEstimatedFare];
        float minfare = estmateFare - (estmateFare *_bookingModel.category.min_offer_perc)/100.0;
        float maxfare = estmateFare + (estmateFare *_bookingModel.category.max_offer_perc)/100.0;
        if([self.txtExtmatedFareAmt.text floatValue]<minfare){
            [self showAlertWithMessgae:[LanguageHelper getStringWithKey:@"k_r1_s6_pls_ntr_amnt_grtr_thn_min_fare"]];
            return;
        }
        if([self.txtExtmatedFareAmt.text floatValue]>maxfare){
            [self showAlertWithMessgae:[LanguageHelper getStringWithKey:@"k_r1_s6_pls_ntr_amnt_less_thn_max_fare"]];
            return;
        }
    }
    if([[ConstantModel getConstantsObject] getCValueFK:ckey_epp]){
        if(paymentViewModel.tripPayMode.length==0){
            [self showAlertWithMessgae:[LanguageHelper getStringWithKey:@"k_r35_s1_please_select_payment_method"]];
            return;
        }
    }

    if((driversArray.count+arrayAllFakeDrivers.count)==0){
        [self showAlert:@"" message:[LanguageHelper getStringWithKey:@"k_r40_s3_driver_nt_avail"]];
    }
    else{
        isRideLaterButtonTap=NO;
        [self showRadarAnimation];
        [self createTrip];     }
}




- (IBAction)ButtonMenuPressed:(id)sender {
    [self.sideMenuController showLeftViewAnimated:YES completionHandler:nil];
}



- (IBAction)onPromocodeApply:(id)sender {
    [self.view endEditing:YES];
    NSString *promoCodeText = [self.txtPromocode.text stringByTrimmingCharactersInSet:
                               [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if(promoCodeText.length==0)   {
        [Utilities showAlertwithTilte:@"" message:[LanguageHelper getStringWithKey:@"k_r49_s3_plz_enter_valid_promo_code"] navigatationController:self.navigationController];
        return;
    }
    if(cityModel==nil)   {
        [Utilities showAlertwithTilte:@"" message:[LanguageHelper getStringWithKey:@"k_r30_s5_select_city"] navigatationController:self.navigationController];
        return;
    }
    promoCode=[[PromoCodeModel alloc]  initWithPromode:promoCodeText  city_id:cityModel.city_id];
    [self calCalculateFare:YES];
}

-(void) promoCodeShowOnText{
    
}



- (IBAction)onShowMyLocationTap:(id)sender {
    isMapDraged=NO;
    isDragged =NO;
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance([APP_DELEGATE currLoc].coordinate, 800, 800);//600,600
    [self mapRegion:region mapView:self.mapView];
    if(!isMapRouteMake && isHome){
        tripCheckTimerForMyLocation = [NSTimer scheduledTimerWithTimeInterval: 1.0 target: self
                                                                     selector: @selector(callNearbyDriverOnMyLocationTap) userInfo: nil repeats: NO];
        
    }
    if(self.txtPickupAddress.text.length==0 ||direction.pickAddress.length==0){
        [ self checkLocationInsieCityMatch:[APP_DELEGATE currLoc].coordinate];
    }else{
        
    }
}

-(void)callNearbyDriverOnMyLocationTap{
    if( isPickupSelected==NO){
        CLLocation * userLoc=[[CLLocation alloc]  initWithCoordinate:centerCoordinate altitude:0 horizontalAccuracy:5 verticalAccuracy:5 timestamp:[NSDate date]];
        [nearByDriverHandler changePickUpLocation:userLoc];
    }
}


-(void)clearMapView{
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self removePolyline];
    
}

-(void)reset:(id)sender{
    self.btPickupDetail.hidden=YES;
    [self.txtDestinationAddres setText:@""];
    [self.txtPickupAddress setText:@""];
    direction.dropAddress =@"";
    direction.dropCountry=@"";
    direction.pickAddress =@"";
    direction.pickCountry=@"";
    
    // share Ride
    isShareRideButtonTap=NO;
    self.imShareRide.image=[UIImage imageNamed:@"icon_unchecked"];
    // share Ride End
    
    [self onShowMyLocationTap:nil];
    isMapRouteMake=NO;
    direction.source =[[CLLocation alloc]initWithLatitude:emptyLoc.latitude longitude:emptyLoc.longitude];;
    direction.destination =[[CLLocation alloc]initWithLatitude:emptyLoc.latitude longitude:emptyLoc.longitude];
    [self.view endEditing:YES];
    
    [self.imCenterPickupLocation setHidden:NO];
    [self.viewCallout setHidden:NO];
    
    isDropSelected = NO;
    isPickupSelected =NO;
    [self setTitleForPickDrop:PICK_LOCATION];
    btnPickupState =@"search";
    [self clearMapView];
    promoCode=nil;
    self.viewInputOffer.hidden=NO;
    [self.btnRemovePromoCode setConstraintConstant:0 forAttribute:NSLayoutAttributeWidth];
    //[self.showButtonOnView setConstraintConstant:90 forAttribute:NSLayoutAttributeHeight];
    self.viewConfirmViewShow.hidden=YES;
    [self.btCouponApply setTitle:[LanguageHelper getStringWithKey:@"k_r45_s3_apply_coupon"] forState:UIControlStateNormal];
    self.btCouponApply.titleLabel.font=FONTS_THEME_REGULAR_NO_SCALE(15);
    int width = [Utilities widthOfString:[LanguageHelper getStringWithKey:@"k_r45_s3_apply_coupon"] withFont:FONTS_THEME_REGULAR_NO_SCALE(15)];
    [self.btCouponApply setConstraintConstant:width+10 forAttribute:NSLayoutAttributeWidth];
    [self invalidateResetPickDrop];
    [self->paymentViewModel updatePaymentModeText:-1];
}

-(void)onAddressEndEditing{
    
}


#pragma API CALLS

-(void)getCategoryFormServer{
    [UtilityClass setLH:NO wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
    NSMutableDictionary * dict=[[NSMutableDictionary alloc] init];
    if(cityModel==nil) {
        return;
    }
    if(cityModel) {
        [dict setObject:[NSString stringWithFormat:@"%d",cityModel.city_id] forKey:P_CITY_ID];
    }
    [GIC mkwu:CAR_GETCATEGORY   d:dict   isa:NO cb:^(id results, NSError *error) {
        self->apiCallAttempt++;
        if([[[results objectForKey:P_STATUS] uppercaseString]isEqualToString:@"OK"]) {
            NSObject * response=[results objectForKey:P_RESPONSE];
            if([response isKindOfClass:[NSArray class]]) {
                NSMutableArray *arrCat = [[NSMutableArray alloc]initWithArray:[results objectForKey:P_RESPONSE]];
                defaults_set_object(@"categoryResponse", arrCat);
                NSMutableArray *arrayCategoryTemp=[CategoryModel parseResponse:arrCat];
                NSSortDescriptor *sortOrder= [NSSortDescriptor sortDescriptorWithKey:@"cat_sort_order" ascending:YES];
                NSArray *sortDescriptors = [NSArray arrayWithObject:sortOrder];
                self->arrayCagetgory = [[arrayCategoryTemp sortedArrayUsingDescriptors:sortDescriptors] mutableCopy];
                [self setCategoryViews:self->arrayCagetgory];
            }
        }
        else{
            for (UIView *view in [self->_viewCategoryBg subviews])
            {
                [view removeFromSuperview];
            }
            [self->arrButtons removeAllObjects];
            if(self->apiCallAttempt<3){
                [self getCategoryFormServer];
            }
        }
        [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
    }];
}


-(void)getTaxiConstant{
    constantTaxiModel =[ConstantModel getConstantsObject];
    [self checkAndShowAlertWith];
}


-(void)setfareDetails:(float)distance isFrom:(BOOL)fromCat{
    if(cityModel==nil)   {
        [Utilities showAlertwithTilte:@"" message:[LanguageHelper getStringWithKey:@"k_r51_s3_service_nt_avail"] navigatationController:self.navigationController];
        return;
    }
    float distanceConvertedInUnit=0.0;
    
    if (isDistanceUnitKm(cityModel.city_dist_unit)/*[[constantTaxiModel.constant_distance capitalizedString] isEqualToString:@"Km"]*/) {
        //        dis =cityModel.city_dist_unit;
        distanceConvertedInUnit =distance;
    }
    else{
        //        dis =cityModel.city_dist_unit;
        float miles = distance*0.621371192;
        distanceConvertedInUnit = distance*0.621371192;
    }
    tripDistanceConvertedInUnit=distanceConvertedInUnit;
    CategoryModel *catModel=[self getSelectectCategoryByRider];
    self->_bookingModel=[[BookingModel alloc] init];
    if(catModel.is_share){
        self->_bookingModel.num_seats=0;
    }
    self->_bookingModel.category=catModel;
    self->_bookingModel.cityModel=cityModel;
    //    self->_bookingModel.duration_in_traffic=0;
    self->_bookingModel.totalTime=tripTime;
    self->_bookingModel.totalDistance=distance;
    self->_bookingModel.direction=direction;
    self->_bookingModel.routeArray=directionModel.arrDirectionLatLng;
    [self calCalculateFare];
}


-(void)calCalculateFare{
    [self calCalculateFare:NO];
}
-(void)calCalculateFare:(BOOL)callFromPromocode{
    [UtilityClass setLH:NO wt:[LanguageHelper getStringWithKey:@"k_r16_s3_plz_wait"]];
    [_bookingModel callFareEstimateApiWithCompletionBlock:^(id  _Nonnull results, NSError * _Nonnull error) {
        [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_r16_s3_plz_wait"]];
        if(isStatusError(results)){
            [self showAlertWithMessgae:[LanguageHelper getStringWithKey:[results objectForKey:P_MESSAGE]]];
            return;
        }
        if(error!=nil){
            if(![self isHandledError:error]){
                [self showAlertWhenEstimateApiFailed];
            }
            return;
        }
        if (!pendingScreen3Presentation) self.showButtonOnView.hidden = NO;
        [self showFareInfoForCategory];
        if(callFromPromocode){
            //            PromoCode *cc=[self->_bookingModel poromCodeApplied];
            if(self->promoCode){
                [self.btCouponApply setTitle:[LanguageHelper getStringWithKey:@"k_r25_s3_coupon_applied"] forState:UIControlStateNormal];
                self.btCouponApply.titleLabel.font=FONTS_THEME_BOLD_NO_SCALE(15);
                int width = [Utilities widthOfString:[LanguageHelper getStringWithKey:@"k_r25_s3_coupon_applied"] withFont:FONTS_THEME_BOLD_NO_SCALE(15)];
                [self.btCouponApply setConstraintConstant:width+10 forAttribute:NSLayoutAttributeWidth];
                [self.btnRemovePromoCode setConstraintConstant:30 forAttribute:NSLayoutAttributeWidth];
                [self.viewPromocodeEnter setHidden:YES];
                //                self.viewInputOffer
                [self.btnRemovePromoCode setHidden:NO];
                
            }else{
                [self.btnRemovePromoCode setHidden:YES];
                [self.viewPromocodeEnter setHidden:YES];
                [self.btCouponApply setTitle:[LanguageHelper getStringWithKey:@"k_r45_s3_apply_coupon"] forState:UIControlStateNormal];
                self.btCouponApply.titleLabel.font=FONTS_THEME_REGULAR_NO_SCALE(15);
                int width = [Utilities widthOfString:[LanguageHelper getStringWithKey:@"k_r45_s3_apply_coupon"] withFont:FONTS_THEME_REGULAR_NO_SCALE(15)];
                [self.btCouponApply setConstraintConstant:width+10 forAttribute:NSLayoutAttributeWidth];
            }
        }
        
        
    } promoCode:promoCode];
}

-(void) showFareInfoForCategory{
    // Screen 3 flow: skip legacy UI updates, present fare sheet instead
    if (pendingScreen3Presentation) {
        isFareCalculated = YES;
        pendingScreen3Presentation = NO;
        [self presentScreen3];
        return;
    }
    [self categoryFareInformationIsHidden:NO];
    EstimatedFare *estimatedFare=[_bookingModel getEstimateFareForCategory:[self getSelectectCategoryByRider].categoryId];
    _bookingModel.fareEstimated=_bookingModel.fareEstimated;
    self.lblCurrency.text=isEmpty(cityModel.city_cur);
    if(estimatedFare){
        isFareCalculated=YES;
        [self showFareOnLabelWithEstimate:estimatedFare];
        if(estimatedFare.trip_promo_amt>0) {
            self.txtExtmatedFareAmt.text=[Utilities formatAmount:estimatedFare.trip_pay_amount_without_share_discount_without_promo];
            float minfare = estimatedFare.trip_pay_amount_without_share_discount_without_promo - (estimatedFare.trip_pay_amount_without_share_discount_without_promo *_bookingModel.category.min_offer_perc)/100.0;
            self.viewMinOffer.text = [NSString stringWithFormat:@"%@: %@",[LanguageHelper getStringWithKey:@"k_r1_s6_min_bid_amt"],[Utilities formatAmountAndCurrency:minfare currency:isEmpty(cityModel.city_cur)]];
            [self.btnRemovePromoCode setConstraintConstant:30 forAttribute:NSLayoutAttributeWidth];
        }else{
            [self.btnRemovePromoCode setConstraintConstant:0 forAttribute:NSLayoutAttributeWidth];
            if(isShareRideButtonTap){
                self.txtExtmatedFareAmt.text=[Utilities formatAmount:estimatedFare.trip_pay_amount_without_share_discount_without_promo];
                float minfare = estimatedFare.trip_pay_amount_without_share_discount_without_promo - (estimatedFare.trip_pay_amount_without_share_discount_without_promo *_bookingModel.category.min_offer_perc)/100.0;
                self.viewMinOffer.text = [NSString stringWithFormat:@"%@: %@",[LanguageHelper getStringWithKey:@"k_r1_s6_min_bid_amt"],[Utilities formatAmountAndCurrency:minfare currency:isEmpty(cityModel.city_cur)]];
            }else{
                self.txtExtmatedFareAmt.text=[Utilities formatAmount:estimatedFare.trip_pay_amount_without_share_discount_without_promo];
                float minfare = estimatedFare.trip_pay_amount_without_share_discount_without_promo - (estimatedFare.trip_pay_amount_without_share_discount_without_promo *_bookingModel.category.min_offer_perc)/100.0;
                self.viewMinOffer.text = [NSString stringWithFormat:@"%@: %@",[LanguageHelper getStringWithKey:@"k_r1_s6_min_bid_amt"],[Utilities formatAmountAndCurrency:minfare currency:isEmpty(cityModel.city_cur)]];
            }
        }
    }
    if(_bookingModel.num_seats==0){
        self.showButtonOnView.hidden = YES;
        [self categoryFareInformationIsHidden:YES];
    }else{
        self.showButtonOnView.hidden = NO;
        [self categoryFareInformationIsHidden:NO];
    }
}



-(float) getEstimatedFare{
    EstimatedFare *estimatedFare=[_bookingModel getEstimateFareForCategory:[self getSelectectCategoryByRider].categoryId];
    if(estimatedFare){
        isFareCalculated=YES;
        if(estimatedFare.trip_promo_amt>0) {
            return estimatedFare.trip_pay_amount;
        }else{
            if(isShareRideButtonTap){
                return estimatedFare.trip_pay_amount;
            }else{
                return estimatedFare.trip_pay_amount;
            }
        }
    }
    return 0;
}

-(void)showAlertWhenEstimateApiFailed{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[LanguageHelper getStringWithKey:@"k_33_s7_alert"]
                                                                             message:[LanguageHelper getStringWithKey:@"k_18_s4_api_retry_msg" defaultValue:@"Api Failed to calculate fare"]
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *actionOk = [UIAlertAction actionWithTitle:[LanguageHelper getStringWithKey:@"k_18_s4_retry" defaultValue:@"Retry"]
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {
        [self calCalculateFare];
    }];
    [alertController addAction:actionOk];
    UIAlertAction *actionRest = [UIAlertAction actionWithTitle:[LanguageHelper getStringWithKey:@"Ok"]
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * _Nonnull action) {
        //        self->isDataLoadErrorAlertShow=NO;
        [self reset:nil];
    }];
    [alertController addAction:actionRest];
    [self presentViewController:alertController animated:YES completion:nil];
}


-(BOOL) isHandledError:(NSError *) error{
    NSData *data=[error.userInfo objectForKey:@"com.alamofire.serialization.response.error.data"];
    if(data){
        NSError * jsonError=nil;
        id json= [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonError];
        if([json isKindOfClass:[NSDictionary class]]) {
            NSString * message=[json objectForKey:@"message"];
            [self showAlertWithMessgae:message];
            return YES;
        }
    }
    return NO;
}


-(CategoryModel *) getSelectectCategoryByRider{
    if (Selectedcategory) return Selectedcategory;
    // Legacy fallback for old button-tag based selection
    for (CategoryModel * category in arrayCagetgory) {
        if(category.categoryId==selectedButton.tag)
        {
            return category;
        }
    }
    return nil;
}



- (void) CenterMapRegionForShot {
    
    if (!isDragged && !self.imCenterPickupLocation.isHidden) {
        
        AppDelegate *delegate = APP_DELEGATE;
        CLLocation *myLocation = [[CLLocation alloc]initWithLatitude:delegate.currLoc.coordinate.latitude longitude:delegate.currLoc.coordinate.longitude];
        _mapView.camera.centerCoordinate = myLocation.coordinate;
        [self.mapView setCamera:self.mapView.camera];
    }
}



-(void)clearRoute:(UITextField *)textfield{
    if (textfield == self.txtPickupAddress) {
        direction.source =[[CLLocation alloc]initWithLatitude:emptyLoc.latitude longitude:emptyLoc.longitude];;
        [self.mapView removeAnnotation:pickUpPin];
        [arrAnotation removeObject:pickUpPin];
        isPickupSelected =NO;
        self.btPickupDetail.hidden=YES;
        [self.mapView removeAnnotation:dropPin];
        [arrAnotation removeObject:dropPin];
        isDropSelected = NO;
        
    }
    else if (textfield == self.txtDestinationAddres){
        
        direction.destination =[[CLLocation alloc]initWithLatitude:emptyLoc.latitude longitude:emptyLoc.longitude];;
        [self.mapView removeAnnotation:dropPin];
        [arrAnotation removeObject:dropPin];
        isDropSelected =NO;
        
    }
    [self.imCenterPickupLocation setHidden:NO];
    [self.viewCallout setHidden:NO];
    [self removePolyline];
    
    [self onShowMyLocationTap:nil];
}

-(void)onAddressShouldClear:(SuggestedLocationDataSource *) soure{
    if (soure.textField == self.txtPickupAddress) {
        
        direction.source =[[CLLocation alloc]initWithLatitude:emptyLoc.latitude longitude:emptyLoc.longitude] ;
        [self.mapView removeAnnotation:pickUpPin];
        [arrAnotation removeObject:pickUpPin];
        [self.mapView removeAnnotation:dropPin];
        [arrAnotation removeObject:dropPin];
        isPickupSelected =NO;
        self.btPickupDetail.hidden=YES;
        isDropSelected = NO;
    }
    else if (soure.textField == self.txtDestinationAddres){
        
        direction.destination =[[CLLocation alloc]initWithLatitude:emptyLoc.latitude longitude:emptyLoc.longitude] ;;
        [self.mapView removeAnnotation:dropPin];
        [arrAnotation removeObject:dropPin];
        isDropSelected = NO;
        
    }
    [self.imCenterPickupLocation setHidden:NO];
    [self.viewCallout setHidden:NO];
    [self removePolyline];
    
    
    
}


-(void)onAddressEmptyShouldClear:(SuggestedLocationDataSource *) soure{
    if (soure.textField == self.txtPickupAddress) {
        [self ButtonDropDownPressed:self.btnSearchPickup];
    }else
    {
        [self ButtonDropDownPressed:self.btnSearchDrop];
    }
}



- (IBAction)ButtonDropDownPressed:(UIButton *)sender {
    [self invalidateResetPickDrop];
    if (sender.tag ==1) {
        [self.btCouponApply setTitle:[LanguageHelper getStringWithKey:@"k_r45_s3_apply_coupon"] forState:UIControlStateNormal];
        self.btCouponApply.titleLabel.font=FONTS_THEME_REGULAR_NO_SCALE(15);
        int width = [Utilities widthOfString:[LanguageHelper getStringWithKey:@"k_r45_s3_apply_coupon"] withFont:FONTS_THEME_REGULAR_NO_SCALE(15)];
        [self.btCouponApply setConstraintConstant:width+10 forAttribute:NSLayoutAttributeWidth];
        [self.viewConfirmViewShow setHidden:YES];
        promoCode=nil;
        if ([btnPickupState isEqualToString: @"add"]) {
            _tableViewDestination.hidden=YES;
            _tableViewPickup.hidden = !_tableViewPickup.isHidden;
        }
        else if ([btnPickupState isEqualToString: @"cross"]){
            [locationDataSourcePickup clearDataOfSuggestion];
            _txtPickupAddress.text =@"";
            _txtDestinationAddres.text =@"";
            direction.source = [[CLLocation alloc]initWithLatitude:emptyLoc.latitude longitude:emptyLoc.longitude];
            direction.destination =[[CLLocation alloc]initWithLatitude:emptyLoc.latitude longitude:emptyLoc.longitude];;
            direction.dropAddress =@"";
            direction.dropCountry=@"";
            direction.pickAddress =@"";
            direction.pickCountry=@"";
            [_txtPickupAddress endEditing:YES];
            [_txtDestinationAddres endEditing:YES];
            _tableViewPickup.hidden=YES;
            isMapRouteMake =NO;
            [self clearRoute:_txtPickupAddress];
            [self clearRoute:_txtDestinationAddres];
            [_btnSearchPickup setImage:[UIImage imageNamed:@"add"] forState:UIControlStateNormal];
            [_btnSearchDrop setImage:[UIImage imageNamed:@"add"] forState:UIControlStateNormal];
            [self setTitleForPickDrop:PICK_LOCATION];
            btnPickupState =@"search";
            self.viewPickup.layer.borderWidth=0;
            self.showButtonOnView.hidden = YES;
            [self categoryFareInformationIsHidden:YES];
            nearByDriverHandler.pickUpLocation=nil;
            [self onPromoEnterCancelButTap:nil];
        }
        
    }
    else{
        [self.btCouponApply setTitle:[LanguageHelper getStringWithKey:@"k_r45_s3_apply_coupon"] forState:UIControlStateNormal];
        [self.viewConfirmViewShow setHidden:YES];
        promoCode=nil;
        if ([btnDropState isEqualToString: @"add"]) {
            _tableViewPickup.hidden=YES;
            _tableViewDestination.hidden = !_tableViewDestination.isHidden;
        }
        else if ([btnDropState isEqualToString: @"cross"]){
            [locationDataSourceDrop clearDataOfSuggestion];
            _txtDestinationAddres.text =@"";
            [_txtDestinationAddres endEditing:YES];
            _tableViewDestination.hidden=YES;
            isMapRouteMake =NO;
            [_btnSearchDrop setImage:[UIImage imageNamed:@"add"] forState:UIControlStateNormal];
            
            if (isPickupSelected && direction.source.coordinate.latitude != emptyLoc.latitude) {
                [self setTitleForPickDrop:DROP_LOCATION];
            }
            else{
                [self setTitleForPickDrop:PICK_LOCATION];
            }
            
            btnDropState =@"search";
            [self clearRoute:self.txtDestinationAddres];
            self.viewDestination.layer.borderWidth=0;
            self.showButtonOnView.hidden = YES;
            [self categoryFareInformationIsHidden:YES];
            [self onPromoEnterCancelButTap:nil];
        }
    }
}


- (IBAction)ButtonSelectPickDrop:(id)sender {
    
    if (!isPickupSelected ) {
        
        isPickupSelected =YES;
        self.btPickupDetail.hidden=NO;
        
        if (direction.source.coordinate.latitude != emptyLoc.latitude) {
            [_btnSearchPickup setImage:[UIImage imageNamed:@"remove"] forState:UIControlStateNormal];
            [self setTitleForPickDrop:DROP_LOCATION];
            btnPickupState=@"cross";
            [self addMapAnnotationsWith:direction type:@"source"];
            
        }
        else{

            // [self setupPickupDropAddress:@"source"]; // drag-to-select location disabled
            [self shwoArrivingTime];
        }
    }
    else if (!isDropSelected) {
        isDropSelected =YES;

        // [self setupPickupDropAddress:@"destination"]; // drag-to-select location disabled

    }
    
}


-(void)setupPickupDropAddressWhenLoadApp:(CLLocation *)location{
    isShwoPickUpLocationOnLoad=YES;
    if (!self.imCenterPickupLocation.isHidden) {
        [UtilityClass setLH:NO wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
        _tableViewPickup.hidden =YES;
        _tableViewDestination.hidden =YES;
        [self setTitleForPickDrop:PICK_LOCATION];
        [_btnSearchPickup setImage:[UIImage imageNamed:@"remove"] forState:UIControlStateNormal];
        btnPickupState =@"cross";
        self.txtPickupAddress.text = @"";
        
        [Utilities getAddressStrinByLat:location.coordinate.latitude longitude:location.coordinate.longitude withcompletionHandler:^(NSString *locAddress, NSString *country) {
            if (locAddress == nil||locAddress.length==0) {
                self.btPickupDetail.hidden=YES;
                self->isPickupSelected =NO;
            }else
            {
                self.btPickupDetail.hidden=NO;
                self->isPickupSelected =YES;
            }
            if (locAddress.length>0) {
                self.txtPickupAddress.text = locAddress;
                self->direction.source =  [[CLLocation alloc]initWithLatitude:location.coordinate.latitude longitude:location.coordinate.longitude] ;
                self->nearByDriverHandler.categoryId=[NSString stringWithFormat:@"%d",self->Selectedcategory.categoryId] ;
                self->nearByDriverHandler.city_id=[NSString stringWithFormat:@"%d",self->cityModel.city_id];
                [self->nearByDriverHandler changePickUpLocation:self->direction.source];
                self-> direction.pickAddress = locAddress;
                self->direction.pickCountry = country;
                
                [self->_btnSearchPickup setImage:[UIImage imageNamed:@"remove"] forState:UIControlStateNormal];
                [self setTitleForPickDrop:DROP_LOCATION];
                self->btnPickupState=@"cross";
                [self addMapAnnotationsWith:self->direction type:@"source"];
                [self drawRoute];
            }
            [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
        }];
    }
}


/* DRAG-TO-SELECT LOCATION DISABLED
-(void)setupPickupDropAddress:(NSString *)type{
    if (!self.imCenterPickupLocation.isHidden) {
        [UtilityClass setLH:NO wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
        _tableViewPickup.hidden =YES;
        _tableViewDestination.hidden =YES;

        if ([type isEqualToString:@"source"]) {


            [self setTitleForPickDrop:PICK_LOCATION];
            [_btnSearchPickup setImage:[UIImage imageNamed:@"remove"] forState:UIControlStateNormal];
            btnPickupState =@"cross";
            self.txtPickupAddress.text = @"";

            [Utilities getAddressStrinByLat:centerCoordinate.latitude longitude:centerCoordinate.longitude withcompletionHandler:^(NSString *locAddress, NSString *country) {
                if (locAddress == nil||locAddress.length==0) {
                    self.btPickupDetail.hidden=YES;
                    self->isPickupSelected =NO;
                }else  {
                    self.btPickupDetail.hidden=NO;
                    self->isPickupSelected =YES;
                }
                if (locAddress.length>0) {
                    self.txtPickupAddress.text = locAddress;
                    self->direction.source =  [[CLLocation alloc]initWithLatitude:self->centerCoordinate.latitude longitude:self->centerCoordinate.longitude] ;
                    self->nearByDriverHandler.categoryId=[NSString stringWithFormat:@"%d",self->Selectedcategory.categoryId] ;
                    self->nearByDriverHandler.city_id=[NSString stringWithFormat:@"%d",self->cityModel.city_id];
                    [self->nearByDriverHandler changePickUpLocation:self->direction.source];
                    self-> direction.pickAddress = locAddress;
                    self->direction.pickCountry = country;
                    [self->_btnSearchPickup setImage:[UIImage imageNamed:@"remove"] forState:UIControlStateNormal];
                    [self setTitleForPickDrop:DROP_LOCATION];
                    self->btnPickupState=@"cross";
                    [self addMapAnnotationsWith:self->direction type:@"source"];
                    [self drawRoute];
                }
                [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
            }];
        }
        else{
            CLLocation *location=[[CLLocation alloc] initWithLatitude:centerCoordinate.latitude longitude:centerCoordinate.longitude];
            if([self->direction.source distanceFromLocation:location]<100){
                isDropSelected=NO;
                [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
                [self showAlertWithOk:@"" message:[LanguageHelper getStringWithKey:@"k_76_s4_cnt_slct_sm_lctn"] handler:^(UIAlertAction * _Nonnull action) {
                    [self ButtonDropDownPressed:self.btnSearchDrop];
                }];
                return;
            }
            self.txtDestinationAddres.text = @"";
            [_btnSearchDrop setImage:[UIImage imageNamed:@"remove"] forState:UIControlStateNormal];

            [self setTitleForPickDrop:DROP_LOCATION];
            btnDropState =@"cross";

            [Utilities getAddressStrinByLat:centerCoordinate.latitude longitude:centerCoordinate.longitude withcompletionHandler:^(NSString *locAddress, NSString *country) {
                if (locAddress == nil||locAddress.length==0) {
                    self->isDropSelected =NO;
                }
                if (locAddress.length>0) {
                    self.txtDestinationAddres.text = locAddress;
                    self->direction.destination = [[CLLocation alloc]initWithLatitude:self->centerCoordinate.latitude longitude:self->centerCoordinate.longitude];
                    self->direction.dropAddress = locAddress;
                    self->direction.dropCountry = country;

                    [self->_btnSearchDrop setImage:[UIImage imageNamed:@"remove"] forState:UIControlStateNormal];

                    [self setTitleForPickDrop:PICK_LOCATION];
                    self->btnDropState=@"cross";
                    [self addMapAnnotationsWith:self->direction type:@"destination"];
                    [self drawRoute];
                    [self resetResetPickDrop];
                }
                [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
            }];
        }
    }

}
*/

-(void)drawRoute{
    
    if (direction.destination.coordinate.latitude !=emptyLoc.latitude && direction.source.coordinate.latitude !=emptyLoc.latitude) {
        
        
        [UtilityClass setLH:NO wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
        [self makeRouteOnMap];
        //}
    }
    
}

-(void)setTitleForPickDrop:(NSString *)str{
    NSString *pickupStr = [LanguageHelper getStringWithKey:@"k_r61_s3_pick_rup"];
    NSString *destStr =[LanguageHelper getStringWithKey:@"k_r63_s3_drop_off"];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@""]];
    if ([str isEqualToString:PICK_LOCATION]) {
        NSAttributedString * attributedStringPart1=[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n",pickupStr]
                                                                                   attributes:@{
            NSFontAttributeName:FONTS_THEME_REGULAR(13),NSForegroundColorAttributeName:[UIColor colorNamed:@"color_app_label"]}];
        
        
        NSAttributedString * attributedStringPart2=[[NSAttributedString alloc] initWithString:[LanguageHelper getStringWithKey:@"k_r62_s3_tap_hre"]
                                                                                   attributes:@{
            NSFontAttributeName:FONTS_THEME_REGULAR(11),NSForegroundColorAttributeName:[UIColor colorNamed:@"color_app_label"]}
        ];
        [attributedString appendAttributedString:attributedStringPart1];
        [attributedString appendAttributedString:attributedStringPart2];
    }
    else{
        NSAttributedString * attributedStringPart1=[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n",destStr]
                                                                                   attributes:@{
            NSFontAttributeName:FONTS_THEME_REGULAR(13),NSForegroundColorAttributeName:[UIColor colorNamed:@"color_app_label"]}];
        
        
        NSAttributedString * attributedStringPart2=[[NSAttributedString alloc] initWithString:[LanguageHelper getStringWithKey:@"k_r62_s3_tap_hre"]
                                                                                   attributes:@{
            NSFontAttributeName:FONTS_THEME_REGULAR(11),NSForegroundColorAttributeName:[UIColor colorNamed:@"color_app_label"]}
        ];
        [attributedString appendAttributedString:attributedStringPart1];
        [attributedString appendAttributedString:attributedStringPart2];
    }
    [_btnSelectPickDrop setAttributedTitle:attributedString forState:UIControlStateNormal];
}

- (void)ZoomToPickupLocation {
    
    if (direction.source.coordinate.latitude != emptyLoc.latitude) {
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(direction.source.coordinate, 800, 800);
        
        [self mapRegion:region mapView:self.mapView];
        centerCoordinate=self.mapView.centerCoordinate;
    }
}

-(void)zoomToDestination{
    
    if (direction.destination.coordinate.latitude != emptyLoc.latitude) {
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(direction.destination.coordinate, 800, 800);
        
        [self mapRegion:region mapView:self.mapView];
    }
    
}

- (void)addMapAnnotationsWith:(GoogleDirectionSource * )directionSource type:(NSString *)type {
    
    if ([type isEqualToString:@"source"]) {
        
        
        [self.mapView removeAnnotation:pickUpPin];
        [arrAnotation removeObject:pickUpPin];
        pickUpPin=[[CustomPointAnnotation alloc]  initWithType:PIN_START];
        pickUpPin.coordinate = directionSource.source.coordinate;
        [self.mapView addAnnotation:pickUpPin];
        [arrAnotation addObject:pickUpPin];
        //  }
    }
    else{
        
        [self.mapView removeAnnotation:dropPin];
        [arrAnotation removeObject:dropPin];
        dropPin=[[CustomPointAnnotation alloc]  initWithType:PIN_DROP];
        dropPin.coordinate = directionSource.destination.coordinate;
        [self.mapView addAnnotation:dropPin];
        [arrAnotation addObject:dropPin];
        //}
    }
    
}


- (IBAction)ButtonScheduleLaterPressed:(id)sender {
    if(cityModel==nil)
    {
        [Utilities showAlertwithTilte:@"" message:[LanguageHelper getStringWithKey:@"k_r51_s3_service_nt_avail"] navigatationController:self.navigationController];
        return;
    }
    
    if((self.txtPickupAddress.text.length==0 ||direction.pickAddress.length==0)||[direction isSourceEmpty])  {
        [self showAlert:@"" message:[LanguageHelper getStringWithKey:@"k_r7_s3_enter_pickup_loc"]];
        return;
    }
    if(![constantTaxiModel getCValueFK:ckey_eod]){
        if((self.txtDestinationAddres.text.length==0 ||direction.dropAddress.length==0)||[direction isDestinationEmpty]){
            [self showAlert:@"" message:[LanguageHelper getStringWithKey:@"k_r57_s3_plz_sel_drp_loc"]];
            return;
        }
    }
    DatePickerViewController *vc=[[DatePickerViewController alloc] initWithNibName:@"DatePickerViewController" bundle:nil];
    vc.modalPresentationStyle=UIModalPresentationOverCurrentContext;
    vc.modalTransitionStyle=UIModalTransitionStyleCrossDissolve;
    vc.delegate=self;
    [self presentViewController:vc animated:YES completion:^{
        
    }];
}

-(void) viewController:(DatePickerViewController *)datePicker dateSelected:(NSDate *)date{
    [datePicker dismissViewControllerAnimated:YES completion:^{
        self->selectedRideLaterDate=date;
        self->isRideLaterButtonTap=YES;
        if([self->constantTaxiModel getCValueFK: ckey_epr])  {
            [self.btCouponApply setTitle:[LanguageHelper getStringWithKey:@"k_r45_s3_apply_coupon"] forState:UIControlStateNormal];
            int width = [Utilities widthOfString:[LanguageHelper getStringWithKey:@"k_r45_s3_apply_coupon"] withFont:FONTS_THEME_REGULAR_NO_SCALE(15)];
            [self.btCouponApply setConstraintConstant:width+10 forAttribute:NSLayoutAttributeWidth];
            self.btCouponApply.titleLabel.font=FONTS_THEME_REGULAR_NO_SCALE(15);
            [self.viewConfirmViewShow setHidden:NO];
        }else{
            [self createTrip:date];
        }
    }];
}



-(void)setPickerCancel_showAlert:(BOOL)showAlert{
    if([self isCheckLocationFailedScreen]){
        [self locatonGetFailedScreen:self.locationManager isBackHidden:YES];
        return;
    }
    [PickerAlertView dismissViewControllerAnimated:YES completion:^{
        if (showAlert) {
            [self showAlertWithMessgae:[LanguageHelper getStringWithKey:@"k_r31_s8_select_future_date"]];
        }
    }];
}




-(void)SelectDate:(NSString *)dateTime date:(NSString*)dateStr time:(NSString*)timeStr originalDate:(NSDate *)originalDate{
    selectedRideLaterDate=originalDate;
    isRideLaterButtonTap=YES;
    [PickerAlertView dismissViewControllerAnimated:YES completion:^{
        [self createTrip:originalDate];
    }];
}






-(void) createTrip:(NSDate *)tripdate  {
    
    //    UIAlertController * alertViewController=[UIAlertController alertControllerWithTitle:@"" message:[LanguageHelper getStringWithKey:@"k_6_s12_ride_booking_msg"] preferredStyle:UIAlertControllerStyleAlert];
    //
    //    [alertViewController addAction:[UIAlertAction actionWithTitle:[LanguageHelper getStringWithKey:@"k_21_s4_yes"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    //        [self openPassengerDetailInputVc:tripdate isRiderLater:YES];
    //    }]];
    //    [alertViewController addAction:[UIAlertAction actionWithTitle:[LanguageHelper getStringWithKey:@"k_22_s4_no"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    //        [self createTripWith:tripdate passengerDetail:nil];
    //    }]];
    //    [self.navigationController presentViewController:alertViewController animated:YES completion:^{
    //
    //    }];
    [self openAskPassengerDetailInputVc:tripdate isRiderLater:YES];
}


#pragma  mark -Passenger Details Info VC
#pragma  mark

-(void) openPassengerDetailInputVc:(NSDate *)tripdate isRiderLater:(BOOL)isRiderLater{
    PassengerViewController *vc = (PassengerViewController *)[StoryBoardUtiles viewContollerWithIdentifier:@"PassengerViewController" name:StoryBoardUtiles.STORYBOARD_EXTRA_FEATURE];
    vc.modalPresentationStyle=UIModalPresentationOverCurrentContext;
    vc.modalTransitionStyle=UIModalTransitionStyleCrossDissolve;
    vc.tripDate=tripdate;
    vc.isRiderLater=isRiderLater;
    vc.delegate=self;
    [self presentViewController:vc animated:YES completion:^{
        
    }];
}


#pragma  mark -Passenger Details InfoVc Delegate Method
#pragma  mark


-(void) controller:(PassengerViewController *)controller onSavePassengerDetail:(NSString *)passengerDetail isSkip:(BOOL)isSkip{
    [controller dismissViewControllerAnimated:YES completion:^{
        if(controller.isRiderLater){
            [self createTripWith:controller.tripDate passengerDetail:passengerDetail];
        }else{
            [self createTripWith:passengerDetail];
        }
    }];
}

-(void) openFareChangeViewController:(NSDate *) tripdate passengerDetail:stringPassengerDetail isRiderLater:(BOOL) isRideLater{
    if([self.txtExtmatedFareAmt.text floatValue]<=0){
        [self showAlertWithMessgae:@"k_r1_s6_please_enter_amount"];
        return;
    }
    //    NSMutableDictionary *dict=[[NSMutableDictionary alloc] initWithDictionary:estimatedDict];
    //    if(promoCode!=nil){
    //        [dict setObject:[Utilities formatAmount:[self.txtExtmatedFareAmt.text floatValue]] forKey:TOTAL_AMT_PROMO ];
    //
    //    }else{
    //        [dict setObject:[Utilities formatAmount:[self.txtExtmatedFareAmt.text floatValue]] forKey:TOTAL_AMT ];
    //    }
    //    estimatedDict=dict;
    //    if(isRideLater){
    //        [self createTripWith:tripdate passengerDetail:stringPassengerDetail];
    //    }else{
    //        [self createTripWith:stringPassengerDetail];
    //    }
    /*FareChangeViewController *vc=[self.storyboard instantiateViewControllerWithIdentifier:@"FareChangeViewController"];
     vc.isRideLater= isRideLater;
     vc.tripDate=tripdate;
     vc.passengerDetails=stringPassengerDetail;
     vc.delegate=self;
     vc.dictFareEstimate=estimatedDict;
     if(promoCode){
     vc.isPromoCodeApplied=YES;
     }else{
     vc.isPromoCodeApplied=NO;
     }
     vc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
     vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
     [self presentViewController:vc animated:YES completion:^{
     
     }];*/
}



-(void)viewController:(FareChangeViewController *)contorller onDoneButtonTap:(id)sender dictFare:(nonnull NSDictionary *)dict{
    //    estimatedDict=dict;
    if(contorller.isRideLater){
        [self createTripWith:contorller.tripDate passengerDetail:contorller.passengerDetails];
    }else{
        [self createTripWith:contorller.passengerDetails];
    }
}

/** La configuracion y, detras, lo que el pasajero haya escrito a mano. */
-(NSString *)notaDeRecogida {
    NSString *escrita = [isEmpty(pickupNotes)
        stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (configDelViaje.length == 0) {
        return escrita;
    }
    if (escrita.length == 0) {
        return configDelViaje;
    }
    return [NSString stringWithFormat:@"%@|%@", configDelViaje, escrita];
}

- (IBAction)onAddPickupDetailsButTap:(id)sender {
    if(self.txtPickupAddress.text.length==0 ||direction.pickAddress.length==0) {
        [UtilityClass swa:@"" m:[LanguageHelper getStringWithKey:@"k_r7_s3_enter_pickup_loc"] cbt:[LanguageHelper getStringWithKey:@"k_18_s4_Ok"] obt:nil vc:self];
        return;
    }
    [[UPickupDetailViewController openMessageViewController:pickupNotes viewController:self] setDelegate:self];
}


-(void)controller:(UPickupDetailViewController *)controller  onDetailDoneTap:(NSString *)pickupDetails{
    [controller dismissViewControllerAnimated:YES completion:^{
        self->pickupNotes=pickupDetails;
    }];
}


-(void) controller:(UPickupDetailViewController *)controller onCancelTap:(UIButton *)sender{
    [controller dismissViewControllerAnimated:YES completion:^{
        
    }];
}


-(void) createTripWith:(NSDate *)tripdate passengerDetail:(NSString *)passengerDetail{
    CategoryModel *catModel=[self getSelectectCategoryByRider];
    NSDictionary *dict1 = [[NSUserDefaults standardUserDefaults]objectForKey:P_USER_DICT];
    NSMutableDictionary  *dict=[[NSMutableDictionary alloc] init];
    [dict  setObject:[dict1  objectForKey:P_API_KEY] forKey:P_API_KEY];
    [dict  setObject:[dict1  objectForKey:P_USER_ID] forKey:P_USER_ID];
    [dict  setObject:[NSString stringWithFormat:@"%d",catModel.categoryId] forKey:P_CATEGORY_ID];
    [dict  setObject:[NSString stringWithFormat:@"%@",catModel.cat_name] forKey:@"cat_name"];
    
    [dict  setObject:[NSString stringWithFormat:@"%f",direction.destination.coordinate.latitude] forKey:@"trip_scheduled_drop_lat"];
    [dict  setObject:[NSString stringWithFormat:@"%f",direction.destination.coordinate.longitude]   forKey:@"trip_scheduled_drop_lng"];
    [dict  setObject:[NSString stringWithFormat:@"%f",direction.source.coordinate.latitude]  forKey:@"trip_scheduled_pick_lat"];
    [dict  setObject:[NSString stringWithFormat:@"%f",direction.source.coordinate.longitude]  forKey:@"trip_scheduled_pick_lng"];
    [dict  setObject:isEmpty(self.txtDestinationAddres.text) forKey:@"trip_search_result_addr"];
    [dict  setObject:direction.dropAddress forKey:@"trip_to_loc"]; // drop
    [dict  setObject:direction.pickAddress  forKey:@"trip_from_loc"];
    [dict  setObject:TS_REQUEST forKey:TRIP_STATUS];
    [dict  setObject:[NSString stringWithFormat:@"%@",[Utilities getStringFromDate:tripdate]] forKey:@"trip_date"];
    [dict  setObject:@"1" forKey:@"store_id"];
    [dict  setObject:@"1" forKey:@"is_ride_later"];
    //    [dict  setObject:self.txtPickupDetails.text forKey:@"pickup_notes"];
    
    if(cityModel)
    {
        [dict setObject:[NSString stringWithFormat:@"%d",cityModel.city_id] forKey:P_CITY_ID];
    }
    [dict  setObject:isEmpty(cityModel.city_cur) forKey:@"trip_currency"];
    EstimatedFare *estimatedFare=[_bookingModel getEstimateFareForCategory:catModel.categoryId];
    [dict  setObject:[Utilities formatAmount:estimatedFare.trip_base_fare] forKey:@"trip_base_fare"];
    //    [dict  setObject:[Utilities formatAmount:estimatedFare.trip_pay_amount] forKey:@"trip_pay_amount"];
    [dict  setObject:[Utilities formatAmount:estimatedFare.trip_pay_amount_without_share_discount_without_promo] forKey:@"base_est_amt"];
    [dict  setObject:self.txtExtmatedFareAmt.text forKey:@"trip_pay_amount"];
    [dict  setObject:[Utilities formatAmount:estimatedFare.tax_amt] forKey:@"tax_amt"];
    if([estimatedFare.promo_id intValue]>0){
        [dict setObject:isEmpty(estimatedFare.promo_id) forKey:@"promo_id"];
        [dict setObject:isEmpty(estimatedFare.promo_code) forKey:@"trip_promo_code"];
        [dict  setObject:[Utilities formatAmount:estimatedFare.trip_promo_amt] forKey:@"trip_promo_amt"];
    }
    [dict  setObject:[NSString stringWithFormat:@"%d",tripTime] forKey:@"trip_total_time"];
    [dict setObject: isEmpty(cityModel.city_dist_unit) forKey:@"trip_dunit"];
    
    
    if(passengerDetail!=nil) {
        [dict  setObject:passengerDetail forKey:@"trip_customer_details"];
    }
    if(isShareRideButtonTap){
        [dict setObject:@"1" forKey:@"is_share"];
    }
    NSString * estimatedJson =[self jsonEstimateDataForTripId:dict];
    if(estimatedJson) {
        [dict setObject:estimatedJson forKey:@"est_data"];
    }
    [dict  setObject:@"1" forKey:@"seats"];
    //    if([self getSelectectCategoryByRider].show_paymode){
    if(paymentViewModel.tripPayMode.length>0){
        [dict setObject:paymentViewModel.tripPayMode forKey:@"trip_pay_mode"];
        if(paymentViewModel.paymentMethod.length>0){
            [dict setObject:paymentViewModel.paymentMethod forKey:@"payment_card_id"];
        }
    }
    //    }else{
    ////        [dict setObject:CASH_PAY forKey:@"trip_pay_mode"];
    //    }
    
    [UtilityClass setLH:NO wt:[LanguageHelper getStringWithKey:@"k_r16_s3_plz_wait"]];
    [GIC mkwerwu:API_CREATE_TRIP
               d:dict
              cb:^(id results, NSError *error) {
        if(error!=nil)
        {
            [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_r16_s3_plz_wait"]];
            [Utilities handleError:error viewController:self defaultMessage:@"Interner Error"];
            return ;
        }
        if ([[[results objectForKey:P_STATUS] uppercaseString] isEqualToString:@"OK"]) {
            // success
            //               tripdate
            NSDateFormatter *df=[[NSDateFormatter alloc] init];
            [df setDateFormat:APP_DATE_FORMAT];
            df.timeZone =NSTimeZone.localTimeZone;
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@""
                                                                                     message:[NSString stringWithFormat:@"%@ %@",[LanguageHelper getStringWithKey:@"k_r41_s3_ride_scheduled"],[df stringFromDate:tripdate]]
                                                                              preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *actionOk = [UIAlertAction actionWithTitle:[LanguageHelper getStringWithKey:@"k_18_s4_Ok"]
                                                               style:UIAlertActionStyleDefault
                                                             handler:nil];
            [alertController addAction:actionOk];
            [self presentViewController:alertController animated:YES completion:nil];
            self.showButtonOnView.hidden = YES;
            [self categoryFareInformationIsHidden:YES];
            NSString *tripId = [[results objectForKey:P_RESPONSE]objectForKey:TRIP_ID];
            DataUploadHelper * uploadHelper=[[DataUploadHelper alloc] init];
            [uploadHelper saveCoverRouteOnServerForTripId:tripId routeArray:directionModel.arrDirectionLatLng completionBlock:^(id  _Nonnull results, NSError * _Nonnull error) {
                
            }];
            [self reset:nil];
        }
        [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_r16_s3_plz_wait"]];
    }];
}


#pragma For Setting Service region   //for setting service region indifferent cities



-(void)showAlertForOutsideServiceRange:(NSString *)type{
    NSString *message;
    if ([type isEqualToString:PICK_LOCATION]) {
        message =[LanguageHelper getStringWithKey:@"k_r30_s10_your_picup_location_is_outside"];
    }
    else{
        message = [LanguageHelper getStringWithKey:@"k_r31_s10_your_drop_location_is_outside"];
    }
    [self showAlertWithMessgae:message];
}



-(BOOL)checkPointInsidePolygonForPickup:(CLLocationCoordinate2D)loc {
    
    BOOL isInsideFirst =  [self pointInsideOverlay:loc polygon:polygonFirst];
    
    BOOL isInsideSecond =  [self pointInsideOverlay:loc polygon:polygonSecond];
    
    BOOL isInsideThird =  [self pointInsideOverlay:loc polygon:polygonThird];
    
    if (!isInsideFirst && !isInsideSecond && !isInsideThird ) {
        polygonPickup =nil;
        return NO;
    }
    else{
        
        if (isInsideFirst) {
            
            polygonPickup = polygonFirst;
        }
        else if (isInsideSecond){
            
            polygonPickup = polygonSecond;
        }
        else{
            
            polygonPickup = polygonThird;
        }
        
        return YES;
    }
    
    
}

-(BOOL)checkPointInsidePolygonForDrop:(CLLocationCoordinate2D)loc{
    
    BOOL isInside =  [self pointInsideOverlay:loc polygon:polygonPickup];
    
    
    if (!isInside) {
        
        return NO;
    }
    return YES;
    
}

-(BOOL)pointInsideOverlay:(CLLocationCoordinate2D )tapPoint polygon:(MKPolygon *)polygon
{
    BOOL  isInside = NO;
    
    MKPolygonRenderer  *polygonRenderer = [[MKPolygonRenderer alloc]initWithPolygon:polygon];
    MKMapPoint point = MKMapPointForCoordinate(tapPoint);
    
    CGPoint polygonViewPoint = [polygonRenderer pointForMapPoint:point];
    
    if (CGPathContainsPoint(polygonRenderer.path, nil, polygonViewPoint, YES)) {
        isInside =YES;
    }
    
    
    return isInside;
}


-(void)removePolyline{
    
    NSArray *arrOverlay = self.mapView.overlays;
    
    for (MKOverlayView *overlay in arrOverlay) {
        
        if ([overlay isKindOfClass:[MKPolyline class]]) {
            
            [self.mapView removeOverlay:(MKPolyline *)overlay];
            return;
        }
    }
    
}


- (IBAction)ButtonCancelRequestPressed:(id)sender {
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{
        TRIP_STATUS :TS_USER_CANCEL,
        TRIP_ID     :[NSString stringWithFormat:@"%@",currTrip.trip_Id],
    }];
    [UtilityClass setLH:NO wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
    [GIC mkwu:TRIP_UPDATE
            d:dict
           cb:^(id results, NSError *error) {
        [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
        if ([[[results objectForKey:P_STATUS]  uppercaseString]isEqualToString:@"OK"]) {
            [self handleAfterTripRequestExpired:NO];
            [self sendNotificationAfterCancelTrip:nil];
            //               currTrip=nil;
            //               // success
            //               //currTrip = [[TripModel alloc] initItemWithDict:[results objectForKey:P_RESPONSE]];
            //               defaults_remove(TRIP_ID);
            //               defaults_remove(@"trip_status");
            //               self->promoCode=nil;
            //               //[self sendNotification];
            [self reset:nil];
            //               self.ViewRequestBg.hidden=YES;
            self.showButtonOnView.hidden = YES;
            [self categoryFareInformationIsHidden:YES];
        }
    }];
}

-(void)sendNotificationAfterCancelTrip:(TripModel *)trip{
    NSMutableDictionary  *dict=[[NSMutableDictionary alloc] init];
    NSMutableDictionary  *dictForNotification=[APP_DELEGATE dictForSendHideAlert];
    if(dictForNotification==nil){
        return;
    }
    [dict setObject:@" " forKey:@"message"];
    [dict setObject:[NSString stringWithFormat:@"%@",[dictForNotification objectForKey:@"trip_id"]] forKey:@"trip_id"];
    [dict setObject:@"hide_alert" forKey:@"trip_status"];
    NSString *ios=[dictForNotification  objectForKey:@"ios"];
    if(ios){
        NSMutableArray *arrayIosDevices=[[ios componentsSeparatedByString:@","] mutableCopy];
        if(trip){
            [arrayIosDevices removeObject:trip.driver.deviceToken ];
        }
        [dict setObject:[arrayIosDevices componentsJoinedByString:@","] forKey:@"ios"];
    }
    NSString *android=[dictForNotification  objectForKey:@"android"];
    if(android){
        NSMutableArray *arrayAndroidDevices=[[android componentsSeparatedByString:@","] mutableCopy];
        if(trip){
            [arrayAndroidDevices removeObject:trip.driver.deviceToken];
        }
        [dict setObject:[arrayAndroidDevices componentsJoinedByString:@","] forKey:@"android"];
    }
    [dict setObject:@"driver" forKey:@"to"];
    [dict setObject:@"1" forKey:@"content-available"];
    [GIC mk:url_notification to:send_driver_notification
          d:dict
        isa:NO
         cb:^(id results, NSError *error) {
    } ];
}

-(void) createTrip{
    //    self.txtPassengeName.text=@"";
    //    self.txtPassengePhone.text=@"";
    //    __weak typeof(self) weakSelf = self;
    //    self.completeProductDetail = ^(NSString *stringPassengerDetail ,BOOL isSkip){
    //        //        [weakSelf createTripWith:stringPassengerDetail];
    //        [weakSelf openFareChangeViewController:nil passengerDetail:stringPassengerDetail isRiderLater:NO];
    //    };
    //    UIAlertController * alertViewController=[UIAlertController alertControllerWithTitle:@"" message:[LanguageHelper getStringWithKey:@"k_6_s12_ride_booking_msg"] preferredStyle:UIAlertControllerStyleAlert];
    //
    //    [alertViewController addAction:[UIAlertAction actionWithTitle:[LanguageHelper getStringWithKey:@"k_21_s4_yes"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    //        [self openPassengerDetailInputVc:nil isRiderLater:NO];
    //
    //    }]];
    //    [alertViewController addAction:[UIAlertAction actionWithTitle:[LanguageHelper getStringWithKey:@"k_22_s4_no"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    //                [self createTripWith:nil];
    ////        [self openFareChangeViewController:nil passengerDetail:nil isRiderLater:NO];
    //
    //    }]];
    //    [self.navigationController presentViewController:alertViewController animated:YES completion:^{
    //
    //    }];
    
    [self openAskPassengerDetailInputVc:nil isRiderLater:NO];
}


#pragma  mark -Passenger Details Info VC
#pragma  mark

-(void) openAskPassengerDetailInputVc :(NSDate *)tripdate isRiderLater:(BOOL)isRiderLater{
    AskForPassengerVC *vc = (AskForPassengerVC *)[StoryBoardUtiles viewContollerWithIdentifier:@"AskForPassengerVC" name:StoryBoardUtiles.STORYBOARD_EXTRA_FEATURE];
    vc.modalPresentationStyle=UIModalPresentationOverCurrentContext;
    vc.modalTransitionStyle=UIModalTransitionStyleCrossDissolve;
    vc.tripDate=tripdate;
    vc.isRiderLater=isRiderLater;
    vc.delegate=self;
    [self presentViewController:vc animated:YES completion:^{
        
    }];
}


#pragma  mark -Passenger Details InfoVc Delegate Method
#pragma  mark


-(void) controller:(PassengerViewController *)controller isYes:(BOOL)isYes{
    [controller dismissViewControllerAnimated:YES completion:^{
        if(isYes){
            [self openPassengerDetailInputVc:controller.tripDate isRiderLater:controller.isRiderLater];
        }else{
            if(controller.isRiderLater){
                [self createTripWith:controller.tripDate passengerDetail:nil];
            }else{
                [self createTripWith:nil];
            }
        }
    }];
}



-(void) createTripWith:(NSString *) passengerDetail{
    
    [UtilityClass setLH:NO wt:[LanguageHelper getStringWithKey:@"k_r16_s3_plz_wait"]];
    CategoryModel *catModel=[self getSelectectCategoryByRider];
    NSDictionary *dict1 = [[NSUserDefaults standardUserDefaults]objectForKey:P_USER_DICT];
    NSMutableDictionary  *dict=[[NSMutableDictionary alloc] init];
    [dict  setObject:[dict1  objectForKey:P_API_KEY] forKey:P_API_KEY];
    [dict  setObject:[dict1  objectForKey:P_USER_ID] forKey:P_USER_ID];
    [dict  setObject:[NSString stringWithFormat:@"%d",catModel.categoryId] forKey:P_CATEGORY_ID];
    [dict  setObject:[NSString stringWithFormat:@"%@",catModel.cat_name] forKey:@"cat_name"];
    [dict  setObject:isEmpty(cityModel.city_cur) forKey:@"trip_currency"];
    EstimatedFare *estimatedFare=[_bookingModel getEstimateFareForCategory:catModel.categoryId];
    //    if(promoCode){
    //        [dict  setObject:[Utilities formatAmount:[[estimatedDict objectForKey:TOTAL_BASE_PROMO] floatValue]] forKey:@"trip_base_fare"];
    //        [dict  setObject:[Utilities formatAmount:[[estimatedDict objectForKey:TOTAL_AMT_PROMO] floatValue]] forKey:@"trip_pay_amount"];
    //        [dict  setObject:[Utilities formatAmount:[[estimatedDict objectForKey:TAX_AMT_PROMO] floatValue]] forKey:@"tax_amt"];
    //    }else{
    //        [dict  setObject:[Utilities formatAmount:[[estimatedDict objectForKey:TOTAL_BASE] floatValue]] forKey:@"trip_base_fare"];
    //        [dict  setObject:[Utilities formatAmount:[[estimatedDict objectForKey:TOTAL_AMT] floatValue]] forKey:@"trip_pay_amount"];
    //        [dict  setObject:[Utilities formatAmount:[[estimatedDict objectForKey:TAX_AMT] floatValue]] forKey:@"tax_amt"];
    //    }
    //    [dict  setObject:[NSString stringWithFormat:@"%d",[[estimatedDict objectForKey:TRIP_DURATION] intValue]] forKey:@"trip_total_time"];
    if([constantTaxiModel getCValueFK:ckey_epr]) {
        if([estimatedFare.promo_id intValue]>0){
            [dict setObject:isEmpty(estimatedFare.promo_id) forKey:@"promo_id"];
            [dict setObject:isEmpty(estimatedFare.promo_code) forKey:@"trip_promo_code"];
            [dict  setObject:[Utilities formatAmount:estimatedFare.trip_promo_amt] forKey:@"trip_promo_amt"];
        }
    }
    [dict  setObject:[Utilities formatAmount:estimatedFare.trip_base_fare] forKey:@"trip_base_fare"];
    [dict  setObject:self.txtExtmatedFareAmt.text forKey:@"trip_pay_amount"];
    [dict  setObject:[Utilities formatAmount:estimatedFare.tax_amt] forKey:@"tax_amt"];
    [dict  setObject:[Utilities formatAmount:estimatedFare.trip_pay_amount_without_share_discount_without_promo] forKey:@"base_est_amt"];
    [dict  setObject:[NSString stringWithFormat:@"%d",tripTime] forKey:@"trip_total_time"];
    [dict  setObject:[Utilities formatDistance:(self->tripDistanceConvertedInUnit)] forKey:@"trip_distance"];
    [dict  setObject:isEmpty(cityModel.city_dist_unit) forKey:@"trip_dunit"];
    [dict  setObject:[NSString stringWithFormat:@"%f",direction.destination.coordinate.latitude] forKey:@"trip_scheduled_drop_lat"];
    [dict  setObject:[NSString stringWithFormat:@"%f",direction.destination.coordinate.longitude]   forKey:@"trip_scheduled_drop_lng"];
    
    [dict  setObject:[NSString stringWithFormat:@"%f",direction.source.coordinate.latitude]  forKey:@"trip_scheduled_pick_lat"];
    [dict  setObject:[NSString stringWithFormat:@"%f",direction.source.coordinate.longitude]  forKey:@"trip_scheduled_pick_lng"];
    [dict  setObject:isEmpty(self.txtDestinationAddres.text) forKey:@"trip_search_result_addr"];
    
    [dict  setObject:direction.dropAddress forKey:@"trip_to_loc"]; // drop
    [dict  setObject:direction.pickAddress  forKey:@"trip_from_loc"];
    [dict  setObject:TS_REQUEST forKey:TRIP_STATUS];
    [dict  setObject:[self notaDeRecogida] forKey:@"pickup_notes"];
    [dict  setObject:[NSString stringWithFormat:@"%@",[Utilities getStringFromDate:[NSDate date]]] forKey:@"trip_date"];
    
    
    if(passengerDetail!=nil){
        [dict  setObject:passengerDetail forKey:@"trip_customer_details"];
    }
    [dict  setObject:@"1" forKey:@"seats"];
    
    if(cityModel){
        [dict setObject:[NSString stringWithFormat:@"%d",cityModel.city_id] forKey:P_CITY_ID];
    }
    if(isShareRideButtonTap){
        [dict setObject:@"1" forKey:@"is_share"];
    }
    NSString * estimatedJson =[self jsonEstimateDataForTripId:dict];
    if(estimatedJson) {
        [dict setObject:estimatedJson forKey:@"est_data"];
    }
    if(paymentViewModel.tripPayMode.length>0){
        [dict setObject:paymentViewModel.tripPayMode forKey:@"trip_pay_mode"];
        if(paymentViewModel.paymentMethod.length>0){
            [dict setObject:paymentViewModel.paymentMethod forKey:@"payment_card_id"];
        }
    }
    [GIC mkwerwu:API_CREATE_TRIP
               d:dict
              cb:^(id results, NSError *error) {
        if(error!=nil){
            [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_r16_s3_plz_wait"]];
            [Utilities handleError:error viewController:self defaultMessage:@"Interner Error"];
            return ;
        }
        if ([[[results objectForKey:P_STATUS] uppercaseString] isEqualToString:@"OK"]) {
            // success
            self->currTrip =[[TripModel alloc]  initItemWithDict:[results objectForKey:P_RESPONSE]];
            defaults_set_object(@"trip_status",self->currTrip.trip_Status);
            defaults_set_object(@"trip_date_create",[Utilities getStringFromDate:[NSDate date]]);
            NSString *tripId=[NSString stringWithFormat:@"%@",self->currTrip.trip_Id];
            defaults_set_object(TRIP_ID,tripId );
            DataUploadHelper * uploadHelper=[[DataUploadHelper alloc] init];
            [uploadHelper saveCoverRouteOnServerForTripId:tripId routeArray:self->directionModel.arrDirectionLatLng completionBlock:^(id  _Nonnull results, NSError * _Nonnull error) {
                
            }];
            [self sendNotificationToAllDriver];
        }
        else{
            [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_r16_s3_plz_wait"]];
            [self showAlertWithMessgae:[results objectForKey:P_MESSAGE]];
        }
    }];
}


-(NSString *) jsonEstimateDataForTripId:(NSDictionary  * ) dict
{
    EstimatedFare * estimatedFare=[_bookingModel getEstimateFareForCategory:[self getSelectectCategoryByRider].categoryId];
    NSMutableDictionary * dictEst=[[NSMutableDictionary alloc] initWithDictionary:estimatedFare.distReponse];
    NSDictionary *dictEstimate=@{
        @"city_dist_unit":isEmpty([dict objectForKey:@"trip_dunit"]),
        @"trip_currency":isEmpty([dict objectForKey:@"trip_currency"]),
        @"trip_distance":isEmpty([dict objectForKey:@"trip_distance"]),
        @"trip_total_time":isEmpty([dict objectForKey:@"trip_total_time"]),
        @"trip_base_fare":isEmpty([dict objectForKey:@"trip_base_fare"]),
    };
    [dictEst addEntriesFromDictionary:dictEstimate];
    NSError * error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictEst options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return jsonString;
}


-(void) sendNotificationToAllDriver{
    if(currTrip==nil){
        return;
    }
    if([constantTaxiModel getCValueFK:ckey_e1]==YES){
        [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_r16_s3_plz_wait"]];
        [self openTripRequest:currTrip];
        return;
    }
    NSMutableDictionary  *dict=[[NSMutableDictionary alloc] init];
    [dict setObject:[LanguageHelper getStringWithKey:@"trip_noti_msg_request"] forKey:@"message"];
    [dict setObject:[NSString stringWithFormat:@"%@",currTrip.trip_Id] forKey:@"trip_id"];
    [dict setObject:TS_REQUEST forKey:@"trip_status"];
    [dict setObject:@"driver" forKey:@"to"];
    NSMutableArray *arrayIosDevices=[[NSMutableArray alloc] init];
    NSMutableArray *arrayAndroidDevices=[[NSMutableArray alloc] init];
    NSMutableArray *arrayDriversIds=[[NSMutableArray alloc] init];
    for (DriverModel *dModel in driversArray) {
        if(dModel.deviceToken.length>0){
            if([dModel  isIos]){
                [arrayIosDevices addObject:[NSString stringWithFormat:@"%@",dModel.deviceToken]];
            }
            else{
                [arrayAndroidDevices addObject:[NSString stringWithFormat:@"%@",dModel.deviceToken]];
            }
        }
        [arrayDriversIds addObject:[NSString stringWithFormat:@"%@",dModel.driverId]];
    }
    if(arrayIosDevices.count>0) {
        [dict setObject:[arrayIosDevices componentsJoinedByString:@","] forKey:IOS_TOKEN];
    }
    if(arrayAndroidDevices.count>0)  {
        [dict setObject:[arrayAndroidDevices componentsJoinedByString:@","] forKey:ANDROID_TOKEN];
    }
    //    [arrayDriversIds addObject:@"1"];
    if(arrayDriversIds.count>0){
        [dict setObject:[arrayDriversIds componentsJoinedByString:@","] forKey:@"drivers"];
    }
    [dict setObject:@"1" forKey:@"content-available"];
    [GIC mkwu:GET_SEND_NOTIFICATION_TRIP_SAVE    d:dict    isa:NO  cb:^(id results, NSError *error) {
        [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_r16_s3_plz_wait"]];
        if ([[[results objectForKey:P_STATUS]  uppercaseString] isEqualToString:@"OK"]) {
            [APP_DELEGATE setDictForSendHideAlert:[[NSMutableDictionary alloc] initWithDictionary:dict]];
        }
        else{
            
        }
        [self  openTripRequest:self->currTrip];
    } ];
}


-(void) openTripRequest:(TripModel *) trip{
    if (![self isTripMarkAsExpire]){
        TripOffersViewContoller *vc = [[TripOffersViewContoller alloc] init];
        vc.trip = trip;
        vc.delegate = self;
        vc.modalPresentationStyle = UIModalPresentationOverFullScreen;
        homeBottomSheet.hidden = YES;
        self.btnGps.hidden = YES;
        [self ocultarPildoraDeRuta];

        // La hoja avisara de su alto de verdad en cuanto se mida; hasta entonces se
        // usa una mitad larga, que es lo que suele ocupar. Sin esto el primer
        // fotograma de la espera sale con el encuadre de la pantalla anterior.
        [self centrarEnRecogidaDejandoHuecoAbajo:self.view.bounds.size.height * 0.55f];

        [self presentViewController:vc animated:YES completion:nil];
    }
}

-(BOOL) isTripMarkAsExpire{
    NSString *startStr =  [Utilities GetGMTDatetoLocalTZ:self->currTrip.trip_created :@"yyyy-MM-dd HH:mm:ss"];
    NSDate *dateTrip =  [self convertStringToDate:startStr fromFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSTimeInterval timeInterval=[[NSDate date]  timeIntervalSinceDate:dateTrip];
    if(timeInterval>TRIP_EXPIRE_TIME)  {
        [self updateTripStatusExpire:[NSString stringWithFormat:@"%@",self->currTrip.trip_Id] completionBlock:^(id results, NSError *error) {
            if(error==nil){
                defaults_remove(TRIP_ID);
                defaults_remove(@"trip_status");
                self->promoCode=nil;
            }else{
                [self checkTripStatus];
            }
        }];
        return YES;
    }else{
        return  NO;
    }
}

-(void)handleAfterTripRequestExpiredOrCancelWithIsShowAlert:(BOOL)isShowAlert{
    homeBottomSheet.hidden = NO;
    self.btnGps.hidden = NO;
    // Solo se apagaba al salir de la pantalla, asi que tras cancelar un viaje el
    // pulso seguia latiendo sobre el home como si aun se buscara a alguien.
    [self hideRadarAnimation];
    [self handleAfterTripRequestExpired:NO];
    [self reset:nil];
    self.showButtonOnView.hidden = YES;
    [self categoryFareInformationIsHidden:YES];
    if(!isShowAlert){
        [self sendNotificationAfterCancelTrip:nil];
    }
}

-(void)onTripOfferAcceptedByRiderWithTrip:(TripModel *)trip{
    [self hideRadarAnimation];
    [self loadBeginViewContoller:trip];
}
-(void)onTripOfferAssignedByRiderWithTrip:(TripModel *)trip{
    homeBottomSheet.hidden = NO;
    self.btnGps.hidden = NO;
    [self hideRadarAnimation];
    [self showAlertWithMessgae:[LanguageHelper getStringWithKey:@"k_con_driver_assigned"]];
    
}


-(void)checkTripStatusForAcceptedNotification:(NSNotification *) notification{
    //    [self checkTripStatusForAccept];
}





-(void) handleAfterTripRequestExpired{
    [self handleAfterTripRequestExpired:YES];
}


-(void) handleAfterTripRequestExpired:(BOOL) isShowAlert{
    //    [self invalidateTripStatusTimer];
    currTrip=nil;
    defaults_remove(TRIP_ID);
    self->promoCode=nil;
    self->isAcceptNotCalled =YES;
    defaults_remove(@"trip_status");
    defaults_remove(@"estimate");
    [self.viewConfirmViewShow setHidden:YES];
    [self startSearchNearbyDriver];
}





-(NSDate *)convertStringToDate:(NSString *)strDate fromFormat:(NSString *)strFromFormat{
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = strFromFormat;
    return [dateFormatter dateFromString:strDate];
}


- (IBAction)ButtonOkPressed:(id)sender {
    
    NSString * string = defaults_object(TRIP_ID);
    if(string.length>0){
        if(![self.navigationController.topViewController isKindOfClass:[BeginTripViewController class]]) {
            if(!self->isGoToHomeScreen){
                [self loadBeginViewContoller:currTrip];
            }
        }
    }
}

/**
 Se asegura de que haya direccion de recogida, y la resuelve si falta.

 Hacia falta porque la de partida se resolvia UNA sola vez por ejecucion:
 locationManager:didUpdateLocations: llama a setupPickupDropAddressWhenLoadApp: solo
 mientras isShwoPickUpLocationOnLoad sea NO, y ese metodo lo pone a YES nada mas entrar.
 Ese mismo metodo ademas se rinde si imCenterPickupLocation esta escondida, que en este
 diseño lo esta.

 Resultado: en cuanto algo borraba direction.pickAddress -- el reset de viewWillAppear,
 por ejemplo -- la recogida no volvia NUNCA, y el pasajero se quedaba con "Ingrese la
 ubicacion de recogida" hasta reiniciar el app, con el mapa enseñandole la ruta que
 acababa de trazar.

 Aqui no se mira ninguna de esas dos banderas: si falta el dato y hay una coordenada
 con la que resolverlo, se resuelve.
 */
-(void)asegurarDireccionDeRecogida {
    if (self.txtPickupAddress.text.length > 0 && direction.pickAddress.length > 0) {
        return;
    }

    // La mejor coordenada que haya: la que el pasajero eligio, o donde esta el movil.
    CLLocationCoordinate2D punto = direction.source.coordinate;
    if (!CLLocationCoordinate2DIsValid(punto) || (punto.latitude == 0 && punto.longitude == 0)) {
        CLLocation *delMovil = [APP_DELEGATE currLoc];
        if (delMovil == nil) {
            return;
        }
        punto = delMovil.coordinate;
    }
    if (punto.latitude == 0 && punto.longitude == 0) {
        return;
    }

    if (resolviendoRecogida) {
        return;
    }
    resolviendoRecogida = YES;

    CLLocationCoordinate2D fijo = punto;
    [Utilities getAddressStrinByLat:(float)fijo.latitude
                          longitude:(float)fijo.longitude
              withcompletionHandler:^(NSString *locAddress, NSString *country) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self->resolviendoRecogida = NO;
            if (locAddress.length == 0) {
                return;
            }
            // Si mientras tanto el pasajero eligio una recogida, esa manda.
            if (self.txtPickupAddress.text.length > 0 && self->direction.pickAddress.length > 0) {
                return;
            }
            self.txtPickupAddress.text = locAddress;
            self->direction.source = [[CLLocation alloc] initWithLatitude:fijo.latitude
                                                                longitude:fijo.longitude];
            self->direction.pickAddress = locAddress;
            self->isPickupSelected = YES;
            [self->nearByDriverHandler changePickUpLocation:self->direction.source];
            [self addMapAnnotationsWith:self->direction type:@"source"];
        });
    }];
}

-(void)resetResetPickDrop{
    [self invalidateResetPickDrop];
    if(!isGoToHomeScreen){
        self->timerForResetPickDrop = [NSTimer scheduledTimerWithTimeInterval: 5*60 target: self
                                                                     selector: @selector(clearPickandDrop) userInfo: nil repeats: NO];
    }
}

-(void)invalidateResetPickDrop{
    if (timerForResetPickDrop) {
        [timerForResetPickDrop invalidate];
        timerForResetPickDrop =nil;
    }
}


-(void)clearPickandDrop{
    [self ButtonDropDownPressed:self.btnSearchPickup];
}


//-(void)resetTripStatusTimer{
//    [self invalidateTripStatusTimer];
//    if(currTrip!=nil){
//        if(!isGoToHomeScreen){
//            self->tripStatusTimer = [NSTimer scheduledTimerWithTimeInterval: 15.0 target: self
//                                                                   selector: @selector(checkTripStatusForAccept) userInfo: nil repeats: NO];
//        }
//    }
//}
//
//
//-(void)invalidateTripStatusTimer{
//    if (tripStatusTimer) {
//        [tripStatusTimer invalidate];
//        tripStatusTimer =nil;
//    }
//}









-(void)checkFor5sScreen{
    if (self.view.frame.size.width == 320 ){
        [_lblPickupLocation setFont:[UIFont fontWithName:@"Karla-Regular" size:14]];
        [_lblDropLocation setFont:[UIFont fontWithName:@"Karla-Regular" size:14]];
        [_txtPickupAddress setFont:[UIFont fontWithName:@"Karla-Regular" size:14]];
        [_txtDestinationAddres setFont:[UIFont fontWithName:@"Karla-Regular" size:13]];
    }else{
        return;
    }
}



- (IBAction)onSelectCityButTap:(UIButton *)sender {
    CGPoint origin = [self.view convertPoint:CGPointZero fromView:sender];
    BOOL isDown;
    CGRect frame;
    frame=CGRectMake(30, origin.y+30, SCREEN_WIDTH-60,240);
    isDown=YES;
    NSMutableArray * arr = [[NSMutableArray alloc] initWithArray:[APP_DELEGATE arrayCities]];
    NSArray * arrImage = [[NSArray alloc] init];
    if(dropDown == nil) {
        CGFloat f =200;
        dropDown = [[NIDropDown alloc]showDropDown:sender :&f :arr :arrImage :@"full" view:self.view frame: frame up:isDown isLeftAligin:YES];
        dropDown.delegate = self;
        dropDown.tag=10;
    }
    else {
        [dropDown hideDropDown:sender];
        dropDown=nil;
    }
}

- (void) niDropDownDelegateMethod: (NIDropDown *) sender index:(int) index  result:(id) resullt
{
    cityModel=(CityModel *)resullt;
    [self.btCity setTitle:@"" forState:UIControlStateNormal];
    [self.txtCity setText:[NSString stringWithFormat:@"%@",cityModel.city_name]];
    dropDown=nil;
    [self getCategoryFormServer];
}






- (IBAction)onShareButtonTap:(UIButton *)sender {
    //    sender.selected=!sender.selected;
    //    CategoryModel *catModel=[self getSelectectCategoryByRider];
    //
    //     if(sender.isSelected)
    //     {
    ////         sharePriceForDiscountValue=(estmatedfare *[[catModel.sharePriceDict objectForKey:@"1"] intValue])/100.0;
    //         float sharePrice= [[estimatedDict objectForKey:TOTAL_AMT] floatValue]-[[estimatedDict objectForKey:SHARE_DIS] floatValue];
    //         self.lblEstimate.text=[Utilities formatAmountAndCurrency:sharePrice currency:isEmpty(cityModel.city_cur)];
    //         self.carPriceLbl.text=[Utilities formatAmountAndCurrency:sharePrice currency:isEmpty(cityModel.city_cur)];
    //         self.lblEstimate.attributedText=[self formattedFareText:[[estimatedDict objectForKey:TOTAL_AMT] floatValue] discountedFare:sharePrice isMuiltiLine:YES];
    //         self.bikePriceLbl.attributedText=[self formattedFareText:[[estimatedDict objectForKey:TOTAL_AMT] floatValue] discountedFare:sharePrice isMuiltiLine:NO];
    //
    //
    //         isShareRideButtonTap=YES;
    //         self.imShareRide.image=[UIImage imageNamed:@"icon_checked"];
    //         if(promoCode) {
    //             [self promoCodeShowOnText ];
    //         }
    //     }else{
    //         self.lblEstimate.text=[Utilities formatAmountAndCurrency:[[estimatedDict objectForKey:TOTAL_AMT] floatValue] currency:isEmpty(cityModel.city_cur)];
    //         self.carPriceLbl.text=[Utilities formatAmountAndCurrency:[[estimatedDict objectForKey:TOTAL_AMT] floatValue] currency:isEmpty(cityModel.city_cur)];
    //         self.bikePriceLbl.text=[Utilities formatAmountAndCurrency:[[estimatedDict objectForKey:TOTAL_AMT] floatValue] currency:isEmpty(cityModel.city_cur)];
    //         isShareRideButtonTap=NO;
    //         self.imShareRide.image=[UIImage imageNamed:@"icon_unchecked"];
    //         if(promoCode){
    ////             sharePriceForDiscountValue=0;
    //             [self promoCodeShowOnText ];
    //         }
    //     }
    
    
    //    sharePriceDictsharePriceDict
}


- (IBAction)onFarePolicyButtonTap:(id)sender {
    AboutUsViewController *viewController=[self.storyboard instantiateViewControllerWithIdentifier:@"AboutUsViewController"];
    viewController.isAboutUs=NO;
    viewController.isFarePolicy=YES;
    isShowFarePolicyButtonTap=YES;
    [self.navigationController pushViewController:viewController animated:YES];
}

-(NSAttributedString *) formattedFareTextNew:(float) actucalFare discountedFare:(float) discountedFare isMuiltiLine:(BOOL) isMulitiLine{
    
    NSString * stringPriceWithPromocode=[Utilities formatAmountAndCurrency:discountedFare currency:isEmpty(cityModel.city_cur)];
    NSString * stringPriceWithOutPromocode=@"";
    if(isMulitiLine)  {
        stringPriceWithOutPromocode=[NSString stringWithFormat:@"%@\n",[Utilities formatAmountAndCurrency:actucalFare currency:isEmpty(cityModel.city_cur)]];
    }else {
        stringPriceWithOutPromocode=[NSString stringWithFormat:@"(%@)",[Utilities formatAmountAndCurrency:actucalFare currency:isEmpty(cityModel.city_cur)]];
    }
    NSString * string =[NSString stringWithFormat:@"%@ ",[LanguageHelper getStringWithKey:@"k_s3_fare_esti"]];
    NSMutableAttributedString * finalAttributedString=[[NSMutableAttributedString alloc] initWithString:string];
    
    NSAttributedString *theAttributedString1;
    theAttributedString1 = [[NSAttributedString alloc] initWithString:stringPriceWithPromocode
                                                           attributes:@{NSFontAttributeName:
                                                                            FONTS_THEME_REGULAR(isMulitiLine?13:16),NSForegroundColorAttributeName:self.lblExtimatedFare.textColor}];
    NSAttributedString *theAttributedString;
    theAttributedString = [[NSAttributedString alloc] initWithString:stringPriceWithOutPromocode
                                                          attributes:@{NSStrikethroughStyleAttributeName:
                                                                           [NSNumber numberWithInteger:NSUnderlineStyleSingle],NSFontAttributeName: FONTS_THEME_REGULAR(isMulitiLine?8:16),NSForegroundColorAttributeName:self.lblExtimatedFare.textColor}];
    [finalAttributedString appendAttributedString:theAttributedString];
    [finalAttributedString appendAttributedString:theAttributedString1];
    return  finalAttributedString;
}

-(NSAttributedString *) formattedFareText:(float) actucalFare discountedFare:(float) discountedFare isMuiltiLine:(BOOL) isMulitiLine{
    NSString * stringPriceWithPromocode=[Utilities formatAmountAndCurrency:discountedFare currency:isEmpty(cityModel.city_cur)];
    NSString * stringPriceWithOutPromocode=@"";
    if(isMulitiLine)
    {
        stringPriceWithOutPromocode=[NSString stringWithFormat:@"%@\n",[Utilities formatAmountAndCurrency:actucalFare currency:isEmpty(cityModel.city_cur)]];
    }else
    {
        stringPriceWithOutPromocode=[Utilities formatAmountAndCurrency:actucalFare currency:isEmpty(cityModel.city_cur)];
    }
    NSMutableAttributedString * finalAttributedString=[[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ ",[LanguageHelper getStringWithKey:@"k_s3_fare_esti"]]];
    
    NSAttributedString *theAttributedString1;
    theAttributedString1 = [[NSAttributedString alloc] initWithString:stringPriceWithPromocode
                                                           attributes:@{NSFontAttributeName:
                                                                            FONTS_THEME_REGULAR(isMulitiLine?13:16),NSForegroundColorAttributeName:RGB(0, 210, 0)}];
    NSAttributedString *theAttributedString;
    theAttributedString = [[NSAttributedString alloc] initWithString:stringPriceWithOutPromocode
                                                          attributes:@{NSStrikethroughStyleAttributeName:
                                                                           [NSNumber numberWithInteger:NSUnderlineStyleSingle],NSFontAttributeName: FONTS_THEME_REGULAR(isMulitiLine?8:16),NSForegroundColorAttributeName:RGB(255, 0, 0)}];
    [finalAttributedString appendAttributedString:theAttributedString];
    [finalAttributedString appendAttributedString:theAttributedString1];
    return  finalAttributedString;
}



-(void)onBoolkingConfirmed{
}



-(void) startSearchNearbyDriver{
    [self stopSearchNearbyDriver];
    nearByDriverHandler=[[NearByDriverHandler alloc]  init];
    nearByDriverHandler.delegate=self;
    nearByDriverHandler.city_id=[NSString stringWithFormat:@"%d",cityModel.city_id];
    nearByDriverHandler.categoryId=[NSString stringWithFormat:@"%d",Selectedcategory.categoryId];
    [nearByDriverHandler  startGettingNearByDriver];
}



-(void) stopSearchNearbyDriver{
    if(nearByDriverHandler){
        [nearByDriverHandler stopGetNearByDriver];
        nearByDriverHandler=nil;
    }
}


-(void)onDriverLogout{
    [[UpdateUserCurrentLocation sharedInstance] stopUpdateCurrentLocation];
    [self stopLocationUpdate];
}

-(void)stopLocationUpdate{
    isGoToHomeScreen=YES;
    if(timerForStartAnimation){
        [timerForStartAnimation invalidate];
        timerForStartAnimation = nil;
    }
    [self stopSearchNearbyDriver];
    [self invalidateResetPickDrop];
    //    [self invalidateTripStatusTimer];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if(self.locationManager){
        [self.locationManager stopUpdatingLocation];
        [self.locationManager stopUpdatingHeading];
        self.locationManager=nil;
    }
    [self purgeMapMemory];
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
-(void) loadBeginViewContoller:(TripModel *)trip{
    [self stopLocationUpdate];
    NSMutableArray *array=[self.navigationController.viewControllers  mutableCopy];
    [array removeAllObjects];
    BeginTripViewController *vc = [[BeginTripViewController alloc] init];
    vc.currentTrip=trip;
    vc.isFromrequest=YES;
    vc.constantModel = constantTaxiModel;
    [array addObject:vc];
    [self.navigationController setViewControllers:array animated:YES];
    [self stopLocationUpdate];
}

-(void) loadUFareSummeryViewContoller:(TripModel *)trip{
    NSMutableArray *array=[self.navigationController.viewControllers  mutableCopy];
    [array removeAllObjects];
    UFareSummeryViewController *vc = (UFareSummeryViewController *)[StoryBoardUtiles viewContollerInUserWithIdentifier:StoryBoardUtiles.UFARE_SUMMERY_VC];
    vc.curr_trip=trip;
    vc.constantModel = constantTaxiModel;
    [array addObject:vc];
    [self.navigationController setViewControllers:array animated:YES];
    [self stopLocationUpdate];
}

-(void)onTripOfferHandleAllWithTrip:(TripModel *)trip{
    homeBottomSheet.hidden = NO;
    self.btnGps.hidden = NO;
    //    [self  showAlertWithOk:@"" message:@"Trip has been accepted" handler:^(UIAlertAction * _Nonnull action) {
    if([trip.trip_Status isEqualToString:TS_ASSIGNED])  {
    }
    else if([trip.trip_Status isEqualToString:TS_ACCEPTED]||[trip.trip_Status isEqualToString:TS_ARRIVE]||[trip.trip_Status isEqualToString:TS_BEGIN]||[trip.trip_Status isEqualToString:TS_PICKED])   {
        [self loadBeginViewContoller:trip];
    }
    else if([trip.trip_Status isEqualToString:TS_END]||[trip.trip_Status isEqualToString:TS_RIDER_CANCEL_CANCEL]) {
        if(![self.navigationController.topViewController isKindOfClass:[FareAmmountViewController class]]) {
            if(!self->isGoToHomeScreen){
                [self loadUFareSummeryViewContoller:trip];
            }
        }
        return ;
    }
    else if([trip.trip_Status isEqualToString:TS_END]||[trip.trip_Status isEqualToString:TS_DRIVER_CANCEL_AT_DROP]) {
        if(![self.navigationController.topViewController isKindOfClass:[FareAmmountViewController class]]) {
            if(!self->isGoToHomeScreen){
                self->currTrip=trip;
                [self loadUFareSummeryViewContoller:trip];
            }
        }
        return ;
    }
    else if([trip.trip_Status isEqualToString:TS_USER_CANCEL]){
        [self handleAfterTripRequestExpired:NO];
        return ;
    }
    else if ([trip.trip_Status isEqualToString:TS_REQUEST]){
        if(!self->isGoToHomeScreen){
        }
    }else if([trip.trip_Status isEqualToString:TS_EXPIRED]){
        [self handleAfterTripRequestExpired];
    }else{
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSString * proposedNewString = [[textField text] stringByReplacingCharactersInRange:range withString:string];
    if(proposedNewString.length>0) {
        NSArray *array=[proposedNewString componentsSeparatedByString:@"."];
        if(array.count>2){
            return NO;
        }
        if(array.count==2){
            NSString *string= [array objectAtIndex:1];
            if(string.length>2){
                return NO;
            }
        }
    }
    return YES;
}

/*
 This method use to hide and show fare information button  fare calcuated successfully.
 */
#pragma  mark
-(void) categoryFareInformationIsHidden:(BOOL) isHidden{
    for (UIButton * button in arrFareInfoButtons) {
        button.hidden=isHidden;
    }
    self.btCouponApply.hidden=isHidden;
}
/*
 This method use to hide and show fare information button  fare calcuated successfully.
 */
#pragma  mark

-(void) showFareOnLabelWithEstimate:(EstimatedFare*)estimateFare{
    NSMutableAttributedString * finalAttributedString=[[NSMutableAttributedString alloc] initWithString:@""];
    // mesg
    NSString * messageTextString =[NSString stringWithFormat:@"%@\n",Localise(@"k_4_s11_est_fare_msg")];
    [finalAttributedString appendAttributedString:[self attributedString:messageTextString font:FONTS_THEME_REGULAR(14) color:UIColor.whiteColor]];
    //fare
    NSString * fareString =[NSString stringWithFormat:@" %@. ",[Utilities formatAmountAndCurrency:estimateFare.trip_pay_amount_without_share_discount_without_promo currency:cityModel.city_cur]];
    [finalAttributedString appendAttributedString:[self attributedString:fareString font:FONTS_THEME_BOLD(14) color:UIColor.whiteColor]];
    // travel Time Text
    NSString * travelTimeTextString =[NSString stringWithFormat:@" %@ ~ ",Localise(@"k_4_s11_trvl_tm")];
    [finalAttributedString appendAttributedString:[self attributedString:travelTimeTextString font:FONTS_THEME_REGULAR(14) color:UIColor.whiteColor]];
    //time
    NSString * travelTimeString =[NSString stringWithFormat:@"%d %@",tripTime ,Localise(@"k_17_s4_mins")];
    [finalAttributedString appendAttributedString:[self attributedString:travelTimeString font:FONTS_THEME_BOLD(14) color:UIColor.whiteColor]];
    // if promo applied
    if(estimateFare.trip_promo_amt>0){
        NSString * promoTextString =[NSString stringWithFormat:@"\n%@",Localise(@"k_4_s11_est_prmo_msg")];
        [finalAttributedString appendAttributedString:[self attributedString:promoTextString font:FONTS_THEME_REGULAR(14) color:UIColor.whiteColor]];
    }
    self.lblExtimatedFare.attributedText = finalAttributedString;
}
/*
 This method use to create attributed string with string, font and color.
 */

-(NSAttributedString*) attributedString:(NSString*)string font:(UIFont*)font color:(UIColor*)color{
    NSAttributedString * attributedString=[[NSAttributedString alloc] initWithString:string
                                                                          attributes:@{NSFontAttributeName:
                                                                                           font,NSForegroundColorAttributeName:color}];
    return attributedString;
}


- (IBAction)openPaymentSelection:(id)sender {
    BOOL isCard=NO;
    BOOL isCash=NO;
    BOOL isWallet=NO;
    if(cityModel){
        if(cityModel.city_pay_options.length>0){
            NSArray * paymentOption=[cityModel.city_pay_options componentsSeparatedByString:@"|"];
            if(paymentOption.count>0){
                for (NSString *  payOption in paymentOption) {
                    if([payOption isEqualToString:@"cash"]) {
                        isCash=YES;
                    }
                    else if([payOption isEqualToString:@"wallet"]){
                        if([[ConstantModel getConstantsObject] getCValueFK:ckey_ewl]){
                            isWallet=YES;
                        }
                    }
                    else if([payOption isEqualToString:@"stripe"]){
                        isCard=YES;
                    }
                }
            }
        }
    }
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[LanguageHelper getStringWithKey:@"k_r38_s9_pay_with"]
                                                                             message:@""
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
    if(isCard) {
        UIAlertAction *actionCreditCard = [UIAlertAction actionWithTitle:[LanguageHelper getStringWithKey:@"k_r39_s9_card"]
                                                                   style:UIAlertActionStyleDefault
                                                                 handler:^(UIAlertAction * action) {
            self->isShowFarePolicyButtonTap=YES;
            PaymentMethodListViewController *vc = (PaymentMethodListViewController *)[StoryBoardUtiles viewContollerInUserWithIdentifier:@"PaymentMethodListViewController"];
            vc.delegate=self;
            vc.isFromPaymentJob = YES;
            [self.navigationController pushViewController:vc animated:YES];
        }];
        [actionCreditCard setValue:[UIColor colorNamed:@"app_theame"] forKey:@"titleTextColor"];
        [alertController addAction:actionCreditCard];
    }
    
    if(isCash) {
        UIAlertAction *actionPayCash = [UIAlertAction actionWithTitle:[LanguageHelper getStringWithKey:@"k_r39_s9_cash"]
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {
            [self->paymentViewModel updatePaymentModeText:0];
            
            //            [self->rentalView updatePaymentModeText:0];
            //            [self->outstationView updatePaymentModeText:0];
        }];
        [actionPayCash setValue:[UIColor colorNamed:@"app_theame"] forKey:@"titleTextColor"];
        [alertController addAction:actionPayCash];
    }
    if(isWallet) {
        UIAlertAction *actionPayByHireMeWallet= [UIAlertAction actionWithTitle:[LanguageHelper getStringWithKey:@"k_r39_s9_wallet"]
                                                                         style:UIAlertActionStyleDefault
                                                                       handler:^(UIAlertAction * action) {
            
            NSDictionary * dictUser=defaults_object(P_USER_DICT);
            float walletBalance =[ [ dictUser objectForKey:P_USER_WAlLET_AMOUNT] floatValue];
            float requiredFare  = [self.txtExtmatedFareAmt.text floatValue];
            if (requiredFare > 0 && walletBalance < requiredFare) {
                [self showAddMoneyAlert];
            } else {
                [self->paymentViewModel updatePaymentModeText:1];
            }
            //            [self->rentalView updatePaymentModeText:1];
            //            [self->outstationView updatePaymentModeText:1];
            
        }];
        [actionPayByHireMeWallet setValue:[UIColor colorNamed:@"app_theame"] forKey:@"titleTextColor"];
        [alertController addAction:actionPayByHireMeWallet];
    }
    
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:[LanguageHelper getStringWithKey:@"k_30_s6_cancel_j"]
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * action) {
    }];
    [actionCancel setValue:[UIColor colorNamed:@"app_theame"] forKey:@"titleTextColor"];
    [alertController addAction:actionCancel];
    [self presentViewController:alertController animated:YES completion:nil];
}

-(void) showAddMoneyAlert{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[LanguageHelper getStringWithKey:@"k_33_s7_alert"]
                                                                             message:[LanguageHelper getStringWithKey:@"k_r16_s7_wlt_msg_for_pay_optn"]
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:[LanguageHelper getStringWithKey: @"k_30_s6_cancel_j"]
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
    }];
    [alertController addAction:actionCancel];
    UIAlertAction *actionOk = [UIAlertAction actionWithTitle:[LanguageHelper getStringWithKey:@"k_4_s10_add_money"]
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {
        if([cityModel isOnlinePaymentEnabled]){
            UWalletViewController *vc1 = (UWalletViewController *)[StoryBoardUtiles viewContollerInUserWithIdentifier:StoryBoardUtiles.WALLET_VC];
            [self.navigationController pushViewController:vc1 animated:YES];
        }else{
            [self openMailComposer];
        }
    }];
    [alertController addAction:actionOk];
    [self presentViewController:alertController animated:YES completion:nil];
}

-(void)openMailComposer{
    if([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mailCont = [[MFMailComposeViewController alloc] init];
        mailCont.mailComposeDelegate = self;        // Required to invoke mailComposeController when send

        ConstantModel *  constantModel =[ConstantModel getConstantsObject];;
        NSString * supportEmail = isEmpty(constantModel.support_email);
        NSMutableArray  *arrayEmails=[[NSMutableArray alloc]  init];
        [arrayEmails addObject:supportEmail];

        [mailCont setToRecipients:arrayEmails];
        /*
         [mailCont setSubject:@""];
         NSMutableString *body = [NSMutableString string];
         NSString *url = [NSString stringWithFormat:@"http://maps.google.com?q=%f,%f",[APP_DELEGATE currLoc].latitude,[APP_DELEGATE currLoc].longitude];
         [body appendString:[NSString stringWithFormat:@"Please help, I am in danger and need assistance.Follow my location,<a href=\"%@\">Click Here</a> \n ",url]];

         [mailCont setMessageBody:body isHTML:YES];
         */
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
    else
    {
        [UtilityClass swa:@"Whoops!" m:[LanguageHelper getStringWithKey:@"k_65_s4_config_mail"] cbt:[LanguageHelper getStringWithKey:@"k_18_s4_Ok"] obt:nil vc:self];
    }
}


- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    if(error!= nil)
    {
        [self showAlert:@"Whoops!" message:[NSString stringWithFormat:@" ERROR %@",error]];
        return;
    }
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (void)onPaymentIntentSelected:(NSString *)paymentMethod dict:(NSDictionary *) dict viewControlllor:(PaymentMethodListViewController *)viewControlllor{
    NSDictionary *dictCard=[dict objectForKey:@"card"];
    NSString * cardNumber =[NSString stringWithFormat:@"****%@", [dictCard  objectForKey:@"last4"]];
    self->paymentViewModel.paymentMethod = paymentMethod;
    [self->paymentViewModel updatePaymentModeText:2 cardNumber:cardNumber];
    [self->currentFareOfferVC updatePaymentLabel:self->paymentViewModel.paymentModeText icon:self->paymentViewModel.paymentModeImage];
    //    [self->rentalView updatePaymentModeText:2 cardNumber:cardNumber];
    //    [self->outstationView updatePaymentModeText:2 cardNumber:cardNumber];
}

- (void)onPaymentMethodSelected:(NSString *)paymentMethodType viewControlllor:(PaymentMethodListViewController *)viewControlllor{
    [self->currentFareOfferVC updatePaymentLabel:self->paymentViewModel.paymentModeText icon:self->paymentViewModel.paymentModeImage];
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
    int dId = [[dictDriver objectForKey:P_USER_ID] intValue];
    if(dId==0){
        return;
    }
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{
        P_API_KEY:[dictDriver objectForKey:P_API_KEY],
        P_USER_ID:[dictDriver objectForKey:P_USER_ID]
    }];
    [self stopTimerForRefresNotificationCount];
    [GIC mkwerwu:GET_USER_PROFILE   d:dict     cb:^(id results, NSError *error) {
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
                        [self.btnMenu setBadgeString:@""];
                        [self.btnMenu setBadgeBackgroundColor:[UIColor clearColor]];
                        [self.btnMenu setHidden:NO];
                    }else{
                        [APP_DELEGATE setNotificationCount:count];
                        [UIApplication sharedApplication].applicationIconBadgeNumber = count;
                        [self.btnMenu setHidden:NO];
                        [self.btnMenu setBadgeString:@""];
                        [self.btnMenu setBadgeBackgroundColor:[UIColor redColor]];
                    }
                    
                }else{
                    [APP_DELEGATE setNotificationCount:0];
                    [self.btnMenu setHidden:NO];
                    [self.btnMenu setBadgeString:@""];
                }
            }else{
                [APP_DELEGATE setNotificationCount:0];
                [self.btnMenu setHidden:NO];
                [self.btnMenu setBadgeString:@""];
            }
        }else{
            [APP_DELEGATE setNotificationCount:0];
            [self.btnMenu setHidden:NO];
            [self.btnMenu setBadgeString:@""];
            [self.btnMenu setBadgeBackgroundColor:[UIColor redColor]];
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
    [self getUpcomingTrips:NO];
}

-(void)getUpcomingTrips:(BOOL) isHideLoader{
    BOOL is_login_as_user = [defaults_object(P_IS_USER_LOGIN) boolValue];
    if(is_login_as_user==NO){
        return;
    }
    NSDictionary *dict1 = [[NSUserDefaults standardUserDefaults]objectForKey:P_USER_DICT];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{
        @"user_id"          :[dict1 objectForKey:P_USER_ID],
        @"statuses" :    @"request,assigned,arrive,begin,accept",
    }];
    [GIC mkwu:TRIP_GETTRIP    d:dict    isa:NO   cb:^(id results, NSError *error) {
        if ([[[results objectForKey:P_STATUS] uppercaseString] isEqualToString:@"OK"]) {
            if ([[results objectForKey:P_RESPONSE] isKindOfClass:[NSArray class]]) {
                NSArray *arrtrip = [results objectForKey:P_RESPONSE];
                self->arrayUpCommingRides = [[NSMutableArray alloc] init];
                for (int i=0; i<arrtrip.count; i++) {
                    TripModel *Trip = [[TripModel alloc] initItemWithDict:[arrtrip objectAtIndex:i]];
                    if(Trip.is_ride_later){
                        [self->arrayUpCommingRides addObject:Trip];
                    }
                }
            }
            if (self->arrayUpCommingRides.count ==0 ) {
                self.viewUpcommingRide.hidden =YES;
                [self.viewUpcommingRide setConstraintConstant:0 forAttribute:(NSLayoutAttributeHeight)];
                self.lblUpComingRides.text=@"";
            }
            else{
                self.lblUpComingRides.text=[NSString stringWithFormat:@"%@ (%lu)",[LanguageHelper getStringWithKey:@"k_1_s1_upcmng_rids_txt"],(unsigned long)self->arrayUpCommingRides.count];
                self.viewUpcommingRide.hidden =NO;
                [self.viewUpcommingRide setConstraintConstant:40 forAttribute:(NSLayoutAttributeHeight)];
            }
        }
    }];
}
- (IBAction)onGoingTrips:(id)sender {
    UTripHistoryViewController *vc= (UTripHistoryViewController*)[StoryBoardUtiles viewContollerInUserWithIdentifier:@"UTripHistoryViewController"];
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}
-(void)openTripOfferPageForTrip:(TripModel *)trip{
    [self  openTripRequest:trip];

}

#pragma mark - Home Screen Layout

-(void)setupHomeLayout {
    CGFloat sh = self.view.bounds.size.height;
    CGFloat statusH = self.view.safeAreaInsets.top;
    sheetCollapsedY = sh - 300.0; // content bottom = 266pt + 34pt safe area padding
    sheetExpandedY  = statusH + 52.0 + 8.0;

    [self buildFullScreenMap];
    [self buildTopBar];
    [self buildGpsButton];
    [self buildBottomSheet];

    // Ensure suggestion tables always render above the bottom sheet
    [self.view bringSubviewToFront:self.tableViewPickup];
    [self.view bringSubviewToFront:self.tableViewDestination];
}

-(void)buildFullScreenMap {
    CGRect bounds = self.view.bounds;
    CGFloat sw = bounds.size.width;
    CGFloat sh = bounds.size.height;

    // Move mapView to fill self.view behind everything
    MKMapView *map = self.mapView;
    [map removeFromSuperview];
    map.translatesAutoresizingMaskIntoConstraints = YES;
    map.frame = bounds;
    [self.view insertSubview:map atIndex:0];

    for (UITableView *t in @[self.tableViewPickup, self.tableViewDestination]) {
        if (!t) continue;
        CGFloat savedH = t.frame.size.height;
        [t removeFromSuperview];
        t.translatesAutoresizingMaskIntoConstraints = YES;
        t.frame = CGRectMake(0, 0, sw, savedH > 0 ? savedH : sh * 0.4);
        t.hidden = YES;
        [self.view addSubview:t];
    }

    /* DRAG-TO-SELECT LOCATION DISABLED: center pickup pin repositioning removed
    UIImageView *centerPin = self.imCenterPickupLocation;
    if (centerPin) {
        CGFloat pw = centerPin.frame.size.width  > 0 ? centerPin.frame.size.width  : 36;
        CGFloat ph = centerPin.frame.size.height > 0 ? centerPin.frame.size.height : 48;
        [centerPin removeFromSuperview];
        centerPin.translatesAutoresizingMaskIntoConstraints = YES;
        centerPin.frame = CGRectMake(sw/2 - pw/2, sh/2 - ph/2, pw, ph);
        [self.view addSubview:centerPin];

        UIView *callout = self.viewCallout;
        if (callout) {
            CGFloat cw = callout.frame.size.width  > 0 ? callout.frame.size.width  : 120;
            CGFloat ch = callout.frame.size.height > 0 ? callout.frame.size.height : 36;
            [callout removeFromSuperview];
            callout.translatesAutoresizingMaskIntoConstraints = YES;
            callout.frame = CGRectMake(sw/2 - cw/2, sh/2 - ph/2 - ch - 4, cw, ch);
            [self.view addSubview:callout];
        }
    }
    */

    self.ContainerView.hidden = YES;
}

/**
 El menu y el titulo, flotando sobre el mapa.

 ANTES HABIA UNA BARRA BLANCA de alto statusH+52 que tapaba la parte de arriba del
 mapa. En Android el mapa llega hasta el borde y solo flotan encima el boton redondo
 y el rotulo (MainScreenActivity / activity_home_user.xml).

 NO SE USA UN CONTENEDOR TRANSPARENTE, que seria lo obvio: una vista de ese tamaño
 seguiria tragandose los toques sobre el mapa en toda esa franja aunque no se viera.
 Los dos elementos van sueltos sobre self.view, asi que solo el boton intercepta.

 homeTopBar se queda a nil a proposito: no lo usa nadie mas, y dejar el ivar evita
 tocar las declaraciones.
 */
-(void)buildTopBar {
    CGFloat sw = self.view.bounds.size.width;
    CGFloat statusH = self.view.safeAreaInsets.top;

    homeTopBar = nil;

    MIBadgeButton *menuBtn = self.btnMenu;
    [menuBtn removeFromSuperview];
    menuBtn.translatesAutoresizingMaskIntoConstraints = YES;
    menuBtn.frame = CGRectMake(16, statusH + (52.0 - 44.0) / 2.0, 44, 44);
    menuBtn.backgroundColor = [UIColor colorWithRed:0.157f green:0.157f blue:0.157f alpha:1.0f];
    menuBtn.layer.cornerRadius = 22;
    menuBtn.clipsToBounds = YES;
    UIImage *menuImg = [UIImage systemImageNamed:@"line.horizontal.3"];
    if (menuImg) {
        [menuBtn setImage:[menuImg imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        menuBtn.tintColor = [UIColor whiteColor];
        [menuBtn setTitle:@"" forState:UIControlStateNormal];
    }
    [self.view addSubview:menuBtn];

    // Titulo, centrado a la altura del boton. "Pide un Viaje" es el rotulo de Android;
    // aqui ponia "Pide un Taxi", que ademas se queda corto: hay categorias de envio.
    CGFloat titleY = statusH + (52.0 - 22.0) / 2.0;
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(74, titleY, sw - 148, 22)];
    titleLabel.text = [LanguageHelper getStringWithKey:@"k_s10_pide_un_viaje" defaultValue:@"Pide un Viaje"];
    titleLabel.font = [UIFont fontWithName:@"NotoSans-Bold" size:18] ?: [UIFont boldSystemFontOfSize:18];
    titleLabel.textColor = [UIColor colorWithRed:0.157f green:0.157f blue:0.157f alpha:1.0f];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    // Sin barra detras, el titulo cae sobre el mapa: un halo claro lo mantiene legible
    // si debajo pasa una carretera oscura o una zona verde.
    titleLabel.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.9];
    titleLabel.shadowOffset = CGSizeMake(0, 1);
    titleLabel.userInteractionEnabled = NO;
    [self.view addSubview:titleLabel];

    self.viewHeader.hidden = YES;
    self.scrollViewCategory.hidden = YES;
    self.viewCategory.hidden = YES;
    self.viewTimeDistance.hidden = YES;
    if (self.viewDriverSearch) self.viewDriverSearch.hidden = YES;
}

-(void)buildGpsButton {
    CGFloat sw = self.view.bounds.size.width;

    UIButton *gpsBtn = self.btnGps;
    [gpsBtn removeFromSuperview];
    gpsBtn.translatesAutoresizingMaskIntoConstraints = YES;
    gpsBtn.frame = CGRectMake(sw - 16 - 52, sheetCollapsedY - 16 - 52, 52, 52);
    gpsBtn.backgroundColor = [UIColor whiteColor];
    gpsBtn.layer.cornerRadius = 26;
    gpsBtn.clipsToBounds = NO;
    gpsBtn.layer.borderWidth = 0;
    gpsBtn.layer.shadowColor = [UIColor blackColor].CGColor;
    gpsBtn.layer.shadowOpacity = 0.12f;
    gpsBtn.layer.shadowRadius = 8.0f;
    gpsBtn.layer.shadowOffset = CGSizeMake(0, 3);

    // Replace existing icon with custom GPS asset (fallback: SF Symbol)
    UIImage *gpsImg = [UIImage imageNamed:@"ic_gps_button"];
    if (gpsImg) {
        [gpsBtn setImage:[gpsImg imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
    } else {
        UIImage *sysImg = [UIImage systemImageNamed:@"location.fill"];
        [gpsBtn setImage:[sysImg imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        gpsBtn.tintColor = [UIColor colorNamed:@"app_theame"];
    }
    if (self.imageGps) self.imageGps.hidden = YES;

    [self.view addSubview:gpsBtn];
}

-(void)buildBottomSheet {
    CGFloat sw = self.view.bounds.size.width;
    CGFloat sh = self.view.bounds.size.height;
    CGFloat sheetH = sh - sheetExpandedY;

    homeBottomSheet = [[UIView alloc] initWithFrame:CGRectMake(0, sheetCollapsedY, sw, sheetH)];
    homeBottomSheet.backgroundColor = [UIColor whiteColor];
    homeBottomSheet.layer.cornerRadius = 20;
    homeBottomSheet.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
    homeBottomSheet.clipsToBounds = NO;
    homeBottomSheet.layer.shadowColor = [UIColor blackColor].CGColor;
    homeBottomSheet.layer.shadowOpacity = 0.08f;
    homeBottomSheet.layer.shadowRadius = 12.0f;
    homeBottomSheet.layer.shadowOffset = CGSizeMake(0, -2);
    [self.view addSubview:homeBottomSheet];

    // Drag handle pill
    UIView *handle = [[UIView alloc] initWithFrame:CGRectMake((sw - 36) / 2.0, 8, 36, 4)];
    handle.backgroundColor = [UIColor colorWithRed:0.878f green:0.878f blue:0.878f alpha:1.0f];
    handle.layer.cornerRadius = 2;
    [homeBottomSheet addSubview:handle];

    // Vehicle selector cards
    [self buildVehicleCards];

    // Availability label — below cards
    CGFloat cardBottom = 8 + 4 + 12 + 140; // handle(y=8,h=4) + gap(12) + card(140)
    homeAvailabilityLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, cardBottom + 12, sw - 32, 22)];
    homeAvailabilityLabel.font = [UIFont fontWithName:@"NotoSans-Regular" size:14] ?: [UIFont systemFontOfSize:14];
    homeAvailabilityLabel.textAlignment = NSTextAlignmentLeft;
    [homeBottomSheet addSubview:homeAvailabilityLabel];

    // This is a styled button that looks like a search placeholder.
    // Tapping it pushes URouteInputViewController (Screen 2) where the user types.
    CGFloat searchY = homeAvailabilityLabel.frame.origin.y + homeAvailabilityLabel.frame.size.height + 12;
    UIButton *adondeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    adondeBtn.frame = CGRectMake(16, searchY, sw - 32, 56);
    adondeBtn.backgroundColor = [UIColor colorWithRed:0.949f green:0.949f blue:0.949f alpha:1.0f];
    adondeBtn.layer.cornerRadius = 12;
    adondeBtn.clipsToBounds = YES;
    adondeBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;

    // Search icon
    UIImageView *adondeIcon = [[UIImageView alloc] initWithFrame:CGRectMake(14, 18, 20, 20)];
    adondeIcon.image = [[UIImage systemImageNamed:@"magnifyingglass"]
                        imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    adondeIcon.tintColor = [UIColor colorWithRed:0.62f green:0.62f blue:0.62f alpha:1.0f];
    adondeIcon.contentMode = UIViewContentModeScaleAspectFit;
    adondeIcon.userInteractionEnabled = NO;
    [adondeBtn addSubview:adondeIcon];

    // Placeholder label
    UILabel *adondeLbl = [[UILabel alloc] initWithFrame:CGRectMake(44, 0, sw - 32 - 44 - 8, 56)];
    adondeLbl.text = [LanguageHelper getStringWithKey:@"k_s10_where_are_you_going" defaultValue:@"¿A dónde vas?"];
    adondeLbl.font = [UIFont fontWithName:@"NotoSans-Regular" size:16] ?: [UIFont systemFontOfSize:16];
    adondeLbl.textColor = [UIColor colorWithRed:0.62f green:0.62f blue:0.62f alpha:1.0f];
    adondeLbl.userInteractionEnabled = NO;
    [adondeBtn addSubview:adondeLbl];

    [adondeBtn addTarget:self action:@selector(showRouteInputScreen)
       forControlEvents:UIControlEventTouchUpInside];
    [homeBottomSheet addSubview:adondeBtn];

    NSArray *hiddenViews = @[
        self.viewPickup,
        self.viewDestination,
        self.viewEstimateFareInput,
        self.viewInputOffer,
        self.viewRiderButtons,
        self.showButtonOnView,
        self.viewPrePayment,
        self.viewPromocodeEnter,
    ];
    for (UIView *v in hiddenViews) {
        if (!v) continue;
        [v removeFromSuperview];
        v.hidden = YES;
        [self.view addSubview:v]; // keep in hierarchy so IBOutlet logic still works
    }

    // Pan gesture for dragging the sheet
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]
        initWithTarget:self action:@selector(handleSheetPan:)];
    [homeBottomSheet addGestureRecognizer:pan];
}

/**
 La fila de categorias, tal y como la manda el servidor.

 ANTES ESTABAN CABLEADAS A MANO: dos tarjetas fijas rotuladas "Moto" y "Auto", con
 imagenes del paquete, y un comentario que daba por hecho "index 0 -- matches server
 order". En Panama el backend devuelve Taxi, Envio y Luxor: se pintaban dos tarjetas
 con nombres e iconos que no eran, y la tercera categoria no existia para el pasajero.

 El nombre y el icono salen ahora de CategoryModel, igual que en Android
 (MainScreenActivity, categoriesAdapter). El hueco conserva el alto de 140 px que tenia,
 asi que nada de lo que va debajo en la hoja se mueve.

 Con tres o menos caben en el ancho; con mas, la fila se desplaza en horizontal en vez
 de encoger las tarjetas hasta que no se lea el nombre.
 */
-(void)buildVehicleCards {
    CGFloat sw = self.view.bounds.size.width;
    CGFloat cardH = 140.0;
    CGFloat cardY = 8 + 4 + 12; // handle: y=8, h=4, gap=12

    vehicleCards = [[NSMutableArray alloc] init];
    selectedVehicleIndex = 0;

    vehicleCardsScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, cardY, sw, cardH)];
    vehicleCardsScroll.backgroundColor = [UIColor clearColor];
    vehicleCardsScroll.showsHorizontalScrollIndicator = NO;
    [homeBottomSheet addSubview:vehicleCardsScroll];

    [self rebuildVehicleCards];
}

/** Repinta la fila con lo que haya en arrayCagetgory. Se puede llamar las veces que haga falta. */
-(void)rebuildVehicleCards {
    if (vehicleCardsScroll == nil) {
        return;
    }
    for (UIView *v in [vehicleCardsScroll subviews]) {
        [v removeFromSuperview];
    }
    [vehicleCards removeAllObjects];

    NSArray *cats = arrayCagetgory;
    if (![cats isKindOfClass:[NSArray class]] || cats.count == 0) {
        vehicleCardsScroll.contentSize = CGSizeZero;
        return;
    }
    if (selectedVehicleIndex >= (NSInteger)cats.count) {
        selectedVehicleIndex = 0;
    }

    CGFloat sw = self.view.bounds.size.width;
    CGFloat cardH = 140.0;
    CGFloat margen = 16.0;
    CGFloat sep = 8.0;
    NSInteger aLaVez = MIN((NSInteger)cats.count, 3);
    CGFloat cardW = (sw - margen * 2 - sep * (aLaVez - 1)) / aLaVez;

    CGFloat x = margen;
    for (NSInteger i = 0; i < (NSInteger)cats.count; i++) {
        CategoryModel *cat = [cats objectAtIndex:(NSUInteger)i];

        UIView *card = [[UIView alloc] initWithFrame:CGRectMake(x, 0, cardW, cardH)];
        card.backgroundColor = [UIColor whiteColor];
        card.layer.cornerRadius = 16;
        card.layer.borderWidth = 1.5f;
        card.layer.borderColor = [UIColor colorWithRed:0.878f green:0.878f blue:0.878f alpha:1.0f].CGColor;
        card.clipsToBounds = YES;
        card.tag = i;

        UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake((cardW - 80) / 2, 12, 80, 70)];
        img.contentMode = UIViewContentModeScaleAspectFit;
        // Si la imagen del servidor no carga, queda el icono del paquete que mas se
        // parezca: mejor una silueta generica que un hueco en blanco.
        UIImage *respaldo = [[cat.cat_name lowercaseString] containsString:@"moto"]
            ? [UIImage imageNamed:@"ic_vehicle_moto"]
            : ([UIImage imageNamed:@"ic_vehicle_car"] ?: [UIImage imageNamed:@"map_car_icon"]);
        [img sd_setImageWithURL:[NSURL URLWithString:isEmpty(cat.cat_image_path)]
               placeholderImage:respaldo];
        [card addSubview:img];

        UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(4, cardH - 32, cardW - 8, 24)];
        lbl.text = isEmpty(cat.cat_name);
        lbl.font = [UIFont fontWithName:@"NotoSans-Bold" size:15] ?: [UIFont boldSystemFontOfSize:15];
        lbl.textAlignment = NSTextAlignmentCenter;
        lbl.adjustsFontSizeToFitWidth = YES;
        lbl.minimumScaleFactor = 0.7f;
        lbl.textColor = [UIColor colorWithRed:0.157f green:0.157f blue:0.157f alpha:1.0f];
        [card addSubview:lbl];

        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
            initWithTarget:self action:@selector(onVehicleCardTap:)];
        card.userInteractionEnabled = YES;
        [card addGestureRecognizer:tap];

        [vehicleCardsScroll addSubview:card];
        [vehicleCards addObject:card];
        x += cardW + sep;
    }

    vehicleCardsScroll.contentSize = CGSizeMake(x - sep + margen, cardH);
    [self updateVehicleCardSelection:selectedVehicleIndex];
}

-(void)onVehicleCardTap:(UITapGestureRecognizer *)gesto {
    [self vehicleCardTapped:gesto.view.tag];
}

-(void)vehicleCardTapped:(NSInteger)index {
    [self updateVehicleCardSelection:index];
    if (index < (NSInteger)arrayCagetgory.count) {
        Selectedcategory = arrayCagetgory[index];
        [nearByDriverHandler changeCategoryId:Selectedcategory.categoryId
                                      city_id:[NSString stringWithFormat:@"%d", cityModel.city_id]];
        if (isMapRouteMake) {
            [self showFareInfoForCategory];
        }
    }
}

-(void)updateVehicleCardSelection:(NSInteger)index {
    if (vehicleCards.count == 0) {
        return;
    }
    selectedVehicleIndex = index;
    UIColor *selBorder = [UIColor colorNamed:@"app_theame"];
    UIColor *selBg     = [UIColor colorWithRed:1.0f green:0.984f blue:0.918f alpha:1.0f]; // #FFFBEA
    UIColor *defBorder = [UIColor colorWithRed:0.878f green:0.878f blue:0.878f alpha:1.0f];
    UIColor *defBg     = [UIColor whiteColor];

    for (NSInteger i = 0; i < (NSInteger)vehicleCards.count; i++) {
        UIView *card = [vehicleCards objectAtIndex:(NSUInteger)i];
        BOOL elegida = (i == index);
        card.layer.borderColor = elegida ? selBorder.CGColor : defBorder.CGColor;
        card.backgroundColor   = elegida ? selBg : defBg;
    }
}


/// Called by the transparent overlay button placed on top of viewDestination in Screen 1.
-(void)showRouteInputScreen {
    URouteInputViewController *vc = [[URouteInputViewController alloc] init];
    vc.direction        = direction;
    vc.categories       = arrayCagetgory;
    vc.selectedCategory = Selectedcategory;
    vc.delegate         = self;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - URouteInputDelegate

/// Destination selected in Screen 2 — geocode place_id, set direction.destination, draw route.
-(void)routeInputVC:(URouteInputViewController *)vc didSelectDestination:(NSDictionary *)dictLocation {
    // Set flag BEFORE the pop triggers viewWillAppear: which would otherwise reset direction.
    isReturningFromRouteInput = YES;
    pendingScreen3Presentation = YES; // show Screen 3 once fare API returns
    btnDropState = @"cross";
    NSString *stringDestinationAddress = [dictLocation objectForKey:@"description"] ?: @"";
    NSArray  *arrTerms                 = [dictLocation objectForKey:@"terms"];
    NSString *country                  = [[arrTerms lastObject] objectForKey:@"value"] ?: @"";
    NSString *stringPlaceId            = [dictLocation objectForKey:@"place_id"];

    self.txtDestinationAddres.text = stringDestinationAddress;

    direction.destination = [[CLLocation alloc] initWithLatitude:emptyLoc.latitude
                                                       longitude:emptyLoc.longitude];

    [UtilityClass setLH:NO wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];

    [Utilities getLocationFromAddressStringPlaceId:stringPlaceId withcompletionHandler:^(CLLocationCoordinate2D loc) {
        CLLocation *location = [[CLLocation alloc] initWithLatitude:loc.latitude longitude:loc.longitude];

        if ([self->direction.source distanceFromLocation:location] < 100) {
            [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
            [self showAlertWithOk:@""
                          message:[LanguageHelper getStringWithKey:@"k_76_s4_cnt_slct_sm_lctn"]
                          handler:^(UIAlertAction *action) { }];
            return;
        }

        self->direction.destination = location;
        self->direction.dropAddress = stringDestinationAddress;
        self->direction.dropCountry = country;

        [self zoomToDestination];
        [self addMapAnnotationsWith:self->direction type:@"destination"];
        [UtilityClass setLH:NO wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
        [self drawRoute];
        [self resetResetPickDrop];
    }];
}

/// Pickup changed in Screen 2 — geocode and update direction.source.
-(void)routeInputVC:(URouteInputViewController *)vc didSelectPickup:(NSDictionary *)dictLocation {
    NSString *stringPickup  = [dictLocation objectForKey:@"description"] ?: @"";
    NSString *stringPlaceId = [dictLocation objectForKey:@"place_id"];
    NSArray  *arrTerms      = [dictLocation objectForKey:@"terms"];
    NSString *country       = [[arrTerms lastObject] objectForKey:@"value"] ?: @"";

    self.txtPickupAddress.text = stringPickup;

    [Utilities getLocationFromAddressStringPlaceId:stringPlaceId withcompletionHandler:^(CLLocationCoordinate2D loc) {
        self->direction.source     = [[CLLocation alloc] initWithLatitude:loc.latitude longitude:loc.longitude];
        self->direction.pickAddress = stringPickup;
        self->direction.pickCountry = country;
        [self->nearByDriverHandler changePickUpLocation:self->direction.source];
        [self addMapAnnotationsWith:self->direction type:@"source"];
    }];
}

#pragma mark - Punto elegido en el mapa

/**
 Recogida elegida arrastrando el mapa.

 Mismo trabajo que didSelectPickup:, sin el paso de resolver el place_id: del mapa sale
 la coordenada directamente. Ver la nota del protocolo en URouteInputViewController.h.
 */
-(void)routeInputVC:(URouteInputViewController *)vc
   eligioRecogidaEn:(CLLocationCoordinate2D)coordenada
          direccion:(NSString *)direccion {

    self.txtPickupAddress.text = direccion;
    direction.source      = [[CLLocation alloc] initWithLatitude:coordenada.latitude
                                                       longitude:coordenada.longitude];
    direction.pickAddress = direccion;
    direction.pickCountry = @"";
    isPickupSelected = YES;

    [nearByDriverHandler changePickUpLocation:direction.source];
    [self addMapAnnotationsWith:direction type:@"source"];

    // Si ya habia destino, la ruta cambia: hay que volver a trazarla.
    if (direction.destination && direction.destination.coordinate.latitude != emptyLoc.latitude) {
        [self drawRoute];
    }
}

/** Destino elegido arrastrando el mapa. */
-(void)routeInputVC:(URouteInputViewController *)vc
    eligioDestinoEn:(CLLocationCoordinate2D)coordenada
          direccion:(NSString *)direccion {

    // Igual que en didSelectDestination:, hay que marcarlo ANTES de que la pantalla de
    // ruta se cierre: al reaparecer, viewWillAppear reiniciaria direction si no.
    isReturningFromRouteInput = YES;
    [self fijarDestinoEn:coordenada nombre:direccion];
}

-(void)handleSheetPan:(UIPanGestureRecognizer *)pan {
    CGFloat sw = self.view.bounds.size.width;
    CGFloat ty = [pan translationInView:self.view].y;
    CGFloat newY = homeBottomSheet.frame.origin.y + ty;
    newY = MAX(sheetExpandedY, MIN(sheetCollapsedY, newY));
    homeBottomSheet.frame = CGRectMake(0, newY, sw, homeBottomSheet.frame.size.height);
    [pan setTranslation:CGPointZero inView:self.view];

    if (pan.state == UIGestureRecognizerStateEnded) {
        CGFloat velocity = [pan velocityInView:self.view].y;
        BOOL expand = (velocity < -300) || (newY < (sheetCollapsedY + sheetExpandedY) / 2.0);
        [UIView animateWithDuration:0.35
                              delay:0
             usingSpringWithDamping:0.85
              initialSpringVelocity:0.5
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
            self->homeBottomSheet.frame = CGRectMake(0,
                expand ? self->sheetExpandedY : self->sheetCollapsedY,
                sw, self->homeBottomSheet.frame.size.height);
        } completion:nil];
    }
}

#pragma mark - Screen 3 — UFareOfferViewController

-(void)presentScreen3 {
    EstimatedFare *estimate = [_bookingModel getEstimateFareForCategory:[self getSelectectCategoryByRider].categoryId];
    float recommended = estimate ? estimate.trip_pay_amount_without_share_discount_without_promo : 0.0f;
    float minOfferPerc = _bookingModel.category ? _bookingModel.category.min_offer_perc : 0.0f;
    float maxOfferPerc = _bookingModel.category ? _bookingModel.category.max_offer_perc : 0.0f;
    float minFare = (minOfferPerc > 0 && recommended > 0) ? recommended * (1.0f - minOfferPerc / 100.0f) : 0.0f;
    float maxFare = (maxOfferPerc > 0 && recommended > 0) ? recommended * (1.0f + maxOfferPerc / 100.0f) : 0.0f;

    UFareOfferViewController *vc = [[UFareOfferViewController alloc] init];
    vc.delegate        = self;
    vc.recommendedFare = recommended;
    vc.minFare         = minFare;
    vc.maxFare         = maxFare;
    vc.currency        = isEmpty(cityModel.city_cur);
    vc.paymentLabel    = paymentViewModel.paymentModeText;
    vc.paymentIcon     = paymentViewModel.paymentModeImage;

    // Para la lista "Elige tu viaje". El diccionario de estimaciones ya lo tenia
    // BookingModel: tripapi/estimatetripfare devuelve una por CADA categoria en una sola
    // llamada, no solo la de la elegida.
    vc.categorias               = arrayCagetgory;
    vc.categoriaElegida         = [self getSelectectCategoryByRider];
    vc.estimacionesPorCategoria = _bookingModel.fareEstimated;

    currentFareOfferVC = vc;

    homeBottomSheet.hidden = YES;
    self.btnGps.hidden     = YES;

    // La ruta se encuadro cuando se trazo, con el mapa entero a la vista. Ahora la hoja
    // de tarifa tapa mas de la mitad de abajo, asi que hay que volver a encuadrarla en
    // el trozo que queda; si no, el viaje se ve a medias o directamente escondido.
    [self encuadrarRutaDejandoHuecoAbajo:self.view.bounds.size.height * 0.58f];
    [self mostrarPildoraDeRuta];

    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    nav.modalPresentationStyle = UIModalPresentationOverFullScreen;
    nav.navigationBarHidden    = YES;
    [self presentViewController:nav animated:YES completion:nil];
}

/**
 Encuadra la ruta dejando libre una franja de abajo.

 zoomToFitMapAnnotations centra en el mapa ENTERO, que es lo correcto mientras se ve
 entero. En cuanto una hoja tapa la parte de abajo hace falta apartar la ruta de esa
 zona, y para eso MapKit tiene margenes: setVisibleMapRect:edgePadding: reduce el
 rectangulo util en vez de tener que inventar un centro desplazado a ojo.
 */
-(void)encuadrarRutaDejandoHuecoAbajo:(CGFloat)hueco {
    if (direction == nil
        || direction.source.coordinate.latitude == emptyLoc.latitude
        || direction.destination.coordinate.latitude == emptyLoc.latitude) {
        return;
    }

    MKMapPoint p1 = MKMapPointForCoordinate(direction.source.coordinate);
    MKMapPoint p2 = MKMapPointForCoordinate(direction.destination.coordinate);
    MKMapRect rect = MKMapRectMake(MIN(p1.x, p2.x), MIN(p1.y, p2.y),
                                   fabs(p1.x - p2.x), fabs(p1.y - p2.y));
    if (MKMapRectIsNull(rect) || rect.size.width == 0 || rect.size.height == 0) {
        return;
    }

    // Arriba se deja sitio para el boton del menu, el titulo y la pildora.
    UIEdgeInsets margenes = UIEdgeInsetsMake(140, 48, hueco + 24, 48);
    [self.mapView setVisibleMapRect:rect edgePadding:margenes animated:YES];
}

/** "2,6 km · 9 min" flotando sobre el mapa, como en Android. */
-(void)mostrarPildoraDeRuta {
    if (tripDistanceConvertedInUnit <= 0 && tripTime <= 0) {
        return;
    }
    NSString *unidad = isDistanceUnitKm(cityModel.city_dist_unit) ? @"km" : @"mi";
    NSString *texto = [NSString stringWithFormat:@"%.2f %@  ·  %d min",
                       tripDistanceConvertedInUnit, unidad, tripTime];

    if (pildoraRuta == nil) {
        pildoraRuta = [[UILabel alloc] init];
        pildoraRuta.backgroundColor = [UIColor whiteColor];
        pildoraRuta.textColor = [UIColor colorWithRed:0.157f green:0.157f blue:0.157f alpha:1.0f];
        pildoraRuta.font = [UIFont fontWithName:@"NotoSans-Bold" size:15] ?: [UIFont boldSystemFontOfSize:15];
        pildoraRuta.textAlignment = NSTextAlignmentCenter;
        pildoraRuta.layer.cornerRadius = 18;
        pildoraRuta.clipsToBounds = NO;
        pildoraRuta.layer.masksToBounds = NO;
        pildoraRuta.layer.shadowColor = [UIColor blackColor].CGColor;
        pildoraRuta.layer.shadowOpacity = 0.15f;
        pildoraRuta.layer.shadowRadius = 6;
        pildoraRuta.layer.shadowOffset = CGSizeMake(0, 2);
        [self.view addSubview:pildoraRuta];
    }
    pildoraRuta.text = texto;
    CGFloat ancho = [texto sizeWithAttributes:@{NSFontAttributeName: pildoraRuta.font}].width + 32;
    CGFloat safeTop = self.view.safeAreaInsets.top;
    if (safeTop <= 0) { safeTop = 44; }
    pildoraRuta.frame = CGRectMake((self.view.bounds.size.width - ancho) / 2.0,
                                   safeTop + 56, ancho, 36);
    // El fondo blanco debe ir redondeado pero la sombra no puede recortarse: por eso
    // masksToBounds queda en NO y el radio se aplica a la capa.
    pildoraRuta.layer.backgroundColor = [UIColor whiteColor].CGColor;
    pildoraRuta.hidden = NO;
    [self.view bringSubviewToFront:pildoraRuta];
}

-(void)ocultarPildoraDeRuta {
    pildoraRuta.hidden = YES;
}

-(void)restoreScreen1Overlays {
    homeBottomSheet.hidden = NO;
    self.btnGps.hidden     = NO;
    [self ocultarPildoraDeRuta];
    [self ocultarRestosDelDisenoViejo];
    [self asegurarDireccionDeRecogida];
}

/**
 Esconde lo que queda del home antiguo.

 showFareInfoForCategory tiene dos caminos: con la pantalla de tarifa pendiente se sale
 antes de tocar nada, pero cualquier estimacion posterior -- un cambio de categoria, un
 cupon -- cae por el camino viejo y ENSEÑA los botones de informacion de tarifa, que en
 este diseño no tienen sitio asignado y aparecen sueltos arriba a la izquierda, encima
 de la barra de estado.
 */
-(void)ocultarRestosDelDisenoViejo {
    [self categoryFareInformationIsHidden:YES];
    self.viewInputOffer.hidden        = YES;
    self.viewEstimateFareInput.hidden = YES;
    self.showButtonOnView.hidden      = YES;
    self.viewTimeDistance.hidden      = YES;
    self.viewConfirmViewShow.hidden   = YES;
}

/**
 El pasajero cambio de categoria desde la lista "Elige tu viaje".

 La pantalla de tarifa ya se ha repintado sola -- precio, topes del ajustador y marcado
 de la fila. Aqui solo hay que dejar el resto de la app de acuerdo con ella: la eleccion
 que se usara al pedir el viaje, la tarjeta marcada en el home detras, y los conductores
 cercanos, que se filtran por categoria.

 No se vuelve a pedir la estimacion: ya estaban todas.
 */
-(void)fareOfferVC:(UFareOfferViewController *)vc eligioCategoria:(CategoryModel *)categoria {
    if (categoria == nil) {
        return;
    }
    Selectedcategory = categoria;
    _bookingModel.category = categoria;

    NSInteger i = [arrayCagetgory indexOfObject:categoria];
    if (i != NSNotFound) {
        [self updateVehicleCardSelection:i];
    }

    if (cityModel) {
        [nearByDriverHandler changeCategoryId:categoria.categoryId
                                      city_id:[NSString stringWithFormat:@"%d", cityModel.city_id]];
    }
}

/**
 El pasajero aplico un cupon.

 No se valida aqui: se manda a la estimacion, que es quien sabe si el codigo existe,
 si sigue vivo y cuanto descuenta. Igual que Android.
 */
-(void)fareOfferVC:(UFareOfferViewController *)vc aplicarCupon:(NSString *)codigo {
    if (cityModel == nil) {
        [Utilities showAlertwithTilte:@""
                              message:[LanguageHelper getStringWithKey:@"k_r30_s5_select_city"]
                 navigatationController:self.navigationController];
        return;
    }
    promoCode = [[PromoCodeModel alloc] initWithPromode:codigo city_id:cityModel.city_id];
    [self reestimarParaLaHojaDeTarifa];
}

-(void)fareOfferVCQuitarCupon:(UFareOfferViewController *)vc {
    promoCode = nil;
    [self reestimarParaLaHojaDeTarifa];
}

/**
 Vuelve a estimar y devuelve el resultado a la hoja que ya esta abierta.

 No vale calCalculateFare: ese camino termina en showFareInfoForCategory, que con la
 hoja pendiente PRESENTA otra, y con ella abierta toca las vistas del diseño viejo del
 guion grafico. Aqui solo hace falta la llamada y el repintado de la hoja viva.
 */
-(void)reestimarParaLaHojaDeTarifa {
    __weak typeof(self) debil = self;
    [_bookingModel callFareEstimateApiWithCompletionBlock:^(id results, NSError *error) {
        __strong typeof(debil) fuerte = debil;
        if (fuerte == nil) {
            return;
        }
        if (isStatusError(results)) {
            [fuerte showAlertWithMessgae:[LanguageHelper getStringWithKey:[results objectForKey:P_MESSAGE]]];
            return;
        }
        if (error != nil) {
            if (![fuerte isHandledError:error]) {
                [fuerte showAlertWhenEstimateApiFailed];
            }
            return;
        }
        [fuerte->currentFareOfferVC refrescarConEstimaciones:fuerte->_bookingModel.fareEstimated];
    } promoCode:promoCode];
}

-(void)fareOfferDidTapBack:(UFareOfferViewController *)vc {
    currentFareOfferVC = nil;
    isReturningFromFareOffer = YES; // prevents viewWillAppear from resetting direction/pickup
    [self dismissViewControllerAnimated:YES completion:^{
        // Don't restore Screen 1 overlays — immediately push Screen 2
        URouteInputViewController *routeVC = [[URouteInputViewController alloc] init];
        routeVC.direction        = self->direction;
        routeVC.categories       = self->arrayCagetgory;
        routeVC.selectedCategory = self->Selectedcategory;
        routeVC.delegate         = self;
        [self.navigationController pushViewController:routeVC animated:YES];
    }];
}

-(void)fareOfferVC:(UFareOfferViewController *)vc didRequestTripWithAmount:(float)amount {
    // Hay que leerlo ahora: en cuanto se cierre la pantalla, el contador y los
    // interruptores se van con ella.
    configDelViaje = [self notaDeConfiguracionDesde:vc];

    // currentFareOfferVC se suelta DESPUES de cerrar, no antes: es la señal que usa
    // viewWillAppear para saber que hay un viaje a medio montar y no reiniciarlo.
    // Ponerlo a nil aqui arriba dejaba ese guardia sin efecto justo en el momento en
    // que hace falta.
    [self dismissViewControllerAnimated:YES completion:^{
        self->currentFareOfferVC = nil;
        [self restoreScreen1Overlays];
        self.txtExtmatedFareAmt.text = [Utilities formatAmount:amount];
        [self onRequestButtonTap:self.btRiderNow];
    }];
}

/**
 "Cash|Mascotas,Delivery|3 Pasajero(s)" -- el mismo formato exacto que manda Android.

 El conductor enseña esta cadena tal cual (TripModel.pickup_notes), sin interpretarla.
 Por eso el formato importa: si iOS mandara otra cosa, el mismo viaje se leeria
 distinto segun con que app lo hubiera pedido el pasajero.
 */
-(NSString *)notaDeConfiguracionDesde:(UFareOfferViewController *)vc {
    NSMutableArray *opciones = [NSMutableArray array];
    if (vc.configPetsAllowed) {
        [opciones addObject:@"Mascotas"];
    }
    if (vc.configIsDelivery) {
        [opciones addObject:@"Delivery"];
    }

    return [NSString stringWithFormat:@"%@|%@|%ld Pasajero(s)",
            [self metodoDePagoParaElConductor],
            [opciones componentsJoinedByString:@","],
            (long)vc.numeroDePasajeros];
}

/**
 Como se llama el metodo de pago en la nota que lee el conductor.

 Ya vale tripPayMode tal cual: desde que el pago movil se manda como "Pago Movil" y no
 como "Card", el nombre es el mismo aqui y en trip_pay_mode. Lo que se le añade es el
 detalle del efectivo -- "Cash [Pago con $20, necesito vuelto]" -- que es como Android
 se lo hace llegar y como el conductor lo lee (TripRequestActivity busca los corchetes).
 */
-(NSString *)metodoDePagoParaElConductor {
    NSString *modo = isEmpty(paymentViewModel.tripPayMode);
    NSString *detalle = [instruccionesDeEfectivo
        stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([modo isEqualToString:CASH_PAY] && detalle.length > 0) {
        return [NSString stringWithFormat:@"%@ [%@]", modo, detalle];
    }
    return modo;
}

-(void)fareOfferVCDidTapPayment:(UFareOfferViewController *)vc {
    PaymentMethodViewController *payVC = [[PaymentMethodViewController alloc] init];
    payVC.delegate      = self;
    payVC.selectedMode  = paymentViewModel.paymentMode;
    payVC.cityModel     = cityModel;
    // Pass the current fare so wallet validation can check the balance
    payVC.tripFare      = vc.currentAmount;
    /*
     OverFullScreen, no FullScreen.

     Se ve igual -- las dos ocupan la pantalla entera -- pero FullScreen SACA de la
     ventana la jerarquia que hay debajo, incluido el home. Al cerrar la hoja el home
     volvia a aparecer, con su viewWillAppear, y ahi hay un reset que reemplaza
     `direction` por un objeto vacio: el pasajero perdia la recogida y el destino que
     acababa de elegir, y al pedir el taxi le decia que no habia direccion.

     Con OverFullScreen el home nunca se va de la ventana y su viewWillAppear no
     llega a correr.
     */
    payVC.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [vc.navigationController presentViewController:payVC animated:YES completion:nil];
}

/**
 Lleva a la pagina de recargas.

 Se empuja en la navegacion de la pantalla de tarifa, no se presenta en modal: el boton
 de volver de AboutUsViewController hace pop, y en un modal sin pila no haria nada.
 */
-(void)paymentSheetDidRequestWalletTopUp:(PaymentMethodViewController *)vc {
    UINavigationController *nav = currentFareOfferVC.navigationController ?: self.navigationController;
    if (nav == nil) {
        return;
    }
    AboutUsViewController *web = [[UIStoryboard storyboardWithName:@"User" bundle:nil]
                                  instantiateViewControllerWithIdentifier:@"AboutUsViewController"];
    web.isCustomUrl = YES;
    web.customTitle = [LanguageHelper getStringWithKey:@"k_s10_recargar" defaultValue:@"Recargar"];
    web.customUrl   = [Utilities urlDeRecargas];
    [nav pushViewController:web animated:YES];
}

-(void)paymentSheet:(PaymentMethodViewController *)vc
   instruccionesDeEfectivo:(NSString *)instrucciones {
    instruccionesDeEfectivo = instrucciones;
}

// PaymentMethodViewControllerDelegate
-(void)paymentSheet:(PaymentMethodViewController *)vc didSelectMode:(int)mode {
    [paymentViewModel updatePaymentModeText:mode];
    [currentFareOfferVC updatePaymentLabel:paymentViewModel.paymentModeText
                                      icon:paymentViewModel.paymentModeImage];
}

-(void)refreshHomeAvailabilityLabel {
    if (!homeAvailabilityLabel) return;
    NSString *time = self.lbTime.text;
    NSString *msg  = self.lbDriversAvailableMessage.text;

    if (!time.length && !msg.length) {
        homeAvailabilityLabel.attributedText = nil;
        homeAvailabilityLabel.text = @"";
        homeAvailabilityLabel.backgroundColor = [UIColor clearColor];
        return;
    }

    // No-vehicle state: time is empty but message is present
    if (!time.length && msg.length) {
        UIColor *orangeColor = [UIColor colorWithRed:0.95f green:0.42f blue:0.09f alpha:1.0f];
        UIFont  *boldFont    = [UIFont fontWithName:@"NotoSans-Bold" size:13] ?: [UIFont boldSystemFontOfSize:13];
        // Strip leading "- " if present
        NSString *cleanMsg = [msg hasPrefix:@"- "] ? [msg substringFromIndex:2] : msg;
        NSMutableAttributedString *as = [[NSMutableAttributedString alloc] init];
        // Orange dot
        [as appendAttributedString:[[NSAttributedString alloc]
            initWithString:@"● "
            attributes:@{NSForegroundColorAttributeName: orangeColor, NSFontAttributeName: boldFont}]];
        [as appendAttributedString:[[NSAttributedString alloc]
            initWithString:cleanMsg
            attributes:@{NSForegroundColorAttributeName: orangeColor, NSFontAttributeName: boldFont}]];
        homeAvailabilityLabel.attributedText = as;
        homeAvailabilityLabel.backgroundColor = [UIColor clearColor];
        return;
    }

    // Vehicles available state
    UIColor *accentColor = [UIColor colorNamed:@"app_theame"];
    UIColor *textColor   = [UIColor colorNamed:@"color_app_label"];
    UIFont  *boldFont    = [UIFont fontWithName:@"NotoSans-Bold"    size:14] ?: [UIFont boldSystemFontOfSize:14];
    UIFont  *regFont     = [UIFont fontWithName:@"NotoSans-Regular" size:14] ?: [UIFont systemFontOfSize:14];
    NSMutableAttributedString *as = [[NSMutableAttributedString alloc] init];
    // Green dot
    UIColor *greenColor = [UIColor colorWithRed:0.17f green:0.74f blue:0.38f alpha:1.0f];
    [as appendAttributedString:[[NSAttributedString alloc]
        initWithString:@"● "
        attributes:@{NSForegroundColorAttributeName: greenColor, NSFontAttributeName: boldFont}]];
    if (time.length) {
        [as appendAttributedString:[[NSAttributedString alloc]
            initWithString:[NSString stringWithFormat:@"(%@)", time]
            attributes:@{NSForegroundColorAttributeName: accentColor, NSFontAttributeName: boldFont}]];
    }
    if (msg.length) {
        NSString *cleanMsg = [msg hasPrefix:@"- "] ? [msg substringFromIndex:2] : msg;
        [as appendAttributedString:[[NSAttributedString alloc]
            initWithString:[NSString stringWithFormat:@" %@", cleanMsg]
            attributes:@{NSForegroundColorAttributeName: textColor, NSFontAttributeName: regFont}]];
    }
    homeAvailabilityLabel.attributedText = as;
    homeAvailabilityLabel.backgroundColor = [UIColor clearColor];
}

@end

