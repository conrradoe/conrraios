//
//  UserModel.m
//  TaxiDriver
//
//  Created by Appicial Taxi App Solutions on 22/06/17.
//  Copyright © 2023 Appicial. All rights reserved.
//

#import "UserModel.h"
#import "Utilities.h"
#import "WebCallConstants.h"
#import <GIKit/GIKit.h>
@implementation UserModel
-(instancetype)initItemWithDict:(NSDictionary *)dict;
{
    self = [super init];
    if (self) {
        
        self.userId=[[dict objectForKey:@"user_id"] intValue];
        self.u_name=[dict objectForKey:@"u_name"];
        self.is_verified=[Utilities estaVerificadoElDiccionario:dict];
        self.u_fname=[dict objectForKey:@"u_fname"];
        self.u_lname=[dict objectForKey:@"u_lname"];
        self.u_phone=[dict objectForKey:@"u_phone"];
        self.rating=[[dict objectForKey:@"rating"] floatValue];
        self.rating_count=[[dict objectForKey:@"rating_count"] intValue];
        self.fire_id=[dict objectForKey:P_FIRE_ID];
        self.u_language = [dict objectForKey:P_U_LANGUAGE];
        if(self.u_language.length==0){
            self.u_language = @"en";
        }
        self.deviceToken=[dict objectForKey:@"u_device_token"];
        self.deviceType=[dict objectForKey:@"u_device_type"];
        self.lat = [[dict objectForKey:@"u_lat"] doubleValue];
        self.lng = [[dict objectForKey:@"u_lng"] doubleValue];
        self.u_profile_image_path=[dict objectForKey:@"u_profile_image_path"];
        
        self.stripe_cust_id = [dict objectForKey:@"stripe_cust_id"];
        self.stripe_dev_cust_id = [dict objectForKey:@"stripe_dev_cust_id"];
        
        self.c_code=[dict objectForKey:@"c_code"];
        // km
        self.distance=[[dict objectForKey:@"distance"] floatValue];
    }
    return self;
}
-(void) updateDriverRating:(float   ) rating completionBlock:(void (^)(id results, NSError *error))block  isShowLoader:(BOOL)isShowLoader
{
    
    
    float totalRating = 0;
    totalRating = (float) ((self.rating * self.rating_count + rating) / (self.rating_count + 1.0));
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]  init];
    [dict setObject:@(totalRating) forKey:@"rating"];
    [dict setObject:@(self.rating_count + 1.0) forKey:@"rating_count"];
    [dict setObject:[NSString stringWithFormat:@"%d",self.userId] forKey:@"user_id"];
    if(isShowLoader)
    {
        [UtilityClass setLH:NO wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
    }
    [GIC mkwu:UPDATE_USER_PROFILE
                  d:dict
           cb:^(id results, NSError *error) {
           if(isShowLoader)
           {
               [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
           }
           if ([[[results objectForKey:P_STATUS] uppercaseString] isEqualToString:@"OK"]) {
               self.rating=totalRating;
               self.rating_count++;
           }
           block(results,error);
       }];
    
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
