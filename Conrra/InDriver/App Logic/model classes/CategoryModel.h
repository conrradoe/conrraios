//
//  CategoryModel.h
//  HIREME_RIDER
//
//  Created by Appicial Taxi App Solutions on 15/06/17.
//  Copyright © 2023 Appicial. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BasePriceTimeModel.h"
#import "CityModel.h"
#import "PromoCodeModel.h"
#define TOTAL_BASE @"total_base"
#define TOTAL_AMT @"total_amt"
#define TAX_AMT @"tax_amt"
#define SHARE_DIS @"share_dis"
#define TOTAL_BASE_PROMO @"total_base_with_promo"
#define TOTAL_AMT_PROMO @"total_amt_with_promo"
#define TAX_AMT_PROMO @"tax_amt_with_promo"
#define SHARE_DIS_PROMO @"share_dis_with_promo"
#define TRIP_DURATION @"trip_duration"
#define PROMO_DIS @"promo_dis"
@interface CategoryModel : NSObject
//@property(strong,nonatomic) NSMutableArray<BasePriceTimeModel *> *basePriceTimeModel;
@property(assign, nonatomic) int categoryId;
@property(assign, nonatomic) float cat_base_price;
@property(assign, nonatomic) float cat_fare_per_km;
@property(assign, nonatomic) float cat_fare_per_min;
@property(assign, nonatomic) NSString *cat_special_fare;
@property(assign, nonatomic) NSString *cat_special_fare_json;
@property(assign, nonatomic) BOOL cat_is_fixed_price;
@property(assign,nonatomic) float cat_prime_time_percentage;
@property(assign,nonatomic) float cat_base_includes;
@property(assign,nonatomic) float wait_free_min;
@property(assign,nonatomic) float wait_per_min;
@property(strong,nonatomic) NSString *cat_name;
@property(strong,nonatomic) NSString *cat_map_icon_path;
@property(strong,nonatomic) NSString *share_disc_json;
@property(strong,nonatomic) NSDictionary *sharePriceDict;
@property(assign,nonatomic) float cat_ppd;
@property(assign, nonatomic) BOOL show_paymode;
@property(assign, nonatomic) BOOL show_fare;
//@property(strong,nonatomic) NSMutableArray *daysSpecialFareArray;
@property(strong,nonatomic) NSMutableDictionary *daysSpecialFareDict;
@property(strong,nonatomic) NSString *cat_image_path;
@property(strong,nonatomic) NSString *cat_sort_order;
@property(assign,nonatomic) BOOL is_share;

@property(assign, nonatomic) float d_can_fee;
@property(assign, nonatomic) float r_can_fee;
@property(assign, nonatomic) int r_can_free_min;
@property(assign, nonatomic) int d_can_free_min;
@property(assign, nonatomic) int cat_max_size;

@property(assign, nonatomic) float max_offer_perc;
@property(assign, nonatomic) float min_offer_perc;

-(instancetype) initWithDict:(NSDictionary *) dict;

-(NSDictionary *) calculatePrice:(float )distance time:(long)min :(NSDate*)pickTime :(NSDate*)dropTime waitingTime:(long)waitingTime ;
-(NSDictionary *) calculatePriceWhitOut:(float )distance time:(long)min  :(NSDate*)pickTime :(NSDate*)dropTime waitingTime:(long)waitingTime;
+(NSMutableArray * ) parseResponse:(NSArray * ) arrCategory;
-(float) calculatePrice:(float )distance time:(long)min waitingTime:(long)waitingTime;
-(NSDictionary *) calculatePriceDict:(float )distance time:(int)min city_id:(int) city_id pormoCode:(PromoCodeModel *) promoCode;
+(CategoryModel *) getCategoryByid:(int )categoryId;

-(BOOL) isAllowToCheckMaxMin;

@end
