//
//  PayoutViewController.m

//
//  Created by Grepix Infotech on 26/11/18.
//  Copyright © 2023 Grepixit. All rights reserved.
//
#import "PayoutViewController.h"
#import "AppDelegate.h"
#import "Utilities.h"
#import "CityModel.h"
#import "UserProfile.h"
@interface PayoutViewController ()<UITextFieldDelegate>{
    NSMutableArray *walletTranArray;
    NSString  *crStr;
    BOOL isStopTripCall;
    BOOL isAlreadyRequested;
//    NSString *currency;
    
}

@end

@implementation PayoutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.txtPayoutAmt.delegate=self;
    [self setTextFieldPlaceholderColor:self.txtPayoutAmt];
    self.viewLastRequest.hidden=YES;
    [self setUIFields];
    [self roundViewWithBorder:self.txtPayoutAmt];
//    currency=@"";
    walletTranArray  = [[NSMutableArray alloc]  init];
//    NSDictionary *dictDriver = defaults_object(P_USER_DICT);
//    CityModel * cityModel=[CityModel getCityByCityId:[UserProfile shared].cityID];
//    if(cityModel){
//        currency=cityModel.city_cur;
//    }
//    if([[dictDriver objectForKey: P_DRIVER_WAlLET_AMOUNT] floatValue ]<0){
//        self.walletAmountLbl.textColor=[UIColor redColor];
//    }else  {
//        self.walletAmountLbl.textColor=RGB(34,139,34);
//    }
//    self.walletAmountLbl.text = [NSString stringWithFormat:@"%@%@",isEmpty(currency),[dictDriver objectForKey: P_DRIVER_WAlLET_AMOUNT]];
//    [self changeIconOnButton:self.btnBack];
    [self showWalletBalance];
}

-(void) showWalletBalance{
    BOOL is_user_login = [defaults_object(P_IS_USER_LOGIN) boolValue];
    NSDictionary *WalletAmtDict = [[NSUserDefaults standardUserDefaults]objectForKey:P_USER_DICT_LOGGED];
    if(is_user_login){
        WalletAmtDict = [[NSUserDefaults standardUserDefaults]objectForKey:P_USER_DICT];
    }
    CityModel *city=[CityModel getCityByCityId:is_user_login?[UserProfile shared].loggedCityID:[UserProfile shared].cityID];
    self.walletAmountLbl.text = [Utilities formatAmountAndCurrency:[[WalletAmtDict objectForKey: P_USER_WAlLET_AMOUNT] floatValue] currency:isEmpty(city.city_cur) ];
     if([[WalletAmtDict objectForKey: P_USER_WAlLET_AMOUNT] floatValue]<0) {
         self.walletAmountLbl.textColor=[UIColor redColor];
     }else{
         self.walletAmountLbl.textColor=RGB(34,139,34);
     }
    if([[WalletAmtDict objectForKey: P_USER_WAlLET_AMOUNT] floatValue]==0) {
        self.walletAmountLbl.text = [Utilities formatAmountAndCurrencyZero:0 currency:isEmpty(city.city_cur) ];
    }
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    [self setUIFields];
    [self getLastPayoutList:NO];
}



-(void) setUIFields{
    self.lblHeader.text = [[LanguageHelper getStringWithKey:@"k_4_s10_payout"] uppercaseString];
    self.lblPayoutAmountText.text = [LanguageHelper getStringWithKey:@"k_2_s10_payout_amount"];
    self.lblCurrentBalanace.text = [LanguageHelper getStringWithKey:@"k_2_s10_current_bal"];
    self.txtPayoutAmt.placeholder = [LanguageHelper getStringWithKey:@"k_3_s18_entr_amt"];
    [self.btnPayoutAmt setTitle:[[LanguageHelper getStringWithKey:@"k_4_s10_payout"] uppercaseString] forState:UIControlStateNormal];
    self.lblReqStatusText.text=[LanguageHelper getStringWithKey:@"k_r16_s7_status"];
    self.lblDateText.text=[LanguageHelper getStringWithKey:@"k_r16_s7_date"];
    self.lblReqAmtText.text=[LanguageHelper getStringWithKey:@"k_3_s5_amount"];
    self.lblLastRequestTitle.text=[LanguageHelper getStringWithKey:@"k_r16_s7_lst_payout_rqst"];
    
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
  
    if (textField ==self.txtPayoutAmt && textField.text.length >= 8 && range.length == 0) {
        return NO; // return NO to not change text
    }
    else  {
        return YES;
        
    }
}

-(void)getLastPayoutList:(BOOL) isLoadMore{
    NSDictionary * dictDriver = defaults_object(P_USER_DICT);
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{
        P_DRIVER_ID:[dictDriver objectForKey:P_DRIVER_ID],
    }];
    [UtilityClass setLH:NO wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
    [GIC mkwu:API_GET_DRIVER_PAYOUT  d:dict isa:NO   cb:^(id results, NSError *error) {
        [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
        if ([[[results objectForKey:P_STATUS]uppercaseString] isEqualToString:@"OK"]) {
            if ([[results objectForKey:P_RESPONSE] isKindOfClass:[NSArray class]]) {
                NSArray *arrtrip = [results objectForKey:P_RESPONSE];
                if(arrtrip.count>0){
                    NSDictionary * dict = [arrtrip objectAtIndex:0];
                    [self showDataWithDict:[arrtrip objectAtIndex:0]];
                    if([[dict objectForKey:@"status"] isEqualToString:@"request"]){
                        self->isAlreadyRequested=YES;
                        self.txtPayoutAmt.enabled = NO;
                    }else{
                        self->isAlreadyRequested=NO;
                        self.txtPayoutAmt.enabled = YES;
                    }
                }
            }else if ([[results objectForKey:P_RESPONSE] isKindOfClass:[NSDictionary class]]) {
                NSDictionary * dict = [results objectForKey:P_RESPONSE];
                [self showDataWithDict:[results objectForKey:P_RESPONSE]];
                if([[dict objectForKey:@"status"] isEqualToString:@"request"]){
                    self->isAlreadyRequested=YES;
                    self.txtPayoutAmt.enabled = NO;
                }else{
                    self->isAlreadyRequested=NO;
                    self.txtPayoutAmt.enabled = YES;
                }
            }
        }
    }];
}


-(void) showDataWithDict:(NSDictionary *) dict{
    self.lblDateValue.text=[Utilities GetGMTDatetoLocalTZ:[dict objectForKey:@"created"] :(NSString *)APP_DATE_FORMAT];
    self.lblReqStatusValue.text=[dict objectForKey:@"status"];
    NSDictionary *dictDriver = defaults_object(P_USER_DICT);
       CityModel * cityModel=[CityModel getCityByCityId:[UserProfile shared].cityID];
    self.lblReqAmtValue.text=[Utilities formatAmountAndCurrency:[[dict objectForKey:@"amount"] floatValue] currency:isEmpty(cityModel.city_cur)];
    self.viewLastRequest.hidden=NO;
}



- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)onPayoutButtonTap:(id)sender {
    [self.view endEditing:YES];
    if(isAlreadyRequested){
        [self showAlertWithMessgae:[LanguageHelper getStringWithKey:@"k_r16_s7_alrdy_rqstd_pyot"]];
        return;
    }
    NSString *trimmed = [self.txtPayoutAmt.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSNumberFormatter * nformatter=[[NSNumberFormatter alloc] init];
    [nformatter setLocale:[NSLocale localeWithLocaleIdentifier:@"EN"]];
    NSString *payoutAmount=[NSString stringWithFormat:@"%@",[nformatter numberFromString:trimmed]];
    if([payoutAmount floatValue]<=0){
        [self showAlertWithMessgae:[LanguageHelper getStringWithKey:@"k_r1_s6_please_enter_amount"]];
        return;
    }
    NSDictionary *dictDriver = defaults_object(P_USER_DICT);
    if([[dictDriver objectForKey: P_DRIVER_WAlLET_AMOUNT] floatValue ]<0){
        [self showAlertWithMessgae:[LanguageHelper getStringWithKey:@"k_r16_s7_outstnd_wallet_blnc"]];
        return;
    }
    if([[dictDriver objectForKey: P_DRIVER_WAlLET_AMOUNT] floatValue ]<[payoutAmount floatValue]){
        [self showAlertWithMessgae:[LanguageHelper getStringWithKey:@"k_r16_s7_nt_engh_wallet"]];
        return;
    }
    [self addPayoutRequestWithAmount:payoutAmount];
}


-(void)addPayoutRequestWithAmount:(NSString *) amount{
    NSDictionary * dictDriver =defaults_object(P_USER_DICT);
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{
        P_DRIVER_ID:[dictDriver objectForKey:P_DRIVER_ID ],
        P_APYOUT_AMOUNT:amount,
    }];
    [UtilityClass setLH:NO wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
    [GIC mkwu:API_GET_DRIVER_ADD_PAYOUT  d:dict isa:NO   cb:^(id results, NSError *error) {
        [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
        if (isStatusOk(results)) {
            [self showDataWithDict:[results objectForKey:P_RESPONSE]];
            if([[[results objectForKey:P_RESPONSE] objectForKey:@"status"] isEqualToString:@"request"]){
                self->isAlreadyRequested=YES;
                self.txtPayoutAmt.enabled = NO;
            }else{
                self->isAlreadyRequested=NO;
                self.txtPayoutAmt.enabled = YES;
            }
            self.txtPayoutAmt.text = @"";
            [self showAlertWithOk:@"" message:[LanguageHelper getStringWithKey:@"k_r16_s7_payout_scs"] handler:^(UIAlertAction * _Nonnull action) {
            }];
        }else if(isStatusError(results)){
            [self showAlertWithMessgae:[LanguageHelper getStringWithKey:errorMessage(results)]];
        }else{
            [Utilities handleError:error viewController:self defaultMessage:@""];
        }
    }];
}

//
@end

