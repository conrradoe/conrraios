//
//  SignInViewController.m
//  Store_project
//
//  Created by  Appicial on 22/05/17.
//  Copyright © 2023 Appicial. All rights reserved.
//

#import "OtpSignInViewController.h"
#import <GIKit/GIKit.h>
#import "WebCallConstants.h"
#import "AppDelegate.h"
#import "MainViewController.h"
#import "HomeViewController.h"
#import "Utilities.h"
#import "NIDropDown.h"
#import "UIHelper.h"
#import "ConstantModel.h"
#import "OTPVerifyViewController.h"
#import "OtpSignUpViewController.h"
#import "ConrraButton.h"

@interface OtpSignInViewController ()<NIDropDownDelegate>

@property (weak, nonatomic) IBOutlet UIButton *btCity;
@property (nonatomic, strong) UIView *loginCardView;
@property (nonatomic, strong) NSLayoutConstraint *scrollViewTopConstraint;
@property (nonatomic, strong) UILabel *loginTitleLabel;
@property (nonatomic, strong) UILabel *loginParagraphLabel;
@property (nonatomic, strong) UILabel *noAccountLabel;
@property (nonatomic, strong) UIButton *registerButtonBottom;
@property (nonatomic, strong) UIView *phoneInputWrapper;
@property (nonatomic, strong) UIView *countryBoxView;
@property (nonatomic, strong) UILabel *logoLabel;
@property (nonatomic, strong) NSLayoutConstraint *logoCenterYConstraint;

@end

@implementation OtpSignInViewController
{
    NSString * countryCodeSelected;
    NIDropDown *dropDown;
    NSDictionary * countrySelected;
    ConstantModel *  constantTaxiModel;
    int smsCode;
     NSDictionary * dictUserForLogin;
    UIButton *dropDownBtnSelected;
    UITapGestureRecognizer *tapRecognizer;
    UIView *gestureBg;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    constantTaxiModel =[ConstantModel getConstantsObject];;
    [self setUIFields];
    self.txtEmail.delegate=self;
    self.txtPassword.delegate=self;
    [self setupTextField:_txtEmail];
    [self setupTextField:_txtPassword];
    
    [self.viewContainer.layer setCornerRadius:5];
    [self.viewContainer setClipsToBounds:YES];
    [self.btLogin.layer setCornerRadius:5];
    [self.btLogin setClipsToBounds:YES];
    [self setThemeConstants];
    self.lbCountryDialCode.attributedText=[CounrySelectionView getCurrentCountry];
    int width = [self.lbCountryDialCode.attributedText size].width+20;
    [self.lbCountryDialCode setConstraintConstant:width forAttribute:NSLayoutAttributeWidth];
    countrySelected=[CounrySelectionView getCurrentCountryDict];
    
    [self setupLoginScreenLayout];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGFloat h = CGRectGetHeight(self.view.bounds);
    if (self.logoCenterYConstraint) {
        self.logoCenterYConstraint.constant = h * 0.2f;
    }
}

- (void)setupLoginScreenLayout {
    self.headerView.hidden   = YES;
    self.loginRegView.hidden = YES;
    self.scrolView.hidden    = YES;

    self.view.backgroundColor = [UIColor blackColor];

    UIImage *bgImage = [UIImage imageNamed:@"login_bg"];
    if (bgImage) {
        UIImageView *bgImageView = [[UIImageView alloc] initWithImage:bgImage];
        bgImageView.translatesAutoresizingMaskIntoConstraints = NO;
        bgImageView.contentMode = UIViewContentModeScaleAspectFill;
        bgImageView.clipsToBounds = YES;
        [self.view insertSubview:bgImageView atIndex:0];
        [NSLayoutConstraint activateConstraints:@[
            [bgImageView.topAnchor      constraintEqualToAnchor:self.view.topAnchor],
            [bgImageView.leadingAnchor  constraintEqualToAnchor:self.view.leadingAnchor],
            [bgImageView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
            [bgImageView.bottomAnchor   constraintEqualToAnchor:self.view.bottomAnchor],
        ]];
        UIView *overlay = [[UIView alloc] init];
        overlay.translatesAutoresizingMaskIntoConstraints = NO;
        overlay.backgroundColor = [UIColor colorWithWhite:0 alpha:0.40f];
        [self.view insertSubview:overlay atIndex:1];
        [NSLayoutConstraint activateConstraints:@[
            [overlay.topAnchor      constraintEqualToAnchor:self.view.topAnchor],
            [overlay.leadingAnchor  constraintEqualToAnchor:self.view.leadingAnchor],
            [overlay.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
            [overlay.bottomAnchor   constraintEqualToAnchor:self.view.bottomAnchor],
        ]];
    } else {
        UIView *bgView = [[UIView alloc] init];
        bgView.translatesAutoresizingMaskIntoConstraints = NO;
        bgView.backgroundColor = [UIColor colorWithWhite:0.12f alpha:1];
        [self.view insertSubview:bgView atIndex:0];
        [NSLayoutConstraint activateConstraints:@[
            [bgView.topAnchor      constraintEqualToAnchor:self.view.topAnchor],
            [bgView.leadingAnchor  constraintEqualToAnchor:self.view.leadingAnchor],
            [bgView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
            [bgView.bottomAnchor   constraintEqualToAnchor:self.view.bottomAnchor],
        ]];
        UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
        blurView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view insertSubview:blurView atIndex:1];
        [NSLayoutConstraint activateConstraints:@[
            [blurView.topAnchor      constraintEqualToAnchor:self.view.topAnchor],
            [blurView.leadingAnchor  constraintEqualToAnchor:self.view.leadingAnchor],
            [blurView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
            [blurView.bottomAnchor   constraintEqualToAnchor:self.view.bottomAnchor],
        ]];
    }

    UIImage *logoImage = [UIImage imageNamed:@"app_logo"];
    if (logoImage) {
        UIImageView *logoImageView = [[UIImageView alloc] initWithImage:logoImage];
        logoImageView.translatesAutoresizingMaskIntoConstraints = NO;
        logoImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.view insertSubview:logoImageView atIndex:2];
        self.logoCenterYConstraint = [logoImageView.centerYAnchor constraintEqualToAnchor:self.view.topAnchor
                                                                                 constant:CGRectGetHeight(self.view.bounds) * 0.2f];
        [NSLayoutConstraint activateConstraints:@[
            [logoImageView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
            self.logoCenterYConstraint,
            [logoImageView.widthAnchor   constraintEqualToConstant:160],
            [logoImageView.heightAnchor  constraintEqualToConstant:60],
        ]];
    } else {
        self.logoLabel = [[UILabel alloc] init];
        self.logoLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.logoLabel.text = [UIHelper appNameForDisplay];
        self.logoLabel.font = [UIFont boldSystemFontOfSize:28];
        self.logoLabel.textColor = [UIColor whiteColor];
        self.logoLabel.textAlignment = NSTextAlignmentCenter;
        [self.view insertSubview:self.logoLabel atIndex:2];
        self.logoCenterYConstraint = [self.logoLabel.centerYAnchor constraintEqualToAnchor:self.view.topAnchor
                                                                                  constant:CGRectGetHeight(self.view.bounds) * 0.2f];
        [NSLayoutConstraint activateConstraints:@[
            [self.logoLabel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
            self.logoCenterYConstraint,
        ]];
    }

    self.loginCardView = [[UIView alloc] init];
    self.loginCardView.translatesAutoresizingMaskIntoConstraints = NO;
    self.loginCardView.backgroundColor = [UIColor whiteColor];
    self.loginCardView.layer.cornerRadius = 24;
    self.loginCardView.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
    self.loginCardView.clipsToBounds = YES;
    [self.view insertSubview:self.loginCardView atIndex:3];
    [NSLayoutConstraint activateConstraints:@[
        [self.loginCardView.leadingAnchor  constraintEqualToAnchor:self.view.leadingAnchor],
        [self.loginCardView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.loginCardView.bottomAnchor   constraintEqualToAnchor:self.view.bottomAnchor],
        [self.loginCardView.heightAnchor   constraintEqualToAnchor:self.view.heightAnchor multiplier:0.55f],
    ]];

    self.loginTitleLabel = [[UILabel alloc] init];
    self.loginTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.loginTitleLabel.text = [LanguageHelper loginScreenTitle];
    self.loginTitleLabel.font = FONTS_NOTO_BOLD(20);
    if (!self.loginTitleLabel.font) self.loginTitleLabel.font = [UIFont boldSystemFontOfSize:20];
    self.loginTitleLabel.textColor = [UIColor colorWithWhite:0.15f alpha:1];

    self.loginParagraphLabel = [[UILabel alloc] init];
    self.loginParagraphLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.loginParagraphLabel.text = [Utilities stringByStrippingHTML:[LanguageHelper getStringWithKey:@"k_login_phone_subtitle"
                                                        defaultValue:@"Ingresa tu número de teléfono para continuar"]];
    self.loginParagraphLabel.font = FONTS_NOTO_REGULAR(16);
    if (!self.loginParagraphLabel.font) self.loginParagraphLabel.font = [UIFont systemFontOfSize:16];
    self.loginParagraphLabel.textColor = [UIColor colorWithRed:0x72/255.0f green:0x72/255.0f blue:0x72/255.0f alpha:1.0f];
    self.loginParagraphLabel.numberOfLines = 0;

    self.lblMobileNumber.hidden = YES;

    // UIStackView with negative spacing to compensate font dead space,
    // achieving exactly 8pt visual glyph gap between title and subtitle.
    UIFont *titleFont = self.loginTitleLabel.font ?: [UIFont boldSystemFontOfSize:20];
    UIFont *paraFont  = self.loginParagraphLabel.font ?: [UIFont systemFontOfSize:16];
    CGFloat stackSpacing = 8.0 - fabs(titleFont.descender) - (paraFont.ascender - paraFont.capHeight);

    UIStackView *headerStack = [[UIStackView alloc] init];
    headerStack.axis      = UILayoutConstraintAxisVertical;
    headerStack.alignment = UIStackViewAlignmentFill;
    headerStack.spacing   = stackSpacing;
    headerStack.translatesAutoresizingMaskIntoConstraints = NO;
    [headerStack addArrangedSubview:self.loginTitleLabel];
    [headerStack addArrangedSubview:self.loginParagraphLabel];
    // Add directly to loginCardView — no scroll view involvement
    [self.loginCardView addSubview:headerStack];
    [NSLayoutConstraint activateConstraints:@[
        [headerStack.topAnchor      constraintEqualToAnchor:self.loginCardView.topAnchor      constant:24],
        [headerStack.leadingAnchor  constraintEqualToAnchor:self.loginCardView.leadingAnchor  constant:24],
        [headerStack.trailingAnchor constraintEqualToAnchor:self.loginCardView.trailingAnchor constant:-24],
    ]];

    // Style mobileView while still attached (internal constraints survive the move)
    self.mobileView.backgroundColor = [UIColor colorWithRed:243/255.0f green:243/255.0f blue:243/255.0f alpha:1.0f];
    self.mobileView.layer.cornerRadius = 14;
    self.mobileView.layer.borderWidth = 0;
    self.mobileView.clipsToBounds = NO;
    [self.mobileView setConstraintConstant:56 forAttribute:NSLayoutAttributeHeight];

    for (UIView *subview in self.mobileView.subviews) {
        for (NSLayoutConstraint *c in subview.constraints) {
            if (c.firstAttribute == NSLayoutAttributeHeight && c.constant <= 1.0f) {
                subview.hidden = YES;
                break;
            }
        }
    }

    // Deactivate storyboard leading on lbCountryDialCode (will re-anchor to box)
    for (NSLayoutConstraint *c in self.mobileView.constraints) {
        if ((c.firstItem == self.lbCountryDialCode && c.firstAttribute == NSLayoutAttributeLeading) ||
            (c.secondItem == self.lbCountryDialCode && c.secondAttribute == NSLayoutAttributeLeading)) {
            c.active = NO;
            break;
        }
    }

    // Center txtEmail vertically (replace any bottom-anchored storyboard constraint)
    for (NSLayoutConstraint *c in self.mobileView.constraints) {
        if (c.firstAttribute == NSLayoutAttributeBottom &&
            c.secondItem == self.txtEmail && c.secondAttribute == NSLayoutAttributeBottom) {
            c.active = NO;
            break;
        }
    }
    [self.txtEmail.centerYAnchor constraintEqualToAnchor:self.mobileView.centerYAnchor].active = YES;

    // White country-code box with subtle shadow
    UIView *countryCodeBox = [[UIView alloc] init];
    countryCodeBox.translatesAutoresizingMaskIntoConstraints = NO;
    countryCodeBox.backgroundColor = [UIColor whiteColor];
    countryCodeBox.layer.cornerRadius = 10;
    countryCodeBox.layer.shadowColor   = [UIColor blackColor].CGColor;
    countryCodeBox.layer.shadowOffset  = CGSizeMake(0, 0);
    countryCodeBox.layer.shadowRadius  = 4;
    countryCodeBox.layer.shadowOpacity = 0.10f;
    [self.mobileView insertSubview:countryCodeBox atIndex:0];
    [NSLayoutConstraint activateConstraints:@[
        [countryCodeBox.leadingAnchor  constraintEqualToAnchor:self.mobileView.leadingAnchor constant:4],
        [countryCodeBox.topAnchor      constraintEqualToAnchor:self.mobileView.topAnchor constant:4],
        [countryCodeBox.bottomAnchor   constraintEqualToAnchor:self.mobileView.bottomAnchor constant:-4],
        [countryCodeBox.trailingAnchor constraintEqualToAnchor:self.lbCountryDialCode.trailingAnchor constant:8],
    ]];
    [self.lbCountryDialCode.leadingAnchor constraintEqualToAnchor:countryCodeBox.leadingAnchor constant:8].active = YES;

    // Phone field leads from the country code box
    for (NSLayoutConstraint *c in self.mobileView.constraints) {
        if (c.firstItem == self.txtEmail && c.firstAttribute == NSLayoutAttributeLeading &&
            c.secondItem == self.lbCountryDialCode && c.secondAttribute == NSLayoutAttributeTrailing) {
            c.active = NO;
            break;
        }
    }
    [self.txtEmail.leadingAnchor constraintEqualToAnchor:countryCodeBox.trailingAnchor constant:10].active = YES;
    self.txtEmail.textColor = [UIColor colorWithRed:40/255.0f green:40/255.0f blue:40/255.0f alpha:1.0f];

    // Move mobileView out of the storyboard hierarchy into loginCardView
    [self.mobileView removeFromSuperview];
    self.mobileView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.loginCardView addSubview:self.mobileView];
    [NSLayoutConstraint activateConstraints:@[
        [self.mobileView.topAnchor      constraintEqualToAnchor:self.loginParagraphLabel.bottomAnchor constant:48],
        [self.mobileView.leadingAnchor  constraintEqualToAnchor:self.loginCardView.leadingAnchor      constant:20],
        [self.mobileView.trailingAnchor constraintEqualToAnchor:self.loginCardView.trailingAnchor     constant:-20],
    ]];

    [self.btLogin removeFromSuperview];
    self.btLogin.translatesAutoresizingMaskIntoConstraints = NO;
    [self.loginCardView addSubview:self.btLogin];
    [ConrraButton applyStyle:ConrraButtonStylePrimary toButton:self.btLogin];
    for (NSLayoutConstraint *c in [self.btLogin.constraints copy]) {
        if (c.firstAttribute == NSLayoutAttributeHeight) { c.active = NO; }
    }
    [NSLayoutConstraint activateConstraints:@[
        [self.btLogin.topAnchor      constraintEqualToAnchor:self.mobileView.bottomAnchor      constant:16],
        [self.btLogin.leadingAnchor  constraintEqualToAnchor:self.loginCardView.leadingAnchor  constant:20],
        [self.btLogin.trailingAnchor constraintEqualToAnchor:self.loginCardView.trailingAnchor constant:-20],
        [self.btLogin.heightAnchor   constraintEqualToConstant:56],
    ]];

    self.noAccountLabel = [[UILabel alloc] init];
    self.noAccountLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.noAccountLabel.text = [LanguageHelper getStringWithKey:@"k_login_no_account" defaultValue:@"¿Aún no tienes una cuenta?"];
    self.noAccountLabel.font = FONTS_NOTO_REGULAR(15);
    if (!self.noAccountLabel.font) self.noAccountLabel.font = [UIFont systemFontOfSize:15];
    self.noAccountLabel.textColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
    [self.loginCardView addSubview:self.noAccountLabel];

    self.registerButtonBottom = [ConrraButton buttonWithStyle:ConrraButtonStyleDark];
    self.registerButtonBottom.translatesAutoresizingMaskIntoConstraints = NO;
    [self.registerButtonBottom setTitle:[LanguageHelper getStringWithKey:@"k_16_s2_register" defaultValue:@"Regístrate"] forState:UIControlStateNormal];
    [self.registerButtonBottom addTarget:self action:@selector(ButtonSignUpPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.loginCardView addSubview:self.registerButtonBottom];

    [NSLayoutConstraint activateConstraints:@[
        [self.registerButtonBottom.leadingAnchor  constraintEqualToAnchor:self.loginCardView.leadingAnchor  constant:20],
        [self.registerButtonBottom.trailingAnchor constraintEqualToAnchor:self.loginCardView.trailingAnchor constant:-20],
        [self.registerButtonBottom.heightAnchor   constraintEqualToConstant:52],
        [self.registerButtonBottom.bottomAnchor   constraintEqualToAnchor:self.loginCardView.bottomAnchor   constant:-20],
        [self.noAccountLabel.centerXAnchor constraintEqualToAnchor:self.loginCardView.centerXAnchor],
        [self.noAccountLabel.bottomAnchor  constraintEqualToAnchor:self.registerButtonBottom.topAnchor constant:-16],
    ]];
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [UtilityClass setLH:YES wt:@""];
    [UtilityClass SetAllLoadersHidden];
    [self checkAndShowAlertWith];
}


-(void)setUIFields{
    [self updateLanguageName];
    self.lblHeader.text = [UIHelper appNameForDisplay];
    self.lblMobileNumber.text = [LanguageHelper getStringWithKey:@"k_2_s1_mobile_number_hint"];
    self.lblPassword.text = [LanguageHelper getStringWithKey:@"k_11_s2_password"];
    [self.btnLogin setTitle:[LanguageHelper loginScreenTitle] forState:UIControlStateNormal];
    [self.btnRegister setTitle: [LanguageHelper getStringWithKey:@"k_16_s2_register"]   forState:UIControlStateNormal];
    [self.btLogin setTitle:[LanguageHelper loginScreenTitle] forState:UIControlStateNormal];
   
    [self.btnFacebook setTitle: [LanguageHelper getStringWithKey:@"k_16_s1_facebook"]   forState:UIControlStateNormal];
    self.txtEmail.placeholder    = [LanguageHelper getStringWithKey:@"k_2_s1_mobile_number_hint"];
    self.txtPassword.placeholder = [LanguageHelper getStringWithKey:@"k_4_s1_enter_password_hint"];
    
    if (self.loginTitleLabel) self.loginTitleLabel.text = [LanguageHelper loginScreenTitle];
    if (self.loginParagraphLabel) self.loginParagraphLabel.text = [Utilities stringByStrippingHTML:[LanguageHelper getStringWithKey:@"k_login_phone_subtitle" defaultValue:@"Ingresa tu número de teléfono para continuar"]];
    if (self.noAccountLabel) self.noAccountLabel.text = [LanguageHelper getStringWithKey:@"k_login_no_account" defaultValue:@"¿Aún no tienes una cuenta?"];
    if (self.registerButtonBottom) [self.registerButtonBottom setTitle:[LanguageHelper getStringWithKey:@"k_16_s2_register" defaultValue:@"Regístrate"] forState:UIControlStateNormal];
    if (self.logoLabel) self.logoLabel.text = [UIHelper appNameForDisplay];
}



 

-(void)setThemeConstants{
   
    [_btnForgotPassword.titleLabel setFont:FONTS_THEME_REGULAR(14)];
}
-(void)setupTextField:(UITextField*)textField{
    [self setTextFieldPlaceholderColor:textField];
}

- (IBAction)ButtonSignUpPressed:(id)sender {
    [self performSegueWithIdentifier:@"OtpSignUpViewController" sender:nil];
}
- (IBAction)ButtonForgotPasswordPressed:(id)sender {
    
    [self performSegueWithIdentifier:@"forgotPasswordViewController" sender:nil];
}

- (IBAction)ButtonBackAction:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    if (textField == self.txtEmail){
        [self.txtPassword becomeFirstResponder];
        
    }
    else if (textField == self.txtPassword){
        
        [self.txtPassword resignFirstResponder];
        
    }
    
    return YES;
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField ==self.txtEmail && textField.text.length >= constantTaxiModel.max_phone_length && range.length == 0)
    {
        return NO; // return NO to not change text
    }
    else
    {
        return YES;
        
    }
}


-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

- (IBAction)ButtonSignIN:(id)sender {
    [self.txtPassword resignFirstResponder];
    [self.view endEditing:YES];
    NSString *mobileNumberCleaned = [Utilities removeAllLeadingZero:self.txtEmail.text ];

    if(IS_PHONE_VERIFICATION_WITH_PASSWORD==1){
        if ( mobileNumberCleaned.length < constantTaxiModel.min_phone_length){
            [self showWarningWithMessgae:[LanguageHelper getStringWithKey:@"k_21_s2_plz_enter_valid_mobile_number"]];
            return;
        }
    }else{
        if (![UtilityClass validateEmailWithString:_txtEmail.text]) {
            [self showAlertWithMessgae:[LanguageHelper getStringWithKey:@"k_14_s3_plz_enter_valid_email"]];
            return;
        }
        if (self.txtPassword.text.length <constantTaxiModel.min_password_length) {
            [self showWarningWithMessgae:[Utilities validPasswordMessage]];
            return;
        }
    }
    
    NSString *countryCode = [Utilities removePlusBeforeNumber:[countrySelected objectForKey:@"dial_code"]];
    NSDictionary *dict = @{P_U_MOBILE:mobileNumberCleaned ,  P_C_CODE: isEmpty(countryCode)};
    [self validateUserName:[dict mutableCopy]];
}

-(void) validateUserName:(NSMutableDictionary *) dictUser{
    [UtilityClass setLH:NO wt:[LanguageHelper getStringWithKey:@"k_53_s3_please_wait"]];
    [GIC mkwerwu:USER_VALIDATE
                  d:dictUser
              cb:^(id results, NSError *error) {
        [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_53_s3_please_wait"]];
        if ([[[results objectForKey:P_STATUS]  uppercaseString]isEqualToString:@"OK"]) {
            if([[results objectForKey:P_RESPONSE] isKindOfClass:[NSDictionary class]]){
                [dictUser setObject:isEmpty([[results objectForKey:P_RESPONSE] objectForKey:@"is_test"]) forKey:@"is_test" ];
                self->dictUserForLogin=dictUser;
                [self verifyMobileNo];
            }else{
                [self userNotExist];
            }
        }
        else if ([[results objectForKey:P_STATUS]  isEqualToString:@"Error"]) {
            if([[results objectForKey:P_RESPONSE] isKindOfClass:[NSDictionary class]]){
                [dictUser setObject:isEmpty([[results objectForKey:P_RESPONSE] objectForKey:@"is_test"]) forKey:@"is_test" ];
                self->dictUserForLogin=dictUser;
                [self verifyMobileNo];
            }else{
                [self showAlertWithMessgae:Localise([results objectForKey:P_MESSAGE])];
            }
        }
        
        else{
            if(results!=nil)   {
                [self userNotExist];
            }else{
                NSDictionary *dictError=[Utilities handleErrorDict:error ];
                if(dictError!=nil){
                    [self userNotExist];
                }else{
                    [Utilities  handleError:error viewController:self defaultMessage:@""];
                }
            }
        }
    }];
}


-(void)userNotExist{
    UIAlertController *alert=[UIAlertController alertControllerWithTitle:[LanguageHelper getStringWithKey:@"k_18_s3_ph_not_exists"] message:[LanguageHelper getStringWithKey:@"k_18_s3_do_uw_reg"] preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:[LanguageHelper getStringWithKey:@"k_30_s6_cancel_j"] style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:[LanguageHelper getStringWithKey:@"k_16_s2_register"] style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull action) {
        OtpSignUpViewController *vc=[self.storyboard instantiateViewControllerWithIdentifier:@"OtpSignUpViewController"];
        vc.modalPresentationStyle=UIModalPresentationFullScreen;
        NSString *mobileNumberCleaned = [Utilities removeAllLeadingZero:self.txtEmail.text ];
        vc.mobileNumber=mobileNumberCleaned;
        [self.navigationController pushViewController:vc animated:NO];
    }]];
    [self.navigationController presentViewController:alert animated:YES completion:^{
        
    }];
}

-(void)verifyMobileNo{
    smsCode = [Utilities getRandomNumberBetween:1000 to:9999];
    ConstantModel *consModel=[ConstantModel getConstantsObject];
    BOOL isTestAccount=NO;
    if(self->dictUserForLogin){
        isTestAccount=[[self->dictUserForLogin objectForKey:@"is_test"]boolValue];
    }
    if(consModel.otp_off||isTestAccount){
        [self sendMeToVerificationView];
        return;
    }
    NSString *otpMessage = [Utilities formatOtpMessageWithOtp:smsCode isResetPassword:NO];
    NSString *phoneNum =[Utilities removeAllLeadingZero:self.txtEmail.text];
    phoneNum = [NSString stringWithFormat:@"%@%@",@"",phoneNum];
    NSString *countryCode = [Utilities removePlusBeforeNumber:[countrySelected objectForKey:@"dial_code"] ];
    phoneNum = [NSString stringWithFormat:@"%@%@",countryCode,phoneNum];
    NSCharacterSet *numbers = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet];
    phoneNum = [phoneNum stringByTrimmingCharactersInSet:numbers];
    NSDictionary *dict = @{
        @"msg": otpMessage,
        @"ph" : phoneNum
    };
    [UtilityClass setLH:NO wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
    [GIC mkwer:enabledEncy?BASE_URL_OTP:[Utilities encodedOTPUrl:dict] to:@"" d:enabledEncy?dict:nil cb:^(id results, NSError *error) {
        [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
        // Antes se miraba solo status, y el backend responde status = "OK" hasta cuando
        // Twilio lanza una excepcion (webservices/tw_sms/index2.php, rama del catch: deja
        // status en "OK" y solo cambia code a 400). Con eso era imposible saber si el SMS
        // habia salido. Peor: si la respuesta no llegaba, se seguia igual a la pantalla del
        // codigo, y alli el boton de reenviar tampoco servia. Quien no recibiera el primer
        // SMS se quedaba fuera. Ver +[Utilities seEnvioElSms:].
        if ([Utilities seEnvioElSms:results]) {
            [self sendMeToVerificationView];
        }
        else{
            [self showWarningWithMessgae:[LanguageHelper getStringWithKey:@"k_21_s2_plz_enter_valid_mobile_number"]];
        }
    }];
    
}


-(void)sendMeToVerificationView{
    OTPVerifyViewController *vc = (OTPVerifyViewController *)[StoryBoardUtiles viewContollerWithIdentifier:StoryBoardUtiles.OTP_VERIFY name:StoryBoardUtiles.STORYBOARD_SIGNUP];
    vc.usersigmUpDict =  dictUserForLogin;
    vc.isFormLogin=YES;
    vc.verificationCode = smsCode;
    NSString *countryCode = [Utilities removePlusBeforeNumber: [countrySelected objectForKey:@"dial_code"] ];
    vc.countryDialCode=countryCode;
    [self.navigationController pushViewController: vc animated:YES];
}



-(void)navigateHome{
    BOOL isSingleMode=  [[[NSUserDefaults standardUserDefaults] objectForKey:P_IS_SINGLE_MODE] boolValue];
    if(isSingleMode){
        [self loadInitailViewController:@[[StoryBoardUtiles viewContollerInMainWithIdentifier:StoryBoardUtiles.HOME_VC],[StoryBoardUtiles viewContollerInMainWithIdentifier:StoryBoardUtiles.HOME_SINGLE_VC]]];
    }else{
        [self loadHomeViewController];
    }
}



- (IBAction)exitToQuizStart:(UIStoryboardSegue *)sender{
}


- (IBAction)buttonLogin:(id)sender {
    
}








- (IBAction)onCountryButTap:(id)sender {
    [self.view endEditing:YES];
    [CounrySelectionView showCountrySelectionViewWithDelegate:self parentView:self.view label:self.lbCountryDialCode];
}

-(void) onCountrySelction:(NSDictionary *)countryDict{
    countrySelected=countryDict;
}

-(void)onCloseView{
    
}



- (IBAction)onLanguageButtonTap:(id)sender {
    [self addTapGesture];
    dropDownBtnSelected=sender;
    CGPoint origin = [self.view convertPoint:CGPointZero fromView:sender];
    BOOL isDown;
    CGRect frame;
    isDown=YES;
    NSArray * arrLanguages = [[LanguageHelper sharedInstance] getLanguageList];
    NSMutableArray * arr = [[NSMutableArray alloc] init];
    for (NSDictionary * dict in arrLanguages) {
        CityModel *city=[[CityModel alloc] init];
        city.city_name=[dict objectForKey:@"name"];
        [arr addObject:city];
    }
    NSArray * arrImage = [[NSArray alloc] init];
    CGFloat f =120;
    if(arr.count<4){
        f=arr.count*40;
    }
    frame=CGRectMake(SCREEN_WIDTH-150, origin.y+40, 130,f);
    if(dropDown == nil) {
        dropDown = [[NIDropDown alloc]showDropDown:sender :&f :arr :arrImage :@"down" view:self.view frame: frame up:isDown isLeftAligin:YES];
        dropDown.delegate = self;
        dropDown.tag=10120;
    }
    else {
        [dropDown hideDropDown:sender];
        dropDown=nil;
    }
}

-(void) addTapGesture{
    gestureBg=[[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [gestureBg setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:.4]];
    tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gestureHandlerMethod:)];
    [gestureBg addGestureRecognizer:tapRecognizer];
    [self.view addSubview:gestureBg];
}

-(void) remoeGesture{
    [gestureBg  removeGestureRecognizer:tapRecognizer];
    [gestureBg removeFromSuperview];
}


-(void)gestureHandlerMethod:(UITapGestureRecognizer*)recognizer {
    [self remoeGesture];
    [dropDown hideDropDown:dropDownBtnSelected];
    dropDown=nil;
}

-(void)updateLanguageName{
    NSString *lng = [[NSUserDefaults standardUserDefaults]objectForKey:@"language"];
    if (lng.length ==0) {
        NSString *deviceLanguage = [[[NSBundle mainBundle] preferredLocalizations] objectAtIndex:0];
        for (NSDictionary * dict in [[LanguageHelper sharedInstance] getLanguageList]) {
//            if([[dict objectForKey:@"is_default"] boolValue])  {
            if([[dict objectForKey:@"code"] isEqualToString:deviceLanguage]) {
                self.lblLanguage.text=[dict objectForKey:@"name"];
                break;
            }
        }
    }
    else{
        for (NSDictionary * dict in [[LanguageHelper sharedInstance] getLanguageList]) {
            if([[dict objectForKey:@"code"] isEqualToString:lng]) {
                self.lblLanguage.text=[dict objectForKey:@"name"];
                break;
            }
        }
    }
    if([[LanguageHelper sharedInstance] getLanguageList].count==Default_City_Count){
        [self.viewLanguage setHidden:YES];
    }else{
        [self.viewLanguage setHidden:NO];
    }
}
- (void) niDropDownDelegateMethod: (NIDropDown *) sender index:(int) index  result:(id) resullt{
        [self remoeGesture];
        CityModel *  cityModel=(CityModel *)resullt;
        self.lblLanguage.text=cityModel.city_name;
            dropDown=nil;
        NSArray * arrLanguages = [[LanguageHelper sharedInstance] getLanguageList];
        NSDictionary * dict=[arrLanguages objectAtIndex:index];
            NSString * selectedLang=[dict objectForKey:@"code"];
        [LanguageHelper  sharedInstance] .cunnrentLanguage=selectedLang;
        NSString * location=[[LanguageHelper sharedInstance] getlcidForCode:selectedLang];
        [[NSUserDefaults standardUserDefaults] setObject:[NSArray arrayWithObjects:location, nil] forKey:@"AppleLanguages"];
        [[NSUserDefaults standardUserDefaults] setObject:selectedLang forKey:@"language"];
        [[NSUserDefaults standardUserDefaults]synchronize];
        [[LanguageHelper  sharedInstance] configureLanguage];
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"NotificationOnLanguageChanged"
         object:nil];
        [self setUIFields];
    
}

@end
