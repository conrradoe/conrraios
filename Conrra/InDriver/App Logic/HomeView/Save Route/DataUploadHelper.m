//
//  DataUploadHelper.m

//
//  Created by Grepix - Baij on 04/09/20.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import "DataUploadHelper.h"
#import <Conrra-Swift.h>
#import <CoreLocation/CoreLocation.h>
#import "Utilities.h"

@implementation DataUploadHelper
{
    BOOL isUploading;
    BOOL isUploaded;
}
-(void) saveCoverRouteOnServerForTripId:(NSString * ) tripId  routeArray:(NSMutableArray * ) routeArray completionBlock:(void (^)(id results, NSError *error))block
{
    NSMutableDictionary * dict=[[NSMutableDictionary alloc] init];
    [dict setObject:tripId forKey:@"trip_id"];
    EncodePolylineHelperSwift * incode=[[EncodePolylineHelperSwift alloc] init];
    NSString *encodedData=[incode encodePointWithLocations:routeArray];
    [dict setObject:isEmpty(encodedData) forKey:@"req_route_data"];
  
    [GIC mkwu:ADD_ROUTE
                  d:dict
           cb:^(id results, NSError *error) {
        if(error==nil){
         
        }
        block(results ,error);
    }];
}

-(void) saveWatingDataBgWithTripId:(NSString *) tripId
{
    [self saveWatingDataWithTripId:tripId completionBlock:^(id  _Nonnull results, NSError * _Nonnull error) {
        
    }  isShowLoader:NO];
}

-(void) saveWatingDataWithTripId:(NSString * ) tripId completionBlock:(void (^)(id results, NSError *error))block isShowLoader:(BOOL) isShowLoader
{
    if(isShowLoader)    {
        [UtilityClass setLH:NO wt:@"Waiting data..."];
    }
    NSMutableDictionary * dict=[[NSMutableDictionary alloc] init];
    [dict setObject:tripId forKey:@"trip_id"];
    
    [dict setObject:[self jsonWaitingDataForTripId:tripId] forKey:@"wait_data"];
    [GIC mkwerwu:ADD_ROUTE
                                    d:dict
              cb:^(id results, NSError *error) {
        
        if(isShowLoader){
            [UtilityClass setLH:YES wt:@"Waiting data..."];
        }
        if(error==nil)
        {
            [[DataBase shareDataBase] deleteWatingForAllTripID];
            [[DataBase shareDataBase] deleteRouteForTripID:tripId];
        }
        block(results ,error);
    }];
}


-(void) saveCoverRouteOnServerForTripId:(NSString * ) tripId completionBlock:(void (^)(id results, NSError *error))block
{
    [UtilityClass setLH:NO wt:@"Saving Route..."];
    NSMutableDictionary * dict=[[NSMutableDictionary alloc] init];
    [dict setObject:tripId forKey:@"trip_id"];
    NSString *string=[self jsonRouteDataForTripId:tripId];
    if(string.length==0){
        string=@" ";
    }
    [dict setObject:string forKey:@"route_data"];
    NSString *waitData= [self jsonWaitingDataForTripId:tripId];
    if(waitData){
        [dict setObject:waitData forKey:@"wait_data"];
    }
    
    NSString *log=[self jsonTripLogDataForTripId:tripId];
    if(log){
        [dict setObject:log forKey:@"log_data"];
    }
    [GIC mkwerwu:ADD_ROUTE
                  d:dict
              cb:^(id results, NSError *error) {
        [UtilityClass setLH:YES wt:@"Saving Route..."];
        if(error==nil)  {
            [[DataBase shareDataBase] deleteRouteForTripID:tripId];
        }
        block(results ,error);
    }];
}


-(NSString *) jsonRouteDataForTripId:(NSString * ) tripId{
    NSMutableArray * array=[[DataBase shareDataBase] getRouteForTripID:tripId];
    
    NSMutableArray * arrayForJson=[[NSMutableArray alloc] init];
    for (NSDictionary * dict in array) {
        CLLocation * loc=[[CLLocation alloc] initWithLatitude:[[dict objectForKey:@"LAT"] floatValue] longitude:[[dict objectForKey:@"LNG"] floatValue]];
//        [arrayForJson addObject:@{@"lat":[dict objectForKey:@"LAT"],@"lng":[dict objectForKey:@"LNG"]}];
        [arrayForJson addObject:loc];
    }
    EncodePolylineHelperSwift *ss=[[EncodePolylineHelperSwift alloc] init];
    NSString * stringPolyLine=   [ss encodePointWithLocations:arrayForJson];
//    NSError * error;
//    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:arrayForJson options:NSJSONWritingPrettyPrinted error:&error];
//    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return stringPolyLine;
}

-(NSString *) jsonWaitingDataForTripId:(NSString * ) tripId
{

    NSMutableArray * array=[[DataBase shareDataBase] getWatingForTripID:tripId];
    NSMutableArray * arrayForJson=[[NSMutableArray alloc] init];
    int i=  (int)array.count;
    for (NSDictionary * dict in array) {
        [arrayForJson addObject:@{
            @"st":isEmpty([dict objectForKey:@"WAITING_DATE_START"]),
            @"st_lat":isEmpty([dict objectForKey:@"START_LAT"]),
            @"st_lng":isEmpty([dict objectForKey:@"START_LNG"]),
            @"et":isEmpty([dict objectForKey:@"WAITING_DATE_END"]),
            @"et_lat":isEmpty([dict objectForKey:@"END_LAT"]),
            @"et_lng":isEmpty([dict objectForKey:@"END_LNG"]),
            @"wait":isEmpty([dict objectForKey:@"WAIT_DURATION"]),
            @"so":[NSString stringWithFormat:@"%d",(i)]
        }];
        i--;
    }
    NSError * error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:arrayForJson options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return jsonString;
}


-(NSString *) jsonTripLogDataForTripId:(NSString * ) tripId{

//    TRIP_ID,U_LAT,U_LNG,D_LAT,D_LNG,TRIP_STATUS,TIME_AT,KEY_1,KEY_2,KEY_3,KEY_4
    NSMutableArray * array=[[DataBase shareDataBase] getTripLogForTripID:tripId];
    if(array.count==0){
        return nil;
    }
    NSMutableArray * arrayForJson=[[NSMutableArray alloc] init];
    int i=  0;
//    (int)array.count;
    NSDictionary *dictDriver=defaults_object(P_USER_DICT);
    for (NSDictionary * dict in array) {
        [arrayForJson addObject:@{
            P_DRIVER_ID:isEmpty([dictDriver objectForKey:P_DRIVER_ID]),
            @"u_lat":isEmpty([dict objectForKey:@"U_LAT"]),
            @"u_lng":isEmpty([dict objectForKey:@"U_LNG"]),
            @"d_lat":isEmpty([dict objectForKey:@"D_LAT"]),
            @"d_lng":isEmpty([dict objectForKey:@"D_LNG"]),
            @"timestamp":isEmpty([dict objectForKey:@"TIME_AT"]),
            @"trip_status":isEmpty([dict objectForKey:@"TRIP_STATUS"]),
//            @"so":[NSString stringWithFormat:@"%d",(i)]
        }];
        i++;
    }
    return [Utilities dictOrArrayToJosnString:arrayForJson];
}


-(void) saveCoverRouteOnServerForTripIdBegin:(NSString * ) tripId userId:(NSString *)userId routeArray:(NSMutableArray * ) routeArray completionBlock:(void (^)(id results, NSError *error))block
{
    
    isUploading=YES;
    isUploaded=NO;
    NSMutableDictionary * dict=[[NSMutableDictionary alloc] init];
    [dict setObject:tripId forKey:@"trip_id"];
    EncodePolylineHelperSwift * incode=[[EncodePolylineHelperSwift alloc] init];
    NSString *encodedData=[incode encodePointWithLocations:routeArray];
    [dict setObject:isEmpty(encodedData) forKey:@"temp_route_data"];
//    [dict setObject:isEmpty(userId) forKey:@"user_id"];
    [GIC mkwerwu:ADD_ROUTE  d:dict  cb:^(id results, NSError *error) {
        self->isUploading=NO;
        if(error==nil) {
            self->isUploaded=YES;
        }
        block(results ,error);
    }];
}
-(BOOL) isRouteDataUploaded{
    if(isUploading){
        return YES;
    }
    if(isUploaded){
        return YES;
    }
    return NO;
}

-(void) saveLogDataWithTripId:(NSString * ) tripId completionBlock:(void (^)(id results, NSError *error))block isShowLoader:(BOOL) isShowLoader onlySave:(BOOL)onlySave{
    NSString *log=[self jsonTripLogDataForTripId:tripId];
    if(log==nil){
        block(nil ,nil);
        return;
    }
    if(isShowLoader)    {
        [UtilityClass setLH:NO wt:@"Please wait..."];
    }
    NSMutableDictionary * dict=[[NSMutableDictionary alloc] init];
    [dict setObject:tripId forKey:@"trip_id"];
    if(log){
//        [dict setObject:@" " forKey:@"route_data"];
        [dict setObject:log forKey:@"log_data"];
    }
    [GIC mkwerwu:ADD_ROUTE d:dict
              cb:^(id results, NSError *error) {
        
        if(isShowLoader){
            [UtilityClass setLH:YES wt:@"Please wait..."];
        }
        if(error==nil) {
            if(!onlySave){
                [[DataBase shareDataBase] deleteTripLogTripID:tripId];
            }
        }
        block(results ,error);
    }];
}

@end
