//
//  TripNotificationHelper.h
//  TruckPagerDriver
//
//  Created by Grepix on 03/12/21.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TripModel.h"
//#import "BaseViewController.h"
NS_ASSUME_NONNULL_BEGIN

@interface TripNotificationHelper : NSObject
+(void)sendNotification:(NSString *)status data:(NSDictionary *) data trip:(TripModel *) trip;
+(void)sendNotificationToUser:(NSString *)status data:( NSDictionary *) data trip:(TripModel *) trip;
//+(void)sendNotificationToDeclinedOffer:(NSString *)status data:( NSDictionary *) data tripOffer:(TripOffer *) tripOffer;
+(void)sendNotification:(NSString *)status  trip:(TripModel *) trip;
+(void)sendNotificationToDeclinedOffer:(NSString *)status data:( NSDictionary *) data tripId:(NSString *) tripId  driver:(DriverModel *)driver;
@end

NS_ASSUME_NONNULL_END
