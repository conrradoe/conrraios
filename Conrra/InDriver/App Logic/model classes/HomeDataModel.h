//
//  HomeDataModel.h
//  LT Partner
//
//  Created by Grepix on 19/01/21.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CategoryModel.h"
#import "TripModel.h"
#import "CityModel.h"
#import "WebCallConstants.h"
#import "PromoCodeModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface HomeDataModel : NSObject
@property(strong,nonatomic)CategoryModel*category;
@property(strong,nonatomic)TripModel*trip;
@property(strong,nonatomic)CityModel*city;
/**
 
 
 */
-(void)setTripModel:(TripModel * _Nonnull)trip;


/**
 
 */
-(NSMutableDictionary *)prepareDataForBegin:(NSString *)actualPickupLocationAddress;


/**
 
 
 */
-(void) updateLocalAfterUpdateBegin:(NSMutableDictionary*) dict;

/**
 
 
 */
-(void)sendNotification:(NSString *)status;


/**
 
 
 */

-(NSMutableDictionary *) prepareDataForEnd:(NSString *)actualDropLocationAddress TotalTripDIstance:(float )TotalTripDIstance promoCode:(PromoCodeModel *) promoCode;


-(NSMutableDictionary *) prepareDataForDriverCancelAtPickUp:(NSString *)reasonString ;


- (void)updateLocalAfterUpdateEnd:(NSMutableDictionary *)dict;

@end

NS_ASSUME_NONNULL_END
