//
//  TripOfferAcceptHelper.m
//  TruckPagerDriver
//
//  Created by Grepix Infotech on 28/03/22.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import "TripOfferAcceptHelper.h"
#import <Conrra-Swift.h>
#import "Utilities.h"

@implementation TripOfferAcceptHelper

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


- (void)onAccetOfferWithAmountCb:(void (^)(id results, NSError *error))b{
     
    [self getTripAllOffer:(TripOffer *)self.tripOffer cb:^(id results, NSError *error) {
        if(results!=nil){
            for (TripOffer *tripOffer  in results) {
                SocketHelperSwift *socket= [APP_DELEGATE getSockethelperSwift]  ;
                if([socket isConnected]){
                    [socket sendOfferStatusWithTripOffer:tripOffer status:@"declined" data:tripOffer.dictOffer];
                }else{
                    [self sendNotificationToDeclinedOffer:@"declined" data:tripOffer.dictOffer tripOffer:tripOffer];
                }
            }
            b(results,nil);
        }else{
            b(nil,error);
        }
    }];
     
}

-(void) getTripAllOffer:(TripOffer *)trip cb:(void (^)(id results, NSError *error))b{
    [UtilityClass setLH:NO wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
    NSMutableDictionary * dict=[[NSMutableDictionary alloc] init];
    [dict setObject:@"offer" forKey:@"status"];
    [dict setObject:trip.trip_id forKey:TRIP_ID];
    [GIC mkwu:API_GET_TRIP_OFFERS   d:dict      isa:NO    cb:^(id results, NSError *error) {
        [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
        if ([[[results objectForKey:P_STATUS] uppercaseString] isEqualToString:@"OK"]) {
            NSMutableArray * arrayOfferToSendDeclinedNotification=[[NSMutableArray alloc] init];
            NSArray * arrayOffers=[results objectForKey:P_RESPONSE];
            if([arrayOffers isKindOfClass:[NSArray class]]){
                // if offer found

                NSDictionary * dictDriver=defaults_object(P_USER_DICT);
                for (NSDictionary * dictOffer in arrayOffers) {
                    TripOffer * tripOffer=[[TripOffer alloc] initWithDict:dictOffer];
                    // skip driver own offer and send notification to  other driver
                    if(![tripOffer.driver.driverId  isEqualToString:[dictDriver objectForKey:P_DRIVER_ID]]){
                        [arrayOfferToSendDeclinedNotification addObject:tripOffer];
                    }
                }
            }else{
                // if no offer
            }
            b(arrayOfferToSendDeclinedNotification,nil);
        }
        else  if (error != nil) {
            [Utilities handleError:error viewController:self.viewController defaultMessage:@""];
            b(nil,error);
        }
    }];
}


-(void)sendNotificationToDeclinedOffer:(NSString *)status data:( NSDictionary *) data tripOffer:(TripOffer *) tripOffer{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{ @"message" :@" ", TRIP_STATUS  :status,TRIP_ID :tripOffer.trip_id, /*@"content-available":@"1"*/}];
    if(tripOffer.driver.deviceToken!=nil) {
        if ([tripOffer.driver.deviceType isEqualToString:IOS]) {
            [dict setObject:tripOffer.driver.deviceToken forKey:IOS_TOKEN];
        }
        else{
            [dict setObject:tripOffer.driver.deviceToken forKey:ANDROID_TOKEN];
        }
    }
    if(data){
        NSError * err;
        NSData * jsonData = [NSJSONSerialization  dataWithJSONObject:data options:0 error:&err];
        NSString * myString = [[NSString alloc] initWithData:jsonData   encoding:NSUTF8StringEncoding];
        NSLog(@"%@",myString);

        [ dict  setObject:[NSString stringWithFormat:@"%@" ,tripOffer.driver.driverId] forKey:P_DRIVER_ID];
        [ dict  setObject:myString forKey:@"data"];
    }
    if (isTokenEmpty(dict)) {
        return;
    }
    [dict setObject:@"driver" forKey:@"to"];
    [GIC mk:url_notification to:send_user_notification
                  d:dict
      isa:NO
       cb:^(id results, NSError *error) {
        if ([[[results objectForKey:P_STATUS]  uppercaseString]isEqualToString:@"OK"]) {
        }
    }];
}
@end
