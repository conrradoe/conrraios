//
//  ShowWalletBalanceAndTranVC.h

//
//  Created by Grepix Infotech on 26/11/18.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface PayoutViewController : BaseViewController

@property (weak, nonatomic) IBOutlet UITableView *walletTableView;

@property (weak, nonatomic) IBOutlet UILabel *walletAmountLbl;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIButton *btnBack;
@property (weak, nonatomic) IBOutlet UILabel *lblHeader;
@property (weak, nonatomic) IBOutlet UIView *headerSepView;

@property (weak, nonatomic) IBOutlet UIView *currentBalanceView;
@property (weak, nonatomic) IBOutlet UILabel *lblCurrentBalanace;
@property (weak, nonatomic) IBOutlet UILabel *currentBalSep;
@property (weak, nonatomic) IBOutlet UILabel *lblRecents;
@property (weak, nonatomic) IBOutlet UILabel *lblPayoutAmountText;

@property (weak, nonatomic) IBOutlet UIButton *btnPayoutAmt;
@property (weak, nonatomic) IBOutlet UITextField *txtPayoutAmt;

@property (weak, nonatomic) IBOutlet UIView *viewLastRequest;
@property (weak, nonatomic) IBOutlet UILabel *lblLastRequestTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblReqAmtText;
@property (weak, nonatomic) IBOutlet UILabel *lblReqAmtValue;
@property (weak, nonatomic) IBOutlet UILabel *lblReqStatusText;
@property (weak, nonatomic) IBOutlet UILabel *lblReqStatusValue;
@property (weak, nonatomic) IBOutlet UILabel *lblDateText;
@property (weak, nonatomic) IBOutlet UILabel *lblDateValue;


@end
