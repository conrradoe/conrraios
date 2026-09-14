//
//  PayoutViewController.m

//
//  Created by Grepix Infotech on 26/11/18.
//  Copyright © 2023 Grepixit. All rights reserved.
//
#import "AskTripOtpVC.h"
#import "AppDelegate.h"
#import "Utilities.h"
#import "CityModel.h"
#import "DataBase.h"
#import <Conrra-Swift.h>

@interface AskTripOtpVC ()<OTPFieldViewDelegate,UITextFieldDelegate>
@property (nonatomic, weak) NSLayoutConstraint *cardCenterYConstraint;
@end

@implementation AskTripOtpVC {
    NSMutableArray *walletTranArray;
    NSString *crStr;
    BOOL isStopTripCall;
    BOOL isAlreadyRequested;
    NSLayoutConstraint *_ndCardBottomConstraint;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.txtTollAmt) {
        self.txtTollAmt.delegate = self;
        self.txtTollAmt.hidden = YES;
    }
    walletTranArray = [[NSMutableArray alloc] init];
    [self setUIFields];
    [self setupNewDesign];
}

- (void)setupNewDesign {
    for (UIView *v in self.view.subviews) {
        v.hidden = YES;
    }
    self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.45];

    UIColor *yellow = [UIColor colorNamed:@"app_theame"] ?: [UIColor colorWithRed:235/255.0 green:181/255.0 blue:24/255.0 alpha:1];

    UIView *card = [[UIView alloc] init];
    card.translatesAutoresizingMaskIntoConstraints = NO;
    card.backgroundColor = UIColor.whiteColor;
    card.layer.cornerRadius = 20;
    card.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
    card.clipsToBounds = YES;
    [self.view addSubview:card];

    _ndCardBottomConstraint = [card.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor];
    [NSLayoutConstraint activateConstraints:@[
        [card.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [card.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        _ndCardBottomConstraint,
    ]];

    // White fill that covers the gap below the card when keyboard pushes it up,
    // preventing the dark overlay + map from showing through.
    UIView *footer = [[UIView alloc] init];
    footer.translatesAutoresizingMaskIntoConstraints = NO;
    footer.backgroundColor = UIColor.whiteColor;
    [self.view addSubview:footer];
    [NSLayoutConstraint activateConstraints:@[
        [footer.topAnchor constraintEqualToAnchor:card.bottomAnchor],
        [footer.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
        [footer.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [footer.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
    ]];

    UILabel *titleLbl = [[UILabel alloc] init];
    titleLbl.translatesAutoresizingMaskIntoConstraints = NO;
    titleLbl.text = self.lblTollCharge.text ?: [LanguageHelper getStringWithKey:@"k_94_s4_enter_otp" defaultValue:@"Ingresa el código OTP"];
    titleLbl.font = FONTS_NOTO_BOLD(17) ?: [UIFont boldSystemFontOfSize:17];
    titleLbl.textColor = [UIColor colorWithWhite:0.1 alpha:1];
    titleLbl.textAlignment = NSTextAlignmentCenter;
    [card addSubview:titleLbl];

    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    closeBtn.translatesAutoresizingMaskIntoConstraints = NO;
    UIImage *xImg = [UIImage systemImageNamed:@"xmark"];
    if (xImg) {
        [closeBtn setImage:[xImg imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    } else {
        [closeBtn setTitle:@"✕" forState:UIControlStateNormal];
    }
    closeBtn.tintColor = [UIColor colorWithWhite:0.2 alpha:1];
    [closeBtn addTarget:self action:@selector(onCancelButtonTap:) forControlEvents:UIControlEventTouchUpInside];
    [card addSubview:closeBtn];

    [NSLayoutConstraint activateConstraints:@[
        [titleLbl.topAnchor constraintEqualToAnchor:card.topAnchor constant:24],
        [titleLbl.centerXAnchor constraintEqualToAnchor:card.centerXAnchor],
        [titleLbl.leadingAnchor constraintGreaterThanOrEqualToAnchor:card.leadingAnchor constant:56],
        [titleLbl.trailingAnchor constraintLessThanOrEqualToAnchor:card.trailingAnchor constant:-56],

        [closeBtn.centerYAnchor constraintEqualToAnchor:titleLbl.centerYAnchor],
        [closeBtn.trailingAnchor constraintEqualToAnchor:card.trailingAnchor constant:-20],
        [closeBtn.widthAnchor constraintEqualToConstant:32],
        [closeBtn.heightAnchor constraintEqualToConstant:32],
    ]];

    UILabel *subtitleLbl = [[UILabel alloc] init];
    subtitleLbl.translatesAutoresizingMaskIntoConstraints = NO;
    subtitleLbl.text = [Utilities stringByStrippingHTML:[LanguageHelper getStringWithKey:@"k_18_s4_plz_ask_psngr_fr_otp"
                                          defaultValue:@"Pide el código OTP de 4 dígitos a tu Pasajero para validar el viaje"]];
    subtitleLbl.font = [UIFont systemFontOfSize:15];
    subtitleLbl.textColor = [UIColor colorWithWhite:0.25 alpha:1];
    subtitleLbl.numberOfLines = 0;
    [card addSubview:subtitleLbl];
    [NSLayoutConstraint activateConstraints:@[
        [subtitleLbl.topAnchor constraintEqualToAnchor:titleLbl.bottomAnchor constant:24],
        [subtitleLbl.leadingAnchor constraintEqualToAnchor:card.leadingAnchor constant:24],
        [subtitleLbl.trailingAnchor constraintEqualToAnchor:card.trailingAnchor constant:-24],
    ]];

    // Compute square boxes that fill the card's content width (24pt padding each side)
    const CGFloat otpPad = 24.0;
    const CGFloat otpGap = 12.0;
    const CGFloat otpTotalW = SCREEN_WIDTH - 2 * otpPad;
    const CGFloat otpW = floor((otpTotalW - 3 * otpGap) / 4);
    const CGFloat otpH = otpW;
    const CGFloat actualTotalW = 4 * otpW + 3 * otpGap;

    // Match login OTP pattern exactly: add to superview FIRST so layoutIfNeeded
    // inside initializeUI runs with the view in the hierarchy and correct bounds.
    [self.txtTripOTP removeFromSuperview];
    [card addSubview:self.txtTripOTP];

    // Remove any stale storyboard self-constraints before applying new ones
    [self.txtTripOTP removeConstraints:self.txtTripOTP.constraints.copy];

    self.txtTripOTP.fieldsCount = 4;
    self.txtTripOTP.fieldSize = otpH;
    self.txtTripOTP.fieldWidth = otpW;
    self.txtTripOTP.separatorSpace = otpGap;
    self.txtTripOTP.fieldBorderWidth = 0;
    self.txtTripOTP.displayType = DisplayTypeRoundedCorner;
    self.txtTripOTP.defaultBackgroundColor = [UIColor colorWithRed:243/255.0f green:243/255.0f blue:243/255.0f alpha:1.0f];
    self.txtTripOTP.filledBackgroundColor  = [UIColor colorWithRed:243/255.0f green:243/255.0f blue:243/255.0f alpha:1.0f];
    self.txtTripOTP.fieldFont = FONTS_THEME_BOLD(23) ?: [UIFont boldSystemFontOfSize:23];
    self.txtTripOTP.otpInputType = KeyboardTypeNumeric;
    self.txtTripOTP.delegate = self;

    self.txtTripOTP.translatesAutoresizingMaskIntoConstraints = YES;
    self.txtTripOTP.frame = CGRectMake(0, 0, actualTotalW, otpH);
    [self.txtTripOTP initializeUI];
    self.txtTripOTP.translatesAutoresizingMaskIntoConstraints = NO;

    [NSLayoutConstraint activateConstraints:@[
        [self.txtTripOTP.topAnchor constraintEqualToAnchor:subtitleLbl.bottomAnchor constant:32],
        [self.txtTripOTP.centerXAnchor constraintEqualToAnchor:card.centerXAnchor],
        [self.txtTripOTP.widthAnchor constraintEqualToConstant:actualTotalW],
        [self.txtTripOTP.heightAnchor constraintEqualToConstant:otpH],
    ]];

    UIButton *verifyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    verifyBtn.translatesAutoresizingMaskIntoConstraints = NO;
    verifyBtn.backgroundColor = yellow;
    [verifyBtn setTitle:[LanguageHelper getStringWithKey:@"k_s7_verfy" defaultValue:@"Verificar"] forState:UIControlStateNormal];
    [verifyBtn setTitleColor:[UIColor colorWithWhite:0.1 alpha:1] forState:UIControlStateNormal];
    verifyBtn.titleLabel.font = FONTS_NOTO_BOLD(17) ?: [UIFont boldSystemFontOfSize:17];
    verifyBtn.layer.cornerRadius = 14;
    verifyBtn.clipsToBounds = YES;
    [verifyBtn addTarget:self action:@selector(onPayoutButtonTap:) forControlEvents:UIControlEventTouchUpInside];
    [card addSubview:verifyBtn];
    [NSLayoutConstraint activateConstraints:@[
        [verifyBtn.topAnchor constraintEqualToAnchor:self.txtTripOTP.bottomAnchor constant:28],
        [verifyBtn.leadingAnchor constraintEqualToAnchor:card.leadingAnchor constant:24],
        [verifyBtn.trailingAnchor constraintEqualToAnchor:card.trailingAnchor constant:-24],
        [verifyBtn.heightAnchor constraintEqualToConstant:56],
        [verifyBtn.bottomAnchor constraintEqualToAnchor:card.bottomAnchor constant:-20],
    ]];
}



-(void)enteredOTPWithOtp:(NSString *)otp{
    [self onPayoutButtonTap:nil];
}

-(BOOL)shouldBecomeFirstResponderForOTPWithOtpTextFieldIndex:(NSInteger)index{
    return YES;
}

-(BOOL)hasEnteredAllOTPWithHasEnteredAll:(BOOL)hasEnteredAll{
    return hasEnteredAll;
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setUIFields];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    CGRect keyboardEndFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyboardHeight = CGRectGetHeight(keyboardEndFrame);
    NSTimeInterval duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView animateWithDuration:duration animations:^{
        // iOS automatically shifts self.view.frame up to keep the first responder
        // visible — reset that shift here so only our constraint moves the card.
        CGRect frame = self.view.frame;
        frame.origin.y = 0;
        self.view.frame = frame;
        if (self->_ndCardBottomConstraint) {
            self->_ndCardBottomConstraint.constant = -keyboardHeight;
        } else if (self.cardCenterYConstraint) {
            self.cardCenterYConstraint.constant = -keyboardHeight;
        }
        [self.view layoutIfNeeded];
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    NSTimeInterval duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView animateWithDuration:duration animations:^{
        CGRect frame = self.view.frame;
        frame.origin.y = 0;
        self.view.frame = frame;
        if (self->_ndCardBottomConstraint) {
            self->_ndCardBottomConstraint.constant = 0;
        } else if (self.cardCenterYConstraint) {
            self.cardCenterYConstraint.constant = 0;
        }
        [self.view layoutIfNeeded];
    }];
}
-(void)openAgainKeyboard:(BOOL)isDeleteOnly{
    if(isDeleteOnly){
        [self.txtTripOTP deleteTextIn:((OTPTextField *)[self.txtTripOTP viewWithTag:1])];
        [self.txtTripOTP deleteTextIn:((OTPTextField *)[self.txtTripOTP viewWithTag:2])];
        [self.txtTripOTP deleteTextIn:((OTPTextField *)[self.txtTripOTP viewWithTag:3])];
        [self.txtTripOTP deleteTextIn:((OTPTextField *)[self.txtTripOTP viewWithTag:4])];
    }else{
        [((OTPTextField *)[self.txtTripOTP viewWithTag:1]) becomeFirstResponder];
    }
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    // Delay so the cross-dissolve presentation animation fully completes before
    // the keyboard notification fires — otherwise the card offset is computed
    // against an intermediate frame and appears too high on first show.
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [((OTPTextField *)[self.txtTripOTP viewWithTag:1]) becomeFirstResponder];
    });
}

- (void)setUIFields {
    self.lblTollCharge.text = [LanguageHelper getStringWithKey:@"k_94_s4_enter_otp" defaultValue:@"Ingresa el código OTP"];
    self.lblTollCharge.font = [UIFont boldSystemFontOfSize:17];
    self.lblTollCharge.textAlignment = NSTextAlignmentCenter;
    self.lblTollCharge.textColor = [UIColor colorWithWhite:0.15 alpha:1];

    NSString *instruction = [Utilities stringByStrippingHTML:[LanguageHelper getStringWithKey:@"k_18_s4_plz_ask_psngr_fr_otp" defaultValue:@"Pide el código OTP de 4 dígitos a tu Pasajero para validar el viaje"]];
    self.lblTollAmountText.text = instruction;
    self.lblTollAmountText.font = [UIFont systemFontOfSize:15];
    self.lblTollAmountText.textAlignment = NSTextAlignmentLeft;
    self.lblTollAmountText.textColor = [UIColor colorWithWhite:0.4 alpha:1];
    self.lblTollAmountText.numberOfLines = 0;

    [self.btnTollAdd setTitle:[LanguageHelper getStringWithKey:@"k_s7_verfy" defaultValue:@"Verificar"] forState:UIControlStateNormal];
    self.btnTollAdd.backgroundColor = [UIColor colorNamed:@"app_theame"] ?: [UIColor colorWithRed:1 green:0.78 blue:0 alpha:1];
    [self.btnTollAdd setTitleColor:[UIColor colorWithWhite:0.15 alpha:1] forState:UIControlStateNormal];
    self.btnTollAdd.titleLabel.font = FONTS_THEME_BOLD(17) ?: [UIFont boldSystemFontOfSize:17];
    self.btnTollAdd.layer.cornerRadius = 12;
    self.btnTollAdd.clipsToBounds = YES;

    UIView *card = self.cardContainerView ?: self.view.subviews.firstObject;
    if (card) {
        card.layer.cornerRadius = 16;
        card.clipsToBounds = YES;
    }
}



- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    NSString *expression = @"^[0-9]*((\\.|,)[0-9]{0,2})?$";
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:expression options:NSRegularExpressionCaseInsensitive error:&error];
    NSUInteger numberOfMatches = [regex numberOfMatchesInString:newString options:0 range:NSMakeRange(0, [newString length])];
    return numberOfMatches != 0;
}


- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}


- (IBAction)onPayoutButtonTap:(id)sender {
   
    if(isAlreadyRequested){
        [self showAlertWithMessgae:[LanguageHelper getStringWithKey:@"k_r16_s7_outstnd_wallet_blnc"]];
        return;
    }
    NSString * otp1=((OTPTextField *)[self.txtTripOTP viewWithTag:1]).text;
    NSString * otp2=((OTPTextField *)[self.txtTripOTP viewWithTag:2]).text;
    NSString * otp3=((OTPTextField *)[self.txtTripOTP viewWithTag:3]).text;
    NSString * otp4=((OTPTextField *)[self.txtTripOTP viewWithTag:4]).text;
    NSString *enteredOtp=[NSString stringWithFormat:@"%@%@%@%@",otp1,otp2,otp3,otp4];
    
//    NSString *trimmed = [self.txtTollAmt.text stringByReplacingOccurrencesOfString:@" " withString:@""];
//    NSNumberFormatter * nformatter=[[NSNumberFormatter alloc] init];
//    [nformatter setLocale:[NSLocale localeWithLocaleIdentifier:@"EN"]];
//     NSString *payoutAmount=[NSString stringWithFormat:@"%@",[nformatter numberFromString:trimmed]];
    if([enteredOtp intValue]<=0){
        [self showAlertWithMessgae:[LanguageHelper getStringWithKey:@"k_45_s4_plz_enter_otp_ask_frm_driver"]];
        return;
    }
//    [self.view endEditing:YES];
//    [self dismissViewControllerAnimated:YES completion:^{
//
//        [self.delegate onOtpEnteredForBegin:enteredOtp viewController:self];
//    }];
            [self.delegate onOtpEnteredForBegin:enteredOtp viewController:self];
}
 
- (IBAction)onCancelButtonTap:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        [self.delegate closeAskOtpScreen];
    }];
}



+(AskTripOtpVC *) openWith:(TripModel *) trip  viewController:(UIViewController *)viewController {
    AskTripOtpVC *vc=(AskTripOtpVC *)[StoryBoardUtiles viewContollerWithIdentifier:@"AskTripOtpVC" name:StoryBoardUtiles.STORYBOARD_EXTRA_FEATURE];
    vc.modalPresentationStyle=UIModalPresentationOverCurrentContext;
    vc.modalTransitionStyle=UIModalTransitionStyleCrossDissolve;
    vc.trip=trip;
    [viewController presentViewController:vc animated:YES completion:^{
      
    }];
    return  vc;
}

@end
