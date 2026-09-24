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

/// El estado del viaje, en negrita y arriba del todo (Android: tripStatus).
@property (nonatomic, strong) UILabel        *lblEstadoViaje;
/// "Dale este numero a tu conductor", debajo del estado (Android: tvOtpLabel).
@property (nonatomic, strong) UILabel        *statusLabel;
@property (nonatomic, strong) UIButton       *actionButton;
@property (nonatomic, strong) UIButton       *shareButton;
/// El chat como boton propio, no escondido en un menu (Android: btnChatDriver).
@property (nonatomic, strong) MIBadgeButton  *btnChatConductor;
@property (nonatomic, strong) UIView         *separadorCabecera;
@property (nonatomic, strong) UILabel        *lbTripOtp;

@property (nonatomic, strong) UIButton       *btnGps;

@property (nonatomic, strong) UIView         *driverCard;
@property (nonatomic, strong) UIImageView    *imgDriver;
@property (nonatomic, strong) UIImageView    *imgEstrella;
@property (nonatomic, strong) UILabel        *starRatingLbl;
/// El icono y el nombre de la categoria, a la derecha de la tarjeta del conductor.
@property (nonatomic, strong) UIImageView    *imgCategoria;
@property (nonatomic, strong) UILabel        *lblCategoria;
@property (nonatomic, strong) UILabel        *lblDriverName;
@property (nonatomic, strong) UILabel        *lbCarName;
@property (nonatomic, strong) UIImageView    *imageVehicle;
@property (nonatomic, strong) UILabel        *lblCarNumber;

/// Los datos de pago movil del conductor. Solo si se paga asi.
@property (nonatomic, strong) UIView         *tarjetaPagoMovil;
@property (nonatomic, strong) UILabel        *lblPagoMovilDatos;

@property (nonatomic, strong) UIView         *destinationCard;
@property (nonatomic, strong) UILabel        *destinationLabel;
/// De donde sale el viaje, bajo el destino (Android: detailpickup).
@property (nonatomic, strong) UILabel        *lblDireccionRecogida;

/// "Metodo de pago: Pago Movil". Encima del importe, como en Android.
@property (nonatomic, strong) UIView         *filaMetodoDePago;
@property (nonatomic, strong) UIImageView    *imgMetodoDePago;
@property (nonatomic, strong) UILabel        *lblMetodoDePago;

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
/// El aspa del aviso de mensaje.
@property (nonatomic, strong) UIButton       *btnCerrarAviso;
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
    /// Con cuantos mensajes sin leer se cerro el aviso a mano. Sirve para no volver a
    /// sacarlo hasta que llegue uno nuevo de verdad.
    int _avisoCerradoConNMensajes;
    NSTimer *timerBlink;
    BOOL blinkStatus;
    /** Cuantos no leidos habia la ultima vez, para avisar solo cuando sube. */
    int ultimoConteoNoLeidos;
    /** La primera lectura trae los mensajes que YA estaban sin leer: esos no se avisan. */
    BOOL primeraLecturaChat;
    NSString * driverLicensePath;
    BOOL isGoToHomeScreen;
    BOOL isBeginRouteDraw;
    /// El recorrido se encuadra una vez, no en cada refresco de la ruta.
    BOOL yaEncuadreElRecorrido;
    /// Con que estado se encuadro el mapa la ultima vez.
    NSString *ultimoEstadoEncuadrado;
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
    [self setupTarjetaPagoMovil];
    [self setupDestinationCard];
    [self setupFilaMetodoDePago];
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
    if (@available(iOS 13.0, *)) {
        self.mapView.pointOfInterestFilter = nil;
    }
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
    // El estado del viaje. Android lo tiene SIEMPRE arriba y en negrita, y debajo --
    // solo cuando toca -- el rotulo del OTP. Aqui los dos compartian una sola
    // etiqueta, asi que en cuanto habia OTP el estado desaparecia: el pasajero no
    // llegaba a leer nunca "El conductor esta en camino".
    self.lblEstadoViaje = [[UILabel alloc] init];
    self.lblEstadoViaje.font = [UIFont fontWithName:@"NotoSans-Bold" size:16]
                               ?: [UIFont boldSystemFontOfSize:16];
    self.lblEstadoViaje.textColor = [UIColor colorWithRed:0x21/255.0 green:0x21/255.0 blue:0x21/255.0 alpha:1];
    self.lblEstadoViaje.numberOfLines = 2;
    [self.sheetPanel addSubview:self.lblEstadoViaje];

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

    // Chat: en Android es un boton mas de esta fila, con el numero de mensajes sin
    // leer encima. Aqui estaba enterrado dentro del menu del boton de llamar, asi que
    // no habia forma de ver que el conductor habia escrito sin abrir ese menu.
    self.btnChatConductor = [[MIBadgeButton alloc] init];
    self.btnChatConductor.backgroundColor = [UIColor colorNamed:@"app_theame"]
        ?: [UIColor colorWithRed:0xEB/255.0 green:0xB5/255.0 blue:0x18/255.0 alpha:1];
    self.btnChatConductor.layer.cornerRadius = 10;
    self.btnChatConductor.clipsToBounds = NO;
    self.btnChatConductor.badgeBackgroundColor = [UIColor colorWithRed:0xEB/255.0 green:0x54/255.0 blue:0x4D/255.0 alpha:1];
    self.btnChatConductor.badgeTextColor = [UIColor whiteColor];
    self.btnChatConductor.hideWhenZero = YES;
    if (@available(iOS 13.0, *)) {
        [self.btnChatConductor setImage:[[UIImage systemImageNamed:@"message.fill"]
            imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    }
    self.btnChatConductor.tintColor = [UIColor blackColor];
    [self.btnChatConductor addTarget:self action:@selector(openChatViewController)
                    forControlEvents:UIControlEventTouchUpInside];
    [self.sheetPanel addSubview:self.btnChatConductor];

    // Action button (SOS or Phone — content set by updateHeaderForStatus:)
    self.actionButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.actionButton.layer.cornerRadius = 24;
    self.actionButton.clipsToBounds = YES;
    [self.sheetPanel addSubview:self.actionButton];

    self.separadorCabecera = [[UIView alloc] init];
    self.separadorCabecera.backgroundColor = [UIColor colorWithRed:0xEF/255.0 green:0xEF/255.0 blue:0xEF/255.0 alpha:1];
    [self.sheetPanel addSubview:self.separadorCabecera];
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

    // Estrella. Android pinta el icono y al lado "2.80 (105)"; aqui salia un numero
    // suelto -- el redondeo de la nota -- que no se entendia como valoracion.
    self.imgEstrella = [[UIImageView alloc] init];
    if (@available(iOS 13.0, *)) {
        self.imgEstrella.image = [[UIImage systemImageNamed:@"star.fill"]
            imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    self.imgEstrella.tintColor = [UIColor colorNamed:@"app_theame"]
        ?: [UIColor colorWithRed:0xEB/255.0 green:0xB5/255.0 blue:0x18/255.0 alpha:1];
    self.imgEstrella.contentMode = UIViewContentModeScaleAspectFit;
    [self.driverCard addSubview:self.imgEstrella];

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

    // Categoria: icono y nombre, como en Android. Es lo que le dice al pasajero que
    // esta esperando un taxi y no un envio.
    self.imgCategoria = [[UIImageView alloc] init];
    self.imgCategoria.contentMode = UIViewContentModeScaleAspectFit;
    [self.driverCard addSubview:self.imgCategoria];

    self.lblCategoria = [[UILabel alloc] init];
    self.lblCategoria.font = [UIFont fontWithName:@"NotoSans-Bold" size:12]
                             ?: [UIFont boldSystemFontOfSize:12];
    self.lblCategoria.textColor = [UIColor colorWithRed:0x69/255.0 green:0x69/255.0 blue:0x69/255.0 alpha:1];
    self.lblCategoria.textAlignment = NSTextAlignmentCenter;
    [self.driverCard addSubview:self.lblCategoria];

    // Plate number
    self.lblCarNumber = [[UILabel alloc] init];
    self.lblCarNumber.font = [UIFont fontWithName:@"NotoSans-Regular" size:11]
                             ?: [UIFont systemFontOfSize:11];
    self.lblCarNumber.textColor = [UIColor colorWithWhite:0.45 alpha:1];
    self.lblCarNumber.textAlignment = NSTextAlignmentRight;
    [self.driverCard addSubview:self.lblCarNumber];
}

/**
 Los datos bancarios del conductor para el pago movil.

 Nace oculta y solo aparece cuando el viaje se paga asi Y el conductor los tiene
 puestos. Android la tiene igual (cvPagoMovilInfo): sin estos datos el pasajero no
 puede transferir, porque el cobro no pasa por el app.
 */
- (void)setupTarjetaPagoMovil {
    self.tarjetaPagoMovil = [[UIView alloc] init];
    self.tarjetaPagoMovil.backgroundColor = UIColor.whiteColor;
    self.tarjetaPagoMovil.layer.cornerRadius = 12;
    self.tarjetaPagoMovil.layer.borderWidth = 1;
    self.tarjetaPagoMovil.layer.borderColor =
        [UIColor colorWithRed:0xEF/255.0 green:0xEF/255.0 blue:0xEF/255.0 alpha:1].CGColor;
    self.tarjetaPagoMovil.hidden = YES;
    [self.sheetPanel addSubview:self.tarjetaPagoMovil];

    UILabel *titulo = [[UILabel alloc] init];
    titulo.text = [LanguageHelper getStringWithKey:@"k_s10_datos_pago_movil"
                                      defaultValue:@"DATOS PAGO MÓVIL DEL CONDUCTOR"];
    titulo.font = [UIFont fontWithName:@"NotoSans-Bold" size:10] ?: [UIFont boldSystemFontOfSize:10];
    titulo.textColor = [UIColor colorNamed:@"app_theame"]
        ?: [UIColor colorWithRed:0xEB/255.0 green:0xB5/255.0 blue:0x18/255.0 alpha:1];
    titulo.tag = 903;
    [self.tarjetaPagoMovil addSubview:titulo];

    self.lblPagoMovilDatos = [[UILabel alloc] init];
    self.lblPagoMovilDatos.font = [UIFont fontWithName:@"NotoSans-Regular" size:12]
                                  ?: [UIFont systemFontOfSize:12];
    self.lblPagoMovilDatos.textColor = [UIColor colorWithRed:0x21/255.0 green:0x21/255.0 blue:0x21/255.0 alpha:1];
    self.lblPagoMovilDatos.numberOfLines = 3;
    [self.tarjetaPagoMovil addSubview:self.lblPagoMovilDatos];
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
    self.destinationLabel.numberOfLines = 2;
    [self.destinationCard addSubview:self.destinationLabel];

    // De donde sale. Aqui solo se enseñaba el destino, asi que el pasajero no podia
    // comprobar que la recogida era la que habia elegido.
    self.lblDireccionRecogida = [[UILabel alloc] init];
    self.lblDireccionRecogida.font = [UIFont fontWithName:@"NotoSans-Regular" size:11]
                                     ?: [UIFont systemFontOfSize:11];
    self.lblDireccionRecogida.textColor = [UIColor colorWithRed:0x69/255.0 green:0x69/255.0 blue:0x69/255.0 alpha:1];
    self.lblDireccionRecogida.numberOfLines = 2;
    [self.destinationCard addSubview:self.lblDireccionRecogida];

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

/**
 Con que se paga el viaje.

 Va ENCIMA del importe a proposito: el pasajero lee de arriba abajo "con que pago" y
 luego "cuanto", que es el orden en el que se lo pregunta. Es el mismo criterio y el
 mismo sitio que en Android (pay_mode_row).

 Si el viaje no trae un metodo conocido, la fila entera se esconde: una linea que
 dijera "Metodo de pago: --" justo encima de lo que hay que pagar no informa de nada.
 */
- (void)setupFilaMetodoDePago {
    self.filaMetodoDePago = [[UIView alloc] init];
    self.filaMetodoDePago.backgroundColor = [UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1];
    self.filaMetodoDePago.layer.cornerRadius = 12;
    self.filaMetodoDePago.clipsToBounds = YES;
    self.filaMetodoDePago.hidden = YES;
    [self.sheetPanel addSubview:self.filaMetodoDePago];

    UILabel *rotulo = [[UILabel alloc] init];
    rotulo.text = [LanguageHelper getStringWithKey:@"k_s10_metodo_de_pago" defaultValue:@"Método de pago:"];
    rotulo.font = [UIFont fontWithName:@"NotoSans-Regular" size:13] ?: [UIFont systemFontOfSize:13];
    rotulo.textColor = [UIColor colorWithRed:0x69/255.0 green:0x69/255.0 blue:0x69/255.0 alpha:1];
    rotulo.tag = 904;
    [self.filaMetodoDePago addSubview:rotulo];

    self.imgMetodoDePago = [[UIImageView alloc] init];
    self.imgMetodoDePago.contentMode = UIViewContentModeScaleAspectFit;
    self.imgMetodoDePago.tintColor = [UIColor colorWithRed:0x21/255.0 green:0x21/255.0 blue:0x21/255.0 alpha:1];
    [self.filaMetodoDePago addSubview:self.imgMetodoDePago];

    self.lblMetodoDePago = [[UILabel alloc] init];
    self.lblMetodoDePago.font = [UIFont fontWithName:@"NotoSans-Bold" size:14] ?: [UIFont boldSystemFontOfSize:14];
    self.lblMetodoDePago.textColor = [UIColor colorWithRed:0x21/255.0 green:0x21/255.0 blue:0x21/255.0 alpha:1];
    self.lblMetodoDePago.textAlignment = NSTextAlignmentRight;
    [self.filaMetodoDePago addSubview:self.lblMetodoDePago];
}

/** Lo que mide de verdad la tarjeta de pago movil con el texto que lleva dentro. */
- (CGFloat)altoDeLaTarjetaDePagoMovilConAncho:(CGFloat)ancho {
    NSString *texto = self.lblPagoMovilDatos.text;
    if (texto.length == 0 || ancho <= 0) {
        return 84;
    }
    UIFont *fuente = self.lblPagoMovilDatos.font ?: [UIFont systemFontOfSize:12];
    CGRect medida = [texto boundingRectWithSize:CGSizeMake(ancho - 20, CGFLOAT_MAX)
                                        options:(NSStringDrawingUsesLineFragmentOrigin |
                                                 NSStringDrawingUsesFontLeading)
                                     attributes:@{NSFontAttributeName: fuente}
                                        context:nil];
    // 26 arriba (margen + rotulo) y 10 abajo.
    return ceilf(medida.size.height) + 36;
}

/**
 Traduce trip_pay_mode a algo legible, con el mismo reparto que Android.

 Se acepta "Card" como pago movil ademas de "Pago Movil": los viajes que se pidieron
 desde un iPhone antes de que esto se escribiera bien tienen "Card" guardado y no se
 corrigen solos. Un "Card" con tarjeta de Stripe de verdad trae payment_card_id, que
 es lo que los distingue.
 */
- (void)actualizarFilaMetodoDePago {
    NSString *modo = [isEmpty(self.currentTrip.trip_pay_mode)
        stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    // "Cash [Pago con $20...]" -- el detalle va aparte, aqui solo interesa el metodo.
    NSRange corchete = [modo rangeOfString:@"["];
    NSString *soloModo = (corchete.location != NSNotFound)
        ? [[modo substringToIndex:corchete.location] stringByTrimmingCharactersInSet:
           [NSCharacterSet whitespaceCharacterSet]]
        : modo;

    NSString *texto = nil;
    NSString *icono = nil;
    if ([soloModo caseInsensitiveCompare:CASH_PAY] == NSOrderedSame) {
        texto = [LanguageHelper getStringWithKey:@"k_r39_s9_cash" defaultValue:@"Efectivo"];
        icono = @"banknote.fill";
    } else if ([soloModo caseInsensitiveCompare:HIRE_ME_WALLET_PAY] == NSOrderedSame) {
        texto = [LanguageHelper getStringWithKey:@"k_r39_s9_wallet" defaultValue:@"Billetera"];
        icono = @"wallet.pass.fill";
    } else if ([soloModo caseInsensitiveCompare:PAGO_MOVIL_PAY] == NSOrderedSame
               || [soloModo caseInsensitiveCompare:@"Pago Móvil"] == NSOrderedSame
               || ([soloModo caseInsensitiveCompare:CARD] == NSOrderedSame
                   && self.currentTrip.payment_card_id.length == 0)) {
        texto = [LanguageHelper getStringWithKey:@"k_s10_mobile_payment" defaultValue:@"Pago Móvil"];
        icono = @"iphone";
    } else if ([soloModo caseInsensitiveCompare:CARD] == NSOrderedSame) {
        texto = [LanguageHelper getStringWithKey:@"k_s10_tarjeta" defaultValue:@"Tarjeta"];
        icono = @"creditcard.fill";
    }

    if (texto == nil) {
        self.filaMetodoDePago.hidden = YES;
        return;
    }
    self.lblMetodoDePago.text = texto;
    [self.view setNeedsLayout];
    if (@available(iOS 13.0, *)) {
        self.imgMetodoDePago.image = [[UIImage systemImageNamed:icono]
            imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    self.filaMetodoDePago.hidden = NO;
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
    [self.btnCancelTrip setTitle:[LanguageHelper getStringWithKey:@"k_s10_cancelar_viaje"
                                                     defaultValue:@"Cancelar viaje"]
                        forState:UIControlStateNormal];
    self.btnCancelTrip.titleLabel.font = [UIFont fontWithName:@"NotoSans-Bold" size:15]
                                         ?: [UIFont boldSystemFontOfSize:15];
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

    /*
     El aspa para cerrarlo.

     No la tenia: el aviso solo se iba cuando el contador de no leidos llegaba a cero, o
     sea cuando el pasajero ABRIA el chat. Si no queria contestar en ese momento, se
     quedaba ahi -- parpadeando -- sin manera de quitarlo.
     */
    self.btnCerrarAviso = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.btnCerrarAviso setImage:[[UIImage systemImageNamed:@"xmark"]
                                   imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
                         forState:UIControlStateNormal];
    self.btnCerrarAviso.tintColor = [UIColor colorWithWhite:0.55 alpha:1];
    [self.btnCerrarAviso addTarget:self action:@selector(cerrarAvisoDeMensaje)
                  forControlEvents:UIControlEventTouchUpInside];
    [self.viewMessage addSubview:self.btnCerrarAviso];
}

/**
 Esconde el aviso sin dar los mensajes por leidos.

 El numero se queda en el boton de chat: el pasajero ha dicho "ahora no", no "ya lo vi". Si
 llega un mensaje NUEVO el aviso vuelve a salir, porque entonces hay algo que el todavia no
 sabe.
 */
-(void)cerrarAvisoDeMensaje {
    if (timerBlink) {
        [timerBlink invalidate];
        timerBlink = nil;
    }
    _viewMessage.backgroundColor = UIColor.whiteColor;
    self.viewMessage.hidden = YES;
    _avisoCerradoConNMensajes = [_firebaseUnReadChat messageCount];
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
            [self encuadrarRecorrido:polyline];
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


/**
 Encuadra el viaje con los puntos que SIEMPRE se conocen.

 El encuadre que habia salia de directionSource.northeast/southwest, que los rellena el
 servicio de rutas: si la ruta no llego -- y no llega mientras el conductor no suba su
 rastro, que es de donde sale temp_route_data -- esos valores se quedan a cero y la
 camara no tiene a donde ir. Por eso el mapa enseñaba un trozo de calle cualquiera.

 Aqui se usan el coche, la recogida y el destino, que vienen en el propio viaje. Antes
 de arrancar interesan coche y recogida (por donde viene a buscarte); con el viaje en
 marcha, coche y destino (cuanto queda).

 Se rehace solo al CAMBIAR de estado. En cada refresco de la ruta el mapa daria un tiron
 cada pocos segundos.
 */
-(void)encuadrarViajeEnCurso {
    NSString *estado = isEmpty(self.currentTrip.trip_Status);
    if (estado.length == 0 || [estado isEqualToString:ultimoEstadoEncuadrado]) {
        return;
    }

    NSMutableArray *puntos = [[NSMutableArray alloc] init];
    CLLocationCoordinate2D coche = CLLocationCoordinate2DMake(self.currentTrip.driver.lat,
                                                              self.currentTrip.driver.lng);
    if (coche.latitude != 0 || coche.longitude != 0) {
        [puntos addObject:[NSValue valueWithMKCoordinate:coche]];
    }

    BOOL enMarcha = ([estado isEqualToString:TS_BEGIN] || [estado isEqualToString:TS_PICKED]);
    CLLocationCoordinate2D otro = enMarcha
        ? CLLocationCoordinate2DMake([self.currentTrip.trip_drop_lat doubleValue],
                                     [self.currentTrip.trip_drop_long doubleValue])
        : CLLocationCoordinate2DMake([self.currentTrip.trip_pick_lat doubleValue],
                                     [self.currentTrip.trip_pick_long doubleValue]);
    if (otro.latitude != 0 || otro.longitude != 0) {
        [puntos addObject:[NSValue valueWithMKCoordinate:otro]];
    }

    if (puntos.count == 0) {
        return;
    }
    ultimoEstadoEncuadrado = estado;

    MKMapRect rect = MKMapRectNull;
    for (NSValue *v in puntos) {
        MKMapPoint p = MKMapPointForCoordinate([v MKCoordinateValue]);
        MKMapRect suyo = MKMapRectMake(p.x, p.y, 0.1, 0.1);
        rect = MKMapRectIsNull(rect) ? suyo : MKMapRectUnion(rect, suyo);
    }
    if (MKMapRectIsNull(rect)) {
        return;
    }
    // Con un solo punto el rectangulo es un pixel: se le da un cuadro de ~1,2 km.
    if (puntos.count == 1) {
        CLLocationCoordinate2D unico = [[puntos firstObject] MKCoordinateValue];
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(unico, 1200, 1200);
        [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
        return;
    }

    [self.mapView setVisibleMapRect:rect edgePadding:[self margenesDelMapa] animated:YES];
}

/** El hueco que deja la hoja, para que nada quede detras de ella. */
-(UIEdgeInsets)margenesDelMapa {
    CGFloat alto = self.view.bounds.size.height;
    CGFloat tapaLaHoja = MAX(0, alto - self.sheetTop) + 16;
    if (tapaLaHoja > alto * 0.66f) {
        tapaLaHoja = alto * 0.66f;
    }
    return UIEdgeInsetsMake(self.view.safeAreaInsets.top + 70, 40, tapaLaHoja, 40);
}

/**
 Encaja el recorrido entero en el trozo de mapa que se ve.

 Estaba comentado, asi que la ruta se dibujaba pero la camara no se movia: el pasajero
 veia un trozo de calle sin saber por donde va. El margen de abajo es el alto de la
 hoja, que tapa mas de media pantalla; contra la vista entera el recorrido quedaria
 detras de ella.

 Solo se encuadra una vez por trazado. Si se hiciera en cada refresco, el mapa daria un
 tiron cada pocos segundos y no habria manera de mirar nada con calma.
 */
-(void)encuadrarRecorrido:(MKPolyline *)recorrido {
    if (recorrido == nil || yaEncuadreElRecorrido) {
        return;
    }
    MKMapRect rect = [recorrido boundingMapRect];
    if (MKMapRectIsNull(rect) || rect.size.width == 0) {
        return;
    }
    yaEncuadreElRecorrido = YES;

    [self.mapView setVisibleMapRect:rect edgePadding:[self margenesDelMapa] animated:YES];
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

    // "2.80 (105)", como Android. Antes salia el redondeo a entero y a secas, que no
    // se leia como una valoracion sino como un numero suelto al lado del nombre.
    float rating=self.currentTrip.driver.rating;
    int cuantas = (int)self.currentTrip.driver.ratingCount;
    if (rating > 0) {
        _starRatingLbl.text = (cuantas > 0)
            ? [NSString stringWithFormat:@"%.2f (%d)", rating, cuantas]
            : [NSString stringWithFormat:@"%.2f", rating];
        self.imgEstrella.hidden = NO;
    } else {
        _starRatingLbl.text = @"";
        self.imgEstrella.hidden = YES;
    }
    self.viewRating.hidden = (rating <= 0);

    self.lblDireccionRecogida.text = isEmpty(self.currentTrip.trip_pick_loc);
    [self actualizarCategoriaDelConductor];
    [self actualizarTarjetaDePagoMovil];
    [self actualizarFilaMetodoDePago];
    [self actualizarFilaMetodoDePago];
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

    [self encuadrarViajeEnCurso];

    /*
     El importe, y debajo en bolivares. Como Android.

     Las dos lineas van con tamaños distintos -- el importe manda -- y por eso se monta
     con texto atribuido: un UILabel solo sabe de UNA fuente para todo su contenido.
     Antes era una sola cadena con salto de linea a 22 puntos, que en una fila de 52 no
     entraba y el label recortaba con puntos suspensivos: se veia "$2.10..." y los
     bolivares no aparecian nunca.
     */
    if (self.currentTrip.trip_fare.length > 0) {
        CityModel *ciudad = [CityModel getCityByCityId:self.currentTrip.city_id];
        float importe = [self.currentTrip.trip_fare floatValue];
        NSString *enDolares = [Utilities formatAmountAndCurrency:importe currency:ciudad.city_cur]
                              ?: self.currentTrip.trip_fare;

        UIColor *oscuro = [UIColor colorNamed:@"color_app_label"]
            ?: [UIColor colorWithRed:0x21/255.0 green:0x21/255.0 blue:0x21/255.0 alpha:1];
        NSMutableParagraphStyle *parrafo = [[NSMutableParagraphStyle alloc] init];
        parrafo.alignment = NSTextAlignmentRight;

        NSMutableAttributedString *texto = [[NSMutableAttributedString alloc] initWithString:enDolares
            attributes:@{ NSFontAttributeName: ([UIFont fontWithName:@"NotoSans-Bold" size:22]
                                                ?: [UIFont boldSystemFontOfSize:22]),
                          NSForegroundColorAttributeName: oscuro,
                          NSParagraphStyleAttributeName: parrafo }];

        float tasa = [ConstantModel tasaDolarALocal];
        if (tasa > 0) {
            NSNumberFormatter *formato = [[NSNumberFormatter alloc] init];
            formato.numberStyle = NSNumberFormatterDecimalStyle;
            formato.minimumFractionDigits = 2;
            formato.maximumFractionDigits = 2;
            NSString *enLocal = [formato stringFromNumber:@(importe * tasa)] ?: @"";
            [texto appendAttributedString:[[NSAttributedString alloc] initWithString:
                [NSString stringWithFormat:@"\nBs %@", enLocal]
                attributes:@{ NSFontAttributeName: ([UIFont fontWithName:@"NotoSans-Bold" size:17]
                                                    ?: [UIFont boldSystemFontOfSize:17]),
                              NSForegroundColorAttributeName: oscuro,
                              NSParagraphStyleAttributeName: parrafo }]];
        }

        self.paymentAmountLabel.numberOfLines = 2;
        self.paymentAmountLabel.adjustsFontSizeToFitWidth = YES;
        self.paymentAmountLabel.minimumScaleFactor = 0.6f;
        self.paymentAmountLabel.attributedText = texto;
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
                
                // Solo al TERMINAR desaparece el boton. Con el viaje en marcha se queda,
                // como en Android.
                if ([self.currentTrip.trip_Status isEqualToString:TS_END]) {
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
    self.lblDireccionRecogida.text = isEmpty(self.currentTrip.trip_pick_loc);
    [self actualizarCategoriaDelConductor];
    [self actualizarTarjetaDePagoMovil];
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
        // El rotulo del OTP es SOLO eso. El estado del viaje vive en su propia
        // etiqueta y no se pisa: antes los dos compartian esta y el estado se perdia.
        self.statusLabel.text = [LanguageHelper getStringWithKey:@"k_r8_s8_give_number_to_driver" defaultValue:@"Dale este número a tu conductor"];
        self.statusLabel.font = [UIFont fontWithName:@"NotoSans-Regular" size:11]
                                ?: [UIFont systemFontOfSize:11];
        self.statusLabel.textColor = [UIColor colorWithRed:0x69/255.0 green:0x69/255.0 blue:0x69/255.0 alpha:1];
        self.statusLabel.hidden = NO;

        // Pastilla amarilla, como el trip_otp de Android. En azul sobre blanco parecia
        // un enlace; aqui es el dato que hay que leerle al conductor.
        // attributedText va ANTES que text, no despues: ponerlo a nil borra lo que el
        // label tenga puesto, y estando debajo se llevaba por delante el OTP que se
        // acababa de escribir. La pastilla salia amarilla y vacia.
        self.lbTripOtp.attributedText = nil;
        self.lbTripOtp.text = [NSString stringWithFormat:@"%@%@",
            [LanguageHelper getStringWithKey:@"k_93_s4_otp" defaultValue:@"OTP: "], otpNumber];
        self.lbTripOtp.font = [UIFont fontWithName:@"NotoSans-Bold" size:18] ?: [UIFont boldSystemFontOfSize:18];
        self.lbTripOtp.textColor = [UIColor blackColor];
        self.lbTripOtp.textAlignment = NSTextAlignmentCenter;
        self.lbTripOtp.backgroundColor = [UIColor colorNamed:@"app_theame"]
            ?: [UIColor colorWithRed:0xEB/255.0 green:0xB5/255.0 blue:0x18/255.0 alpha:1];
        self.lbTripOtp.layer.cornerRadius = 17;
        self.lbTripOtp.clipsToBounds = YES;
        self.lbTripOtp.numberOfLines = 1;
        self.lbTripOtp.hidden = NO;
        [self.view setNeedsLayout];
    }else{
        self.statusLabel.text = @"";
        self.statusLabel.hidden = YES;
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

    // --- La hoja, medida por su contenido ---
    //
    // Antes empezaba en un 44% fijo de la pantalla. Con la tarjeta de pago movil
    // puesta -- que aparece o no segun el metodo de pago -- el boton de cancelar se
    // salia por abajo. Ahora se suma lo que ocupa cada pieza y la hoja arranca donde
    // haga falta, que es lo que hace Android con wrap_content pegado al fondo.
    CGFloat cardW  = w - pad * 2;
    CGFloat safeB  = self.view.safeAreaInsets.bottom;

    CGFloat alto = 10 + 5 + 12;                       // asa

    CGFloat altoCabecera = 48;                        // los botones mandan
    CGFloat altoEstado   = 22;
    CGFloat altoOtpLbl   = 16;
    CGFloat altoOtp      = 34;
    BOOL hayOtp = !self.lbTripOtp.isHidden;
    CGFloat altoColumna = altoEstado + (hayOtp ? 2 + altoOtpLbl + 6 + altoOtp : 0);
    CGFloat bloqueCabecera = MAX(altoCabecera, altoColumna);
    alto += bloqueCabecera + 8 + 1 + 8;               // + separador

    CGFloat altoTarjetaConductor = 66;
    alto += altoTarjetaConductor;

    BOOL hayPagoMovil = !self.tarjetaPagoMovil.isHidden;
    // Se MIDE el texto en vez de suponer cuanto ocupa. Noto Sans tiene las metricas
    // altas -- tres lineas de 12 puntos pasan de 48 -- y cada vez que puse un numero
    // a ojo se quedaba corto por poco y cortaba el telefono, que es justo el dato con
    // el que se hace la transferencia.
    CGFloat altoPagoMovil = [self altoDeLaTarjetaDePagoMovilConAncho:cardW];
    if (hayPagoMovil) {
        alto += 6 + altoPagoMovil;
    }

    CGFloat altoDirecciones = 62;
    alto += 6 + altoDirecciones;

    CGFloat altoMetodo = 46;
    BOOL hayMetodo = !self.filaMetodoDePago.isHidden;
    if (hayMetodo) {
        alto += 6 + altoMetodo;
    }

    // Dos lineas de verdad: el importe y debajo los bolivares. Con 52 no cabian y el
    // label recortaba la segunda, que es lo que dejaba "$2.10..." con puntos suspensivos.
    CGFloat altoPrecio = 64;
    alto += 6 + altoPrecio;

    CGFloat altoCancelar = 44;
    BOOL hayCancelar = !self.btnCancelTrip.isHidden;
    if (hayCancelar) {
        alto += 8 + altoCancelar;
    }
    alto += 14 + safeB;

    // Nunca mas de dos tercios de pantalla: el mapa tiene que seguir contando algo.
    CGFloat arriba = h - alto;
    if (arriba < h * 0.30f) {
        arriba = h * 0.30f;
    }
    self.sheetTop = arriba;
    self.sheetPanel.frame = CGRectMake(0, self.sheetTop, w, h - self.sheetTop);

    CGFloat gpsSize = 44;
    self.btnGps.frame = CGRectMake(w - pad - gpsSize,
                                   self.sheetTop - 12 - gpsSize,
                                   gpsSize, gpsSize);
    self.btnGps.layer.cornerRadius = gpsSize / 2;

    self.dragHandle.frame = CGRectMake((w - 36) / 2, 10, 36, 5);

    // --- Cabecera: estado y OTP a la izquierda, acciones a la derecha ---
    CGFloat y = 10 + 5 + 12;
    CGFloat btnSize = 44;
    CGFloat shareSz = 22;

    CGFloat xAccion = w - pad - btnSize;
    CGFloat yAccion = y + (bloqueCabecera - btnSize) / 2.0;
    self.actionButton.frame = CGRectMake(xAccion, yAccion, btnSize, btnSize);
    self.actionButton.layer.cornerRadius = btnSize / 2;

    CGFloat xChat = xAccion - 12 - btnSize;
    self.btnChatConductor.frame = CGRectMake(xChat, yAccion, btnSize, btnSize);

    CGFloat xShare = xChat - 12 - shareSz;
    self.shareButton.frame = CGRectMake(xShare, yAccion + (btnSize - shareSz) / 2, shareSz, shareSz);

    CGFloat anchoColumna = xShare - pad - 8;
    self.lblEstadoViaje.frame = CGRectMake(pad, y, anchoColumna, altoEstado);
    if (hayOtp) {
        self.statusLabel.frame = CGRectMake(pad, CGRectGetMaxY(self.lblEstadoViaje.frame) + 2,
                                            anchoColumna, altoOtpLbl);
        self.lbTripOtp.frame   = CGRectMake(pad, CGRectGetMaxY(self.statusLabel.frame) + 6,
                                            anchoColumna, altoOtp);
    } else {
        self.statusLabel.frame = CGRectZero;
        self.lbTripOtp.frame   = CGRectZero;
    }
    y += bloqueCabecera + 8;

    self.separadorCabecera.frame = CGRectMake(pad, y, cardW, 1);
    y += 1 + 8;

    // --- Tarjeta del conductor ---
    self.driverCard.frame = CGRectMake(pad, y, cardW, altoTarjetaConductor);

    CGFloat avatarSz = 42;
    self.imgDriver.frame = CGRectMake(10, (altoTarjetaConductor - avatarSz) / 2, avatarSz, avatarSz);
    self.imgDriver.layer.cornerRadius = avatarSz / 2;

    CGFloat anchoCategoria = 62;
    CGFloat xCategoria = cardW - 10 - anchoCategoria;
    self.imgCategoria.frame = CGRectMake(xCategoria + (anchoCategoria - 34) / 2, 8, 34, 26);
    self.lblCategoria.frame = CGRectMake(xCategoria, 36, anchoCategoria, 16);
    // El hueco del vehiculo que habia antes lo ocupa ahora la categoria.
    self.imageVehicle.frame = CGRectZero;
    self.lblCarNumber.frame = CGRectZero;

    CGFloat xDatos = 10 + avatarSz + 12;
    CGFloat anchoDatos = xCategoria - xDatos - 8;
    self.imgEstrella.frame   = CGRectMake(xDatos, 11, 12, 12);
    self.starRatingLbl.frame = CGRectMake(xDatos + 16, 9, anchoDatos - 16, 16);
    self.lblDriverName.frame = CGRectMake(xDatos, 26, anchoDatos, 18);
    self.lbCarName.frame     = CGRectMake(xDatos, 44, anchoDatos, 14);
    y += altoTarjetaConductor;

    // --- Pago movil ---
    if (hayPagoMovil) {
        y += 6;
        self.tarjetaPagoMovil.frame = CGRectMake(pad, y, cardW, altoPagoMovil);
        UIView *tituloPM = [self.tarjetaPagoMovil viewWithTag:903];
        tituloPM.frame = CGRectMake(10, 8, cardW - 20, 12);
        self.lblPagoMovilDatos.frame = CGRectMake(10, 26, cardW - 20, altoPagoMovil - 26 - 10);
        y += altoPagoMovil;
    }

    // --- Direcciones ---
    y += 6;
    self.destinationCard.frame = CGRectMake(pad, y, cardW, altoDirecciones);
    CGFloat pinSz = 16;
    UIView *pinBtn = [self.destinationCard viewWithTag:901];
    pinBtn.frame = CGRectMake(cardW - 10 - pinSz, 10, pinSz, pinSz);
    CGFloat anchoDir = cardW - 20 - pinSz - 8;
    self.destinationLabel.frame      = CGRectMake(10, 8, anchoDir, 32);
    self.lblDireccionRecogida.frame  = CGRectMake(10, 42, anchoDir, 14);
    y += altoDirecciones;

    // --- Metodo de pago ---
    if (hayMetodo) {
        y += 6;
        self.filaMetodoDePago.frame = CGRectMake(pad, y, cardW, altoMetodo);
        UIView *rotuloPago = [self.filaMetodoDePago viewWithTag:904];
        rotuloPago.frame = CGRectMake(16, 0, 160, altoMetodo);
        CGFloat anchoTexto = 140;
        self.lblMetodoDePago.frame = CGRectMake(cardW - 16 - anchoTexto, 0, anchoTexto, altoMetodo);
        self.imgMetodoDePago.frame = CGRectMake(self.lblMetodoDePago.frame.origin.x - 6 - 18,
                                                (altoMetodo - 18) / 2.0, 18, 18);
        y += altoMetodo;
    } else {
        self.filaMetodoDePago.frame = CGRectZero;
    }

    // --- Precio ---
    y += 6;
    self.paymentRow.frame = CGRectMake(pad, y, cardW, altoPrecio);
    self.paymentRow.layer.cornerRadius = 12;
    self.paymentRow.clipsToBounds = YES;
    UIView *payLabel = [self.paymentRow viewWithTag:902];
    payLabel.frame = CGRectMake(16, 0, 130, altoPrecio);
    CGFloat anchoImporte = cardW - 16 - 130 - 16 - 8;
    self.paymentAmountLabel.frame = CGRectMake(cardW - 16 - anchoImporte, 0, anchoImporte, altoPrecio);
    y += altoPrecio;

    // --- Cancelar ---
    if (hayCancelar) {
        y += 8;
        self.btnCancelTrip.frame = CGRectMake(pad, y, cardW, altoCancelar);
    } else {
        self.btnCancelTrip.frame = CGRectZero;
    }

    /*
     Aviso de mensaje: flota dentro de la hoja, escondido por defecto.

     Va DEBAJO del separador de la cabecera. Estaba clavado en y=27, que es justo donde vive
     el OTP: el aviso lo tapaba entero, y como encima no se podia cerrar, el pasajero se
     quedaba sin poder leerle el codigo al conductor.
     */
    CGFloat bannerH = 64;
    CGFloat bannerW = cardW;
    CGFloat yAviso = CGRectGetMaxY(self.separadorCabecera.frame) + 10;
    self.viewMessage.frame = CGRectMake(pad, yAviso, bannerW, bannerH);
    CGFloat msgAvatarSz = 40;
    self.msgAvatarView.frame = CGRectMake(12, (bannerH - msgAvatarSz) / 2, msgAvatarSz, msgAvatarSz);
    self.msgAvatarView.layer.cornerRadius = msgAvatarSz / 2;
    CGFloat msgTextX = 12 + msgAvatarSz + 8;
    // 56 y no 48: el aspa de la esquina se come una parte del ancho de arriba.
    CGFloat msgTextW = bannerW - msgTextX - 56;
    self.msgDriverNameLabel.frame = CGRectMake(msgTextX, 12, msgTextW, 18);
    self.msgPreviewLabel.frame    = CGRectMake(msgTextX, CGRectGetMaxY(self.msgDriverNameLabel.frame) + 4, msgTextW, 16);
    CGFloat phoneSz = 36;
    self.btnPhone.frame = CGRectMake(bannerW - 12 - phoneSz, (bannerH - phoneSz) / 2, phoneSz, phoneSz);
    self.btnCerrarAviso.frame = CGRectMake(bannerW - 30, 4, 26, 26);

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

    [self actualizarEstadoDelViaje:status];

    if ([status isEqualToString:TS_BEGIN]||[status isEqualToString:TS_PICKED]) {
        // Trip started / rider picked up — show drop leg: SOS button, no OTP, no cancel
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
        // El boton de cancelar SIGUE ahi con el viaje empezado. Android no lo esconde
        // nunca -- en "begin" lo pone explicitamente visible -- y tiene sentido: que el
        // viaje haya arrancado no quiere decir que ya no se pueda echar atras.
        self.btnCancelTrip.hidden = NO;
        self.lbTripOtp.hidden = YES;
    } else {
        // Driver on the way / arrived — showTripOtpOnUi coloca el rotulo y la pastilla
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

/**
 El titulo de estado, con los mismos textos que Android.

 Van en su propia etiqueta y no en la del OTP: son dos cosas distintas y el pasajero
 necesita las dos a la vez -- en que punto va el viaje, y que numero dar.
 */
- (void)actualizarEstadoDelViaje:(NSString *)estado {
    NSString *texto;
    if ([estado isEqualToString:TS_BEGIN] || [estado isEqualToString:TS_PICKED]) {
        texto = [LanguageHelper getStringWithKey:@"k_r5_s8_on_ride" defaultValue:@"Ya estás en camino..."];
    } else if ([estado isEqualToString:TS_ARRIVE]) {
        texto = [LanguageHelper getStringWithKey:@"k_r6_s8_driver_arrived" defaultValue:@"¡El conductor ha llegado!"];
    } else {
        texto = [LanguageHelper getStringWithKey:@"k_ride_progress_status_arriving"
                                    defaultValue:@"El conductor está en camino"];
    }
    self.lblEstadoViaje.text = texto;
}

/**
 Los datos bancarios del conductor, solo si el viaje se paga por pago movil.

 Se sigue aceptando "card" ademas de "pago movil" por los viajes VIEJOS: los que se
 pidieron desde un iPhone antes de que esto se escribiera bien ya tienen "Card"
 guardado en la base y no se van a corregir solos.
 */
- (void)actualizarTarjetaDePagoMovil {
    self.tarjetaPagoMovil.hidden = YES;

    NSString *modo = [isEmpty(self.currentTrip.trip_pay_mode) lowercaseString];
    BOOL esPagoMovil = ([modo containsString:@"pago movil"]
                        || [modo containsString:@"pago móvil"]
                        || [modo isEqualToString:@"card"]);
    if (!esPagoMovil) {
        return;
    }

    NSString *datos = isEmpty(self.currentTrip.driver.d_bank_info);
    if (![datos hasPrefix:@"{"]) {
        return;
    }
    NSError *error = nil;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[datos dataUsingEncoding:NSUTF8StringEncoding]
                                                        options:0
                                                          error:&error];
    if (error != nil || ![json isKindOfClass:[NSDictionary class]]) {
        return;
    }

    NSString *banco   = isEmpty([json objectForKey:@"bank"]);
    NSString *tipoId  = isEmpty([json objectForKey:@"idType"]);
    NSString *numeroId = isEmpty([json objectForKey:@"idNumber"]);
    NSString *telefono = isEmpty([json objectForKey:@"phone"]);
    if (banco.length == 0 && numeroId.length == 0 && telefono.length == 0) {
        return;
    }

    self.lblPagoMovilDatos.text = [NSString stringWithFormat:@"Banco: %@\nID: %@ %@\nTel: %@",
                                   banco.length ? banco : @"N/A",
                                   tipoId, numeroId,
                                   telefono.length ? telefono : @"N/A"];
    self.tarjetaPagoMovil.hidden = NO;
    [self.view setNeedsLayout];
}

/** La categoria del viaje: icono y nombre, a la derecha de la tarjeta del conductor. */
- (void)actualizarCategoriaDelConductor {
    CategoryModel *cat = [CategoryModel getCategoryByid:self.currentTrip.driver.category_id];
    if (cat == nil) {
        self.lblCategoria.text = @"";
        return;
    }
    self.lblCategoria.text = [isEmpty(cat.cat_name) uppercaseString];
    UIImage *respaldo = [[cat.cat_name lowercaseString] containsString:@"moto"]
        ? [UIImage imageNamed:@"ic_vehicle_moto"]
        : ([UIImage imageNamed:@"ic_vehicle_car"] ?: [UIImage imageNamed:@"map_car_icon"]);
    [self.imgCategoria sd_setImageWithURL:[NSURL URLWithString:isEmpty(cat.cat_image_path)]
                         placeholderImage:respaldo];
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
        // El boton de cancelar se queda. Android no lo esconde en ningun momento del
        // viaje; aqui se escondia justo al arrancar, que es cuando el pasajero todavia
        // puede querer echarse atras.
        _btnCancelTrip.hidden=NO;
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
        // El numero tambien encima del boton de chat, no solo en el aviso: el aviso se
        // va solo y el boton se queda, que es lo que hace Android con viewChatBadge.
        int sinLeer = [_firebaseUnReadChat messageCount];
        self.btnChatConductor.badgeString = (sinLeer > 0)
            ? [NSString stringWithFormat:@"%d", sinLeer] : nil;
        // Si lo cerro a mano, no vuelve hasta que llegue un mensaje NUEVO. Sin esto, el
        // siguiente refresco del contador lo sacaba otra vez y el aspa no servia de nada.
        if (sinLeer > 0 && sinLeer <= _avisoCerradoConNMensajes) {
            // El numero del boton ya quedo puesto arriba; aqui solo se evita el aviso.
            return;
        }
        if (sinLeer == 0) {
            _avisoCerradoConNMensajes = 0;
        }
        if(sinLeer>0) {
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
