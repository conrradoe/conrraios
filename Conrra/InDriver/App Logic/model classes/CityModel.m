//
//  CityModel.m
//  HireMe Rider
//
//  Created by Grepix - Baij on 22/08/19.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import "CityModel.h"
#import "WebCallConstants.h"
#import "SettingsModel.h"
#import "UserProfile.h"
@implementation CityModel
- (instancetype)initWithDict:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        self.city_id=[[dict objectForKey:@"city_id"] intValue];
        self.parent_id = [[dict objectForKey:@"parent_id"] intValue];
        self.country_id=[dict objectForKey:@"country_id"];
        self.city_name=[dict objectForKey:@"city_name"];
        self.city_code=[dict objectForKey:@"city_code"];
        self.city_cur=[dict objectForKey:@"city_cur"];
        self.pg_cur=[dict objectForKey:@"pg_cur"];
        self.city_comm=[[dict objectForKey:@"city_comm"] floatValue];
        self.city_tax=[[dict objectForKey:@"city_tax"] floatValue];
        self.city_active=[[dict objectForKey:@"city_active"] boolValue];
        self.country_code=[dict objectForKey:@"country_code"];
        self.city_dist_unit=[dict objectForKey:@"city_dist_unit"];
        self.geofence_json=[dict objectForKey:@"geofence_json"];
        self.country_code=[dict objectForKey:@"country_code"];
        self.city_pay_options=[dict objectForKey:@"city_pay_options"];
        self.pg_cur=[dict objectForKey:@"pg_cur"];
        self.geofenceArrayMulti= [[NSMutableArray alloc] init];
        self.geofenceArrayMulti = [self parseCityGeofance:[self.geofence_json dataUsingEncoding:NSUTF8StringEncoding]];
        
        self.geofenceArrayRedZone = [[NSMutableArray alloc] init];
        NSString * readZone = [dict objectForKey:@"redzone_geofence_json"];
        if(readZone.length>0){
            self.geofenceArrayRedZone = [self parseCityGeofance:[readZone dataUsingEncoding:NSUTF8StringEncoding]];
        }
    }
    return self;
}

-(NSMutableArray *) parseCityGeofance:(NSData *)data{
    if(data){
        NSDictionary *geofanceDict= [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        if([geofanceDict isKindOfClass:[NSDictionary class]])  {
            NSString * stringType=[ geofanceDict objectForKey:@"type"];
            if([stringType isEqualToString:@"MultiPolygon"]){
                NSArray * coordinates = [geofanceDict objectForKey:@"coordinates"];
                if([coordinates isKindOfClass:[NSArray class]]){
                    return [self parseCoordinates:coordinates];
                }
            }
            else if([stringType isEqualToString:@"GeometryCollection"]) {
                NSArray * geometries=[geofanceDict objectForKey:@"geometries"];
                for (NSDictionary *geometrie in geometries) {
                    if([geometrie isKindOfClass: [NSDictionary class]]){
                        NSArray * coordinates=[geometrie objectForKey:@"coordinates"];
                        if([coordinates isKindOfClass:[NSArray class]]){
                            return [self parseCoordinates:coordinates];
                        }
                    }
                }
            }else{
                NSArray * coordinates =[geofanceDict objectForKey:@"coordinates"];
                if([coordinates isKindOfClass:[NSArray class]]){
                    return [self parseCoordinates:coordinates];
                }
            }
        }
    }
    return nil;
}

-(NSMutableArray *)parseCoordinates:(NSArray*) coordinates{
    NSMutableArray * arrayCollectionOfGegofance= [[NSMutableArray alloc] init];
    for (NSArray *arrayPoints in coordinates) {
        NSMutableArray * arraySingleGeofance= [[NSMutableArray alloc] init];
        for (NSArray * points in arrayPoints) {
            for (NSArray * point in points) {
                if(point.count>1) {
                    CLLocation * location=[[CLLocation alloc] initWithLatitude:[[point objectAtIndex:1] doubleValue] longitude:[[point objectAtIndex:0] doubleValue]];
                    [arraySingleGeofance addObject:location];
                }
            }
        }
        [arrayCollectionOfGegofance addObject:arraySingleGeofance];
    }
    return arrayCollectionOfGegofance;
}

+(NSMutableArray *) parseCities:(NSArray *) array
{
    NSMutableArray * arrayObject=[[NSMutableArray alloc] init];
    for (NSDictionary * dict in array) {
        [arrayObject addObject:[[CityModel alloc] initWithDict:dict]];
    }
    return arrayObject;
}

+(CityModel *) getCityByCityId:(long ) cityId {
    AppDelegate * app=APP_DELEGATE;
    NSArray * arr=[app arrayCities];
    if(arr==nil)
    {
        NSArray * arrcity = defaults_object(@"city_repsponse");
        app.arrayCities =[CityModel parseCities:arrcity];
    }
    for (CityModel * cModel in [app arrayCities]) {
        if(cModel.city_id ==cityId)
        {
            return cModel;
        }
    }
    return nil;
}

+(CityModel *) getCityByDriverCityId
{
    NSDictionary *WalletAmtDict = [[NSUserDefaults standardUserDefaults]objectForKey:P_USER_DICT];
    if(WalletAmtDict)
    {
        return [self getCityByCityId:[UserProfile shared].cityID];
    }
    return  nil;
}
//-(BOOL) containsLocation:(CLLocationCoordinate2D) point
//{
////    return YES;
////    return [self isPoint:point inPloygon:self.geofenceArray];
//    return [self containsLocation:point polygon:self.geofenceArray geodesic:YES];
//}
-(BOOL) containsLocation:(CLLocationCoordinate2D) point{
    for (NSArray *arrayGeofancePoints in self.geofenceArrayMulti) {
        if ([self containsLocation:point polygon:arrayGeofancePoints geodesic:YES]){
            return YES;
        }
    }
    return  NO;
//    return [self containsLocation:point polygon:self.geofenceArray geodesic:YES];
}

-(CGFloat) DegreesToRadians:(CGFloat) degrees
{
    return degrees * M_PI / 180;
}

-(CGFloat) RadiansToDegrees:(CGFloat) radians
{
    return radians * 180 / M_PI;
}
-(BOOL) containsLocation:(CLLocationCoordinate2D) point polygon:(NSArray *) polygon geodesic:(BOOL) geodesic {
     int size = (int)polygon.count;
    if (size == 0) {
        return false;
    }
    double lat3 = [self DegreesToRadians :point.latitude];
    double lng3 = [self DegreesToRadians:point.longitude ];
    CLLocation *prev = [polygon objectAtIndex:(size - 1)];
    double lat1 = [self DegreesToRadians :prev.coordinate.latitude];
    double lng1 = [self DegreesToRadians :prev.coordinate.longitude];
    int nIntersect = 0;
    for (CLLocation * point2  in polygon) {
        double dLng3 = [self wrap:(lng3 - lng1) min: -M_PI max: M_PI];
        // Special case: point equal to vertex is inside.
        if (lat3 == lat1 && dLng3 == 0) {
            return true;
        }
        double lat2 = [self DegreesToRadians :point2.coordinate.latitude];
        double lng2 =  [self DegreesToRadians :point2.coordinate.longitude];
        // Offset longitudes by -lng1.
        if ([self intersects:lat1 lat2: lat2 lng2: [self wrap:(lng2 - lng1)min:-M_PI max:  M_PI] lat3:lat3 lng3:dLng3 geodesic:geodesic]) {
            ++nIntersect;
        }
        lat1 = lat2;
        lng1 = lng2;
    }
    return (nIntersect & 1) != 0;
}

/**
 * Wraps the given value into the inclusive-exclusive interval between min and max.
 * @param n   The value to wrap.
 * @param min The minimum.
 * @param max The maximum.
 */
-(double) wrap:(double) n min:(double) min max: (double) max {
    return (n >= min && n < max) ? n : ([self mod:n - min m: max - min ] + min);
}

/**
 * Returns the non-negative remainder of x / m.
 * @param x The operand.
 * @param m The modulus.
 */
-(double) mod:(double) x m:( double) m {
    
    return fmod((fmod(x, m) + m) , m);
}

/**
 * Computes whether the vertical segment (lat3, lng3) to South Pole intersects the segment
 * (lat1, lng1) to (lat2, lng2).
 * Longitudes are offset by -lng1; the implicit lng1 becomes 0.
 */
-(BOOL) intersects:(double) lat1 lat2:(double) lat2 lng2:( double) lng2
              lat3:(double) lat3 lng3:(double) lng3 geodesic:(BOOL) geodesic {
    // Both ends on the same side of lng3.
    if ((lng3 >= 0 && lng3 >= lng2) || (lng3 < 0 && lng3 < lng2)) {
        return false;
    }
    // Point is South Pole.
    if (lat3 <= -M_PI/2) {
        return false;
    }
    // Any segment end is a pole.
    if (lat1 <= -M_PI/2 || lat2 <= -M_PI/2 || lat1 >= M_PI/2 || lat2 >= M_PI/2) {
        return false;
    }
    if (lng2 <= -M_PI) {
        return false;
    }
    double linearLat = (lat1 * (lng2 - lng3) + lat2 * lng3) / lng2;
    // Northern hemisphere and point under lat-lng line.
    if (lat1 >= 0 && lat2 >= 0 && lat3 < linearLat) {
        return false;
    }
    // Southern hemisphere and point above lat-lng line.
    if (lat1 <= 0 && lat2 <= 0 && lat3 >= linearLat) {
        return true;
    }
    // North Pole.
    if (lat3 >= M_PI/2) {
        return true;
    }
    // Compare lat3 with latitude on the GC/Rhumb segment corresponding to lng3.
    // Compare through a strictly-increasing function (tan() or mercator()) as convenient.
    return geodesic ?
    tan(lat3) >= [self tanLatGC:lat1 lat2:lat2 lng2: lng2  lng3:lng3] :
    [self mercator:lat3 ] >=[self  mercatorLatRhumb:lat1 lat2: lat2 lng2:lng2 lng3:lng3];
}

/**
 * Returns tan(latitude-at-lng3) on the great circle (lat1, lng1) to (lat2, lng2). lng1==0.
 * See http://williams.best.vwh.net/avform.htm .
 */
-(double) tanLatGC:(double) lat1 lat2:(double) lat2 lng2:(double) lng2 lng3:(double) lng3 {
    return (tan(lat1) * sin(lng2 - lng3) + tan(lat2) * sin(lng3)) / sin(lng2);
}

/**
 * Returns mercator Y corresponding to latitude.
 * See http://en.wikipedia.org/wiki/Mercator_projection .
 */
-( double) mercator:(double) lat {
    return log(tan(lat * 0.5 + M_PI/4));
}

/**
 * Returns mercator(latitude-at-lng3) on the Rhumb line (lat1, lng1) to (lat2, lng2). lng1==0.
 */
-( double) mercatorLatRhumb:(double) lat1 lat2: (double) lat2 lng2: (double) lng2 lng3:(double) lng3 {
    return ([self mercator:lat1] * (lng2 - lng3) + [self  mercator:lat2] * lng3) / lng2;
}
+(CityModel *)checkLocationInsieCityMatchFinal:(CLLocationCoordinate2D ) locCoordinate{
    AppDelegate * delegate=APP_DELEGATE;
    if([delegate arrayCities].count>1){
        NSMutableArray * arrayParents = [[NSMutableArray alloc] init];
        NSMutableArray * arrayChilds = [[NSMutableArray alloc] init];
        for (CityModel * cModel in [delegate arrayCities]) {
            if(cModel.parent_id==0){
                [arrayParents addObject:cModel];
            }else{
                [arrayChilds addObject:cModel];
            }
        }
        if(arrayParents.count==1 &&arrayChilds.count==1){
            CityModel *cModel;
            if(arrayChilds.count>0){
                cModel =[arrayChilds objectAtIndex:0];
            }
            if(cModel&&cModel.geofenceArrayMulti.count>0)  {
                if([cModel containsLocation:locCoordinate]){
                    BOOL isInRedZone=[cModel containsLocationRedZone:locCoordinate];
                    if(isInRedZone==YES){
                        return nil;
                    }
                    return  cModel;
                }
            }else{
                if(cModel){
                    // in case  geofacne is empty then check only red
                    BOOL isInRedZone=[cModel containsLocationRedZone:locCoordinate];
                    if(isInRedZone==YES){
                        return nil;
                    }
                    return cModel;
                }
            }
        }else{
            for (CityModel * cModel in [delegate arrayCities]) {
                if([cModel containsLocation:locCoordinate]){
                    BOOL isInRedZone=[cModel containsLocationRedZone:locCoordinate];
                    if(isInRedZone==YES){
                        return nil;
                    }
                    return  cModel;
                }
            }
        }
    }else{
        // one city
        CityModel *cModel;
        if([delegate arrayCities].count>0){
            cModel =[[delegate arrayCities] objectAtIndex:0];
        }
        if(cModel&&cModel.geofenceArrayMulti.count>0)  {
            if([cModel containsLocation:locCoordinate]){
                BOOL isInRedZone=[cModel containsLocationRedZone:locCoordinate];
                if(isInRedZone==YES){
                    return nil;
                }
                return  cModel;
            }
        }else{
            if(cModel){
                // in case  geofacne is empty then check only red
                BOOL isInRedZone=[cModel containsLocationRedZone:locCoordinate];
                if(isInRedZone==YES){
                    return nil;
                }
                return cModel;
            }
        }
    }
    return  nil;
}

-(BOOL) containsLocationRedZone:(CLLocationCoordinate2D) point{
    for (NSMutableArray *arrayGeo in self.geofenceArrayRedZone) {
        BOOL isYES=[self containsLocation:point polygon:arrayGeo geodesic:YES];
        if(isYES){
            return YES;
        }
    }
    return NO;
}


-(BOOL) isOnlinePaymentEnabled{
    if(self.city_pay_options.length>0) {
        NSArray * paymentOption=[self.city_pay_options componentsSeparatedByString:@"|"];
        if(paymentOption.count>0) {
            for (NSString *  payOption in paymentOption) {
                if([payOption isEqualToString:@"stripe"]){
                    return  YES;
                }
            }
        }
    }
    return  NO;
}
@end
