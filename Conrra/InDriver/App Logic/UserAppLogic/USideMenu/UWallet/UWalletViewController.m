//
//  UWalletViewController.m
//  HireMe Rider
//
//  Created by Grepix Infotech on 26/11/18.
//  Copyright © 2023 Grepixit. All rights reserved.
//
#import <GIKit/GIKit.h>
#import "LanguageHelper.h"
#import "WebCallConstants.h"
#import "AppDelegate.h"
#import "UWalletTableViewCell.h"
#import "MainViewController.h"
#import "HomeViewController.h"
#import "UWalletViewController.h"
#import "WalletInfo.h"
#import "Utilities.h"
#import "DWalletTableViewCell.h"
#import <Conrra-Swift.h>
#import "UserProfile.h"

@interface UWalletViewController (){
    NSMutableArray *walletTranArray;
    NSString  *crStr;
    BOOL isStopTripCall;
    BOOL isRefresh;
    UILabel *_ndBalanceLabel;
}
@end

@implementation UWalletViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    isRefresh = YES;
    walletTranArray = [[NSMutableArray alloc] init];
    [self setupNewDesign];
    [self showWalletBalance];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    if (isRefresh) {
        [self getWalletTranList:NO];
        [self refreshUserProfile];
        isRefresh = NO;
    }
}

#pragma mark - New Design

- (void)setupNewDesign {
    for (UIView *v in [self.view.subviews copy]) { v.hidden = YES; }
    self.view.backgroundColor = [UIColor colorWithRed:0.96 green:0.96 blue:0.96 alpha:1];

    UIColor *textMain = [UIColor colorNamed:@"color_app_label"] ?: [UIColor blackColor];
    UILayoutGuide *safe = self.view.safeAreaLayoutGuide;

    UIView *header = [[UIView alloc] init];
    header.translatesAutoresizingMaskIntoConstraints = NO;
    header.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:header];

    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    backBtn.translatesAutoresizingMaskIntoConstraints = NO;
    backBtn.backgroundColor = [UIColor colorWithWhite:0.93 alpha:1];
    backBtn.layer.cornerRadius = 18;
    backBtn.tintColor = textMain;
    if (@available(iOS 13, *)) {
        UIImageSymbolConfiguration *cfg = [UIImageSymbolConfiguration configurationWithWeight:UIImageSymbolWeightMedium];
        [backBtn setImage:[[UIImage systemImageNamed:@"chevron.left" withConfiguration:cfg]
                           imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
                 forState:UIControlStateNormal];
    } else {
        [backBtn setTitle:@"‹" forState:UIControlStateNormal];
        backBtn.titleLabel.font = [UIFont systemFontOfSize:26];
    }
    [backBtn addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    [header addSubview:backBtn];

    UILabel *titleLbl = [[UILabel alloc] init];
    titleLbl.translatesAutoresizingMaskIntoConstraints = NO;
    titleLbl.text = @"Mi Billetera (Actas)";
    titleLbl.font = FONTS_NOTO_BOLD(18);
    titleLbl.textColor = textMain;
    [header addSubview:titleLbl];

    UIView *hSep = [[UIView alloc] init];
    hSep.translatesAutoresizingMaskIntoConstraints = NO;
    hSep.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
    [header addSubview:hSep];

    [NSLayoutConstraint activateConstraints:@[
        [header.topAnchor constraintEqualToAnchor:safe.topAnchor],
        [header.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [header.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [header.heightAnchor constraintEqualToConstant:64],
        [backBtn.leadingAnchor constraintEqualToAnchor:header.leadingAnchor constant:16],
        [backBtn.centerYAnchor constraintEqualToAnchor:header.centerYAnchor],
        [backBtn.widthAnchor constraintEqualToConstant:36],
        [backBtn.heightAnchor constraintEqualToConstant:36],
        [titleLbl.centerXAnchor constraintEqualToAnchor:header.centerXAnchor],
        [titleLbl.centerYAnchor constraintEqualToAnchor:header.centerYAnchor],
        [hSep.bottomAnchor constraintEqualToAnchor:header.bottomAnchor],
        [hSep.leadingAnchor constraintEqualToAnchor:header.leadingAnchor],
        [hSep.trailingAnchor constraintEqualToAnchor:header.trailingAnchor],
        [hSep.heightAnchor constraintEqualToConstant:1],
    ]];

    UIView *balanceBar = [[UIView alloc] init];
    balanceBar.translatesAutoresizingMaskIntoConstraints = NO;
    balanceBar.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:balanceBar];

    UILabel *saldoKey = [[UILabel alloc] init];
    saldoKey.translatesAutoresizingMaskIntoConstraints = NO;
    saldoKey.text = [LanguageHelper getStringWithKey:@"k_s10_balance_available" defaultValue:@"Saldo Disponible:"];
    saldoKey.font = FONTS_NOTO_BOLD(14);
    saldoKey.textColor = textMain;
    [balanceBar addSubview:saldoKey];

    UILabel *saldoVal = [[UILabel alloc] init];
    saldoVal.translatesAutoresizingMaskIntoConstraints = NO;
    saldoVal.font = FONTS_NOTO_BOLD(14);
    saldoVal.textColor = [UIColor colorWithRed:0.02 green:0.62 blue:0.35 alpha:1];
    saldoVal.textAlignment = NSTextAlignmentRight;
    [balanceBar addSubview:saldoVal];
    _ndBalanceLabel = saldoVal;

    UIView *bSep = [[UIView alloc] init];
    bSep.translatesAutoresizingMaskIntoConstraints = NO;
    bSep.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
    [balanceBar addSubview:bSep];

    CGFloat bp = 20.0;
    [NSLayoutConstraint activateConstraints:@[
        [balanceBar.topAnchor constraintEqualToAnchor:header.bottomAnchor],
        [balanceBar.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [balanceBar.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [saldoKey.topAnchor constraintEqualToAnchor:balanceBar.topAnchor constant:14],
        [saldoKey.leadingAnchor constraintEqualToAnchor:balanceBar.leadingAnchor constant:bp],
        [saldoVal.centerYAnchor constraintEqualToAnchor:saldoKey.centerYAnchor],
        [saldoVal.trailingAnchor constraintEqualToAnchor:balanceBar.trailingAnchor constant:-bp],
        [saldoVal.leadingAnchor constraintGreaterThanOrEqualToAnchor:saldoKey.trailingAnchor constant:8],
        [bSep.topAnchor constraintEqualToAnchor:saldoKey.bottomAnchor constant:14],
        [bSep.leadingAnchor constraintEqualToAnchor:balanceBar.leadingAnchor],
        [bSep.trailingAnchor constraintEqualToAnchor:balanceBar.trailingAnchor],
        [bSep.heightAnchor constraintEqualToConstant:1],
        [bSep.bottomAnchor constraintEqualToAnchor:balanceBar.bottomAnchor],
    ]];

    UITableView *tv = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    tv.translatesAutoresizingMaskIntoConstraints = NO;
    tv.backgroundColor = [UIColor clearColor];
    tv.separatorStyle = UITableViewCellSeparatorStyleNone;
    tv.showsVerticalScrollIndicator = NO;
    tv.contentInset = UIEdgeInsetsMake(8, 0, 8, 0);
    tv.delegate = self;
    tv.dataSource = self;
    [tv registerClass:[UITableViewCell class] forCellReuseIdentifier:@"WalletCardCell"];
    [self.view addSubview:tv];

    [NSLayoutConstraint activateConstraints:@[
        [tv.topAnchor constraintEqualToAnchor:balanceBar.bottomAnchor],
        [tv.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [tv.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [tv.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
    ]];

    self.walletTableView = tv;
}

#pragma mark - Balance Display

-(void)showWalletBalance {
    BOOL isDriver = ![defaults_object(P_IS_USER_LOGIN) boolValue];
    CityModel *cityModel;
    float balance;

    if (isDriver) {
        NSDictionary *dict = [[NSUserDefaults standardUserDefaults] objectForKey:P_USER_DICT];
        cityModel = [CityModel getCityByDriverCityId];
        balance = [[dict objectForKey:P_DRIVER_WAlLET_AMOUNT] floatValue];
    } else {
        NSDictionary *dict = [[NSUserDefaults standardUserDefaults] objectForKey:P_USER_DICT_LOGGED];
        cityModel = [CityModel getCityByCityId:[UserProfile shared].loggedCityID];
        balance = [[dict objectForKey:P_USER_WAlLET_AMOUNT] floatValue];
    }

    NSString *currency = isEmpty(cityModel.city_cur);

    if (_ndBalanceLabel) {
        _ndBalanceLabel.text = [Utilities formatAmountAndCurrency:balance currency:currency];
        _ndBalanceLabel.textColor = (balance < 0)
            ? [UIColor redColor]
            : [UIColor colorWithRed:0.02 green:0.62 blue:0.35 alpha:1];
    }
}

-(void)monyAddSucessfully {
    isRefresh = YES;
}

-(void)setUIFields {
    // Labels are now built programmatically in setupNewDesign
}

#pragma mark - API

-(void)getWalletTranList:(BOOL)isLoadMore {
    NSDictionary *dict1 = [[NSUserDefaults standardUserDefaults] objectForKey:P_USER_DICT_LOGGED];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{
        @"user_id": [dict1 objectForKey:P_USER_ID],
        @"limit":   @(SIZE),
        @"api_key": [dict1 objectForKey:P_API_KEY],
    }];
    if (isLoadMore) {
        [dict setObject:[NSString stringWithFormat:@"%lu", (unsigned long)walletTranArray.count] forKey:@"offset"];
    } else {
        [dict setObject:@"0" forKey:@"offset"];
    }
    [UtilityClass setLH:NO wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
    [GIC mkwu:GET_WALLET_USER_TRANS d:dict isa:NO cb:^(id results, NSError *error) {
        [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
        if ([[[results objectForKey:P_STATUS] uppercaseString] isEqualToString:@"OK"]) {
            if ([[results objectForKey:P_RESPONSE] isKindOfClass:[NSArray class]]) {
                NSArray *arr = [results objectForKey:P_RESPONSE];
                self->isStopTripCall = arr.count < SIZE;
                if (!isLoadMore) {
                    [self->walletTranArray removeAllObjects];
                }
                for (int i = 0; i < arr.count; i++) {
                    WalletInfo *info = [[WalletInfo alloc] initWalletInfoWithArray:[arr objectAtIndex:i]];
                    [self->walletTranArray addObject:info];
                }
                [self->_walletTableView reloadData];
            } else {
                self->isStopTripCall = YES;
            }
        }
    }];
}

#pragma mark - IBAction

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)pushToAddMoneyVC:(id)sender {
    UAddMoneyWalletVC *vc = (UAddMoneyWalletVC *)[StoryBoardUtiles viewContollerInUserWithIdentifier:StoryBoardUtiles.WALLET_ADD_MOENY_VC];
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - TableView Data Source / Delegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView { return 1; }

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return walletTranArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WalletCardCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];

    if (![cell.contentView viewWithTag:1001]) {
        [self buildWalletCardInCell:cell];
    }

    WalletInfo *data = [walletTranArray objectAtIndex:indexPath.row];
    [self populateWalletCell:cell withData:data];

    if (indexPath.row > 3 && indexPath.row > (NSInteger)walletTranArray.count - 2 && !isStopTripCall) {
        [self getWalletTranList:YES];
    }
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 260;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    WalletInfo *walletInfo = [walletTranArray objectAtIndex:indexPath.row];
    [self getTripDetail:[NSString stringWithFormat:@"%d", walletInfo.transactionModel.trip_id]];
}

#pragma mark - Card Cell Layout

- (void)buildWalletCardInCell:(UITableViewCell *)cell {
    UIColor *textMain = [UIColor colorNamed:@"color_app_label"] ?: [UIColor blackColor];
    UIColor *textGray = [UIColor colorWithWhite:0.5 alpha:1];
    CGFloat p = 16.0;

    // Card shell
    UIView *card = [[UIView alloc] init];
    card.translatesAutoresizingMaskIntoConstraints = NO;
    card.tag = 1001;
    card.backgroundColor = [UIColor whiteColor];
    card.layer.cornerRadius = 14;
    card.layer.shadowColor = [UIColor blackColor].CGColor;
    card.layer.shadowOpacity = 0.07;
    card.layer.shadowRadius = 8;
    card.layer.shadowOffset = CGSizeMake(0, 2);
    card.clipsToBounds = NO;
    [cell.contentView addSubview:card];

    [NSLayoutConstraint activateConstraints:@[
        [card.topAnchor constraintEqualToAnchor:cell.contentView.topAnchor constant:8],
        [card.leadingAnchor constraintEqualToAnchor:cell.contentView.leadingAnchor constant:16],
        [card.trailingAnchor constraintEqualToAnchor:cell.contentView.trailingAnchor constant:-16],
        [card.bottomAnchor constraintEqualToAnchor:cell.contentView.bottomAnchor constant:-8],
    ]];

    // IDENTIFICACIÓN row
    UILabel *idKey = [[UILabel alloc] init];
    idKey.translatesAutoresizingMaskIntoConstraints = NO;
    idKey.text = [LanguageHelper getStringWithKey:@"k_s10_identification" defaultValue:@"IDENTIFICACIÓN:"];
    idKey.font = FONTS_NOTO_BOLD(14);
    idKey.textColor = textMain;
    [card addSubview:idKey];

    UILabel *idVal = [[UILabel alloc] init];
    idVal.translatesAutoresizingMaskIntoConstraints = NO;
    idVal.font = FONTS_NOTO_REGULAR(14);
    idVal.textColor = textMain;
    idVal.textAlignment = NSTextAlignmentRight;
    idVal.tag = 1002;
    [card addSubview:idVal];

    [NSLayoutConstraint activateConstraints:@[
        [idKey.topAnchor constraintEqualToAnchor:card.topAnchor constant:20],
        [idKey.leadingAnchor constraintEqualToAnchor:card.leadingAnchor constant:p],
        [idVal.centerYAnchor constraintEqualToAnchor:idKey.centerYAnchor],
        [idVal.trailingAnchor constraintEqualToAnchor:card.trailingAnchor constant:-p],
        [idVal.leadingAnchor constraintGreaterThanOrEqualToAnchor:idKey.trailingAnchor constant:8],
    ]];

    // Separator under ID
    UIView *sep0 = [[UIView alloc] init];
    sep0.translatesAutoresizingMaskIntoConstraints = NO;
    sep0.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
    [card addSubview:sep0];

    [NSLayoutConstraint activateConstraints:@[
        [sep0.topAnchor constraintEqualToAnchor:idKey.bottomAnchor constant:20],
        [sep0.leadingAnchor constraintEqualToAnchor:card.leadingAnchor constant:p],
        [sep0.trailingAnchor constraintEqualToAnchor:card.trailingAnchor constant:-p],
        [sep0.heightAnchor constraintEqualToConstant:1],
    ]];

    // 4 detail rows: Fecha/Hora, Tipo de pago, Impuesto, Billetera
    NSArray *rowKeys  = @[@"Fecha / Hora:", @"Tipo de pago:", @"Impuesto:", @"Billetera:"];
    NSArray *rowIcons = @[@"calendar", @"creditcard", @"percent", @"banknote"];
    NSArray *rowTags  = @[@1003, @1004, @1005, @1006];

    UIView *prevBottom = sep0;
    for (int i = 0; i < 4; i++) {
        UIImageView *icon = [[UIImageView alloc] init];
        icon.translatesAutoresizingMaskIntoConstraints = NO;
        icon.contentMode = UIViewContentModeScaleAspectFit;
        icon.tintColor = [UIColor colorWithWhite:0.65 alpha:1];
        if (@available(iOS 13, *)) {
            UIImageSymbolConfiguration *cfg = [UIImageSymbolConfiguration configurationWithWeight:UIImageSymbolWeightLight];
            icon.image = [[UIImage systemImageNamed:rowIcons[i] withConfiguration:cfg]
                          imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        }
        [card addSubview:icon];

        UILabel *keyLbl = [[UILabel alloc] init];
        keyLbl.translatesAutoresizingMaskIntoConstraints = NO;
        keyLbl.text = rowKeys[i];
        keyLbl.font = FONTS_NOTO_REGULAR(13);
        keyLbl.textColor = textGray;
        [card addSubview:keyLbl];

        UILabel *valLbl = [[UILabel alloc] init];
        valLbl.translatesAutoresizingMaskIntoConstraints = NO;
        valLbl.font = FONTS_NOTO_REGULAR(13);
        valLbl.textColor = textMain;
        valLbl.textAlignment = NSTextAlignmentRight;
        valLbl.tag = [rowTags[i] integerValue];
        [card addSubview:valLbl];

        [NSLayoutConstraint activateConstraints:@[
            [icon.topAnchor constraintEqualToAnchor:prevBottom.bottomAnchor constant:10],
            [icon.leadingAnchor constraintEqualToAnchor:card.leadingAnchor constant:p],
            [icon.widthAnchor constraintEqualToConstant:18],
            [icon.heightAnchor constraintEqualToConstant:18],
            [keyLbl.centerYAnchor constraintEqualToAnchor:icon.centerYAnchor],
            [keyLbl.leadingAnchor constraintEqualToAnchor:icon.trailingAnchor constant:6],
            [valLbl.centerYAnchor constraintEqualToAnchor:icon.centerYAnchor],
            [valLbl.trailingAnchor constraintEqualToAnchor:card.trailingAnchor constant:-p],
            [valLbl.leadingAnchor constraintGreaterThanOrEqualToAnchor:keyLbl.trailingAnchor constant:8],
        ]];

        prevBottom = icon;
    }

    // Separator above Balance
    UIView *sep1 = [[UIView alloc] init];
    sep1.translatesAutoresizingMaskIntoConstraints = NO;
    sep1.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
    [card addSubview:sep1];

    [NSLayoutConstraint activateConstraints:@[
        [sep1.topAnchor constraintEqualToAnchor:prevBottom.bottomAnchor constant:12],
        [sep1.leadingAnchor constraintEqualToAnchor:card.leadingAnchor constant:p],
        [sep1.trailingAnchor constraintEqualToAnchor:card.trailingAnchor constant:-p],
        [sep1.heightAnchor constraintEqualToConstant:1],
    ]];

    // Balance Actual row
    UILabel *balKey = [[UILabel alloc] init];
    balKey.translatesAutoresizingMaskIntoConstraints = NO;
    balKey.text = @"Balance Actual:";
    balKey.font = FONTS_NOTO_REGULAR(14);
    balKey.textColor = textGray;
    [card addSubview:balKey];

    UILabel *balVal = [[UILabel alloc] init];
    balVal.translatesAutoresizingMaskIntoConstraints = NO;
    balVal.font = FONTS_NOTO_BOLD(14);
    balVal.textColor = textMain;
    balVal.textAlignment = NSTextAlignmentRight;
    balVal.tag = 1007;
    [card addSubview:balVal];

    [NSLayoutConstraint activateConstraints:@[
        [balKey.topAnchor constraintEqualToAnchor:sep1.bottomAnchor constant:12],
        [balKey.leadingAnchor constraintEqualToAnchor:card.leadingAnchor constant:p],
        [balKey.bottomAnchor constraintEqualToAnchor:card.bottomAnchor constant:-16],
        [balVal.centerYAnchor constraintEqualToAnchor:balKey.centerYAnchor],
        [balVal.trailingAnchor constraintEqualToAnchor:card.trailingAnchor constant:-p],
        [balVal.leadingAnchor constraintGreaterThanOrEqualToAnchor:balKey.trailingAnchor constant:8],
    ]];
}

- (void)populateWalletCell:(UITableViewCell *)cell withData:(WalletInfo *)data {
    UIView *card = [cell.contentView viewWithTag:1001];
    if (!card) return;

    CityModel *cityModel = [defaults_object(P_IS_USER_LOGIN) boolValue]
        ? [CityModel getCityByCityId:[UserProfile shared].loggedCityID]
        : [CityModel getCityByDriverCityId];
    NSString *currency = isEmpty(cityModel.city_cur);

    // IDENTIFICACIÓN
    UILabel *idVal = (UILabel *)[card viewWithTag:1002];
    idVal.text = isEmpty(data.transactionModel.transaction_id);

    // Fecha / Hora
    UILabel *dateVal = (UILabel *)[card viewWithTag:1003];
    dateVal.text = [Utilities GetGMTDatetoLocalTZ:data.wallet_Created :APP_DATE_FORMAT];

    // Tipo de pago
    UILabel *payVal = (UILabel *)[card viewWithTag:1004];
    payVal.text = [self getPayModeTanslation:isEmpty(data.transactionModel.trans_pay_mode)];

    // Impuesto
    UILabel *taxVal = (UILabel *)[card viewWithTag:1005];
    taxVal.text = [Utilities formatAmountAndCurrency:[data.wallet_Trans_Tax_Amt floatValue] currency:currency];

    // Billetera
    UILabel *walletVal = (UILabel *)[card viewWithTag:1006];
    walletVal.text = [Utilities formatAmountAndCurrency:data.wallet_Amount currency:currency];

    // Balance Actual
    UILabel *balVal = (UILabel *)[card viewWithTag:1007];
    balVal.text = [Utilities formatAmountAndCurrency:[data.current_bal floatValue] currency:currency];
}

#pragma mark - Helpers

-(NSString *)getPayModeTanslation:(NSString *)paymode {
    if ([[paymode lowercaseString] isEqualToString:@"cash"])   return [LanguageHelper getStringWithKey:@"k_r39_s9_cash"];
    if ([[paymode lowercaseString] isEqualToString:@"card"])   return [LanguageHelper getStringWithKey:@"k_r39_s9_card"];
    if ([[paymode lowercaseString] isEqualToString:@"wallet"]) return [LanguageHelper getStringWithKey:@"k_r39_s9_wallet"];
    return paymode;
}

-(void)getTripDetail:(NSString *)tripId {
    if (tripId.length == 0 || [tripId intValue] == 0) return;

    TripModel *currTrip = [[TripModel alloc] init];
    currTrip.trip_Id = tripId;
    BOOL is_login_as_user = [defaults_object(P_IS_USER_LOGIN) boolValue];
    NSDictionary *userDict = defaults_object(P_USER_DICT);
    NSString *userId   = is_login_as_user ? [userDict objectForKey:@"user_id"]   : [userDict objectForKey:@"usr_ref_id"];
    NSString *driverId = is_login_as_user ? [userDict objectForKey:@"drv_ref_id"] : [userDict objectForKey:@"driver_id"];

    [currTrip refreshTripModelWithCompletionBlock:^(id results, NSError *error) {
        if ([[results objectForKey:P_RESPONSE] isKindOfClass:[NSArray class]]) {
            if (currTrip.user.userId == [userId intValue]) {
                [self openTripDetialForRider:currTrip];
            } else if ([currTrip.driver.driverId intValue] == [driverId intValue]) {
                [currTrip refreshTripModelWithDriverId:driverId completionBlock:^(id results, NSError *error) {
                    if ([[results objectForKey:P_RESPONSE] isKindOfClass:[NSArray class]]) {
                        [self openTripDetialForDriver:currTrip];
                    }
                } isShowLoader:YES];
            }
        }
    } isShowLoader:YES];
}

-(void)openTripDetialForDriver:(TripModel *)trip {
    TripDetailsViewController *details = (TripDetailsViewController *)[StoryBoardUtiles viewContollerInMainWithIdentifier:StoryBoardUtiles.TRIP_DETAIL_VC];
    details.trip = trip;
    [self addChildViewController:details];
    [details.view setFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [self.view addSubview:details.view];
    [details didMoveToParentViewController:self];
}

-(void)openTripDetialForRider:(TripModel *)trip {
    self.tripDetailsViewController = (UTripDetailsViewController *)[StoryBoardUtiles viewContollerInUserWithIdentifier:StoryBoardUtiles.UTRIP_DETAIL_VC];
    [self addChildViewController:self.tripDetailsViewController];
    self.tripDetailsViewController.trip = trip;
    [self.tripDetailsViewController.view setFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [self.view addSubview:self.tripDetailsViewController.view];
    [self.tripDetailsViewController didMoveToParentViewController:self];
    self.tripDetailsViewController.tripDetailDelegate = self;
}

-(void)onDismissDetailTrip {
    [self.tripDetailsViewController.view removeFromSuperview];
    [self.tripDetailsViewController removeFromParentViewController];
}

-(void)refreshUserProfile {
    NSDictionary *dictUser = defaults_object(P_USER_DICT_LOGGED);
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{
        P_API_KEY: [dictUser objectForKey:P_API_KEY],
    }];
    [GIC mkwerwu:GET_USER_PROFILE d:dict cb:^(id results, NSError *error) {
        if ([[results objectForKey:P_STATUS] isEqualToString:@"OK"]) {
            if ([[results objectForKey:P_RESPONSE] isKindOfClass:[NSDictionary class]]) {
                defaults_set_object(P_USER_DICT_LOGGED, [results objectForKey:P_RESPONSE]);
            } else if ([[results objectForKey:P_RESPONSE] isKindOfClass:[NSArray class]]) {
                NSArray *arr = [results objectForKey:P_RESPONSE];
                if (arr.count > 0) defaults_set_object(P_USER_DICT_LOGGED, [arr firstObject]);
            }
            [self showWalletBalance];
        }
    }];
}

@end
