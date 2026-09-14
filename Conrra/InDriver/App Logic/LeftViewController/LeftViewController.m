//
//  LeftViewController.m
//  TempProject
//
//  Created by Appicial Taxi App Solutions on 09/02/17.
//  Copyright © 2023 Appicial Taxi App Solutions. All rights reserved.
//

#import "LeftViewController.h"
#import "SideMenuCell.h"
#import "EditProfileViewController.h"
#import "WebCallConstants.h"
#import "AppDelegate.h"
#import "UIImageView+WebCache.h"
#import "WebCallConstants.h"
#import "OtpSignInViewController.h"

#import <GIKit/GIKit.h>
#import "UpdateUserCurrentLocation.h"
#import <MessageUI/MFMailComposeViewController.h>
#import "ConstantModel.h"
#import "AboutUsViewController.h"
#import "UIView+UpdateAutoLayoutConstraints.h"
#import "SettingsModel.h"
#import "UserProfile.h"
#import "CityModel.h"
#import "Utilities.h"

@interface LeftViewController ()<MFMailComposeViewControllerDelegate> {
    UILabel *_ratingLabel;
    UILabel *_balanceAmountLabel;
    UILabel *_balanceRateLabel;
    UILabel *_availTitleLabel;
}
@end

@implementation LeftViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupMenuUI];
    [self setUIFields];
    [self setprofileImage];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onConstantCalled)     name:@"constant_api_called"           object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setprofileImage)      name:@"change_profile"                object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setSwitchStatusNo)    name:@"change_switch1"                object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setUIFields)          name:@"NotificationOnLanguageChanged" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tripIdChanged)        name:TRIP_ID                          object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(apiCallFaliuer:)      name:@"api_error_handle"              object:nil];
}

-(void) tripIdChanged {}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setprofileImage];
}

#pragma mark - New programmatic UI setup

- (void)setupMenuUI {
    for (UIView *v in [self.view.subviews copy]) { [v removeFromSuperview]; }

    self.view.backgroundColor = [UIColor whiteColor];
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
    self.imgProfile = profileImg;

    // Name label
    UILabel *nameLbl = [[UILabel alloc] init];
    nameLbl.translatesAutoresizingMaskIntoConstraints = NO;
    nameLbl.font          = FONTS_NOTO_BOLD(16);
    nameLbl.textColor     = [UIColor colorNamed:@"color_app_label"] ?: [UIColor blackColor];
    nameLbl.numberOfLines = 1;
    [self.view addSubview:nameLbl];
    self.lblName = nameLbl;

    // Mobile / email label
    UILabel *mobileLbl = [[UILabel alloc] init];
    mobileLbl.translatesAutoresizingMaskIntoConstraints = NO;
    mobileLbl.font          = FONTS_NOTO_REGULAR(13);
    mobileLbl.textColor     = [UIColor grayColor];
    mobileLbl.numberOfLines = 1;
    [self.view addSubview:mobileLbl];
    _userMobile = mobileLbl;

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

    // Balance section
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
    tasaTitleLbl.text      = [LanguageHelper getStringWithKey:@"k_s10_exchange_rate" defaultValue:@"Tasa de cambio"];
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

    // Availability toggle row — 2xl radius, bg #f3f3f3, ~30% smaller
    UIView *toggleRow = [[UIView alloc] init];
    toggleRow.translatesAutoresizingMaskIntoConstraints = NO;
    toggleRow.backgroundColor = [UIColor colorWithRed:243/255.0 green:243/255.0 blue:243/255.0 alpha:1];
    toggleRow.layer.cornerRadius = 10;
    toggleRow.layer.masksToBounds = YES;
    if (@available(iOS 13.0, *)) {
        toggleRow.layer.cornerCurve = kCACornerCurveContinuous;
    }
    [self.view addSubview:toggleRow];

    UISwitch *availSwitch = [[UISwitch alloc] init];
    availSwitch.translatesAutoresizingMaskIntoConstraints = NO;
    availSwitch.transform = CGAffineTransformMakeScale(0.7, 0.7);
    availSwitch.onTintColor = [UIColor colorNamed:@"app_theame"]
                              ?: [UIColor colorWithRed:235/255.0 green:181/255.0 blue:24/255.0 alpha:1];
    if (@available(iOS 14.0, *)) {
        availSwitch.preferredStyle = UISwitchStyleSliding;
    }
    [availSwitch addTarget:self action:@selector(switchChange:)
          forControlEvents:UIControlEventValueChanged];
    [toggleRow addSubview:availSwitch];
    self.switchAvailability = availSwitch;

    _availTitleLabel = [[UILabel alloc] init];
    _availTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _availTitleLabel.text = [LanguageHelper getStringWithKey:@"k_2_s14_go_online_accept_ride" defaultValue:@"Iniciar actividad"];
    _availTitleLabel.font = FONTS_NOTO_BOLD(14);
    _availTitleLabel.textColor = [UIColor colorNamed:@"color_app_label"] ?: [UIColor blackColor];
    _availTitleLabel.numberOfLines = 1;
    [toggleRow addSubview:_availTitleLabel];

    UIButton *availBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    availBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [availBtn setTitle:_availTitleLabel.text forState:UIControlStateNormal];
    [availBtn setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
    availBtn.titleLabel.font = _availTitleLabel.font;
    [availBtn addTarget:self action:@selector(onAvailabilityRowTapped:) forControlEvents:UIControlEventTouchUpInside];
    [toggleRow addSubview:availBtn];
    self.btnAvailability = availBtn;

    // Separator below toggle
    UIView *toggleSep = [[UIView alloc] init];
    toggleSep.translatesAutoresizingMaskIntoConstraints = NO;
    toggleSep.backgroundColor = [UIColor colorWithWhite:0.88 alpha:1];
    [self.view addSubview:toggleSep];

    // TableView
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
    self.tableView = tv;

    // Bottom container
    UIView *bottomView = [[UIView alloc] init];
    bottomView.translatesAutoresizingMaskIntoConstraints = NO;
    bottomView.backgroundColor = [UIColor colorWithRed:243/255.0 green:243/255.0 blue:243/255.0 alpha:1];
    [self.view addSubview:bottomView];

    UIView *btmSep = [[UIView alloc] init];
    btmSep.translatesAutoresizingMaskIntoConstraints = NO;
    btmSep.backgroundColor = [UIColor colorWithWhite:0.88 alpha:1];
    [bottomView addSubview:btmSep];

    // Yellow "Ir a Modo Pasajero" button (icon on right — use asset "menu_icon_passenger_mode")
    UIButton *switchModeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    switchModeBtn.translatesAutoresizingMaskIntoConstraints = NO;
    switchModeBtn.backgroundColor = [UIColor colorNamed:@"app_theame"]
                                    ?: [UIColor colorWithRed:235/255.0 green:181/255.0 blue:24/255.0 alpha:1];
    switchModeBtn.layer.cornerRadius = 14;
    switchModeBtn.clipsToBounds = YES;
    [switchModeBtn setTitle:[LanguageHelper getStringWithKey:@"k_52_s4_passenger_mode" defaultValue:@"Ir a Modo Pasajero"] forState:UIControlStateNormal];
    [switchModeBtn setTitleColor:[UIColor colorWithWhite:0.1 alpha:1] forState:UIControlStateNormal];
    switchModeBtn.titleLabel.font = FONTS_NOTO_BOLD(17);
    UIImage *passengerIcon = [[UIImage imageNamed:@"menu_icon_passenger_mode"]
                              imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    if (!passengerIcon) {
        if (@available(iOS 13, *)) {
            passengerIcon = [[UIImage systemImageNamed:@"person.fill"]
                             imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        }
    }
    if (passengerIcon) {
        [switchModeBtn setImage:passengerIcon forState:UIControlStateNormal];
        switchModeBtn.tintColor = [UIColor colorWithWhite:0.2 alpha:1];
        switchModeBtn.semanticContentAttribute = UISemanticContentAttributeForceRightToLeft;
        switchModeBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 10, 0, -10);
        switchModeBtn.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 10);
    }
    [switchModeBtn addTarget:self action:@selector(onDriverSwitchButtonTap:)
            forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:switchModeBtn];
    self.btnSwitchDriver = switchModeBtn;
    _lblCasDriver = switchModeBtn.titleLabel;

    // Gray "Cerrar sesión" button (icon on right — use asset "menu_icon_logout")
    UIButton *logoutBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    logoutBtn.translatesAutoresizingMaskIntoConstraints = NO;
    logoutBtn.backgroundColor   = [UIColor colorWithWhite:0.93 alpha:1];
    logoutBtn.layer.cornerRadius = 14;
    logoutBtn.clipsToBounds = YES;
    [logoutBtn setTitle:[LanguageHelper getStringWithKey:@"k_3_s4_logout" defaultValue:@"Cerrar sesión"]
               forState:UIControlStateNormal];
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

    // Saldo Disponible row
    NSLayoutConstraint *saldoFromImg  = [saldoTitleLbl.topAnchor
                                         constraintGreaterThanOrEqualToAnchor:profileImg.bottomAnchor
                                         constant:14];
    NSLayoutConstraint *saldoFromText = [saldoTitleLbl.topAnchor
                                         constraintGreaterThanOrEqualToAnchor:ratingLbl.bottomAnchor
                                         constant:14];
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

    // Toggle row — 2xl radius, ~30% smaller, horizontal inset + bottom spacing
    static const CGFloat toggleRowPadH = 11.0;
    static const CGFloat toggleRowHeight = 36.0;
    [NSLayoutConstraint activateConstraints:@[
        [toggleRow.topAnchor      constraintEqualToAnchor:rateAmtLbl.bottomAnchor constant:8],
        [toggleRow.leadingAnchor  constraintEqualToAnchor:self.view.leadingAnchor constant:toggleRowPadH],
        [toggleRow.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-toggleRowPadH],
        [toggleRow.heightAnchor   constraintEqualToConstant:toggleRowHeight],
    ]];
    [NSLayoutConstraint activateConstraints:@[
        [availSwitch.leadingAnchor constraintEqualToAnchor:toggleRow.leadingAnchor constant:11],
        [availSwitch.centerYAnchor  constraintEqualToAnchor:toggleRow.centerYAnchor],
    ]];
    [NSLayoutConstraint activateConstraints:@[
        [_availTitleLabel.leadingAnchor constraintEqualToAnchor:availSwitch.trailingAnchor constant:10],
        [_availTitleLabel.centerYAnchor constraintEqualToAnchor:toggleRow.centerYAnchor],
        [_availTitleLabel.trailingAnchor constraintLessThanOrEqualToAnchor:toggleRow.trailingAnchor constant:-11],
    ]];
    [NSLayoutConstraint activateConstraints:@[
        [availBtn.leadingAnchor constraintEqualToAnchor:_availTitleLabel.leadingAnchor],
        [availBtn.trailingAnchor constraintEqualToAnchor:toggleRow.trailingAnchor],
        [availBtn.topAnchor constraintEqualToAnchor:toggleRow.topAnchor],
        [availBtn.bottomAnchor constraintEqualToAnchor:toggleRow.bottomAnchor],
    ]];

    // Toggle separator — gap below toggle row so space is visible (separator top = toggle bottom + constant)
    static const CGFloat toggleBottomGap = 12.0;
    [NSLayoutConstraint activateConstraints:@[
        [toggleSep.topAnchor      constraintEqualToAnchor:toggleRow.bottomAnchor constant:toggleBottomGap],
        [toggleSep.leadingAnchor  constraintEqualToAnchor:self.view.leadingAnchor],
        [toggleSep.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [toggleSep.heightAnchor   constraintEqualToConstant:1],
    ]];

    // Bottom container (pinned to view bottom)
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

    // "Ir a Modo Pasajero" button
    [NSLayoutConstraint activateConstraints:@[
        [switchModeBtn.topAnchor      constraintEqualToAnchor:btmSep.bottomAnchor constant:16],
        [switchModeBtn.leadingAnchor  constraintEqualToAnchor:bottomView.leadingAnchor constant:20],
        [switchModeBtn.trailingAnchor constraintEqualToAnchor:bottomView.trailingAnchor constant:-20],
        [switchModeBtn.heightAnchor   constraintEqualToConstant:56],
    ]];

    // Logout button
    [NSLayoutConstraint activateConstraints:@[
        [logoutBtn.topAnchor      constraintEqualToAnchor:switchModeBtn.bottomAnchor constant:12],
        [logoutBtn.leadingAnchor  constraintEqualToAnchor:bottomView.leadingAnchor constant:20],
        [logoutBtn.trailingAnchor constraintEqualToAnchor:bottomView.trailingAnchor constant:-20],
        [logoutBtn.heightAnchor   constraintEqualToConstant:56],
        [logoutBtn.bottomAnchor   constraintEqualToAnchor:bottomView.bottomAnchor constant:-20],
    ]];

    // TableView (fills between toggle separator and bottom container)
    [NSLayoutConstraint activateConstraints:@[
        [tv.topAnchor      constraintEqualToAnchor:toggleSep.bottomAnchor],
        [tv.leadingAnchor  constraintEqualToAnchor:self.view.leadingAnchor],
        [tv.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [tv.bottomAnchor   constraintEqualToAnchor:bottomView.topAnchor],
    ]];
}

#pragma mark - UI text / data

-(void)setUIFields {
    [self onConstantCalled];
    [self setSwitchStatusNo];
    [self.btnLogout setTitle:[LanguageHelper getStringWithKey:@"k_3_s4_logout" defaultValue:@"Cerrar sesión"]
                     forState:UIControlStateNormal];
    [self.btnSwitchDriver setTitle:[LanguageHelper getStringWithKey:@"k_52_s4_passenger_mode" defaultValue:@"Ir a Modo Pasajero"]
                            forState:UIControlStateNormal];
}

-(void)apiCallFaliuer:(NSNotification *)notification {
    NSLog(@"apiCallFaliuer : %@", notification.userInfo);
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

-(void)onConstantCalled {
    ConstantModel *constantModel = [ConstantModel getConstantsObject];

    // Mi billetera — always shown; opens original driver wallet screen
    self.arrSideMenu = [[NSMutableArray alloc] initWithObjects:
        @{@"title":      @"Mi billetera",
          @"icon":       @"menu_icon_wallet",
          @"identifier": StoryBoardUtiles.WALLET_VC,
          @"storyboard": StoryBoardUtiles.STORYBOARD_USER},
        // Recargas — webview; dollar icon fallback
        @{@"title":    @"Recargas",
          @"icon":     @"menu_icon_recargas",
          @"sfSymbol": @"dollarsign.circle",
          @"identifier": @"recargas"},
        nil];

    // Mis ganancias — always shown; sfSymbol fallback for missing asset
    [self.arrSideMenu addObject:@{
        @"title":    @"Mis ganancias",
        @"icon":     @"menu_icon_earnings",
        @"sfSymbol": @"dollarsign.circle",
        @"identifier": @"MyEarningsViewController"
    }];

    // Payout
    CityModel *cityModel = [CityModel getCityByCityId:[UserProfile shared].loggedCityID];
    if ([constantModel getCValueFK:ckey_epo] && [cityModel isOnlinePaymentEnabled]) {
        [self.arrSideMenu addObject:@{
            @"title": [LanguageHelper getStringWithKey:@"k_4_s10_payout" defaultValue:@"Mi billetera"],
            @"icon":  @"walletNew",
            @"identifier": StoryBoardUtiles.PAYOUT_VC,
            @"storyboard": StoryBoardUtiles.STORYBOARD_EXTRA_FEATURE
        }];
    }

    // Mis viajes
    [self.arrSideMenu addObject:@{
        @"title": [LanguageHelper getStringWithKey:@"k_6_s4_a1_your_rides" defaultValue:@"Mis viajes"],
        @"icon":  @"menu_icon_trips",
        @"identifier": @"TripHistoryViewController"
    }];

    // Upcoming rides
    if ([constantModel getCValueFK:ckey_rdl]) {
        [self.arrSideMenu addObject:@{
            @"title": [LanguageHelper getStringWithKey:@"k_6_s4_a1_upcmng_rides" defaultValue:@"Próximos viajes"],
            @"icon":  @"ic_schedule",
            @"identifier": @"TripUpCommingViewController",
            @"storyboard": StoryBoardUtiles.STORYBOARD_MAIN
        }];
    }

    // Notificaciones
    if ([constantModel getCValueFK:ckey_en]) {
        [self.arrSideMenu addObject:@{
            @"title": [LanguageHelper getStringWithKey:@"k_15_s4_a1_notifications" defaultValue:@"Notificaciones"],
            @"icon":  @"menu_icon_notifications",
            @"identifier": @"NotificationViewController"
        }];
    }

    // Lenguaje
    if ([[LanguageHelper sharedInstance] getLanguageList].count > Default_City_Count) {
        [self.arrSideMenu addObject:@{
            @"title": [LanguageHelper getStringWithKey:@"k_12_s4_a1_language" defaultValue:@"Lenguaje"],
            @"icon":  @"menu_icon_language",
            @"identifier": @"LanguageViewController"
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

    // Contacto SOS
    [self.arrSideMenu addObject:@{
        @"title": [LanguageHelper getStringWithKey:@"k_s40_contacts_title" defaultValue:@"Contacto SOS"],
        @"icon":  @"menu_icon_sos",
        @"identifier": @"SettingViewController",
        @"storyboard": StoryBoardUtiles.STORYBOARD_USER
    }];

    // Chatea con nosotros
    if (constantModel.enable_chat) {
        [self.arrSideMenu addObject:@{
            @"title": [LanguageHelper getStringWithKey:@"k_11_s4_chat_us" defaultValue:@"Chatea con nosotros"],
            @"icon":  @"menu_icon_chat",
            @"identifier": @"chat_with_us"
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

    // Payment
    if ([constantModel getCValueFK:ckey_est]) {
        [self.arrSideMenu addObject:@{
            @"title": [LanguageHelper getStringWithKey:@"k_3_s5_payemnt" defaultValue:@"Método de pago"],
            @"icon":  @"ic_payment_method",
            @"identifier": @"PaymentMethodListViewController",
            @"storyboard": StoryBoardUtiles.STORYBOARD_USER
        }];
    }

    // Referral
    if ([constantModel getCValueFK:ckey_erf]) {
        [self.arrSideMenu addObject:@{
            @"title": [LanguageHelper getStringWithKey:@"k_s10_referral" defaultValue:@"Referidos"],
            @"icon":  @"referrals",
            @"identifier": @"ReferralViewController"
        }];
    }

    // Single mode
    if ([constantModel getCValueFK:ckey_srd]) {
        [self.arrSideMenu addObject:@{
            @"title": [LanguageHelper getStringWithKey:@"k_14_s4_a1_single_mode" defaultValue:@"Modo individual"],
            @"icon":  @"walletNew1",
            @"identifier": StoryBoardUtiles.HOME_SINGLE_VC
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

    UINib *nib = [UINib nibWithNibName:@"SideMenuCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"SideMenuCell"];
    [self.tableView reloadData];
}

-(void)setThemeConstants {}

-(void)setSwitchStatusNo {
    int availaitity = [[[[NSUserDefaults standardUserDefaults] objectForKey:P_USER_DICT]
                        objectForKey:P_DRIVER_AVAILAILITY] intValue];
    BOOL isAvailable = (availaitity == 1 || availaitity == 2);

    self.switchAvailability.on = isAvailable;
    NSString *title;
    if (self.switchAvailability.isOn) {
        title = [LanguageHelper getStringWithKey:@"k_9_s8_go_offline" defaultValue:@"Detenerme"];
    } else {
        title = [LanguageHelper getStringWithKey:@"k_2_s14_go_online_accept_ride" defaultValue:@"Iniciar actividad"];
    }
    [self.btnAvailability setTitle:title forState:UIControlStateNormal];
    _availTitleLabel.text = title;
}

- (void)onAvailabilityRowTapped:(id)sender {
    [self.switchAvailability setOn:!self.switchAvailability.isOn animated:YES];
    [self switchChange:self.switchAvailability];
}

-(void)setprofileImage {
    NSDictionary *dict1 = [[NSUserDefaults standardUserDefaults] objectForKey:P_USER_DICT];
    _lblName.text = [NSString stringWithFormat:@"%@ %@",
                     [dict1 objectForKey:P_FNAME],
                     [dict1 objectForKey:P_LNAME]];

    if (IS_PHONE_VERIFICATION == 1) {
        _userMobile.text = [NSString stringWithFormat:@"+%@%@",
                            isEmpty([dict1 objectForKey:P_C_CODE]),
                            [dict1 objectForKey:P_MOBILE]];
    } else {
        _userMobile.text = isEmpty([dict1 objectForKey:P_EMAIL]);
    }

    // Rating — always use star.fill SF Symbol (iOS 13+) with yellow tint; fallback ★ character
    NSString *rating = [dict1 objectForKey:@"d_rating"] ?: [dict1 objectForKey:@"rating"];
    if (!rating || [rating floatValue] <= 0) rating = @"0.0";
    UIColor *starYellow = [UIColor colorWithRed:235/255.0 green:181/255.0 blue:24/255.0 alpha:1];
    UIImage *starImg = nil;
    if (@available(iOS 13, *)) {
        UIImageSymbolConfiguration *cfg = [UIImageSymbolConfiguration configurationWithPointSize:19.5
                                                                                          weight:UIImageSymbolWeightRegular];
        UIImage *base = [UIImage systemImageNamed:@"star.fill" withConfiguration:cfg];
        // Draw star as mask, then fill with yellow using sourceIn
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

    NSString *profile = [dict1 objectForKey:P_DRIVER_PROFILE_IMAGE_PATH];
    if (profile.length > 0) {
        [_imgProfile sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", url_base_images, profile]]
                       placeholderImage:[UIImage imageNamed:@"Profile Icon Crop Image"]];
    }

    // Balance (driver wallet)
    if (_balanceAmountLabel) {
        float balance = [[dict1 objectForKey:P_DRIVER_WAlLET_AMOUNT] floatValue];
        CityModel *cityModel = [CityModel getCityByDriverCityId];
        NSString *currency = isEmpty(cityModel.city_cur);
        if (balance < 0) {
            _balanceAmountLabel.textColor = [UIColor redColor];
        } else {
            _balanceAmountLabel.textColor = [UIColor colorWithRed:34/255.0 green:167/255.0 blue:93/255.0 alpha:1];
        }
        if (balance == 0) {
            _balanceAmountLabel.text = [Utilities formatAmountAndCurrencyZero:0 currency:currency];
        } else {
            _balanceAmountLabel.text = [Utilities formatAmountAndCurrency:balance currency:currency];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
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
    cell.lblMenu.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];

    if ([title isEqualToString:[LanguageHelper getStringWithKey:@"k_15_s4_a1_notifications"]]) {
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

    UIImage *iconImage = [UIImage imageNamed:[item objectForKey:@"icon"]];
    if (!iconImage) {
        // Fallback to SF Symbol if asset is missing
        NSString *sfName = [item objectForKey:@"sfSymbol"];
        if (sfName.length > 0) {
            if (@available(iOS 13, *)) {
                UIImageSymbolConfiguration *cfg = [UIImageSymbolConfiguration configurationWithWeight:UIImageSymbolWeightRegular];
                iconImage = [UIImage systemImageNamed:sfName withConfiguration:cfg];
            }
        }
    }
    UIImage *image = [iconImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    cell.imgIcon.tintColor = [UIColor colorWithRed:107/255.0 green:114/255.0 blue:128/255.0 alpha:1];
    [cell.imgIcon setImage:image];
    cell.selectionStyle  = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    cell.viewSeparator.hidden = YES;
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        [cell setSelected:YES animated:NO];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 42;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *sideOption = [[_arrSideMenu objectAtIndex:indexPath.row] objectForKey:@"identifier"];

    if ([sideOption isEqualToString:SIDE_MENU_LOGOUT]) {
        [self LogoutPressed_isLogout:YES];

    } else if ([sideOption isEqualToString:@"recargas"]) {
        AboutUsViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"AboutUsViewController"];
        vc.isCustomUrl  = YES;
        vc.customTitle  = @"Recargas";
        vc.customUrl    = @"https://www.google.com"; // TODO: Replace with actual Recargas URL
        MainViewController *mainViewController = (MainViewController *)self.sideMenuController;
        UINavigationController *navVC = (UINavigationController *)mainViewController.rootViewController;
        [navVC pushViewController:vc animated:YES];
        [mainViewController hideLeftViewAnimated:YES completionHandler:nil];

    } else if ([sideOption isEqualToString:@"chat_with_us"]) {
        AboutUsViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"AboutUsViewController"];
        viewController.isCustomUrl = YES;
        viewController.customTitle = [LanguageHelper getStringWithKey:@"k_11_s4_chat_us"];
        viewController.customUrl   = isEmpty([SettingsModel getSettignsObject].enable_chat);
        MainViewController *mainViewController = (MainViewController *)self.sideMenuController;
        UINavigationController *navigationController = (UINavigationController *)mainViewController.rootViewController;
        [navigationController pushViewController:viewController animated:YES];
        [mainViewController hideLeftViewAnimated:YES completionHandler:nil];

    } else if ([sideOption isEqualToString:SIDE_MENU_SHARE]) {
        [self shareApp];

    } else if ([sideOption isEqualToString:SIDE_MENU_DEACTIVATE]) {
        [self LogoutPressed_isLogout:NO];

    } else if ([sideOption isEqualToString:SIDE_MENU_SUPPORT]) {
        [self openMailComposer];

    } else {
        [self setViewControllers:sideOption
                   storyboardName:[[_arrSideMenu objectAtIndex:indexPath.row] objectForKey:@"storyboard"]];
    }
}

#pragma mark - Navigation helpers

-(void)setViewControllers:(NSString *)sender storyboardName:(NSString *)storyboardName {
    if ([sender isEqualToString:StoryBoardUtiles.HOME_SINGLE_VC]) {
        NSString *tripIdOld = defaults_object(DRIVER_STATUS);
        if (tripIdOld != nil && (![tripIdOld isEqualToString:TS_END])) {
            if (![tripIdOld isEqualToString:TS_WAITING]) {
                [self showAlert:@"Whoops!" message:[LanguageHelper getStringWithKey:@"k_64_s4_single_mode_error_message"]];
                return;
            }
        }
        [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:P_IS_SINGLE_MODE];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    if (storyboardName.length == 0) {
        storyboardName = StoryBoardUtiles.STORYBOARD_MAIN;
    }
    MainViewController *mainViewController = (MainViewController *)self.sideMenuController;
    UINavigationController *navigationController = (UINavigationController *)mainViewController.rootViewController;
    UIViewController *viewController = [StoryBoardUtiles viewContollerWithIdentifier:sender name:storyboardName];
    [navigationController pushViewController:viewController animated:YES];
    [mainViewController hideLeftViewAnimated:YES completionHandler:nil];
}

#pragma mark - Availability Switch

- (IBAction)switchChange:(UISwitch *)sender {
    NSDictionary *dictDriver = defaults_object(P_USER_DICT);
    if ([[dictDriver objectForKey:P_DRIVER_VERIFIED] intValue] == 1) {
        NSString *string = defaults_object(DRIVER_STATUS);
        if (![string isEqualToString:TS_WAITING]) {
            sender.on = NO;
            [UIView animateWithDuration:0.3 animations:^{
                sender.on = NO;
            } completion:^(BOOL finished) {
                [UtilityClass swa:@"Alert!" m:@"Your are in trip,So cannot change availability." cbt:@"ok" obt:nil];
            }];
            return;
        }
        [UtilityClass setLH:NO wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
        [[UpdateUserCurrentLocation sharedInstance] updateDriverActivityLogAvailablity:sender.isOn ? @"1" : @"0"
                                                                                  type:sender.isOn ? @"Login" : @"Logout"
                                                                       completionBlock:^(id results, NSError *error) {
            [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
            if (isStatusOk(results)) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"change_switch_home" object:nil];
            }
        }];
    } else {
        sender.on = NO;
    }
}

#pragma mark - Logout

- (void)LogoutPressed_isLogout:(BOOL)isLogout {
    UIAlertController *alert = [UIAlertController
        alertControllerWithTitle:isLogout ? @"" : [LanguageHelper getStringWithKey:@"k_10_s4_a1_deactivate"]
        message:isLogout ? [LanguageHelper getStringWithKey:@"k_54_s4_do_you_want_to_exit_now"] : [LanguageHelper getStringWithKey:@"k_63_s4_deactivate_alert"]
        preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *yesButton = [UIAlertAction
        actionWithTitle:[LanguageHelper getStringWithKey:@"k_21_s4_yes"]
        style:UIAlertActionStyleDefault
        handler:^(UIAlertAction *action) {
            isLogout ? [self logoutAction] : [self deactivateAccount];
        }];
    UIAlertAction *noButton = [UIAlertAction
        actionWithTitle:[LanguageHelper getStringWithKey:@"k_22_s4_no"]
        style:UIAlertActionStyleDefault
        handler:^(UIAlertAction *action) {}];
    [alert addAction:yesButton];
    [alert addAction:noButton];
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)logoutAction {
    [UtilityClass setLH:NO wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
    NSDictionary *dict = @{
        P_DRIVER_AVAILAILITY: @"0",
        @"type": @"Logout",
    };
    [GIC mkwu:UPDATE_DRIVER_ACTIVITY d:dict isa:NO cb:^(id results, NSError *error) {
        [self afterLogutWork];
        [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
    }];
}

-(void)deactivateAccount {
    NSString *status = defaults_object(DRIVER_STATUS);
    NSDictionary *dict1 = [[NSUserDefaults standardUserDefaults] objectForKey:P_USER_DICT];
    NSString *driverID = [dict1 objectForKey:P_DRIVER_ID];
    if ([status isEqualToString:TS_WAITING]) {
        [UtilityClass setLH:NO wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
        NSDictionary *dict = @{
            P_DRIVER_AVAILAILITY: @"0",
            P_DRIVER_ID: driverID,
            P_DRIVER_VERIFIED: @"0"
        };
        [GIC mkwu:UPDATE_DRIVER_PROFILE d:dict isa:NO cb:^(id results, NSError *error) {
            if (error == nil) {}
            [self afterLogutWork];
            [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
        }];
    }
}

-(void)afterLogutWork {
    [UtilityClass setLH:YES wt:@""];
    [UtilityClass SetAllLoadersHidden];
    defaults_remove(P_API_KEY);
    defaults_remove(P_USER_DICT);
    defaults_remove(P_IS_SINGLE_MODE);
    defaults_remove(TRIP_ID);
    defaults_remove(TRIP_STATUS);
    defaults_remove(P_USER_DICT_LOGGED);
    defaults_remove(P_IS_USER_LOGIN);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"driver_logout" object:nil];
    UINavigationController *nav = IS_PHONE_VERIFICATION == 1
        ? [StoryBoardUtiles navigationPhone]
        : [StoryBoardUtiles navigationEmail];
    UIWindow *window = UIApplication.sharedApplication.delegate.window;
    window.rootViewController = nav;
    [nav setNavigationBarHidden:YES];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - IBActions

- (IBAction)onSettingButtonTap:(id)sender {
    [self setViewControllers:StoryBoardUtiles.EDIT_PROFILE storyboardName:StoryBoardUtiles.STORYBOARD_SIGNUP];
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

-(void)openWebUrl:(BOOL)isAboutUs {
    MainViewController *mainViewController = (MainViewController *)self.sideMenuController;
    UINavigationController *navigationController = (UINavigationController *)mainViewController.rootViewController;
    AboutUsViewController *viewController = (AboutUsViewController *)[StoryBoardUtiles viewContollerInMainWithIdentifier:StoryBoardUtiles.ABOUT_US];
    viewController.isAboutUs = isAboutUs;
    [navigationController pushViewController:viewController animated:YES];
    [mainViewController hideLeftViewAnimated:YES completionHandler:nil];
}

- (IBAction)onDriverSwitchButtonTap:(id)sender {
    [APP_DELEGATE onDriverSwitchButtonTap:nil];
}

#pragma mark - Sharing

-(void)shareApp {
    ConstantModel *constantModel = [ConstantModel getConstantsObject];
    NSString *textToShare = isEmpty(constantModel.share_text);
    NSArray *objectsToShare = @[textToShare];
    UIActivityViewController *activityVC = [[UIActivityViewController alloc]
        initWithActivityItems:objectsToShare applicationActivities:nil];
    activityVC.excludedActivityTypes = @[
        UIActivityTypeAirDrop, UIActivityTypePrint,
        UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll,
        UIActivityTypeAddToReadingList, UIActivityTypePostToFlickr,
        UIActivityTypePostToVimeo
    ];
    [self presentViewController:activityVC animated:YES completion:nil];
}

#pragma mark - Mail

-(void)openMailComposer {
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mailCont = [[MFMailComposeViewController alloc] init];
        mailCont.mailComposeDelegate = self;
        NSString *supportEmail = isEmpty([ConstantModel getConstantsObject].support_email);
        [mailCont setToRecipients:@[supportEmail]];
        [self presentViewController:mailCont animated:YES completion:nil];
    } else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"googlegmail://"]]) {
        NSString *supportEmail = isEmpty([ConstantModel getConstantsObject].support_email);
        NSString *subject = [LanguageHelper getStringWithKey:@"k_9_s5_support_subject"];
        NSString *gmailURLString = [NSString stringWithFormat:@"googlegmail:///co?to=%@&subject=%@",
            [supportEmail stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]],
            [subject       stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:gmailURLString] options:@{} completionHandler:nil];
    } else {
        [UtilityClass swa:@"Whoops!" m:[LanguageHelper getStringWithKey:@"k_65_s4_config_mail"]
                      cbt:[LanguageHelper getStringWithKey:@"k_18_s4_Ok"] obt:nil vc:self];
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error {
    if (error != nil) {
        [self showAlert:@"Whoops!" message:[NSString stringWithFormat:@" ERROR %@", error]];
        return;
    }
    [controller dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - URL helper

-(void)openUrl:(NSURL *)url {
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
    } else {
        [UtilityClass swa:nil m:[LanguageHelper getStringWithKey:@"k_61_s4_url_can_not_open"] cbt:@"Ok" obt:nil vc:self];
    }
}

@end
