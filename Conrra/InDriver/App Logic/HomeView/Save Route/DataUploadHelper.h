//
//  DataUploadHelper.h

//
//  Created by Grepix - Baij on 04/09/20.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GIKit/GIKit.h>
#import "WebCallConstants.h"
#import "DataBase.h"
NS_ASSUME_NONNULL_BEGIN

@interface DataUploadHelper : NSObject
-(void) saveCoverRouteOnServerForTripId:(NSString * ) tripId routeArray:(NSMutableArray * ) routeArray completionBlock:(void (^)(id results, NSError *error))block;
/**
  save waiting data to server  using triprouteapi/addroute api on wait_data  parameter with trip_id
 */
-(void) saveWatingDataBgWithTripId:(NSString *) tripId;

/**
 save waiting data to server  using triprouteapi/addroute api on wait_data  parameter with trip_id
*/
-(void) saveWatingDataWithTripId:(NSString *) tripId completionBlock:(void (^)(id results, NSError *error))block isShowLoader:(BOOL) isShowLoader;

/**
 save cover route data to server  using triprouteapi/addroute api  on route_data parameter  with trip_id
*/
-(void) saveCoverRouteOnServerForTripId:(NSString * ) tripId completionBlock:(void (^)(id results, NSError *error))block;

-(void) saveLogDataWithTripId:(NSString * ) tripId completionBlock:(void (^)(id results, NSError *error))block isShowLoader:(BOOL) isShowLoader onlySave:(BOOL)onlySave;

-(void) saveCoverRouteOnServerForTripIdBegin:(NSString * ) tripId userId:(NSString *)userId routeArray:(NSMutableArray * ) routeArray completionBlock:(void (^)(id results, NSError *error))block;
-(BOOL)isRouteDataUploaded;
@end

NS_ASSUME_NONNULL_END
