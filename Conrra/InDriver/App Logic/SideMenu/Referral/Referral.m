//
//  Legal.m

//
//  Created by Grepix - Baij on 01/09/20.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import "Referral.h"

@implementation Referral

- (instancetype)initWithDict:(NSDictionary *) dict
{
    self = [super init];
    if (self) {
        self.status=[dict objectForKey:@"status"];
        self.st_dt=[dict objectForKey:@"st_dt"];
        self.et_dt=[dict objectForKey:@"et_dt"];
        self.driver=[[DriverModel alloc] initItemWithDict:[dict objectForKey:@"Driver"]];
    }
    return self;
}

//"ref_id": "1",
//            "driver_id": "69",
//            "ref_driver_id": "2",
//            "status": "joined",
//            "disc_rate": "0",
//            "st_dt": null,
//            "et_dt": null,
//            "created": "2020-09-30 06:32:16",
//            "modified": "2020-09-30 06:32:16"
+(NSMutableArray *) parseArray:(NSArray *)array
{
    NSMutableArray * arr=[[NSMutableArray alloc] init];
    if([array isKindOfClass:[NSArray class]])
    {
        for (NSDictionary *dict in array) {
            Referral *l1=[[Referral alloc] initWithDict:dict];
            [arr addObject:l1];
        }

    }
    return  arr;
}
@end
