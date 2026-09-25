//
//  UIViewController+Extension.m
//  Golden Moto
//
//  Created by Grepix - Baij on 14/02/20.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import "UIViewController+Extension.h"
#import "WebCallConstants.h"
#import <UIKit/UIKit.h>
#import <GIKit/GIKit.h>
#import "ConstantModel.h"
#import "CityModel.h"
#import "Utilities.h"
#import "AppDelegate.h"
#import "LanguageHelper.h"
#import "UserProfile.h"
//#import <AFNetworking/AFNetworking.h>

@implementation UIViewController (Extension)




- (float)getDriverCommissionForTrip:(TripModel *)tripeModel{
    float driverCommission=0;
    CityModel *cityModel=[CityModel getCityByCityId:tripeModel.city_id];

    driverCommission =[tripeModel.trip_fare doubleValue]*(100-cityModel.city_comm)/100;
    return driverCommission;
}



-(void) cancelTripBeforeBeginTrip:(TripModel *) tripModel completionBlock:(void (^)(id results, NSError *error))block isShowLoader:(BOOL)isShowLoader isSendNotification:(BOOL)isSendNotification withDelegate:(id<UIViewControllerExtensionDelegate>)delegate isFromBeginTrip:(BOOL)isFromBeginTrip
{
    long valur1Hours=1*60*60;
    NSString * message=@"";
    if([tripModel.trip_Status isEqualToString:TS_REQUEST]){
        message=[LanguageHelper getStringWithKey:@"k_r16_s8_cancel_trip_now" ];
    }else if(tripModel.is_ride_later&&[tripModel.trip_Status isEqualToString:TS_ASSIGNED]&&(![tripModel isTripStartRemainingTimeLessThan:valur1Hours])){
        message=[LanguageHelper getStringWithKey:@"k_r16_s8_cancel_trip_now" ];
    }else{
        message=[LanguageHelper getStringWithKey:@"ride_later_cancel_confirmation_text" ];
    }
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[LanguageHelper getStringWithKey:@"k_33_s7_alert" ]
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *actionOk = [UIAlertAction actionWithTitle:[LanguageHelper getStringWithKey:@"k_21_s4_yes" defaultValue:@"Yes"]
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {
        if([tripModel.trip_Status isEqualToString:TS_REQUEST]){
            [self onCancelTripByRiderWithTripModel:tripModel completionBlock:block isShowLoader:isShowLoader isSendNotification:isSendNotification];
            return;
        }
        else if(tripModel.is_ride_later&&[tripModel.trip_Status isEqualToString:TS_ASSIGNED]&&(![tripModel isTripStartRemainingTimeLessThan:valur1Hours])){
            [self onCancelTripByRiderWithTripModel:tripModel completionBlock:block isShowLoader:isShowLoader isSendNotification:isSendNotification];
            return;
        }
        [self onCancelWithServiewByRiderWithTripModel:tripModel completionBlock:block isShowLoader:isShowLoader isSendNotification:isSendNotification];
        return;
    }];
    [alertController addAction:actionOk];
    UIAlertAction *actionNo = [UIAlertAction actionWithTitle:[LanguageHelper getStringWithKey:@"k_22_s4_no" defaultValue:@"No"]
                                                       style:UIAlertActionStyleDefault
                                                     handler:nil];
    [alertController addAction:actionNo];
    [self presentViewController:alertController animated:YES completion:nil];
}




- (IBAction)onCancelTripByRiderWithTripModel:(TripModel *) tripModel completionBlock:(void (^)(id results, NSError *error))block isShowLoader:(BOOL)isShowLoader isSendNotification:(BOOL)isSendNotification{
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]  init];
    [dict setObject: [NSString stringWithFormat:@"%@",tripModel.trip_Id] forKey:TRIP_ID];
    [dict setObject:TS_USER_CANCEL forKey:TRIP_STATUS];
    [dict setObject:@"1" forKey:@"is_cancelled"];
    [dict setObject:@"1" forKey:@"is_return_details"];
    [dict setObject:@"r" forKey:@"can_fee_by"];
    if(tripModel.is_ride_later){
        [dict setObject:@"1" forKey:@"is_ride_later"];
        NSDictionary * dictUser = defaults_object(P_USER_DICT);
        [dict setObject:[dictUser objectForKey:P_USER_ID] forKey:@"user_id"];
    }
    [tripModel updateTripModelWith:dict completionBlock:^(id results, NSError *error) {
        if([[results objectForKey:P_RESPONSE] isKindOfClass:[NSDictionary class]])
        {
            
        }
        else{
            if([[results objectForKey:P_RESPONSE] intValue]==1)
            {
                [self sendCancelTripNotification:tripModel];
            }
        }
        block(results,error);
    } isShowLoader:YES isSendNotification:NO];
}


- (IBAction)onCancelWithServiewByRiderWithTripModel:(TripModel *) tripModel completionBlock:(void (^)(id results, NSError *error))block isShowLoader:(BOOL)isShowLoader isSendNotification:(BOOL)isSendNotification{
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]  init];
    [dict setObject: [NSString stringWithFormat:@"%@",tripModel.trip_Id] forKey:TRIP_ID];
    [dict setObject:TS_USER_CANCEL forKey:TRIP_STATUS];
    [dict setObject:@"1" forKey:@"is_cancelled"];
    [dict setObject:@"1" forKey:@"is_return_details"];
    [dict setObject:@"r" forKey:@"can_fee_by"];
    [tripModel updateTripModelWith:dict completionBlock:^(id results, NSError *error) {
        if([[results objectForKey:P_RESPONSE] isKindOfClass:[NSDictionary class]])
        {
            [self sendCancelTripNotification:tripModel];
        }
        else{
            if([[results objectForKey:P_RESPONSE] intValue]==1)
            {
                [self sendCancelTripNotification:tripModel];
            }
        }
        block(results,error);
    } isShowLoader:YES isSendNotification:NO];
}



-(void) payWithHireMeWalletWithTripModel:(TripModel *) tripModel completionBlock:(void (^)(id results, NSError *error))block isShowLoader:(BOOL)isShowLoader isSendNotification:(BOOL)isSendNotification withDelegate:(id<UIViewControllerExtensionDelegate>)delegate isFromBeginTrip:(BOOL)isFromBeginTrip{
    
    float tripFareEstmated=[tripModel.trip_fare floatValue];
    float tripFareFinal=tripFareEstmated;
    
    if([tripModel.trip_Status isEqualToString:TS_ASSIGNED]||[tripModel.trip_Status isEqualToString:TS_ASSIGNED])
    {
        
        //check trip trip
        //         Any cancellation less than 48h needs to be charge at 50% of the estimate and cancellation less then 24h needs to be charge at 100% of the estimate
        
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSLocale *indianLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        [dateFormat setLocale:indianLocale];
        [dateFormat setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
        NSDate *datePickupTime = [dateFormat dateFromString:tripModel.trip_date];
        NSDate * currntDate=[NSDate date];
        long valur48Hours=48*60*60;
        long valur24Hours=24*60*60;
        long  pickTime=[datePickupTime timeIntervalSince1970];
        
        long timeDiffBetweenNowAndPick=pickTime-[currntDate timeIntervalSince1970];
        
        if(timeDiffBetweenNowAndPick<=valur24Hours){
            tripFareFinal=tripFareEstmated;
        }else{
            tripFareFinal=tripFareEstmated/2.0;
        }
    }
    NSDictionary *dict1 = [[NSUserDefaults standardUserDefaults]objectForKey:P_USER_DICT];

    ConstantModel *constantModel =[ConstantModel getConstantsObject];
    NSData *data ;
    data=[constantModel.currency_conversion dataUsingEncoding:NSUTF8StringEncoding];
    
    CityModel *  cityModel= [CityModel getCityByCityId:[UserProfile shared].cityID];
    CityModel *  cityModelTrip= [CityModel getCityByCityId:tripModel.city_id];
    float currencyMul=1;
    if(cityModel){
        if(data){
            NSDictionary * dictCurrency = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            NSString * mul=[dictCurrency objectForKey:[NSString stringWithFormat:@"%@%@",cityModelTrip.city_cur,cityModel.city_cur]];
            if(mul)           {
                currencyMul=   [mul floatValue];
            }
        }
    }
    float tripTax=[tripModel.trip_fare floatValue]-([tripModel.trip_fare floatValue]*(100.0-cityModelTrip.city_tax)/100.0);
    
    
    tripModel.trip_fare=[Utilities formatDistance:tripFareFinal];
    tripModel.tax_amount=[Utilities formatDistance:tripTax];
    if(isFromBeginTrip)
    {
        [self payWithHireMeWallet:tripModel  tripFare: tripFareFinal tripTax:tripTax  isSendNotification:YES completionBlock:block withDelegate:delegate isAnyTripRunning:NO];
    }else{
        NSString *savedTripId=defaults_object(TRIP_ID);
        BOOL isAnyTripRunning =NO;
        if(savedTripId!=nil)
        {
            isAnyTripRunning=YES;
            
        }
        
        if(isAnyTripRunning)
        {
            [self chargeOffSessionUserWhenUserCancelTrip:tripModel  tripFare: tripFareFinal tripTax:tripTax  isSendNotification:YES completionBlock:block withDelegate:delegate isAnyTripRunning:YES];
        }else{
            [self payWithHireMeWallet:tripModel  tripFare: tripFareFinal tripTax:tripTax  isSendNotification:YES completionBlock:block withDelegate:delegate isAnyTripRunning:NO];
        }
    }
}



-(void) makeWalletPaymentWhenCardPaymentFailed:(TripModel *) tripModel tripFare:(float) tripFareFinal tripTax:(float ) tripTax isSendNotification:(BOOL)isSendNotification completionBlock:(void (^)(id results, NSError *error))block  withDelegate:(id<UIViewControllerExtensionDelegate>)delegate isAnyTripRunning:(BOOL)isAnyTripRunning
{
    
    NSDictionary *dict1 = [[NSUserDefaults standardUserDefaults]objectForKey:P_USER_DICT];
    
    ConstantModel *constantModel =[ConstantModel getConstantsObject];
    NSData *data ;
    data=[constantModel.currency_conversion dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary * dictCurrency = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    CityModel *  cityModel= [CityModel getCityByCityId:[UserProfile shared].cityID];
    CityModel *  cityModelTrip= [CityModel getCityByCityId:tripModel.city_id];
    float currencyMul=1;
    if(cityModel)
    {
        
        NSString * mul=[dictCurrency objectForKey:[NSString stringWithFormat:@"%@%@",cityModelTrip.city_cur,cityModel.city_cur]];
        if(mul)
        {
            currencyMul=   [mul floatValue];
        }
    }
    float driverCommission=[self getDriverCommissionForTrip:tripModel];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{
        @"user_id":[dict1 objectForKey:P_USER_ID],
        @"total_amt":[Utilities formatDistance:[tripModel.trip_fare floatValue]],
        @"rider_amt":[Utilities formatDistance:currencyMul*([tripModel.trip_fare floatValue])],
        @"pay_amount":[Utilities formatDistance:[tripModel.trip_fare floatValue]],
        @"api_key":[ dict1 objectForKey:P_API_KEY],
        @"trip_id":[NSString stringWithFormat:@"%@",tripModel.trip_Id],
        @"driver_id":[NSString stringWithFormat:@"%@",tripModel.trip_Driver_Id],
        @"city_id":[NSString stringWithFormat:@"%d",tripModel.city_id],
        //                                                                                    @"pay_status":PAID,
        @"trip_driver_commision":[Utilities formatDistance:driverCommission],
        @"pay_mode":HIRE_ME_WALLET_PAY,
        @"trans_description":@"Trip Payment",
        @"promo_amt":[Utilities formatDistance:[tripModel.trip_promo_amt floatValue]],
        @"commission_amt":[Utilities formatDistance:([[Utilities formatDistance:[tripModel.trip_fare floatValue]] floatValue]-driverCommission)]
    }];
    [UtilityClass setLH:NO wt:[LanguageHelper getStringWithKey:@"k_53_s3_please_wait"]];
    
    [GIC mkwu:GET_WALLET_ADD_TRIP_TRAN
                  d:dict
      isa:NO
           cb:^(id results, NSError *error) {
        
        if ([[results objectForKey:P_STATUS] isEqualToString:@"OK"]) {
            // success
            [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_53_s3_please_wait"]];
            if ([[results objectForKey:P_RESPONSE] isKindOfClass:[NSDictionary class]]) {
                //                       NSDictionary *arrtrip = [results objectForKey:P_RESPONSE];
                NSMutableDictionary *WalletAmtDict = [[[NSUserDefaults standardUserDefaults]objectForKey:P_USER_DICT] mutableCopy];
                int toatalAmt=[[WalletAmtDict  objectForKey:P_USER_WAlLET_AMOUNT] intValue];
                [WalletAmtDict setObject:[NSString stringWithFormat:@"%d",(toatalAmt-[tripModel.trip_fare intValue]-[tripModel.trip_promo_amt intValue])] forKey:P_USER_WAlLET_AMOUNT ];
                [[NSUserDefaults standardUserDefaults] setObject:WalletAmtDict forKey:P_USER_DICT];
                [[NSUserDefaults standardUserDefaults] synchronize];
                   tripModel.trip_pay_mode=CARD;
            }
       
            [self payWithHireMeWallet:tripModel  tripFare: tripFareFinal tripTax:tripTax  isSendNotification:YES completionBlock:block withDelegate:delegate isAnyTripRunning:isAnyTripRunning];
        }else {
            block(results,error);
        }
        
    }];
}








-(void)payWithHireMeWallet:(TripModel *) tripModel tripFare:(float) tripFare tripTax:(float ) tripTax isSendNotification:(BOOL)isSendNotification completionBlock:(void (^)(id results, NSError *error))block  withDelegate:(id<UIViewControllerExtensionDelegate>)delegate isAnyTripRunning:(BOOL)isAnyTripRunning
{
  
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]  init];
    [dict setObject:[NSString stringWithFormat:@"%@",tripModel.trip_Id] forKey:@"trip_id"];
    [dict setObject:isEmpty(tripModel.trip_pay_mode) forKey:@"trip_pay_mode"];
    if(isAnyTripRunning)
    {
        [dict setObject:TS_USER_CANCEL forKey:TRIP_STATUS];
    }else{
        [dict setObject:TS_RIDER_CANCEL forKey:TRIP_STATUS];
    }
    [dict setObject:[Utilities formatDistance:tripFare] forKey:@"trip_pay_amount"];
    [dict setObject:[Utilities formatDistance:tripTax] forKey:@"tax_amt"];
    [dict setObject:[Utilities getStringFromDate:[NSDate date]] forKey:@"trip_pay_date"];
    tripModel.trip_fare=[Utilities formatDistance:tripFare] ;
    tripModel.tax_amount=[Utilities formatDistance:tripTax] ;
    [tripModel updateTripModelWith:dict completionBlock:^(id results, NSError *error) {
        if([[results objectForKey:P_STATUS]isEqualToString:@"OK"])
        {
            if(!isAnyTripRunning)
            {
                [delegate goToFareSummeryScreenWhenTripCancelByRider:tripModel];
            }else{
                            [self sendCancelTripNotification:tripModel];
            }
              block(results,error);

        }else
        {
            block(results,error);
        }
        
    } isShowLoader:YES isSendNotification:NO];
}


-(NSString *) getValueForKey:(NSString *) key lang:(NSString*)lang{
    return [[LanguageHelper sharedInstance] getStringWithKey:key currentLanguage:lang];
}
-(void)sendCancelTripNotification:(TripModel *) tripModel{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{
        
        @"message"       :[self getValueForKey:@"k_53_s4_rider_has_cancelled_trip" lang:tripModel.driver.d_lang]/*MESSAGE_USER_CANCEL*/,
        TRIP_STATUS      :TS_USER_CANCEL,
        TRIP_ID          :[NSString stringWithFormat:@"%@",tripModel.trip_Id],
        @"content-available":@"1",
        
    }];
    [dict setObject:@"driver_cancel.caf" forKey:@"sound"];
    [dict addEntriesFromDictionary:[tripModel.driver deviceTypeAndToken]];
    if (isTokenEmpty(dict)) {
        return;
    }
    if(tripModel.is_share){
        [dict setObject:@"1" forKey:@"is_share"];
    }
    [dict setObject:@"driver" forKey:@"to"];
    [GIC mk:url_notification to:send_driver_notification   d:dict  isa:NO cb:^(id results, NSError *error) {
        if ([[results objectForKey:P_STATUS] isEqualToString:@"OK"]) {
        }
    }];
}










-(void)getRiderCancelTripsWithDelegate:(id<UIViewControllerExtensionDelegate>)delegate{
    
    NSDictionary *dict1 = [[NSUserDefaults standardUserDefaults]objectForKey:P_USER_DICT];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{
                                                                                   
                                                                                   @"user_id"          :[dict1 objectForKey:P_USER_ID],
                                                                                   @"trip_status" :   TS_RIDER_CANCEL,
                                                                                   @"api_key" : [dict1 objectForKey:P_API_KEY],
                                                                                   }];
    [UtilityClass setLH:NO wt:[LanguageHelper getStringWithKey:@"k_53_s3_please_wait"]];
    
    [GIC mkwu:TRIP_GET_USER_TRIP
                  d:dict
      isa:NO
           cb:^(id results, NSError *error) {
           
           if ([[results objectForKey:P_STATUS] isEqualToString:@"OK"]) {
               // success
               if ([[results objectForKey:P_RESPONSE] isKindOfClass:[NSArray class]]) {
                   NSArray *arrtrip = [results objectForKey:P_RESPONSE];
                   if ([arrtrip isKindOfClass:[NSArray class]]){
                       if(arrtrip.count>0)
                       {
                           TripModel *cancelTripModel = [[TripModel alloc] initItemWithDict:[arrtrip objectAtIndex:0]];
                           [delegate goToFareSummeryScreenWhenTripCancelByRider:cancelTripModel];
                           
                       }else
                       {
                       }
                   }
               }else{
//                   self.cancelTripModel=nil;
               }
           }else{
//               self.cancelTripModel=nil;
           }
           [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_53_s3_please_wait"]];
       }];
}



-(void) chargeOffSessionUserWhenUserCancelTrip:(TripModel *)tripModel tripFare:(float) tripFareFinal tripTax:(float ) tripTax isSendNotification:(BOOL)isSendNotification completionBlock:(void (^)(id results, NSError *error))block  withDelegate:(id<UIViewControllerExtensionDelegate>)delegate isAnyTripRunning:(BOOL)isAnyTripRunning
{
    BOOL isByPassCardPayment=NO;
    if(isByPassCardPayment)
    {
        [self payWithCardDetectComssionCancelTrip:tripModel tripFare:tripFareFinal tripTax:tripTax isSendNotification:isSendNotification completionBlock:block withDelegate:delegate];
    }else{
//         CityModel *cityModel=[CityModel getCityByCityId:tripModel.city_id];
//        [UtilityClass setLH:NO wt:[LanguageHelper getStringWithKey:@"k_53_s3_please_wait"]];
//        NSDictionary *dict1 = [[NSUserDefaults standardUserDefaults]objectForKey:P_USER_DICT];
        
//        ConstantModel *constantModel =[ConstantModel getConstantsObject];
//        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//        [manager.requestSerializer setAuthorizationHeaderFieldWithUsername:isEmpty(constantModel.stripe_s_key/*STRIPE_SECRET_KEY*/) password:@""];
////        NSURLCredential *credential = [NSURLCredential credentialWithUser:isEmpty(constantModel.stripe_s_key/*STRIPE_SECRET_KEY*/) password:@"" persistence:NSURLCredentialPersistenceNone];
//        NSDictionary *parameters = @{@"customer": isEmpty(constantModel.is_stripe_live?[dict1 objectForKey:P_STRIPE_CUS_ID]:[dict1 objectForKey:P_STRIPE_DEV_CUS_ID]),@"payment_method":isEmpty([dict1 objectForKey:P_USER_DEFAULT_PAY_METHOD]),@"amount":[NSString stringWithFormat:@"%d",(int)([tripModel.trip_fare floatValue]-[tripModel.trip_promo_amt floatValue])*100],@"currency":isEmpty(cityModel.pg_cur)/*@"eur"*/,@"off_session":@"true",@"confirm":@"true",@"statement_descriptor_suffix":[NSString stringWithFormat:@"Trip ID = %d",tripModel.trip_Id]};
//        NSString * urlForSave=[NSString stringWithFormat:@"https://api.stripe.com/v1/payment_intents"];
//        NSMutableURLRequest *request= [manager.requestSerializer requestWithMethod:@"POST" URLString:urlForSave parameters:parameters error:nil];
//
//        [manager POST:urlForSave parameters:parameters headers:nil progress:^(NSProgress * _Nonnull uploadProgress) {
//
//        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//            NSLog(@"Success: %@", responseObject);
//            [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_53_s3_please_wait"]];
//            NSDictionary * error=[responseObject objectForKey:@"error"];
//            if(error==nil)
//            {
//                tripModel.trip_pay_mode=CARD_PAY;
//                [self payWithCardDetectComssionCancelTrip:tripModel tripFare:tripFareFinal tripTax:tripTax isSendNotification:isSendNotification completionBlock:block withDelegate:delegate];
//            }else{
//                [self makeWalletPaymentWhenCardPaymentFailed:tripModel tripFare:tripFareFinal tripTax:tripTax isSendNotification:isSendNotification completionBlock:block withDelegate:delegate isAnyTripRunning:isAnyTripRunning];
//            }
//        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//            NSLog(@"Failure: %@", error);
//            [UtilityClass setLH:NO wt:[LanguageHelper getStringWithKey:@"k_53_s3_please_wait"]];
//              [self makeWalletPaymentWhenCardPaymentFailed:tripModel tripFare:tripFareFinal tripTax:tripTax isSendNotification:isSendNotification completionBlock:block withDelegate:delegate isAnyTripRunning:isAnyTripRunning];
//        }];
//        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
//        [operation setCredential:credential];
//        [operation setResponseSerializer:[AFJSONResponseSerializer alloc]];
//        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
//            NSLog(@"Success: %@", responseObject);
//            [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_53_s3_please_wait"]];
//            NSDictionary * error=[responseObject objectForKey:@"error"];
//            if(error==nil)
//            {
//                tripModel.trip_pay_mode=CARD_PAY;
//                [self payWithCardDetectComssionCancelTrip:tripModel tripFare:tripFareFinal tripTax:tripTax isSendNotification:isSendNotification completionBlock:block withDelegate:delegate];
//            }else{
//                [self makeWalletPaymentWhenCardPaymentFailed:tripModel tripFare:tripFareFinal tripTax:tripTax isSendNotification:isSendNotification completionBlock:block withDelegate:delegate isAnyTripRunning:isAnyTripRunning];
//            }
//        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//            NSLog(@"Failure: %@", error);
//            [UtilityClass setLH:NO wt:[LanguageHelper getStringWithKey:@"k_53_s3_please_wait"]];
//              [self makeWalletPaymentWhenCardPaymentFailed:tripModel tripFare:tripFareFinal tripTax:tripTax isSendNotification:isSendNotification completionBlock:block withDelegate:delegate isAnyTripRunning:isAnyTripRunning];
//        }];
//        [manager.operationQueue addOperation:operation];
    }
}



-(void) payWithCardDetectComssionCancelTrip:(TripModel *)tripModel tripFare:(float) tripFareFinal tripTax:(float ) tripTax isSendNotification:(BOOL)isSendNotification completionBlock:(void (^)(id results, NSError *error))block  withDelegate:(id<UIViewControllerExtensionDelegate>)delegate{
    NSDictionary *dict1 = [[NSUserDefaults standardUserDefaults]objectForKey:P_USER_DICT];
    float driverCommission=[self getDriverCommissionForTrip:tripModel];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{
        @"user_id":[dict1 objectForKey:P_USER_ID],
        @"total_amt":[Utilities formatDistance:[tripModel.trip_fare floatValue]],
        @"rider_amt":[Utilities formatDistance:[tripModel.trip_fare floatValue]],
        @"pay_amount":[Utilities formatDistance:[tripModel.trip_fare floatValue]],
        @"api_key":[ dict1 objectForKey:P_API_KEY],
        @"trip_id":[NSString stringWithFormat:@"%@",tripModel.trip_Id],
        @"driver_id":[NSString stringWithFormat:@"%@",tripModel.trip_Driver_Id],                                                                              @"pay_status":TS_PAID,
        @"city_id":[NSString stringWithFormat:@"%d",tripModel.city_id],
        @"trip_driver_commision":[Utilities formatDistance:driverCommission],
        @"pay_mode":@"Card",
        @"trans_description":@"Trip Payment",
        @"promo_amt":[Utilities formatDistance:[tripModel.trip_promo_amt floatValue]],
        @"commission_amt":[Utilities formatDistance:([[Utilities formatDistance:[tripModel.trip_fare floatValue]] floatValue]-driverCommission)]
    }];
    [UtilityClass setLH:NO wt:[LanguageHelper getStringWithKey:@"k_53_s3_please_wait"]];
    [GIC mkwu:GET_WALLET_ADD_TRIP_TRAN
                  d:dict
      isa:YES
           cb:^(id results, NSError *error) {
        if ([[results objectForKey:P_STATUS] isEqualToString:@"OK"]) {
            [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_53_s3_please_wait"]];
            // success
            [self payWithHireMeWallet:tripModel tripFare:tripFareFinal tripTax:tripTax isSendNotification:isSendNotification completionBlock:block withDelegate:delegate isAnyTripRunning:YES];
        }else {
            
            [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_53_s3_please_wait"]];
            [UtilityClass swa:@"Alert" m:@"Error in payment" cbt:@"ok" obt:nil];
        }
    }];
}


//-(void)payWithCardOnHand:(BOOL)isSendNotification CancelTrip:(TripModel *)tripModel tripFare:(float) tripFareFinal tripTax:(float ) tripTax isSendNotification:(BOOL)isSendNotification completionBlock:(void (^)(id results, NSError *error))block  withDelegate:(id<UIViewControllerExtensionDelegate>)delegate
//{
//    NSMutableDictionary *dict=[[NSMutableDictionary alloc]  init];
//    [dict setObject:tripModel.trip_Id forKey:@"trip_id"];
//    [dict setObject:CARD_PAY forKey:@"trip_pay_mode"];
//    [dict setObject:PAID forKey:@"trip_pay_status"];
//    [dict setObject:TS_USER_CANCEL forKey:TRIP_STATUS];
//    tripModel.trip_pay_mode=CARD_PAY;
//    [dict setObject:[Utilities getStringFromDate:[NSDate date]] forKey:@"trip_pay_date"];
//    [tripModel updateTripModelWith:dict completionBlock:^(id results, NSError *error) {
//        if([[results objectForKey:P_STATUS]isEqualToString:@"OK"])
//        {
//
//        }
//    } isShowLoader:YES isSendNotification:isSendNotification];
//}

- (void)makeCallToNumber:(TripModel *) tripModel {
    
     if(tripModel.driver.phone==nil)
     {
         [UtilityClass swa:nil
                                       m:NSLocalizedString(@"invaild mobile number", @"")
                             cbt:@"Ok"
                              obt:nil vc:self];
         return;
     }

        UIAlertController *alertViewcontroller=[UIAlertController alertControllerWithTitle:[LanguageHelper getStringWithKey:@"k_s4_contact" defaultValue:@"Contact"] message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *actionCall=[UIAlertAction actionWithTitle:[LanguageHelper getStringWithKey:@"k_r1_s8_call_driver" defaultValue:@"Call Driver"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
            [self doSimpleNativeCall:tripModel];
        
        
    }];
    [actionCall setValue:[UIColor colorNamed:@"app_theame"] forKey:@"titleTextColor"];
    [alertViewcontroller addAction:actionCall];
    if([[ConstantModel getConstantsObject] getCValueFK:ckey_ech]==YES){
        UIAlertAction * actionChat=[UIAlertAction actionWithTitle:[LanguageHelper getStringWithKey:@"k_r1_s8_chat_with_driver" defaultValue:@"Chat with Driver" ] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self openChatViewController:tripModel];
        }];
        [actionChat setValue:[UIColor colorNamed:@"app_theame"] forKey:@"titleTextColor"];
        [alertViewcontroller addAction:actionChat];
    }
    UIAlertAction * actionCancel=[UIAlertAction actionWithTitle:[LanguageHelper getStringWithKey:@"k_30_s6_cancel_j" defaultValue:@"Cancel"] style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [actionCancel setValue:[UIColor colorNamed:@"app_theame"] forKey:@"titleTextColor"];
    [alertViewcontroller addAction:actionCancel];
    [self.navigationController presentViewController:alertViewcontroller animated:YES completion:^{
        
    }];
    
    
    
}
-(void)doSimpleNativeCall:(TripModel *)tripModel
{
    NSString * numberWithCode=[Utilities numeroParaLlamarConCodigo:tripModel.driver.c_code numero:tripModel.driver.phone];
    NSURL *phoneUrl = [NSURL URLWithString:[@"telprompt://"stringByAppendingString:numberWithCode]];
    NSURL *phoneFallbackUrl = [NSURL URLWithString:[@"tel://" stringByAppendingString:numberWithCode]];
    
    // Sin numero la URL se queda en "telprompt://" y abriria el marcador en blanco. Cayendo
    // al else sale el aviso de que no se puede llamar, que es lo que el usuario necesita oir.
    if (numberWithCode.length > 0 && [UIApplication.sharedApplication canOpenURL:phoneUrl]) {
        [[UIApplication sharedApplication] openURL:phoneUrl options:@{} completionHandler:^(BOOL success) {
            
        }];
    } else if (numberWithCode.length > 0 && [UIApplication.sharedApplication canOpenURL:phoneFallbackUrl]) {
        [UIApplication.sharedApplication openURL:phoneFallbackUrl options:@{} completionHandler:^(BOOL success) {
            
        }];
    } else {
        [UtilityClass swa:nil
                               m:[LanguageHelper getStringWithKey:@"k_8_s9_no_call_facility" defaultValue:@"No Call facility"]
                     cbt:[LanguageHelper getStringWithKey:@"k_18_s4_Ok" defaultValue:@"Ok"]
                      obt:nil vc:self];
    }
}

-(void) openChatViewController:(TripModel *) tripModel
{
    ChatViewController *vc = (ChatViewController*)[StoryBoardUtiles viewContollerInMainWithIdentifier:StoryBoardUtiles.CHAT_VC ];
    vc.tripID=[NSString stringWithFormat:@"%d",tripModel.trip_Id];
    [self.navigationController pushViewController:vc animated:YES];
}

@end

