//
//  PayoutViewController.m

//
//  Created by Grepix Infotech on 26/11/18.
//  Copyright © 2023 Grepixit. All rights reserved.
//
#import "AskLast4DigitDeleteVC.h"
#import "AppDelegate.h"
#import "Utilities.h"
#import "CityModel.h"
@interface AskLast4DigitDeleteVC ()<OTPFieldViewDelegate>{
    NSMutableArray *walletTranArray;
    NSString  *crStr;
    BOOL isStopTripCall;
    BOOL isAlreadyRequested;
    
}

@end

@implementation AskLast4DigitDeleteVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUIFields];
    
    walletTranArray  = [[NSMutableArray alloc]  init];
    self.txtTripOTP.fieldsCount = 4;
    self.txtTripOTP.fieldBorderWidth = 1;
    self.txtTripOTP.fieldSize=46;
    self.txtTripOTP.defaultBorderColor=[UIColor colorNamed:@"app_theame"];
    self.txtTripOTP.filledBorderColor=[UIColor colorNamed:@"app_theame"];
    self.txtTripOTP.displayType=DisplayTypeRoundedCorner;
    self.txtTripOTP.separatorSpace=10;
    self.txtTripOTP.fieldFont = FONTS_THEME_BOLD(23);
    self.txtTripOTP.delegate=self;
    [self.txtTripOTP initializeUI];
    [((OTPTextField *)[self.txtTripOTP viewWithTag:1]) becomeFirstResponder];
}



-(void)enteredOTPWithOtp:(NSString *)otp{
//    [self validateOTP:otp];
}

-(BOOL)shouldBecomeFirstResponderForOTPWithOtpTextFieldIndex:(NSInteger)index{
    return YES;
}

-(BOOL)hasEnteredAllOTPWithHasEnteredAll:(BOOL)hasEnteredAll{
    return hasEnteredAll;
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    [self setUIFields];
}



-(void) setUIFields{
    self.lblTollCharge.text = [LanguageHelper getStringWithKey:@"k_s7_mo_verfy"  ];
    [self.btnTollAdd setTitle:[LanguageHelper getStringWithKey:@"k_s7_verfy"]  forState:UIControlStateNormal];
    NSString *htmlString=[LanguageHelper getStringWithKey:@"k_s7_ms_last4"];
    htmlString= [NSString stringWithFormat:@"<span style='font-family: \"-apple-system\", \"Karla\"; font-size: 19px' >%@</span>",htmlString];
    NSAttributedString * attrStr = [[NSAttributedString alloc] initWithData:[htmlString dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
    self.lblTollAmountText.attributedText = attrStr;
    self.lblTollAmountText.textColor = [UIColor colorNamed:@"color_app_label"];
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
    [self.view endEditing:YES];
    NSString * otp1=((OTPTextField *)[self.txtTripOTP viewWithTag:1]).text;
    NSString * otp2=((OTPTextField *)[self.txtTripOTP viewWithTag:2]).text;
    NSString * otp3=((OTPTextField *)[self.txtTripOTP viewWithTag:3]).text;
    NSString * otp4=((OTPTextField *)[self.txtTripOTP viewWithTag:4]).text;
    NSString *enteredOtp=[NSString stringWithFormat:@"%@%@%@%@",otp1,otp2,otp3,otp4];
    if([enteredOtp intValue]<=0){
        [self showAlertWithMessgae:[LanguageHelper getStringWithKey:@"k_s7_vld_last4"]];
        return;
    }
    [self dismissViewControllerAnimated:YES completion:^{
        [self.delegate onOtpEnteredForBegin:enteredOtp];
    }];
}
 
- (IBAction)onCancelButtonTap:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


+(AskLast4DigitDeleteVC *) openWithViewController:(UIViewController *)viewController {
    AskLast4DigitDeleteVC *vc=(AskLast4DigitDeleteVC *)[StoryBoardUtiles viewContollerWithIdentifier:@"AskLast4DigitDeleteVC" name:@"ExtraFeature"];
    vc.modalPresentationStyle=UIModalPresentationOverCurrentContext;
    vc.modalTransitionStyle=UIModalTransitionStyleCrossDissolve;
    [viewController presentViewController:vc animated:YES completion:^{
      
    }];
    return  vc;
}

@end
