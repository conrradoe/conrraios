//
//  TripModel.m
//  TaxiDriver
//
//  Created by  Appicial on 25/05/17.
//  Copyright © 2023 Appicial. All rights reserved.
//



#import "TripModel.h"
#import "WebCallConstants.h"
#import <GIKit/GIKit.h>
#import "AFHTTPRequestOperationManager.h"
#import "CityModel.h"
#import "ConstantModel.h"
#import "BaseViewController.h"
#import <Conrra-Swift.h>
@implementation TripModel
-(instancetype)initItemWithDict:(NSDictionary *)tripDict{
    
    self = [super init];
    
    if (self) {
        [self  parseResponse:tripDict];
    }
    return self;
}


-(void)  parseResponse:(NSDictionary *)tripDict
{
    self.trip_Id  = [tripDict objectForKey:@"trip_id"];
    self.m_trip_id=[tripDict objectForKey:@"m_trip_id"];
    self.category_id=[tripDict objectForKey:@"category_id"];
    self.cat_name = [tripDict objectForKey:@"cat_name"];
    self.trip_fare = [tripDict objectForKey:@"trip_pay_amount"];
    self.base_est_amt=[tripDict objectForKey:@"base_est_amt"];
    self.trip_base_fare = [tripDict objectForKey:@"trip_base_fare"];
    self.trip_Status = [tripDict objectForKey:@"trip_status"];
    self.trip_drop_loc = [tripDict objectForKey:@"trip_to_loc"];
    if (![self.trip_drop_loc length])
        self.trip_drop_loc = [tripDict objectForKey:@"trip_to_address"];
    if (![self.trip_drop_loc length])
        self.trip_drop_loc = [tripDict objectForKey:@"to_address"];
    if (![self.trip_drop_loc length])
        self.trip_drop_loc = [tripDict objectForKey:@"to_loc"];
    if (![self.trip_drop_loc length])
        self.trip_drop_loc = [tripDict objectForKey:@"drop_address"];
    self.trip_distance = [tripDict objectForKey:@"trip_distance"];
    self.is_cancelled=[[tripDict objectForKey:@"is_cancelled"] boolValue];
//    self.trip_cat_id = [tripDict objectForKey:P_CATEGORY_ID];
    self.trip_pick_loc = [tripDict objectForKey:@"trip_from_loc"];
    if (![self.trip_pick_loc length])
        self.trip_pick_loc = [tripDict objectForKey:@"trip_from_address"];
    if (![self.trip_pick_loc length])
        self.trip_pick_loc = [tripDict objectForKey:@"from_address"];
    if (![self.trip_pick_loc length])
        self.trip_pick_loc = [tripDict objectForKey:@"from_loc"];
    if (![self.trip_pick_loc length])
        self.trip_pick_loc = [tripDict objectForKey:@"pickup_address"];
    self.trip_created_time = [tripDict objectForKey:@"trip_created"];
    self.trip_modified_time = [tripDict objectForKey:@"trip_modified"];
    self.trip_created=[tripDict objectForKey:@"trip_created"];
    self.tm_arr = [tripDict objectForKey:@"tm_arr"];
    self.tm_acc = [tripDict objectForKey:@"tm_acc"];
    self.trip_pick_lat = [tripDict objectForKey:@"trip_scheduled_pick_lat"];
    self.trip_drop_lat = [tripDict objectForKey:@"trip_scheduled_drop_lat"];
    self.trip_drop_long = [tripDict objectForKey:@"trip_scheduled_drop_lng"];
    self.trip_pick_long = [tripDict objectForKey:@"trip_scheduled_pick_lng"];
    self.trip_driver_commision = [tripDict objectForKey:@"trip_driver_commision"];
    self.trip_pay_mode = [tripDict objectForKey:@"trip_pay_mode"];
    self.trip_pay_status = [tripDict objectForKey:@"trip_pay_status"];
    self.trip_promo_amt = [tripDict objectForKey:@"trip_promo_amt"];
    self.trip_cancel_reason=[tripDict objectForKey:@"trip_reason"];
    self.trip_Driver_Id = [tripDict objectForKey: P_DRIVER_ID];
    self.otp=[tripDict objectForKey:@"otp"];
    self.trip_promo_code=[tripDict objectForKey:@"trip_promo_code"];
    
    self.trip_total_time=[[tripDict objectForKey:@"trip_total_time"] intValue];
    
    self.tax_amount = [tripDict objectForKey:@"tax_amt"];
    self.tax_amount_r = [tripDict objectForKey:@"tax_amt_r"];
    self.trip_pickup_time = [tripDict objectForKey:@"trip_pickup_time"];
    self.trip_drop_time = [tripDict objectForKey:@"trip_drop_time"];
    self.actual_to_loc = [tripDict objectForKey:@"actual_to_loc"];
    self.actual_from_loc = [tripDict objectForKey:@"actual_from_loc"];
    self.trip_rating = [[tripDict objectForKey:@"trip_rating"]  floatValue];
    self.user_rating = [[tripDict objectForKey:@"user_rating"]  floatValue];
    self.trip_actual_pick_lat=[[tripDict objectForKey:@"trip_actual_pick_lat"]  floatValue];
    self.trip_actual_pick_lng=[[tripDict objectForKey:@"trip_actual_pick_lng"]  floatValue];
     self.is_ride_later=[[tripDict objectForKey:@"is_ride_later"] boolValue];
    self.is_share=[[tripDict objectForKey:@"is_share"] boolValue];
    
    self.trip_date=[tripDict objectForKey:@"trip_date"];
    self.wait_duration=[[tripDict objectForKey:@"wait_duration"] intValue];
    NSObject * driverDict=[tripDict  objectForKey:@"Driver"];
    self.city_id=[[tripDict objectForKey:@"city_id"]intValue];
    self.payment_card_id=[tripDict objectForKey:@"payment_card_id"];
    self.payment_intent_id=[tripDict objectForKey:@"payment_intent_id"];
    if([driverDict  isKindOfClass:[NSDictionary class]])
    {
        self.driver=[[DriverModel alloc]  initItemWithDict:[tripDict  objectForKey:@"Driver"]];
    }
    
     NSObject * userDict=[tripDict  objectForKey:@"User"];
    
    if([userDict  isKindOfClass:[NSDictionary class]]){
        self.user=[[UserModel alloc]  initItemWithDict:[tripDict objectForKey:@"User"]];
    }
    
    self.pickup_notes=[tripDict objectForKey:@"pickup_notes"];
//    if(self.pickup_notes.length>0)
//    {
//        self.trip_pick_loc=[NSString stringWithFormat:@"%@ %@",self.pickup_notes,self.trip_pick_loc];
//    }
    
    self.trip_customer_details=[tripDict objectForKey:@"trip_customer_details"];
}



-(BOOL) isTripStartRemainingTimeLessThan:(long )valueInMin{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSLocale *indianLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [dateFormat setLocale:indianLocale];
    [dateFormat setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    NSDate *datePickupTime = [dateFormat dateFromString:self.trip_date];
    NSDate * currntDate=[NSDate date];
    long valur48Hours=48*60*60;
    long valur24Hours=24*60*60;
    long valur1Hours=1*60*60;
    long  pickTime=[datePickupTime timeIntervalSince1970];
    long timeDiffBetweenNowAndPick=pickTime-[currntDate timeIntervalSince1970];
    return timeDiffBetweenNowAndPick<=valueInMin;
}
-(void) refreshTripModelWithCompletionBlock:(void (^)(id results, NSError *error))block isShowLoader:(BOOL)isShowLoader
{
    if(![self.trip_Id  isKindOfClass:[NSString class]]){
        return;
    }
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{
                                                                                
                                                                                @"trip_id" :self.trip_Id
                                                                                }];
    if(isShowLoader)
    {
        [UtilityClass setLH:NO wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
    }
    [GIC mkwu:TRIP_GETTRIP    d:dict    isa:NO    cb:^(id results, NSError *error) {
           if(isShowLoader)
           {
               [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
           }
           if ([[[results objectForKey:P_STATUS] uppercaseString] isEqualToString:@"OK"]) {
               if([[results objectForKey:P_RESPONSE] isKindOfClass:[NSArray class]]){
                   NSArray * arrTrip=[results objectForKey:P_RESPONSE];
                   if ([arrTrip isKindOfClass:[NSArray class]]){
                       if(arrTrip.count>0)  {
                           [self parseResponse:[arrTrip  objectAtIndex:0]];
                       }
                   }
               }else{
                   defaults_remove(TRIP_ID);
               }
           }
           block(results,error);
       }];
}
-(void) refreshTripModelWithDriverId:(NSString *) driverId completionBlock:(void (^)(id results, NSError *error))block isShowLoader:(BOOL)isShowLoader{
  
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{
        @"trip_id" :self.trip_Id,
        P_DRIVER_ID:driverId
    }];
    if(isShowLoader)  {
        [UtilityClass setLH:NO wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
    }
    [GIC mkwu:TRIP_GETTRIP   d:dict  isa:NO
        cb:^(id results, NSError *error) {
//        self->dateCalled=[NSDate date];
           if(isShowLoader) {
               [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
           }
           if ([[[results objectForKey:P_STATUS] uppercaseString] isEqualToString:@"OK"]) {
               NSArray * arrTrip=[results objectForKey:P_RESPONSE];
               if ([arrTrip isKindOfClass:[NSArray class]]){
                   if(arrTrip.count>0)  {
                       [self parseResponse:[arrTrip  objectAtIndex:0]];
                   }
               }
           }
           block(results,error);
       }];
}


-(void) updateTripModelWith:(NSDictionary *) dict completionBlock:(void (^)(id results, NSError *error))block isShowLoader:(BOOL)isShowLoader
{
    [self updateTripModelWith:dict completionBlock:block isShowLoader:isShowLoader isSendNotification:NO];
    
}



-(void) updateTripModelWith:(NSDictionary *) dict completionBlock:(void (^)(id results, NSError *error))block isShowLoader:(BOOL)isShowLoader isSendNotification:(BOOL)isSendNotification
{
    
    if(isShowLoader)
    {
        [UtilityClass setLH:NO wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
    }
    [GIC mkwu:TRIP_UPDATE
                  d:dict
      isa:NO
           cb:^(id results, NSError *error) {
           
           if(isShowLoader)
           {
               [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
           }
           if ([[[results objectForKey:P_STATUS] uppercaseString] isEqualToString:@"OK"]) {
               if(isSendNotification)
               {
                   [self sendNotification];
               }
           }
           block(results,error);
       }];
}

-(BOOL) isTripSingleRide
{
     if(self.user.userId==0)
     {
         return YES;
     }
    if(self.user.userId ==1)
    {
        return YES;
    }
    return NO;
}
-(NSString *) getValueForKey:(NSString *) key lang:(NSString*)lang{
    return [[LanguageHelper sharedInstance] getStringWithKey:key currentLanguage:lang];
}


-(void)sendNotification{
    BOOL is_user_login=[defaults_object(P_IS_USER_LOGIN) boolValue];
    NSString * messgae=[self getValueForKey:@"trip_noti_msg_payment_completed" lang:is_user_login?self.driver.d_lang:self.user.u_language];
    if([self isPaid]){
        if([self.trip_pay_mode isEqualToString:CASH_PAY]){
            messgae=[self getValueForKey:@"trip_noti_msg_pay_by_cash" lang:is_user_login?self.driver.d_lang:self.user.u_language];
        }else if([self.trip_pay_mode isEqualToString:HIRE_ME_WALLET_PAY]){
            messgae=[self getValueForKey:@"trip_noti_msg_pay_by_wallet" lang:is_user_login?self.driver.d_lang:self.user.u_language];
        }else if([self.trip_pay_mode isEqualToString:CARD]){
            messgae=[self getValueForKey:@"trip_noti_msg_pay_by_card" lang:is_user_login?self.driver.d_lang:self.user.u_language];
        }
    }
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{
        @"message"          :messgae,
        @"content-available":@"1",
    }];
 
    if(is_user_login){
        if(self.driver.deviceToken!=nil){
            if ([self.driver.deviceType isEqualToString:IOS]) {
                [dict setObject:self.driver.deviceToken forKey:IOS_TOKEN];
            }
            else{
                [dict setObject:self.driver.deviceToken forKey:ANDROID_TOKEN];
            }
        }
        [dict setObject:@"driver" forKey:@"to"];
    }else{
        if(self.user.deviceToken!=nil){
            if ([self.user.deviceType isEqualToString:IOS]) {
                [dict setObject:self.user.deviceToken forKey:IOS_TOKEN];
            }
            else{
                [dict setObject:self.user.deviceToken forKey:ANDROID_TOKEN];
            }
        }
        [dict setObject:@"user" forKey:@"to"];
    }
    [dict setObject:self.trip_Id forKey:@"trip_id"];
    [dict setObject:@"Cash" forKey:@"trip_status"];
    if ([[dict objectForKey:IOS_TOKEN] length]==0  && [[dict objectForKey:ANDROID_TOKEN] length]==0) {
        return;
    }
    
    [GIC mk:url_notification to:send_user_notification
                  d:dict
      isa:NO
                    cb:^(id results, NSError *error) {
        if ([[[results objectForKey:P_STATUS] uppercaseString] isEqualToString:@"OK"]) {
            
        }
    }];
}

-(BOOL) isTripCancelled{
    BOOL isCancelled=[self.trip_Status isEqualToString:TS_DRIVER_CANCEL]||[self.trip_Status isEqualToString:TS_DRIVER_CANCEL_AT_PICKUP]||[self.trip_Status isEqualToString:TS_DRIVER_CANCEL_AT_DROP]||[self.trip_Status isEqualToString:@"cancel"]||[self.trip_Status isEqualToString:TS_RIDER_CANCEL_CANCEL];
    return isCancelled;
}


-(BOOL) isTripCancelledForPay{
    BOOL isCancelled=[self.trip_Status isEqualToString:TS_DRIVER_CANCEL]||[self.trip_Status isEqualToString:TS_DRIVER_CANCEL_AT_PICKUP]||[self.trip_Status isEqualToString:@"cancel"]||[self.trip_Status isEqualToString:TS_RIDER_CANCEL_CANCEL];
    return isCancelled;
}

-(BOOL) isPaid
{
    return  [self.trip_pay_status isEqualToString:TS_PAID];
}

- (NSComparisonResult)compare:(TripModel *)other
{
    return [self.trip_Id integerValue]<[other.trip_Id integerValue];
}

-(BOOL) isTripDropLocationOptional
{
    if([self.trip_drop_lat doubleValue]==0.0&&[self.trip_drop_long doubleValue]==0.0)
    {
        return YES;
    }
    return NO;
}
-(void)sendNotificationAccepted{
    NSString * messgae=@"";
    if([self.trip_Status isEqualToString:TS_ACCEPTED]){
        messgae=[self getValueForKey:@"trip_noti_msg_offer_accepted"  lang:self.driver.d_lang];
    }
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{ @"message":messgae, @"content-available":@"1",}];
    if(self.driver.deviceToken){
        if ([self.driver.deviceType isEqualToString:IOS]) {
            [dict setObject:self.driver.deviceToken forKey:IOS_TOKEN];
        }
        else{
            [dict setObject:self.driver.deviceToken forKey:ANDROID_TOKEN];
        }
    }
    [dict setObject:[NSString stringWithFormat:@"%@",self.trip_Id] forKey:TRIP_ID];
    [dict setObject:isEmpty(self.trip_Status) forKey:TRIP_STATUS];
    if ([[dict objectForKey:IOS_TOKEN] length]==0  && [[dict objectForKey:ANDROID_TOKEN] length]==0) {
        return;
    }
    [dict setObject:@"driver" forKey:@"to"];
    [GIC mk:url_notification to:send_driver_notification
                  d:dict
      isa:NO
                    cb:^(id results, NSError *error) {
        if ([[[results objectForKey:P_STATUS] uppercaseString] isEqualToString:@"OK"]) {
        }
    }];
}
-(void)sendNotificationAssigned{
    NSString * messgae=@"";
    if([self.trip_Status isEqualToString:TS_ASSIGNED]){
        messgae=[self getValueForKey:@"trip_noti_msg_offer_accepted" lang:self.driver.d_lang];
    }
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{ @"message":messgae, @"content-available":@"1",}];
    if(self.driver.deviceToken){
        if ([self.driver.deviceType isEqualToString:IOS]) {
            [dict setObject:self.driver.deviceToken forKey:IOS_TOKEN];
        }
        else{
            [dict setObject:self.driver.deviceToken forKey:ANDROID_TOKEN];
        }
    }
    [dict setObject:[NSString stringWithFormat:@"%@",self.trip_Id] forKey:TRIP_ID];
    [dict setObject:isEmpty(self.trip_Status) forKey:TRIP_STATUS];
    if ([[dict objectForKey:IOS_TOKEN] length]==0  && [[dict objectForKey:ANDROID_TOKEN] length]==0) {
        return;
    }
    [dict setObject:@"driver" forKey:@"to"];
    [GIC mk:url_notification to:send_driver_notification
                  d:dict
      isa:NO
                    cb:^(id results, NSError *error) {
        if ([[[results objectForKey:P_STATUS] uppercaseString] isEqualToString:@"OK"]) {
        }
    }];
}

-(BOOL)isPickedLocal{
    NSString *localTripStatus=defaults_object(DRIVER_STATUS_TEMP);
    if(localTripStatus!=nil &&[localTripStatus isEqualToString:TS_PICKED]) {
        return YES;
    }
    return NO;
}


-(void) createStripUserCreatePaymentIntentDone:(UIViewController *)controller trip_fare:(float)trip_fare completionBlock:(void (^)(id _Nullable results,   NSError * _Nullable error))block
{
//    amount=amount+5000;
    NSDictionary *dict1 = [[NSUserDefaults standardUserDefaults]objectForKey:P_USER_DICT_LOGGED];
    [UtilityClass setLH:NO wt:[LanguageHelper getStringWithKey:@"k_53_s3_please_wait"]];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    CityModel *cModel=[CityModel getCityByCityId:self.city_id];
    ConstantModel *consModel=[ConstantModel getConstantsObject];
    NSURLCredential *credential = [NSURLCredential credentialWithUser:isEmpty(consModel.stripe_s_key)/*STRIPE_SECRET_KEY*/ password:@"" persistence:NSURLCredentialPersistenceNone];
    NSString * stripeCustomerId = isEmpty([ConstantModel getConstantsObject].is_stripe_live?[dict1 objectForKey:P_STRIPE_CUS_ID]:[dict1 objectForKey:P_STRIPE_DEV_CUS_ID]);
    if([ConstantModel getConstantsObject].is_stripe_live==NO){
        if(stripeCustomerId){
#if TARGET_OS_SIMULATOR
            stripeCustomerId = P_STRIPE_CUS_DEV_CUS_ID;
#else

#endif
        }
    }
    NSDictionary *parameters = @{@"amount":  [NSString stringWithFormat:@"%ld",(long)ceil(trip_fare *100)],@"currency":cModel.pg_cur,@"payment_method":self.payment_card_id,@"statement_descriptor_suffix":[NSString stringWithFormat:@"Trip ID = %@",self.trip_Id],@"confirm":@"true",@"customer": stripeCustomerId,@"capture_method":@"manual",@"payment_method_types[]":@"card"};
    NSMutableURLRequest *request= [manager.requestSerializer requestWithMethod:@"POST" URLString:@"https://api.stripe.com/v1/payment_intents" parameters:parameters error:nil];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCredential:credential];
    [operation setResponseSerializer:[AFJSONResponseSerializer alloc]];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Success: %@", responseObject);
        NSDictionary * error=[responseObject objectForKey:@"error"];
        [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_53_s3_please_wait"]];
        if(error==nil)  {
//            [self payWithCardDetectComssion:responseObject];
            block(responseObject,nil);
        }else{
            
            [UtilityClass swa:@"Payment failed!" m: isEmpty([error objectForKey:@"message"]) cbt:@"Ok" obt:nil vc:controller];
            block(nil,nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Failure: %@", error);
        [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_53_s3_please_wait" ]];
        
        [UtilityClass swa:@"Error!" m: isEmpty(error.localizedDescription ?: @"") cbt:@"Ok" obt:nil vc:controller];
        
        block(nil,error);
    }];
    [manager.operationQueue addOperation:operation];
}


-(void) createStripUserCreatePaymentIntentDonetrip_fare:(float)trip_fare completionBlock:(void (^)(id _Nullable results,   NSError * _Nullable error,NSString * _Nullable))block
{
    [UtilityClass setLH:NO wt:[LanguageHelper getStringWithKey:@"k_53_s3_please_wait"]];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    CityModel *cModel=[CityModel getCityByCityId:self.city_id];
    ConstantModel *consModel=[ConstantModel getConstantsObject];
    NSURLCredential *credential = [NSURLCredential credentialWithUser:isEmpty(consModel.stripe_s_key)/*STRIPE_SECRET_KEY*/ password:@"" persistence:NSURLCredentialPersistenceNone];
    NSString * stripeCustomerId = isEmpty([ConstantModel getConstantsObject].is_stripe_live?self.user.stripe_cust_id:self.user.stripe_dev_cust_id);
    NSDictionary *parameters = @{@"amount":  [NSString stringWithFormat:@"%ld",(long)ceil(trip_fare *100)],@"currency":cModel.pg_cur,@"payment_method":self.payment_card_id,@"statement_descriptor_suffix":[NSString stringWithFormat:@"Trip ID = %@",self.trip_Id],@"confirm":@"true",@"customer": stripeCustomerId,@"capture_method":@"manual",@"payment_method_types[]":@"card"};
    NSMutableURLRequest *request= [manager.requestSerializer requestWithMethod:@"POST" URLString:@"https://api.stripe.com/v1/payment_intents" parameters:parameters error:nil];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCredential:credential];
    [operation setResponseSerializer:[AFJSONResponseSerializer alloc]];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Success: %@", responseObject);
        NSDictionary * error=[responseObject objectForKey:@"error"];
        [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_53_s3_please_wait"]];
        if(error==nil)  {
            block(responseObject,nil,nil);
        }else{
            block(nil,nil,[error objectForKey:@"message"]);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Failure: %@", error);
        [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_53_s3_please_wait" ]];
        block(nil,error,nil);
    }];
    [manager.operationQueue addOperation:operation];
}
@end
