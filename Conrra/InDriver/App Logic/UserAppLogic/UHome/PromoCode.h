//
//  PromoCode.h
//  PrathiCabs
//
//  Created by Grepix on 11/08/21.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PromoCode : NSObject

@property(strong,nonatomic) NSString * promo_id;
@property(strong,nonatomic) NSString * promo_code;
@property(strong,nonatomic) NSString * promo_type;
@property(assign,nonatomic) float  promoValue;
@property(assign,nonatomic) BOOL  promo_status;
@property(assign,nonatomic) int  city_id;

-(instancetype)initWithDict:(NSDictionary *)dict;

+(NSMutableArray *)parseReponse:(NSArray *)array;
@end

NS_ASSUME_NONNULL_END
