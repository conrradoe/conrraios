//
//  EstimatedFare.h
//  PrathiCabs
//
//  Created by Grepix on 11/08/21.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface EstimatedFare : NSObject
@property (nonatomic, assign) float referral_discount;
@property (nonatomic, assign) float tax_amt;
@property (nonatomic, assign) float toll_charges;
@property (nonatomic, assign) float trip_base_fare;
@property (nonatomic, assign) float trip_comp_commision;
@property (nonatomic, assign) float trip_driver_commision;
@property (nonatomic, assign) float trip_pay_amount;
@property (nonatomic, assign) float trip_pay_amount_without_promo;
@property (nonatomic, assign) float trip_pay_amount_without_share_discount;
@property (nonatomic, assign) float trip_pay_amount_without_share_discount_without_promo;


@property (nonatomic, strong) NSString *promo_id;
@property (nonatomic, strong) NSString *promo_code;

@property (nonatomic, assign) float trip_promo_amt;
@property (nonatomic, assign) float trip_share_discount;
@property (nonatomic, strong)NSDictionary *extra_charges;
@property (nonatomic, strong)NSDictionary *distReponse;


-(instancetype)initItemWithDict:(NSDictionary *)dict;
@end

NS_ASSUME_NONNULL_END
