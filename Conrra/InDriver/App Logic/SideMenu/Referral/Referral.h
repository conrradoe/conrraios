//
//  Legal.h

//
//  Created by Grepix - Baij on 01/09/20.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DriverModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface Referral : NSObject
@property (strong,nonatomic) NSString * status;
@property (strong,nonatomic) NSString * st_dt;
@property (strong,nonatomic) NSString * et_dt;
@property (strong,nonatomic) DriverModel * driver;


- (instancetype)initWithDict:(NSDictionary *) dict;
+(NSMutableArray *) parseArray:(NSArray *)array;
@end

NS_ASSUME_NONNULL_END
