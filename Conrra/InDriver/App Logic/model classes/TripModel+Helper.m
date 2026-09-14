//
//  TripModel+Helper.m
//  InDriver
//
//  Created by Grepix on 19/11/21.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import "TripModel+Helper.h"
#import "Utilities.h"
@implementation TripModel (Helper)

-(NSString *) dropLocationApp{
    if(self.actual_to_loc.length>0) {
        return  self.actual_to_loc;
    }else {
        return  self.trip_drop_loc;
    }
}
-(NSString *) pickupLocationApp{
    if(self.pickup_notes.length>0)    {
        if(self.actual_from_loc.length>0) {
            return  [NSString stringWithFormat:@"%@\n\n%@ %@",self.actual_from_loc,[LanguageHelper getStringWithKey:@"k_1_s8_special_notes"],self.pickup_notes];
        }else {
            return  [NSString stringWithFormat:@"%@\n\n%@ %@",self.trip_pick_loc,[LanguageHelper getStringWithKey:@"k_1_s8_special_notes"],self.pickup_notes];
        }
    }
    if(self.actual_from_loc.length>0) {
        return  self.actual_from_loc;
    }else {
        return  self.trip_pick_loc;
    }
}

-(NSString *) pickupTitleWithPickUpTime{
    NSString * pickupTime=[Utilities GetGMTDatetoLocalTZ:self.trip_pickup_time:APP_TIME_ONLY];
    /*if(pickupTime)  {
        return [NSString stringWithFormat:@"%@ @ %@",[LanguageHelper getStringWithKey:@"k_20_s4_pick"],pickupTime];
    }else{
        return [NSString stringWithFormat:@"%@",[LanguageHelper getStringWithKey:@"k_20_s4_pick"]];
    }*/
    if(pickupTime)  {
        return [NSString stringWithFormat:@"%@ @ %@",[LanguageHelper getStringWithKey:@"k_1_s11_pickup_n_loc"],pickupTime];
    }else{
        return [NSString stringWithFormat:@"%@",[LanguageHelper getStringWithKey:@"k_1_s11_pickup_n_loc"]];
    }
}

-(NSString *) dropTitleWithDropTime{
    NSString * dropTime=[Utilities GetGMTDatetoLocalTZ:self.trip_drop_time:APP_TIME_ONLY];
    /*if(dropTime){
        return [NSString stringWithFormat:@"%@ @ %@",[LanguageHelper getStringWithKey:@"k_10_s8_drop"],dropTime];
    }else {
        return [NSString stringWithFormat:@"%@",[LanguageHelper getStringWithKey:@"k_10_s8_drop"]];
    }*/
    if(dropTime){
        return [NSString stringWithFormat:@"%@ @ %@",[LanguageHelper getStringWithKey:@"k_11_s8_search_drop_location"],dropTime];
    }else {
        return [NSString stringWithFormat:@"%@",[LanguageHelper getStringWithKey:@"k_11_s8_search_drop_location"]];
    }
}
//k_11_s8_search_drop_location
//k_1_s11_pickup_n_loc



-(void)sendChatNotificationToDriver:(NSString *)message{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{
        @"message"       :message,
        TRIP_STATUS      :TS_CHAT,
        TRIP_ID          :isEmpty(self.trip_Id),
        @"content-available":@"1",
    }];
    [dict addEntriesFromDictionary:[self.driver deviceTypeAndToken]];
    if (isTokenEmpty(dict)) {
        return;
    }
    [dict setObject:@"driver" forKey:@"to"];
    [GIC mk:url_notification to:send_driver_notification    d:dict  isa:NO   cb:^(id results, NSError *error) {
        if ([[results objectForKey:P_STATUS] isEqualToString:@"OK"]) {
            NSLog(@"notification success");
        }
    }];
}


-(void)sendChatNotificationToUser:(NSString *)message{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{
        @"message"       :message,
        TRIP_STATUS      :TS_CHAT,
        TRIP_ID          :isEmpty(self.trip_Id),
        @"content-available":@"1",
    }];
    [dict addEntriesFromDictionary:[self.user deviceTypeAndToken]];
    if (isTokenEmpty(dict)) {
        return;
    }
    [dict setObject:@"user" forKey:@"to"];
    [GIC mk:url_notification to:send_driver_notification    d:dict  isa:NO   cb:^(id results, NSError *error) {
        if ([[results objectForKey:P_STATUS] isEqualToString:@"OK"]) {
            NSLog(@"notification success");
        }
    }];
}

-(BOOL) isTripCancelledForStatus{
    BOOL isCancelled=[self.trip_Status isEqualToString:TS_DRIVER_CANCEL]||[self.trip_Status isEqualToString:TS_DRIVER_CANCEL_AT_PICKUP]||[self.trip_Status isEqualToString:@"cancel"];
    return isCancelled;
}
@end
