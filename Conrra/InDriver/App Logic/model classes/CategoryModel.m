//
//  CategoryModel.m
//  HIREME_RIDER
//
//  Created by Appicial Taxi App Solutions on 15/06/17.
//  Copyright © 2023 Appicial. All rights reserved.
//

#import <GIKit/GIKit.h>
#import "CategoryModel.h"
#import "WebCallConstants.h"
#import "ConstantModel.h"
#import "BasePriceTimeModel.h"
#import "CityModel.h"
#import "Utilities.h"
#import "Keys.h"
@implementation CategoryModel
-(instancetype) initWithDict:(NSDictionary *) dict
{
    self=[super init];
    self.max_offer_perc = -1;
    self.min_offer_perc = -1;
    self.categoryId=[[dict objectForKey:P_CATEGORY_ID]  intValue];
    self.cat_base_price=[[dict objectForKey:P_CATEGORY_BASE_PRICE]  floatValue];
    self.cat_fare_per_km=[[dict objectForKey:P_CATEGORY_FARE_PER_KM]  floatValue];
    self.cat_fare_per_min=[[dict objectForKey:P_CATEGORY_FARE_PER_MIN]  floatValue];
    self.cat_special_fare = [dict objectForKey:P_CATEGORY_SPECIAL_FARE];
    self.cat_special_fare_json =[dict objectForKey:P_CATEGORY_SPECIAL_FARE_JSON];
    self.cat_is_fixed_price=[[dict objectForKey:P_CATEGORY_IS_FIXED_PRICE]  boolValue];
    self.cat_prime_time_percentage=[[dict objectForKey:P_CATEGORY_PRIME_TIME_PERCENTAGE]  floatValue];
    self.cat_base_includes=[[dict objectForKey:@"cat_base_includes"]  floatValue];
    self.wait_free_min=[[dict objectForKey:@"wait_free_min"] floatValue];
    self.wait_per_min=[[dict objectForKey:@"wait_per_min"] floatValue];
    self.is_share=[[dict objectForKey:@"is_share"] boolValue];
    self.show_fare=[[dict objectForKey:@"show_fare"] boolValue];
    self.show_paymode=[[dict objectForKey:@"show_paymode"] boolValue];
    if([[dict objectForKey:@"cat_icon_path"] hasPrefix:@"http"]){
        self.cat_image_path  = [dict objectForKey:@"cat_icon_path"];
    }else{
        self.cat_image_path  = [NSString stringWithFormat:@"%@%@",url_base_category,[dict objectForKey:@"cat_icon_path"]];
    }
    self.cat_max_size = [[dict objectForKey:@"cat_max_size"] intValue];
    self.cat_sort_order  = [dict objectForKey:@"sort_order"];
    self.cat_name = [dict objectForKey:P_CATEGORY_NAME];
    
    
    
    if([[dict objectForKey:@"cat_map_icon_path"] hasPrefix:@"http"]){
        self.cat_map_icon_path  = [dict objectForKey:@"cat_map_icon_path"];
    
    }else{
        self.cat_map_icon_path=[NSString stringWithFormat:@"%@%@",url_base_category,[dict objectForKey:@"cat_map_icon_path"]];
    }
    
    self.cat_ppd=[[dict objectForKey:@"cat_ppd"] floatValue];
    self.d_can_fee=[[dict objectForKey:@"d_can_fee"] floatValue];
    self.r_can_fee=[[dict objectForKey:@"r_can_fee"] floatValue];
    self.max_offer_perc=[[dict objectForKey:@"max_offer_perc"] floatValue];
    self.min_offer_perc=[[dict objectForKey:@"min_offer_perc"] floatValue];
    self.d_can_free_min=[[dict objectForKey:@"d_can_free_min"] intValue]*60;
    self.r_can_free_min=[[dict objectForKey:@"r_can_free_min"] intValue]*60;
    
//    self.d_can_free_min=10*60;
    NSString *jsonString = [dict objectForKey:P_CATEGORY_SPECIAL_FARE_JSON];
    NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    if(data){
//        NSDictionary  *priceDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    }
    self.share_disc_json=[dict objectForKey:@"share_disc_json"];
    if(self.share_disc_json)
    {
        NSError *jsonError;
        NSData *objectData = [self.share_disc_json dataUsingEncoding:NSUTF8StringEncoding];
        self.sharePriceDict = [NSJSONSerialization JSONObjectWithData:objectData
                                                             options:NSJSONReadingMutableContainers
                                                               error:&jsonError];
    }
   // [self readBasePriceFareJson:priceDict];
    
    return self;
}



-(NSDictionary *) calculatePrice:(float )distance time:(long)min  :(NSDate*)pickTime :(NSDate*)dropTime waitingTime:(long)waitingTime
{
    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateStyle:NSDateFormatterMediumStyle];
    [dateFormat setDateFormat:@"EE"];
    NSString *dateString = [dateFormat stringFromDate:today];
    NSMutableArray *daysSpecialFareArray=[self.daysSpecialFareDict  objectForKey:dateString];
    
    CityModel * citmodel=[CityModel getCityByDriverCityId];
   
    for (BasePriceTimeModel * basePriceTimeModel in daysSpecialFareArray) {
        if([basePriceTimeModel isTimeBetweenn: dropTime ]){
            self.cat_base_price = basePriceTimeModel.cat_base_price_per_km;
            break;
        }
    }
    
    float distance1 = 0.0;
    if (distance>self.cat_base_includes) {
        
        distance1 = distance-self.cat_base_includes;
    }

    float totalPrice = self.cat_base_price + distance1*self.cat_fare_per_km + ((min-waitingTime)>=0?(min-waitingTime):min)*self.cat_fare_per_min+waitingTime*self.wait_per_min;
    
    
    float tax1 = totalPrice *citmodel.city_tax/100.0;
    totalPrice = totalPrice + tax1;
    
    
    NSDictionary *dict =[[NSDictionary alloc]initWithObjectsAndKeys:[Utilities formatAmount:totalPrice],@"total_amt",[Utilities formatAmount:tax1],@"tax_amt", nil];
    return  dict;
}


-(NSDictionary *) calculatePriceWhitOut:(float )distance time:(long)min  :(NSDate*)pickTime :(NSDate*)dropTime waitingTime:(long)waitingTime
{
    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateStyle:NSDateFormatterMediumStyle];
    [dateFormat setDateFormat:@"EE"];
    NSString *dateString = [dateFormat stringFromDate:today];
    NSMutableArray *daysSpecialFareArray=[self.daysSpecialFareDict  objectForKey:dateString];
    
    for (BasePriceTimeModel * basePriceTimeModel in daysSpecialFareArray) {
        if([basePriceTimeModel isTimeBetweenn: dropTime ]){
            self.cat_base_price = basePriceTimeModel.cat_base_price_per_km;
            break;
        }
    }
    
    CityModel * citmodel=[CityModel getCityByDriverCityId];
    float distance1 = 0.0;
    if (distance>self.cat_base_includes) {
        
        distance1 = distance-self.cat_base_includes;
    }

    float totalPrice = self.cat_base_price + distance1*self.cat_fare_per_km + ((min-waitingTime)>=0?(min-waitingTime):min)*self.cat_fare_per_min+waitingTime*self.wait_per_min;
    
    
    float tax1 = totalPrice *citmodel.city_tax/100.0;
//    totalPrice = totalPrice ;
    
    
    NSDictionary *dict =[[NSDictionary alloc]initWithObjectsAndKeys:[Utilities formatAmount:totalPrice],@"total_amt",[Utilities formatAmount:tax1],@"tax_amt", nil];
    return  dict;
}

-(float) calculatePrice:(float )distance time:(long)min waitingTime:(long)waitingTime
{
    
    CityModel * citmodel=[CityModel getCityByDriverCityId];
   
    float distance1 = 0.0;
    if (distance>self.cat_base_includes) {
        
        distance1 = distance-self.cat_base_includes;
    }
    
     float totalPrice = self.cat_base_price + distance1*self.cat_fare_per_km + ((min-waitingTime)>=0?(min-waitingTime):min)*self.cat_fare_per_min+waitingTime*self.wait_per_min;
//    float totalPrice = self.cat_base_price + distance1*self.cat_fare_per_km + min*self.cat_fare_per_min;
    
    
    float tax1 = totalPrice *citmodel.city_tax/100;
    totalPrice = totalPrice + tax1;
    
    //    if(!self.cat_is_fixed_price)
    //     {
    //         float primepercentage=(totelPrice * self.cat_prime_time_percentage) / 100.0;
    //         totelPrice=totelPrice+primepercentage;
    //     }
    return  totalPrice;
}




+(NSMutableArray * ) parseResponse:(NSArray * ) arrCategory
{
    NSMutableArray * arr=[[NSMutableArray alloc]  init];
    if([arrCategory isKindOfClass:[NSArray class]])
    {
        for (NSDictionary * dict in arrCategory) {
            [arr addObject:[[CategoryModel alloc] initWithDict:dict]];
        }
    }
    return  arr;
}
-(NSString *) formatDateToString:(NSDate *) date
{
    NSDateFormatter *dateFormat=[[NSDateFormatter alloc]init];
    dateFormat.dateStyle=NSDateFormatterNoStyle;
    [dateFormat setDateFormat:@"HH:mm a"];
    NSString *str=[NSString stringWithFormat:@"%@",[dateFormat  stringFromDate:date]];
    return  str;
}
- (void)readBasePriceFareJson:(NSDictionary *)dict
{

    self.daysSpecialFareDict = [[NSMutableDictionary alloc] init];
   for( NSString * key  in [dict allKeys])
    {
        NSArray *days = [dict objectForKey:key];
        NSMutableArray  *daysSpecialFareArray=[[NSMutableArray alloc]  init];
        for (NSDictionary *data in days) {
            BasePriceTimeModel * basePriceTimeModel = [[BasePriceTimeModel alloc] initBasePriceAndTimeWithDict:data.mutableCopy];
            [daysSpecialFareArray addObject:basePriceTimeModel];
        }
        [self.daysSpecialFareDict  setObject:daysSpecialFareArray forKey:key];
    }
}


- (NSDictionary *)JSONFromFile
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"basePriceAnsTime" ofType:@"txt"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    return [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
}


+(CategoryModel *) getCategoryByid:(int )categoryId{
    NSArray * arrCateResponse=defaults_object(@"categoryResponse");
    if(arrCateResponse)
    {
        NSArray *    arrCategory=[CategoryModel parseResponse:arrCateResponse ];
        for (CategoryModel * category in arrCategory) {
            if(category.categoryId == categoryId )
            {
                return category;
            }
        }
    }
    return nil;
}

-(NSDictionary *) calculatePriceDict:(float )distance time:(int)min city_id:(int) city_id pormoCode:(PromoCodeModel *) promoCode
{

    CityModel * cityModel=[CityModel getCityByCityId:city_id];
    float distanceTotal =distance;
    int time =min;
    float distanceWithOutBaseIncludes = 0.0;
    if (distance>self.cat_base_includes) {
        distanceWithOutBaseIncludes = distanceTotal-self.cat_base_includes;
    }
    float baseFareCalculated = self.cat_base_price + distanceWithOutBaseIncludes*self.cat_fare_per_km + time*self.cat_fare_per_min;
    float taxOnBaseFareCalculated = baseFareCalculated *cityModel.city_tax/100.0;
    float totalFareCalculated =baseFareCalculated+taxOnBaseFareCalculated;
    
    
    float totalPriceWithPromo=baseFareCalculated;
    // promocode
    float tripFareAfterApllyPromoCode=0;
    if(promoCode){
        tripFareAfterApllyPromoCode= [promoCode calucalateAmtByPromoCode:totalPriceWithPromo];
    }
    totalPriceWithPromo=totalPriceWithPromo-tripFareAfterApllyPromoCode;
    float totalPriceWithPromoBase=totalPriceWithPromo;
    float taxWithPromo = totalPriceWithPromo *cityModel.city_tax/100.0;
    totalPriceWithPromo = totalPriceWithPromo + taxWithPromo;
    float shareDiscountWithPromo=0;
    float shareDiscountWithOutPromo=0;
    if([self.sharePriceDict isKindOfClass:[NSDictionary class]]){
        shareDiscountWithOutPromo=(totalFareCalculated *[[self.sharePriceDict objectForKey:@"1"] intValue])/100.0;
        shareDiscountWithPromo=(totalPriceWithPromo *[[self.sharePriceDict objectForKey:@"1"] intValue])/100.0;
    }
    
    NSDictionary *dict=@{
        TOTAL_AMT:[Utilities formatAmount:totalFareCalculated],
        TOTAL_BASE:[Utilities formatAmount:baseFareCalculated],
        TAX_AMT:[Utilities formatAmount:taxOnBaseFareCalculated],
        
        SHARE_DIS:[Utilities formatAmount:shareDiscountWithOutPromo],
        TOTAL_BASE_PROMO:[Utilities formatAmount:totalPriceWithPromoBase],
        TOTAL_AMT_PROMO:[Utilities formatAmount:totalPriceWithPromo],
        TAX_AMT_PROMO:[Utilities formatAmount:taxWithPromo],
        SHARE_DIS_PROMO:[Utilities formatAmount:shareDiscountWithPromo],
        PROMO_DIS:[Utilities formatAmount:tripFareAfterApllyPromoCode],
        TRIP_DURATION:[NSString stringWithFormat:@"%d",min]
    };
    return  dict;
}

-(BOOL) isAllowToCheckMaxMin{
    if(self.max_offer_perc > -1 && self.min_offer_perc > -1){
        return YES;
    }
    return NO;
}
@end
