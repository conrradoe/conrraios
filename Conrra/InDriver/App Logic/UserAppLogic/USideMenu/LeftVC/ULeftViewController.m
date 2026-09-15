//
//  LeftViewController.m
//  TempProject
//
//  Created by Appicial Taxi App Soutions on 09/02/17.
//  Copyright © 2023 Appicial Taxi App Soutions. All rights reserved.
//

#import "ULeftViewController.h"
#import "SideMenuCell.h"
#import "ConstantModel.h"
#import "EditProfileViewController.h"
#import "WebCallConstants.h"
#import "AppDelegate.h"
#import "UIImageView+WebCache.h"
#import "WebCallConstants.h"
#import <GIKit/GIKit.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "AboutUsViewController.h"
#import "UIView+UpdateAutoLayoutConstraints.h"
#import "ChatViewController.h"
#import "OtpSignInViewController.h"
#import "UpdateUserCurrentLocation.h"
#import "SettingsModel.h"
#import "PlanesViewController.h"
#import "Utilities.h"
#import "RecargasViewController.h"
#import "NSString+URLEncoding.h"
#import <Conrra-Swift.h>
#import "UHomeViewController.h"
#import "UTripHistoryViewController.h"

@interface ULeftViewController ()<MFMailComposeViewControllerDelegate, UTripHistoryViewControllerDelegate> {
    UILabel  *_ratingLabel;
    UILabel  *_balanceAmountLabel;
    UILabel  *_balanceRateLabel;
    UILabel  *_lblRotuloBolivares;
    UIImageView *_palomitaVerificado;
}
@end

@implementation ULeftViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupMenuUI];
    [self setUIfields];
    [self setprofileImage];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onConstantCalled)    name:@"constant_api_called"         object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setprofileImage)    name:@"change_profile"              object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(apiCallFaliuer:)    name:@"api_error_handle"            object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setUIfields)        name:@"NotificationOnLanguageChanged" object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setprofileImage];
}

#pragma mark - New programmatic UI setup

- (void)setupMenuUI {
    for (UIView *v in self.view.subviews) { v.hidden = YES; }
    self.view.backgroundColor = [UIColor whiteColor];

    // Round top-right and bottom-right corners of the menu panel
    self.view.layer.cornerRadius = 18;
    if (@available(iOS 11.0, *)) {
        self.view.layer.maskedCorners = kCALayerMaxXMinYCorner | kCALayerMaxXMaxYCorner;
    }
    self.view.clipsToBounds = YES;

    UILayoutGuide *safe = self.view.safeAreaLayoutGuide;

    // Profile image
    UIImageView *profileImg = [[UIImageView alloc] init];
    profileImg.translatesAutoresizingMaskIntoConstraints = NO;
    profileImg.contentMode  = UIViewContentModeScaleAspectFill;
    profileImg.clipsToBounds = YES;
    profileImg.layer.cornerRadius = 28;
    profileImg.image = [UIImage imageNamed:@"Profile Icon Crop Image"];
    [self.view addSubview:profileImg];
    _imgProfile = profileImg;

    /*
     La palomita azul de verificado, abajo a la izquierda de la foto.

     Va FUERA de profileImg, no dentro: la foto lleva clipsToBounds para recortarse en
     circulo, y cualquier hija suya se recortaria con ella. Y va despues, para quedar por
     encima -- es el equivalente del bringToFront() que hace Android.

     Abajo a la izquierda porque es donde la pone Android (layout_alignStart +
     layout_alignBottom), no donde suele ir en otras apps.
     */
    UIImageView *palomita = [[UIImageView alloc] init];
    palomita.translatesAutoresizingMaskIntoConstraints = NO;
    palomita.contentMode = UIViewContentModeScaleAspectFit;
    palomita.image = [UIImage systemImageNamed:@"checkmark.seal.fill"];
    palomita.tintColor = [UIColor colorWithRed:0x1D/255.0 green:0x9B/255.0 blue:0xF0/255.0 alpha:1];
    // Circulito blanco detras: sobre una foto oscura la palomita azul se pierde.
    palomita.backgroundColor = [UIColor whiteColor];
    palomita.layer.cornerRadius = 11;
    palomita.clipsToBounds = YES;
    palomita.hidden = YES;
    [self.view addSubview:palomita];
    _palomitaVerificado = palomita;

    // Name label
    UILabel *nameLbl = [[UILabel alloc] init];
    nameLbl.translatesAutoresizingMaskIntoConstraints = NO;
    nameLbl.font          = FONTS_NOTO_BOLD(16);
    nameLbl.textColor     = [UIColor colorNamed:@"color_app_label"] ?: [UIColor blackColor];
    nameLbl.numberOfLines = 1;
    [self.view addSubview:nameLbl];
    _lblName = nameLbl;

    // Mobile / email label
    UILabel *mobileLbl = [[UILabel alloc] init];
    mobileLbl.translatesAutoresizingMaskIntoConstraints = NO;
    mobileLbl.font          = FONTS_NOTO_REGULAR(13);
    mobileLbl.textColor     = [UIColor grayColor];
    mobileLbl.numberOfLines = 1;
    [self.view addSubview:mobileLbl];
    _userMobileLbl = mobileLbl;

    // Rating label  (★ 4.6)
    UILabel *ratingLbl = [[UILabel alloc] init];
    ratingLbl.translatesAutoresizingMaskIntoConstraints = NO;
    ratingLbl.font      = FONTS_NOTO_REGULAR(13);
    ratingLbl.textColor = [UIColor colorNamed:@"app_theame"]
                          ?: [UIColor colorWithRed:235/255.0 green:181/255.0 blue:24/255.0 alpha:1];
    ratingLbl.numberOfLines = 1;
    [self.view addSubview:ratingLbl];
    _ratingLabel = ratingLbl;

    // Settings (gear) button
    UIButton *settingsBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    settingsBtn.translatesAutoresizingMaskIntoConstraints = NO;
    UIImage *gearImg = [[UIImage imageNamed:@"menu_icon_settings"]
                        imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [settingsBtn setImage:gearImg forState:UIControlStateNormal];
    settingsBtn.tintColor = [UIColor colorWithWhite:0.3 alpha:1];
    [settingsBtn addTarget:self action:@selector(onSettingButtonTap:)
          forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:settingsBtn];
    _btnSetting = settingsBtn;

    // Balance section: "Saldo Disponible: $0.00"
    UILabel *saldoTitleLbl = [[UILabel alloc] init];
    saldoTitleLbl.translatesAutoresizingMaskIntoConstraints = NO;
    saldoTitleLbl.text      = [LanguageHelper getStringWithKey:@"k_s10_balance_available" defaultValue:@"Saldo Disponible:"];
    saldoTitleLbl.font      = FONTS_NOTO_BOLD(13);
    saldoTitleLbl.textColor = [UIColor colorNamed:@"color_app_label"] ?: [UIColor blackColor];
    [self.view addSubview:saldoTitleLbl];

    UILabel *balanceLbl = [[UILabel alloc] init];
    balanceLbl.translatesAutoresizingMaskIntoConstraints = NO;
    balanceLbl.text          = @"$0.00";
    balanceLbl.font          = FONTS_NOTO_BOLD(15);
    balanceLbl.textColor     = [UIColor colorWithRed:34/255.0 green:167/255.0 blue:93/255.0 alpha:1];
    balanceLbl.textAlignment = NSTextAlignmentRight;
    [self.view addSubview:balanceLbl];
    _balanceAmountLabel = balanceLbl;

    UILabel *tasaTitleLbl = [[UILabel alloc] init];
    tasaTitleLbl.translatesAutoresizingMaskIntoConstraints = NO;
    // "Monto en bs", como Android: la linea de abajo NO es la tasa, es el mismo saldo
    // escrito en bolivares. Enseñaba "Tasa de cambio / --" porque leia currency_conversion
    // a pelo, que en esta instalacion viene vacia.
    tasaTitleLbl.text      = [LanguageHelper getStringWithKey:@"k_s10_amount_in_bs" defaultValue:@"Monto en bs"];
    _lblRotuloBolivares    = tasaTitleLbl;
    tasaTitleLbl.font      = FONTS_NOTO_REGULAR(12);
    tasaTitleLbl.textColor = [UIColor grayColor];
    [self.view addSubview:tasaTitleLbl];

    UILabel *rateAmtLbl = [[UILabel alloc] init];
    rateAmtLbl.translatesAutoresizingMaskIntoConstraints = NO;
    rateAmtLbl.text          = @"Bs. 0.00";
    rateAmtLbl.font          = FONTS_NOTO_REGULAR(12);
    rateAmtLbl.textColor     = [UIColor grayColor];
    rateAmtLbl.textAlignment = NSTextAlignmentRight;
    [self.view addSubview:rateAmtLbl];
    _balanceRateLabel = rateAmtLbl;

    // Main separator (below balance section)
    UIView *mainSep = [[UIView alloc] init];
    mainSep.translatesAutoresizingMaskIntoConstraints = NO;
    mainSep.backgroundColor = [UIColor colorWithWhite:0.88 alpha:1];
    [self.view addSubview:mainSep];

    // TableView (menu items)
    UITableView *tv = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    tv.translatesAutoresizingMaskIntoConstraints = NO;
    tv.delegate       = self;
    tv.dataSource     = self;
    tv.separatorStyle = UITableViewCellSeparatorStyleNone;
    tv.separatorInset = UIEdgeInsetsZero;
    tv.backgroundColor  = [UIColor whiteColor];
    tv.showsVerticalScrollIndicator = NO;
    tv.bounces = NO;
    UINib *nib = [UINib nibWithNibName:@"SideMenuCell" bundle:nil];
    [tv registerNib:nib forCellReuseIdentifier:@"SideMenuCell"];
    [self.view addSubview:tv];
    _tableView = tv;

    // Bottom container
    UIView *bottomView = [[UIView alloc] init];
    bottomView.translatesAutoresizingMaskIntoConstraints = NO;
    bottomView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bottomView];

    // Thin top separator for bottom area
    UIView *btmSep = [[UIView alloc] init];
    btmSep.translatesAutoresizingMaskIntoConstraints = NO;
    btmSep.backgroundColor = [UIColor colorWithWhite:0.88 alpha:1];
    [bottomView addSubview:btmSep];

    // --- Yellow "Aplica para Conductor" button ---
    UIButton *driverBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    driverBtn.translatesAutoresizingMaskIntoConstraints = NO;
    driverBtn.backgroundColor = [UIColor colorNamed:@"app_theame"];
    driverBtn.layer.cornerRadius = 14;
    driverBtn.clipsToBounds = YES;
    [driverBtn addTarget:self action:@selector(onDriverSwitchButtonTap:)
        forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:driverBtn];
    _btnSwitchDriver = driverBtn;

    // Label inside driver button (reassign IBOutlet so onConstantCalled sets text correctly)
    UILabel *driverLbl = [[UILabel alloc] init];
    driverLbl.translatesAutoresizingMaskIntoConstraints = NO;
    driverLbl.font              = FONTS_NOTO_BOLD(17);
    driverLbl.textColor         = [UIColor colorWithWhite:0.1 alpha:1];
    driverLbl.textAlignment     = NSTextAlignmentCenter;
    driverLbl.userInteractionEnabled = NO;
    [driverBtn addSubview:driverLbl];
    _lblCasDriverText = driverLbl;

    // --- Gray "Cerrar sesión" button ---
    UIButton *logoutBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    logoutBtn.translatesAutoresizingMaskIntoConstraints = NO;
    logoutBtn.backgroundColor   = [UIColor colorWithWhite:0.93 alpha:1];
    logoutBtn.layer.cornerRadius = 14;
    logoutBtn.clipsToBounds = YES;
    [logoutBtn setTitle:[LanguageHelper getStringWithKey:@"k_3_s4_logout" defaultValue:@"Cerrar sesión"] forState:UIControlStateNormal];
    [logoutBtn setTitleColor:[UIColor colorWithWhite:0.25 alpha:1] forState:UIControlStateNormal];
    logoutBtn.titleLabel.font = FONTS_NOTO_BOLD(17);
    UIImage *logoutIcon = [[UIImage imageNamed:@"menu_icon_logout"]
                           imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    if (!logoutIcon) {
        if (@available(iOS 13, *)) {
            logoutIcon = [[UIImage systemImageNamed:@"arrow.right.circle.fill"]
                          imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        }
    }
    if (logoutIcon) {
        [logoutBtn setImage:logoutIcon forState:UIControlStateNormal];
        logoutBtn.tintColor = [UIColor colorWithWhite:0.45 alpha:1];
        logoutBtn.semanticContentAttribute = UISemanticContentAttributeForceRightToLeft;
        logoutBtn.imageEdgeInsets  = UIEdgeInsetsMake(0, 10, 0, -10);
        logoutBtn.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 10);
    }
    [logoutBtn addTarget:self action:@selector(onLogutButtonTap:)
        forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:logoutBtn];
    _btnLogout = logoutBtn;

    // Constraints

    // Profile image
    [NSLayoutConstraint activateConstraints:@[
        [profileImg.topAnchor     constraintEqualToAnchor:safe.topAnchor constant:24],
        [profileImg.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [profileImg.widthAnchor   constraintEqualToConstant:56],
        [profileImg.heightAnchor  constraintEqualToConstant:56],

        [_palomitaVerificado.leadingAnchor constraintEqualToAnchor:profileImg.leadingAnchor],
        [_palomitaVerificado.bottomAnchor  constraintEqualToAnchor:profileImg.bottomAnchor],
        [_palomitaVerificado.widthAnchor   constraintEqualToConstant:22],
        [_palomitaVerificado.heightAnchor  constraintEqualToConstant:22],
    ]];

    // Settings button (top-right)
    [NSLayoutConstraint activateConstraints:@[
        [settingsBtn.topAnchor      constraintEqualToAnchor:safe.topAnchor constant:24],
        [settingsBtn.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-16],
        [settingsBtn.widthAnchor    constraintEqualToConstant:32],
        [settingsBtn.heightAnchor   constraintEqualToConstant:32],
    ]];

    // Name
    [NSLayoutConstraint activateConstraints:@[
        [nameLbl.topAnchor      constraintEqualToAnchor:profileImg.topAnchor],
        [nameLbl.leadingAnchor  constraintEqualToAnchor:profileImg.trailingAnchor constant:12],
        [nameLbl.trailingAnchor constraintLessThanOrEqualToAnchor:settingsBtn.leadingAnchor constant:-8],
    ]];

    // Mobile
    [NSLayoutConstraint activateConstraints:@[
        [mobileLbl.topAnchor      constraintEqualToAnchor:nameLbl.bottomAnchor constant:4],
        [mobileLbl.leadingAnchor  constraintEqualToAnchor:nameLbl.leadingAnchor],
        [mobileLbl.trailingAnchor constraintLessThanOrEqualToAnchor:settingsBtn.leadingAnchor constant:-8],
    ]];

    // Rating
    [NSLayoutConstraint activateConstraints:@[
        [ratingLbl.topAnchor      constraintEqualToAnchor:mobileLbl.bottomAnchor constant:4],
        [ratingLbl.leadingAnchor  constraintEqualToAnchor:nameLbl.leadingAnchor],
        [ratingLbl.trailingAnchor constraintLessThanOrEqualToAnchor:settingsBtn.leadingAnchor constant:-8],
    ]];

    // Saldo Disponible row — clears both image bottom and text stack bottom
    NSLayoutConstraint *saldoFromImg  = [saldoTitleLbl.topAnchor
                                         constraintGreaterThanOrEqualToAnchor:profileImg.bottomAnchor
                                         constant:14];
    NSLayoutConstraint *saldoFromText = [saldoTitleLbl.topAnchor
                                         constraintGreaterThanOrEqualToAnchor:ratingLbl.bottomAnchor
                                         constant:14];
    // Low-priority pull that prefers the rating label anchor (compact layout)
    NSLayoutConstraint *saldoPull = [saldoTitleLbl.topAnchor
                                     constraintEqualToAnchor:ratingLbl.bottomAnchor
                                     constant:14];
    saldoPull.priority = 749;
    [NSLayoutConstraint activateConstraints:@[
        saldoFromImg, saldoFromText, saldoPull,
        [saldoTitleLbl.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
    ]];

    [NSLayoutConstraint activateConstraints:@[
        [balanceLbl.centerYAnchor  constraintEqualToAnchor:saldoTitleLbl.centerYAnchor],
        [balanceLbl.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-16],
        [balanceLbl.leadingAnchor  constraintGreaterThanOrEqualToAnchor:saldoTitleLbl.trailingAnchor constant:8],
    ]];

    // Tasa de cambio row
    [NSLayoutConstraint activateConstraints:@[
        [tasaTitleLbl.topAnchor     constraintEqualToAnchor:saldoTitleLbl.bottomAnchor constant:6],
        [tasaTitleLbl.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
    ]];

    [NSLayoutConstraint activateConstraints:@[
        [rateAmtLbl.centerYAnchor  constraintEqualToAnchor:tasaTitleLbl.centerYAnchor],
        [rateAmtLbl.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-16],
        [rateAmtLbl.leadingAnchor  constraintGreaterThanOrEqualToAnchor:tasaTitleLbl.trailingAnchor constant:8],
    ]];

    // Main separator
    [NSLayoutConstraint activateConstraints:@[
        [mainSep.topAnchor      constraintEqualToAnchor:tasaTitleLbl.bottomAnchor constant:16],
        [mainSep.leadingAnchor  constraintEqualToAnchor:self.view.leadingAnchor],
        [mainSep.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [mainSep.heightAnchor   constraintEqualToConstant:1],
    ]];

    // Bottom container (pin to view bottom, height self-determined by content)
    [NSLayoutConstraint activateConstraints:@[
        [bottomView.leadingAnchor  constraintEqualToAnchor:self.view.leadingAnchor],
        [bottomView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [bottomView.bottomAnchor   constraintEqualToAnchor:self.view.bottomAnchor],
    ]];

    // Bottom separator
    [NSLayoutConstraint activateConstraints:@[
        [btmSep.topAnchor      constraintEqualToAnchor:bottomView.topAnchor],
        [btmSep.leadingAnchor  constraintEqualToAnchor:bottomView.leadingAnchor],
        [btmSep.trailingAnchor constraintEqualToAnchor:bottomView.trailingAnchor],
        [btmSep.heightAnchor   constraintEqualToConstant:1],
    ]];

    // Driver button
    [NSLayoutConstraint activateConstraints:@[
        [driverBtn.topAnchor      constraintEqualToAnchor:btmSep.bottomAnchor constant:16],
        [driverBtn.leadingAnchor  constraintEqualToAnchor:bottomView.leadingAnchor constant:20],
        [driverBtn.trailingAnchor constraintEqualToAnchor:bottomView.trailingAnchor constant:-20],
        [driverBtn.heightAnchor   constraintEqualToConstant:56],
    ]];

    // Driver label (centered inside button)
    [NSLayoutConstraint activateConstraints:@[
        [driverLbl.centerXAnchor  constraintEqualToAnchor:driverBtn.centerXAnchor],
        [driverLbl.centerYAnchor  constraintEqualToAnchor:driverBtn.centerYAnchor],
        [driverLbl.leadingAnchor  constraintGreaterThanOrEqualToAnchor:driverBtn.leadingAnchor  constant:16],
        [driverLbl.trailingAnchor constraintLessThanOrEqualToAnchor:driverBtn.trailingAnchor constant:-16],
    ]];

    // Logout button
    [NSLayoutConstraint activateConstraints:@[
        [logoutBtn.topAnchor      constraintEqualToAnchor:driverBtn.bottomAnchor constant:12],
        [logoutBtn.leadingAnchor  constraintEqualToAnchor:bottomView.leadingAnchor constant:20],
        [logoutBtn.trailingAnchor constraintEqualToAnchor:bottomView.trailingAnchor constant:-20],
        [logoutBtn.heightAnchor   constraintEqualToConstant:56],
        [logoutBtn.bottomAnchor   constraintEqualToAnchor:bottomView.bottomAnchor constant:-20],
    ]];

    // TableView (fills space between main separator and bottom container)
    [NSLayoutConstraint activateConstraints:@[
        [tv.topAnchor      constraintEqualToAnchor:mainSep.bottomAnchor],
        [tv.leadingAnchor  constraintEqualToAnchor:self.view.leadingAnchor],
        [tv.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [tv.bottomAnchor   constraintEqualToAnchor:bottomView.topAnchor],
    ]];
}

#pragma mark - UI text / data

- (void)setUIfields {
    [self onConstantCalled];
    [self.btAboutUs setTitle:[LanguageHelper getStringWithKey:@"k_r1_s3_about_us"] forState:UIControlStateNormal];
    [self.btPrivacyPolicy setTitle:[LanguageHelper getStringWithKey:@"k_r2_s3_privacy_policy"] forState:UIControlStateNormal];
    // Logout button title kept as set in setupMenuUI / use language key if available
    NSString *logoutTitle = [LanguageHelper getStringWithKey:@"k_3_s4_logout" defaultValue:@"Cerrar sesión"];
    [self.btnLogout setTitle:logoutTitle forState:UIControlStateNormal];
}

- (void)apiCallFaliuer:(NSNotification *)notification {
    NSLog(@"apiCallFaliuer : %@", notification.userInfo);
    id delegate = [UIApplication sharedApplication].delegate;
    if ([delegate isKindOfClass:[AppDelegate class]] && [(AppDelegate *)delegate switchingToDriverMode]) return;
    NSDictionary *error = [notification.userInfo objectForKey:@"error_object"];
    if (error) {
        if ([error isKindOfClass:[NSDictionary class]]) {
            if ([[error objectForKey:@"code"] intValue] == 401) {
                NSDictionary *dict = defaults_object(P_USER_DICT);
                if (dict) {
                    defaults_remove(P_USER_DICT);
                    [[NSNotificationCenter defaultCenter] removeObserver:self];
                    [[UpdateUserCurrentLocation sharedInstance] stopUpdateCurrentLocation];
                    [self afterLogutWork];
                }
            }
        }
    }
}

- (void)onConstantCalled {
    ConstantModel *constantModel = [ConstantModel getConstantsObject];

    /*
     El orden es el de Android (MainScreenActivity.manageLeftslider), a proposito.

     No es cosmetica: un pasajero que usa las dos apps busca "Recargar" donde lo dejo la
     ultima vez, y encontrarlo en otro sitio hace que parezca otra aplicacion.
     */

    // Tus viajes
    self.arrSideMenu = [[NSMutableArray alloc] initWithObjects:
        @{@"title": [LanguageHelper getStringWithKey:@"k_6_s4_a1_your_rides" defaultValue:@"Tus viajes"],
          @"icon":  @"menu_icon_trips",
          @"identifier": @"UTripHistoryViewController"},
        nil];

    // Sitios
    //
    // Se llama "Sitios" para el pasajero; en el panel y en la API la familia se llama
    // "planes". Solo aparece si el backend enciende enable_sitios, la misma constante que
    // mira Android en Controller.isSitiosEnabled.
    //
    // El icono es el de estrella porque no hay uno propio todavia y es de la misma familia
    // de iconos de linea que el resto del menu, asi que el tinte gris le sienta igual. Si
    // se dibuja uno propio, basta cambiar este nombre.
    if ([PlanesViewController estaHabilitada]) {
        [self.arrSideMenu addObject:@{
            @"title": [LanguageHelper getStringWithKey:@"k_s10_planes_menu" defaultValue:@"Sitios"],
            @"icon":  @"menu_icon_star",
            @"identifier": @"planes_sitios"
        }];
    }

    /*
     Contacto Pago Movil.

     Es la misma pantalla que antes se llamaba aqui "Contacto SOS": guarda los contactos de
     emergencia Y los datos de pago movil. Se le pone el rotulo de Android porque es lo que
     el pasajero viene a hacer aqui el 99% de las veces -- registrar su banco y su telefono
     para cobrar y pagar -- y "SOS" no lo sugiere en absoluto.
     */
    [self.arrSideMenu addObject:@{
        @"title": [LanguageHelper getStringWithKey:@"k_s10_contacto_pago_movil"
                                      defaultValue:@"Contacto Pago Móvil"],
        @"icon":  @"menu_icon_sos",
        @"identifier": @"SettingViewController"
    }];

    /*
     Mi Billetera y Recargar, con el mismo interruptor que Android (ewl).

     "Mi wallet" abria un WebView apuntando a google.com con un TODO al lado, y la pantalla
     de billetera del pasajero -- UWalletViewController -- ya existia en el storyboard sin
     que nada la abriera desde el menu. Ahora apunta donde debe.
     */
    if ([constantModel getCValueFK:ckey_ewl]) {
        [self.arrSideMenu addObject:@{
            @"title": [LanguageHelper getStringWithKey:@"k_1_s10_wallet" defaultValue:@"Mi Billetera"],
            @"icon":  @"menu_icon_wallet",
            @"identifier": StoryBoardUtiles.WALLET_VC
        }];
        [self.arrSideMenu addObject:@{
            // No hay recurso propio para Recargar, y repetir el icono de la billetera
            // dejaria dos filas seguidas indistinguibles de un vistazo. El simbolo del
            // sistema entra por el camino de respaldo de la celda.
            @"title": [LanguageHelper getStringWithKey:@"k_s10_recarga_menu" defaultValue:@"Recargar"],
            @"icon":  @"menu_icon_recargas",
            @"sfSymbol": @"plus.circle",
            @"identifier": @"recargas"
        }];
    }

    // Referidos
    if ([constantModel getCValueFK:ckey_erf]) {
        [self.arrSideMenu addObject:@{
            @"title": [LanguageHelper getStringWithKey:@"k_s10_referral" defaultValue:@"Referidos"],
            @"icon":  @"referrals",
            @"identifier": @"ReferralViewController"
        }];
    }

    // Notificaciones
    if ([constantModel getCValueFK:ckey_en]) {
        [self.arrSideMenu addObject:@{
            @"title": [LanguageHelper getStringWithKey:@"k_15_s4_a1_notifications"
                                          defaultValue:@"Notificaciones"],
            @"icon":  @"menu_icon_notifications",
            @"identifier": @"NotificationViewController",
            @"storyboard": StoryBoardUtiles.STORYBOARD_MAIN
        }];
    }

    // Info de tarifas
    if ([constantModel getCValueFK:ckey_efi]) {
        [self.arrSideMenu addObject:@{
            @"title": [LanguageHelper getStringWithKey:@"k_2_s10_fare_info"
                                          defaultValue:@"Información de tarifas"],
            @"icon":  @"fare_info",
            @"identifier": @"FareInfoViewController"
        }];
    }

    // Metodo de pago
    if ([constantModel getCValueFK:ckey_est]) {
        [self.arrSideMenu addObject:@{
            @"title": [LanguageHelper getStringWithKey:@"k_3_s5_payemnt" defaultValue:@"Método de pago"],
            @"icon":  @"ic_payment_method",
            @"identifier": @"PaymentMethodListViewController"
        }];
    }

    // Lenguaje
    if ([[LanguageHelper sharedInstance] getLanguageList].count > Default_City_Count) {
        [self.arrSideMenu addObject:@{
            @"title": [LanguageHelper getStringWithKey:@"k_12_s4_a1_language" defaultValue:@"Idioma"],
            @"icon":  @"menu_icon_language",
            @"identifier": @"LanguageViewController",
            @"storyboard": StoryBoardUtiles.STORYBOARD_MAIN
        }];
    }

    // Comparte
    if (constantModel.enable_share) {
        [self.arrSideMenu addObject:@{
            @"title": [LanguageHelper getStringWithKey:@"k_9_s4_a1_share" defaultValue:@"Comparte"],
            @"icon":  @"menu_icon_share",
            @"identifier": SIDE_MENU_SHARE
        }];
    }

    // Contáctanos
    if (constantModel.enable_contactus) {
        [self.arrSideMenu addObject:@{
            @"title": [LanguageHelper getStringWithKey:@"k_11_s4_a1_contact_us" defaultValue:@"Contáctanos"],
            @"icon":  @"menu_icon_contact",
            @"identifier": SIDE_MENU_SUPPORT
        }];
    }

    // Chatea con nosotros
    if (constantModel.enable_chat) {
        [self.arrSideMenu addObject:@{
            @"title": [LanguageHelper getStringWithKey:@"k_11_s4_chat_us" defaultValue:@"Chatea con nosotros"],
            @"icon":  @"menu_icon_chat",
            @"identifier": @"chat_with_us"
        }];
    }

    // Legal
    if ([constantModel getCValueFK:ckey_elg]) {
        [self.arrSideMenu addObject:@{
            @"title": [LanguageHelper getStringWithKey:@"k_2_s10_legal" defaultValue:@"Legal"],
            @"icon":  @"legal",
            @"identifier": @"LegalViewController"
        }];
    }

    // Legacy About Us / Privacy Policy buttons (hidden in new design; honour feature flags)
    if (constantModel.enable_aboutus == NO) {
        [self.btAboutUs hideByHeight:YES];
    } else {
        [self.btAboutUs setHidden:NO];
        [self.btAboutUs setConstraintConstant:30 forAttribute:NSLayoutAttributeHeight];
    }
    if (constantModel.enable_pp == NO) {
        [self.btPrivacyPolicy hideByHeight:YES];
    } else {
        [self.btPrivacyPolicy setHidden:NO];
        [self.btPrivacyPolicy setConstraintConstant:30 forAttribute:NSLayoutAttributeHeight];
    }

    // Driver button text
    NSDictionary *dictUser = defaults_object(P_USER_DICT_LOGGED);
    BOOL is_driver = [[dictUser objectForKey:@"is_driver"] boolValue];
    self.lblCasDriverText.text = is_driver
        ? [LanguageHelper getStringWithKey:@"k_s4_cas_d"  defaultValue:@"Continúa como Conductor"]
        : [LanguageHelper getStringWithKey:@"k_s4_apf_d"  defaultValue:@"Aplica para Conductor"];

    UINib *nib = [UINib nibWithNibName:@"SideMenuCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"SideMenuCell"];
    [self.tableView reloadData];
}

- (void)setThemeConstants {}

- (void)setprofileImage {
    NSDictionary *dict1 = [[NSUserDefaults standardUserDefaults] objectForKey:P_USER_DICT_LOGGED];
    _lblName.text = [NSString stringWithFormat:@"%@ %@",
                     [dict1 objectForKey:P_U_FNAME],
                     [dict1 objectForKey:P_U_LNAME]];
    if (IS_PHONE_VERIFICATION == 1) {
        _userMobileLbl.text = [NSString stringWithFormat:@"+%@%@",
                               [dict1 objectForKey:P_C_CODE],
                               [dict1 objectForKey:P_U_MOBILE]];
    } else {
        _userMobileLbl.text = isEmpty([dict1 objectForKey:P_EMAIL]);
    }

    // Rating — read from P_USER_DICT (same source as Mi Perfil screen)
    NSDictionary *userDict = [[NSUserDefaults standardUserDefaults] objectForKey:P_USER_DICT];
    NSString *rating = [userDict objectForKey:@"rating"] ?: [dict1 objectForKey:@"rating"];
    if (!rating || [rating floatValue] <= 0) rating = @"0.0";
    UIColor *starYellow = [UIColor colorWithRed:235/255.0 green:181/255.0 blue:24/255.0 alpha:1];
    UIImage *starImg = nil;
    if (@available(iOS 13, *)) {
        UIImageSymbolConfiguration *cfg = [UIImageSymbolConfiguration configurationWithPointSize:19.5
                                                                                          weight:UIImageSymbolWeightRegular];
        UIImage *base = [UIImage systemImageNamed:@"star.fill" withConfiguration:cfg];
        UIGraphicsBeginImageContextWithOptions(base.size, NO, 0);
        [base drawInRect:CGRectMake(0, 0, base.size.width, base.size.height)];
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        CGContextSetBlendMode(ctx, kCGBlendModeSourceIn);
        [starYellow setFill];
        CGContextFillRect(ctx, CGRectMake(0, 0, base.size.width, base.size.height));
        starImg = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    if (starImg) {
        NSTextAttachment *att = [[NSTextAttachment alloc] init];
        att.image = starImg;
        CGFloat cap = _ratingLabel.font.capHeight;
        CGFloat size = cap * 1.5;
        CGFloat baseline = (cap - size) / 2.0;
        att.bounds = CGRectMake(0, baseline, size, size);
        NSMutableAttributedString *full = [[NSMutableAttributedString alloc]
            initWithAttributedString:[NSAttributedString attributedStringWithAttachment:att]];
        [full appendAttributedString:[[NSAttributedString alloc]
            initWithString:[NSString stringWithFormat:@" %@", rating]
                attributes:@{ NSFontAttributeName: _ratingLabel.font,
                               NSForegroundColorAttributeName: [UIColor colorNamed:@"color_app_label"] ?: [UIColor blackColor] }]];
        _ratingLabel.attributedText = full;
    } else {
        _ratingLabel.text = [NSString stringWithFormat:@"★ %@", rating];
        _ratingLabel.textColor = starYellow;
    }

    NSString *profile = [dict1 objectForKey:P_PROFILE_IMAGE_PATH];
    if (profile.length > 0) {
        NSString *profilePath = [NSString stringWithFormat:@"%@%@", url_base_images, profile];
        [_imgProfile sd_setImageWithURL:[NSURL URLWithString:profilePath]
                       placeholderImage:[UIImage imageNamed:@"Profile Icon Crop Image"]];
    }

    // Wallet balance
    float walletBalance = [[userDict objectForKey:P_USER_WAlLET_AMOUNT] floatValue];
    _balanceAmountLabel.text = [NSString stringWithFormat:@"$%.2f", walletBalance];

    // El mismo saldo en bolivares. Si el servidor no publica tasa se esconde la fila
    // entera, como hace Android, en vez de dejar un guion suelto.
    NSString *enBolivares = [Utilities montoEnBolivares:walletBalance];
    _balanceRateLabel.text = enBolivares;
    _balanceRateLabel.hidden = (enBolivares.length == 0);
    _lblRotuloBolivares.hidden = (enBolivares.length == 0);

    _palomitaVerificado.hidden = ![self estaVerificado:dict1] && ![self estaVerificado:userDict];
}

/**
 Si la cuenta esta verificada.

 Se miran muchos nombres de campo a proposito, igual que Android en la anotacion
 @SerializedName de uIsVerified: el backend no ha sido consistente con como se llama, y
 quedarse solo con "u_is_verified" dejaba la palomita apagada para cuentas que SI estan
 verificadas. Tambien vale el codigo postal con "v" o "verified", que es el apaño que ya
 existia en Android para las cuentas antiguas.
 */
- (BOOL)estaVerificado:(NSDictionary *)dict {
    if (![dict isKindOfClass:[NSDictionary class]]) {
        return NO;
    }
    NSArray *campos = @[@"u_is_verified", @"is_verified", @"verified", @"u_verified",
                        @"isVerified", @"is_user_verified", @"v_status", @"u_verified_status",
                        @"verified_status", @"verify_status", @"u_verify_status",
                        @"is_verified_passenger", @"verified_passenger",
                        @"is_rider_verified", @"is_verified_user"];
    NSArray *afirmativos = @[@"1", @"true", @"yes", @"y", @"verified", @"success",
                             @"active", @"v", @"verified_passenger"];

    for (NSString *campo in campos) {
        id crudo = [dict objectForKey:campo];
        if (crudo == nil) {
            continue;
        }
        NSString *valor = [[NSString stringWithFormat:@"%@", crudo]
                           stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        // El servidor manda a veces el numero como decimal: "1.0".
        if ([valor hasSuffix:@".0"]) {
            valor = [valor substringToIndex:valor.length - 2];
        }
        for (NSString *afirmativo in afirmativos) {
            if ([valor caseInsensitiveCompare:afirmativo] == NSOrderedSame) {
                return YES;
            }
        }
    }

    for (NSString *campo in @[@"u_zip", @"u_zipcode"]) {
        id crudo = [dict objectForKey:campo];
        NSString *valor = [NSString stringWithFormat:@"%@", crudo ?: @""];
        if ([valor caseInsensitiveCompare:@"v"] == NSOrderedSame ||
            [valor caseInsensitiveCompare:@"verified"] == NSOrderedSame) {
            return YES;
        }
    }
    return NO;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView { return 1; }

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _arrSideMenu.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SideMenuCell *cell = (SideMenuCell *)[tableView dequeueReusableCellWithIdentifier:@"SideMenuCell"];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"SideMenuCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }

    NSDictionary *item = [_arrSideMenu objectAtIndex:indexPath.row];
    NSString *title = [item objectForKey:@"title"];
    cell.lblMenu.text = title;
    // 16pt medium weight
    cell.lblMenu.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];

    // El globito de avisos se busca por IDENTIFICADOR, no por el rotulo. Comparando
    // rotulos, cambiar la traduccion -- o darle un texto por defecto a la fila, como ahora
    // -- dejaba el globito sin salir nunca, sin que nada pareciera roto.
    if ([[item objectForKey:@"identifier"] isEqualToString:@"NotificationViewController"]) {
        if ([APP_DELEGATE notificationCount] > 0) {
            [cell.viewNotification setHidden:NO];
            cell.lblNotificationCount.text = [NSString stringWithFormat:@"%d", [APP_DELEGATE notificationCount]];
        } else {
            cell.lblNotificationCount.text = @"";
            [cell.viewNotification setHidden:YES];
        }
    } else {
        [cell.viewNotification setHidden:YES];
    }

    // El icono, y si el recurso no existe el simbolo del sistema que la fila indique.
    // El menu del conductor ya lo hacia asi; aqui una fila sin recurso salia sin icono y
    // el rotulo quedaba desalineado con el resto, sin ningun aviso de que faltaba nada.
    UIImage *iconImage = [UIImage imageNamed:[item objectForKey:@"icon"]];
    if (iconImage == nil) {
        NSString *simbolo = [item objectForKey:@"sfSymbol"];
        if (simbolo.length > 0) {
            iconImage = [UIImage systemImageNamed:simbolo
                                withConfiguration:[UIImageSymbolConfiguration
                                                   configurationWithWeight:UIImageSymbolWeightRegular]];
        }
    }
    UIImage *image = [iconImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    // gray-500 (#6B7280)
    cell.imgIcon.tintColor = [UIColor colorWithRed:107/255.0 green:114/255.0 blue:128/255.0 alpha:1];
    [cell.imgIcon setImage:image];
    cell.selectionStyle  = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    cell.viewSeparator.hidden = YES;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 42;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *sideOption = [[_arrSideMenu objectAtIndex:indexPath.row] objectForKey:@"identifier"];

    if ([sideOption isEqualToString:SIDE_MENU_LOGOUT]) {
        [self LogoutPressed_isLogout:YES];

    } else if ([sideOption isEqualToString:SIDE_MENU_SHARE]) {
        [self shareApp];

    } else if ([sideOption isEqualToString:@"recargas"]) {
        // No esta en ningun storyboard: se monta a mano, como Sitios.
        [self empujar:[[RecargasViewController alloc] init]];

    } else if ([sideOption isEqualToString:@"planes_sitios"]) {
        [self empujar:[[PlanesViewController alloc] init]];

    } else if ([sideOption isEqualToString:@"chat_with_us"]) {
        AboutUsViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"AboutUsViewController"];
        vc.isCustomUrl  = YES;
        vc.customTitle  = [LanguageHelper getStringWithKey:@"k_11_s4_chat_us" defaultValue:@"Chatea con nosotros"];
        vc.customUrl    = isEmpty([SettingsModel getSettignsObject].enable_chat);
        [self empujar:vc];

    } else if ([sideOption isEqualToString:SIDE_MENU_DEACTIVATE]) {
        [self LogoutPressed_isLogout:NO];

    } else if ([sideOption isEqualToString:SIDE_MENU_SUPPORT]) {
        [self openMailComposer];

    } else {
        [self setViewControllers:sideOption
                   storyboardName:[[_arrSideMenu objectAtIndex:indexPath.row] objectForKey:@"storyboard"]];
    }
}

#pragma mark - Logout

- (void)LogoutPressed_isLogout:(BOOL)isLogout {
    UIAlertController *alert = [UIAlertController
        alertControllerWithTitle:isLogout ? @"" : [LanguageHelper getStringWithKey:@"k_r29_s4_deactivate_acc"]
        message:isLogout ? [LanguageHelper getStringWithKey:@"k_54_s4_do_you_want_to_exit_now"] : [LanguageHelper getStringWithKey:@"k_r29_s4_deactivate_acc"]
        preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *yes = [UIAlertAction
        actionWithTitle:[LanguageHelper getStringWithKey:@"k_21_s4_yes"]
        style:UIAlertActionStyleDefault
        handler:^(UIAlertAction *a) { [self LogoutPressed]; }];
    UIAlertAction *no = [UIAlertAction
        actionWithTitle:[LanguageHelper getStringWithKey:@"k_22_s4_no"]
        style:UIAlertActionStyleDefault
        handler:^(UIAlertAction *a) {}];
    [alert addAction:yes];
    [alert addAction:no];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)LogoutPressed {
    NSString *tripId = defaults_object(TRIP_ID);
    if ([tripId intValue] > 0) {
        UIAlertController *alert = [UIAlertController
            alertControllerWithTitle:@""
            message:[LanguageHelper getStringWithKey:@"Con not logout during trip"]
            preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *no = [UIAlertAction
            actionWithTitle:[LanguageHelper getStringWithKey:@"k_22_s4_no"]
            style:UIAlertActionStyleDefault
            handler:^(UIAlertAction *a) {}];
        [alert addAction:no];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    NSDictionary *dict1 = [[NSUserDefaults standardUserDefaults] objectForKey:P_USER_DICT];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{
        P_USER_ID           : [dict1 objectForKey:P_USER_ID],
        P_USER_IS_AVAILABLE : @"0"
    }];
    [UtilityClass setLH:NO wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
    [GIC mkwu:UPDATE_USER_PROFILE d:dict isa:NO cb:^(id results, NSError *error) {
        if ([[[results objectForKey:P_STATUS] uppercaseString] isEqualToString:@"OK"]) {}
        [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
        [self afterLogutWork];
    }];
}

- (void)afterLogutWork {
    defaults_remove(P_API_KEY);
    defaults_remove(TRIP_ID);
    defaults_remove(TRIP_STATUS);
    defaults_remove(P_USER_DICT);
    defaults_remove(P_USER_DICT_LOGGED);
    defaults_remove(P_IS_USER_LOGIN);
    [UtilityClass setLH:YES wt:@""];
    [UtilityClass SetAllLoadersHidden];
    UINavigationController *nav = IS_PHONE_VERIFICATION == 1
        ? [StoryBoardUtiles navigationPhone]
        : [StoryBoardUtiles navigationEmail];
    UIWindow *window = UIApplication.sharedApplication.delegate.window;
    window.rootViewController = nav;
    [nav setNavigationBarHidden:YES];
    [self.navigationController popToRootViewControllerAnimated:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"driver_logout" object:nil];
}

#pragma mark - Navigation helpers

/**
 Empuja una pantalla montada a mano y cierra el menu.

 Las pantallas que no viven en ningun storyboard -- Sitios, Recargas -- repetian estas
 cuatro lineas cada una, y son cuatro lineas que hay que acertar enteras: si se olvida el
 hideLeftView, la pantalla se abre con el menu todavia encima.
 */
- (void)empujar:(UIViewController *)vc {
    MainViewController *mainVC = (MainViewController *)self.sideMenuController;
    UINavigationController *navVC = (UINavigationController *)mainVC.rootViewController;
    [navVC pushViewController:vc animated:YES];
    [mainVC hideLeftViewAnimated:YES completionHandler:nil];
}

- (void)setViewControllers:(NSString *)sender storyboardName:(NSString *)storyboardName {
    MainViewController *mainVC = (MainViewController *)self.sideMenuController;
    UINavigationController *navVC = (UINavigationController *)mainVC.rootViewController;
    if (storyboardName.length == 0) { storyboardName = StoryBoardUtiles.STORYBOARD_USER; }
    UIViewController *vc = [StoryBoardUtiles viewContollerWithIdentifier:sender name:storyboardName];
    if ([sender isEqualToString:@"UTripHistoryViewController"]) {
        ((UTripHistoryViewController *)vc).delegate = self;
    }
    [navVC popToRootViewControllerAnimated:NO];
    NSTimeInterval delay = 0.1;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [navVC pushViewController:vc animated:YES];
        [mainVC hideLeftViewAnimated:YES completionHandler:nil];
    });
}

#pragma mark - IBActions (still wired in storyboard; also wired programmatically)

- (IBAction)onSettingButtonTap:(id)sender {
    [self setViewControllers:StoryBoardUtiles.UEDIT_PROFILE
               storyboardName:StoryBoardUtiles.STORYBOARD_SIGNUP];
}

- (IBAction)onLogutButtonTap:(id)sender {
    [self LogoutPressed_isLogout:YES];
}

- (IBAction)onAboutUs:(id)sender {
    [self openWebUrl:YES];
}

- (IBAction)onPrivacyPloicy:(id)sender {
    [self openWebUrl:NO];
}

- (void)openWebUrl:(BOOL)isAboutUs {
    MainViewController *mainVC = (MainViewController *)self.sideMenuController;
    UINavigationController *navVC = (UINavigationController *)mainVC.rootViewController;
    AboutUsViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"AboutUsViewController"];
    vc.isAboutUs = isAboutUs;
    [navVC pushViewController:vc animated:YES];
    [mainVC hideLeftViewAnimated:YES completionHandler:nil];
}

- (IBAction)onDriverSwitchButtonTap:(id)sender {
    [self setViewControllers:@"BecomeDriverVC" storyboardName:StoryBoardUtiles.STORYBOARD_USER];
}

#pragma mark - Sharing

- (void)shareApp {
    ConstantModel *constantModel = [ConstantModel getConstantsObject];
    NSString *text = isEmpty(constantModel.share_text);
    UIActivityViewController *activityVC = [[UIActivityViewController alloc]
        initWithActivityItems:@[text] applicationActivities:nil];
    activityVC.excludedActivityTypes = @[
        UIActivityTypeAirDrop, UIActivityTypePrint,
        UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll,
        UIActivityTypeAddToReadingList, UIActivityTypePostToFlickr,
        UIActivityTypePostToVimeo
    ];
    [self presentViewController:activityVC animated:YES completion:nil];
}

#pragma mark - Mail

- (void)openMailComposer {
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mailVC = [[MFMailComposeViewController alloc] init];
        mailVC.mailComposeDelegate = self;
        NSString *supportEmail = isEmpty([ConstantModel getConstantsObject].support_email);
        [mailVC setToRecipients:@[supportEmail]];
        [self presentViewController:mailVC animated:YES completion:nil];
    } else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"googlegmail://"]]) {
        NSString *supportEmail = isEmpty([ConstantModel getConstantsObject].support_email);
        NSString *subject = [LanguageHelper getStringWithKey:@"k_9_s5_support_subject"];
        NSString *gmailURL = [NSString stringWithFormat:@"googlegmail:///co?to=%@&subject=%@",
            [supportEmail stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]],
            [subject      stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:gmailURL] options:@{} completionHandler:nil];
    } else {
        [UtilityClass swa:@"Whoops!" m:[LanguageHelper getStringWithKey:@"k_65_s4_config_mail"] cbt:[LanguageHelper getStringWithKey:@"k_18_s4_Ok"] obt:nil vc:self];
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    if (error) {
        [self showAlert:@"Whoops!" message:[NSString stringWithFormat:@" ERROR %@", error]];
        return;
    }
    [controller dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - URL helper

- (void)openUrl:(NSURL *)url {
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
    } else {
        [UtilityClass swa:nil m:[LanguageHelper getStringWithKey:@"k_r12_s5_url_can_not_open"] cbt:@"Ok" obt:nil vc:self];
    }
}

#pragma mark - UTripHistoryViewControllerDelegate

- (void)onTripCreateSuccessfully:(int)trip {
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{TRIP_ID: @(trip)}];
    [UtilityClass setLH:NO wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
    [GIC mkwerwu:TRIP_GETTRIP d:dict cb:^(id results, NSError *error) {
        [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
        if ([[results objectForKey:P_RESPONSE] isKindOfClass:[NSArray class]]) {
            NSArray *tripArray = [results objectForKey:P_RESPONSE];
            if (tripArray.count > 0) {
                TripModel *currTrip = [[TripModel alloc] initItemWithDict:[tripArray objectAtIndex:0]];
                [self openTripOfferPageForTrip:currTrip];
            }
        }
    }];
}

- (void)openTripOfferPageForTrip:(TripModel *)trip {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        for (UIViewController *vc in [APP_DELEGATE navigationController].viewControllers) {
            if ([vc isKindOfClass:[UHomeViewController class]]) {
                [(UHomeViewController *)vc openTripRequest:trip];
                break;
            }
        }
    });
}

@end
