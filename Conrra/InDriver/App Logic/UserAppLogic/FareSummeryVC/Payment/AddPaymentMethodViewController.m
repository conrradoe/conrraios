//
//  LanguageViewController.m
//  JS Rider
//
//  Created by Devineer on 25/06/18.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import "AddPaymentMethodViewController.h"
#import "PaymentTableViewCell.h"
#import <GIKit/GIKit.h>
#import "WebCallConstants.h"
#import "AppDelegate.h"
#import "ConstantModel.h"
#import "LanguageHelper.h"

@interface AddPaymentMethodViewController ()<STPAuthenticationContext>
{
}

@end

@implementation AddPaymentMethodViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if(self.isFromRideLoginAddMethod)  {
        self.btnBackButton.hidden=YES;
    }
    self.lblHeaderTitle.text =[LanguageHelper getStringWithKey:@"k_r35_s1_add_payment_method" defaultValue:@"Add Payment Method"];
    if([ConstantModel getConstantsObject].is_stripe_live){
        [self.viewTestCardDetails setHidden:YES];
    }else{
        [self.viewTestCardDetails setHidden:NO];
    }
    // Do any additional setup after loading the view.
    self.lblHeaderTitle.text =[LanguageHelper getStringWithKey:@"k_r35_s1_add_payment_method" defaultValue:@"Add Payment Method"];
    self.lblTestCardDetails.text=[LanguageHelper getStringWithKey:@"k_s12_test_crd_dts" defaultValue:@"Test Card Details"];
    self.lblCardNumber.text=[LanguageHelper getStringWithKey:@"k_s12_test_crd_cnum" defaultValue:@"Card Number"];
    self.lblExpiry.text=[LanguageHelper getStringWithKey:@"k_s12_test_crd_expry" defaultValue:@"Expiry:"];
    self.lblCVV.text=[LanguageHelper getStringWithKey:@"k_s12_test_crd_cvv" defaultValue:@"CVV:"];
    self.lblPinCode.text=[LanguageHelper getStringWithKey:@"k_s12_test_crd_pin" defaultValue:@"Pincode"];
    [self.btnAdd setTitle:[LanguageHelper getStringWithKey:@"k_r35_s1_continue"] forState:UIControlStateNormal];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */



- (IBAction)ButtonBackPressed:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}




- (IBAction)onAddCardButtonTap:(id)sender {
    if(self.cardDetail.isValid)
    {
        [self createStripUserCreatePaymentIntent];
    }else{
        [UtilityClass swa:@"Alert!" m:@"Invalid card details." cbt:@"Ok" obt:nil vc:self];
    }
}


-(void) createStripUserCreatePaymentIntent
{
    
    [UtilityClass setLH:NO wt:[LanguageHelper getStringWithKey:@"k_53_s3_please_wait" defaultValue:@"Please wait..."]];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSURLCredential *credential = [NSURLCredential credentialWithUser:isEmpty([ConstantModel getConstantsObject].stripe_s_key)/*STRIPE_SECRET_KEY*/ password:@"" persistence:NSURLCredentialPersistenceNone];
    NSDictionary *parameters = @{/*@"amount": Default_ADD_CARD_MONEY,@"currency":@"eur",*/@"payment_method_types[]":@"card"};
    NSMutableURLRequest *request= [manager.requestSerializer requestWithMethod:@"POST" URLString:@"https://api.stripe.com/v1/setup_intents" parameters:parameters error:nil];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCredential:credential];
    [operation setResponseSerializer:[AFJSONResponseSerializer alloc]];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Success: %@", responseObject);
        NSDictionary * error=[responseObject objectForKey:@"error"];
        if(error==nil)
        {
            [self submitPayment:[responseObject objectForKey:@"client_secret"] ];
        }else{
            [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_53_s3_please_wait" defaultValue:@"Please wait..."]];
            [UtilityClass swa:@"Payment failed!" m: isEmpty([error objectForKey:@"message"]) cbt:@"Ok" obt:nil vc:self];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Failure: %@", error);
        [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_53_s3_please_wait" defaultValue:@"Please wait..."]];
    }];
    [manager.operationQueue addOperation:operation];
}



-(void) submitPayment:(NSString * )clentSecretKey
{
    STPPaymentMethodCardParams *cardParams = self.cardDetail.cardParams;
    STPPaymentMethodParams *paymentMethodParams = [STPPaymentMethodParams paramsWithCard:cardParams billingDetails:nil metadata:nil];
    
    STPPaymentIntentParams *paymentIntentParams = [[STPPaymentIntentParams alloc] initWithClientSecret:clentSecretKey];
    paymentIntentParams.paymentMethodParams = paymentMethodParams;
    paymentIntentParams.setupFutureUsage = @(STPPaymentIntentSetupFutureUsageOffSession);
    
    STPSetupIntentConfirmParams *setupIntentParams = [[STPSetupIntentConfirmParams alloc] initWithClientSecret:clentSecretKey];
    setupIntentParams.paymentMethodParams = paymentMethodParams;
    //      setupIntentParams.setupFutureUsage = @(STPPaymentIntentSetupFutureUsageOffSession);
    // Submit the payment
    STPPaymentHandler *paymentHandler = [STPPaymentHandler sharedHandler];
    
    [paymentHandler confirmSetupIntent:setupIntentParams withAuthenticationContext:self completion:^(STPPaymentHandlerActionStatus status, STPSetupIntent *setupIntent, NSError *error) {
        switch (status) {
            case STPPaymentHandlerActionStatusFailed: {
                [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_53_s3_please_wait" defaultValue:@"Please wait..."]];
                [UtilityClass swa:@"Payment failed!" m:error.localizedDescription ?: @"" cbt:@"Ok" obt:nil vc:self];
                break;
            }
            case STPPaymentHandlerActionStatusCanceled: {
                // Setup canceled
                [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_53_s3_please_wait" defaultValue:@"Please wait..."]];
                [UtilityClass swa:@"Payment canceled" m:error.localizedDescription ?: @"" cbt:@"Ok" obt:nil vc:self];
                break;
            }
            case STPPaymentHandlerActionStatusSucceeded: {
                // Setup succeeded
                [self addStripUser:setupIntent.paymentMethodID ];
                break;
            }
            default:
                break;
        }
    }];
}


-(void) showAlertAddedWithPaymentMethod:(NSString *) paymentMethodId
{
    if(self.isFromRideLoginAddMethod)
    {
        [self updateDefaultPaymentMethod:paymentMethodId];
        return;
    }
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:[LanguageHelper getStringWithKey:@"k_33_success"]
                                 message:[LanguageHelper getStringWithKey:@"k_r35_s1_payment_method_added_success"]
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    //Add Buttons
    
    UIAlertAction* yesButton = [UIAlertAction
                                actionWithTitle:@"Ok"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action) {
        //Handle your yes please button action here
        
        [self.navigationController popViewControllerAnimated:YES];
    }];
    [alert addAction:yesButton];
    [self presentViewController:alert animated:YES completion:nil];
}





-(void) addStripUser:(NSString *) paymentMethodId{
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *WalletAmtDict = [[NSUserDefaults standardUserDefaults]objectForKey:P_USER_DICT_LOGGED];
    ConstantModel *constModel=[ConstantModel getConstantsObject];
    NSURLCredential *credential = [NSURLCredential credentialWithUser:isEmpty([ConstantModel getConstantsObject].stripe_s_key)  password:@"" persistence:NSURLCredentialPersistenceNone];
    NSString * stripeCustomerId = isEmpty(constModel.is_stripe_live?[WalletAmtDict objectForKey:P_STRIPE_CUS_ID]:[WalletAmtDict objectForKey:P_STRIPE_DEV_CUS_ID]);
    if([ConstantModel getConstantsObject].is_stripe_live==NO){
        if(stripeCustomerId){
#if TARGET_OS_SIMULATOR
            stripeCustomerId = P_STRIPE_CUS_DEV_CUS_ID;
#else

#endif
        }
        
    }
    NSDictionary *parameters = @{@"customer":stripeCustomerId};
    NSString * urlForSave=[NSString stringWithFormat:@"https://api.stripe.com/v1/payment_methods/%@/attach",paymentMethodId];
    NSMutableURLRequest *request= [manager.requestSerializer requestWithMethod:@"POST" URLString:urlForSave parameters:parameters error:nil];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCredential:credential];
    [operation setResponseSerializer:[AFJSONResponseSerializer alloc]];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Success: %@", responseObject);
        [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_53_s3_please_wait" defaultValue:@"Please wait..."]];
        NSDictionary * error=[responseObject objectForKey:@"error"];
        if(error==nil)
        {
            [self showAlertAddedWithPaymentMethod:paymentMethodId];
        }else{
            [UtilityClass swa:@"Add card failed!" m: isEmpty([error objectForKey:@"message"]) cbt:@"Ok" obt:nil vc:self];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Failure: %@", error);
        [UtilityClass swa:@"Error!" m:@"Error " cbt:@"Ok" obt:nil vc:self];
        [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_53_s3_please_wait" defaultValue:@"Please wait..."]];
    }];
    [manager.operationQueue addOperation:operation];
}

# pragma mark STPAuthenticationContext
- (UIViewController *)authenticationPresentingViewController {
    return self;
}


-(void)updateDefaultPaymentMethod:(NSString  *)paymentMethodId{
    NSDictionary *dict1 = [[NSUserDefaults standardUserDefaults]objectForKey:P_USER_DICT_LOGGED];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{
        P_USER_ID       :[dict1 objectForKey:P_USER_ID],
        P_USER_DEFAULT_PAY_METHOD        :isEmpty(paymentMethodId),
    }];
    [UtilityClass setLH:NO wt:[LanguageHelper getStringWithKey:@"k_53_s3_please_wait" defaultValue:@"Please wait..."]];
    [GIC mkwu:UPDATE_USER_PROFILE  d:dict  isa:NO cb:^(id results, NSError *error) {
        [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_53_s3_please_wait" defaultValue:@"Please wait..."]];
        if ([[results objectForKey:P_STATUS] isEqualToString:@"OK"]) {
            defaults_set_object(P_USER_DICT_LOGGED,[results objectForKey:P_RESPONSE]);
            UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:[LanguageHelper getStringWithKey:@"k_33_success" defaultValue:@"Success"] message:[LanguageHelper getStringWithKey:@"k_r35_s1_payment_method_added_success" defaultValue:@"Payment method updated."] preferredStyle:UIAlertControllerStyleAlert];
            [actionSheet addAction:[UIAlertAction actionWithTitle:[LanguageHelper getStringWithKey:@"k_18_s4_Ok" defaultValue:@"Ok"] style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                [self.navigationController popViewControllerAnimated:NO];
            }]];
            [self presentViewController:actionSheet animated:YES completion:nil];
        }
    }];
}

@end
