//
//  UserModel.h
//  TaxiDriver
//
//  Created by Appicial Taxi App Solutions on 22/06/17.
//  Copyright © 2023 Appicial. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LanguageHelper.h"


@interface UserModel : NSObject
@property(assign,nonatomic)  int   userId;

@property(strong,nonatomic)  NSString *  u_name;
@property(strong,nonatomic)  NSString *  u_fname;
@property(strong,nonatomic)  NSString *  u_lname;
@property(strong,nonatomic)  NSString *  u_phone;
@property(strong,nonatomic)  NSString *  c_code;

@property(nonatomic,strong) NSString *deviceToken;
@property(nonatomic,strong) NSString *deviceType;
@property(nonatomic,strong) NSString *u_profile_image_path;

@property(nonatomic,strong) NSString * fire_id;
@property(nonatomic,strong) NSString * u_language;
@property(assign,nonatomic) float rating;
@property(assign,nonatomic) int rating_count;

@property(nonatomic,strong) NSString *stripe_cust_id;
@property(nonatomic,strong) NSString *stripe_dev_cust_id;
@property(nonatomic,assign) double lat;
@property(assign,nonatomic) double lng;
@property(assign,nonatomic) float distance;
/// Si la cuenta esta verificada. Se decide al parsear, con Utilities estaVerificadoElDiccionario.
@property(assign,nonatomic) BOOL is_verified;

-(instancetype)initItemWithDict:(NSDictionary *)dict;
-(void) updateDriverRating:(float   ) rating completionBlock:(void (^)(id results, NSError *error))block  isShowLoader:(BOOL)isShowLoader;
-(NSMutableDictionary *) deviceTypeAndToken;
@end
