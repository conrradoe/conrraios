//
//  ForgotPasswordViewController.m
//  Store_project
//
//  Created by  Appicial on 22/05/17.
//  Copyright © 2023 Appicial. All rights reserved.
//

#import "ForgotPasswordViewController.h"
#import "WebCallConstants.h"
#import <GIKit/GIKit.h>
#import "AFHTTPSessionManager.h"
#import "Utilities.h"
#import "OTPVerifyViewController.h"
#import "NIDropDown.h"
#import "AppDelegate.h"
#import <objc/runtime.h>
#import "CounrySelectionView.h"
#import "ConstantModel.h"
#import "UIView+UpdateAutoLayoutConstraints.h"
@interface ForgotPasswordViewController ()<NIDropDownDelegate,CounrySelectionViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *btContainer;

@end

@implementation ForgotPasswordViewController
{
    int smsCode;
    NSDictionary * dictUserRestPassword;
    NSDictionary * countrySelected;
//    NSString * countryDialCodeSelected;
    NIDropDown *dropDown;
//    CityModel *cityModel;
    ConstantModel *  constantTaxiModel;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    constantTaxiModel =[ConstantModel getConstantsObject];
    // Do any additional setup after loading the view.
    [self setUIFiels];
    self.txtEmail.delegate=self;
    [self.btReset.layer  setCornerRadius:5];
    [self.btContainer.layer  setCornerRadius:5];
    [self setThemeConstants];
    [self setupTextField:self.txtEmail];
    if(IS_PHONE_VERIFICATION==1)
    {
        self.lbEmailTitle.text=[LanguageHelper getStringWithKey:@"k_r1_s4_mob_no"];
        self.txtEmail.placeholder=[LanguageHelper getStringWithKey:@"k_r6_s2_enter_mob_no"];
        self.lblRestore.text=@"*Reset your password via mobile number";
        self.lbCountryDialCode.attributedText=[CounrySelectionView getCurrentCountry];
        int width = [self.lbCountryDialCode.attributedText size].width+20;
        [self.lbCountryDialCode setConstraintConstant:width forAttribute:NSLayoutAttributeWidth];
            countrySelected=[CounrySelectionView getCurrentCountryDict];

         self.consLeading.constant=10+85;
    }else
    {
        self.btCountry.hidden=YES;
        self.imgeCountry.hidden=YES;
        self.lbCountryDialCode.hidden=YES;
    }
}


-(void)setUIFiels{
    
    self.lblHeader.text = [LanguageHelper getStringWithKey:@"k_1_s3_forgot_password"];
    self.lbEmailTitle.text = [LanguageHelper getStringWithKey:@"k_13_s1_email"];
    self.txtEmail.placeholder=[LanguageHelper getStringWithKey:@"k_6_s3_email_address"];
    self.lbCountryDialCode.text = [LanguageHelper getStringWithKey:@"k_15_s3_select_country_code"];
    self.lblRestore.text = [LanguageHelper getStringWithKey:@"k_5_s3_restore_your_password_via_emai"];
    [self.btnDone setTitle: [LanguageHelper getStringWithKey:@"k_19_s3_done"]   forState:UIControlStateNormal];
    [self.btnResetPassword setTitle: [LanguageHelper getStringWithKey:@"k_4_s3_reset_password"]   forState:UIControlStateNormal];

}



-(void)setThemeConstants{
 
    [_lblHeader setFont:FONTS_THEME_REGULAR(18)];
    [_btnResetPassword.titleLabel setFont:FONTS_THEME_REGULAR(18)];
    [_txtEmail setFont:FONTS_THEME_REGULAR(16)];
    [_lblRestore setFont:FONTS_THEME_REGULAR(12)];
    
}

-(void)setupTextField:(UITextField*)textField{
    textField.delegate=self;
    [self setTextFieldPlaceholderColor:textField];
    
}




- (IBAction)ButtonResetPasswordPressed:(id)sender {
    if(IS_PHONE_VERIFICATION==1) {
        [self ButtonPhoneResetPasswordPressed:sender];
        return;
    }
    if (![UtilityClass validateEmailWithString:_txtEmail.text ]){
        [Utilities showAlertwithTilte:[LanguageHelper getStringWithKey:@"k_23_s3_warning"] message:[LanguageHelper getStringWithKey:@"k_14_s3_plz_enter_valid_email"] viewController:self ];
    }
    else{
        [UtilityClass setLH:NO wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
        NSDictionary *dict = @{P_EMAIL:_txtEmail.text, };
        [GIC mkwerwu:DRIVER_CHANGE_PASSWORD
                      d:dict
                  cb:^(id results, NSError *error) {
            [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
               if ([[results objectForKey:P_STATUS] isEqualToString:@"OK"]) {
                   [self showAlertWithOk:@"" message:[LanguageHelper getStringWithKey:@"k_24_s3_forgot_password_link"] handler:^(UIAlertAction * _Nonnull action) {
                       
                   }];
               }else  {
                   [Utilities handleError:error viewController:self defaultMessage:@""];
               }
           }];
    }
}





- (IBAction)ButtonPhoneResetPasswordPressed:(id)sender {
    
    [self.view endEditing:YES];
    NSString *mobileNumberCleaned = [Utilities removeAllLeadingZero:self.txtEmail.text ];
    if (countrySelected==nil){
        [Utilities showAlertwithTilte:[LanguageHelper getStringWithKey:@"k_23_s3_warning"] message:[LanguageHelper getStringWithKey:@"k_10_s1_plz_sel_country_code"] viewController:self ];
    }
    else if (mobileNumberCleaned.length<constantTaxiModel.min_phone_length){
        [Utilities showAlertwithTilte:[LanguageHelper getStringWithKey:@"k_23_s3_warning"] message:[LanguageHelper getStringWithKey:@"k_21_s2_plz_enter_valid_mobile_number"] viewController:self ];
    }
//    else   if (cityModel==nil){
//        [Utilities showAlertwithTilte:[LanguageHelper getStringWithKey:@"k_23_s3_warning"] message:[LanguageHelper getStringWithKey:@"k_10_s1_plz_sel_country_code"] viewController:self ];
//    }
    else{
        NSString *countryCode = [Utilities removePlusBeforeNumber:[countrySelected objectForKey:@"dial_code"] ];
        [UtilityClass setLH:NO wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
        NSDictionary *dict = @{P_MOBILE:mobileNumberCleaned /*,P_CITY_ID:[NSString stringWithFormat:@"%d",cityModel.city_id] */,  P_C_CODE: isEmpty(countryCode),};
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        [manager POST:[NSString stringWithFormat:@"%@%@",BASE_URL_DRIVER,USER_VALIDATE] parameters:dict  success:^(NSURLSessionTask *task, id responseObject) {
            if ([[responseObject objectForKey:P_STATUS] isEqualToString:@"Error"]||[[responseObject objectForKey:P_STATUS] isEqualToString:@" Error"]) {
                NSObject * response=[responseObject objectForKey:@"response"];
                if([response isKindOfClass:[NSDictionary class]])
                {
                    self->dictUserRestPassword=(NSDictionary *)response;
                    [self verifyMobileNo];
                }else{
                    [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
                    [Utilities showAlertwithTilte:[LanguageHelper getStringWithKey:@"k_23_s3_warning"] message:[LanguageHelper getStringWithKey:@"k_17_s3_phone_number_does_not_exists"] viewController:self ];
                }
            }
            else if ([[[responseObject objectForKey:P_STATUS]  uppercaseString] isEqualToString:@"OK"]||[[responseObject objectForKey:P_STATUS] isEqualToString:@" OK"]) {
                
                NSObject * response=[responseObject objectForKey:@"response"];
                if([response isKindOfClass:[NSDictionary class]])
                {
                    self->dictUserRestPassword=(NSDictionary *)response;
                    [self verifyMobileNo];
                }else{
                    [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
                    [Utilities showAlertwithTilte:[LanguageHelper getStringWithKey:@"k_23_s3_warning"] message:[LanguageHelper getStringWithKey:@"k_17_s3_phone_number_does_not_exists"] viewController:self ];
                }
            }else
            {
                [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
                [Utilities showAlertwithTilte:[LanguageHelper getStringWithKey:@"k_23_s3_warning"] message:[LanguageHelper getStringWithKey:@"k_17_s3_phone_number_does_not_exists"] viewController:self ];
            }
            
        } failure:^(NSURLSessionTask *operation, NSError *error) {
            NSData *data=[error.userInfo objectForKey:AppKeysName.ERROR_DATA];
            NSError* errorJson;
            NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data
                                                                 options:kNilOptions
                                                                   error:&errorJson];
            [Utilities showAlertwithTilte:[LanguageHelper getStringWithKey:@"k_23_s3_warning"] message:[NSString stringWithFormat:@"%@",json] viewController:self ];
            [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
        }];
    }
}

-(void)verifyMobileNo{
    
    
        smsCode = [Utilities getRandomNumberBetween:1000 to:9999];
    
    ConstantModel *consModel=[ConstantModel getConstantsObject];
    if(consModel.otp_off){
        [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
        [self sendMeToVerificationView];
        return ;
    }
    NSString *otpMessage =[Utilities formatOtpMessageWithOtp:smsCode isResetPassword:YES];
    NSString *phoneNum = [Utilities removeAllLeadingZero:self.txtEmail.text];
    
    NSString *countryCode = [Utilities removePlusBeforeNumber:[countrySelected objectForKey:@"dial_code"]];
    phoneNum = [NSString stringWithFormat:@"%@%@",countryCode,phoneNum];
    NSDictionary *dict = @{
        @"msg": otpMessage,
        @"ph" : phoneNum
    };
    
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
               [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
               [Utilities showAlertwithTilte:[LanguageHelper getStringWithKey:@"k_33_s7_alert"] message:[LanguageHelper getStringWithKey:@"k_17_s3_phone_number_does_not_exists"] viewController:self];
           }
       }];
}

-(void)sendMeToVerificationView{
    OTPVerifyViewController *vc = (OTPVerifyViewController *)[StoryBoardUtiles viewContollerWithIdentifier:StoryBoardUtiles.OTP_VERIFY name:StoryBoardUtiles.STORYBOARD_SIGNUP];
    vc.usersigmUpDict =  dictUserRestPassword;
    vc.verificationCode = smsCode;
    NSString *countryCode = [Utilities removePlusBeforeNumber:[countrySelected objectForKey:@"dial_code"] ];
    vc.countryDialCode=countryCode;
    vc.isRestPassword=YES;
    
    
    NSString *phoneNum = [self.txtEmail.text stringByTrimmingCharactersInSet:
                          [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if([phoneNum hasPrefix:@"0"])
    {
        phoneNum = [phoneNum substringFromIndex:1];
    }
    phoneNum = [NSString stringWithFormat:@"%@%@",countryCode,phoneNum];
    vc.phoneNum=phoneNum;
    vc.modalPresentationStyle=UIModalPresentationFullScreen;
    [self presentViewController:vc animated:YES completion:nil];
//    [self.navigationController pushViewController: vc animated:YES];
}

- (IBAction)ButtonBackAction:(id)sender {
   
    [self dismissViewControllerAnimated:YES completion:nil];
}
    
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
        [textField resignFirstResponder];
        return YES;
    }


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if(IS_PHONE_VERIFICATION==1)
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
    return YES;
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


- (void) niDropDownDelegateMethod: (NIDropDown *) sender index:(int) index  result:(id) resullt
{
//    cityModel=(CityModel *)resullt tyModel.country_code];
    dropDown=nil;
}



@end
