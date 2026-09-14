//
//  BookingModel.h
//
//  Created by Grepix on 25/01/21.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GoogleDirectionSource.h"
#import "CategoryModel.h"
#import "CityModel.h"
#import "DirectionModel.h"
#import "EstimatedFare.h"
#import "PromoCodeModel.h"
#import "PromoCode.h"


NS_ASSUME_NONNULL_BEGIN
typedef enum : NSUInteger {
    DAILY,
    RENTALS,
    OUTSTATION,
} BookingType;

@interface BookingModel : NSObject
@property(assign,)BOOL isRideLater;
@property(assign,nonatomic)BOOL isAutoAppliedOTP;
@property(strong,nonatomic)NSString *stringPassengerDetail;
@property(strong,nonatomic) GoogleDirectionSource *direction;
@property(strong,nonatomic)NSDate *tripDate;
@property(strong,nonatomic)NSString *pay_card;
@property(assign,nonatomic)int totalTime;
@property(assign,nonatomic)float totalDistance;
@property(strong,nonatomic)NSMutableDictionary *fareEstimated;
//@property(assign,nonatomic)int duration_in_traffic;
@property(strong,nonatomic) NSArray *routeArray;
@property(strong,nonatomic)CategoryModel *category;
@property(strong,nonatomic)CityModel *cityModel;
@property(strong,nonatomic) DirectionModel * dModel;
@property(strong,nonatomic) NSDictionary *dictCustomiseOptions;
@property(strong,nonatomic) NSString *parentDetailsEntered;
@property(strong,nonatomic) NSString *pay_intent;
@property(strong,nonatomic)PromoCodeModel *promoCode;
@property(strong,nonatomic)DirectionModel *directionModel;
@property(assign,nonatomic) int num_seats;
@property(assign,nonatomic)BOOL isRiderSahre;
@property(assign,nonatomic)BookingType bookingType ;

-(void) callFareEstimateApiWithCompletionBlock:(void (^)(id results, NSError *error)) block promoCode:(PromoCodeModel *) promoCode;
-(NSMutableDictionary *) prepareAPIData;
//-(NSMutableDictionary *) getExtraOption:(NSDictionary *)dictCustomiseOptions parentDetailsEntered:(NSString *)parentDetailsEntered;
//-(NSMutableDictionary *)getPromoDict:(PromoCodeModel *)promoCode;
-(EstimatedFare *) getEstimateFareForCategory:(int) category_id;

-(PromoCode *) poromCodeApplied;
@end

NS_ASSUME_NONNULL_END
