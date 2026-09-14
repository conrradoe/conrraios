//
//  SignUpViewController.h
//  Store_project
//
//  Created by Appicial Taxi App Soutions on 22/05/17.
//  Copyright © 2023 Appicial Taxi App Soutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IQPreviousNextView.h"
#import "NIDropDown.h"
#import <objc/runtime.h>
#import "LanguageHelper.h"
#import "CounrySelectionView.h"
#import "AboutUsViewController.h"
#import "BaseViewController.h"

@interface OtpSignUpViewController : BaseViewController<UITextFieldDelegate, UIScrollViewDelegate,CounrySelectionViewDelegate>
@property (strong, nonatomic) IBOutlet UITextField *txtFirstName;
@property (strong, nonatomic) IBOutlet UITextField *txtLastName;
@property (strong, nonatomic) IBOutlet UITextField *txtEmail;
@property (strong, nonatomic) IBOutlet UITextField *txtMobile;
@property (strong, nonatomic) IBOutlet UITextField *txtPassword;
@property (strong, nonatomic) IBOutlet UIButton *btnJoin;
@property (strong, nonatomic) IBOutlet UIView *viewHeader;
@property (strong, nonatomic) IBOutlet UILabel *blHeader;
@property (weak, nonatomic) IBOutlet UIScrollView *registerScrollView;
@property (weak, nonatomic) IBOutlet UIView *viewOnScroll;
@property (weak, nonatomic) IBOutlet IQPreviousNextView *viewContainer;
@property (weak, nonatomic) IBOutlet UIButton *btRegister;
@property (weak, nonatomic) IBOutlet UITextField *txtRePassword;
@property (weak, nonatomic) IBOutlet UITextField *txtCity;
@property (weak, nonatomic) IBOutlet UIButton *btCity;
@property (weak, nonatomic) IBOutlet UIView *viewContryContainer;
@property (weak, nonatomic) IBOutlet UIImageView *imgeCountry;
@property (weak, nonatomic) IBOutlet UILabel *lbCountryDialCode;
- (IBAction)backToLoginbtn:(id)sender;

@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIImageView *imgViewLogo;
@property (weak, nonatomic) IBOutlet UILabel *lblHeader;
@property (weak, nonatomic) IBOutlet UIView *headerSepView;
@property (weak, nonatomic) IBOutlet UIView *loginRegiView;
@property (weak, nonatomic) IBOutlet UIButton *btnLogin;
@property (weak, nonatomic) IBOutlet UIButton *btnRegister;
@property (weak, nonatomic) IBOutlet UIView *logRegiSepView;
@property (weak, nonatomic) IBOutlet UIView *logRegBottomSepView;
@property (weak, nonatomic) IBOutlet UIView *firstNameView;
@property (weak, nonatomic) IBOutlet UILabel *lblFirstName;
@property (weak, nonatomic) IBOutlet UIView *firstNameSepView;

@property (weak, nonatomic) IBOutlet UIView *lastNameView;
@property (weak, nonatomic) IBOutlet UILabel *lblLastName;

@property (weak, nonatomic) IBOutlet UIView *lastNameSepView;
@property (weak, nonatomic) IBOutlet UIView *mobileview;
@property (weak, nonatomic) IBOutlet UILabel *lblMobileNumber;
@property (weak, nonatomic) IBOutlet UIView *emailView;
@property (weak, nonatomic) IBOutlet UILabel *lblEmail;
@property (weak, nonatomic) IBOutlet UILabel *lblSep;
@property (weak, nonatomic) IBOutlet UIView *cityView;
@property (weak, nonatomic) IBOutlet UILabel *lblCity;
@property (weak, nonatomic) IBOutlet UIButton *citySepView;

@property (weak, nonatomic) IBOutlet UILabel *lblPassword;

@property (weak, nonatomic) IBOutlet UILabel *lblPassSepView;

@property (weak, nonatomic) IBOutlet UIView *passworgVeaw;
@property (weak, nonatomic) IBOutlet UIView *confirmPassWiew;
@property (weak, nonatomic) IBOutlet UILabel *lblConfirnPass;
@property (weak, nonatomic) IBOutlet UILabel *lblConfirmPassSep;
@property (weak, nonatomic) IBOutlet UILabel *lblBottomSep;
@property (weak, nonatomic) IBOutlet UIButton *btnFacebook;
@property (weak, nonatomic) IBOutlet UIView *countryView;
@property (weak, nonatomic) IBOutlet UIButton *btnDone;

@property (weak, nonatomic) IBOutlet UIView *viewReferral;
@property (weak, nonatomic) IBOutlet UILabel *lblReferral;

@property (weak, nonatomic) IBOutlet UITextField *txtReferral;

@property (weak, nonatomic) IBOutlet UIButton *btnTerms;

@property (strong, nonatomic) NSString * mobileNumber;

@property (weak, nonatomic) IBOutlet UIView *viewLanguage;
@property (weak, nonatomic) IBOutlet UILabel *lblLanguage;
@property (weak, nonatomic) IBOutlet UIImageView *languageIcon;
@property (weak, nonatomic) IBOutlet UIButton *btnLanguage;

@property (weak, nonatomic) IBOutlet UIView *viewTerms;
@property (weak, nonatomic) IBOutlet UITextView *txtTerms;

@end
