//
//  CityModel.h
//  HireMe Rider
//
//  Created by Grepix - Baij on 22/08/19.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"
NS_ASSUME_NONNULL_BEGIN

@interface CityModel : NSObject
@property(nonatomic,assign) int city_id;
@property(nonatomic,assign) int parent_id;

@property(nonatomic,strong) NSString *country_id;
@property(nonatomic,strong) NSString *city_name;
@property(nonatomic,strong) NSString *city_code;
@property(nonatomic,strong) NSString *city_cur;
@property(nonatomic,strong) NSString *pg_cur;

@property(nonatomic,assign) float city_comm;
@property(nonatomic,assign) float city_tax;
@property(nonatomic,assign) BOOL city_active;
@property(nonatomic,strong) NSString * country_code;
@property(nonatomic,strong) NSString * city_dist_unit;
@property(nonatomic,strong) NSString *geofence_json;

@property(nonatomic,strong) NSString *city_pay_options;
@property(nonatomic,strong) NSMutableArray *geofenceArrayMulti;
@property(nonatomic,strong) NSMutableArray *geofenceArrayRedZone;
-(instancetype) initWithDict:(NSDictionary *) dict;
+(NSMutableArray *) parseCities:(NSArray *) array;
+(CityModel *) getCityByCityId:(long ) cityId;
+(CityModel *) getCityByDriverCityId;
-(BOOL) isOnlinePaymentEnabled;
-(BOOL) containsLocation:(CLLocationCoordinate2D) point;
+(CityModel *)checkLocationInsieCityMatchFinal:(CLLocationCoordinate2D ) locCoordinate;
@end

NS_ASSUME_NONNULL_END
