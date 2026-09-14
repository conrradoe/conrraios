//
//  DriverModel.m
//  HIREME_RIDER
//
//  Created by Appicial Taxi App Solutions on 08/06/17.
//  Copyright © 2023 Appicial. All rights reserved.
//

#import "DriverModel.h"
//#import "Constants.h"
#import "WebCallConstants.h"
#import <GIKit/GIKit.h>
//#import "CallAPI.h"
@implementation DriverModel
-(instancetype)initItemWithDict:(NSDictionary *)dict;
{
    self = [super init];
    if (self) {
        if(![[dict objectForKey:@"d_rating"] isKindOfClass:[NSNull class]]){
            self.rating=[[dict objectForKey:@"d_rating"]floatValue ];
        }
        self.driverId=[dict objectForKey:P_DRIVER_ID];
        self.d_fname=[dict objectForKey:@"d_fname"];
        self.d_lname=[dict objectForKey:@"d_lname"];
        self.phone=[dict objectForKey:P_MOBILE];
        if(![[dict objectForKey:@"d_degree"] isKindOfClass:[NSNull class]]){
            self.d_degree = [[dict objectForKey:@"d_degree"] floatValue];
        }
        
        self.d_lang = [dict objectForKey:@"d_lang"];
        if(self.d_lang.length==0){
            self.d_lang = @"en";
        }
        self.fire_id=[dict objectForKey:P_FIRE_ID];
        self.car_registration_no=[dict objectForKey:@"car_reg_no"];
        if([[dict objectForKey:@"d_bank_info"] isKindOfClass:[NSString class]]){
            self.d_bank_info=[dict objectForKey:@"d_bank_info"];
        }
        if(![[dict objectForKey:@"d_rating_count"] isKindOfClass:[NSNull class]]){
            self.ratingCount=[[dict objectForKey:@"d_rating_count"] floatValue];
        }
        if(![[dict objectForKey:@"num_trip"] isKindOfClass:[NSNull class]]){
            self.num_trip=[[dict objectForKey:@"num_trip"] intValue];
        }
        self.deviceToken=[dict objectForKey:@"d_device_token"];
        self.deviceType=[dict objectForKey:@"d_device_type"];
        if(![[dict objectForKey:@"d_lat"] isKindOfClass:[NSNull class]]){
        self.lat = [[dict objectForKey:@"d_lat"] doubleValue];
        }
        if(![[dict objectForKey:@"d_lng"] isKindOfClass:[NSNull class]]){
            self.lng = [[dict objectForKey:@"d_lng"] doubleValue];
        }
        self.car_make = [dict objectForKey:@"car_make"];
        
        
        if(![[dict objectForKey:@"category_id"] isKindOfClass:[NSNull class]]){
        self.category_id = [[dict objectForKey:@"category_id"] intValue];
        }
        self.carname=[dict objectForKey:@"car_name"];
        self.c_code=[dict objectForKey:@"c_code"];
        // km
        if(![[dict objectForKey:@"distance"] isKindOfClass:[NSNull class]]){
            self.distance=[[dict objectForKey:@"distance"] floatValue];
        }
        self.d_is_available=[dict objectForKey:P_DRIVER_AVAILAILITY];
        
        self.d_profile_image_path=[dict objectForKey:@"d_profile_image_path"];
        self.d_car_image_path=[dict objectForKey:@"d_car_image_path"];
        self.car_model=[dict objectForKey:@"car_model"];
        self.car_name =[dict objectForKey:@"car_name"]; 
    }
    return self;
}


-(BOOL ) isIos
{
    return  ![self.deviceType isEqualToString:@"Android"];
}

-(void) updateDriverRating:(float   ) rating completionBlock:(void (^)(id results, NSError *error))block  isShowLoader:(BOOL)isShowLoader
{
    
    
    float totalRating = 0;
    
  
    totalRating = (float) ((self.rating * self.ratingCount + rating) / (self.ratingCount + 1.0));
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]  init];
    [dict setObject:@(totalRating) forKey:@"d_rating"];
    [dict setObject:@(self.ratingCount + 1.0) forKey:@"d_rating_count"];
    [dict setObject:self.driverId forKey:P_DRIVER_ID];
    if(isShowLoader)
    {
        [UtilityClass setLH:NO wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
    }
    [GIC mkwu:UPDATE_DRIVER_PROFILE
                        d:dict
           cb:^(id results, NSError *error) {
                    if(isShowLoader)
                    {
                        [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
                    }
                    if ([[[results objectForKey:P_STATUS]  uppercaseString]isEqualToString:@"OK"]) {
                        self.rating=totalRating;
                        self.ratingCount++;
                    }
                    block(results,error);
                }];

}


+(NSMutableArray *) parseDirversResponse:(NSArray *) arrDrivers
{
    NSMutableArray * array=[[NSMutableArray alloc]  init];
    for (NSDictionary * dict in arrDrivers) {
        [array addObject:[[DriverModel alloc]  initItemWithDict:dict]];
    }
    return array;
}


-(NSMutableDictionary *) deviceTypeAndToken{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    if(self.deviceToken!=nil){
        if ([self.deviceType isEqualToString:IOS]) {
            [dict setObject:self.deviceToken forKey:IOS_TOKEN];
        }
        else{
            [dict setObject:self.deviceToken forKey:ANDROID_TOKEN];
        }
    }
    return  dict;
}
@end
