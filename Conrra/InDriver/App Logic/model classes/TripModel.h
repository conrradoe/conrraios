//
//  TripModel.h
//  TaxiDriver
//
//  Created by  Appicial on 25/05/17.
//  Copyright © 2023 Appicial. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DriverModel.h"
#import "UserModel.h"
#import "LanguageHelper.h" 



@interface TripModel : NSObject

@property(nonatomic,strong) NSString* trip_Id;
@property(nonatomic,strong) NSString* m_trip_id;
@property(nonatomic,strong) NSString* category_id;
@property(nonatomic,strong)NSString *cat_name;
@property(nonatomic,strong) NSString *trip_Status;
@property(nonatomic,strong) NSString *trip_pick_loc;
@property(nonatomic,strong) NSString *trip_drop_loc;
@property(nonatomic,strong) NSString *trip_pick_lat;
@property(nonatomic,strong) NSString *trip_pick_long;
@property(nonatomic,strong) NSString *trip_drop_lat;
@property(nonatomic,strong) NSString *trip_drop_long;
@property(nonatomic,strong) NSString *trip_created_time;
@property(nonatomic,strong) NSString *trip_fare;
@property(nonatomic,strong) NSString *base_est_amt;

@property(nonatomic,strong) NSString *trip_driver_commision;
@property(nonatomic,strong) NSString *trip_distance;
@property(nonatomic,strong) NSString *trip_pay_mode;
@property(nonatomic,strong) NSString *trip_pay_status;
@property(nonatomic,strong) NSString *trip_promo_amt;
@property(nonatomic,strong) NSString *trip_cancel_reason;
@property(nonatomic,assign) float trip_time;
@property(nonatomic,strong) NSString *tax_amount;
@property(nonatomic,strong) NSString *tax_amount_r;
@property(nonatomic,assign) BOOL isPromoCodeUsed;
@property(strong,nonatomic) DriverModel *driver;
@property(strong,nonatomic) UserModel *user;
@property(nonatomic,strong) NSString *trip_pickup_time;
@property(nonatomic,strong) NSString *trip_drop_time;

@property (nonatomic, assign) int trip_total_time;

@property (nonatomic, strong) NSString *trip_Driver_Id;
@property(nonatomic,strong) NSString *actual_to_loc;
@property (nonatomic, strong) NSString *actual_from_loc;
@property (nonatomic, assign) float trip_rating;
@property (nonatomic, assign) float user_rating;
@property (nonatomic, assign) float trip_actual_pick_lat;
@property (nonatomic, assign) float trip_actual_pick_lng;
@property (nonatomic, strong) NSString * pickup_notes;
@property(nonatomic,assign) BOOL is_ride_later;
@property(nonatomic,assign) BOOL is_share;
@property (nonatomic, assign) int wait_duration;
@property (nonatomic, assign) int city_id;
@property(nonatomic,strong) NSString *trip_date;
@property(nonatomic,strong) NSString *trip_customer_details;
@property(nonatomic,strong) NSString *trip_base_fare;
@property(nonatomic,strong) NSString *tm_arr;
@property(nonatomic,strong) NSString *tm_acc;
//@property(nonatomic,strong) NSString *trip_cat_id;
@property (nonatomic, assign) BOOL is_cancelled;
@property (nonatomic, strong) NSString *otp;
@property(nonatomic,strong) NSString *trip_modified_time;
@property(nonatomic,strong) NSString * trip_created;
@property (nonatomic, strong) NSString *trip_promo_code;
@property (nonatomic, strong) NSString *payment_card_id;
@property(nonatomic,strong) NSString *payment_intent_id;
@property(nonatomic,assign) BOOL isOfferSent;

-(BOOL) isTripCancelled;
-(BOOL) isTripCancelledForPay;

-(BOOL) isPaid;
-(BOOL) isTripSingleRide;

-(void)sendNotification;

-(instancetype)initItemWithDict:(NSDictionary *)tripDict;

-(void) updateTripModelWith:(NSDictionary *) dict completionBlock:(void (^)(id results, NSError *error))block isShowLoader:(BOOL)isShowLoader;
-(void) updateTripModelWith:(NSDictionary *) dict completionBlock:(void (^)(id results, NSError *error))block isShowLoader:(BOOL)isShowLoader isSendNotification:(BOOL)isSendNotification;
-(void) refreshTripModelWithDriverId:(NSString *) driverId completionBlock:(void (^)(id results, NSError *error))block isShowLoader:(BOOL)isShowLoader;
-(void) refreshTripModelWithCompletionBlock:(void (^)(id results, NSError *error))block isShowLoader:(BOOL)isShowLoader;
-(BOOL) isTripDropLocationOptional;
-(void)sendNotificationAccepted;
-(void)sendNotificationAssigned;
-(BOOL) isTripStartRemainingTimeLessThan:(long )valueInMin;
-(BOOL)isPickedLocal;
-(void) createStripUserCreatePaymentIntentDone:(UIViewController *)controller  trip_fare:(float )trip_fare completionBlock:(void (^_Nullable)(id _Nullable results,   NSError * _Nullable error))block;
-(void) createStripUserCreatePaymentIntentDonetrip_fare:(float)trip_fare completionBlock:(void (^_Nullable)(id _Nullable results,   NSError * _Nullable error,NSString * _Nullable))block;
@end
