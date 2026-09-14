//
//  UAddMoneyWalletVC.m
//  HireMe Rider
//
//  Created by Grepix Infotech on 27/11/18.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import "UAddMoneyWalletVC.h"
#import <GIKit/GIKit.h>
#import "WebCallConstants.h"
#import "AppDelegate.h"
#import "UWalletTableViewCell.h"
#import "MainViewController.h"
#import "HomeViewController.h"
#import "WalletInfo.h"
#import "AddMoneyInfo.h"
#import "PaymentMethodListViewController.h"
#import "Utilities.h"
#import "ConstantModel.h"
#import <Conrra-Swift.h>
#import "UserProfile.h"
@interface UAddMoneyWalletVC ()<UITextViewDelegate,PaymentMethodListViewControllerDelegate,UITextFieldDelegate>
{
}
@end

@implementation UAddMoneyWalletVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.enterAmountTextField.delegate = self;
    [self.viewAmount.layer setCornerRadius:3];
    [self.viewAmount setClipsToBounds:YES];
    [self.viewAmount.layer setBorderWidth:1];
    [self.viewAmount.layer setBorderColor:RGB(126, 126, 126).CGColor];
    
    [self.viewDesc.layer setCornerRadius:3];
    [self.viewDesc setClipsToBounds:YES];
    [self.viewDesc.layer setBorderWidth:1];
    [self.viewDesc.layer setBorderColor:RGB(126, 126, 126).CGColor];
    self.addAmountDesc.text=[LanguageHelper getStringWithKey:@"k_3_s5_desc"];
    self.addAmountDesc.delegate=self;
    [self setUIFields];
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (textField ==self.enterAmountTextField && textField.text.length >= 5 && range.length == 0)  {
        return NO; // return NO to not change text
    }
    return YES;
}

-(void) setUIFields{
    
    self.lblHeader.text = [LanguageHelper getStringWithKey:@"k_4_s10_add_money"];
    self.enterAmountTextField.placeholder=[LanguageHelper getStringWithKey:@"k_3_s5_amount"];

   [self.btnAddMoney setTitle: [LanguageHelper getStringWithKey:@"k_3_s5_add_money"]   forState:UIControlStateNormal];
   
    
}

- (void)textViewDidBeginEditing:(UITextView *)textView{
    
    if(textView==self.addAmountDesc)  {
        if([self.addAmountDesc.text isEqualToString:[LanguageHelper getStringWithKey:@"k_3_s5_desc"]])
        {
            self.addAmountDesc.text=@"";
        }
    }
    
}



- (void)textViewDidEndEditing:(UITextView *)textView{
    if(textView==self.addAmountDesc) {
        if(textView.text.length==0)   {
            self.addAmountDesc.text=[LanguageHelper getStringWithKey:@"k_3_s5_desc"];
        }
    }
}

- (void)viewDidLayoutSubviews {
    [self.addAmountDesc setContentOffset:CGPointZero animated:NO];
}

-(void)addMoneyToWallet{
    NSString * desc=self.addAmountDesc.text ;
    if([self.addAmountDesc.text isEqualToString:[LanguageHelper getStringWithKey:@"k_3_s5_desc"]]){
        desc=@"";
    }
    NSDictionary *dict1 = [[NSUserDefaults standardUserDefaults]objectForKey:P_USER_DICT_LOGGED];
    NSMutableDictionary *addMoneyDict = [NSMutableDictionary dictionaryWithDictionary:@{
        @"user_id":[dict1 objectForKey:P_USER_ID],
        @"total_amt":[NSString stringWithFormat:@"%@",self.enterAmountTextField.text],
        @"city_id":@([[UserProfile shared] cityID]),
        @"trans_description":desc,
    }];
    CityModel * cityModel=[CityModel getCityByCityId:[UserProfile shared].loggedCityID];
    if(addMoneyDict){
        [addMoneyDict setObject:isEmpty(cityModel.city_cur) forKey:@"currency"];
    }
    [UtilityClass setLH:NO wt:[LanguageHelper getStringWithKey:@"k_53_s3_please_wait"]];
    [GIC mkwerwu:GET_WALLET_ADD_TRAN_WITHOUT_TRIP
                                    d:addMoneyDict
                         cb:^(id results, NSError *error) {
        [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_53_s3_please_wait"]];
        if(error!=nil)
        {
            [Utilities handleError:error viewController:self defaultMessage:@""];
            return;
        }
        if ([[results objectForKey:P_STATUS] isEqualToString:@"OK"]) {
            // success
            if ([[results objectForKey:P_RESPONSE] isKindOfClass:[NSDictionary class]]) {
                [self showAlertAndGoBack];
            }else {
            }
        }
    }];
}
-(void) showAlertAndGoBack
{
    [self showAlertWithOk:[LanguageHelper getStringWithKey:@"k_33_success"] message:[LanguageHelper getStringWithKey:@"k_1_s18_success_add_mney"] handler:^(UIAlertAction * _Nonnull action) {
        if(self.delegate)
        {
            [self.delegate monyAddSucessfully];
        }
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)addMoneyClicked:(id)sender {
    [self.view endEditing:YES];
    if([self.enterAmountTextField.text floatValue]<=0)
    {
        [self showAlertWithMessgae:[LanguageHelper getStringWithKey:@"k_r1_s6_please_enter_amount"]];
        return;
    }
    PaymentMethodListViewController * vc=[self.storyboard instantiateViewControllerWithIdentifier:@"PaymentMethodListViewController"];
    vc.delegate=self;
    vc.isFromPaymentJob=YES;
    [self.navigationController pushViewController:vc animated:YES];
}

-(void) onPaymentMethodSelected:(NSString *) paymentMethodType viewControlllor:(PaymentMethodListViewController*)viewControlllor
{
    
}
-(void) onPaymentIntentSelected:(NSString *) paymentMethod dict:(NSDictionary *) dict viewControlllor:(PaymentMethodListViewController*)viewControlllor
{
    int price =(int)([self.enterAmountTextField.text floatValue])*100;
    [self createStripUserCreatePaymentIntentDone:price paymentMethod:paymentMethod];
}


-(void) createStripUserCreatePaymentIntentDone:(int )amount paymentMethod:(NSString *)paymentMethod
{
    NSArray * arr = defaults_object(@"constantResponse");
    ConstantModel * constantModel =[[ConstantModel alloc]initItemWithDict:arr];
    NSDictionary *dict1 = [[NSUserDefaults standardUserDefaults]objectForKey:P_USER_DICT_LOGGED];
    [UtilityClass setLH:NO wt:[LanguageHelper getStringWithKey:@"k_53_s3_please_wait"]];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    CityModel *cModel=[CityModel getCityByCityId:[UserProfile shared].cityID];
    NSURLCredential *credential = [NSURLCredential credentialWithUser:isEmpty(constantModel.stripe_s_key)/*STRIPE_SECRET_KEY*/ password:@"" persistence:NSURLCredentialPersistenceNone];
    NSString * stripeCustomerId = isEmpty([ConstantModel getConstantsObject].is_stripe_live?[dict1 objectForKey:P_STRIPE_CUS_ID]:[dict1 objectForKey:P_STRIPE_DEV_CUS_ID]);
    if([ConstantModel getConstantsObject].is_stripe_live==NO){
        if(stripeCustomerId){
#if TARGET_OS_SIMULATOR
            stripeCustomerId = P_STRIPE_CUS_DEV_CUS_ID;
#else

#endif
        }
        
    }
    NSDictionary *parameters = @{@"amount": [NSString stringWithFormat:@"%d",amount],@"currency":isEmpty(cModel.pg_cur),@"payment_method":paymentMethod,@"statement_descriptor_suffix":[NSString stringWithFormat:@"%@",@"Wallet"],@"off_session":@"true",@"confirm":@"true",@"customer": stripeCustomerId};
    NSMutableURLRequest *request= [manager.requestSerializer requestWithMethod:@"POST" URLString:@"https://api.stripe.com/v1/payment_intents" parameters:parameters error:nil];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCredential:credential];
    [operation setResponseSerializer:[AFJSONResponseSerializer alloc]];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Success: %@", responseObject);
        NSDictionary * error=[responseObject objectForKey:@"error"];
        [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_53_s3_please_wait"]];
        if(error==nil)
        {
            [self addMoneyToWallet];
        }else{
            [self showAlertWithMessgae:isEmpty([error objectForKey:@"message"])];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Failure: %@", error);
        [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_53_s3_please_wait" defaultValue:@"Please wait..."]];
        [self showAlertWithMessgae:error.localizedDescription ?: @""];
    }];
    [manager.operationQueue addOperation:operation];
}
@end

