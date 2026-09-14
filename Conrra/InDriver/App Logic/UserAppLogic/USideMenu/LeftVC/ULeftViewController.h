//
//  LeftViewController.h
//  TempProject
//
//  Created by Appicial Taxi App Soutions on 09/02/17.
//  Copyright © 2023 Appicial Taxi App Soutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+LGSideMenuController.h"
#import "MainViewController.h"
#import "LanguageHelper.h"
#import "BaseViewController.h"

@interface ULeftViewController : BaseViewController<UITableViewDelegate,UITableViewDataSource,LGSideMenuDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *arrSideMenu;
@property (strong, nonatomic) IBOutlet UILabel *lblName;
@property (strong, nonatomic) IBOutlet UIImageView *imgProfile;
@property (weak, nonatomic) IBOutlet UILabel *userMobileLbl;

@property (strong, nonatomic) IBOutlet UISwitch *switchAvailability;
@property (strong, nonatomic) IBOutlet UIButton *btnAvailability;

@property (strong, nonatomic) IBOutlet UIView *viewBackground;
@property (strong, nonatomic) IBOutlet UIView *viewSeparator;
@property (weak, nonatomic) IBOutlet UIButton *btAboutUs;

@property (weak, nonatomic) IBOutlet UIButton *btPrivacyPolicy;

@property (weak, nonatomic) IBOutlet UIButton *btnLogout;

@property (weak, nonatomic) IBOutlet UIButton *btnSetting;
@property (weak, nonatomic) IBOutlet UILabel *lblCasDriverText;

@property (weak, nonatomic) IBOutlet UIButton *btnSwitchDriver;
@property (weak, nonatomic) IBOutlet UIImageView *imageProfileIcon;


@end
