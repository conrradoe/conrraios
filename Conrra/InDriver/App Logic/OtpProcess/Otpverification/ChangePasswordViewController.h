//
//  ChangePasswordViewController.h
//  HireMe Rider
//
//  Created by Grepix Infotech on 01/01/19.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import "LanguageHelper.h"
#import "BaseViewController.h"
NS_ASSUME_NONNULL_BEGIN

@interface ChangePasswordViewController : BaseViewController

@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (strong, nonatomic) IBOutlet UITextField *txtNewPassword;
@property (strong, nonatomic) IBOutlet UITextField *txtConfirmPassword;
@property (weak, nonatomic) IBOutlet UIView *nPassView;
@property (weak, nonatomic) IBOutlet UIView *cPassView;
@property (weak, nonatomic) IBOutlet UILabel *lbHeader;

@property (assign, nonatomic) BOOL isRestPassword;
@property (strong, nonatomic) NSDictionary * dictUserRestPassword;

- (IBAction)btnBack:(id)sender;
- (IBAction)savePassword:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *btnBack;
@property (weak, nonatomic) IBOutlet UIView *headerSepView;
@property (weak, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UIView *firstNameView;
@property (weak, nonatomic) IBOutlet UILabel *lblNewPassword;
@property (weak, nonatomic) IBOutlet UIView *firstNameSepView;
@property (weak, nonatomic) IBOutlet UILabel *lblConfirmPassword;

@property (weak, nonatomic) IBOutlet UIView *confirmPassSepView;

@property (weak, nonatomic) IBOutlet UIButton *btnSave;





@end

NS_ASSUME_NONNULL_END
