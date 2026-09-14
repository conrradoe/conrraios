//
//  MyEarnings.m

//
//  Created by Grepix Infotech on 01/01/20.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import "MyEarningsViewController.h"
#import "LanguageHelper.h"
#import <MapKit/MapKit.h>
#import <GIKit/GIKit.h>
#import "CustomPointAnnotation.h"
#import "WebCallConstants.h"
#import "Utilities.h"
#import "UIView+UpdateAutoLayoutConstraints.h"
#import "CategoryModel.h"
#import "ConstantModel.h"
#import "AppDelegate.h"
#import "WebCallConstants.h"
#import "CityModel.h"
#import "UserProfile.h"
@interface MyEarningsViewController ()
{
    NSMutableArray *tripArray;
    BOOL IsLoadNext;
    ConstantModel  *constantModel;
    NSString *currency;
    UILabel *_ndSaldoLabel;
    // Accordion state (index 0=today, 1=week, 2=month)
    NSMutableArray *_cardContentViews;          // UIView per card
    NSMutableArray *_cardCollapseConstraints;   // NSLayoutConstraint (height=0) per card — active when collapsed
    NSMutableArray *_cardExpandedConstraints;   // NSLayoutConstraint (amtText.bottom) per card — active when expanded
    NSMutableArray *_cardChevrons;              // UIImageView per card
    NSMutableArray *_cardExpanded;              // NSNumber<BOOL> per card
}
@end

@implementation MyEarningsViewController
{
    CategoryModel *earningCategory;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    CityModel *cModel = [CityModel getCityByCityId:[UserProfile shared].cityID];
    currency = isEmpty(cModel.city_cur);
    [self setupNewDesign];
}



-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self setUIFields];
}


-(void)setThemeConstants{
}



-(void) setUIFields{
    self.lblTodayText.text  = @"HOY";
    self.lblWeekText.text   = @"ESTA SEMANA";
    self.lblMonthText.text  = @"ESTE MES";

    self.lblTodayRidesText.text     = @"Paseo total:";
    self.lblTodayAccepetedText.text = @"Aceptado:";
    self.lblTodayCancelledText.text = @"Cancelado:";
    self.lblTodayCompletedText.text = @"Terminado:";
    self.lblTodayAmountText.text    = @"Monto ganado:";

    self.lblWeekRidesText.text     = @"Paseo total:";
    self.lblWeekAccepetedText.text = @"Aceptado:";
    self.lblWeekCancelledText.text = @"Cancelado:";
    self.lblWeekCompletedText.text = @"Terminado:";
    self.lblWeekAmountText.text    = @"Monto ganado:";

    self.lblMonthRidesText.text     = @"Paseo total:";
    self.lblMonthAcceptedText.text  = @"Aceptado:";
    self.lblMonthCancelledText.text = @"Cancelado:";
    self.lblMonthCompletedText.text = @"Terminado:";
    self.lblMonthAmountText.text    = @"Monto ganado:";
}

-(void)setDataOnUI{
    NSDate * date=[NSDate date];
    NSDateFormatter * df=[[NSDateFormatter alloc] init];
    df.dateFormat=@"MMM dd, yyyy";
    self.lblDate.text=[df stringFromDate:date];
    
    
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDate *now = [NSDate date];
    NSDate *startOfTheWeek;
    NSDate *endOfWeek;
    NSTimeInterval interval;
    //    NSLocale * locale=[NSLocale localeWithLocaleIdentifier:@"en_US"];
    //    [cal setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US"]];
    [cal rangeOfUnit:NSCalendarUnitWeekOfYear
           startDate:&startOfTheWeek
            interval:&interval
             forDate:now];
    //startOfWeek holds now the first day of the week, according to locale (monday vs. sunday)
    
    
    endOfWeek = [startOfTheWeek dateByAddingTimeInterval:interval];
    
    NSUInteger units = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
    NSDateComponents *comps = [[NSCalendar currentCalendar] components:units fromDate:startOfTheWeek];
    // Add one day
    comps.day = comps.day + 1; // no worries: even if it is the end of the month it will wrap to the next month, see doc
    // Recompose a new date, without any time information (so this will be at midnight)
    NSDate *tomorrowMidnight = [[NSCalendar currentCalendar] dateFromComponents:comps];
    
    self.lblWeekDate.text=[NSString stringWithFormat:@"%@ - %@",[df stringFromDate:tomorrowMidnight],[df stringFromDate:endOfWeek]];
    df.dateFormat=@"MMM,yyyy";
    self.lblMonth.text=[df stringFromDate:date];
}

- (IBAction)btnBackPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


-(void) getEarnDeatails{
    NSDictionary *dict1 = [[NSUserDefaults standardUserDefaults]objectForKey:P_USER_DICT];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{P_DRIVER_ID :[dict1 objectForKey:P_DRIVER_ID]}];
    [UtilityClass setLH:NO wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
    [GIC mkwu:GET_EARNINGS    d:dict   isa:NO  cb:^(id results, NSError *error) {
        [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
        if ([[[results objectForKey:P_STATUS] uppercaseString] isEqualToString:@"OK"]) {
            
            NSMutableDictionary *dict3=[results objectForKey:P_RESPONSE];
            if([dict3 isKindOfClass:[NSDictionary class]])
            {
                NSArray *arrToday=[dict3 objectForKey:@"Today"];
                NSArray *arrMonth=[dict3 objectForKey:@"Month"];
                NSArray *arrWeek=[dict3 objectForKey:@"Month"];
                
                [self showMonthData:arrMonth];
                [self showDailyData:arrToday];
                [self showWeekData:arrWeek];
            }
        }
    }];
}




-(void)showMonthData:(NSArray *)arrMonth{
    self.lblMonthRidesValue.text = @"0";
    self.lblMonthAmountValue.text = @"0";
    if(arrMonth.count>0)  {
        NSDictionary * dict =arrMonth.firstObject;
        int count= [[ dict objectForKey:@"total_trips"] intValue];
        if(count==0){
            self.lblMonthRidesValue.text = @"0";
        }else{
            self.lblMonthRidesValue.text = [NSString stringWithFormat:@"%d",count];
        }
        int countAccepted= [[ dict objectForKey:@"total_accepted_trips"] intValue];
        if(countAccepted==0){
            self.lblMonthAcceptedValue.text = @"0";
        }else{
            self.lblMonthAcceptedValue.text = [NSString stringWithFormat:@"%d",countAccepted];
        }
        
        
        int countCancelled= [[ dict objectForKey:@"total_cancelled_trips"] intValue];
        if(countCancelled==0){
            self.lblMonthCancelledValue.text = @"0";
        }else{
            self.lblMonthCancelledValue.text = [NSString stringWithFormat:@"%d",countCancelled];
        }
        int countCompleted= [[ dict objectForKey:@"total_completed_trips"] intValue];
        if(countCompleted==0){
            self.lblMonthCompletedValue.text = @"0";
        }else{
            self.lblMonthCompletedValue.text = [NSString stringWithFormat:@"%d",countCompleted];
        }
        
        NSString *strTrips = [Utilities formatAmountAndCurrency:[[ dict objectForKey:@"total_pay_amt"] floatValue] currency:isEmpty(self->currency)] ;
        self.lblMonthAmountValue.text = strTrips;
    }
}



-(void)showDailyData:(NSArray *)arrMonth{
    self.lblTodayRidesValue.text = @"0";
    self.lblTodayAmountValue.text = @"0";
    if(arrMonth.count>0)  {
        NSDictionary * dict =arrMonth.firstObject;
        int count= [[ dict objectForKey:@"total_trips"] intValue];
        if(count==0){
            self.lblTodayRidesValue.text = @"0";
        }else{
            self.lblTodayRidesValue.text = [NSString stringWithFormat:@"%d",count];
        }
        
        
        int countAccepted= [[ dict objectForKey:@"total_accepted_trips"] intValue];
        if(countAccepted==0){
            self.lblTodayAccepetedValue.text = @"0";
        }else{
            self.lblTodayAccepetedValue.text = [NSString stringWithFormat:@"%d",countAccepted];
        }
        
        
        int countCancelled= [[ dict objectForKey:@"total_cancelled_trips"] intValue];
        if(countCancelled==0){
            self.lblTodayCancelledValue.text = @"0";
        }else{
            self.lblTodayCancelledValue.text = [NSString stringWithFormat:@"%d",countCancelled];
        }
        int countCompleted= [[ dict objectForKey:@"total_completed_trips"] intValue];
        if(countCompleted==0){
            self.lblTodayCompletedValue.text = @"0";
        }else{
            self.lblTodayCompletedValue.text = [NSString stringWithFormat:@"%d",countCompleted];
        }
        NSString *strTrips =[Utilities formatAmountAndCurrency:[[ dict objectForKey:@"total_pay_amt"] floatValue] currency:isEmpty(self->currency)] ;
        self.lblTodayAmountValue.text = strTrips;
    }
}


-(void)showWeekData:(NSArray *)arrMonth{
    self.lblWeekRidesValue.text = @"0";
    self.lblWeekAmountValue.text = @"0";
    if(arrMonth.count>0)  {
        NSDictionary * dict =arrMonth.firstObject;
        int count= [[ dict objectForKey:@"total_trips"] intValue];
        if(count==0){
            self.lblWeekRidesValue.text = @"0";
        }else{
            self.lblWeekRidesValue.text = [NSString stringWithFormat:@"%d",count];
        }
        int countAccepted= [[ dict objectForKey:@"total_accepted_trips"] intValue];
        if(countAccepted==0){
            self.lblWeekAccepetedValue.text = @"0";
        }else{
            self.lblWeekAccepetedValue.text = [NSString stringWithFormat:@"%d",countAccepted];
        }
        
        
        int countCancelled= [[ dict objectForKey:@"total_cancelled_trips"] intValue];
        if(countCancelled==0){
            self.lblWeekCancelledValue.text = @"0";
        }else{
            self.lblWeekCancelledValue.text = [NSString stringWithFormat:@"%d",countCancelled];
        }
        int countCompleted= [[ dict objectForKey:@"total_completed_trips"] intValue];
        if(countCompleted==0){
            self.lblWeekCompletedValue.text = @"0";
        }else{
            self.lblWeekCompletedValue.text = [NSString stringWithFormat:@"%d",countCompleted];
        }
        
        NSString *strMonth =[Utilities formatAmountAndCurrency:[[ dict objectForKey:@"total_pay_amt"]floatValue] currency:isEmpty(self->currency)];
        self.lblWeekAmountValue.text = strMonth;
    }
}

#pragma mark - New Design

- (void)setupNewDesign {
    for (UIView *v in [self.view.subviews copy]) { v.hidden = YES; }

    self.view.backgroundColor = [UIColor colorWithRed:0.96 green:0.96 blue:0.96 alpha:1];

    UILayoutGuide *safe = self.view.safeAreaLayoutGuide;
    UIColor *textMain = [UIColor colorNamed:@"color_app_label"] ?: [UIColor blackColor];

    UIView *header = [[UIView alloc] init];
    header.translatesAutoresizingMaskIntoConstraints = NO;
    header.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:header];

    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    backBtn.translatesAutoresizingMaskIntoConstraints = NO;
    backBtn.tintColor = textMain;
    if (@available(iOS 13, *)) {
        UIImageSymbolConfiguration *cfg = [UIImageSymbolConfiguration configurationWithWeight:UIImageSymbolWeightMedium];
        [backBtn setImage:[[UIImage systemImageNamed:@"chevron.left" withConfiguration:cfg]
                           imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
                 forState:UIControlStateNormal];
    } else {
        [backBtn setTitle:@"‹" forState:UIControlStateNormal];
        backBtn.titleLabel.font = [UIFont systemFontOfSize:26 weight:UIFontWeightLight];
    }
    [backBtn addTarget:self action:@selector(btnBackPressed:) forControlEvents:UIControlEventTouchUpInside];
    [header addSubview:backBtn];

    UILabel *titleLbl = [[UILabel alloc] init];
    titleLbl.translatesAutoresizingMaskIntoConstraints = NO;
    titleLbl.text = [LanguageHelper getStringWithKey:@"k_1_s13_my_earnings" defaultValue:@"Mis Ganancias"];
    titleLbl.font = FONTS_NOTO_BOLD(18);
    titleLbl.textColor = textMain;
    [header addSubview:titleLbl];

    UIView *headerSep = [[UIView alloc] init];
    headerSep.translatesAutoresizingMaskIntoConstraints = NO;
    headerSep.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
    [header addSubview:headerSep];

    [NSLayoutConstraint activateConstraints:@[
        [header.topAnchor constraintEqualToAnchor:safe.topAnchor],
        [header.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [header.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [header.heightAnchor constraintEqualToConstant:56],
        [backBtn.leadingAnchor constraintEqualToAnchor:header.leadingAnchor constant:16],
        [backBtn.centerYAnchor constraintEqualToAnchor:header.centerYAnchor],
        [backBtn.widthAnchor constraintEqualToConstant:36],
        [backBtn.heightAnchor constraintEqualToConstant:36],
        [titleLbl.centerXAnchor constraintEqualToAnchor:header.centerXAnchor],
        [titleLbl.centerYAnchor constraintEqualToAnchor:header.centerYAnchor],
        [headerSep.bottomAnchor constraintEqualToAnchor:header.bottomAnchor],
        [headerSep.leadingAnchor constraintEqualToAnchor:header.leadingAnchor],
        [headerSep.trailingAnchor constraintEqualToAnchor:header.trailingAnchor],
        [headerSep.heightAnchor constraintEqualToConstant:1],
    ]];

    UIView *balanceBar = [[UIView alloc] init];
    balanceBar.translatesAutoresizingMaskIntoConstraints = NO;
    balanceBar.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:balanceBar];

    UILabel *saldoTitle = [[UILabel alloc] init];
    saldoTitle.translatesAutoresizingMaskIntoConstraints = NO;
    saldoTitle.text = [LanguageHelper getStringWithKey:@"k_s10_balance_available" defaultValue:@"Saldo Disponible:"];
    saldoTitle.font = FONTS_NOTO_BOLD(14);
    saldoTitle.textColor = textMain;
    [balanceBar addSubview:saldoTitle];

    UILabel *saldoValue = [[UILabel alloc] init];
    saldoValue.translatesAutoresizingMaskIntoConstraints = NO;
    saldoValue.text = @"$0.00";
    saldoValue.font = FONTS_NOTO_BOLD(14);
    saldoValue.textColor = [UIColor colorWithRed:0.02 green:0.62 blue:0.35 alpha:1];
    saldoValue.textAlignment = NSTextAlignmentRight;
    [balanceBar addSubview:saldoValue];
    _ndSaldoLabel = saldoValue;

    UILabel *tasaTitle = [[UILabel alloc] init];
    tasaTitle.translatesAutoresizingMaskIntoConstraints = NO;
    tasaTitle.text = [LanguageHelper getStringWithKey:@"k_s10_exchange_rate" defaultValue:@"Tasa de cambio"];
    tasaTitle.font = FONTS_NOTO_REGULAR(13);
    tasaTitle.textColor = [UIColor colorWithWhite:0.5 alpha:1];
    [balanceBar addSubview:tasaTitle];

    UILabel *tasaValue = [[UILabel alloc] init];
    tasaValue.translatesAutoresizingMaskIntoConstraints = NO;
    tasaValue.text = @"Bs. 0.00";
    tasaValue.font = FONTS_NOTO_REGULAR(13);
    tasaValue.textColor = [UIColor colorWithWhite:0.5 alpha:1];
    tasaValue.textAlignment = NSTextAlignmentRight;
    [balanceBar addSubview:tasaValue];

    UIView *balanceSep = [[UIView alloc] init];
    balanceSep.translatesAutoresizingMaskIntoConstraints = NO;
    balanceSep.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
    [balanceBar addSubview:balanceSep];

    CGFloat bp = 20.0;
    [NSLayoutConstraint activateConstraints:@[
        [balanceBar.topAnchor constraintEqualToAnchor:header.bottomAnchor],
        [balanceBar.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [balanceBar.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],

        [saldoTitle.topAnchor constraintEqualToAnchor:balanceBar.topAnchor constant:14],
        [saldoTitle.leadingAnchor constraintEqualToAnchor:balanceBar.leadingAnchor constant:bp],
        [saldoValue.centerYAnchor constraintEqualToAnchor:saldoTitle.centerYAnchor],
        [saldoValue.trailingAnchor constraintEqualToAnchor:balanceBar.trailingAnchor constant:-bp],
        [saldoValue.leadingAnchor constraintGreaterThanOrEqualToAnchor:saldoTitle.trailingAnchor constant:8],

        [tasaTitle.topAnchor constraintEqualToAnchor:saldoTitle.bottomAnchor constant:6],
        [tasaTitle.leadingAnchor constraintEqualToAnchor:balanceBar.leadingAnchor constant:bp],
        [tasaValue.centerYAnchor constraintEqualToAnchor:tasaTitle.centerYAnchor],
        [tasaValue.trailingAnchor constraintEqualToAnchor:balanceBar.trailingAnchor constant:-bp],
        [tasaValue.leadingAnchor constraintGreaterThanOrEqualToAnchor:tasaTitle.trailingAnchor constant:8],

        [balanceSep.topAnchor constraintEqualToAnchor:tasaTitle.bottomAnchor constant:14],
        [balanceSep.leadingAnchor constraintEqualToAnchor:balanceBar.leadingAnchor],
        [balanceSep.trailingAnchor constraintEqualToAnchor:balanceBar.trailingAnchor],
        [balanceSep.heightAnchor constraintEqualToConstant:1],
        [balanceSep.bottomAnchor constraintEqualToAnchor:balanceBar.bottomAnchor],
    ]];

    // Populate saldo from wallet
    [self refreshSaldoLabel];

    UIScrollView *scroll = [[UIScrollView alloc] init];
    scroll.translatesAutoresizingMaskIntoConstraints = NO;
    scroll.showsVerticalScrollIndicator = NO;
    scroll.backgroundColor = [UIColor clearColor];
    [self.view addSubview:scroll];

    UIView *content = [[UIView alloc] init];
    content.translatesAutoresizingMaskIntoConstraints = NO;
    [scroll addSubview:content];

    [NSLayoutConstraint activateConstraints:@[
        [scroll.topAnchor constraintEqualToAnchor:balanceBar.bottomAnchor],
        [scroll.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [scroll.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [scroll.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
        [content.topAnchor constraintEqualToAnchor:scroll.topAnchor],
        [content.leadingAnchor constraintEqualToAnchor:scroll.leadingAnchor],
        [content.trailingAnchor constraintEqualToAnchor:scroll.trailingAnchor],
        [content.bottomAnchor constraintEqualToAnchor:scroll.bottomAnchor],
        [content.widthAnchor constraintEqualToAnchor:scroll.widthAnchor],
    ]];

    _cardContentViews        = [NSMutableArray array];
    _cardCollapseConstraints = [NSMutableArray array];
    _cardExpandedConstraints = [NSMutableArray array];
    _cardChevrons            = [NSMutableArray array];
    _cardExpanded            = [NSMutableArray arrayWithObjects:@NO, @NO, @NO, nil];

    UILabel *todayTitleOut = nil, *todayDateOut = nil;
    UILabel *todayTripsTextOut = nil, *todayTripsValOut = nil;
    UILabel *todayAccTextOut = nil, *todayAccValOut = nil;
    UILabel *todayCancelTextOut = nil, *todayCancelValOut = nil;
    UILabel *todayCompleteTextOut = nil, *todayCompleteValOut = nil;
    UILabel *todayAmtTextOut = nil, *todayAmtValOut = nil;
    UIView *todayCard = [self buildEarningsCardIn:content cardIndex:0
        titleLabel:&todayTitleOut dateLabel:&todayDateOut
        ridesTextLabel:&todayTripsTextOut ridesValLabel:&todayTripsValOut
        accTextLabel:&todayAccTextOut accValLabel:&todayAccValOut
        cancelTextLabel:&todayCancelTextOut cancelValLabel:&todayCancelValOut
        completeTextLabel:&todayCompleteTextOut completeValLabel:&todayCompleteValOut
        amtTextLabel:&todayAmtTextOut amtValLabel:&todayAmtValOut];

    UILabel *weekTitleOut = nil, *weekDateOut = nil;
    UILabel *weekTripsTextOut = nil, *weekTripsValOut = nil;
    UILabel *weekAccTextOut = nil, *weekAccValOut = nil;
    UILabel *weekCancelTextOut = nil, *weekCancelValOut = nil;
    UILabel *weekCompleteTextOut = nil, *weekCompleteValOut = nil;
    UILabel *weekAmtTextOut = nil, *weekAmtValOut = nil;
    UIView *weekCard = [self buildEarningsCardIn:content cardIndex:1
        titleLabel:&weekTitleOut dateLabel:&weekDateOut
        ridesTextLabel:&weekTripsTextOut ridesValLabel:&weekTripsValOut
        accTextLabel:&weekAccTextOut accValLabel:&weekAccValOut
        cancelTextLabel:&weekCancelTextOut cancelValLabel:&weekCancelValOut
        completeTextLabel:&weekCompleteTextOut completeValLabel:&weekCompleteValOut
        amtTextLabel:&weekAmtTextOut amtValLabel:&weekAmtValOut];

    UILabel *monthTitleOut = nil, *monthDateOut = nil;
    UILabel *monthTripsTextOut = nil, *monthTripsValOut = nil;
    UILabel *monthAccTextOut = nil, *monthAccValOut = nil;
    UILabel *monthCancelTextOut = nil, *monthCancelValOut = nil;
    UILabel *monthCompleteTextOut = nil, *monthCompleteValOut = nil;
    UILabel *monthAmtTextOut = nil, *monthAmtValOut = nil;
    UIView *monthCard = [self buildEarningsCardIn:content cardIndex:2
        titleLabel:&monthTitleOut dateLabel:&monthDateOut
        ridesTextLabel:&monthTripsTextOut ridesValLabel:&monthTripsValOut
        accTextLabel:&monthAccTextOut accValLabel:&monthAccValOut
        cancelTextLabel:&monthCancelTextOut cancelValLabel:&monthCancelValOut
        completeTextLabel:&monthCompleteTextOut completeValLabel:&monthCompleteValOut
        amtTextLabel:&monthAmtTextOut amtValLabel:&monthAmtValOut];

    CGFloat pad = 16.0, gap = 14.0;
    [NSLayoutConstraint activateConstraints:@[
        [todayCard.topAnchor constraintEqualToAnchor:content.topAnchor constant:pad],
        [todayCard.leadingAnchor constraintEqualToAnchor:content.leadingAnchor constant:pad],
        [todayCard.trailingAnchor constraintEqualToAnchor:content.trailingAnchor constant:-pad],
        [weekCard.topAnchor constraintEqualToAnchor:todayCard.bottomAnchor constant:gap],
        [weekCard.leadingAnchor constraintEqualToAnchor:content.leadingAnchor constant:pad],
        [weekCard.trailingAnchor constraintEqualToAnchor:content.trailingAnchor constant:-pad],
        [monthCard.topAnchor constraintEqualToAnchor:weekCard.bottomAnchor constant:gap],
        [monthCard.leadingAnchor constraintEqualToAnchor:content.leadingAnchor constant:pad],
        [monthCard.trailingAnchor constraintEqualToAnchor:content.trailingAnchor constant:-pad],
        [monthCard.bottomAnchor constraintEqualToAnchor:content.bottomAnchor constant:-pad],
    ]];

    self.lblTodayText            = todayTitleOut;
    self.lblDate                 = todayDateOut;
    self.lblTodayRidesText       = todayTripsTextOut;
    self.lblTodayRidesValue      = todayTripsValOut;
    self.lblTodayAccepetedText   = todayAccTextOut;
    self.lblTodayAccepetedValue  = todayAccValOut;
    self.lblTodayCancelledText   = todayCancelTextOut;
    self.lblTodayCancelledValue  = todayCancelValOut;
    self.lblTodayCompletedText   = todayCompleteTextOut;
    self.lblTodayCompletedValue  = todayCompleteValOut;
    self.lblTodayAmountText      = todayAmtTextOut;
    self.lblTodayAmountValue     = todayAmtValOut;

    self.lblWeekText             = weekTitleOut;
    self.lblWeekDate             = weekDateOut;
    self.lblWeekRidesText        = weekTripsTextOut;
    self.lblWeekRidesValue       = weekTripsValOut;
    self.lblWeekAccepetedText    = weekAccTextOut;
    self.lblWeekAccepetedValue   = weekAccValOut;
    self.lblWeekCancelledText    = weekCancelTextOut;
    self.lblWeekCancelledValue   = weekCancelValOut;
    self.lblWeekCompletedText    = weekCompleteTextOut;
    self.lblWeekCompletedValue   = weekCompleteValOut;
    self.lblWeekAmountText       = weekAmtTextOut;
    self.lblWeekAmountValue      = weekAmtValOut;

    self.lblMonthText            = monthTitleOut;
    self.lblMonth                = monthDateOut;
    self.lblMonthRidesText       = monthTripsTextOut;
    self.lblMonthRidesValue      = monthTripsValOut;
    self.lblMonthAcceptedText    = monthAccTextOut;
    self.lblMonthAcceptedValue   = monthAccValOut;
    self.lblMonthCancelledText   = monthCancelTextOut;
    self.lblMonthCancelledValue  = monthCancelValOut;
    self.lblMonthCompletedText   = monthCompleteTextOut;
    self.lblMonthCompletedValue  = monthCompleteValOut;
    self.lblMonthAmountText      = monthAmtTextOut;
    self.lblMonthAmountValue     = monthAmtValOut;

    // Seed Spanish labels, dates, and kick off API
    [self setUIFields];
    [self setDataOnUI];
    [self getEarnDeatails];
}

- (void)refreshSaldoLabel {
    if (!_ndSaldoLabel) return;
    NSDictionary *dict = [[NSUserDefaults standardUserDefaults] objectForKey:P_USER_DICT];
    float balance = [[dict objectForKey:P_DRIVER_WAlLET_AMOUNT] floatValue];
    CityModel *cityModel = [CityModel getCityByDriverCityId];
    NSString *cur = isEmpty(cityModel.city_cur);
    if (balance == 0) {
        _ndSaldoLabel.text = [Utilities formatAmountAndCurrencyZero:0 currency:cur];
    } else {
        _ndSaldoLabel.text = [Utilities formatAmountAndCurrency:balance currency:cur];
    }
    _ndSaldoLabel.textColor = (balance < 0)
        ? [UIColor redColor]
        : [UIColor colorWithRed:0.02 green:0.62 blue:0.35 alpha:1];
}

- (UIView *)buildEarningsCardIn:(UIView *)parent
                     cardIndex:(NSInteger)cardIndex
                    titleLabel:(UILabel **)titleOut
                     dateLabel:(UILabel **)dateOut
                ridesTextLabel:(UILabel **)ridesTextOut
                 ridesValLabel:(UILabel **)ridesValOut
                  accTextLabel:(UILabel **)accTextOut
                   accValLabel:(UILabel **)accValOut
               cancelTextLabel:(UILabel **)cancelTextOut
                cancelValLabel:(UILabel **)cancelValOut
             completeTextLabel:(UILabel **)completeTextOut
              completeValLabel:(UILabel **)completeValOut
                  amtTextLabel:(UILabel **)amtTextOut
                   amtValLabel:(UILabel **)amtValOut {

    UIColor *textMain = [UIColor colorNamed:@"color_app_label"] ?: [UIColor blackColor];
    UIColor *textGray = [UIColor colorWithWhite:0.45 alpha:1];
    CGFloat p = 16.0;

    UIView *card = [[UIView alloc] init];
    card.translatesAutoresizingMaskIntoConstraints = NO;
    card.backgroundColor = [UIColor whiteColor];
    card.layer.cornerRadius = 14;
    card.layer.shadowColor = [UIColor blackColor].CGColor;
    card.layer.shadowOpacity = 0.07;
    card.layer.shadowRadius = 8;
    card.layer.shadowOffset = CGSizeMake(0, 2);
    card.layer.masksToBounds = NO;
    card.clipsToBounds = NO;
    [parent addSubview:card];

    UIView *headerView = [[UIView alloc] init];
    headerView.translatesAutoresizingMaskIntoConstraints = NO;
    headerView.tag = cardIndex;
    [card addSubview:headerView];

    UILabel *titleLbl = [[UILabel alloc] init];
    titleLbl.translatesAutoresizingMaskIntoConstraints = NO;
    titleLbl.font = FONTS_NOTO_BOLD(15);
    titleLbl.textColor = textMain;
    [headerView addSubview:titleLbl];
    if (titleOut) *titleOut = titleLbl;

    UILabel *dateLbl = [[UILabel alloc] init];
    dateLbl.translatesAutoresizingMaskIntoConstraints = NO;
    dateLbl.font = FONTS_NOTO_REGULAR(12);
    dateLbl.textColor = textGray;
    [headerView addSubview:dateLbl];
    if (dateOut) *dateOut = dateLbl;

    // Arrow icon — ic_arrow_down (collapsed), ic_arrow_up (expanded)
    UIImageView *chevron = [[UIImageView alloc] init];
    chevron.translatesAutoresizingMaskIntoConstraints = NO;
    chevron.contentMode = UIViewContentModeScaleAspectFit;
    chevron.tintColor = textGray;
    UIImage *arrowDown = [UIImage imageNamed:@"ic_arrow_down"];
    if (!arrowDown) {
        if (@available(iOS 13, *)) {
            UIImageSymbolConfiguration *cfg = [UIImageSymbolConfiguration configurationWithWeight:UIImageSymbolWeightLight];
            arrowDown = [[UIImage systemImageNamed:@"chevron.down" withConfiguration:cfg]
                         imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        }
    }
    chevron.image = arrowDown;
    [headerView addSubview:chevron];
    [_cardChevrons addObject:chevron];

    [NSLayoutConstraint activateConstraints:@[
        [headerView.topAnchor constraintEqualToAnchor:card.topAnchor],
        [headerView.leadingAnchor constraintEqualToAnchor:card.leadingAnchor],
        [headerView.trailingAnchor constraintEqualToAnchor:card.trailingAnchor],

        [titleLbl.topAnchor constraintEqualToAnchor:headerView.topAnchor constant:16],
        [titleLbl.leadingAnchor constraintEqualToAnchor:headerView.leadingAnchor constant:p],
        [titleLbl.trailingAnchor constraintLessThanOrEqualToAnchor:chevron.leadingAnchor constant:-8],
        [dateLbl.topAnchor constraintEqualToAnchor:titleLbl.bottomAnchor constant:2],
        [dateLbl.leadingAnchor constraintEqualToAnchor:headerView.leadingAnchor constant:p],
        [dateLbl.trailingAnchor constraintLessThanOrEqualToAnchor:chevron.leadingAnchor constant:-8],
        [dateLbl.bottomAnchor constraintEqualToAnchor:headerView.bottomAnchor constant:-16],
        [chevron.centerYAnchor constraintEqualToAnchor:headerView.centerYAnchor],
        [chevron.trailingAnchor constraintEqualToAnchor:headerView.trailingAnchor constant:-p],
        [chevron.widthAnchor constraintEqualToConstant:20],
        [chevron.heightAnchor constraintEqualToConstant:20],
    ]];

    // Tap gesture on header
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
        initWithTarget:self action:@selector(onCardHeaderTapped:)];
    headerView.userInteractionEnabled = YES;
    [headerView addGestureRecognizer:tap];

    UIView *contentView = [[UIView alloc] init];
    contentView.translatesAutoresizingMaskIntoConstraints = NO;
    contentView.clipsToBounds = YES;
    [card addSubview:contentView];
    [_cardContentViews addObject:contentView];

    // Separator at top of content
    UIView *sep0 = [[UIView alloc] init];
    sep0.translatesAutoresizingMaskIntoConstraints = NO;
    sep0.backgroundColor = [UIColor colorWithWhite:0.92 alpha:1];
    [contentView addSubview:sep0];

    // Stat rows
    UILabel *ridesText = [self makeStatTextLabel:textGray];  [contentView addSubview:ridesText];  if (ridesTextOut) *ridesTextOut = ridesText;
    UILabel *ridesVal  = [self makeStatValueLabel:textMain]; [contentView addSubview:ridesVal];   if (ridesValOut)  *ridesValOut  = ridesVal;
    UILabel *accText   = [self makeStatTextLabel:textGray];  [contentView addSubview:accText];    if (accTextOut)   *accTextOut   = accText;
    UILabel *accVal    = [self makeStatValueLabel:textMain]; [contentView addSubview:accVal];     if (accValOut)    *accValOut    = accVal;
    UILabel *cancelText = [self makeStatTextLabel:textGray]; [contentView addSubview:cancelText]; if (cancelTextOut) *cancelTextOut = cancelText;
    UILabel *cancelVal  = [self makeStatValueLabel:textMain];[contentView addSubview:cancelVal];  if (cancelValOut)  *cancelValOut  = cancelVal;
    UILabel *completeText = [self makeStatTextLabel:textGray]; [contentView addSubview:completeText]; if (completeTextOut) *completeTextOut = completeText;
    UILabel *completeVal  = [self makeStatValueLabel:textMain];[contentView addSubview:completeVal];  if (completeValOut)  *completeValOut  = completeVal;

    UIView *sep1 = [[UIView alloc] init];
    sep1.translatesAutoresizingMaskIntoConstraints = NO;
    sep1.backgroundColor = [UIColor colorWithWhite:0.92 alpha:1];
    [contentView addSubview:sep1];

    UILabel *amtText = [[UILabel alloc] init];
    amtText.translatesAutoresizingMaskIntoConstraints = NO;
    amtText.font = FONTS_NOTO_BOLD(14);
    amtText.textColor = textMain;
    [contentView addSubview:amtText];
    if (amtTextOut) *amtTextOut = amtText;

    UILabel *amtVal = [[UILabel alloc] init];
    amtVal.translatesAutoresizingMaskIntoConstraints = NO;
    amtVal.font = FONTS_NOTO_BOLD(14);
    amtVal.textColor = textMain;
    amtVal.textAlignment = NSTextAlignmentRight;
    amtVal.text = @"$0.00";
    [contentView addSubview:amtVal];
    if (amtValOut) *amtValOut = amtVal;

    [NSLayoutConstraint activateConstraints:@[
        // contentView anchored below headerView, fills card width, bottom = card bottom
        [contentView.topAnchor constraintEqualToAnchor:headerView.bottomAnchor],
        [contentView.leadingAnchor constraintEqualToAnchor:card.leadingAnchor],
        [contentView.trailingAnchor constraintEqualToAnchor:card.trailingAnchor],
        [contentView.bottomAnchor constraintEqualToAnchor:card.bottomAnchor],

        // Separator top of content (no explicit height — set below at low priority)
        [sep0.topAnchor constraintEqualToAnchor:contentView.topAnchor],
        [sep0.leadingAnchor constraintEqualToAnchor:contentView.leadingAnchor constant:p],
        [sep0.trailingAnchor constraintEqualToAnchor:contentView.trailingAnchor constant:-p],

        // Stat rows — no explicit heights; use label intrinsic content size
        [ridesText.topAnchor constraintEqualToAnchor:sep0.bottomAnchor constant:10],
        [ridesText.leadingAnchor constraintEqualToAnchor:contentView.leadingAnchor constant:p],
        [ridesVal.centerYAnchor constraintEqualToAnchor:ridesText.centerYAnchor],
        [ridesVal.trailingAnchor constraintEqualToAnchor:contentView.trailingAnchor constant:-p],
        [accText.topAnchor constraintEqualToAnchor:ridesText.bottomAnchor constant:10],
        [accText.leadingAnchor constraintEqualToAnchor:contentView.leadingAnchor constant:p],
        [accVal.centerYAnchor constraintEqualToAnchor:accText.centerYAnchor],
        [accVal.trailingAnchor constraintEqualToAnchor:contentView.trailingAnchor constant:-p],
        [cancelText.topAnchor constraintEqualToAnchor:accText.bottomAnchor constant:10],
        [cancelText.leadingAnchor constraintEqualToAnchor:contentView.leadingAnchor constant:p],
        [cancelVal.centerYAnchor constraintEqualToAnchor:cancelText.centerYAnchor],
        [cancelVal.trailingAnchor constraintEqualToAnchor:contentView.trailingAnchor constant:-p],
        [completeText.topAnchor constraintEqualToAnchor:cancelText.bottomAnchor constant:10],
        [completeText.leadingAnchor constraintEqualToAnchor:contentView.leadingAnchor constant:p],
        [completeVal.centerYAnchor constraintEqualToAnchor:completeText.centerYAnchor],
        [completeVal.trailingAnchor constraintEqualToAnchor:contentView.trailingAnchor constant:-p],

        // Separator + amount row (no explicit sep height — set below at low priority)
        [sep1.topAnchor constraintEqualToAnchor:completeText.bottomAnchor constant:10],
        [sep1.leadingAnchor constraintEqualToAnchor:contentView.leadingAnchor constant:p],
        [sep1.trailingAnchor constraintEqualToAnchor:contentView.trailingAnchor constant:-p],
        [amtText.topAnchor constraintEqualToAnchor:sep1.bottomAnchor constant:12],
        [amtText.leadingAnchor constraintEqualToAnchor:contentView.leadingAnchor constant:p],
        [amtVal.centerYAnchor constraintEqualToAnchor:amtText.centerYAnchor],
        [amtVal.trailingAnchor constraintEqualToAnchor:contentView.trailingAnchor constant:-p],
        [amtVal.leadingAnchor constraintGreaterThanOrEqualToAnchor:amtText.trailingAnchor constant:8],
    ]];

    // Separator heights at low priority so the collapse constraint can override them
    NSLayoutConstraint *sep0H = [sep0.heightAnchor constraintEqualToConstant:1];
    sep0H.priority = UILayoutPriorityDefaultLow;
    sep0H.active = YES;
    NSLayoutConstraint *sep1H = [sep1.heightAnchor constraintEqualToConstant:1];
    sep1H.priority = UILayoutPriorityDefaultLow;
    sep1H.active = YES;

    // Expanded constraint — defines card bottom via amtText; inactive when collapsed
    NSLayoutConstraint *expandedHC = [amtText.bottomAnchor constraintEqualToAnchor:contentView.bottomAnchor constant:-14];
    expandedHC.priority = UILayoutPriorityRequired;
    expandedHC.active = NO;
    [_cardExpandedConstraints addObject:expandedHC];

    // Collapse constraint — forces contentView height to 0; active when collapsed
    // Required priority beats label intrinsic height resistance (750) so rows are fully hidden
    NSLayoutConstraint *collapseHC = [contentView.heightAnchor constraintEqualToConstant:0];
    collapseHC.priority = UILayoutPriorityRequired;
    collapseHC.active = YES; // start collapsed
    [_cardCollapseConstraints addObject:collapseHC];

    return card;
}

- (void)onCardHeaderTapped:(UITapGestureRecognizer *)tap {
    NSInteger idx = tap.view.tag;
    BOOL nowExpanded = ![[_cardExpanded objectAtIndex:idx] boolValue];
    [_cardExpanded replaceObjectAtIndex:idx withObject:@(nowExpanded)];

    UIImageView *chevron = [_cardChevrons objectAtIndex:idx];
    NSLayoutConstraint *collapseHC = [_cardCollapseConstraints objectAtIndex:idx];
    NSLayoutConstraint *expandedHC = [_cardExpandedConstraints objectAtIndex:idx];

    // Update arrow icon
    NSString *assetName = nowExpanded ? @"ic_arrow_up" : @"ic_arrow_down";
    UIImage *arrowImg = [UIImage imageNamed:assetName];
    if (!arrowImg) {
        if (@available(iOS 13, *)) {
            NSString *sfName = nowExpanded ? @"chevron.up" : @"chevron.down";
            UIImageSymbolConfiguration *cfg = [UIImageSymbolConfiguration configurationWithWeight:UIImageSymbolWeightLight];
            arrowImg = [[UIImage systemImageNamed:sfName withConfiguration:cfg]
                        imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        }
    }
    chevron.image = arrowImg;

    // Swap mutually exclusive constraints
    collapseHC.active = !nowExpanded;
    expandedHC.active = nowExpanded;

    [UIView animateWithDuration:0.28 delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
        [self.view layoutIfNeeded];
    } completion:nil];
}

- (UILabel *)makeStatTextLabel:(UIColor *)color {
    UILabel *lbl = [[UILabel alloc] init];
    lbl.translatesAutoresizingMaskIntoConstraints = NO;
    lbl.font = FONTS_NOTO_REGULAR(14);
    lbl.textColor = color;
    return lbl;
}

- (UILabel *)makeStatValueLabel:(UIColor *)color {
    UILabel *lbl = [[UILabel alloc] init];
    lbl.translatesAutoresizingMaskIntoConstraints = NO;
    lbl.font = FONTS_NOTO_REGULAR(14);
    lbl.textColor = color;
    lbl.textAlignment = NSTextAlignmentRight;
    lbl.text = @"0";
    return lbl;
}

@end
