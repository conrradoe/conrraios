//
//  EstimatedFare.m
//  PrathiCabs
//
//  Created by Grepix on 11/08/21.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import "EstimatedFare.h"

@implementation EstimatedFare
-(instancetype)initItemWithDict:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        self.distReponse=dict;
        self.referral_discount=[[dict objectForKey:@"referral_discount"]floatValue ];
        self.tax_amt=[[dict objectForKey:@"tax_amt"] floatValue];
        self.toll_charges=[[dict objectForKey:@"toll_charges"] floatValue];
        self.trip_base_fare = [[dict objectForKey:@"trip_base_fare"] floatValue];
        self.extra_charges=[dict objectForKey:@"extra_charges"];
        self.trip_comp_commision=[[dict objectForKey:@"trip_comp_commision"]floatValue ];
        self.trip_driver_commision=[[dict objectForKey:@"trip_driver_commision"] floatValue];
        self.trip_pay_amount=[[dict objectForKey:@"trip_pay_amount"] floatValue];
        self.trip_promo_amt = [[dict objectForKey:@"trip_promo_amt"] floatValue];
        self.trip_share_discount = [[dict objectForKey:@"trip_share_discount"] floatValue];
        self.trip_pay_amount_without_promo = [[dict objectForKey:@"trip_pay_amount_without_promo"] floatValue];
        self.trip_pay_amount_without_share_discount=[[dict objectForKey:@"trip_pay_amount_without_share_discount"] floatValue];
        self.trip_pay_amount_without_share_discount_without_promo=[[dict objectForKey:@"trip_pay_amount_without_share_discount_without_promo"] floatValue];
        self.promo_id=[dict objectForKey:@"promo_id"];
        self.promo_code=[dict objectForKey:@"promo_code"];
    }
    return self;
}@end
//{
//    "adjust_amt" = 0;
//    "extra_charges" =     {
//        AirportCharges = 0;
//        BookingFee = "0.49";
//        CTP = 0;
//        GovtTransportLevy = "1.1";
//        TransFee = "0.16";
//    };
//    "referral_discount" = 0;
//    "tax_amt" = "0.26";
//    "toll_charges" = 0;
//    "trip_base_fare" = "3.9";
//    "trip_comp_commision" = "0.31";
//    "trip_driver_commision" = "3.59";
//    "trip_pay_amount" = "5.91";
//    "trip_pay_amount_without_promo" = "5.91";
//    "trip_promo_amt" = 0;
//    "trip_share_discount" = 0;
//}
