//
//  PromoCode.m
//
//  Created by Grepix on 09/04/21.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import "PromoCode.h"

@implementation PromoCode
-(instancetype)initWithDict:(NSDictionary *)dict{
    if(self) {
        self=[self init];
        self.promo_id=[dict objectForKey:@"promo_id"];
        self.city_id=[[dict objectForKey:@"city_id"] intValue];
        self.promo_status=[[dict objectForKey:@"promo_status"]boolValue];
        self.promo_type=[dict objectForKey:@"promo_type"];
        self.promo_code=[dict objectForKey:@"promo_code"];
    }
    return  self;
}


+(NSMutableArray *)parseReponse:(NSArray *)array{
    
    NSMutableArray *arr=[[NSMutableArray alloc] init];
        for (NSDictionary *dict in array) {
            [arr addObject:[[PromoCode alloc] initWithDict:dict]];
            
        }
    return arr;
}
@end
    
