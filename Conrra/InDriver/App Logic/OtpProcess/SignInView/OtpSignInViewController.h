//
//  SignInViewController.h
//  Store_project
//
//  Created by Appicial Taxi App Soutions on 22/05/17.
//  Copyright © 2023 Appicial Taxi App Soutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import "LanguageHelper.h"
#import "CounrySelectionView.h"
#import "BaseViewController.h"
@interface OtpSignInViewController : BaseViewController<UITextFieldDelegate,CounrySelectionViewDelegate>

@property (strong, nonatomic) IBOutlet UITextField *txtEmail;
@property (strong, nonatomic) IBOutlet UITextField *txtPassword;
@property (strong, nonatomic) IBOutlet UILabel *lblHeader;
@property (strong, nonatomic) IBOutlet UIButton *btnForgotPassword;
@property (weak, nonatomic) IBOutlet UIButton *btnLogin;
@property (weak, nonatomic) IBOutlet UIView *viewContainer;
@property (weak, nonatomic) IBOutlet UIButton *btLogin;
@property (weak, nonatomic) IBOutlet UILabel *lbCountryDialCode;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIImageView *imgViewLogo;
@property (weak, nonatomic) IBOutlet UIView *headerSepView;
@property (weak, nonatomic) IBOutlet UIView *loginRegView;
@property (weak, nonatomic) IBOutlet UIButton *btnRegister;
@property (weak, nonatomic) IBOutlet UIView *loginSepView;
@property (weak, nonatomic) IBOutlet UIView *loginSepBottomView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrolView;
@property (weak, nonatomic) IBOutlet UIView *otpFieldsView;
@property (weak, nonatomic) IBOutlet UIView *mobileView;
@property (weak, nonatomic) IBOutlet UILabel *lblMobileNumber;
@property (weak, nonatomic) IBOutlet UIView *mobileSepView;
@property (weak, nonatomic) IBOutlet UIView *passwordView;
@property (weak, nonatomic) IBOutlet UILabel *lblPassword;
@property (weak, nonatomic) IBOutlet UIView *passwordSepView;
@property (weak, nonatomic) IBOutlet UIButton *btnFacebook;
@property (weak, nonatomic) IBOutlet UIView *viewLanguage;
@property (weak, nonatomic) IBOutlet UILabel *lblLanguage;
@property (weak, nonatomic) IBOutlet UIImageView *languageIcon;
@property (weak, nonatomic) IBOutlet UIButton *btnLanguage;

- (IBAction)buttonLogin:(id)sender;

@property (nonatomic) BOOL isFromUpload;
@end
