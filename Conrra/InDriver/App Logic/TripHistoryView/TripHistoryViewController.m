//
//  TripHistoryViewController.m
//  TaxiDriver
//
//  Created by  Appicial on 24/05/17.
//  Copyright © 2023 Appicial. All rights reserved.
//

#import "TripHistoryViewController.h"
#import "LanguageHelper.h"
#import "AppDelegate.h"
#import "WebCallConstants.h"
#import <GIKit/GIKit.h>
#import "tripHistoryCell.h"
#import "TripDetailsViewController.h"
#import "ConstantModel.h"
#import "UIView+UpdateAutoLayoutConstraints.h"
#import "TripModel+Helper.h"
#import "TripDetailsViewController.h"
#import "UIImageView+WebCache.h"
#import "CityModel.h"

#define kDTHReceiptNotchGuide 5099

#define kDTHTagCard     4001
#define kDTHTagDate     4002
#define kDTHTagBadgeBg  4003
#define kDTHTagBadgeLbl 4004
#define kDTHTagSep      4005
#define kDTHTagPickIcon 4006
#define kDTHTagPickName 4007
#define kDTHTagPickAddr 4008
#define kDTHTagDash     4009
#define kDTHTagDestIcon 4010
#define kDTHTagDestName 4011
#define kDTHTagDestAddr 4012

@interface TripHistoryViewController ()
{
    NSMutableArray *tripArray;
    BOOL IsLoadNext;
    ConstantModel  *constantModel;

    // Receipt modal
    UIView *_receiptOverlay;
    UIView *_receiptSheet;
}

@end

@implementation TripHistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    tripArray =[[NSMutableArray alloc]init];
    constantModel =[ConstantModel getConstantsObject];;

    [self setupNewDesign];
    IsLoadNext =NO;
    [self gettripHistoryWithLoader:YES];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setUIFields];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) setUIFields{
    self.lblHeader.text = [LanguageHelper getStringWithKey:@"k_6_s4_a1_your_rides"];
    self.lblNoRec.text=[LanguageHelper getStringWithKey:@"k_17_s10_no_trips_avail"];
}

-(void)setThemeConstants{
}

- (void)setupNewDesign {
    for (UIView *v in [self.view.subviews copy]) { v.hidden = YES; }

    self.view.backgroundColor = [UIColor colorWithRed:0.97 green:0.97 blue:0.97 alpha:1];
    UILayoutGuide *safe = self.view.safeAreaLayoutGuide;
    UIColor *textMain = [UIColor colorNamed:@"color_app_label"] ?: [UIColor blackColor];

    UIView *header = [[UIView alloc] init];
    header.translatesAutoresizingMaskIntoConstraints = NO;
    header.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:header];

    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    backBtn.translatesAutoresizingMaskIntoConstraints = NO;
    backBtn.backgroundColor = [UIColor colorWithWhite:0.93 alpha:1];
    backBtn.layer.cornerRadius = 20;
    backBtn.tintColor = textMain;
    if (@available(iOS 13, *)) {
        UIImageSymbolConfiguration *cfg = [UIImageSymbolConfiguration configurationWithWeight:UIImageSymbolWeightMedium];
        [backBtn setImage:[[UIImage systemImageNamed:@"chevron.left" withConfiguration:cfg]
                           imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    } else {
        [backBtn setTitle:@"‹" forState:UIControlStateNormal];
        backBtn.titleLabel.font = [UIFont systemFontOfSize:26];
    }
    [backBtn addTarget:self action:@selector(ButtonBackAction:) forControlEvents:UIControlEventTouchUpInside];
    [header addSubview:backBtn];

    UILabel *titleLbl = [[UILabel alloc] init];
    titleLbl.translatesAutoresizingMaskIntoConstraints = NO;
    titleLbl.text = @"Tus viajes";
    titleLbl.font = FONTS_NOTO_BOLD(18);
    titleLbl.textColor = textMain;
    [header addSubview:titleLbl];
    self.lblHeader = titleLbl;

    UIView *hSep = [[UIView alloc] init];
    hSep.translatesAutoresizingMaskIntoConstraints = NO;
    hSep.backgroundColor = [UIColor colorWithWhite:0.88 alpha:1];
    [header addSubview:hSep];

    [NSLayoutConstraint activateConstraints:@[
        [header.topAnchor constraintEqualToAnchor:safe.topAnchor],
        [header.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [header.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [header.heightAnchor constraintEqualToConstant:64],
        [backBtn.leadingAnchor constraintEqualToAnchor:header.leadingAnchor constant:16],
        [backBtn.centerYAnchor constraintEqualToAnchor:header.centerYAnchor],
        [backBtn.widthAnchor constraintEqualToConstant:40],
        [backBtn.heightAnchor constraintEqualToConstant:40],
        [titleLbl.centerXAnchor constraintEqualToAnchor:header.centerXAnchor],
        [titleLbl.centerYAnchor constraintEqualToAnchor:header.centerYAnchor],
        [hSep.bottomAnchor constraintEqualToAnchor:header.bottomAnchor],
        [hSep.leadingAnchor constraintEqualToAnchor:header.leadingAnchor],
        [hSep.trailingAnchor constraintEqualToAnchor:header.trailingAnchor],
        [hSep.heightAnchor constraintEqualToConstant:1],
    ]];

    UITableView *tv = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    tv.translatesAutoresizingMaskIntoConstraints = NO;
    tv.backgroundColor = [UIColor colorWithRed:0.97 green:0.97 blue:0.97 alpha:1];
    tv.separatorStyle = UITableViewCellSeparatorStyleNone;
    tv.showsVerticalScrollIndicator = NO;
    tv.estimatedRowHeight = 180;
    tv.rowHeight = UITableViewAutomaticDimension;
    tv.contentInset = UIEdgeInsetsMake(8, 0, 16, 0);
    [tv registerClass:[UITableViewCell class] forCellReuseIdentifier:@"TripCard"];
    tv.dataSource = self;
    tv.delegate = self;
    [self.view addSubview:tv];
    self.tableView = tv;

    [NSLayoutConstraint activateConstraints:@[
        [tv.topAnchor constraintEqualToAnchor:header.bottomAnchor],
        [tv.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [tv.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [tv.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
    ]];

    UILabel *noRecLbl = [[UILabel alloc] init];
    noRecLbl.translatesAutoresizingMaskIntoConstraints = NO;
    noRecLbl.text = [LanguageHelper getStringWithKey:@"k_17_s10_no_trips_avail"];
    noRecLbl.textColor = [UIColor colorWithWhite:0.5 alpha:1];
    noRecLbl.font = FONTS_NOTO_REGULAR(15);
    noRecLbl.textAlignment = NSTextAlignmentCenter;
    noRecLbl.hidden = YES;
    [self.view addSubview:noRecLbl];
    self.lblNoRec = noRecLbl;

    [NSLayoutConstraint activateConstraints:@[
        [noRecLbl.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [noRecLbl.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor],
    ]];
}

- (void)buildTripCardInCell:(UITableViewCell *)cell {
    UIView *cv = cell.contentView;

    UIView *card = [[UIView alloc] init];
    card.translatesAutoresizingMaskIntoConstraints = NO;
    card.tag = kDTHTagCard;
    card.backgroundColor = [UIColor whiteColor];
    card.layer.cornerRadius = 16;
    card.layer.shadowColor = [UIColor blackColor].CGColor;
    card.layer.shadowOpacity = 0.08;
    card.layer.shadowRadius = 8;
    card.layer.shadowOffset = CGSizeMake(0, 2);
    [cv addSubview:card];

    [NSLayoutConstraint activateConstraints:@[
        [card.topAnchor constraintEqualToAnchor:cv.topAnchor constant:8],
        [card.bottomAnchor constraintEqualToAnchor:cv.bottomAnchor constant:-4],
        [card.leadingAnchor constraintEqualToAnchor:cv.leadingAnchor constant:12],
        [card.trailingAnchor constraintEqualToAnchor:cv.trailingAnchor constant:-12],
    ]];

    UILabel *dateLbl = [[UILabel alloc] init];
    dateLbl.translatesAutoresizingMaskIntoConstraints = NO;
    dateLbl.tag = kDTHTagDate;
    dateLbl.font = FONTS_NOTO_REGULAR(13);
    dateLbl.textColor = [UIColor colorWithWhite:0.5 alpha:1];
    [card addSubview:dateLbl];

    UIView *badge = [[UIView alloc] init];
    badge.translatesAutoresizingMaskIntoConstraints = NO;
    badge.tag = kDTHTagBadgeBg;
    badge.layer.cornerRadius = 10;
    [card addSubview:badge];

    UILabel *badgeLbl = [[UILabel alloc] init];
    badgeLbl.translatesAutoresizingMaskIntoConstraints = NO;
    badgeLbl.tag = kDTHTagBadgeLbl;
    badgeLbl.font = FONTS_NOTO_REGULAR(12);
    [badge addSubview:badgeLbl];

    UIView *sep = [[UIView alloc] init];
    sep.translatesAutoresizingMaskIntoConstraints = NO;
    sep.tag = kDTHTagSep;
    sep.backgroundColor = [UIColor colorWithWhite:0.88 alpha:1];
    [card addSubview:sep];

    UIImageView *pickIcon = [[UIImageView alloc] init];
    pickIcon.translatesAutoresizingMaskIntoConstraints = NO;
    pickIcon.tag = kDTHTagPickIcon;
    pickIcon.contentMode = UIViewContentModeScaleAspectFit;
    UIImage *pickImg = [UIImage imageNamed:@"ic_trip_pickup"];
    if (!pickImg && @available(iOS 13, *)) {
        UIImageSymbolConfiguration *cfg = [UIImageSymbolConfiguration configurationWithPointSize:20 weight:UIImageSymbolWeightMedium];
        pickImg = [[UIImage systemImageNamed:@"mappin.circle.fill" withConfiguration:cfg]
                   imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        pickIcon.tintColor = [UIColor colorWithRed:0.85 green:0.15 blue:0.15 alpha:1];
    }
    pickIcon.image = pickImg;
    [card addSubview:pickIcon];

    UILabel *pickName = [[UILabel alloc] init];
    pickName.translatesAutoresizingMaskIntoConstraints = NO;
    pickName.tag = kDTHTagPickName;
    pickName.font = FONTS_NOTO_BOLD(14);
    pickName.numberOfLines = 1;
    [card addSubview:pickName];

    UILabel *pickAddr = [[UILabel alloc] init];
    pickAddr.translatesAutoresizingMaskIntoConstraints = NO;
    pickAddr.tag = kDTHTagPickAddr;
    pickAddr.font = FONTS_NOTO_REGULAR(12);
    pickAddr.textColor = [UIColor colorWithWhite:0.5 alpha:1];
    pickAddr.numberOfLines = 1;
    [card addSubview:pickAddr];

    UIView *dash = [[UIView alloc] init];
    dash.translatesAutoresizingMaskIntoConstraints = NO;
    dash.tag = kDTHTagDash;
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(2, 8), NO, 0);
    [[UIColor colorWithWhite:0.72 alpha:1] setFill];
    UIRectFill(CGRectMake(0, 0, 2, 4));
    UIImage *dashImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    dash.backgroundColor = [UIColor colorWithPatternImage:dashImg];
    [card addSubview:dash];

    UIImageView *destIcon = [[UIImageView alloc] init];
    destIcon.translatesAutoresizingMaskIntoConstraints = NO;
    destIcon.tag = kDTHTagDestIcon;
    destIcon.contentMode = UIViewContentModeScaleAspectFit;
    UIImage *destImg = [UIImage imageNamed:@"ic_trip_drop"];
    if (!destImg && @available(iOS 13, *)) {
        UIImageSymbolConfiguration *cfg = [UIImageSymbolConfiguration configurationWithPointSize:20 weight:UIImageSymbolWeightMedium];
        destImg = [[UIImage systemImageNamed:@"flag.circle.fill" withConfiguration:cfg]
                   imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        destIcon.tintColor = [UIColor colorWithRed:0.1 green:0.65 blue:0.3 alpha:1];
    }
    destIcon.image = destImg;
    [card addSubview:destIcon];

    UILabel *destName = [[UILabel alloc] init];
    destName.translatesAutoresizingMaskIntoConstraints = NO;
    destName.tag = kDTHTagDestName;
    destName.font = FONTS_NOTO_BOLD(14);
    destName.numberOfLines = 1;
    [card addSubview:destName];

    UILabel *destAddr = [[UILabel alloc] init];
    destAddr.translatesAutoresizingMaskIntoConstraints = NO;
    destAddr.tag = kDTHTagDestAddr;
    destAddr.font = FONTS_NOTO_REGULAR(12);
    destAddr.textColor = [UIColor colorWithWhite:0.5 alpha:1];
    destAddr.numberOfLines = 1;
    [card addSubview:destAddr];

    CGFloat iconSize = 26.0;
    CGFloat pad = 16.0;

    [NSLayoutConstraint activateConstraints:@[
        [badgeLbl.topAnchor constraintEqualToAnchor:badge.topAnchor constant:5],
        [badgeLbl.bottomAnchor constraintEqualToAnchor:badge.bottomAnchor constant:-5],
        [badgeLbl.leadingAnchor constraintEqualToAnchor:badge.leadingAnchor constant:10],
        [badgeLbl.trailingAnchor constraintEqualToAnchor:badge.trailingAnchor constant:-10],

        [dateLbl.topAnchor constraintEqualToAnchor:card.topAnchor constant:16],
        [dateLbl.leadingAnchor constraintEqualToAnchor:card.leadingAnchor constant:pad],
        [badge.centerYAnchor constraintEqualToAnchor:dateLbl.centerYAnchor],
        [badge.trailingAnchor constraintEqualToAnchor:card.trailingAnchor constant:-pad],
        [dateLbl.trailingAnchor constraintLessThanOrEqualToAnchor:badge.leadingAnchor constant:-8],

        [sep.topAnchor constraintEqualToAnchor:dateLbl.bottomAnchor constant:12],
        [sep.leadingAnchor constraintEqualToAnchor:card.leadingAnchor],
        [sep.trailingAnchor constraintEqualToAnchor:card.trailingAnchor],
        [sep.heightAnchor constraintEqualToConstant:1],

        [pickIcon.topAnchor constraintEqualToAnchor:sep.bottomAnchor constant:14],
        [pickIcon.leadingAnchor constraintEqualToAnchor:card.leadingAnchor constant:pad],
        [pickIcon.widthAnchor constraintEqualToConstant:iconSize],
        [pickIcon.heightAnchor constraintEqualToConstant:iconSize],

        [pickName.leadingAnchor constraintEqualToAnchor:pickIcon.trailingAnchor constant:12],
        [pickName.trailingAnchor constraintEqualToAnchor:card.trailingAnchor constant:-pad],
        [pickName.topAnchor constraintEqualToAnchor:pickIcon.topAnchor],

        [pickAddr.leadingAnchor constraintEqualToAnchor:pickName.leadingAnchor],
        [pickAddr.trailingAnchor constraintEqualToAnchor:card.trailingAnchor constant:-pad],
        [pickAddr.topAnchor constraintEqualToAnchor:pickName.bottomAnchor constant:2],

        [dash.topAnchor constraintEqualToAnchor:pickIcon.bottomAnchor constant:4],
        [dash.centerXAnchor constraintEqualToAnchor:pickIcon.centerXAnchor],
        [dash.widthAnchor constraintEqualToConstant:2],
        [dash.bottomAnchor constraintEqualToAnchor:destIcon.topAnchor constant:-4],

        [destIcon.topAnchor constraintEqualToAnchor:pickAddr.bottomAnchor constant:12],
        [destIcon.leadingAnchor constraintEqualToAnchor:card.leadingAnchor constant:pad],
        [destIcon.widthAnchor constraintEqualToConstant:iconSize],
        [destIcon.heightAnchor constraintEqualToConstant:iconSize],

        [destName.leadingAnchor constraintEqualToAnchor:destIcon.trailingAnchor constant:12],
        [destName.trailingAnchor constraintEqualToAnchor:card.trailingAnchor constant:-pad],
        [destName.topAnchor constraintEqualToAnchor:destIcon.topAnchor],

        [destAddr.leadingAnchor constraintEqualToAnchor:destName.leadingAnchor],
        [destAddr.trailingAnchor constraintEqualToAnchor:card.trailingAnchor constant:-pad],
        [destAddr.topAnchor constraintEqualToAnchor:destName.bottomAnchor constant:2],
        [destAddr.bottomAnchor constraintEqualToAnchor:card.bottomAnchor constant:-16],
    ]];
}

- (void)populateTripCard:(UITableViewCell *)cell withTrip:(TripModel *)trip {
    UILabel *dateLbl  = (UILabel *)[cell.contentView viewWithTag:kDTHTagDate];
    UIView  *badge    = [cell.contentView viewWithTag:kDTHTagBadgeBg];
    UILabel *badgeLbl = (UILabel *)[cell.contentView viewWithTag:kDTHTagBadgeLbl];
    UILabel *pickName = (UILabel *)[cell.contentView viewWithTag:kDTHTagPickName];
    UILabel *pickAddr = (UILabel *)[cell.contentView viewWithTag:kDTHTagPickAddr];
    UILabel *destName = (UILabel *)[cell.contentView viewWithTag:kDTHTagDestName];
    UILabel *destAddr = (UILabel *)[cell.contentView viewWithTag:kDTHTagDestAddr];

    dateLbl.text = [Utilities GetGMTDatetoLocalTZ:trip.trip_date :APP_DATE_FORMAT];

    NSArray *pickParts = [trip.pickupLocationApp componentsSeparatedByString:@","];
    pickName.text = [pickParts.firstObject stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    pickAddr.text = pickParts.count > 1
        ? [[[pickParts subarrayWithRange:NSMakeRange(1, pickParts.count - 1)] componentsJoinedByString:@","]
           stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]
        : @"";

    NSArray *dropParts = [trip.dropLocationApp componentsSeparatedByString:@","];
    destName.text = [dropParts.firstObject stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    destAddr.text = dropParts.count > 1
        ? [[[dropParts subarrayWithRange:NSMakeRange(1, dropParts.count - 1)] componentsJoinedByString:@","]
           stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]
        : @"";

    NSString *statusText;
    UIColor  *badgeBg;
    UIColor  *badgeTextColor;

    if ([trip isTripCancelled]) {
        statusText = [LanguageHelper getStringWithKey:@"k_r8_s10_cancelled" defaultValue:@"Cancelado"];
        badgeBg = [UIColor colorWithRed:1.0 green:0.9 blue:0.9 alpha:1];
        badgeTextColor = [UIColor colorWithRed:0.85 green:0.15 blue:0.15 alpha:1];
    } else if ([trip.trip_Status isEqualToString:TS_END] && [trip.trip_pay_status isEqualToString:TS_PAID]) {
        statusText = [LanguageHelper getStringWithKey:@"k_com_18_completed" defaultValue:@"Terminado"];
        badgeBg = [UIColor colorWithWhite:0.88 alpha:1];
        badgeTextColor = [UIColor colorWithWhite:0.45 alpha:1];
    } else if ([trip.trip_Status isEqualToString:TS_END]) {
        statusText = [LanguageHelper getStringWithKey:@"k_con_21_trip_payment_awaited" defaultValue:@"Pago pendiente"];
        badgeBg = [UIColor colorWithWhite:0.88 alpha:1];
        badgeTextColor = [UIColor colorWithWhite:0.45 alpha:1];
    } else if ([trip.trip_Status isEqualToString:TS_REQUEST]) {
        statusText = [LanguageHelper getStringWithKey:@"k_con_21_request" defaultValue:@"Solicitud"];
        badgeBg = [UIColor colorWithWhite:0.88 alpha:1];
        badgeTextColor = [UIColor colorWithWhite:0.45 alpha:1];
    } else if ([trip.trip_Status isEqualToString:TS_ASSIGNED]) {
        statusText = [LanguageHelper getStringWithKey:@"k_con_21_assigned" defaultValue:@"Asignado"];
        badgeBg = [UIColor colorWithWhite:0.88 alpha:1];
        badgeTextColor = [UIColor colorWithWhite:0.45 alpha:1];
    } else {
        statusText = [LanguageHelper getStringWithKey:@"p_14_s4_ongoing" defaultValue:@"En curso"];
        badgeBg = [UIColor colorWithWhite:0.88 alpha:1];
        badgeTextColor = [UIColor colorWithWhite:0.45 alpha:1];
    }

    badge.backgroundColor = badgeBg;
    badgeLbl.text = statusText;
    badgeLbl.textColor = badgeTextColor;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"TripDetailsViewController"]) {
        
        TripDetailsViewController *details =(TripDetailsViewController *)[segue destinationViewController];
        
        details.trip = [tripArray objectAtIndex:[sender floatValue]];
//        details.constantModel=constantModel;
    }
}

- (IBAction)ButtonBackAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)gettripHistory{
    [self gettripHistoryWithLoader:YES];
}

-(void)gettripHistoryWithLoader:(BOOL)showLoader{
    NSDictionary *dict1 = [[NSUserDefaults standardUserDefaults]objectForKey:P_USER_DICT];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{
        
        P_DRIVER_ID          :[dict1 objectForKey:P_DRIVER_ID],
        @"limit"              : @SIZE,
        @"statuses":@"completed,paid,cancel,p_cancel_drop,p_cancel_pickup,expired,paid_cancel"
    }];
    
    [dict setObject:[NSString stringWithFormat:@"%lu", (unsigned long)tripArray.count] forKey:@"offset"];
    if (showLoader) {
        [UtilityClass setLH:NO wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
    }
    [GIC mkwu:TRIP_GETTRIP
                  d:dict
      isa:NO
           cb:^(id results, NSError *error) {
        if ([[[results objectForKey:P_STATUS]  uppercaseString]isEqualToString:@"OK"]) {
            NSArray *arrtrip =[[NSArray alloc]init];
            if ([[results objectForKey:P_RESPONSE] isKindOfClass:[NSArray class]]) {
                arrtrip = [results objectForKey:P_RESPONSE];
                for (int i=0; i<arrtrip.count; i++) {
                    TripModel *Trip = [[TripModel alloc] initItemWithDict:[arrtrip objectAtIndex:i]];
                    [self->tripArray addObject:Trip];
                }
            }
            if (arrtrip.count<SIZE) {
                self->IsLoadNext =YES;
            }
            if (self->tripArray.count ==0 ) {
                self.lblNoRec.hidden =NO;
            }
            else{
                self.lblNoRec.hidden =YES;
            }
            
            [self.tableView reloadData];
        }
        if (showLoader) {
            [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
        }
    }];
    
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    
    return tripArray.count;
    
}



- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TripCard" forIndexPath:indexPath];
    cell.selectionStyle =UITableViewCellSelectionStyleNone;
    cell.backgroundColor=[UIColor clearColor];
    if (![cell.contentView viewWithTag:kDTHTagCard]) {
        [self buildTripCardInCell:cell];
    }
    [self populateTripCard:cell withTrip:[tripArray objectAtIndex:indexPath.row]];
    if (indexPath.row >tripArray.count-2 && !IsLoadNext) {
        [self gettripHistory];
    }
    return cell;
}



-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewAutomaticDimension;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self showReceiptSheetForTrip:[tripArray objectAtIndex:indexPath.row]];
}

#pragma mark - Receipt Modal

- (void)showReceiptSheetForTrip:(TripModel *)trip {
    if (_receiptOverlay) return;

    UIWindow *window = self.view.window ?: UIApplication.sharedApplication.keyWindow;
    CGRect wb = window.bounds;

    UIView *overlay = [[UIView alloc] initWithFrame:wb];
    overlay.backgroundColor = [UIColor colorWithWhite:0 alpha:0.45];
    overlay.alpha = 0;
    [overlay addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissReceiptSheet)]];
    [window addSubview:overlay];
    _receiptOverlay = overlay;

    CGFloat sheetH = wb.size.height * 0.90;
    UIView *sheet = [[UIView alloc] initWithFrame:CGRectMake(0, wb.size.height, wb.size.width, sheetH)];
    sheet.backgroundColor = [UIColor whiteColor];
    sheet.layer.cornerRadius = 20;
    sheet.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
    sheet.clipsToBounds = YES;
    [window addSubview:sheet];
    _receiptSheet = sheet;

    [self buildReceiptContent:trip inSheet:sheet];
    [sheet setNeedsLayout];
    [sheet layoutIfNeeded];

    UIView *ticketView = [sheet viewWithTag:kDTHReceiptNotchGuide + 1];
    if (ticketView) {
        UIView *notchGuide = [ticketView viewWithTag:kDTHReceiptNotchGuide];
        [self applyTicketMaskToView:ticketView atNotchY:notchGuide ? notchGuide.frame.origin.y : 0];
    }

    [UIView animateWithDuration:0.28 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        overlay.alpha = 1;
        sheet.frame = CGRectMake(0, wb.size.height - sheetH, wb.size.width, sheetH);
    } completion:nil];
}

- (void)buildReceiptContent:(TripModel *)trip inSheet:(UIView *)sheet {
    CGFloat sw = sheet.bounds.size.width;
    UIColor *textMain = [UIColor colorNamed:@"color_app_label"] ?: [UIColor blackColor];
    UIColor *textGray = [UIColor colorWithWhite:0.5 alpha:1];
    UIColor *yellow   = [UIColor colorNamed:@"app_theame"] ?: [UIColor colorWithRed:0.92 green:0.71 blue:0.09 alpha:1];
    CGFloat pad = 20.0;

    // Header
    UIView *header = [[UIView alloc] init];
    header.translatesAutoresizingMaskIntoConstraints = NO;
    header.backgroundColor = [UIColor whiteColor];
    [sheet addSubview:header];

    UILabel *titleLbl = [[UILabel alloc] init];
    titleLbl.translatesAutoresizingMaskIntoConstraints = NO;
    titleLbl.text = @"Recibo";
    titleLbl.font = FONTS_NOTO_BOLD(18);
    titleLbl.textColor = textMain;
    [header addSubview:titleLbl];

    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    closeBtn.translatesAutoresizingMaskIntoConstraints = NO;
    closeBtn.backgroundColor = [UIColor colorWithWhite:0.93 alpha:1];
    closeBtn.layer.cornerRadius = 16;
    closeBtn.tintColor = textMain;
    if (@available(iOS 13, *)) {
        [closeBtn setImage:[UIImage systemImageNamed:@"xmark"] forState:UIControlStateNormal];
    } else {
        [closeBtn setTitle:@"✕" forState:UIControlStateNormal];
    }
    [closeBtn addTarget:self action:@selector(dismissReceiptSheet) forControlEvents:UIControlEventTouchUpInside];
    [header addSubview:closeBtn];

    UIView *hSep = [[UIView alloc] init];
    hSep.translatesAutoresizingMaskIntoConstraints = NO;
    hSep.backgroundColor = [UIColor colorWithWhite:0.88 alpha:1];
    [header addSubview:hSep];

    [NSLayoutConstraint activateConstraints:@[
        [header.topAnchor constraintEqualToAnchor:sheet.topAnchor],
        [header.leadingAnchor constraintEqualToAnchor:sheet.leadingAnchor],
        [header.trailingAnchor constraintEqualToAnchor:sheet.trailingAnchor],
        [header.heightAnchor constraintEqualToConstant:60],
        [titleLbl.centerXAnchor constraintEqualToAnchor:header.centerXAnchor],
        [titleLbl.centerYAnchor constraintEqualToAnchor:header.centerYAnchor],
        [closeBtn.trailingAnchor constraintEqualToAnchor:header.trailingAnchor constant:-pad],
        [closeBtn.centerYAnchor constraintEqualToAnchor:header.centerYAnchor],
        [closeBtn.widthAnchor constraintEqualToConstant:32],
        [closeBtn.heightAnchor constraintEqualToConstant:32],
        [hSep.bottomAnchor constraintEqualToAnchor:header.bottomAnchor],
        [hSep.leadingAnchor constraintEqualToAnchor:header.leadingAnchor],
        [hSep.trailingAnchor constraintEqualToAnchor:header.trailingAnchor],
        [hSep.heightAnchor constraintEqualToConstant:1],
    ]];

    // Scroll + content
    UIScrollView *scroll = [[UIScrollView alloc] init];
    scroll.translatesAutoresizingMaskIntoConstraints = NO;
    scroll.showsVerticalScrollIndicator = NO;
    [sheet addSubview:scroll];

    UIView *content = [[UIView alloc] init];
    content.translatesAutoresizingMaskIntoConstraints = NO;
    [scroll addSubview:content];

    [NSLayoutConstraint activateConstraints:@[
        [scroll.topAnchor constraintEqualToAnchor:header.bottomAnchor],
        [scroll.leadingAnchor constraintEqualToAnchor:sheet.leadingAnchor],
        [scroll.trailingAnchor constraintEqualToAnchor:sheet.trailingAnchor],
        [scroll.bottomAnchor constraintEqualToAnchor:sheet.bottomAnchor],
        [content.topAnchor constraintEqualToAnchor:scroll.topAnchor],
        [content.leadingAnchor constraintEqualToAnchor:scroll.leadingAnchor],
        [content.trailingAnchor constraintEqualToAnchor:scroll.trailingAnchor],
        [content.bottomAnchor constraintEqualToAnchor:scroll.bottomAnchor],
        [content.widthAnchor constraintEqualToConstant:sw],
    ]];

    // Rider avatar
    UIImageView *avatar = [[UIImageView alloc] init];
    avatar.translatesAutoresizingMaskIntoConstraints = NO;
    avatar.layer.cornerRadius = 30;
    avatar.clipsToBounds = YES;
    avatar.contentMode = UIViewContentModeScaleAspectFill;
    avatar.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
    if (trip.user.u_profile_image_path.length > 0) {
        [avatar sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", url_base_images, trip.user.u_profile_image_path]]
                  placeholderImage:[UIImage imageNamed:@"Profile Icon Crop Image"]];
    }
    [content addSubview:avatar];

    UILabel *personName = [[UILabel alloc] init];
    personName.translatesAutoresizingMaskIntoConstraints = NO;
    personName.font = FONTS_NOTO_BOLD(15);
    personName.textColor = textMain;
    NSString *fullName = [[NSString stringWithFormat:@"%@ %@", trip.user.u_fname ?: @"", trip.user.u_lname ?: @""]
                          stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    personName.text = fullName.length > 0 ? fullName : [LanguageHelper getStringWithKey:@"k_s3_passenger_name" defaultValue:@"Pasajero"];
    [content addSubview:personName];

    UILabel *ratingLbl = [[UILabel alloc] init];
    ratingLbl.translatesAutoresizingMaskIntoConstraints = NO;
    ratingLbl.font = FONTS_NOTO_REGULAR(13);
    ratingLbl.textColor = textGray;

    NSMutableAttributedString *ratingStr = [[NSMutableAttributedString alloc] init];
    if (@available(iOS 13, *)) {
        UIImageSymbolConfiguration *cfg = [UIImageSymbolConfiguration configurationWithPointSize:13 weight:UIImageSymbolWeightMedium];
        UIImage *base = [UIImage systemImageNamed:@"star.fill" withConfiguration:cfg];
        UIGraphicsBeginImageContextWithOptions(base.size, NO, 0);
        [base drawInRect:CGRectMake(0, 0, base.size.width, base.size.height)];
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        CGContextSetBlendMode(ctx, kCGBlendModeSourceIn);
        [yellow setFill];
        CGContextFillRect(ctx, CGRectMake(0, 0, base.size.width, base.size.height));
        UIImage *yellowStar = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        NSTextAttachment *att = [[NSTextAttachment alloc] init];
        att.image = yellowStar;
        att.bounds = CGRectMake(0, -1, 13, 13);
        [ratingStr appendAttributedString:[NSAttributedString attributedStringWithAttachment:att]];
        [ratingStr appendAttributedString:[[NSAttributedString alloc] initWithString:
            [NSString stringWithFormat:@" %.1f (%d)", trip.user.rating, trip.user.rating_count]
            attributes:@{ NSFontAttributeName: ratingLbl.font, NSForegroundColorAttributeName: textGray }]];
    } else {
        ratingStr = [[NSMutableAttributedString alloc] initWithString:
            [NSString stringWithFormat:@"★ %.1f (%d)", trip.user.rating, trip.user.rating_count]];
    }
    ratingLbl.attributedText = ratingStr;
    [content addSubview:ratingLbl];

    [NSLayoutConstraint activateConstraints:@[
        [avatar.topAnchor constraintEqualToAnchor:content.topAnchor constant:20],
        [avatar.leadingAnchor constraintEqualToAnchor:content.leadingAnchor constant:pad],
        [avatar.widthAnchor constraintEqualToConstant:60],
        [avatar.heightAnchor constraintEqualToConstant:60],
        [personName.leadingAnchor constraintEqualToAnchor:avatar.trailingAnchor constant:12],
        [personName.trailingAnchor constraintEqualToAnchor:content.trailingAnchor constant:-pad],
        [personName.topAnchor constraintEqualToAnchor:avatar.topAnchor constant:10],
        [ratingLbl.leadingAnchor constraintEqualToAnchor:personName.leadingAnchor],
        [ratingLbl.topAnchor constraintEqualToAnchor:personName.bottomAnchor constant:4],
    ]];

    // Gray ticket container
    UIView *ticket = [[UIView alloc] init];
    ticket.translatesAutoresizingMaskIntoConstraints = NO;
    ticket.tag = kDTHReceiptNotchGuide + 1;
    ticket.backgroundColor = [UIColor colorWithWhite:0.96 alpha:1];
    [content addSubview:ticket];

    [NSLayoutConstraint activateConstraints:@[
        [ticket.topAnchor constraintEqualToAnchor:avatar.bottomAnchor constant:16],
        [ticket.leadingAnchor constraintEqualToAnchor:content.leadingAnchor constant:pad],
        [ticket.trailingAnchor constraintEqualToAnchor:content.trailingAnchor constant:-pad],
    ]];

    CGFloat tpad = 16.0;
    CGFloat iconW = 22.0;

    UIImageView *pickIcon = [[UIImageView alloc] init];
    pickIcon.translatesAutoresizingMaskIntoConstraints = NO;
    pickIcon.contentMode = UIViewContentModeScaleAspectFit;
    UIImage *pickImg = [UIImage imageNamed:@"ic_trip_pickup"];
    if (!pickImg && @available(iOS 13, *)) {
        UIImageSymbolConfiguration *cfg = [UIImageSymbolConfiguration configurationWithPointSize:18 weight:UIImageSymbolWeightMedium];
        pickImg = [[UIImage systemImageNamed:@"mappin.circle.fill" withConfiguration:cfg] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        pickIcon.tintColor = [UIColor colorWithRed:0.85 green:0.15 blue:0.15 alpha:1];
    }
    pickIcon.image = pickImg;
    [ticket addSubview:pickIcon];

    NSArray *pickParts = [trip.pickupLocationApp componentsSeparatedByString:@","];
    NSString *pickLocName = pickParts.count > 0 ? [pickParts[0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] : @"";
    NSString *pickAddrStr = pickParts.count > 1 ? [[[pickParts subarrayWithRange:NSMakeRange(1, pickParts.count - 1)] componentsJoinedByString:@","] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] : @"";

    UILabel *pickNameLbl = [[UILabel alloc] init];
    pickNameLbl.translatesAutoresizingMaskIntoConstraints = NO;
    pickNameLbl.text = pickLocName;
    pickNameLbl.font = FONTS_NOTO_BOLD(13);
    pickNameLbl.textColor = textMain;
    pickNameLbl.numberOfLines = 1;
    [ticket addSubview:pickNameLbl];

    UILabel *pickAddrLbl = [[UILabel alloc] init];
    pickAddrLbl.translatesAutoresizingMaskIntoConstraints = NO;
    pickAddrLbl.text = pickAddrStr;
    pickAddrLbl.font = FONTS_NOTO_REGULAR(11);
    pickAddrLbl.textColor = textGray;
    pickAddrLbl.numberOfLines = 2;
    [ticket addSubview:pickAddrLbl];

    UIView *dashLine = [[UIView alloc] init];
    dashLine.translatesAutoresizingMaskIntoConstraints = NO;
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(2, 8), NO, 0);
    [[UIColor colorWithWhite:0.72 alpha:1] setFill];
    UIRectFill(CGRectMake(0, 0, 2, 4));
    UIImage *dashImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    dashLine.backgroundColor = [UIColor colorWithPatternImage:dashImg];
    [ticket addSubview:dashLine];

    UIImageView *destIcon = [[UIImageView alloc] init];
    destIcon.translatesAutoresizingMaskIntoConstraints = NO;
    destIcon.contentMode = UIViewContentModeScaleAspectFit;
    UIImage *destImg = [UIImage imageNamed:@"ic_trip_drop"];
    if (!destImg && @available(iOS 13, *)) {
        UIImageSymbolConfiguration *cfg = [UIImageSymbolConfiguration configurationWithPointSize:18 weight:UIImageSymbolWeightMedium];
        destImg = [[UIImage systemImageNamed:@"flag.circle.fill" withConfiguration:cfg] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        destIcon.tintColor = [UIColor colorWithRed:0.1 green:0.65 blue:0.3 alpha:1];
    }
    destIcon.image = destImg;
    [ticket addSubview:destIcon];

    NSArray *dropParts = [trip.dropLocationApp componentsSeparatedByString:@","];
    NSString *dropLocName = dropParts.count > 0 ? [dropParts[0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] : @"";
    NSString *dropAddrStr = dropParts.count > 1 ? [[[dropParts subarrayWithRange:NSMakeRange(1, dropParts.count - 1)] componentsJoinedByString:@","] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] : @"";

    UILabel *destNameLbl = [[UILabel alloc] init];
    destNameLbl.translatesAutoresizingMaskIntoConstraints = NO;
    destNameLbl.text = dropLocName;
    destNameLbl.font = FONTS_NOTO_BOLD(13);
    destNameLbl.textColor = textMain;
    destNameLbl.numberOfLines = 1;
    [ticket addSubview:destNameLbl];

    UILabel *destAddrLbl = [[UILabel alloc] init];
    destAddrLbl.translatesAutoresizingMaskIntoConstraints = NO;
    destAddrLbl.text = dropAddrStr;
    destAddrLbl.font = FONTS_NOTO_REGULAR(11);
    destAddrLbl.textColor = textGray;
    destAddrLbl.numberOfLines = 2;
    [ticket addSubview:destAddrLbl];

    UIView *notchGuide = [[UIView alloc] init];
    notchGuide.translatesAutoresizingMaskIntoConstraints = NO;
    notchGuide.tag = kDTHReceiptNotchGuide;
    notchGuide.backgroundColor = [UIColor clearColor];
    [ticket addSubview:notchGuide];

    UIView *notchDivider = [[UIView alloc] init];
    notchDivider.translatesAutoresizingMaskIntoConstraints = NO;
    notchDivider.backgroundColor = [UIColor colorWithWhite:0.82 alpha:1];
    [ticket addSubview:notchDivider];

    NSString *currency = [CityModel getCityByCityId:trip.city_id].city_cur ?: @"";

    UILabel *statusKey = [self dReceiptKeyLabel:@"Estatus"];
    UILabel *statusVal = [self dReceiptValueLabel:@""];
    [ticket addSubview:statusKey]; [ticket addSubview:statusVal];
    if ([trip isTripCancelled]) {
        statusVal.text = @"Cancelado";
        statusVal.textColor = [UIColor colorWithRed:0.85 green:0.15 blue:0.15 alpha:1];
    } else if ([trip.trip_Status isEqualToString:TS_END]) {
        statusVal.text = @"Terminado";
    } else {
        statusVal.text = trip.trip_Status ?: @"-";
    }

    UILabel *dateKey = [self dReceiptKeyLabel:@"Fecha / Hora"];
    UILabel *dateVal = [self dReceiptValueLabel:[Utilities GetGMTDatetoLocalTZ:trip.trip_date :APP_DATE_FORMAT] ?: @"-"];
    [ticket addSubview:dateKey]; [ticket addSubview:dateVal];

    UILabel *distKey = [self dReceiptKeyLabel:@"Distancia"];
    UILabel *distVal = [self dReceiptValueLabel:trip.trip_distance.length > 0 ? [NSString stringWithFormat:@"%@ km", trip.trip_distance] : @"-"];
    [ticket addSubview:distKey]; [ticket addSubview:distVal];

    UILabel *idKey = [self dReceiptKeyLabel:@"ID del Conductor"];
    UILabel *idVal = [self dReceiptValueLabel:trip.driver.car_registration_no ?: @"-"];
    [ticket addSubview:idKey]; [ticket addSubview:idVal];

    UIView *fareSep = [[UIView alloc] init];
    fareSep.translatesAutoresizingMaskIntoConstraints = NO;
    fareSep.backgroundColor = [UIColor colorWithWhite:0.85 alpha:1];
    [ticket addSubview:fareSep];

    UILabel *taxKey = [self dReceiptKeyLabel:@"Impuestos"];
    UILabel *taxVal = [self dReceiptValueLabel:trip.tax_amount_r.length > 0 ? [NSString stringWithFormat:@"%@ %@", trip.tax_amount_r, currency] : [NSString stringWithFormat:@"0.00 %@", currency]];
    [ticket addSubview:taxKey]; [ticket addSubview:taxVal];

    UILabel *fareKey = [self dReceiptKeyLabel:@"Traslado"];
    UILabel *fareVal = [self dReceiptValueLabel:trip.trip_fare.length > 0 ? [NSString stringWithFormat:@"%@ %@", trip.trip_fare, currency] : [NSString stringWithFormat:@"0.00 %@", currency]];
    [ticket addSubview:fareKey]; [ticket addSubview:fareVal];

    UILabel *totalKey = [[UILabel alloc] init];
    totalKey.translatesAutoresizingMaskIntoConstraints = NO;
    totalKey.text = @"Total";
    totalKey.font = FONTS_NOTO_BOLD(15);
    totalKey.textColor = textMain;
    [ticket addSubview:totalKey];

    UILabel *totalVal = [[UILabel alloc] init];
    totalVal.translatesAutoresizingMaskIntoConstraints = NO;
    totalVal.text = [NSString stringWithFormat:@"%.2f %@", [trip.tax_amount_r floatValue] + [trip.trip_fare floatValue], currency];
    totalVal.font = FONTS_NOTO_BOLD(15);
    totalVal.textColor = textMain;
    totalVal.textAlignment = NSTextAlignmentRight;
    [ticket addSubview:totalVal];

    UIView *bottomSpacer = [[UIView alloc] init];
    bottomSpacer.translatesAutoresizingMaskIntoConstraints = NO;
    [ticket addSubview:bottomSpacer];

    [NSLayoutConstraint activateConstraints:@[
        [pickIcon.topAnchor constraintEqualToAnchor:ticket.topAnchor constant:tpad],
        [pickIcon.leadingAnchor constraintEqualToAnchor:ticket.leadingAnchor constant:tpad],
        [pickIcon.widthAnchor constraintEqualToConstant:iconW],
        [pickIcon.heightAnchor constraintEqualToConstant:iconW],
        [pickNameLbl.leadingAnchor constraintEqualToAnchor:pickIcon.trailingAnchor constant:10],
        [pickNameLbl.trailingAnchor constraintEqualToAnchor:ticket.trailingAnchor constant:-tpad],
        [pickNameLbl.topAnchor constraintEqualToAnchor:pickIcon.topAnchor],
        [pickAddrLbl.leadingAnchor constraintEqualToAnchor:pickNameLbl.leadingAnchor],
        [pickAddrLbl.trailingAnchor constraintEqualToAnchor:pickNameLbl.trailingAnchor],
        [pickAddrLbl.topAnchor constraintEqualToAnchor:pickNameLbl.bottomAnchor constant:2],
        [dashLine.topAnchor constraintEqualToAnchor:pickIcon.bottomAnchor constant:3],
        [dashLine.centerXAnchor constraintEqualToAnchor:pickIcon.centerXAnchor],
        [dashLine.widthAnchor constraintEqualToConstant:2],
        [dashLine.bottomAnchor constraintEqualToAnchor:destIcon.topAnchor constant:-3],
        [destIcon.topAnchor constraintEqualToAnchor:pickAddrLbl.bottomAnchor constant:10],
        [destIcon.leadingAnchor constraintEqualToAnchor:ticket.leadingAnchor constant:tpad],
        [destIcon.widthAnchor constraintEqualToConstant:iconW],
        [destIcon.heightAnchor constraintEqualToConstant:iconW],
        [destNameLbl.leadingAnchor constraintEqualToAnchor:destIcon.trailingAnchor constant:10],
        [destNameLbl.trailingAnchor constraintEqualToAnchor:ticket.trailingAnchor constant:-tpad],
        [destNameLbl.topAnchor constraintEqualToAnchor:destIcon.topAnchor],
        [destAddrLbl.leadingAnchor constraintEqualToAnchor:destNameLbl.leadingAnchor],
        [destAddrLbl.trailingAnchor constraintEqualToAnchor:destNameLbl.trailingAnchor],
        [destAddrLbl.topAnchor constraintEqualToAnchor:destNameLbl.bottomAnchor constant:2],
        [notchGuide.topAnchor constraintEqualToAnchor:destAddrLbl.bottomAnchor constant:tpad],
        [notchGuide.leadingAnchor constraintEqualToAnchor:ticket.leadingAnchor],
        [notchGuide.trailingAnchor constraintEqualToAnchor:ticket.trailingAnchor],
        [notchGuide.heightAnchor constraintEqualToConstant:0],
        [notchDivider.topAnchor constraintEqualToAnchor:notchGuide.topAnchor],
        [notchDivider.leadingAnchor constraintEqualToAnchor:ticket.leadingAnchor constant:20],
        [notchDivider.trailingAnchor constraintEqualToAnchor:ticket.trailingAnchor constant:-20],
        [notchDivider.heightAnchor constraintEqualToConstant:1],
        [statusKey.topAnchor constraintEqualToAnchor:notchDivider.bottomAnchor constant:14],
        [statusKey.leadingAnchor constraintEqualToAnchor:ticket.leadingAnchor constant:tpad],
        [statusVal.trailingAnchor constraintEqualToAnchor:ticket.trailingAnchor constant:-tpad],
        [statusVal.centerYAnchor constraintEqualToAnchor:statusKey.centerYAnchor],
        [dateKey.topAnchor constraintEqualToAnchor:statusKey.bottomAnchor constant:10],
        [dateKey.leadingAnchor constraintEqualToAnchor:ticket.leadingAnchor constant:tpad],
        [dateVal.trailingAnchor constraintEqualToAnchor:ticket.trailingAnchor constant:-tpad],
        [dateVal.centerYAnchor constraintEqualToAnchor:dateKey.centerYAnchor],
        [distKey.topAnchor constraintEqualToAnchor:dateKey.bottomAnchor constant:10],
        [distKey.leadingAnchor constraintEqualToAnchor:ticket.leadingAnchor constant:tpad],
        [distVal.trailingAnchor constraintEqualToAnchor:ticket.trailingAnchor constant:-tpad],
        [distVal.centerYAnchor constraintEqualToAnchor:distKey.centerYAnchor],
        [idKey.topAnchor constraintEqualToAnchor:distKey.bottomAnchor constant:10],
        [idKey.leadingAnchor constraintEqualToAnchor:ticket.leadingAnchor constant:tpad],
        [idVal.trailingAnchor constraintEqualToAnchor:ticket.trailingAnchor constant:-tpad],
        [idVal.centerYAnchor constraintEqualToAnchor:idKey.centerYAnchor],
        [fareSep.topAnchor constraintEqualToAnchor:idKey.bottomAnchor constant:14],
        [fareSep.leadingAnchor constraintEqualToAnchor:ticket.leadingAnchor constant:tpad],
        [fareSep.trailingAnchor constraintEqualToAnchor:ticket.trailingAnchor constant:-tpad],
        [fareSep.heightAnchor constraintEqualToConstant:1],
        [taxKey.topAnchor constraintEqualToAnchor:fareSep.bottomAnchor constant:14],
        [taxKey.leadingAnchor constraintEqualToAnchor:ticket.leadingAnchor constant:tpad],
        [taxVal.trailingAnchor constraintEqualToAnchor:ticket.trailingAnchor constant:-tpad],
        [taxVal.centerYAnchor constraintEqualToAnchor:taxKey.centerYAnchor],
        [fareKey.topAnchor constraintEqualToAnchor:taxKey.bottomAnchor constant:10],
        [fareKey.leadingAnchor constraintEqualToAnchor:ticket.leadingAnchor constant:tpad],
        [fareVal.trailingAnchor constraintEqualToAnchor:ticket.trailingAnchor constant:-tpad],
        [fareVal.centerYAnchor constraintEqualToAnchor:fareKey.centerYAnchor],
        [totalKey.topAnchor constraintEqualToAnchor:fareKey.bottomAnchor constant:10],
        [totalKey.leadingAnchor constraintEqualToAnchor:ticket.leadingAnchor constant:tpad],
        [totalVal.trailingAnchor constraintEqualToAnchor:ticket.trailingAnchor constant:-tpad],
        [totalVal.centerYAnchor constraintEqualToAnchor:totalKey.centerYAnchor],
        [bottomSpacer.topAnchor constraintEqualToAnchor:totalKey.bottomAnchor constant:tpad],
        [bottomSpacer.leadingAnchor constraintEqualToAnchor:ticket.leadingAnchor],
        [bottomSpacer.trailingAnchor constraintEqualToAnchor:ticket.trailingAnchor],
        [bottomSpacer.heightAnchor constraintEqualToConstant:4],
        [bottomSpacer.bottomAnchor constraintEqualToAnchor:ticket.bottomAnchor],
        [ticket.bottomAnchor constraintEqualToAnchor:content.bottomAnchor constant:-20],
    ]];
}

- (UILabel *)dReceiptKeyLabel:(NSString *)text {
    UILabel *lbl = [[UILabel alloc] init];
    lbl.translatesAutoresizingMaskIntoConstraints = NO;
    lbl.text = text;
    lbl.font = FONTS_NOTO_REGULAR(13);
    lbl.textColor = [UIColor colorWithWhite:0.5 alpha:1];
    return lbl;
}

- (UILabel *)dReceiptValueLabel:(NSString *)text {
    UILabel *lbl = [[UILabel alloc] init];
    lbl.translatesAutoresizingMaskIntoConstraints = NO;
    lbl.text = text;
    lbl.font = FONTS_NOTO_REGULAR(13);
    lbl.textColor = [UIColor colorNamed:@"color_app_label"] ?: [UIColor blackColor];
    lbl.textAlignment = NSTextAlignmentRight;
    return lbl;
}

- (void)applyTicketMaskToView:(UIView *)ticketView atNotchY:(CGFloat)notchY {
    if (!ticketView) return;
    CGRect bounds = ticketView.bounds;
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:bounds cornerRadius:14.0];
    [path appendPath:[UIBezierPath bezierPathWithArcCenter:CGPointMake(0, notchY) radius:12.0 startAngle:-M_PI_2 endAngle:M_PI_2 clockwise:YES]];
    [path appendPath:[UIBezierPath bezierPathWithArcCenter:CGPointMake(bounds.size.width, notchY) radius:12.0 startAngle:M_PI_2 endAngle:-M_PI_2 clockwise:YES]];
    CAShapeLayer *mask = [CAShapeLayer layer];
    mask.frame = bounds;
    mask.path = path.CGPath;
    mask.fillRule = kCAFillRuleEvenOdd;
    ticketView.layer.mask = mask;
}

- (void)dismissReceiptSheet {
    if (!_receiptOverlay) return;
    UIView *overlay = _receiptOverlay;
    UIView *sheet   = _receiptSheet;
    _receiptOverlay = nil;
    _receiptSheet   = nil;
    CGRect off = sheet.frame;
    off.origin.y = sheet.superview.bounds.size.height;
    [UIView animateWithDuration:0.24 animations:^{
        overlay.alpha = 0;
        sheet.frame = off;
    } completion:^(BOOL f) {
        [overlay removeFromSuperview];
        [sheet removeFromSuperview];
    }];
}

@end
