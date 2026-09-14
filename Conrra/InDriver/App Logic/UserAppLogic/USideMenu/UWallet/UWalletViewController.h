//
//  UWalletViewController.h
//  HireMe Rider
//
//  Created by Grepix Infotech on 26/11/18.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ConstantModel.h"
#import "LanguageHelper.h"
#import "UTripDetailsViewController.h"
#import "UAddMoneyWalletVC.h"
#import "TripDetailsViewController.h"


@interface UWalletViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,UTripDetailsViewControllerDelegate,UAddMoneyWalletVCDelegate>
- (IBAction)back:(id)sender;
@property (weak, nonatomic) IBOutlet UITableView *walletTableView;
- (IBAction)pushToAddMoneyVC:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *walletAmountLbl; 

@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIButton *btnBack;
@property (weak, nonatomic) IBOutlet UILabel *lblHeader;
@property (weak, nonatomic) IBOutlet UIView *viewCorrentBalance;
@property (weak, nonatomic) IBOutlet UILabel *lblCurrentBalance;

@property (weak, nonatomic) IBOutlet UIButton *addMoneyWalet;

@property (weak, nonatomic) IBOutlet UILabel *lblRecent;
@property (weak, nonatomic)  NSString *addAmount;



@property(weak,nonatomic) UTripDetailsViewController *tripDetailsViewController;



@end
