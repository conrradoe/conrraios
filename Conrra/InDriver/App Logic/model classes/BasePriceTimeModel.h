//
//  BasePriceTimeModel.h

//
//  Created by Grepix Infotech on 06/12/18.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BasePriceTimeModel : NSObject
@property(strong, nonatomic) NSString *cat_base_price_time;
@property(assign, nonatomic) float cat_base_price_per_km;
@property(strong, nonatomic) NSDate  *startTime;
@property(strong, nonatomic) NSDate *endTime;





-(instancetype)initBasePriceAndTimeWithDict:(NSMutableDictionary*)infoDict;

-(BOOL)  isTimeBetweenn:(NSDate *) date;

@end
