//
//  LeftViewController.h
//  TempProject
//
//  Created by Appicial Taxi App Solutions on 09/02/17.
//  Copyright © 2023 Appicial Taxi App Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+LGSideMenuController.h"
#import "MainViewController.h"
#import "LanguageHelper.h"
#import "BaseViewController.h"


@interface LeftViewController : BaseViewController<UITableViewDelegate,UITableViewDataSource,LGSideMenuDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *arrSideMenu;
@property (strong, nonatomic) IBOutlet UILabel *lblName;
@property (strong, nonatomic) IBOutlet UIImageView *imgProfile;

@property (weak, nonatomic) IBOutlet UIButton *btnSwitchDriver;
@property (strong, nonatomic) IBOutlet UISwitch *switchAvailability;
@property (strong, nonatomic) IBOutlet UIButton *btnAvailability;
@property (strong, nonatomic) IBOutlet UIView *viewBackground;
@property (strong, nonatomic) IBOutlet UIView *viewSeparator;
@property (weak, nonatomic) IBOutlet UILabel *userMobile;
@property (weak, nonatomic) IBOutlet UIButton *btAboutUs;
@property (weak, nonatomic) IBOutlet UIButton *btPrivacyPolicy;
@property (weak, nonatomic) IBOutlet UIImageView *imgViewCover;
@property (weak, nonatomic) IBOutlet UIButton *btnSetting;
@property (weak, nonatomic) IBOutlet UIView *nameSepView;

@property (weak, nonatomic) IBOutlet UILabel *lblCasDriver;
@property (weak, nonatomic) IBOutlet UIButton *btnLogout;

@property (weak, nonatomic) IBOutlet UIImageView *imageProfileIcon;






@end
