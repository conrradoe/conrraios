//
//  SignUpViewController.m
//  Store_project
//
//  Created by  Appicial on 22/05/17.
//  Copyright © 2023 Appicial. All rights reserved.
//

#import "OtpSignUpViewController.h"
#import <GIKit/GIKit.h>
#import "WebCallConstants.h"
#import "AppDelegate.h"
#import "UploadDocumentViewController.h"
#import "Utilities.h"
#import "OTPVerifyViewController.h"
#import "CityModel.h"
#import "NIDropDown.h"
#import "UIHelper.h"
#import "UIView+UpdateAutoLayoutConstraints.h"
#import "ConstantModel.h"
#import "SettingsModel.h"
#import "ConrraButton.h"
#import "LanguageHelper.h"
@interface OtpSignUpViewController ()<NIDropDownDelegate>
@end

@implementation OtpSignUpViewController
{
    int smsCode;
    NSMutableDictionary *dict;
    NIDropDown *dropDown;
    //    CityModel *cityModel;
    NSDictionary * countrySelected;
    ConstantModel *  constantTaxiModel;
    UIButton *dropDownBtnSelected;
    UITapGestureRecognizer *tapRecognizer;
    UIView *gestureBg;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    constantTaxiModel =[ConstantModel getConstantsObject];
    [self setUIFields];
    [self setThemeConstants];
    self.txtMobile.text=isEmpty(self.mobileNumber);
    [self setupTextField:_txtRePassword];
    [self setupTextField:_txtMobile];
    [self setupTextField:_txtLastName];
    [self setupTextField:_txtFirstName];
    [self setupTextField:_txtPassword];
    [self setupTextField:_txtEmail];
    [self setupTextField:_txtCity];
    self.btnTerms.tintColor = [UIColor colorNamed:@"color_app_input"];
    [self.btnTerms setImage:[[UIImage imageNamed:@"icon_unchecked"] imageWithRenderingMode:(UIImageRenderingModeAlwaysTemplate)] forState:(UIControlStateNormal)];
    [self.btnTerms setImage:[[UIImage imageNamed:@"icon_checked"] imageWithRenderingMode:(UIImageRenderingModeAlwaysTemplate)] forState:(UIControlStateSelected)];
    
    self.lbCountryDialCode.attributedText=[CounrySelectionView getCurrentCountry];
    int width = [self.lbCountryDialCode.attributedText size].width+20;
    [self.lbCountryDialCode setConstraintConstant:width forAttribute:NSLayoutAttributeWidth];
    countrySelected=[CounrySelectionView getCurrentCountryDict];
    if([[ConstantModel getConstantsObject] getCValueFK:@"tnc"]==YES){
        self.viewTerms.hidden=NO;
    }else{
        [self.viewTerms hideByHeight:YES];
    }
    [self.cityView hideByHeight:YES];
    [self.txtTerms setEditable:NO];
    [self.txtTerms setSelectable:NO];
    [self.txtTerms addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapOnLabel:)]];

    [self setupSignUpScreenLayout];
}


-(void) setUIFields{
    self.lblHeader.text =[UIHelper appNameForDisplay];
    //    self.imgViewLogo.image = [UIImage imageNamed:@"hireMe_logo"];
    [self.btnLogin setTitle:[LanguageHelper loginScreenTitle] forState:UIControlStateNormal];
    [self.btnRegister setTitle: [LanguageHelper getStringWithKey:@"k_16_s2_register"]   forState:UIControlStateNormal];
    self.lblFirstName.text = [LanguageHelper getStringWithKey:@"k_1_s2_fname"];
    self.txtFirstName.placeholder    = [LanguageHelper getStringWithKey:@"k_2_s2_fname_hint"];
    self.lblLastName.text = [LanguageHelper getStringWithKey:@"k_3_s2_lname"];
    self.txtLastName.placeholder    =[LanguageHelper getStringWithKey:@"k_4_s2_lname_hint"];
    self.lblMobileNumber.text = [LanguageHelper getStringWithKey:@"k_2_s1_mobile_number_hint"];
    self.txtMobile.placeholder = [LanguageHelper getStringWithKey:@"k_r6_s2_enter_mob_no"];
    self.lbCountryDialCode.text = [LanguageHelper getStringWithKey:@"k_26_s2_select"];
    self.lblEmail.text = [LanguageHelper getStringWithKey:@"k_r8_s2_email"];
    self.txtEmail.placeholder = [LanguageHelper getStringWithKey:@"k_6_s3_email_address"];
    self.lblCity.text = [LanguageHelper getStringWithKey:@"k_18_s6_city"];
    self.txtCity.placeholder = [LanguageHelper getStringWithKey:@"k_16_s7_please_select_city"];
    self.lblPassword.text = [LanguageHelper getStringWithKey:@"k_11_s2_password"];
    self.txtPassword.placeholder = [LanguageHelper getStringWithKey:@"k_4_s1_enter_password_hint"];
    self.lblConfirnPass.text = [LanguageHelper getStringWithKey:@"k_13_s2_confirm_password"];
    self.txtRePassword.placeholder = [LanguageHelper getStringWithKey:@"k_14_s2_confirm_password_hint"];
    [self.btnJoin setTitle: [LanguageHelper getStringWithKey:@"k_16_s2_register"]   forState:UIControlStateNormal];
    [self.btnFacebook setTitle: [LanguageHelper getStringWithKey:@"k_31_s2_facebook"]   forState:UIControlStateNormal];
    [self.btnDone setTitle: [LanguageHelper getStringWithKey:@"k_18_s1_done"]   forState:UIControlStateNormal];
    [self.viewContainer setClipsToBounds:YES];
    [self.viewContainer.layer setCornerRadius:5];
    [self.btRegister setClipsToBounds:YES];
    [self.btRegister.layer setCornerRadius:5];
    if([constantTaxiModel getCValueFK:ckey_erf] ==NO)
    {
        [self.viewReferral hideByHeight:YES];
    }
    self.txtReferral.placeholder=[LanguageHelper getStringWithKey:@"k_15_s2_referral_id"];
    self.lblReferral.text=[LanguageHelper getStringWithKey:@"k_15_s2_referral_id"];
    [self updateLanguageName];
    self.txtTerms.attributedText = [self formatViewDetailText:[LanguageHelper getStringWithKey:@"k_6_s12_i_read_and_agree"]];
}







-(void)setThemeConstants{
    
    //    [_blHeader setFont:FONTS_THEME_REGULAR(19)];
    // [_btnJoin.titleLabel setFont:FONTS_THEME_REGULAR(18)];
    //    [_txtEmail setFont:FONTS_THEME_REGULAR(16)];
    //    [_txtPassword setFont:FONTS_THEME_REGULAR(16)];
    //    [_txtFirstName setFont:FONTS_THEME_REGULAR(16)];
    //    [_txtLastName setFont:FONTS_THEME_REGULAR(16)];
    //    [_txtMobile setFont:FONTS_THEME_REGULAR(16)];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:StoryBoardUtiles.UPLOAD_DOCUMENT]) {
        UploadDocumentViewController *view =(UploadDocumentViewController *)[segue destinationViewController];
        
        view.isfromProfile = NO;
    }
}


-(void)setupTextField:(UITextField*)textField{
    textField.delegate=self;
    [self setTextFieldPlaceholderColor:textField];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    if (textField == self.txtFirstName){
        [self.txtLastName becomeFirstResponder];
        
    }
    else if (textField == self.txtLastName){
        
        [self.txtMobile becomeFirstResponder];
        
    }
    else if (textField == self.txtMobile){
        
        [self.txtEmail becomeFirstResponder];
        
    }
    else if (textField == self.txtEmail){
        
        [self.txtPassword becomeFirstResponder];
        
    }
    else if (textField == self.txtPassword){
        
        [self.txtRePassword becomeFirstResponder];
        
    }
    else if (textField == self.txtRePassword){
        
        [self.txtRePassword resignFirstResponder];
        
    }
    return YES;
}


-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

- (IBAction)ButtonBackAction:(id)sender {
    [self.navigationController popViewControllerAnimated:NO];
    //    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)ButtonJoinPressed:(id)sender {
    NSString *mobileNumberCleaned = [Utilities removeAllLeadingZero:self.txtMobile.text ];
    if (_txtFirstName.text.length==0){
        [self showAlertWithMessgae:[LanguageHelper getStringWithKey:@"k_18_s2_plz_enter_first_name"]];
    }
    else if (_txtLastName.text.length==0){
        [self showAlertWithMessgae:[LanguageHelper getStringWithKey:@"k_19_s2_plz_enter_last_name"]];
    }
    //    else if(cityModel==nil){
    //        [self showAlertWithMessgae:[LanguageHelper getStringWithKey:@"k_10_s1_plz_sel_country_code"]];
    //    }
    else if(countrySelected==nil){
        [self showAlertWithMessgae:[LanguageHelper getStringWithKey:@"k_r9_s1_plz_enter_valid_cc"]];
    }
    else  if (mobileNumberCleaned.length<constantTaxiModel.min_phone_length){
        [self showAlertWithMessgae:[LanguageHelper getStringWithKey:@"k_21_s2_plz_enter_valid_mobile_number"]];
    }
    else if (![UtilityClass validateEmailWithString:_txtEmail.text]) {
        [self showAlertWithMessgae:[LanguageHelper getStringWithKey:@"k_14_s3_plz_enter_valid_email"]];
    }
    
    //    else if (_txtPassword.text.length<constantTaxiModel.min_password_length){
    //        [self showAlertWithMessgae:[Utilities validPasswordMessage]];
    //    }
    //    else if (_txtRePassword.text.length<constantTaxiModel.min_password_length){
    //        [self showAlertWithMessgae:[LanguageHelper getStringWithKey:@"k_13_s2_confirm_password"]];
    //    }
    //    else  if (![_txtPassword.text isEqualToString:_txtRePassword.text]){
    //        [self showAlertWithMessgae:[LanguageHelper getStringWithKey:@"k_25_s2_password_not_match"]];
    //    }
    /* else if (!self.btnTerms.selected){
     [self showAlertWithMessgae:[LanguageHelper getStringWithKey:@"k_6_s12_please_terms_and_conditions"]]
     return;
     }*/
    else{
        //        if(cityModel.city_id == 0)  {
        //            [self showAlertWithMessgae:[LanguageHelper getStringWithKey:@"k_16_s7_please_select_city"]];
        //            return;
        //        }
        if(IS_PHONE_VERIFICATION_WITH_PASSWORD==0){
            if (_txtPassword.text.length<constantTaxiModel.min_password_length){
                [self showAlertWithMessgae:[Utilities validPasswordMessage]
                ];
                return;
            }
            else if (_txtRePassword.text.length<constantTaxiModel.min_password_length){
                [self showAlertWithMessgae:[LanguageHelper getStringWithKey:@"k_22_s2_plz_enter_valid_password"]];
                return;
            }
            else if (![_txtPassword.text isEqualToString:_txtRePassword.text]){
                [self showAlertWithMessgae:[LanguageHelper getStringWithKey:@"k_25_s2_password_not_match"] ];
                return;
            }
        }
        if (!self.btnTerms.selected){
            [self showAlertWithMessgae:[LanguageHelper getStringWithKey:@"k_6_s12_please_terms_and_conditions"]];
            return;
        }
        [self.view endEditing:YES];
        NSString *countryCode = [Utilities removePlusBeforeNumber:[countrySelected objectForKey:@"dial_code"] ];
        NSString *isoCode = [countrySelected objectForKey:@"code"];
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{
            P_U_EMAIL      :_txtEmail.text,
            //            P_PASSWORD   :_txtPassword.text,
            P_U_FNAME      :_txtFirstName.text,
            P_U_LNAME      :_txtLastName.text,
            P_U_MOBILE     :mobileNumberCleaned,
            //            P_CITY_ID:[NSString stringWithFormat:@"%d",cityModel.city_id],
            P_ISO_CODE:isEmpty(isoCode),
            P_C_CODE: isEmpty(countryCode),
        }];
        [dict addEntriesFromDictionary:[Utilities appBuildVersionAndOsInfo]];
        NSString * deviceToken=[[NSUserDefaults standardUserDefaults] objectForKey:P_DEVICE_TOKEN];
        
        if (deviceToken.length>0) {
            [dict  setObject:deviceToken forKey:P_DEVICE_TOKEN];
            [dict  setObject:IOS forKey:P_DEVICE_TYPE];
        }
        if(self.txtReferral.text.length>0){
            [self validateReferralCode:self.txtReferral.text dictProfileData:dict];
        }else{
            
            [self validateUserName:dict];
        }
    }
}




-(void) driverRegister{
    [UtilityClass setLH:NO wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
    [GIC mkwu:DRIVER_SIGNUP
            d:dict
           cb:^(id results, NSError *error) {
        [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
        
        if ([[[results objectForKey:P_STATUS] uppercaseString] isEqualToString:@"OK"]) {
            
            defaults_set_object(P_USER_DICT_LOGGED, [results objectForKey:P_RESPONSE]);
            [self performSegueWithIdentifier:StoryBoardUtiles.UPLOAD_DOCUMENT sender:nil];
        }
        else{
            if(results!=nil){
                [self showWarningWithMessgae:[results objectForKey:P_MESSAGE]];
            }else{
                [Utilities handleError:error viewController:self defaultMessage:@""];
            }
        }
    }];
}





-(void) validateUserName:(NSMutableDictionary *) dictUser{
    NSString *mobileNumberCleaned = [Utilities removeAllLeadingZero:self.txtMobile.text ];
    NSString *countryCode = [Utilities removePlusBeforeNumber:[countrySelected objectForKey:@"dial_code"] ];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{
        P_U_MOBILE:mobileNumberCleaned,
        P_U_EMAIL:self.txtEmail.text,
        P_C_CODE: isEmpty(countryCode)
    }];
    [UtilityClass setLH:NO wt:[LanguageHelper getStringWithKey:@"k_53_s3_please_wait"]];
    [GIC mkwerwu:USER_VALIDATE
               d:dict
              cb:^(id results, NSError *error) {
        [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_53_s3_please_wait"]];
        if ([[[results objectForKey:P_STATUS]  uppercaseString]isEqualToString:@"OK"]) {
            self->dict=dictUser;
            [self verifyMobileNo];
        }
        else{
            if(results!=nil)   {
                [self showWarningWithMessgae:[results objectForKey:@"message"]];
            }else{
                [Utilities handleError:error viewController:self defaultMessage:@""];
            }
        }
    }];
}




-(void)verifyMobileNo{
    
    smsCode = [Utilities getRandomNumberBetween:1000 to:9999];
    
    ConstantModel *consModel=[ConstantModel getConstantsObject];
    if(consModel.otp_off){
        [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
        [self sendMeToVerificationView];
        return ;
    }
    NSString *otpMessage =[Utilities formatOtpMessageWithOtp:smsCode isResetPassword:NO];
    NSString *phoneNum = [Utilities removeAllLeadingZero:_txtMobile.text ];
    NSString *countryCode = [Utilities removePlusBeforeNumber:[countrySelected objectForKey:@"dial_code"] ];
    phoneNum = [NSString stringWithFormat:@"%@%@",countryCode,phoneNum];
    NSDictionary *dict = @{
        @"msg": otpMessage,
        @"ph" : phoneNum
    };
    [UtilityClass setLH:NO wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
    [GIC mk:enabledEncy?BASE_URL_OTP:[Utilities encodedOTPUrl:dict] to:@"" d:enabledEncy?dict:nil isa:NO
         cb:^(id results, NSError *error) {
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
            [Utilities showAlertwithTilte:[LanguageHelper getStringWithKey:@"k_23_s3_warning"] message:[LanguageHelper getStringWithKey:@"k_r6_s2_enter_mob_no"] navigatationController:self.navigationController];
        }
    }];
}


-(void)sendMeToVerificationView{
    OTPVerifyViewController *vc = (OTPVerifyViewController *)[StoryBoardUtiles viewContollerWithIdentifier:StoryBoardUtiles.OTP_VERIFY name:StoryBoardUtiles.STORYBOARD_SIGNUP];
    vc.usersigmUpDict =  dict;
    vc.verificationCode = smsCode;
    NSString *countryCode = [Utilities removePlusBeforeNumber: [countrySelected objectForKey:@"dial_code"] ];
    vc.countryDialCode=countryCode;
    vc.modalPresentationStyle=UIModalPresentationFullScreen;
    [self.navigationController pushViewController: vc animated:YES];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (textField ==self.txtMobile && textField.text.length >= constantTaxiModel.max_phone_length && range.length == 0){
        return NO; // return NO to not change text
    }
    else{
        return YES;
    }
}



- (IBAction)onSelectCityButTap:(UIButton *)sender {
    //    [self addTapGesture];
    //    dropDownBtnSelected=sender;
    //    BOOL isDown;
    //    isDown=YES;
    //    NSMutableArray * arr = [[NSMutableArray alloc] initWithArray:[APP_DELEGATE arrayCities]];
    //    CityModel * cityFirst=[[CityModel alloc] init];
    //    cityFirst.city_name=[LanguageHelper getStringWithKey:@"k_16_s7_please_select_city"];
    //    cityFirst.city_id=0;
    //    [arr insertObject:cityFirst atIndex:0];
    //    CGFloat f =120;
    //    if(arr.count<4){
    //        f=arr.count*40;
    //    }
    //    f = SCREEN_HEIGHT-200;
    //    CGRect frame=CGRectMake(30,100, SCREEN_WIDTH-60,SCREEN_HEIGHT-100);
    //    if(dropDown == nil) {
    //        dropDown = [[NIDropDown alloc]showDropDown:sender :&f :arr :@[] :@"full" view:self.view frame: frame up:isDown isLeftAligin:YES];
    //        dropDown.delegate = self;
    //        dropDown.tag=13;
    //    }
    //    else {
    //        [dropDown hideDropDown:sender];
    //        dropDown=nil;
    //    }
}

- (void) niDropDownDelegateMethod: (NIDropDown *) sender index:(int) index  result:(id) resullt
{
    [self remoeGesture];
    if(sender.tag==13) {
        //        cityModel=(CityModel *)resullt;
        //        self.txtCity.text=[NSString stringWithFormat:@"%@",cityModel.city_name];
        //        dropDown=nil;
    }else  {
        
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
}


- (IBAction)backToLoginbtn:(id)sender {
    [self.navigationController popViewControllerAnimated:NO];
}





- (IBAction)onCountryButTap:(id)sender {
    [self.view endEditing:YES];
    [CounrySelectionView showCountrySelectionViewWithDelegate:self parentView:self.view label:self.lbCountryDialCode];
}

-(void) onCountrySelction:(NSDictionary *)countryDict{
    countrySelected=countryDict;
}

- (void)onCloseView{
    
}


-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    CGRect frame=dropDown.frame;
    CGPoint origin = [self.view convertPoint:CGPointZero fromView:self.btCity];
    frame.origin.y=origin.y+40;
    dropDown.frame=frame;
}
- (IBAction)onTermsButtonTap:(UIButton *)sender {
    sender.selected=!sender.selected;
}


- (IBAction)onTermsAndContionButtonTap:(id)sender {
    AboutUsViewController *viewController=(AboutUsViewController *)[StoryBoardUtiles viewContollerInMainWithIdentifier:StoryBoardUtiles.ABOUT_US ];
    viewController.isAboutUs=NO;
    viewController.isFormSignUp=YES;
    viewController.modalPresentationStyle=UIModalPresentationFullScreen;
    [self presentViewController:viewController animated:YES completion:^{
        
    }];
}


-(void) validateReferralCode:(NSString *) referralCode dictProfileData:(NSMutableDictionary*) profileData
{
    [UtilityClass setLH:NO wt:[LanguageHelper getStringWithKey:@"k_53_s3_please_wait"]];
    [GIC mkwerwu:API_VALIDATE_REFERRAL_CODE
               d:@{@"ref_id":isEmpty(referralCode)}
     //isa:NO
              cb:^(id results, NSError *error) {
        
        [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_53_s3_please_wait"]];
        
        if(error != nil)
        {
            [Utilities handleError:error viewController:self defaultMessage:@"Internet Error"];
            return;
        }
        if([[[results objectForKey:P_STATUS] uppercaseString] isEqualToString:@"OK"])
        {
            [profileData setObject:referralCode forKey:@"ref_id"];
            [self validateUserName:profileData];
        }
    }];
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

- (IBAction)onTermsAndCondition:(UIButton *)sender {
    sender.selected = !sender.selected;
}

#pragma mark - New UI Layout

- (void)setupSignUpScreenLayout {
    self.viewHeader.hidden         = YES;
    self.headerView.hidden         = YES;   // second header with logo + app name
    self.headerSepView.hidden      = YES;
    self.loginRegiView.hidden      = YES;
    self.viewLanguage.hidden       = YES;
    self.registerScrollView.hidden = YES;

    self.view.backgroundColor = [UIColor blackColor];
    UIImage *bgImage = [UIImage imageNamed:@"login_bg"];
    if (bgImage) {
        UIImageView *bgIV = [[UIImageView alloc] initWithImage:bgImage];
        bgIV.translatesAutoresizingMaskIntoConstraints = NO;
        bgIV.contentMode = UIViewContentModeScaleAspectFill;
        bgIV.clipsToBounds = YES;
        [self.view insertSubview:bgIV atIndex:0];
        [NSLayoutConstraint activateConstraints:@[
            [bgIV.topAnchor      constraintEqualToAnchor:self.view.topAnchor],
            [bgIV.leadingAnchor  constraintEqualToAnchor:self.view.leadingAnchor],
            [bgIV.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
            [bgIV.bottomAnchor   constraintEqualToAnchor:self.view.bottomAnchor],
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
    }

    UIView *cardView = [[UIView alloc] init];
    cardView.translatesAutoresizingMaskIntoConstraints = NO;
    cardView.backgroundColor = [UIColor whiteColor];
    cardView.layer.cornerRadius = 24;
    cardView.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
    cardView.clipsToBounds = YES;
    [self.view addSubview:cardView];
    [NSLayoutConstraint activateConstraints:@[
        [cardView.leadingAnchor  constraintEqualToAnchor:self.view.leadingAnchor],
        [cardView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [cardView.bottomAnchor   constraintEqualToAnchor:self.view.bottomAnchor],
        [cardView.heightAnchor   constraintEqualToAnchor:self.view.heightAnchor multiplier:0.90f],
    ]];

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    titleLabel.text = [LanguageHelper getStringWithKey:@"k_16_s2_register" defaultValue:@"Regístrate"];
    titleLabel.font = FONTS_NOTO_BOLD(20);
    if (!titleLabel.font) titleLabel.font = [UIFont boldSystemFontOfSize:20];
    titleLabel.textColor = [UIColor colorWithWhite:0.1f alpha:1];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [cardView addSubview:titleLabel];

    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    closeBtn.translatesAutoresizingMaskIntoConstraints = NO;
    UIImage *xIcon = [UIImage systemImageNamed:@"xmark"];
    if (xIcon) {
        [closeBtn setImage:[xIcon imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    } else {
        [closeBtn setTitle:@"✕" forState:UIControlStateNormal];
        closeBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    }
    closeBtn.tintColor = [UIColor colorWithWhite:0.25f alpha:1];
    [closeBtn addTarget:self action:@selector(ButtonBackAction:) forControlEvents:UIControlEventTouchUpInside];
    [cardView addSubview:closeBtn];

    [NSLayoutConstraint activateConstraints:@[
        [titleLabel.topAnchor      constraintEqualToAnchor:cardView.topAnchor constant:20],
        [titleLabel.centerXAnchor  constraintEqualToAnchor:cardView.centerXAnchor],
        [closeBtn.centerYAnchor    constraintEqualToAnchor:titleLabel.centerYAnchor],
        [closeBtn.trailingAnchor   constraintEqualToAnchor:cardView.trailingAnchor constant:-20],
        [closeBtn.widthAnchor      constraintEqualToConstant:32],
        [closeBtn.heightAnchor     constraintEqualToConstant:32],
    ]];

    UIButton *registerBtn = [ConrraButton buttonWithStyle:ConrraButtonStylePrimary];
    registerBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [registerBtn setTitle:@"Registrarme" forState:UIControlStateNormal];
    [registerBtn addTarget:self action:@selector(ButtonJoinPressed:) forControlEvents:UIControlEventTouchUpInside];
    [cardView addSubview:registerBtn];
    [NSLayoutConstraint activateConstraints:@[
        [registerBtn.leadingAnchor  constraintEqualToAnchor:cardView.leadingAnchor  constant:20],
        [registerBtn.trailingAnchor constraintEqualToAnchor:cardView.trailingAnchor constant:-20],
        [registerBtn.heightAnchor   constraintEqualToConstant:56],
        [registerBtn.bottomAnchor   constraintEqualToAnchor:cardView.bottomAnchor   constant:-34],
    ]];

    UIScrollView *sv = [[UIScrollView alloc] init];
    sv.translatesAutoresizingMaskIntoConstraints = NO;
    sv.showsVerticalScrollIndicator = NO;
    [cardView addSubview:sv];
    [NSLayoutConstraint activateConstraints:@[
        [sv.topAnchor      constraintEqualToAnchor:titleLabel.bottomAnchor constant:16],
        [sv.leadingAnchor  constraintEqualToAnchor:cardView.leadingAnchor],
        [sv.trailingAnchor constraintEqualToAnchor:cardView.trailingAnchor],
        [sv.bottomAnchor   constraintEqualToAnchor:registerBtn.topAnchor constant:-12],
    ]];

    UIView *cv = [[UIView alloc] init];
    cv.translatesAutoresizingMaskIntoConstraints = NO;
    [sv addSubview:cv];
    [NSLayoutConstraint activateConstraints:@[
        [cv.topAnchor      constraintEqualToAnchor:sv.contentLayoutGuide.topAnchor],
        [cv.leadingAnchor  constraintEqualToAnchor:sv.contentLayoutGuide.leadingAnchor],
        [cv.trailingAnchor constraintEqualToAnchor:sv.contentLayoutGuide.trailingAnchor],
        [cv.bottomAnchor   constraintEqualToAnchor:sv.contentLayoutGuide.bottomAnchor],
        [cv.widthAnchor    constraintEqualToAnchor:sv.frameLayoutGuide.widthAnchor],
    ]];

    const CGFloat fH  = 56;
    const CGFloat fR  = 14;
    const CGFloat hP  = 20;
    const CGFloat gap = 12;
    UIColor *fBg = [UIColor colorWithRed:243/255.0f green:243/255.0f blue:243/255.0f alpha:1.0f];

    // Nombre
    UIView *firstNameBox = [self su_makeFieldBox:fH radius:fR bg:fBg];
    [cv addSubview:firstNameBox];
    UITextField *firstNameTF = [self su_makeField:@"Nombre" inBox:firstNameBox];
    firstNameTF.returnKeyType = UIReturnKeyNext;
    self.txtFirstName = firstNameTF;
    [self setupTextField:firstNameTF];
    [NSLayoutConstraint activateConstraints:@[
        [firstNameBox.topAnchor      constraintEqualToAnchor:cv.topAnchor constant:20],
        [firstNameBox.leadingAnchor  constraintEqualToAnchor:cv.leadingAnchor  constant:hP],
        [firstNameBox.trailingAnchor constraintEqualToAnchor:cv.trailingAnchor constant:-hP],
        [firstNameBox.heightAnchor   constraintEqualToConstant:fH],
    ]];

    // Apellido
    UIView *lastNameBox = [self su_makeFieldBox:fH radius:fR bg:fBg];
    [cv addSubview:lastNameBox];
    UITextField *lastNameTF = [self su_makeField:@"Apellido" inBox:lastNameBox];
    lastNameTF.returnKeyType = UIReturnKeyNext;
    self.txtLastName = lastNameTF;
    [self setupTextField:lastNameTF];
    [NSLayoutConstraint activateConstraints:@[
        [lastNameBox.topAnchor      constraintEqualToAnchor:firstNameBox.bottomAnchor constant:gap],
        [lastNameBox.leadingAnchor  constraintEqualToAnchor:cv.leadingAnchor  constant:hP],
        [lastNameBox.trailingAnchor constraintEqualToAnchor:cv.trailingAnchor constant:-hP],
        [lastNameBox.heightAnchor   constraintEqualToConstant:fH],
    ]];

    // Phone row
    UIView *phoneBox = [self su_makeFieldBox:fH radius:fR bg:fBg];
    phoneBox.clipsToBounds = NO;
    [cv addSubview:phoneBox];

    UIView *ccBox = [[UIView alloc] init];
    ccBox.translatesAutoresizingMaskIntoConstraints = NO;
    ccBox.backgroundColor = [UIColor whiteColor];
    ccBox.layer.cornerRadius = 10;
    ccBox.layer.shadowColor   = [UIColor blackColor].CGColor;
    ccBox.layer.shadowOffset  = CGSizeMake(0, 0);
    ccBox.layer.shadowRadius  = 4;
    ccBox.layer.shadowOpacity = 0.10f;
    [phoneBox addSubview:ccBox];

    UILabel *dialCodeLbl = [[UILabel alloc] init];
    dialCodeLbl.translatesAutoresizingMaskIntoConstraints = NO;
    dialCodeLbl.font = FONTS_NOTO_REGULAR(15);
    if (!dialCodeLbl.font) dialCodeLbl.font = [UIFont systemFontOfSize:15];
    dialCodeLbl.attributedText = [CounrySelectionView getCurrentCountry];
    self.lbCountryDialCode = dialCodeLbl;
    [ccBox addSubview:dialCodeLbl];

    UIImageView *chevronIV = [[UIImageView alloc] init];
    chevronIV.translatesAutoresizingMaskIntoConstraints = NO;
    UIImage *chevronImg = [UIImage systemImageNamed:@"chevron.down"];
    if (chevronImg) {
        chevronIV.image = [chevronImg imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        chevronIV.tintColor = [UIColor colorWithWhite:0.4f alpha:1];
    }
    chevronIV.contentMode = UIViewContentModeScaleAspectFit;
    [ccBox addSubview:chevronIV];

    UIButton *ccTapBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    ccTapBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [ccTapBtn addTarget:self action:@selector(onCountryButTap:) forControlEvents:UIControlEventTouchUpInside];
    [phoneBox addSubview:ccTapBtn];

    UITextField *phoneTF = [[UITextField alloc] init];
    phoneTF.translatesAutoresizingMaskIntoConstraints = NO;
    phoneTF.placeholder = @"Ej. 4129876543";
    phoneTF.keyboardType = UIKeyboardTypePhonePad;
    phoneTF.font = FONTS_NOTO_REGULAR(15);
    if (!phoneTF.font) phoneTF.font = [UIFont systemFontOfSize:15];
    phoneTF.textColor = [UIColor colorWithRed:40/255.0f green:40/255.0f blue:40/255.0f alpha:1.0f]; // #282828
    phoneTF.text = isEmpty(self.mobileNumber);
    [phoneBox addSubview:phoneTF];
    self.txtMobile = phoneTF;
    [self setupTextField:phoneTF];
    [self setTextFieldPlaceholderColor:phoneTF];

    [NSLayoutConstraint activateConstraints:@[
        [phoneBox.topAnchor      constraintEqualToAnchor:lastNameBox.bottomAnchor constant:gap],
        [phoneBox.leadingAnchor  constraintEqualToAnchor:cv.leadingAnchor  constant:hP],
        [phoneBox.trailingAnchor constraintEqualToAnchor:cv.trailingAnchor constant:-hP],
        [phoneBox.heightAnchor   constraintEqualToConstant:fH],

        [ccBox.leadingAnchor  constraintEqualToAnchor:phoneBox.leadingAnchor  constant:4],
        [ccBox.topAnchor      constraintEqualToAnchor:phoneBox.topAnchor      constant:4],
        [ccBox.bottomAnchor   constraintEqualToAnchor:phoneBox.bottomAnchor   constant:-4],

        [dialCodeLbl.leadingAnchor  constraintEqualToAnchor:ccBox.leadingAnchor constant:8],
        [dialCodeLbl.centerYAnchor  constraintEqualToAnchor:ccBox.centerYAnchor],

        [chevronIV.leadingAnchor  constraintEqualToAnchor:dialCodeLbl.trailingAnchor constant:4],
        [chevronIV.trailingAnchor constraintEqualToAnchor:ccBox.trailingAnchor constant:-8],
        [chevronIV.centerYAnchor  constraintEqualToAnchor:ccBox.centerYAnchor],
        [chevronIV.widthAnchor    constraintEqualToConstant:10],
        [chevronIV.heightAnchor   constraintEqualToConstant:10],

        [ccTapBtn.topAnchor      constraintEqualToAnchor:ccBox.topAnchor],
        [ccTapBtn.leadingAnchor  constraintEqualToAnchor:ccBox.leadingAnchor],
        [ccTapBtn.trailingAnchor constraintEqualToAnchor:ccBox.trailingAnchor],
        [ccTapBtn.bottomAnchor   constraintEqualToAnchor:ccBox.bottomAnchor],

        [phoneTF.leadingAnchor  constraintEqualToAnchor:ccBox.trailingAnchor constant:10],
        [phoneTF.trailingAnchor constraintEqualToAnchor:phoneBox.trailingAnchor constant:-12],
        [phoneTF.centerYAnchor  constraintEqualToAnchor:phoneBox.centerYAnchor],
    ]];

    // Email
    UIView *emailBox = [self su_makeFieldBox:fH radius:fR bg:fBg];
    [cv addSubview:emailBox];
    UITextField *emailTF = [self su_makeField:@"Email" inBox:emailBox];
    emailTF.keyboardType = UIKeyboardTypeEmailAddress;
    emailTF.autocapitalizationType = UITextAutocapitalizationTypeNone;
    emailTF.autocorrectionType = UITextAutocorrectionTypeNo;
    emailTF.returnKeyType = UIReturnKeyNext;
    self.txtEmail = emailTF;
    [self setupTextField:emailTF];
    [NSLayoutConstraint activateConstraints:@[
        [emailBox.topAnchor      constraintEqualToAnchor:phoneBox.bottomAnchor constant:gap],
        [emailBox.leadingAnchor  constraintEqualToAnchor:cv.leadingAnchor  constant:hP],
        [emailBox.trailingAnchor constraintEqualToAnchor:cv.trailingAnchor constant:-hP],
        [emailBox.heightAnchor   constraintEqualToConstant:fH],
    ]];

    // Referral description label
    UILabel *refDescLabel = [[UILabel alloc] init];
    refDescLabel.translatesAutoresizingMaskIntoConstraints = NO;
    refDescLabel.text = [LanguageHelper getStringWithKey:@"k_s10_referral_desc" defaultValue:@"Si tienes un código de Referido escríbelo aquí para continuar"];
    refDescLabel.font = FONTS_NOTO_REGULAR(14);
    if (!refDescLabel.font) refDescLabel.font = [UIFont systemFontOfSize:14];
    refDescLabel.textColor = [UIColor colorWithWhite:0.2f alpha:1];
    refDescLabel.numberOfLines = 0;
    [cv addSubview:refDescLabel];

    // Referral field
    UIView *refBox = [self su_makeFieldBox:fH radius:fR bg:fBg];
    [cv addSubview:refBox];
    UITextField *refTF = [self su_makeField:[LanguageHelper getStringWithKey:@"k_s10_referral_code_optional" defaultValue:@"Código de Referido (Opcional)"] inBox:refBox];
    refTF.returnKeyType = UIReturnKeyDone;
    self.txtReferral = refTF;
    [self setupTextField:refTF];

    [NSLayoutConstraint activateConstraints:@[
        [refDescLabel.topAnchor      constraintEqualToAnchor:emailBox.bottomAnchor constant:20],
        [refDescLabel.leadingAnchor  constraintEqualToAnchor:cv.leadingAnchor  constant:hP],
        [refDescLabel.trailingAnchor constraintEqualToAnchor:cv.trailingAnchor constant:-hP],

        [refBox.topAnchor      constraintEqualToAnchor:refDescLabel.bottomAnchor constant:8],
        [refBox.leadingAnchor  constraintEqualToAnchor:cv.leadingAnchor  constant:hP],
        [refBox.trailingAnchor constraintEqualToAnchor:cv.trailingAnchor constant:-hP],
        [refBox.heightAnchor   constraintEqualToConstant:fH],
    ]];

    // Referral section always visible

    // Terms row: checkbox + attributed text view
    UIButton *checkBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    checkBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [checkBtn setImage:[self su_checkboxImage:NO]  forState:UIControlStateNormal];
    [checkBtn setImage:[self su_checkboxImage:YES] forState:UIControlStateSelected];
    [checkBtn addTarget:self action:@selector(onTermsButtonTap:) forControlEvents:UIControlEventTouchUpInside];
    self.btnTerms = checkBtn;

    UITextView *termsTV = [[UITextView alloc] init];
    termsTV.translatesAutoresizingMaskIntoConstraints = NO;
    termsTV.editable = NO;
    termsTV.selectable = NO;
    termsTV.scrollEnabled = NO;
    termsTV.backgroundColor = [UIColor clearColor];
    termsTV.textContainerInset = UIEdgeInsetsZero;
    termsTV.textContainer.lineFragmentPadding = 0;
    termsTV.attributedText = [self formatViewDetailText:[LanguageHelper getStringWithKey:@"k_6_s12_i_read_and_agree"]];
    [termsTV addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapOnLabel:)]];
    self.txtTerms = termsTV;

    [cv addSubview:checkBtn];
    [cv addSubview:termsTV];

    UIView *termsAnchorView = refBox;
    [NSLayoutConstraint activateConstraints:@[
        [checkBtn.topAnchor     constraintEqualToAnchor:termsAnchorView.bottomAnchor constant:24],
        [checkBtn.leadingAnchor constraintEqualToAnchor:cv.leadingAnchor constant:hP],
        [checkBtn.widthAnchor   constraintEqualToConstant:28],
        [checkBtn.heightAnchor  constraintEqualToConstant:28],

        [termsTV.leadingAnchor  constraintEqualToAnchor:checkBtn.trailingAnchor constant:8],
        [termsTV.trailingAnchor constraintEqualToAnchor:cv.trailingAnchor constant:-hP],
        [termsTV.topAnchor      constraintEqualToAnchor:checkBtn.topAnchor],
        [termsTV.bottomAnchor   constraintEqualToAnchor:cv.bottomAnchor constant:-20],
    ]];

    // T&C always visible
}

- (UIView *)su_makeFieldBox:(CGFloat)height radius:(CGFloat)radius bg:(UIColor *)bg {
    UIView *box = [[UIView alloc] init];
    box.translatesAutoresizingMaskIntoConstraints = NO;
    box.backgroundColor = bg;
    box.layer.cornerRadius = radius;
    box.clipsToBounds = YES;
    return box;
}

- (UITextField *)su_makeField:(NSString *)placeholder inBox:(UIView *)box {
    UITextField *tf = [[UITextField alloc] init];
    tf.translatesAutoresizingMaskIntoConstraints = NO;
    tf.placeholder = placeholder;
    tf.font = FONTS_NOTO_REGULAR(15);
    if (!tf.font) tf.font = [UIFont systemFontOfSize:15];
    tf.textColor = [UIColor colorWithRed:40/255.0f green:40/255.0f blue:40/255.0f alpha:1.0f]; // #282828
    [box addSubview:tf];
    [NSLayoutConstraint activateConstraints:@[
        [tf.leadingAnchor  constraintEqualToAnchor:box.leadingAnchor  constant:16],
        [tf.trailingAnchor constraintEqualToAnchor:box.trailingAnchor constant:-16],
        [tf.centerYAnchor  constraintEqualToAnchor:box.centerYAnchor],
    ]];
    [self setTextFieldPlaceholderColor:tf];
    return tf;
}

- (void)handleTapOnLabel:(UITapGestureRecognizer *)gesture{
    UITextView *textView = (UITextView *)gesture.view;
    //    int tag = (int)[textView tag];
    NSLayoutManager *layoutManager = textView.layoutManager;
    CGPoint location = [gesture locationInView:textView];
    location.x -= textView.textContainerInset.left;
    location.y -= textView.textContainerInset.top;
    NSUInteger characterIndex;
    characterIndex = [layoutManager characterIndexForPoint:location
                                           inTextContainer:textView.textContainer
                  fractionOfDistanceBetweenInsertionPoints:NULL];
    
    if (characterIndex < textView.textStorage.length) {
        NSRange range;
        NSDictionary *attributes =
        [textView.textStorage attributesAtIndex:characterIndex
                                 effectiveRange:&range];
        if ([attributes objectForKey:@"object"]) {
            [self onTermsButtonnTap:NO];
        }else if ([attributes objectForKey:@"object2"]) {
            [self onTermsButtonnTap:YES];
        }
    }
}

- (void)onTermsButtonnTap:(BOOL)isPrivacy{
    AboutUsViewController *viewController=(AboutUsViewController *)[StoryBoardUtiles viewContollerInMainWithIdentifier:StoryBoardUtiles.ABOUT_US ];
    if(isPrivacy){
        viewController.customTitle=[LanguageHelper getStringWithKey:@"k_2_s4_privacy"];
        viewController.customUrl=[SettingsModel getSettignsObject].privacyUrl;
    }else{
        viewController.customTitle=[LanguageHelper getStringWithKey:@"k_6_s12_terms_and_conditions_title"];
        viewController.customUrl=[SettingsModel getSettignsObject].tnc;
    }
    viewController.isCustomUrl =YES;
    [self.navigationController pushViewController:viewController animated:YES];
    
}
- (UIImage *)su_checkboxImage:(BOOL)checked {
    CGFloat size = 28.0;
    UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:CGSizeMake(size, size)];
    return [renderer imageWithActions:^(UIGraphicsImageRendererContext *ctx) {
        CGContextRef c = ctx.CGContext;
        CGFloat stroke = 2.0;
        CGFloat radius = 8.0;
        CGFloat inset  = stroke / 2.0;
        CGRect  rect   = CGRectInset(CGRectMake(0, 0, size, size), inset, inset);

        UIBezierPath *box = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:radius];
        box.lineWidth = stroke;
        [[UIColor blackColor] setStroke];
        [UIColor.clearColor setFill];
        [box fill];
        [box stroke];

        if (checked) {
            UIBezierPath *tick = [UIBezierPath bezierPath];
            [tick moveToPoint:CGPointMake(size * 0.22, size * 0.50)];
            [tick addLineToPoint:CGPointMake(size * 0.43, size * 0.72)];
            [tick addLineToPoint:CGPointMake(size * 0.78, size * 0.28)];
            tick.lineWidth = stroke;
            tick.lineCapStyle  = kCGLineCapRound;
            tick.lineJoinStyle = kCGLineJoinRound;
            [[UIColor blackColor] setStroke];
            [tick stroke];
        }
        (void)c;
    }];
}

-(NSAttributedString *) formatViewDetailText:(NSString *)string{
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@""]];
    
    [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ ",string] attributes:@{ NSFontAttributeName:FONTS_THEME_REGULAR_NO_SCALE(14), NSForegroundColorAttributeName:[UIColor colorNamed:@"color_app_label"]}]];
    
    [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:[LanguageHelper getStringWithKey:@"k_6_s12_terms_and_conditions_title"] attributes:@{ NSFontAttributeName:FONTS_THEME_REGULAR_NO_SCALE(15), NSForegroundColorAttributeName:[UIColor blackColor], NSUnderlineStyleAttributeName:@(NSUnderlineStyleSingle), NSUnderlineColorAttributeName:[UIColor blackColor], @"object":@"viewDetails"}]];
    NSAttributedString * attrStrAnd = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@ ",[LanguageHelper getStringWithKey:@"k_2_s4_and"]] attributes:@{ NSFontAttributeName:FONTS_THEME_REGULAR_NO_SCALE(14), NSForegroundColorAttributeName:[UIColor colorNamed:@"color_app_label"]}];
    [attributedString appendAttributedString:attrStrAnd];
    [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:[LanguageHelper getStringWithKey:@"k_2_s4_privacy"] attributes:@{ NSFontAttributeName:FONTS_THEME_REGULAR_NO_SCALE(15), NSForegroundColorAttributeName:[UIColor blackColor], NSUnderlineStyleAttributeName:@(NSUnderlineStyleSingle), NSUnderlineColorAttributeName:[UIColor blackColor], @"object2":@"viewDetails2"}]];
    return attributedString;
}

@end

