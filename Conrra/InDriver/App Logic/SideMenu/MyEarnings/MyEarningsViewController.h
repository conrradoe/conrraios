//
//  MyEarnings.h

//
//  Created by Grepix Infotech on 01/01/20.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ConstantModel.h"
#import "LanguageHelper.h"
#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface MyEarningsViewController : BaseViewController
@property (weak, nonatomic) IBOutlet UILabel *lblHraderTitle;

@property (weak, nonatomic) IBOutlet UILabel *lblDate;
@property (weak, nonatomic) IBOutlet UILabel *lblTodayText;
@property (weak, nonatomic) IBOutlet UILabel *lblTodayCountValue;
@property (weak, nonatomic) IBOutlet UILabel *lblTodayRidesText;
@property (weak, nonatomic) IBOutlet UILabel *lblTodayRidesValue;
@property (weak, nonatomic) IBOutlet UILabel *lblTodayAmountText;
@property (weak, nonatomic) IBOutlet UILabel *lblTodayAmountValue;
@property (weak, nonatomic) IBOutlet UILabel *lblTodayAccepetedText;
@property (weak, nonatomic) IBOutlet UILabel *lblTodayAccepetedValue;
@property (weak, nonatomic) IBOutlet UILabel *lblTodayCancelledText;
@property (weak, nonatomic) IBOutlet UILabel *lblTodayCancelledValue;
@property (weak, nonatomic) IBOutlet UILabel *lblTodayCompletedText;
@property (weak, nonatomic) IBOutlet UILabel *lblTodayCompletedValue;

 
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIButton *btnBack;
@property (weak, nonatomic) IBOutlet UIView *headerSeperatorView;
@property (weak, nonatomic) IBOutlet UIView *dailyEarnSepView;
@property (weak, nonatomic) IBOutlet UIView *monthlyEarnSepView;


@property (weak, nonatomic) IBOutlet UILabel *lblWeekText;
@property (weak, nonatomic) IBOutlet UILabel *lblWeekRidesText;
@property (weak, nonatomic) IBOutlet UILabel *lblWeekRidesValue;
@property (weak, nonatomic) IBOutlet UILabel *lblWeekAmountText;
@property (weak, nonatomic) IBOutlet UILabel *lblWeekAmountValue;
@property (weak, nonatomic) IBOutlet UILabel *lblWeekAccepetedText;
@property (weak, nonatomic) IBOutlet UILabel *lblWeekAccepetedValue;
@property (weak, nonatomic) IBOutlet UILabel *lblWeekCancelledText;
@property (weak, nonatomic) IBOutlet UILabel *lblWeekCancelledValue;
@property (weak, nonatomic) IBOutlet UILabel *lblWeekCompletedText;
@property (weak, nonatomic) IBOutlet UILabel *lblWeekCompletedValue;



@property (weak, nonatomic) IBOutlet UILabel *lblMonthText;
@property (weak, nonatomic) IBOutlet UILabel *lblMonthRidesText;
@property (weak, nonatomic) IBOutlet UILabel *lblMonthRidesValue;
@property (weak, nonatomic) IBOutlet UILabel *lblMonthAmountText;
@property (weak, nonatomic) IBOutlet UILabel *lblMonthAmountValue;
@property (weak, nonatomic) IBOutlet UILabel *lblMonthAcceptedText;
@property (weak, nonatomic) IBOutlet UILabel *lblMonthAcceptedValue;
@property (weak, nonatomic) IBOutlet UILabel *lblMonthCancelledText;
@property (weak, nonatomic) IBOutlet UILabel *lblMonthCancelledValue;
@property (weak, nonatomic) IBOutlet UILabel *lblMonthCompletedText;
@property (weak, nonatomic) IBOutlet UILabel *lblMonthCompletedValue;

@property (weak, nonatomic) IBOutlet UILabel *lblWeekDate;
@property (weak, nonatomic) IBOutlet UILabel *lblMonth;

@end

NS_ASSUME_NONNULL_END
