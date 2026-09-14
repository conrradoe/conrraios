//
//  RouteDestinationLess.h
//  HireMe Rider
//
//  Created by Grepix - Baij on 22/02/19.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "WebCallConstants.h"
#import "AppDelegate.h"
#import <GIKit/GIKit.h>
#import <MapKit/MapKit.h>
#import <CoreMotion/CoreMotion.h>
#import "Utilities.h"

NS_ASSUME_NONNULL_BEGIN

@interface RouteDestinationLess : NSObject
@property (strong, nonatomic)  MKMapView *mapView;
@property (assign, nonatomic)  BOOL isMapDraged;
@property (assign, nonatomic)  BOOL isFirstLoad;
@property (assign, nonatomic)  BOOL routeDestinationCV;


-(void)setDriverPin:(CLLocation *)loc;
-(void)setDriverCurrentLocation:(CLLocation *)loc;
-(instancetype) initWithMap:(MKMapView *) mapView;
-(float) getTotalTripDIstanceCal;
-(CLLocation *) getCurrentLocation;
-(CLLocation *) getCurrentLocationLast;
-(CLLocation *) getCurrentLocationFirst;
-(void) clearMapDriverPin;
@end

NS_ASSUME_NONNULL_END
