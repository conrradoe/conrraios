//
//  PromoCodeModel.h
//  HIREME_RIDER
//
//  Created by Appicial Taxi App Soutions on 08/06/17.
//  Copyright © 2023 Appicial Taxi App Soutions. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PromoCodeModel : NSObject
@property(strong,nonatomic) NSString * promoId;
@property(strong,nonatomic) NSString * promoCode;
@property(strong,nonatomic) NSString * promoType;
@property(assign,nonatomic) float  promoValue;
@property(strong,nonatomic) NSString * promoStatus;
@property(strong,nonatomic) NSString * promoSreated;
@property(assign,nonatomic) float  percent;
@property(assign,nonatomic) int  city_id;
-(instancetype)initWithPromode:(NSString *)promoCode city_id:(int  ) city_id;




-(void) validatePromoCodeWithCompletionBlock:(int) category_id baseFare:(float)baseFare block:(void (^)(id results, NSError *error))block;

-(float) calucalateAmtByPromoCode:(float ) tripAmount;
@end
