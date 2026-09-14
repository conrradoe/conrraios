//
//  PromoCodeModel.m
//  HIREME_RIDER
//
//  Created by Appicial Taxi App Soutions on 08/06/17.
//  Copyright © 2023 Appicial Taxi App Soutions. All rights reserved.
//

#import "PromoCodeModel.h"
#import "WebCallConstants.h"
#import "LanguageHelper.h"
#import "Utilities.h"
#import <GIKit/GIKit.h>
@implementation PromoCodeModel
-(instancetype)initWithPromode:(NSString *)promoCode city_id:(int  ) city_id
{
    if(self)
    {
        self=[self init];
        self.city_id=city_id;
        self.promoCode=promoCode;
    }
    return  self;
}

-(void) validatePromoCodeWithCompletionBlock:(int) category_id  baseFare:(float)baseFare block:(void (^)(id results, NSError *error))block
{
    NSMutableDictionary * dict=[[NSMutableDictionary alloc] init];
    NSDictionary *dictUser=defaults_object(P_USER_DICT);
    
    [dict setObject:isEmpty([dictUser objectForKey:P_USER_ID]) forKey:P_USER_ID];
    [dict setObject:[NSString stringWithFormat:@"%d",self.city_id] forKey:P_CITY_ID];
    [dict setObject:[NSString stringWithFormat:@"%d",category_id] forKey:P_CATEGORY_ID];
    [dict setObject:[Utilities formatAmount:baseFare] forKey:@"amount"];
    [dict setObject:isEmpty(self.promoCode) forKey:p_promo_code];
    [UtilityClass setLH:NO wt:[LanguageHelper getStringWithKey:@"k_r37_s2_validating"]];
    [GIC mkwu:API_VALIDATE_PROMO
                  d:dict
      isa:NO
           cb:^(id results, NSError *error) {
           [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_r37_s2_validating"]];
           if ([[[results objectForKey:P_STATUS] uppercaseString] isEqualToString:@"OK"]) {
               NSArray * arrPromoCodes=[results objectForKey:P_RESPONSE];
               if(arrPromoCodes.count>0){
                   [self parsePromoCodeResponse:[arrPromoCodes  objectAtIndex:0]];
               }
           }
           block(results,error);
       }];
    
}
-(void) parsePromoCodeResponse:(NSDictionary *) dict
{
    self.promoId=[dict objectForKey:@"promo_id"];
    self.promoCode=[dict objectForKey:@"promo_code"];
    self.promoType=[dict objectForKey:@"promo_type"];
    self.promoValue=[[dict objectForKey:@"promo_value"] floatValue];
    self.promoStatus=[dict objectForKey:@"promo_status"];
    self.percent=[[dict objectForKey:@"percent"] floatValue];
}


-(float) calucalateAmtByPromoCode:(float ) tripAmount {
    return  self.promoValue;
}

-(BOOL) isFixed {
    return [self.promoType isEqualToString:@"Fixed Amt"];
}
@end
