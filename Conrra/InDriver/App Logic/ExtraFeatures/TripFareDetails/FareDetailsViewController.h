//
//  LanguageViewController.h
//  JS Rider
//
//  Created by Devineer on 25/06/18.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LanguageHelper.h"
#import "BaseViewController.h"
#import "TripModel.h"
#import "AboutUsViewController.h"

@interface FareDetailsViewController : BaseViewController<UITableViewDataSource,UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UILabel *lblHeaderTitle;
@property (weak, nonatomic) IBOutlet UIImageView *imgMain;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIButton *btnBack;
@property (weak, nonatomic) IBOutlet UIView *headerSepView;
@property(strong,nonatomic)TripModel * trip;
@property (weak, nonatomic) IBOutlet UILabel *lblTotalFare;
@property (weak, nonatomic) IBOutlet UILabel *lblCurrency;
@property (weak, nonatomic) IBOutlet UILabel *lblFarePolicy;

@end
