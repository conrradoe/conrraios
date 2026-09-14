//
//  DirectionModel.m
//  HIREME_RIDER
//
//  Created by Appicial Taxi App Solutions on 12/06/17.
//  Copyright © 2023 Appicial. All rights reserved.
//

#import "DirectionModel.h"
#import "WebCallConstants.h"
#import <GIKit/GIKit.h>
//#import "Constants.h"

@implementation DirectionModel
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.distance=0;
        self.arrDirectionLatLng=[[NSMutableArray alloc]  init];
        self.arrManeuvers=[[NSMutableArray alloc] init];
        self.arrDirectionLatLngSimplified=[[NSMutableArray alloc] init];
        self.arrDirectionLatLngSimplifiedChecked=[[NSMutableArray alloc] init];
    }
    return self;
}

-(void)zoomToPolyLine: (MKMapView*)map polyline: (MKPolyline*)polyline animated: (BOOL)animated
{
    [map setVisibleMapRect:[polyline boundingMapRect] edgePadding:UIEdgeInsetsMake(40.0, 60.0, 40.0, 60.0) animated:animated];
}


- (void)zoomToFitMapAnnotations:(MKMapView *)mapView   currentLocation:(CLLocation *)currentLocation{
    
    
    CLLocationDistance distance = 0.0f;
    
    
    for (CLLocation *location in self.arrDirectionLatLng) {
        CLLocationDistance distanceTemp =  [currentLocation distanceFromLocation:location];
        if (distanceTemp > distance)
        {
            distance = distanceTemp;
        }
    }
    
    distance *= 1.2;
    
    // setting the min zoom level
    if (distance < SCREEN_WIDTH)
    {
        distance =SCREEN_WIDTH;
    }
    if ( self.arrDirectionLatLng.count > 2) {
        CLLocationCoordinate2D loc = [currentLocation coordinate];
        MKCoordinateRegion region =
        MKCoordinateRegionMakeWithDistance(loc, distance, distance);
        MKCoordinateRegion regionMap = [mapView region];
        MKCoordinateRegion adjustedRegion = [mapView regionThatFits:region];
        BOOL isContained = MKMapRectContainsRect( [self mapRectForCoordinateRegion:regionMap],  [self mapRectForCoordinateRegion:adjustedRegion]);
        // map will adjust zoom only if required.
        if (isContained) {
            [mapView setCenterCoordinate:currentLocation.coordinate];
        }
        else{
            [mapView setRegion:adjustedRegion animated:NO];
        }
    }
}


- (MKMapRect)mapRectForCoordinateRegion:(MKCoordinateRegion)coordinateRegion
{
    CLLocationCoordinate2D topLeftCoordinate =
    CLLocationCoordinate2DMake(coordinateRegion.center.latitude
                               + (coordinateRegion.span.latitudeDelta/2.0),
                               coordinateRegion.center.longitude
                               - (coordinateRegion.span.longitudeDelta/2.0));
    
    MKMapPoint topLeftMapPoint = MKMapPointForCoordinate(topLeftCoordinate);
    
    CLLocationCoordinate2D bottomRightCoordinate =
    CLLocationCoordinate2DMake(coordinateRegion.center.latitude
                               - (coordinateRegion.span.latitudeDelta/2.0),
                               coordinateRegion.center.longitude
                               + (coordinateRegion.span.longitudeDelta/2.0));
    
    MKMapPoint bottomRightMapPoint = MKMapPointForCoordinate(bottomRightCoordinate);
    
    MKMapRect mapRect = MKMapRectMake(topLeftMapPoint.x,
                                      topLeftMapPoint.y,
                                      fabs(bottomRightMapPoint.x-topLeftMapPoint.x),
                                      fabs(bottomRightMapPoint.y-topLeftMapPoint.y));
    
    return mapRect;
}


-(MKPolyline *) getPolyline
{
    CLLocationCoordinate2D coords[self.arrDirectionLatLng.count];
    
    for (int i = 0; i < self.arrDirectionLatLng.count; i++) {
        CLLocation *location = [self.arrDirectionLatLng objectAtIndex:i];
        coords[i] = CLLocationCoordinate2DMake(location.coordinate.latitude,location.coordinate.longitude);
    }
    
    return   [MKPolyline polylineWithCoordinates:coords count:self.arrDirectionLatLng.count];
}


-(void)  printGPxDataSimply{
#if TARGET_OS_SIMULATOR
    NSMutableString * stringGPX=[[NSMutableString alloc] init];
    [stringGPX appendString:@"<gpx>\n"];
    for (CLLocation *loc in self.arrDirectionLatLngSimplified) {
        [stringGPX appendString:[NSString stringWithFormat:@"<wpt lat=\"%f\" lon=\"%f\">  </wpt>\n",loc.coordinate.latitude,loc.coordinate.longitude]];
    }
    
    [stringGPX appendString:@"</gpx>"];
    NSLog(@"GPX Data : \n%@",stringGPX);
#else
    
#endif
    
}
@end
