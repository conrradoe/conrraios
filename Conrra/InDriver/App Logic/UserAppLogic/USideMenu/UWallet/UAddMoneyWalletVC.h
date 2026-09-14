//
//  AddMoneyWalletVC.h
//  HireMe Rider
//
//  Created by Grepix Infotech on 27/11/18.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LanguageHelper.h"
#import "BaseViewController.h"
@protocol UAddMoneyWalletVCDelegate <NSObject>

-(void)monyAddSucessfully;

@end
@interface UAddMoneyWalletVC : BaseViewController
@property (strong, nonatomic) NSString *addAmount;
@property (weak, nonatomic) id<UAddMoneyWalletVCDelegate> delegate;
- (IBAction)back:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *enterAmountTextField;
- (IBAction)addMoneyClicked:(id)sender;
@property (strong, nonatomic) IBOutlet UITextView *addAmountDesc;

@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIButton *btnBack;
@property (weak, nonatomic) IBOutlet UILabel *lblHeader;
@property (weak, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UIView *viewAmount;

@property (weak, nonatomic) IBOutlet UIView *viewDesc;
@property (weak, nonatomic) IBOutlet UIButton *btnAddMoney;




@end
