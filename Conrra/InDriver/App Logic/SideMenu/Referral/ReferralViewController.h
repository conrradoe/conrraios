//
//  LanguageViewController.h
//  JS Rider
//
//  Created by Devineer on 25/06/18.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LanguageHelper.h"
#import "AboutUsViewController.h"

@interface ReferralViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UILabel *lblHeaderTitle;
@property (weak, nonatomic) IBOutlet UIImageView *imgMain;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIButton *btnBack;
@property (weak, nonatomic) IBOutlet UIView *headerSepView;
@property (weak, nonatomic) IBOutlet UIView *viewEranigs;
@property (weak, nonatomic) IBOutlet UIButton *btnEraning;
@property (weak, nonatomic) IBOutlet UIButton *btnReferal;
@property (weak, nonatomic) IBOutlet UIView *viewReferalCode;
@property (weak, nonatomic) IBOutlet UILabel *lblReferralCode;
@property (weak, nonatomic) IBOutlet UIView *viewReferalList;
@property (weak, nonatomic) IBOutlet UILabel *lblReferals;
@property (weak, nonatomic) IBOutlet UIButton *btnCopyCode;
@property (weak, nonatomic) IBOutlet UIButton *btnInvite;
@property (weak, nonatomic) IBOutlet UILabel *lblEraningMessage;

@end
