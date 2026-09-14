//
//  TransactionModel.m

//
//  Created by Grepix - Baij on 04/12/19.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import "TransactionModel.h"
#import "CityModel.h"
#import "WebCallConstants.h"
#import <Conrra-Swift.h>
#import "UserProfile.h"
@implementation TransactionModel

-(instancetype)initWithDict:(NSMutableDictionary *)dict{
    self = [super init];
    if(self){
        
         self.transaction_id=[dict objectForKey:@"transaction_id"];
         self.trip_id=[[dict objectForKey:@"trip_id"]intValue];
         self.trans_status=[dict objectForKey:@"trans_pay_mode"];
         self.trans_pay_mode=[dict objectForKey:@"trans_pay_mode"];
         self.trans_description=[dict objectForKey:@"trans_description"];
         self.trans_date=[dict objectForKey:@"trans_date"];
         self.total_amt=[dict objectForKey:@"total_amt"];
         self.tax_amt=[dict objectForKey:@"tax_amt"];
         self.other_amt=[dict objectForKey:@"other_amt"];
         self.net_amt=[dict objectForKey:@"net_amt"];
         self.commission_amt=[dict objectForKey:@"commission_amt"];
        self.exc_dt=[dict objectForKey:@"exc_dt"];
        self.currency = [dict objectForKey:@"currency"];
        if(self.currency.length==0){
            CityModel * cityModel=[CityModel getCityByCityId:[UserProfile shared].loggedCityID];
            self.currency = cityModel.city_cur;
        }
    }
    return self;
}
@end
