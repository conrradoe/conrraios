//
//  HomeDataModel.m
//  LT Partner
//
//  Created by Grepix on 19/01/21.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import "HomeDataModel.h"
#import "ConstantModel.h"
#import "AppDelegate.h"
#import "Utilities.h"
#import "PromoCodeModel.h"
#import <QuartzCore/QuartzCore.h>
@implementation HomeDataModel{
    ConstantModel *constant;
}
 

-(void)setTripModel:(TripModel *)trip{
    self.trip=trip;
    constant=[ConstantModel getConstantsObject];
    self.category=  [CategoryModel getCategoryByid:[trip.category_id intValue]];
    self.city=[CityModel getCityByCityId:trip.city_id];
}





-(NSMutableDictionary *)prepareDataForBegin:(NSString *)actualPickupLocationAddress{
    NSMutableDictionary * dict=[[NSMutableDictionary alloc] init];
    NSString *pickTime = [NSString stringWithFormat:@"%@",[Utilities getStringFromDate:[NSDate date]]];
    [dict  setObject:pickTime forKey:@"trip_pickup_time"];
    if(constant.otp_end){
        [dict  setObject:[Utilities getRandomPINString:5] forKey:@"otp"];
    }
    AppDelegate *appdelegate=APP_DELEGATE;
    [dict setObject:[NSString stringWithFormat:@"%f",appdelegate.currLoc.coordinate.latitude] forKey:@"trip_actual_pick_lat"];
    [dict setObject:[NSString stringWithFormat:@"%f",appdelegate.currLoc.coordinate.longitude] forKey:@"trip_actual_pick_lng"];
    if(actualPickupLocationAddress.length>0){
        [dict setObject:[NSString stringWithFormat:@"%@",actualPickupLocationAddress] forKey:@"actual_from_loc"];
    }
    return dict;
}




- (void)updateLocalAfterUpdateBegin:(NSMutableDictionary *)dict{
    self.trip.actual_from_loc=isEmpty([dict objectForKey:@"actual_from_loc"]);
    self.trip.otp=[dict objectForKey:@"otp"];
    self.trip.trip_pickup_time=[dict objectForKey:@"trip_pickup_time"];
    self.trip.trip_Status=[dict objectForKey:TRIP_STATUS];
}




- (void)updateLocalAfterUpdateEnd:(NSMutableDictionary *)dict{
    self.trip.actual_to_loc=isEmpty([dict objectForKey:@"actual_to_loc"]);
    self.trip.trip_fare=[dict objectForKey:@"trip_pay_amount"];
    self.trip.trip_drop_time=[dict objectForKey:@"trip_drop_time"];
    self.trip.tax_amount=[dict objectForKey:@"tax_amt"];
    self.trip.trip_total_time=[[dict objectForKey:@"trip_total_time"] intValue];
}




-(int) calculateMinutesBetweenTwoDate:(NSDate*) date1 date2:(NSDate *)date2{
    NSTimeInterval secondsBetween = [date2 timeIntervalSinceDate:date1];
    
    int minutes = secondsBetween / 60;
    int secondRem = ((long)secondsBetween)%60;
    if(secondRem>0)
    {
        minutes=minutes+1;
    }
    if (isnan(minutes)) {
        minutes = 0.0;
    }
    return minutes;
}





-(NSMutableDictionary *) prepareDataForEnd:(NSString *)actualDropLocationAddress TotalTripDIstance:(float )TotalTripDIstance promoCode:(PromoCodeModel *) promoCode { NSMutableDictionary * dict=[[NSMutableDictionary alloc] init];
    NSString *dropTime = [NSString stringWithFormat:@"%@",[Utilities getStringFromDate:[NSDate date]]];
    [dict  setObject:dropTime forKey:@"trip_drop_time"];
    NSDate *date1 = [Utilities GetGMTDatetoLocalTZ1:self.trip.trip_pickup_time];
    NSDate *date2 = [Utilities GetGMTDatetoLocalTZ1:dropTime];
    int minutes = [self calculateMinutesBetweenTwoDate:date1 date2:date2];
    int trip_total_time=minutes;
    long watiTime=0;
    NSString *calTime=defaults_object(@"cal_wait_time");
    if(calTime!=nil)  {
        watiTime= [calTime intValue];
    }
    if(watiTime>0&&trip_total_time>watiTime){
        trip_total_time=trip_total_time-watiTime;
    }
    if(watiTime>self.category.wait_free_min){
        watiTime=watiTime-self.category.wait_free_min;
        NSString * string=[NSString stringWithFormat:@"%ld",watiTime];
        [dict setObject:string forKey:@"wait_duration"];
    }else  {
        watiTime=0;
        NSString * string=[NSString stringWithFormat:@"%ld",watiTime];
        [dict setObject:string forKey:@"wait_duration"];
    }
    
    AppDelegate *appdelegate=APP_DELEGATE;
    float distanceConvertedInUnit=0;
    if(isDistanceUnitKm(self.city.city_dist_unit)) {
        distanceConvertedInUnit = TotalTripDIstance;
    }
    else{
        distanceConvertedInUnit =KM_TO_MI(TotalTripDIstance);
    }
  
    [dict setObject:[NSString stringWithFormat:@"%f",appdelegate.currLoc.coordinate.latitude] forKey:@"trip_actual_drop_lat"];
    [dict setObject:[NSString stringWithFormat:@"%f",appdelegate.currLoc.coordinate.longitude] forKey:@"trip_actual_drop_lng"];
    NSDictionary *dictBaseFare=[self.category calculatePriceWhitOut:TotalTripDIstance time:minutes :date1 :date2 waitingTime:watiTime];
    [dict setObject:isEmpty(self.city.city_cur) forKey:@"trip_currency"];
    if(actualDropLocationAddress.length>0){
        [dict setObject:[NSString stringWithFormat:@"%@",actualDropLocationAddress] forKey:@"actual_to_loc"];
    }
    if(!self.trip.is_share){
        float trip_base_fare=[[dictBaseFare objectForKey:@"total_amt"] floatValue];
        float tax1 = 0;
        float totoalAmount = 0;
        float comCommission = 0;
        float trip_driver_commision = 0;
        float total_pay_amount_with_promo=trip_base_fare;
        if([constant getCValueFK:ckey_epr]){
            if(self.trip.isPromoCodeUsed&&promoCode!=nil) {
                float tripFareAfterApllyPromoCode=[promoCode calucalateAmtByPromoCode:trip_base_fare];
                NSString *trip_promo_amt=[Utilities formatAmount:tripFareAfterApllyPromoCode];
                self.trip.trip_promo_amt=trip_promo_amt;
//                [dict setObject:trip_promo_amt forKey:@"trip_promo_amt"];
//                [dict setObject:isEmpty(promoCode.promoId) forKey:@"promo_id"];
//                [dict setObject:isEmpty(promoCode.promoCode) forKey:@"trip_promo_code"];
                total_pay_amount_with_promo=trip_base_fare-tripFareAfterApllyPromoCode;
            }
        }
        tax1 = total_pay_amount_with_promo *self.city.city_tax/100;
        totoalAmount = total_pay_amount_with_promo+tax1 ;
        comCommission = totoalAmount *self.city.city_comm/100;
        trip_driver_commision = totoalAmount -comCommission;
        
//        [dict setObject:[Utilities formatAmount:totoalAmount] forKey:@"trip_pay_amount"];
//        [dict setObject:[Utilities formatAmount:tax1] forKey:@"tax_amt"];
//        [dict setObject:[Utilities formatAmount:trip_driver_commision] forKey:@"trip_driver_commision"];
//        [dict setObject:[Utilities formatAmount:comCommission] forKey:@"trip_comp_commision"];
        [dict setObject:[NSString stringWithFormat:@"%d",trip_total_time] forKey:@"trip_total_time"];
        [dict setObject:[Utilities formatDistance:distanceConvertedInUnit] forKey:@"trip_distance"];
    }
    return dict;
}


-(NSMutableDictionary *) prepareDataForDriverCancelAtPickUp:(NSString *)reasonString
{
    NSMutableDictionary * dict=[[NSMutableDictionary alloc] init];
    [dict setObject:reasonString forKey:TRIP_REASON];

    [dict setObject:@"0.00" forKey:@"trip_distance"];
    [dict setObject:@"1" forKey:@"is_cancelled"];
    return dict;
}




-(NSString *) getValueForKey:(NSString *) key lang:(NSString*)lang{
    return [[LanguageHelper sharedInstance] getStringWithKey:key currentLanguage:lang];
}

-(void)sendNotification:(NSString *)status{
    NSString *message;
    if ( [status isEqualToString:TS_DRIVER_CANCEL_AT_DROP] ) {
        message = [self getValueForKey:@"k_2_s14_trip_conplete" lang:self.trip.user.u_language];
    }
    else if ([status isEqualToString:TS_DRIVER_CANCEL_AT_PICKUP]){
        message =[self getValueForKey:@"k_5_s14_trip_cancelled_by_driver" lang:self.trip.user.u_language];
    }
    else if ([status isEqualToString:TS_ACCEPTED]){
        message = [self getValueForKey:@"k_1_s14_trip_confirm" lang:self.trip.user.u_language];
    }
    else if ([status isEqualToString:TS_ARRIVE]) {
        message = [self getValueForKey:@"k_3_s14_arrive_soon" lang:self.trip.user.u_language];
    }
    else if ([status isEqualToString:TS_END]){
        message = [self getValueForKey:@"k_2_s14_trip_conplete" lang:self.trip.user.u_language];
    }
    else if ([status isEqualToString:TS_BEGIN]){
        message = [self getValueForKey:@"k_4_s14_trip_started" lang:self.trip.user.u_language];
    }
    else if ([status isEqualToString:TS_REJECT])  {
        message = [self getValueForKey:@"k_10_s14_trip_request_rerject" lang:self.trip.user.u_language];
    }
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{ @"message" :message, TRIP_STATUS  :status,TRIP_ID :self.trip.trip_Id, @"content-available":@"1",}];
    if([status isEqualToString:TS_ARRIVE]){
        [ dict  setObject:@"cab_arrive.caf" forKey:@"sound"];
    }
    else if([status isEqualToString:TS_BEGIN]){
        [ dict  setObject:@"vehicle_arrive_soon.caf" forKey:@"sound"];
    }
    else if([status isEqualToString:TS_REJECT]){
        [ dict  setObject:@"driver_cancelled.caf" forKey:@"sound"];
    }
    else if([status isEqualToString:TS_ACCEPTED]){
        [ dict  setObject:@"driver_accepted.caf" forKey:@"sound"];
    }
    else if([status isEqualToString:TS_END]){
        [ dict  setObject:@"trip_complete.caf" forKey:@"sound"];
    }
    if(self.trip.user.deviceToken!=nil) {
        if ([self.trip.user.deviceType isEqualToString:IOS]) {
            [dict setObject:self.trip.user.deviceToken forKey:IOS_TOKEN];
        }
        else{
            [dict setObject:self.trip.user.deviceToken forKey:ANDROID_TOKEN];
        }
    }
    if ([[dict objectForKey:IOS] length]==0  && [[dict objectForKey:ANDROID_TOKEN] length]==0) {
        return;
    }
    [dict setObject:@"user" forKey:@"to"];
    [GIC mk:url_notification to:send_user_notification
                  d:dict
      isa:NO
                    cb:^(id results, NSError *error) {
        if ([[[results objectForKey:P_STATUS]  uppercaseString]isEqualToString:@"OK"]) {
        }
    }];
}
@end
