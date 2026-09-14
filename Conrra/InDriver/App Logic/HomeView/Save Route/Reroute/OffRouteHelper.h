//
//  OffRouteHelper.h
//  LTS Driver
//
//  Created by Grepix on 05/02/21.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN

@interface OffRouteHelper : NSObject
-(void)resolve:(NSMutableArray *) arrayPoint  outputArray:(NSMutableArray *) output;
@end

NS_ASSUME_NONNULL_END
