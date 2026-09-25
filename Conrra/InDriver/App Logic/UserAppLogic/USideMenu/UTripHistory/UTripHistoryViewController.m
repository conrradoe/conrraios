//
//  TripHistoryViewController.m
//  TaxiDriver
//
//  Created by Appicial Taxi App Soutions on 24/05/17.
//  Copyright © 2023 Appicial Taxi App Soutions. All rights reserved.
//

#import "UTripHistoryViewController.h"
#import "AppDelegate.h"
#import "WebCallConstants.h"
#import "UFareSummeryViewController.h"
#import <GIKit/GIKit.h>
#import "UTripHistoryCell.h"
#import "UTripDetailsViewController.h"
#import "ConstantModel.h"
#import "UIView+UpdateAutoLayoutConstraints.h"
#import "MainViewController.h"
#import "TripModel+Helper.h"
#import "UIImageView+WebCache.h"
#import "CityModel.h"
#import "Utilities.h"

#define kTHReceiptNotchGuide 4099

// Tag constants for programmatic card cells
#define kTHTagCard     3001
#define kTHTagDate     3002
#define kTHTagBadgeBg  3003
#define kTHTagBadgeLbl 3004
#define kTHTagSep      3005
#define kTHTagPickIcon 3006
#define kTHTagPickName 3007
#define kTHTagPickAddr 3008
#define kTHTagDash     3009
#define kTHTagDestIcon 3010
#define kTHTagDestName 3011
#define kTHTagDestAddr 3012

@interface UTripHistoryViewController ()<UTripHistoryCellCellDelegate>
{
    NSMutableArray *tripArrayPast;
    NSMutableArray *tripArrayUpcoming;
    BOOL isStopTripCall;
    BOOL isStopTripCall1;
    ConstantModel  *constantModel;
    BOOL isPastSelected;
    int pastArrCount;

    // Receipt modal
    UIView *_receiptOverlay;
    UIView *_receiptSheet;
}

@end

@implementation UTripHistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    pastArrCount = 0;
    constantModel = [ConstantModel getConstantsObject];
    tripArrayPast = [[NSMutableArray alloc] init];
    tripArrayUpcoming = [[NSMutableArray alloc] init];

    [self setupNewDesign];

    if (![constantModel getCValueFK:ckey_rdl]) {
        isPastSelected = YES;
        [self gettripHistoryWithLoader:YES];
    } else {
        isPastSelected = NO;
        [self ButtonSelectType:_btnUpcoming];
    }
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setUIFields];
    [self.tableView reloadData];
}




#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
}



-(void) setUIFields {}

#pragma mark - New Design

- (void)setupNewDesign {
    for (UIView *v in [self.view.subviews copy]) { v.hidden = YES; }

    self.view.backgroundColor = [UIColor colorWithRed:0.97 green:0.97 blue:0.97 alpha:1];
    UILayoutGuide *safe = self.view.safeAreaLayoutGuide;
    UIColor *textMain = [UIColor colorNamed:@"color_app_label"] ?: [UIColor blackColor];

    // Header
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

    // Table view
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

    // No records label
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
    card.tag = kTHTagCard;
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
    dateLbl.tag = kTHTagDate;
    dateLbl.font = FONTS_NOTO_REGULAR(13);
    dateLbl.textColor = [UIColor colorWithWhite:0.5 alpha:1];
    [card addSubview:dateLbl];

    UIView *badge = [[UIView alloc] init];
    badge.translatesAutoresizingMaskIntoConstraints = NO;
    badge.tag = kTHTagBadgeBg;
    badge.layer.cornerRadius = 10;
    [card addSubview:badge];

    UILabel *badgeLbl = [[UILabel alloc] init];
    badgeLbl.translatesAutoresizingMaskIntoConstraints = NO;
    badgeLbl.tag = kTHTagBadgeLbl;
    badgeLbl.font = FONTS_NOTO_REGULAR(12);
    [badge addSubview:badgeLbl];

    UIView *sep = [[UIView alloc] init];
    sep.translatesAutoresizingMaskIntoConstraints = NO;
    sep.tag = kTHTagSep;
    sep.backgroundColor = [UIColor colorWithWhite:0.88 alpha:1];
    [card addSubview:sep];

    UIImageView *pickIcon = [[UIImageView alloc] init];
    pickIcon.translatesAutoresizingMaskIntoConstraints = NO;
    pickIcon.tag = kTHTagPickIcon;
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
    pickName.tag = kTHTagPickName;
    pickName.font = FONTS_NOTO_BOLD(14);
    pickName.numberOfLines = 1;
    [card addSubview:pickName];

    UILabel *pickAddr = [[UILabel alloc] init];
    pickAddr.translatesAutoresizingMaskIntoConstraints = NO;
    pickAddr.tag = kTHTagPickAddr;
    pickAddr.font = FONTS_NOTO_REGULAR(12);
    pickAddr.textColor = [UIColor colorWithWhite:0.5 alpha:1];
    pickAddr.numberOfLines = 1;
    [card addSubview:pickAddr];

    // Dashed vertical line (tiled 2×8 pattern: 4px solid / 4px transparent)
    UIView *dash = [[UIView alloc] init];
    dash.translatesAutoresizingMaskIntoConstraints = NO;
    dash.tag = kTHTagDash;
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(2, 8), NO, 0);
    [[UIColor colorWithWhite:0.72 alpha:1] setFill];
    UIRectFill(CGRectMake(0, 0, 2, 4));
    UIImage *dashImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    dash.backgroundColor = [UIColor colorWithPatternImage:dashImg];
    [card addSubview:dash];

    UIImageView *destIcon = [[UIImageView alloc] init];
    destIcon.translatesAutoresizingMaskIntoConstraints = NO;
    destIcon.tag = kTHTagDestIcon;
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
    destName.tag = kTHTagDestName;
    destName.font = FONTS_NOTO_BOLD(14);
    destName.numberOfLines = 1;
    [card addSubview:destName];

    UILabel *destAddr = [[UILabel alloc] init];
    destAddr.translatesAutoresizingMaskIntoConstraints = NO;
    destAddr.tag = kTHTagDestAddr;
    destAddr.font = FONTS_NOTO_REGULAR(12);
    destAddr.textColor = [UIColor colorWithWhite:0.5 alpha:1];
    destAddr.numberOfLines = 1;
    [card addSubview:destAddr];

    CGFloat iconSize = 26.0;
    CGFloat pad = 16.0;

    [NSLayoutConstraint activateConstraints:@[
        // Badge label padding
        [badgeLbl.topAnchor constraintEqualToAnchor:badge.topAnchor constant:5],
        [badgeLbl.bottomAnchor constraintEqualToAnchor:badge.bottomAnchor constant:-5],
        [badgeLbl.leadingAnchor constraintEqualToAnchor:badge.leadingAnchor constant:10],
        [badgeLbl.trailingAnchor constraintEqualToAnchor:badge.trailingAnchor constant:-10],

        // Date + badge row
        [dateLbl.topAnchor constraintEqualToAnchor:card.topAnchor constant:16],
        [dateLbl.leadingAnchor constraintEqualToAnchor:card.leadingAnchor constant:pad],
        [badge.centerYAnchor constraintEqualToAnchor:dateLbl.centerYAnchor],
        [badge.trailingAnchor constraintEqualToAnchor:card.trailingAnchor constant:-pad],
        [dateLbl.trailingAnchor constraintLessThanOrEqualToAnchor:badge.leadingAnchor constant:-8],

        // Separator
        [sep.topAnchor constraintEqualToAnchor:dateLbl.bottomAnchor constant:12],
        [sep.leadingAnchor constraintEqualToAnchor:card.leadingAnchor],
        [sep.trailingAnchor constraintEqualToAnchor:card.trailingAnchor],
        [sep.heightAnchor constraintEqualToConstant:1],

        // Pickup icon
        [pickIcon.topAnchor constraintEqualToAnchor:sep.bottomAnchor constant:14],
        [pickIcon.leadingAnchor constraintEqualToAnchor:card.leadingAnchor constant:pad],
        [pickIcon.widthAnchor constraintEqualToConstant:iconSize],
        [pickIcon.heightAnchor constraintEqualToConstant:iconSize],

        // Pickup name (top-aligned with icon)
        [pickName.leadingAnchor constraintEqualToAnchor:pickIcon.trailingAnchor constant:12],
        [pickName.trailingAnchor constraintEqualToAnchor:card.trailingAnchor constant:-pad],
        [pickName.topAnchor constraintEqualToAnchor:pickIcon.topAnchor],

        // Pickup address
        [pickAddr.leadingAnchor constraintEqualToAnchor:pickName.leadingAnchor],
        [pickAddr.trailingAnchor constraintEqualToAnchor:card.trailingAnchor constant:-pad],
        [pickAddr.topAnchor constraintEqualToAnchor:pickName.bottomAnchor constant:2],

        // Dashed line (from below pickup icon to above dest icon)
        [dash.topAnchor constraintEqualToAnchor:pickIcon.bottomAnchor constant:4],
        [dash.centerXAnchor constraintEqualToAnchor:pickIcon.centerXAnchor],
        [dash.widthAnchor constraintEqualToConstant:2],
        [dash.bottomAnchor constraintEqualToAnchor:destIcon.topAnchor constant:-4],

        // Dest icon (below pickup address)
        [destIcon.topAnchor constraintEqualToAnchor:pickAddr.bottomAnchor constant:12],
        [destIcon.leadingAnchor constraintEqualToAnchor:card.leadingAnchor constant:pad],
        [destIcon.widthAnchor constraintEqualToConstant:iconSize],
        [destIcon.heightAnchor constraintEqualToConstant:iconSize],

        // Dest name
        [destName.leadingAnchor constraintEqualToAnchor:destIcon.trailingAnchor constant:12],
        [destName.trailingAnchor constraintEqualToAnchor:card.trailingAnchor constant:-pad],
        [destName.topAnchor constraintEqualToAnchor:destIcon.topAnchor],

        // Dest address (anchors card bottom)
        [destAddr.leadingAnchor constraintEqualToAnchor:destName.leadingAnchor],
        [destAddr.trailingAnchor constraintEqualToAnchor:card.trailingAnchor constant:-pad],
        [destAddr.topAnchor constraintEqualToAnchor:destName.bottomAnchor constant:2],
        [destAddr.bottomAnchor constraintEqualToAnchor:card.bottomAnchor constant:-16],
    ]];
}

- (void)populateTripCard:(UITableViewCell *)cell withTrip:(TripModel *)trip {
    UILabel *dateLbl  = (UILabel *)[cell.contentView viewWithTag:kTHTagDate];
    UIView  *badge    = [cell.contentView viewWithTag:kTHTagBadgeBg];
    UILabel *badgeLbl = (UILabel *)[cell.contentView viewWithTag:kTHTagBadgeLbl];
    UILabel *pickName = (UILabel *)[cell.contentView viewWithTag:kTHTagPickName];
    UILabel *pickAddr = (UILabel *)[cell.contentView viewWithTag:kTHTagPickAddr];
    UILabel *destName = (UILabel *)[cell.contentView viewWithTag:kTHTagDestName];
    UILabel *destAddr = (UILabel *)[cell.contentView viewWithTag:kTHTagDestAddr];

    dateLbl.text = [Utilities GetGMTDatetoLocalTZ:trip.trip_date :APP_DATE_FORMAT];

    // Split location string on first comma: "Name, address detail..."
    NSArray *pickParts = [trip.pickupLocationApp componentsSeparatedByString:@","];
    pickName.text = [pickParts.firstObject stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    pickAddr.text = pickParts.count > 1
        ? [[pickParts subarrayWithRange:NSMakeRange(1, pickParts.count - 1)]
           componentsJoinedByString:@","]
        : @"";

    NSArray *dropParts = [trip.dropLocationApp componentsSeparatedByString:@","];
    destName.text = [dropParts.firstObject stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    destAddr.text = dropParts.count > 1
        ? [[dropParts subarrayWithRange:NSMakeRange(1, dropParts.count - 1)]
           componentsJoinedByString:@","]
        : @"";

    // Status badge
    NSString *statusText;
    UIColor  *badgeBg, *badgeTextColor;

    if ([trip isTripCancelled]) {
        statusText     = @"Cancelado";
        badgeBg        = [UIColor colorWithRed:1.0 green:0.9 blue:0.9 alpha:1];
        badgeTextColor = [UIColor colorWithRed:0.85 green:0.15 blue:0.15 alpha:1];
    } else if ([trip.trip_Status isEqualToString:TS_END]) {
        statusText     = @"Terminado";
        badgeBg        = [UIColor colorWithWhite:0.88 alpha:1];
        badgeTextColor = [UIColor colorWithWhite:0.45 alpha:1];
    } else {
        statusText     = isEmpty(trip.trip_Status) ?: @"";
        badgeBg        = [UIColor colorWithWhite:0.88 alpha:1];
        badgeTextColor = [UIColor colorWithWhite:0.45 alpha:1];
    }

    badge.backgroundColor = badgeBg;
    badgeLbl.text = statusText;
    badgeLbl.textColor = badgeTextColor;
}





- (IBAction)ButtonBackAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)gettripHistory {
    [self gettripHistoryWithLoader:YES];
}

-(void)gettripHistoryWithLoader:(BOOL)showLoader {
    NSDictionary *dict1 = [[NSUserDefaults standardUserDefaults]objectForKey:P_USER_DICT];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{
        @"user_id"          :[dict1 objectForKey:P_USER_ID],
        @"limit"            :@(SIZE),
        @"offset"           :[NSString stringWithFormat:@"%d",pastArrCount],
        @"statuses":@"completed,paid,cancel,p_cancel_drop,p_cancel_pickup,expired",
    }];
    if (showLoader) {
        [UtilityClass setLH:NO wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
    }
    [GIC mkwu:TRIP_GETTRIP
            d:dict
          isa:NO
           cb:^(id results, NSError *error) {
        if ([[[results objectForKey:P_STATUS] uppercaseString] isEqualToString:@"OK"]) {
            if ([[results objectForKey:P_RESPONSE] isKindOfClass:[NSArray class]]) {
                NSArray *arrtrip = [results objectForKey:P_RESPONSE];
                self->pastArrCount = self->pastArrCount+(int)arrtrip.count;
                self->isStopTripCall = arrtrip.count < SIZE ? YES : NO;
                for (int i=0; i<arrtrip.count; i++) {
                    TripModel *Trip = [[TripModel alloc] initItemWithDict:[arrtrip objectAtIndex:i]];
                    [self->tripArrayPast addObject:Trip];
                }
            }
            else{
                self->isStopTripCall =YES;
            }
            if (self->isPastSelected) {
                if (self->tripArrayPast.count ==0 ) {
                    self.lblNoRec.hidden =NO;
                    self.lblNoRec.text=[LanguageHelper getStringWithKey:@"k_17_s10_no_trips_avail"];
                }
                else{
                    self.lblNoRec.hidden =YES;
                }
            }
            [self.tableView reloadData];
        }
        if (showLoader) {
            [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
        }
    }];
}



-(void)getUpcomingTrips:(BOOL)isHideLoader {
    [self getUpcomingTrips:isHideLoader showLoader:YES];
}

-(void)getUpcomingTrips:(BOOL)isHideLoader showLoader:(BOOL)showLoader {
    NSDictionary *dict1 = [[NSUserDefaults standardUserDefaults]objectForKey:P_USER_DICT];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{
        @"user_id"          :[dict1 objectForKey:P_USER_ID],
        @"limit"            :@(SIZE),
        @"offset"           :[NSString stringWithFormat:@"%lu",tripArrayUpcoming.count],
        @"statuses" :    @"request,assigned,arrive,begin,accept",
    }];
    if (showLoader) {
        [UtilityClass setLH:NO wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
    }
    [GIC mkwu:TRIP_GETTRIP    d:dict    isa:NO   cb:^(id results, NSError *error) {
        if ([[[results objectForKey:P_STATUS] uppercaseString] isEqualToString:@"OK"]) {
            if ([[results objectForKey:P_RESPONSE] isKindOfClass:[NSArray class]]) {
                NSArray *arrtrip = [results objectForKey:P_RESPONSE];
                self->isStopTripCall1 = arrtrip.count < SIZE ? YES : NO;
                [self->tripArrayUpcoming removeAllObjects];
                for (int i=0; i<arrtrip.count; i++) {
                    TripModel *Trip = [[TripModel alloc] initItemWithDict:[arrtrip objectAtIndex:i]];
                    [self->tripArrayUpcoming addObject:Trip];
                }
            }
            else{
                self->isStopTripCall1 =YES;
            }
            if (!self->isPastSelected) {
                if (self->tripArrayUpcoming.count ==0 ) {
                    self.lblNoRec.hidden =NO;
                    self.lblNoRec.text=[LanguageHelper getStringWithKey:@"k_17_s10_no_trips_avail"];
                }
                else{
                    self.lblNoRec.hidden =YES;
                }
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
    
    if (isPastSelected) {
        return tripArrayPast.count;
    }
    else{
        return tripArrayUpcoming.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TripCard" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];

    TripModel *trip = isPastSelected
        ? tripArrayPast[(NSUInteger)indexPath.row]
        : tripArrayUpcoming[(NSUInteger)indexPath.row];

    if (![cell.contentView viewWithTag:kTHTagCard]) {
        [self buildTripCardInCell:cell];
    }
    [self populateTripCard:cell withTrip:trip];

    // Pagination
    if (isPastSelected && indexPath.row > 3
        && indexPath.row > (NSInteger)tripArrayPast.count - 2 && !isStopTripCall) {
        [self gettripHistory];
    }
    return cell;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (isPastSelected) {
        [self showReceiptSheetForTrip:[tripArrayPast objectAtIndex:indexPath.row]];
    } else {
        TripModel *tripModel=[tripArrayUpcoming objectAtIndex:indexPath.row];
        if([tripModel.trip_Status isEqualToString:TS_ACCEPTED]||[tripModel.trip_Status isEqualToString:TS_ARRIVE]||[tripModel.trip_Status isEqualToString:TS_BEGIN]||[tripModel.trip_Status isEqualToString:TS_PICKED])  {
            NSString *tripId=[NSString stringWithFormat:@"%@",tripModel.trip_Id];
            defaults_set_object(TRIP_ID,tripId);
            [self loadHomeViewController];
        }else{
            if([tripModel.trip_Status isEqualToString:TS_REQUEST]){
                [self.navigationController popViewControllerAnimated:YES];
                [self.delegate openTripOfferPageForTrip:tripModel];
                return;
            }
            [UtilityClass swa:@"" m:@"Driver will be assigned shortly. Please wait..." cbt:@"Ok" obt:nil vc:self];
        }
    }
}

- (IBAction)ButtonSelectType:(UIButton *)sender {
    if (sender== _btnPast) {
        isPastSelected =YES;
        [_btnPast setTitleColor:[UIColor colorNamed:@"app_theame"] forState:UIControlStateNormal];
        [_btnUpcoming setTitleColor:[UIColor colorNamed:@"color_bt_un_select_text"] forState:UIControlStateNormal];
        _upcomingBottomView.hidden = YES;
        _pastBottomView.hidden = NO;
        
        if (tripArrayPast.count ==0 ) {
            _lblNoRec.hidden =NO;
            _lblNoRec.text=[LanguageHelper getStringWithKey:@"k_r17_s10_no_trips_avail"];
            [self gettripHistory];
        }
        else{
            _lblNoRec.hidden =YES;
        }
    }
    else{
        isPastSelected =NO;
        [_btnPast setTitleColor:[UIColor colorNamed:@"color_bt_un_select_text"] forState:UIControlStateNormal];
        [_btnUpcoming setTitleColor:[UIColor colorNamed:@"app_theame"] forState:UIControlStateNormal];
        _upcomingBottomView.hidden = NO;
        _pastBottomView.hidden = YES;
        if (tripArrayUpcoming.count ==0 ) {
            _lblNoRec.hidden =NO;
            _lblNoRec.text=[LanguageHelper getStringWithKey:@"k_17_s10_no_trips_scheduled"];
            [self getUpcomingTrips:YES showLoader:NO];
        }
        else{
            _lblNoRec.hidden =YES;
        }
    }
    [_tableView reloadData];
}

-(void)refreshOnCancelTrip{
    tripArrayUpcoming =[[NSMutableArray alloc]init];
    [self getUpcomingTrips:YES];
}


-(void)cancelTrip:(TripModel *)tripModel {
    [self cancelTripBeforeBeginTrip:tripModel completionBlock:^(id  _Nonnull results, NSError * _Nonnull error) {
        
        if([[results objectForKey:P_RESPONSE] isKindOfClass:[NSDictionary class]])
        {
            [self sendNotification:tripModel];
            TripModel * tModelForDelete=nil;
            for (TripModel * tModel in self->tripArrayUpcoming) {
                if(tModel.trip_Id == tripModel.trip_Id)
                {
                    tModelForDelete=tModel;
                    break;
                }
            }
            if(tModelForDelete!=nil)  {
                [ self->tripArrayUpcoming removeObject:tModelForDelete];
            }
            if (self->  tripArrayUpcoming.count ==0 ) {
                self.lblNoRec.hidden =NO;
                self.lblNoRec.text=[LanguageHelper getStringWithKey:@"k_17_s10_no_trips_scheduled"];
            }
            else{
                self.lblNoRec.hidden =YES;
            }
            [self.tableView reloadData];
        }
        else{
            if([[results objectForKey:P_RESPONSE] intValue]==1)
            {
                [self sendNotification:tripModel];
                TripModel * tModelForDelete=nil;
                for (TripModel * tModel in self->tripArrayUpcoming) {
                    if(tModel.trip_Id == tripModel.trip_Id)
                    {
                        tModelForDelete=tModel;
                        break;
                    }
                }
                if(tModelForDelete!=nil)  {
                    [ self->tripArrayUpcoming removeObject:tModelForDelete];
                }
                if (self->  tripArrayUpcoming.count ==0 ) {
                    self.lblNoRec.hidden =NO;
                    self.lblNoRec.text=[LanguageHelper getStringWithKey:@"k_17_s10_no_trips_scheduled"];
                }
                else{
                    self.lblNoRec.hidden =YES;
                }
                [self.tableView reloadData];
            }
        }
        
    } isShowLoader:YES isSendNotification:YES withDelegate:self isFromBeginTrip:NO];
    
}


-(void)sendNotification:(TripModel *)tripModel{
    
    
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{
        
        @"message"       :[[LanguageHelper sharedInstance] getStringWithKey:@"k_53_s4_rider_has_cancelled_trip" currentLanguage:tripModel.driver.d_lang]/*[LanguageHelper getStringWithKey:@"k_53_s4_rider_has_cancelled_trip"]*/,
        TRIP_STATUS      :TS_RIDER_CANCEL,
        TRIP_ID          :[NSString stringWithFormat:@"%@",tripModel.trip_Id],
        @"content-available":@"1",
        
    }];
    
    [dict setObject:@"driver_cancel.caf" forKey:@"sound"];
    if(tripModel.driver.deviceToken)
    {
        if ([tripModel.driver.deviceType isEqualToString:IOS]) {
            
            [dict setObject:tripModel.driver.deviceToken forKey:IOS_TOKEN];
        }
        else{
            
            [dict setObject:tripModel.driver.deviceToken forKey:ANDROID_TOKEN];
        }
    }
    if ([[dict objectForKey:IOS_TOKEN] length]==0  && [[dict objectForKey:ANDROID_TOKEN] length]==0) {
        return;
    }
    [dict setObject:@"driver" forKey:@"to"];
    [GIC mk:url_notification to:send_driver_notification
          d:dict
        isa:NO
         cb:^(id results, NSError *error) {
        if ([[results objectForKey:P_STATUS] isEqualToString:@"OK"]) {
        }
        
    }];
    
    
}

-(void)doSimpleNativeCall:(TripModel *)tripModel{
    NSString * numberWithCode=[Utilities numeroParaLlamarConCodigo:tripModel.driver.c_code numero:tripModel.driver.phone];
    NSURL *phoneUrl = [NSURL URLWithString:[@"telprompt://"stringByAppendingString:numberWithCode]];
    NSURL *phoneFallbackUrl = [NSURL URLWithString:[@"tel://" stringByAppendingString:numberWithCode]];
    // Sin numero la URL se queda en "telprompt://" y abriria el marcador en blanco. Cayendo
    // al else sale el aviso de que no se puede llamar, que es lo que el usuario necesita oir.
    if (numberWithCode.length > 0 && [UIApplication.sharedApplication canOpenURL:phoneUrl]) {
        [[UIApplication sharedApplication] openURL:phoneUrl options:@{} completionHandler:nil];
    } else if (numberWithCode.length > 0 && [UIApplication.sharedApplication canOpenURL:phoneFallbackUrl]) {
        [UIApplication.sharedApplication openURL:phoneFallbackUrl options:@{} completionHandler:nil];
    } else {
        [UtilityClass swa:nil
                        m:[LanguageHelper getStringWithKey:@"k_r33_s8_no_call_facility"]
                      cbt:@"Ok"
                      obt:nil vc:self];
    }
}

/**
 driver call button tap
 */
-(void)onDriverCallButtonTap:(TripModel *)tripModel
{
    
    UIAlertController *alertViewcontroller=[UIAlertController alertControllerWithTitle:[LanguageHelper getStringWithKey:@"k_s4_contact" defaultValue:@"Contact"] message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *actionCall=[UIAlertAction actionWithTitle:[LanguageHelper getStringWithKey:@"k_r1_s8_call_driver" defaultValue:@"Call Driver"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
            [self doSimpleNativeCall:tripModel];
      
    }];
    [actionCall setValue:[UIColor colorNamed:@"app_theame"] forKey:@"titleTextColor"];
    [alertViewcontroller addAction:actionCall];
    if([[ConstantModel getConstantsObject] getCValueFK:ckey_ech]==YES){
        UIAlertAction * actionChat=[UIAlertAction actionWithTitle:[LanguageHelper getStringWithKey:@"k_r1_s8_chat_with_driver" defaultValue:@"Chat with Driver"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self openChatViewController:tripModel];
        }];
        [actionChat setValue:[UIColor colorNamed:@"app_theame"] forKey:@"titleTextColor"];
        [alertViewcontroller addAction:actionChat];
    }
    UIAlertAction *actionCancel=[UIAlertAction actionWithTitle:[LanguageHelper getStringWithKey:@"k_30_s6_cancel_j" defaultValue:@"Cancel"] style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [actionCancel setValue:[UIColor colorNamed:@"app_theame"] forKey:@"titleTextColor"];
    [alertViewcontroller addAction:actionCancel];
    [self.navigationController presentViewController:alertViewcontroller animated:YES completion:^{
        
    }];
    
    
}



-(void) openChatViewController:(TripModel *)tripModel
{
    UChatViewController *vc = (UChatViewController*)[StoryBoardUtiles viewContollerInUserWithIdentifier:StoryBoardUtiles.UCHAT_VC];
    vc.tripID=[NSString stringWithFormat:@"%@",tripModel.trip_Id];
    [self.navigationController pushViewController:vc animated:YES];
}


#pragma mark - Receipt Modal

- (void)showReceiptSheetForTrip:(TripModel *)trip {
    if (_receiptOverlay) return;

    UIWindow *window = self.view.window ?: UIApplication.sharedApplication.keyWindow;
    CGRect windowBounds = window.bounds;

    // Dim overlay
    UIView *overlay = [[UIView alloc] initWithFrame:windowBounds];
    overlay.backgroundColor = [UIColor colorWithWhite:0 alpha:0.45];
    overlay.alpha = 0;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissReceiptSheet)];
    [overlay addGestureRecognizer:tap];
    [window addSubview:overlay];
    _receiptOverlay = overlay;

    // Sheet: 90% height, slides from bottom
    CGFloat sheetH = windowBounds.size.height * 0.90;
    UIView *sheet = [[UIView alloc] initWithFrame:CGRectMake(0, windowBounds.size.height, windowBounds.size.width, sheetH)];
    sheet.backgroundColor = [UIColor whiteColor];
    sheet.layer.cornerRadius = 20;
    sheet.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
    sheet.clipsToBounds = YES;
    [window addSubview:sheet];
    _receiptSheet = sheet;

    [self buildReceiptContent:trip inSheet:sheet];

    // Force layout so we can read frames for the ticket mask
    [sheet setNeedsLayout];
    [sheet layoutIfNeeded];

    // Apply ticket mask using the notch guide tag
    UIView *notchGuide = [sheet viewWithTag:kTHReceiptNotchGuide];
    if (notchGuide) {
        CGFloat notchY = notchGuide.frame.origin.y;
        [self applyTicketMaskToView:[sheet viewWithTag:kTHReceiptNotchGuide + 1] atNotchY:notchY];
    }

    // Animate in
    [UIView animateWithDuration:0.28 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        overlay.alpha = 1;
        sheet.frame = CGRectMake(0, windowBounds.size.height - sheetH, windowBounds.size.width, sheetH);
    } completion:nil];
}

- (void)buildReceiptContent:(TripModel *)trip inSheet:(UIView *)sheet {
    CGFloat sw = sheet.bounds.size.width;
    UIColor *textMain  = [UIColor colorNamed:@"color_app_label"] ?: [UIColor blackColor];
    UIColor *textGray  = [UIColor colorWithWhite:0.5 alpha:1];
    UIColor *yellow    = [UIColor colorNamed:@"app_theame"] ?: [UIColor colorWithRed:0.92 green:0.71 blue:0.09 alpha:1];
    CGFloat pad        = 20.0;

    // ---- Header: "Recibo" + close button ----
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

    // ---- Scroll view for content below header ----
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

    // ---- Driver info row ----
    UIImageView *avatar = [[UIImageView alloc] init];
    avatar.translatesAutoresizingMaskIntoConstraints = NO;
    avatar.layer.cornerRadius = 30;
    avatar.clipsToBounds = YES;
    avatar.contentMode = UIViewContentModeScaleAspectFill;
    avatar.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
    if (trip.driver.d_profile_image_path.length > 0) {
        NSURL *avatarURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", url_base_images, trip.driver.d_profile_image_path]];
        [avatar sd_setImageWithURL:avatarURL placeholderImage:[UIImage imageNamed:@"Profile Icon Crop Image"]];
    }
    [content addSubview:avatar];

    UILabel *driverName = [[UILabel alloc] init];
    driverName.translatesAutoresizingMaskIntoConstraints = NO;
    driverName.font = FONTS_NOTO_BOLD(15);
    driverName.textColor = textMain;
    NSString *fullName = [[NSString stringWithFormat:@"%@ %@",
                           trip.driver.d_fname ?: @"",
                           trip.driver.d_lname ?: @""]
                          stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    driverName.text = fullName.length > 0 ? fullName : @"Conductor";
    [content addSubview:driverName];

    // Star + rating label
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
            [NSString stringWithFormat:@" %.1f (%d)", trip.driver.rating, (int)trip.driver.ratingCount]
            attributes:@{ NSFontAttributeName: ratingLbl.font,
                          NSForegroundColorAttributeName: textGray }]];
    } else {
        ratingStr = [[NSMutableAttributedString alloc] initWithString:
            [NSString stringWithFormat:@"★ %.1f (%d)", trip.driver.rating, (int)trip.driver.ratingCount]];
    }
    ratingLbl.attributedText = ratingStr;
    [content addSubview:ratingLbl];

    [NSLayoutConstraint activateConstraints:@[
        [avatar.topAnchor constraintEqualToAnchor:content.topAnchor constant:20],
        [avatar.leadingAnchor constraintEqualToAnchor:content.leadingAnchor constant:pad],
        [avatar.widthAnchor constraintEqualToConstant:60],
        [avatar.heightAnchor constraintEqualToConstant:60],
        [driverName.leadingAnchor constraintEqualToAnchor:avatar.trailingAnchor constant:12],
        [driverName.trailingAnchor constraintEqualToAnchor:content.trailingAnchor constant:-pad],
        [driverName.topAnchor constraintEqualToAnchor:avatar.topAnchor constant:10],
        [ratingLbl.leadingAnchor constraintEqualToAnchor:driverName.leadingAnchor],
        [ratingLbl.topAnchor constraintEqualToAnchor:driverName.bottomAnchor constant:4],
    ]];

    // ---- Gray ticket container ----
    UIView *ticket = [[UIView alloc] init];
    ticket.translatesAutoresizingMaskIntoConstraints = NO;
    ticket.tag = kTHReceiptNotchGuide + 1;
    ticket.backgroundColor = [UIColor colorWithWhite:0.96 alpha:1];
    // Corner rounding and notch cutouts handled entirely by the CAShapeLayer mask
    [content addSubview:ticket];

    [NSLayoutConstraint activateConstraints:@[
        [ticket.topAnchor constraintEqualToAnchor:avatar.bottomAnchor constant:16],
        [ticket.leadingAnchor constraintEqualToAnchor:content.leadingAnchor constant:pad],
        [ticket.trailingAnchor constraintEqualToAnchor:content.trailingAnchor constant:-pad],
    ]];

    // --- Route section inside ticket ---
    UIView *ticketContent = ticket; // alias for clarity

    // Pickup icon
    UIImageView *pickIcon = [[UIImageView alloc] init];
    pickIcon.translatesAutoresizingMaskIntoConstraints = NO;
    pickIcon.contentMode = UIViewContentModeScaleAspectFit;
    UIImage *pickImg = [UIImage imageNamed:@"ic_trip_pickup"];
    if (!pickImg && @available(iOS 13, *)) {
        UIImageSymbolConfiguration *cfg = [UIImageSymbolConfiguration configurationWithPointSize:18 weight:UIImageSymbolWeightMedium];
        pickImg = [[UIImage systemImageNamed:@"mappin.circle.fill" withConfiguration:cfg]
                   imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        pickIcon.tintColor = [UIColor colorWithRed:0.85 green:0.15 blue:0.15 alpha:1];
    }
    pickIcon.image = pickImg;
    [ticketContent addSubview:pickIcon];

    NSArray *pickParts = [trip.pickupLocationApp componentsSeparatedByString:@","];
    NSString *pickLocName = pickParts.count > 0 ? [pickParts[0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] : @"";
    NSString *pickAddrStr = pickParts.count > 1 ? [[[pickParts subarrayWithRange:NSMakeRange(1, pickParts.count - 1)] componentsJoinedByString:@","] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] : @"";

    UILabel *pickNameLbl = [[UILabel alloc] init];
    pickNameLbl.translatesAutoresizingMaskIntoConstraints = NO;
    pickNameLbl.text = pickLocName;
    pickNameLbl.font = FONTS_NOTO_BOLD(13);
    pickNameLbl.textColor = textMain;
    pickNameLbl.numberOfLines = 1;
    [ticketContent addSubview:pickNameLbl];

    UILabel *pickAddrLbl = [[UILabel alloc] init];
    pickAddrLbl.translatesAutoresizingMaskIntoConstraints = NO;
    pickAddrLbl.text = pickAddrStr;
    pickAddrLbl.font = FONTS_NOTO_REGULAR(11);
    pickAddrLbl.textColor = textGray;
    pickAddrLbl.numberOfLines = 2;
    [ticketContent addSubview:pickAddrLbl];

    // Dashed vertical connector
    UIView *dashLine = [[UIView alloc] init];
    dashLine.translatesAutoresizingMaskIntoConstraints = NO;
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(2, 8), NO, 0);
    [[UIColor colorWithWhite:0.72 alpha:1] setFill];
    UIRectFill(CGRectMake(0, 0, 2, 4));
    UIImage *dashImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    dashLine.backgroundColor = [UIColor colorWithPatternImage:dashImg];
    [ticketContent addSubview:dashLine];

    // Dest icon
    UIImageView *destIcon = [[UIImageView alloc] init];
    destIcon.translatesAutoresizingMaskIntoConstraints = NO;
    destIcon.contentMode = UIViewContentModeScaleAspectFit;
    UIImage *destImg = [UIImage imageNamed:@"ic_trip_drop"];
    if (!destImg && @available(iOS 13, *)) {
        UIImageSymbolConfiguration *cfg = [UIImageSymbolConfiguration configurationWithPointSize:18 weight:UIImageSymbolWeightMedium];
        destImg = [[UIImage systemImageNamed:@"flag.circle.fill" withConfiguration:cfg]
                   imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        destIcon.tintColor = [UIColor colorWithRed:0.1 green:0.65 blue:0.3 alpha:1];
    }
    destIcon.image = destImg;
    [ticketContent addSubview:destIcon];

    NSArray *dropParts = [trip.dropLocationApp componentsSeparatedByString:@","];
    NSString *dropLocName = dropParts.count > 0 ? [dropParts[0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] : @"";
    NSString *dropAddrStr = dropParts.count > 1 ? [[[dropParts subarrayWithRange:NSMakeRange(1, dropParts.count - 1)] componentsJoinedByString:@","] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] : @"";

    UILabel *destNameLbl = [[UILabel alloc] init];
    destNameLbl.translatesAutoresizingMaskIntoConstraints = NO;
    destNameLbl.text = dropLocName;
    destNameLbl.font = FONTS_NOTO_BOLD(13);
    destNameLbl.textColor = textMain;
    destNameLbl.numberOfLines = 1;
    [ticketContent addSubview:destNameLbl];

    UILabel *destAddrLbl = [[UILabel alloc] init];
    destAddrLbl.translatesAutoresizingMaskIntoConstraints = NO;
    destAddrLbl.text = dropAddrStr;
    destAddrLbl.font = FONTS_NOTO_REGULAR(11);
    destAddrLbl.textColor = textGray;
    destAddrLbl.numberOfLines = 2;
    [ticketContent addSubview:destAddrLbl];

    CGFloat iconW = 22.0;
    CGFloat tpad  = 16.0;

    // Notch guide view — we read its Y after layout to place ticket mask
    UIView *notchGuide = [[UIView alloc] init];
    notchGuide.translatesAutoresizingMaskIntoConstraints = NO;
    notchGuide.tag = kTHReceiptNotchGuide;
    notchGuide.backgroundColor = [UIColor clearColor];
    [ticketContent addSubview:notchGuide];

    // Notch divider (thin horizontal line inside the ticket at boundary)
    UIView *notchDivider = [[UIView alloc] init];
    notchDivider.translatesAutoresizingMaskIntoConstraints = NO;
    notchDivider.backgroundColor = [UIColor colorWithWhite:0.82 alpha:1];
    [ticketContent addSubview:notchDivider];

    // ---- Details section ----
    NSString *currency = [CityModel getCityByCityId:trip.city_id].city_cur ?: @"";

    // Status
    UILabel *statusKey = [self receiptKeyLabel:@"Estatus"];
    UILabel *statusVal = [self receiptValueLabel:@""];
    [ticketContent addSubview:statusKey];
    [ticketContent addSubview:statusVal];
    if ([trip isTripCancelled]) {
        statusVal.text = @"Cancelado";
        statusVal.textColor = [UIColor colorWithRed:0.85 green:0.15 blue:0.15 alpha:1];
    } else if ([trip.trip_Status isEqualToString:TS_END]) {
        statusVal.text = @"Terminado";
    } else {
        statusVal.text = trip.trip_Status ?: @"-";
    }

    // Fecha / Hora
    UILabel *dateKey = [self receiptKeyLabel:@"Fecha / Hora"];
    UILabel *dateVal = [self receiptValueLabel:[Utilities GetGMTDatetoLocalTZ:trip.trip_date :APP_DATE_FORMAT] ?: @"-"];
    [ticketContent addSubview:dateKey];
    [ticketContent addSubview:dateVal];

    // Distancia
    UILabel *distKey = [self receiptKeyLabel:@"Distancia"];
    NSString *distStr = trip.trip_distance.length > 0
        ? [NSString stringWithFormat:@"%@ km", trip.trip_distance]
        : @"-";
    UILabel *distVal = [self receiptValueLabel:distStr];
    [ticketContent addSubview:distKey];
    [ticketContent addSubview:distVal];

    // ID del Conductor
    UILabel *idKey = [self receiptKeyLabel:@"ID del Conductor"];
    UILabel *idVal = [self receiptValueLabel:trip.driver.car_registration_no ?: @"-"];
    [ticketContent addSubview:idKey];
    [ticketContent addSubview:idVal];

    // Thin separator between details and fares
    UIView *fareSep = [[UIView alloc] init];
    fareSep.translatesAutoresizingMaskIntoConstraints = NO;
    fareSep.backgroundColor = [UIColor colorWithWhite:0.85 alpha:1];
    [ticketContent addSubview:fareSep];

    // Impuestos
    UILabel *taxKey = [self receiptKeyLabel:@"Impuestos"];
    NSString *taxStr = trip.tax_amount_r.length > 0
        ? [NSString stringWithFormat:@"%@ %@", trip.tax_amount_r, currency]
        : [NSString stringWithFormat:@"0.00 %@", currency];
    UILabel *taxVal = [self receiptValueLabel:taxStr];
    [ticketContent addSubview:taxKey];
    [ticketContent addSubview:taxVal];

    // Traslado
    UILabel *fareKey = [self receiptKeyLabel:@"Traslado"];
    NSString *fareStr = trip.trip_fare.length > 0
        ? [NSString stringWithFormat:@"%@ %@", trip.trip_fare, currency]
        : [NSString stringWithFormat:@"0.00 %@", currency];
    UILabel *fareVal = [self receiptValueLabel:fareStr];
    [ticketContent addSubview:fareKey];
    [ticketContent addSubview:fareVal];

    // Total
    UILabel *totalKey = [[UILabel alloc] init];
    totalKey.translatesAutoresizingMaskIntoConstraints = NO;
    totalKey.text = @"Total";
    totalKey.font = FONTS_NOTO_BOLD(15);
    totalKey.textColor = textMain;
    [ticketContent addSubview:totalKey];

    float taxAmt  = [trip.tax_amount_r floatValue];
    float fareAmt = [trip.trip_fare floatValue];
    UILabel *totalVal = [[UILabel alloc] init];
    totalVal.translatesAutoresizingMaskIntoConstraints = NO;
    totalVal.text = [NSString stringWithFormat:@"%.2f %@", taxAmt + fareAmt, currency];
    totalVal.font = FONTS_NOTO_BOLD(15);
    totalVal.textColor = textMain;
    [ticketContent addSubview:totalVal];

    // Bottom padding spacer
    UIView *bottomSpacer = [[UIView alloc] init];
    bottomSpacer.translatesAutoresizingMaskIntoConstraints = NO;
    [ticketContent addSubview:bottomSpacer];

    // ---- Layout constraints inside ticket ----
    [NSLayoutConstraint activateConstraints:@[
        // Pickup icon
        [pickIcon.topAnchor constraintEqualToAnchor:ticketContent.topAnchor constant:tpad],
        [pickIcon.leadingAnchor constraintEqualToAnchor:ticketContent.leadingAnchor constant:tpad],
        [pickIcon.widthAnchor constraintEqualToConstant:iconW],
        [pickIcon.heightAnchor constraintEqualToConstant:iconW],

        // Pickup name/addr
        [pickNameLbl.leadingAnchor constraintEqualToAnchor:pickIcon.trailingAnchor constant:10],
        [pickNameLbl.trailingAnchor constraintEqualToAnchor:ticketContent.trailingAnchor constant:-tpad],
        [pickNameLbl.topAnchor constraintEqualToAnchor:pickIcon.topAnchor],
        [pickAddrLbl.leadingAnchor constraintEqualToAnchor:pickNameLbl.leadingAnchor],
        [pickAddrLbl.trailingAnchor constraintEqualToAnchor:pickNameLbl.trailingAnchor],
        [pickAddrLbl.topAnchor constraintEqualToAnchor:pickNameLbl.bottomAnchor constant:2],

        // Dash line
        [dashLine.topAnchor constraintEqualToAnchor:pickIcon.bottomAnchor constant:3],
        [dashLine.centerXAnchor constraintEqualToAnchor:pickIcon.centerXAnchor],
        [dashLine.widthAnchor constraintEqualToConstant:2],
        [dashLine.bottomAnchor constraintEqualToAnchor:destIcon.topAnchor constant:-3],

        // Dest icon
        [destIcon.topAnchor constraintEqualToAnchor:pickAddrLbl.bottomAnchor constant:10],
        [destIcon.leadingAnchor constraintEqualToAnchor:ticketContent.leadingAnchor constant:tpad],
        [destIcon.widthAnchor constraintEqualToConstant:iconW],
        [destIcon.heightAnchor constraintEqualToConstant:iconW],

        // Dest name/addr
        [destNameLbl.leadingAnchor constraintEqualToAnchor:destIcon.trailingAnchor constant:10],
        [destNameLbl.trailingAnchor constraintEqualToAnchor:ticketContent.trailingAnchor constant:-tpad],
        [destNameLbl.topAnchor constraintEqualToAnchor:destIcon.topAnchor],
        [destAddrLbl.leadingAnchor constraintEqualToAnchor:destNameLbl.leadingAnchor],
        [destAddrLbl.trailingAnchor constraintEqualToAnchor:destNameLbl.trailingAnchor],
        [destAddrLbl.topAnchor constraintEqualToAnchor:destNameLbl.bottomAnchor constant:2],

        // Notch guide (zero-height) at boundary between route and details
        [notchGuide.topAnchor constraintEqualToAnchor:destAddrLbl.bottomAnchor constant:tpad],
        [notchGuide.leadingAnchor constraintEqualToAnchor:ticketContent.leadingAnchor],
        [notchGuide.trailingAnchor constraintEqualToAnchor:ticketContent.trailingAnchor],
        [notchGuide.heightAnchor constraintEqualToConstant:0],

        // Notch divider
        [notchDivider.topAnchor constraintEqualToAnchor:notchGuide.topAnchor],
        [notchDivider.leadingAnchor constraintEqualToAnchor:ticketContent.leadingAnchor constant:20],
        [notchDivider.trailingAnchor constraintEqualToAnchor:ticketContent.trailingAnchor constant:-20],
        [notchDivider.heightAnchor constraintEqualToConstant:1],

        // Estatus row
        [statusKey.topAnchor constraintEqualToAnchor:notchDivider.bottomAnchor constant:14],
        [statusKey.leadingAnchor constraintEqualToAnchor:ticketContent.leadingAnchor constant:tpad],
        [statusVal.trailingAnchor constraintEqualToAnchor:ticketContent.trailingAnchor constant:-tpad],
        [statusVal.centerYAnchor constraintEqualToAnchor:statusKey.centerYAnchor],

        // Fecha row
        [dateKey.topAnchor constraintEqualToAnchor:statusKey.bottomAnchor constant:10],
        [dateKey.leadingAnchor constraintEqualToAnchor:ticketContent.leadingAnchor constant:tpad],
        [dateVal.trailingAnchor constraintEqualToAnchor:ticketContent.trailingAnchor constant:-tpad],
        [dateVal.centerYAnchor constraintEqualToAnchor:dateKey.centerYAnchor],

        // Distancia row
        [distKey.topAnchor constraintEqualToAnchor:dateKey.bottomAnchor constant:10],
        [distKey.leadingAnchor constraintEqualToAnchor:ticketContent.leadingAnchor constant:tpad],
        [distVal.trailingAnchor constraintEqualToAnchor:ticketContent.trailingAnchor constant:-tpad],
        [distVal.centerYAnchor constraintEqualToAnchor:distKey.centerYAnchor],

        // ID row
        [idKey.topAnchor constraintEqualToAnchor:distKey.bottomAnchor constant:10],
        [idKey.leadingAnchor constraintEqualToAnchor:ticketContent.leadingAnchor constant:tpad],
        [idVal.trailingAnchor constraintEqualToAnchor:ticketContent.trailingAnchor constant:-tpad],
        [idVal.centerYAnchor constraintEqualToAnchor:idKey.centerYAnchor],

        // Fare separator
        [fareSep.topAnchor constraintEqualToAnchor:idKey.bottomAnchor constant:14],
        [fareSep.leadingAnchor constraintEqualToAnchor:ticketContent.leadingAnchor constant:tpad],
        [fareSep.trailingAnchor constraintEqualToAnchor:ticketContent.trailingAnchor constant:-tpad],
        [fareSep.heightAnchor constraintEqualToConstant:1],

        // Impuestos row
        [taxKey.topAnchor constraintEqualToAnchor:fareSep.bottomAnchor constant:14],
        [taxKey.leadingAnchor constraintEqualToAnchor:ticketContent.leadingAnchor constant:tpad],
        [taxVal.trailingAnchor constraintEqualToAnchor:ticketContent.trailingAnchor constant:-tpad],
        [taxVal.centerYAnchor constraintEqualToAnchor:taxKey.centerYAnchor],

        // Traslado row
        [fareKey.topAnchor constraintEqualToAnchor:taxKey.bottomAnchor constant:10],
        [fareKey.leadingAnchor constraintEqualToAnchor:ticketContent.leadingAnchor constant:tpad],
        [fareVal.trailingAnchor constraintEqualToAnchor:ticketContent.trailingAnchor constant:-tpad],
        [fareVal.centerYAnchor constraintEqualToAnchor:fareKey.centerYAnchor],

        // Total row
        [totalKey.topAnchor constraintEqualToAnchor:fareKey.bottomAnchor constant:10],
        [totalKey.leadingAnchor constraintEqualToAnchor:ticketContent.leadingAnchor constant:tpad],
        [totalVal.trailingAnchor constraintEqualToAnchor:ticketContent.trailingAnchor constant:-tpad],
        [totalVal.centerYAnchor constraintEqualToAnchor:totalKey.centerYAnchor],

        // Bottom spacer anchors ticket bottom
        [bottomSpacer.topAnchor constraintEqualToAnchor:totalKey.bottomAnchor constant:tpad],
        [bottomSpacer.leadingAnchor constraintEqualToAnchor:ticketContent.leadingAnchor],
        [bottomSpacer.trailingAnchor constraintEqualToAnchor:ticketContent.trailingAnchor],
        [bottomSpacer.heightAnchor constraintEqualToConstant:4],
        [bottomSpacer.bottomAnchor constraintEqualToAnchor:ticketContent.bottomAnchor],
    ]];

    // Anchor ticket bottom to content bottom
    [NSLayoutConstraint activateConstraints:@[
        [ticket.bottomAnchor constraintEqualToAnchor:content.bottomAnchor constant:-20],
    ]];
}

/// Helper: gray key label for receipt rows
- (UILabel *)receiptKeyLabel:(NSString *)text {
    UILabel *lbl = [[UILabel alloc] init];
    lbl.translatesAutoresizingMaskIntoConstraints = NO;
    lbl.text = text;
    lbl.font = FONTS_NOTO_REGULAR(13);
    lbl.textColor = [UIColor colorWithWhite:0.5 alpha:1];
    return lbl;
}

/// Helper: dark value label for receipt rows
- (UILabel *)receiptValueLabel:(NSString *)text {
    UILabel *lbl = [[UILabel alloc] init];
    lbl.translatesAutoresizingMaskIntoConstraints = NO;
    lbl.text = text;
    lbl.font = FONTS_NOTO_REGULAR(13);
    lbl.textColor = [UIColor colorNamed:@"color_app_label"] ?: [UIColor blackColor];
    lbl.textAlignment = NSTextAlignmentRight;
    return lbl;
}

/// Apply ticket cutout mask: rounded rect with two semicircle bites at notchY (in sheet coords)
- (void)applyTicketMaskToView:(UIView *)ticketView atNotchY:(CGFloat)notchY {
    if (!ticketView) return;

    // notchY is in sheet coordinates; convert to ticket view coordinates
    CGFloat localY = notchY;  // ticket is positioned relative to content, not sheet directly
    // We need notchY relative to ticketView's own bounds
    // Use the notchGuide which is a subview of ticketView (not the sheet)
    UIView *notchGuide = [ticketView viewWithTag:kTHReceiptNotchGuide];
    if (notchGuide) {
        localY = notchGuide.frame.origin.y;
    }

    CGRect bounds = ticketView.bounds;
    CGFloat radius = 14.0; // Matches ticket corner radius
    CGFloat notchR = 12.0; // Semicircle notch radius

    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:bounds cornerRadius:radius];

    // Left notch: semicircle biting into left edge at localY
    UIBezierPath *leftNotch = [UIBezierPath bezierPathWithArcCenter:CGPointMake(0, localY)
                                                             radius:notchR
                                                         startAngle:-M_PI_2
                                                           endAngle:M_PI_2
                                                          clockwise:YES];
    [path appendPath:leftNotch];

    // Right notch: semicircle biting into right edge at localY
    UIBezierPath *rightNotch = [UIBezierPath bezierPathWithArcCenter:CGPointMake(bounds.size.width, localY)
                                                              radius:notchR
                                                          startAngle:M_PI_2
                                                            endAngle:-M_PI_2
                                                           clockwise:YES];
    [path appendPath:rightNotch];

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

    CGRect offscreen = sheet.frame;
    offscreen.origin.y = sheet.superview.bounds.size.height;

    [UIView animateWithDuration:0.24 animations:^{
        overlay.alpha = 0;
        sheet.frame = offscreen;
    } completion:^(BOOL finished) {
        [overlay removeFromSuperview];
        [sheet removeFromSuperview];
    }];
}

-(void)addRideDetailView :(NSUInteger)index {
    
    self.tripDetailsViewController = (UTripDetailsViewController *)[StoryBoardUtiles viewContollerInUserWithIdentifier:StoryBoardUtiles.UTRIP_DETAIL_VC ];
    [self addChildViewController:self.tripDetailsViewController];
    self.tripDetailsViewController.trip = [tripArrayPast objectAtIndex:index];
    [self.tripDetailsViewController.view setFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height)];
    [self.view addSubview:self.tripDetailsViewController.view];
    [self.tripDetailsViewController didMoveToParentViewController:self];
    self.tripDetailsViewController.tripDetailDelegate = self;
    // [self.tripDetailsViewController.view setBackgroundColor:[UIColor clearColor]];
    
}

-(void)viewController:(UTripDetailsViewController *)viewController tripModel:(TripModel *)tripModel
{
    
}

-(void)onDismissDetailTrip{
    [self.tripDetailsViewController.view removeFromSuperview];
    [self.tripDetailsViewController removeFromParentViewController];
}
-(void) goToFareSummeryScreenWhenTripCancelByRider:(TripModel *)tripModel
{
    UFareSummeryViewController *fareView= (UFareSummeryViewController *) [StoryBoardUtiles viewContollerInUserWithIdentifier:StoryBoardUtiles.UFARE_SUMMERY_VC];
    
    ConstantModel *  constantTaxiModel =[ConstantModel getConstantsObject];
    fareView.curr_trip = tripModel;
    fareView.constantModel =constantTaxiModel;
    [self.navigationController pushViewController:fareView animated:YES];
}
@end
