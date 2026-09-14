//
//  ForgotPasswordViewController.h
//  Store_project
//
//  Created by  Appicial on 22/05/17.
//  Copyright © 2023 Appicial. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LanguageHelper.h"
#import "BaseViewController.h"

@interface ForgotPasswordViewController : BaseViewController<UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UITextField *txtEmail;
@property (strong, nonatomic) IBOutlet UIButton *btnResetPassword;
@property (strong, nonatomic) IBOutlet UIView *viewHeader;
@property (strong, nonatomic) IBOutlet UILabel *lblHeader;
@property (strong, nonatomic) IBOutlet UILabel  *lblRestore;
@property (weak, nonatomic) IBOutlet UIButton *btReset;
@property (weak, nonatomic) IBOutlet UILabel *lbEmailTitle;


@property (weak, nonatomic) IBOutlet UIView *viewContryContainer;
@property (weak, nonatomic) IBOutlet UIImageView *imgeCountry;
@property (weak, nonatomic) IBOutlet UIButton *btCountry;
@property (weak, nonatomic) IBOutlet UILabel *lbCountryDialCode;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *consLeading;

@property (weak, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UIView *emailSepView;
@property (weak, nonatomic) IBOutlet UIView *headerSepView;
@property (weak, nonatomic) IBOutlet UIButton *btnBack;

@property (weak, nonatomic) IBOutlet UIView *countryView;
@property (weak, nonatomic) IBOutlet UIButton *btnDone;




@end
