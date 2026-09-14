//
//  NearByDriverHandler.h
//  HIREME_RIDER
//
//  Created by Appicial Taxi App Soutions on 14/06/17.
//  Copyright © 2023 Appicial Taxi App Soutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DriverModel.h"
#import <MapKit/MapKit.h>
#import "Utilities.h"

@class  NearByDriverHandler;
@protocol NearByDriverHandlerDelegate <NSObject>
-(void)onStartRefreshing;
-(void) onRefreshNearByDriver:(NSMutableArray *) arrayDrivers; 

@end
@interface NearByDriverHandler : NSObject

@property(strong,nonatomic) NSString *categoryId;
@property(strong,nonatomic) NSString *city_id;
@property(assign,nonatomic) int carCount;

@property(strong,nonatomic)  CLLocation * pickUpLocation ;
@property(weak,nonatomic) id<NearByDriverHandlerDelegate> delegate;

-(void) startGettingNearByDriver;
-(void) stopGetNearByDriver;

-(void) changeCategoryId :(int) categoryId city_id:(NSString * ) city_id;

-(void) changePickUpLocation :(CLLocation *) picklocation;


@end
