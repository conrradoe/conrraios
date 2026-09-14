//
//  DirectionModel.h
//  HIREME_RIDER
//
//  Created by Appicial Taxi App Solutions on 12/06/17.
//  Copyright © 2023 Appicial. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
@interface DirectionModel : NSObject
@property(assign,nonatomic) float distance; // miles
@property(assign,nonatomic) float duration;
@property(strong,nonatomic) NSMutableArray * arrDirectionLatLng;
@property(strong,nonatomic) NSMutableArray * arrDirectionLatLngSimplified;
@property(strong,nonatomic) NSMutableArray * arrDirectionLatLngSimplifiedChecked;
@property(strong,nonatomic) NSMutableArray * arrManeuvers;
@property(strong,nonatomic) CLLocation * northeast;
@property(strong,nonatomic) CLLocation * southwest;
@property(assign,nonatomic) int duration_in_traffic;
@property(assign,nonatomic) float speed_in_kmphs;

-(void)  printGPxDataSimply;

- (void)zoomToFitMapAnnotations:(MKMapView *)mapView    currentLocation:(CLLocation *)currentLocation;
-(void)zoomToPolyLine: (MKMapView*)map polyline: (MKPolyline*)polyline animated: (BOOL)animated;

-(MKPolyline *) getPolyline;
@end
