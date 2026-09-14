//
//  BookingModel.m
//  PrathiCabs
//
//  Created by Grepix on 11/08/21.
//  Copyright © 2023 Grepixit. All rights reserved.
//
#import "BookingModel.h"
#import <GIKit/GIKit.h>
#import "WebCallConstants.h"
#import "AppDelegate.h"
#import "LanguageHelper.h"
#import "Utilities.h"
#import "EstimatedFare.h"
#import "ConstantModel.h"
#import <Conrra-Swift.h>
@implementation BookingModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.tripDate=[NSDate date];
        self.num_seats=1;
    }
    return self;
}
-(void) callFareEstimateApiWithCompletionBlock:(void (^)(id results, NSError *error)) block  promoCode:(PromoCodeModel *) promoCode{
//    if(self.bookingType == RENTALS){
//        [self callFareEstimateForRentalsApiWithCompletionBlock:block promoCode:promoCode];
//        return;
//    }
    NSMutableDictionary * dict=[[NSMutableDictionary alloc] init];
    [dict setObject:[NSString stringWithFormat:@"%f",self.direction.source.coordinate.latitude] forKey:@"trip_scheduled_pick_lat"];
    [dict setObject:[NSString stringWithFormat:@"%f",self.direction.source.coordinate.longitude] forKey:@"trip_scheduled_pick_lng"];
    [dict setObject:isEmpty(self.direction.pickAddress) forKey:@"trip_from_loc"];
    [dict setObject:[NSString stringWithFormat:@"%f",self.direction.destination.coordinate.latitude] forKey:@"trip_scheduled_drop_lat"];
    [dict setObject:[NSString stringWithFormat:@"%f",self.direction.destination.coordinate.longitude] forKey:@"trip_scheduled_drop_lng"];
    [dict setObject:isEmpty(self.direction.dropAddress) forKey:@"trip_to_loc"];
    [dict  setObject:[NSString stringWithFormat:@"%@",[Utilities getStringFromDate:self.tripDate]] forKey:@"trip_date"];
    float distanceConvertedInUnit=0.0;
    if (isDistanceUnitKm(self.cityModel.city_dist_unit)) {
        distanceConvertedInUnit =self.totalDistance;
    }
    else{
        distanceConvertedInUnit = self.totalDistance*0.621371192;
    }
    [dict  setObject:[NSString stringWithFormat:@"%.3f",distanceConvertedInUnit] forKey:@"trip_distance"];
    [dict  setObject:[NSString stringWithFormat:@"%d",self.totalTime] forKey:@"trip_hrs"];
    if(self.cityModel){
        [dict setObject:[NSString stringWithFormat:@"%d",self.cityModel.city_id] forKey:P_CITY_ID];
    }
    if(self.num_seats>0){
        [dict  setObject:[NSString stringWithFormat:@"%d",self.num_seats] forKey:@"seats"];
    }else{
        [dict  setObject:@"1" forKey:@"seats"];
    }
    if(promoCode){
        //promo_code, promo_id, user_id
       
        [dict  setObject:[NSString stringWithFormat:@"%@",promoCode.promoCode] forKey:@"promo_code"];
//        [dict  setObject:[NSString stringWithFormat:@"%@",promoCode.promoCode] forKey:@"promo_code"];
    }else{
        
//        if(!self.isAutoAppliedOTP){
//            NSMutableArray * promos=[[NSMutableArray alloc] init];
//            for (PromoCode *promo in [APP_DELEGATE arrayPromoCode]) {
//                [promos addObject:promo.promo_code];
//            }
//            [dict  setObject:[promos componentsJoinedByString:@","] forKey:@"promo_code"];
//        }
    }
    NSDictionary *dictUser= defaults_object(P_USER_DICT);
    if(dictUser){
        [dict  setObject:[dictUser  objectForKey:P_USER_ID] forKey:P_USER_ID];
    }
    EncodePolylineHelperSwift * incode=[[EncodePolylineHelperSwift alloc] init];
    NSString *encodedData=[incode encodePointWithLocations:self.routeArray];
    [dict  setObject:isEmpty(encodedData) forKey:@"polyline"];

    [UtilityClass setLH:NO wt:[LanguageHelper getStringWithKey:@"k_r16_s3_plz_wait"]];
    [GIC mkwerwu:API_ESTIMATE_FARE_NORMAL
                                    d:dict
              cb:^(id results, NSError *error) {
        [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_r16_s3_plz_wait"]];
        if(error!=nil){
            
        }
        if([[[results objectForKey:P_STATUS] uppercaseString]isEqualToString:@"OK"]){
            self.fareEstimated=[[NSMutableDictionary alloc] init];
            self.isAutoAppliedOTP=YES;
            NSDictionary * response=[results objectForKey:P_RESPONSE];
            if([response isKindOfClass:[NSDictionary class]]){
                NSArray *keys=[response allKeys];
                for (NSString  *key in keys) {
                    EstimatedFare *estimated=[[EstimatedFare alloc] initItemWithDict:[response objectForKey:key]];
                    [self.fareEstimated setObject:estimated forKey:[NSString stringWithFormat:@"%@",key]];
                }
            }
        }
        block(results, error);
    }];
}


-(PromoCode *) poromCodeApplied{
//    NSArray *keys=[self.fareEstimated allKeys];
//    for (NSString  *key in keys) {
//        EstimatedFare *estimated=[self.fareEstimated objectForKey:key];
//        if(estimated.trip_promo_amt>0){
//            for (PromoCode *promo in [APP_DELEGATE arrayPromoCode]) {
//                 if([promo.promo_id isEqualToString:estimated.promo_id]){
//                     return promo;
//                 }
//            }
//        }
//    }
    return  nil;
}





-(NSMutableDictionary *) prepareAPIData{
    NSMutableDictionary *dict=[[NSMutableDictionary alloc] init];
    NSDictionary *dict1 = [[NSUserDefaults standardUserDefaults]objectForKey:P_USER_DICT];
    [dict  setObject:[dict1  objectForKey:P_API_KEY] forKey:P_API_KEY];
    [dict  setObject:[dict1  objectForKey:P_USER_ID] forKey:P_USER_ID];
    EstimatedFare * estimatedFare=[self getEstimateFareForCategory :self.category.categoryId];
    [dict  setObject:[NSString stringWithFormat:@"%d",self.category.categoryId] forKey:P_CATEGORY_ID];
    [dict  setObject:isEmpty(self.cityModel.city_cur) forKey:@"trip_currency"];
    [dict  setObject:[Utilities formatAmount:estimatedFare.trip_base_fare] forKey:@"trip_base_fare"];
    [dict  setObject:[NSString stringWithFormat:@"%d",(self.totalTime)] forKey:@"trip_total_time"];
    [dict  setObject:[Utilities formatAmount:(estimatedFare.trip_pay_amount)] forKey:@"trip_pay_amount"];
    [dict  setObject:[Utilities formatAmount:(estimatedFare.tax_amt)] forKey:@"tax_amt"];
    
    float distanceConvertedInUnit=0.0;
    if (isDistanceUnitKm(self.cityModel.city_dist_unit)) {
        distanceConvertedInUnit =self.totalDistance;
    }
    else{
        distanceConvertedInUnit = self.totalDistance*0.621371192;
    }
    [dict  setObject:[Utilities formatDistance:distanceConvertedInUnit] forKey:@"trip_distance"];
    
    [dict  setObject:isEmpty(self.cityModel.city_dist_unit) forKey:@"trip_dunit"];
    [dict  setObject:isEmpty(self.pay_card) forKey:@"pay_card"];
    if(self.pay_intent.length>0){
        [dict  setObject:isEmpty(self.pay_intent) forKey:@"pay_intent"];
    }
    [dict  setObject:[NSString stringWithFormat:@"%f",self.direction.destination.coordinate.latitude] forKey:@"trip_scheduled_drop_lat"];
    [dict  setObject:[NSString stringWithFormat:@"%f",self.direction.destination.coordinate.longitude]   forKey:@"trip_scheduled_drop_lng"];
    
    [dict  setObject:[NSString stringWithFormat:@"%f",self.direction.source.coordinate.latitude]  forKey:@"trip_scheduled_pick_lat"];
    [dict  setObject:[NSString stringWithFormat:@"%f",self.direction.source.coordinate.longitude]  forKey:@"trip_scheduled_pick_lng"];
    
    
    
    [dict  setObject:self.direction.dropAddress forKey:@"trip_to_loc"]; // drop
    [dict  setObject:self.direction.pickAddress  forKey:@"trip_from_loc"];
    [dict  setObject:TS_REQUEST forKey:TRIP_STATUS];
    
    [dict  setObject:[NSString stringWithFormat:@"%@",[Utilities getStringFromDate:[NSDate date]]] forKey:@"trip_date"];
    
   
//    if(self.direction.postalCodePickUp){
//        [dict  setObject:isEmpty(self.direction.postalCodePickUp) forKey:@"trip_suburb"];
//    }
//
    
    if(self.stringPassengerDetail!=nil) {
        [dict  setObject:self.stringPassengerDetail forKey:@"trip_customer_details"];
    }
    
    [dict  setObject:@"1" forKey:@"seats"];
    
    if(self.cityModel){
        [dict setObject:[NSString stringWithFormat:@"%d",self.cityModel.city_id] forKey:P_CITY_ID];
    }
   
    NSString * estimatedJson =[self jsonEstimateDataForTripId:dict];
    if(estimatedJson){
        [dict setObject:estimatedJson forKey:@"est_data"];
    }
    if(estimatedFare.toll_charges>0){
        [dict setObject:[Utilities formatAmount:estimatedFare.toll_charges] forKey:@"toll_charges"];
    }
//
    
//    if([self isAirportRequest:self.cityModel.city_id location:self.direction.source]){
//        [dict  setObject:@"1" forKey:@"is_airport"];
//    }
//    AirportModel *airport=[self isAirportRequestObject:self.cityModel.city_id location:self.direction.source];
//    if(airport!=nil){
//        [dict  setObject:isEmpty(airport.airport_id) forKey:@"airport_id"];
//        [dict  setObject:@"1" forKey:@"is_airport"];
//    }
    
   
//    [dict  setObject:isEmpty(self.txtDestinationAddres.text) forKey:@"trip_search_result_addr"];
//    [dict  setObject:self.txtPickupDetails.text forKey:@"pickup_notes"];
//
//    if(isShareRideButtonTap)  {
//        [dict setObject:@"1" forKey:@"is_share"];
//    }
    
//    if(self->dictCustomiseOptions.count>0){
//        NSMutableArray *array=[[NSMutableArray alloc] init];
//        NSArray * arrayKeys=[dictCustomiseOptions allKeys];
//        for (NSString * key in arrayKeys) {
//            NSArray *arrayObject=[dictCustomiseOptions objectForKey:key];
//            for (ExtraOption * exOption in arrayObject) {
//                [array addObject:exOption.extra_option_id];
//            }
//        }
//        [dict setObject:[array componentsJoinedByString:@","] forKey:@"extra_options"];
//        if(self->parentDetailsEntered)
//        {
//            [dict setObject:isEmpty(parentDetailsEntered) forKey:@"co_pass_info"];
//        }
//    }
     if([estimatedFare.promo_id intValue]>0){
         [dict setObject:isEmpty(estimatedFare.promo_id) forKey:@"promo_id"];
         [dict setObject:isEmpty(estimatedFare.promo_code) forKey:@"trip_promo_code"];
     }
    return dict;
}

-(EstimatedFare *) getEstimateFareForCategory:(int) category_id{
    return [self.fareEstimated objectForKey:[NSString stringWithFormat:@"%d",category_id]];
}








-(NSString *) jsonEstimateDataForTripId:(NSDictionary  * ) dict
{
    EstimatedFare * estimatedFare=[self getEstimateFareForCategory :self.category.categoryId];
    NSMutableDictionary * dictEst=[[NSMutableDictionary alloc] initWithDictionary:estimatedFare.distReponse];
    
    
//    ConstantModel *constantModel=[ConstantModel getConstantsObject];
    /*   change the estimate json on date 31 may
        NSDictionary *dictEstimate=@{
            @"trip_currency":isEmpty([dict objectForKey:@"trip_currency"]),
            @"trip_base_fare":isEmpty([dict objectForKey:@"trip_base_fare"]),
            @"trip_total_time":isEmpty([dict objectForKey:@"trip_total_time"]),
            @"trip_pay_amount":isEmpty([dict objectForKey:@"trip_pay_amount"]),
            @"tax_amt":isEmpty([dict objectForKey:@"tax_amt"]),
            @"city_dist_unit":isEmpty([dict objectForKey:@"trip_dunit"]),
            @"trip_distance":isEmpty([dict objectForKey:@"trip_distance"]),
            @"capture_amt":[Utilities formatAmount:constantModel.capture_multiplier *[[dict objectForKey:@"trip_pay_amount"] floatValue]]
        };
    */
    
    
    NSDictionary *dictEstimate=@{
            @"city_dist_unit":isEmpty([dict objectForKey:@"trip_dunit"]),
             @"trip_currency":isEmpty([dict objectForKey:@"trip_currency"]),
            @"trip_distance":isEmpty([dict objectForKey:@"trip_distance"]),
            @"trip_total_time":isEmpty([dict objectForKey:@"trip_total_time"]),
             @"trip_base_fare":isEmpty([dict objectForKey:@"trip_base_fare"]),
//            @"capture_amt":[Utilities formatAmount:constantModel.capture_multiplier *[[dict objectForKey:@"trip_pay_amount"] floatValue]],
            
//             @"capture_multiplier":[NSString stringWithFormat:@"%.2f",constantModel.capture_multiplier],
         };

    [dictEst addEntriesFromDictionary:dictEstimate];
    NSError * error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictEst options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return jsonString;
}




-(void) callFareEstimateForRentalsApiWithCompletionBlock:(void (^)(id results, NSError *error)) block  promoCode:(PromoCodeModel *) promoCode{
    NSMutableDictionary * dict=[[NSMutableDictionary alloc] init];
    [dict setObject:[NSString stringWithFormat:@"%f",self.direction.source.coordinate.latitude] forKey:@"trip_scheduled_pick_lat"];
    [dict setObject:[NSString stringWithFormat:@"%f",self.direction.source.coordinate.longitude] forKey:@"trip_scheduled_pick_lng"];
    [dict setObject:isEmpty(self.direction.pickAddress) forKey:@"trip_from_loc"];
    [dict setObject:[NSString stringWithFormat:@"%f",self.direction.destination.coordinate.latitude] forKey:@"trip_scheduled_drop_lat"];
    [dict setObject:[NSString stringWithFormat:@"%f",self.direction.destination.coordinate.longitude] forKey:@"trip_scheduled_drop_lng"];
    [dict setObject:isEmpty(self.direction.dropAddress) forKey:@"trip_to_loc"];
    [dict  setObject:[NSString stringWithFormat:@"%@",[Utilities getStringFromDate:self.tripDate]] forKey:@"trip_date"];
    float distanceConvertedInUnit=0.0;
    if (isDistanceUnitKm(self.cityModel.city_dist_unit)) {
        distanceConvertedInUnit =self.totalDistance;
    }
    else{
        distanceConvertedInUnit = self.totalDistance*0.621371192;
    }
    [dict  setObject:[NSString stringWithFormat:@"%.3f",distanceConvertedInUnit] forKey:@"trip_distance"];
    [dict  setObject:[NSString stringWithFormat:@"%d",self.totalTime] forKey:@"trip_hrs"];
    if(self.cityModel){
        [dict setObject:[NSString stringWithFormat:@"%d",self.cityModel.city_id] forKey:P_CITY_ID];
    }
    if(promoCode){
        //promo_code, promo_id, user_id
       
        [dict  setObject:[NSString stringWithFormat:@"%@",promoCode.promoCode] forKey:@"promo_code"];
//        [dict  setObject:[NSString stringWithFormat:@"%@",promoCode.promoCode] forKey:@"promo_code"];
    }else{
        
//        if(!self.isAutoAppliedOTP){
//            NSMutableArray * promos=[[NSMutableArray alloc] init];
//            for (PromoCode *promo in [APP_DELEGATE arrayPromoCode]) {
//                [promos addObject:promo.promo_code];
//            }
//            [dict  setObject:[promos componentsJoinedByString:@","] forKey:@"promo_code"];
//        }
    }
    NSDictionary *dictUser= defaults_object(P_USER_DICT);
    if(dictUser){
        [dict  setObject:[dictUser  objectForKey:P_USER_ID] forKey:P_USER_ID];
    }
    EncodePolylineHelperSwift * incode=[[EncodePolylineHelperSwift alloc] init];
    NSString *encodedData=[incode encodePointWithLocations:self.routeArray];
    [dict  setObject:isEmpty(encodedData) forKey:@"polyline"];

    [UtilityClass setLH:NO wt:[LanguageHelper getStringWithKey:@"k_r16_s3_plz_wait"]];
    [GIC mkwerwu:API_ESTIMATE_FARE_NORMAL
                                    d:dict
              cb:^(id results, NSError *error) {
        [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_r16_s3_plz_wait"]];
        if(error!=nil){
            
        }
        if([[[results objectForKey:P_STATUS] uppercaseString]isEqualToString:@"OK"]){
            self.fareEstimated=[[NSMutableDictionary alloc] init];
            self.isAutoAppliedOTP=YES;
            NSDictionary * response=[results objectForKey:P_RESPONSE];
            if([response isKindOfClass:[NSDictionary class]]){
                NSArray *keys=[response allKeys];
                for (NSString  *key in keys) {
                    EstimatedFare *estimated=[[EstimatedFare alloc] initItemWithDict:[response objectForKey:key]];
                    [self.fareEstimated setObject:estimated forKey:[NSString stringWithFormat:@"%@",key]];
                }
            }
        }
        block(results, error);
    }];
}

@end
