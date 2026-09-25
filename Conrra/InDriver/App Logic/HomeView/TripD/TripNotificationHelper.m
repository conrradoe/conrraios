//
//  TripNotificationHelper.m
//  TruckPagerDriver
//
//  Created by Grepix on 03/12/21.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import "TripNotificationHelper.h"


@implementation TripNotificationHelper

+(NSString *) getValueForKey:(NSString *) key lang:(NSString*)lang{
    return [[LanguageHelper sharedInstance] getStringWithKey:key currentLanguage:lang];
}
+(void)sendNotificationToUser:(NSString *)status data:( NSDictionary *) data trip:(TripModel *) trip{
    NSString *message;
    if ( [status isEqualToString:TS_OFFER] ) {
        message = [self getValueForKey:@"k_2_s14_trip_offer" lang:trip.user.u_language];
    }
    else if ( [status isEqualToString:TS_DRIVER_CANCEL_AT_DROP] ) {
        message = [self getValueForKey:@"k_2_s14_trip_conplete" lang:trip.user.u_language];
    }
    else if ([status isEqualToString:TS_DRIVER_CANCEL_AT_PICKUP]){
        message =[self getValueForKey:@"k_5_s14_trip_cancelled_by_driver" lang:trip.user.u_language];
    }
    else if ([status isEqualToString:TS_ACCEPTED]){
        message = [self getValueForKey:@"k_1_s14_trip_confirm" lang:trip.user.u_language];
    }
    else if ([status isEqualToString:TS_ARRIVE]) {
        message = [self getValueForKey:@"k_3_s14_arrive_soon" lang:trip.user.u_language];
    }
    else if ([status isEqualToString:TS_END]){
        message = [self getValueForKey:@"k_2_s14_trip_conplete" lang:trip.user.u_language];
    }
    else if ([status isEqualToString:TS_BEGIN]){
        message = [self getValueForKey:@"k_4_s14_trip_started" lang:trip.user.u_language];
    }
    else if ([status isEqualToString:TS_REJECT])  {
        message = [self getValueForKey:@"k_10_s14_trip_request_rerject" lang:trip.user.u_language];
    }else if ( [status isEqualToString:@"declined"] ) {
        message = [LanguageHelper getStringWithKey:@" "];
    }
    NSString * tripid = [NSString stringWithFormat:@"%@",trip.trip_Id];
    /*
     Sin esto, un estado que no este en la cadena de arriba deja el mensaje en nil y el
     diccionario literal revienta al construirse, no al usarse: "attempt to insert nil object
     from objects[0]". Es una trampa para cualquiera que llame con un estado nuevo, y ya
     costo un cierre de la app en el camino de "no me pagaron".
     */
    if (message == nil) {
        message = @" ";
    }
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{ @"message" :message, TRIP_STATUS  :status,TRIP_ID :tripid, /*@"content-available":@"1"*/}];
    if([status isEqualToString:TS_ARRIVE]){
        [ dict  setObject:@"cab_arrive.caf" forKey:@"sound"];
    }
    else if([status isEqualToString:TS_BEGIN]){
        [ dict  setObject:@"vehicle_arrive_soon.caf" forKey:@"sound"];
    }
    else if([status isEqualToString:TS_REJECT]){
        [ dict  setObject:@"driver_cancelled.caf" forKey:@"sound"];
    }
    else if([status isEqualToString:TS_ACCEPTED]){
        [ dict  setObject:@"driver_accepted.caf" forKey:@"sound"];
    }
    else if([status isEqualToString:TS_END]){
        [ dict  setObject:@"trip_complete.caf" forKey:@"sound"];
    }
    if(trip.user.deviceToken!=nil) {
        if ([trip.user.deviceType isEqualToString:IOS]) {
            [dict setObject:trip.user.deviceToken forKey:IOS_TOKEN];
        }
        else{
            [dict setObject:trip.user.deviceToken forKey:ANDROID_TOKEN];
        }
    }
    [dict setObject:@"user" forKey:@"to"];
    if(data){
        NSError * err;
        NSData * jsonData = [NSJSONSerialization  dataWithJSONObject:data options:0 error:&err];
        NSString * myString = [[NSString alloc] initWithData:jsonData   encoding:NSUTF8StringEncoding];
        NSLog(@"%@",myString);
        
        [ dict  setObject:[NSString stringWithFormat:@"%d" ,trip.user.userId] forKey:P_USER_ID];
        [ dict  setObject:myString forKey:@"data"];
    }
    if (isTokenEmpty(dict)) {
        return;
    }
    [GIC mk:url_notification to:send_user_notification   d:dict   isa:NO  cb:^(id results, NSError *error) {
        if ([[[results objectForKey:P_STATUS]  uppercaseString]isEqualToString:@"OK"]) {
        }
    }];
}

/**
 
 send notification to driver
 */

+(void)sendNotification:(NSString *)status data:( NSDictionary *) data trip:(TripModel *) trip{
    NSString *message;
    if ( [status isEqualToString:TS_OFFER] ) {
        message = [self getValueForKey:@"k_2_s14_trip_offer" lang:trip.driver.d_lang];
    }
    else if ( [status isEqualToString:TS_DRIVER_CANCEL_AT_DROP] ) {
        message = [self getValueForKey:@"k_2_s14_trip_conplete" lang:trip.driver.d_lang];
    }
    else if ([status isEqualToString:TS_DRIVER_CANCEL_AT_PICKUP]){
        message =[self getValueForKey:@"k_5_s14_trip_cancelled_by_driver" lang:trip.driver.d_lang];
    }
    else if ([status isEqualToString:TS_ACCEPTED]){
        message = [self getValueForKey:@"k_1_s14_trip_confirm" lang:trip.driver.d_lang];
    }
    else if ([status isEqualToString:TS_ARRIVE]) {
        message = [self getValueForKey:@"k_3_s14_arrive_soon" lang:trip.driver.d_lang];
    }
    else if ([status isEqualToString:TS_END]){
        message = [self getValueForKey:@"k_2_s14_trip_conplete" lang:trip.driver.d_lang];
    }
    else if ([status isEqualToString:TS_BEGIN]){
        message = [self getValueForKey:@"k_4_s14_trip_started" lang:trip.driver.d_lang];
    }
    else if ([status isEqualToString:TS_REJECT])  {
        message = [self getValueForKey:@"k_10_s14_trip_request_rerject" lang:trip.driver.d_lang];
    }
    /*
     Sin esto, un estado que no este en la cadena de arriba deja el mensaje en nil y el
     diccionario literal revienta al construirse, no al usarse: "attempt to insert nil object
     from objects[0]". Es una trampa para cualquiera que llame con un estado nuevo, y ya
     costo un cierre de la app en el camino de "no me pagaron".
     */
    if (message == nil) {
        message = @" ";
    }
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{ @"message" :message, TRIP_STATUS  :status,TRIP_ID :trip.trip_Id, /*@"content-available":@"1"*/}];
    if([status isEqualToString:TS_ARRIVE]){
        [ dict  setObject:@"cab_arrive.caf" forKey:@"sound"];
    }
    else if([status isEqualToString:TS_BEGIN]){
        [ dict  setObject:@"vehicle_arrive_soon.caf" forKey:@"sound"];
    }
    else if([status isEqualToString:TS_REJECT]){
        [ dict  setObject:@"driver_cancelled.caf" forKey:@"sound"];
    }
    else if([status isEqualToString:TS_ACCEPTED]){
        [ dict  setObject:@"driver_accepted.caf" forKey:@"sound"];
    }
    else if([status isEqualToString:TS_END]){
        [ dict  setObject:@"trip_complete.caf" forKey:@"sound"];
    }
    if(trip.driver.deviceToken!=nil) {
        if ([trip.driver.deviceType isEqualToString:IOS]) {
            [dict setObject:trip.driver.deviceToken forKey:IOS_TOKEN];
        }
        else{
            [dict setObject:trip.driver.deviceToken forKey:ANDROID_TOKEN];
        }
    }
    [dict setObject:@"driver" forKey:@"to"];
    if(data){
        NSError * err;
        NSData * jsonData = [NSJSONSerialization  dataWithJSONObject:data options:0 error:&err];
        NSString * myString = [[NSString alloc] initWithData:jsonData   encoding:NSUTF8StringEncoding];
        NSLog(@"%@",myString);
        [ dict  setObject:[NSString stringWithFormat:@"%d" ,trip.user.userId] forKey:P_USER_ID];
        [ dict  setObject:myString forKey:@"data"];
    }
    if (isTokenEmpty(dict)) {
        return;
    }
    [GIC mk:url_notification to:send_user_notification     d:dict   isa:NO   cb:^(id results, NSError *error) {
        if ([[[results objectForKey:P_STATUS]  uppercaseString]isEqualToString:@"OK"]) {
        }
    }];
}

+(void)sendNotification:(NSString *)status  trip:(TripModel *) trip{
    [self sendNotification:status data:nil trip:trip];
}

+(void)sendNotificationToDeclinedOffer:(NSString *)status data:( NSDictionary *) data tripId:(NSString *) tripId  driver:(DriverModel *)driver{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{ @"message" :@" ", TRIP_STATUS  :status,TRIP_ID :tripId, /*@"content-available":@"1"*/}];
    if(driver.deviceToken!=nil) {
        if ([driver.deviceType isEqualToString:IOS]) {
            [dict setObject:driver.deviceToken forKey:IOS_TOKEN];
        }
        else{
            [dict setObject:driver.deviceToken forKey:ANDROID_TOKEN];
        }
    }
    if(data){
        NSError * err;
        NSData * jsonData = [NSJSONSerialization  dataWithJSONObject:data options:0 error:&err];
        NSString * myString = [[NSString alloc] initWithData:jsonData   encoding:NSUTF8StringEncoding];
        NSLog(@"%@",myString);
        
        [ dict  setObject:[NSString stringWithFormat:@"%@" ,driver.driverId] forKey:@"driver_id"];
        [ dict  setObject:myString forKey:@"data"];
    }
    if (isTokenEmpty(dict)) {
        return;
    }
    [dict setObject:@"driver" forKey:@"to"];
    [GIC mk:url_notification to:send_driver_notification
                  d:dict
      isa:NO
       cb:^(id results, NSError *error) {
        if ([[[results objectForKey:P_STATUS]  uppercaseString]isEqualToString:@"OK"]) {
        }
    }];
}
@end
