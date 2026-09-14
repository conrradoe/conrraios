//
//  BasePriceTimeModel.m

//
//  Created by Grepix Infotech on 06/12/18.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import "BasePriceTimeModel.h"

@implementation BasePriceTimeModel


-(instancetype) initBasePriceAndTimeWithDict:(NSMutableDictionary *)infoDict{
    self = [super init];
    if (self){[self parseBasePriceAndTime:infoDict];}
    return self;
}


-(void) parseBasePriceAndTime:    (NSDictionary *) infoDict  {
        //  prec -key server
        self.cat_base_price_per_km         = [[infoDict objectForKey:@"perc"]floatValue];
        self.cat_base_price_time           = [infoDict objectForKey:@"time"];
    
    NSArray * splitTimeStr = [self.cat_base_price_time componentsSeparatedByString:@":"];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"dd-MM-yyyy";
    NSString *currentDateValueStr = [formatter stringFromDate:[NSDate date]];
    NSString *startTimeStr = [NSString stringWithFormat:@"%@ %@", currentDateValueStr, [splitTimeStr firstObject]];
    NSString *endTimeStr = [NSString stringWithFormat:@"%@ %@", currentDateValueStr, [splitTimeStr lastObject]];
    formatter.dateFormat = @"dd-MM-yyyy hh:mma";

    NSDate *startTime = [formatter dateFromString:startTimeStr];
    NSDate *endTime = [formatter dateFromString:endTimeStr];
    self.startTime = startTime;
    self.endTime = endTime;
}
    

-(BOOL)  isTimeBetweenn:(NSDate *) date {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"dd-MM-yyyy hh:mm:ss a";
    if ([date compare:self.startTime] == NSOrderedDescending  && [date compare:self.endTime] == NSOrderedAscending) {
        return YES;
    } else {
        return NO;
    }
}

@end
