//
//  RouteDestinationLess.m
//  HireMe Rider
//
//  Created by Grepix - Baij on 22/02/19.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import "RouteDestinationLess.h"

@implementation RouteDestinationLess
{
    int  modofiedTrackLastIndex;
//    MKPointAnnotation *driverPin;
//    MKPointAnnotation *preDriverPin;
    BOOL StartLocationTaken;
    CLLocation *StartLocation,*CurrentLocation,*OldLocation,*NewLocaton,*OldLoc,*NewLoc,*pathLast,*pathFirst;
    NSString *_activtiyNameDetactor;
    NSString *driverStatus;
    float TotalM,TotalTripDIstance;
    NSMutableArray *arrFilteredWayPoints, *arrCoveredRootPoints;
}

-(float) getTotalTripDIstanceCal
{
    return TotalTripDIstance;
}
-(instancetype) initWithMap:(MKMapView *) mapView
{
    self = [super init];
    if (self) {
        self.mapView=mapView;
        arrFilteredWayPoints =[[NSMutableArray alloc]init];
        arrCoveredRootPoints =[[NSMutableArray alloc]init];
        driverStatus=@"begin";
    }
    return self;
}


-(void)setDriverCurrentLocation:(CLLocation *)loc
{
    CurrentLocation=loc;
    StartLocationTaken=TRUE;
}
-(CLLocation *)getCurrentLocation
{
    return CurrentLocation;
}
-(CLLocation *) getCurrentLocationLast;
{
    return pathLast;
}
-(CLLocation *) getCurrentLocationFirst;
{
    return pathFirst;
}

-(void) mapRegion:(MKCoordinateRegion ) region mapView:(MKMapView *)mapView{
    @try {
        [mapView setRegion:[mapView regionThatFits:region] animated:NO];
    } @catch (NSException *exception) {
        if( region.center.longitude > -89 && region.center.longitude < 89 && region.center.longitude > -179 && region.center.longitude < 179 ){
        [mapView setRegion:[mapView regionThatFits:region] animated:YES];
        }
    } @finally {
    }
}

-(void)setDriverPin:(CLLocation *)loc
{
    CurrentLocation=loc;
     if(!self.routeDestinationCV)
     {
//    [self CenterMapRegionForShot];
     }
    AppDelegate *appdelegate= APP_DELEGATE;
    appdelegate.currLoc = loc;
    NSDictionary * dict =[[NSDictionary alloc]initWithObjectsAndKeys:[NSString stringWithFormat:@"%f",appdelegate.currLoc.coordinate.latitude],@"lat",[NSString stringWithFormat:@"%f",appdelegate.currLoc.coordinate.longitude ],@"lng", nil];
    defaults_set_object(@"curr_loc", dict);

    
    if (!self.isFirstLoad) {
        self.isFirstLoad =YES;
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(loc.coordinate, 600, 600);
        [self mapRegion:region mapView:self.mapView];
    }
    
    //if ([driverStatus isEqualToString:TS_BEGIN ]) {
    if (StartLocationTaken == FALSE && [Utilities isValidLocation:CurrentLocation.coordinate]) {
        StartLocationTaken = TRUE;
        StartLocation = [[CLLocation alloc] initWithLatitude:CurrentLocation.coordinate.latitude longitude:CurrentLocation.coordinate.longitude];
        
        NewLocaton = [[CLLocation alloc] init];
        OldLocation = [[CLLocation alloc] init];
        NewLoc = [[CLLocation alloc] init];
        OldLoc = [[CLLocation alloc] init];
        OldLoc =StartLocation;
        OldLocation = StartLocation;
    }
    else{
        BOOL b = [CMMotionActivityManager isActivityAvailable];
        if(b)
        {
            if([_activtiyNameDetactor isEqualToString:@"Not Walking"] || [_activtiyNameDetactor isEqualToString:@"stationary"])
            {
                return;
            }
        }
        else{
            if(CurrentLocation.horizontalAccuracy>20)
            {
                return;
            }
        }
        NewLocaton = loc;
        
        if ([driverStatus isEqualToString:TS_BEGIN]) {
            if (OldLocation.coordinate.latitude==0.0) {
                OldLocation = NewLocaton;
            }
            float dis =0.0;
            if ([Utilities isValidLocation:OldLocation.coordinate] && [Utilities isValidLocation:NewLocaton.coordinate]) {
                dis = [NewLocaton distanceFromLocation:OldLocation];
            }
            if (dis >5) {
                TotalM = TotalM+dis;
//                [UtilityClass showWarningAlert:@"Alert_3" message:[NSString stringWithFormat:@"3  %.2f",TotalM] cancelButtonTitle:@"Ok" otherButtonTitle:nil];
                TotalTripDIstance = (TotalM / 1000.0); //Converting Meters to KM
                NSString *dist =[NSString stringWithFormat:@"%f",TotalTripDIstance];
                defaults_set_object(@"total_travelled_distance",dist );
                if (![arrCoveredRootPoints containsObject:dict]) {
                    [arrCoveredRootPoints addObject:dict];
                    defaults_set_object(@"travelled_points_array",arrCoveredRootPoints);
                    NSMutableArray *arrtemp1 = [self convertDictToLoc:arrCoveredRootPoints];
                    NSMutableArray * arrTrackedPointsModified=[[NSMutableArray alloc] init];
                    int range=5;
                    if(arrCoveredRootPoints.count>range)
                    {
                        modofiedTrackLastIndex++;
                        NSMutableArray * arrayTemp=[[NSMutableArray alloc] init];
                        for (int i=(int)(arrCoveredRootPoints.count-range); i<arrCoveredRootPoints.count; i++) {
                            [arrayTemp  addObject:[arrCoveredRootPoints  objectAtIndex:i]];
                        }
                        NSMutableArray *arrtemp2 = [self convertDictToLoc:arrayTemp];
                        [self resolve:arrtemp2 outputArray:arrTrackedPointsModified];
                        for (NSDictionary * dict in arrayTemp) {
                            [arrCoveredRootPoints removeObject:dict];
                            
                        }
                        
                        NSMutableArray *arrTmp3 = [self convertLocToDict:arrTrackedPointsModified];
                        
                        [arrCoveredRootPoints  addObjectsFromArray: arrTmp3];
                        modofiedTrackLastIndex=0;
                    }
                    else
                    {
                        
                        [self resolve:arrtemp1 outputArray:arrTrackedPointsModified];
                        
                        NSMutableArray *arrTmp4 = [self convertLocToDict:arrTrackedPointsModified];
                        arrCoveredRootPoints =[[NSMutableArray alloc] initWithArray:arrTmp4];
                        
                        //                    [self resolve:arrTrackedPoints outputArray:arrTrackedPointsModified];
                        //                    arrTrackedPoints=[[NSMutableArray alloc] initWithArray:arrTrackedPointsModified];
                    }
                }
                [self drawReRoute:arrCoveredRootPoints];
            }
            //                //_lblLocationTitle.text = [NSString stringWithFormat:@"%.2f",TotalTripDIstance* 0.621371192];
            OldLocation = NewLocaton;
        }
    }
}



-(void) clearMapDriverPin
{
//    [self.mapView removeAnnotation:driverPin];
//    [self.mapView removeAnnotation:preDriverPin];
}
-(NSMutableArray *)convertLocToDict:(NSMutableArray *)arrPoints{
    
    NSMutableArray *arrTemp1 =[[NSMutableArray alloc]init];
    for (CLLocation *loc in arrPoints) {
        
        NSDictionary *dict =[[NSDictionary alloc]initWithObjectsAndKeys:[NSString stringWithFormat:@"%f",loc.coordinate.latitude],@"lat", [NSString stringWithFormat:@"%f",loc.coordinate.longitude],@"lng", nil];
        
        //CLLocation *loc1 = [[CLLocation alloc]initWithLatitude:[[dict objectForKey:@"lat"]floatValue] longitude:[[dict objectForKey:@"lng"]floatValue]];
        [arrTemp1 addObject:dict];
    }
    return arrTemp1;
}






-(void)resolve:(NSMutableArray *) arrayPoint  outputArray:(NSMutableArray *) output
{
    NSMutableArray *tmp=[[NSMutableArray alloc] init];
    int iterations=2;
    [output removeAllObjects];
    if (arrayPoint.count<=2) { //simple copy
        [output addObjectsFromArray:arrayPoint];
        return;
    }
    int simplifyTolerance=0.3;
    //simplify with squared tolerance
    if (simplifyTolerance>0 && arrayPoint.count>3) {
        [self  simplify:arrayPoint sqTolerance:simplifyTolerance outputArray:tmp];
        arrayPoint = tmp;
    }
    //perform smooth operations
    if (iterations<=0) { //no smooth, just copy input to output
        [output addObjectsFromArray:arrayPoint];
    } else if (iterations==1) { //1 iteration, smooth to output
        [self smooth:arrayPoint outputArray:output];
    } else { //multiple iterations.. ping-pong between arrays
        int iters = iterations;
        //subsequent iterations
        do {
            [self smooth:arrayPoint outputArray:output];
            [tmp removeAllObjects];
            [tmp addObjectsFromArray:output];
            NSMutableArray * old=output;
            arrayPoint=tmp;
            output = old;
        } while (--iters > 0);
    }
}

-(void) smooth:(NSMutableArray *) arrayPoint  outputArray:(NSMutableArray *) output
{
    if(arrayPoint.count==0)
    {
        return;
    }
    [output removeAllObjects];
    [output addObject:[arrayPoint objectAtIndex:0]];
    
    //average elements
    for (int i=0; i<arrayPoint.count-1; i++) {
        CLLocation  *p0 = [arrayPoint objectAtIndex:i];//[[CLLocation alloc]initWithLatitude:[[[arrayPoint objectAtIndex:i] objectForKey:@"lat"] doubleValue] longitude:[[[arrayPoint objectAtIndex:i] objectForKey:@"lng"] doubleValue]] ;
        CLLocation  *p1 = [arrayPoint objectAtIndex:i+1];//[[CLLocation alloc]initWithLatitude:[[[arrayPoint objectAtIndex:i+1] objectForKey:@"lat"] doubleValue] longitude:[[[arrayPoint objectAtIndex:i+1] objectForKey:@"lng"] doubleValue]] ;
        
        //        CLLocation *p0 =loc0.location;
        //        CLLocation *p1 = loc1.location;
        
        CLLocation *Q = [[CLLocation alloc] initWithLatitude:0.75f * p0.coordinate.latitude + 0.25f * p1.coordinate.latitude longitude: 0.75f * p0.coordinate.longitude + 0.25f * p1.coordinate.longitude];
        
        CLLocation *R =[[CLLocation alloc] initWithLatitude:0.25f * p0.coordinate.latitude + 0.75f * p1.coordinate.latitude longitude:0.25f * p0.coordinate.longitude + 0.75f * p1.coordinate.longitude];
        
        //        CLLocation  *loc0Q= [[LocationModel alloc] init];
        //        loc0Q.location=Q;
        //        LocationModel  *loc1R = [[LocationModel alloc] init];
        //        loc1R.location=R;
        [output addObject:Q];
        [output addObject:R];
    }
}


-(void) simplify:(NSMutableArray *) locations   sqTolerance:(float)sqTolerance outputArray:(NSMutableArray *) output{
    if(locations.count==0)
    {
        return;
    }
    int len =(int)locations.count;
    CLLocation *point = [[CLLocation alloc] init];
    
    CLLocation *prevPoint = [locations objectAtIndex:0];
    //CLLocation *prevPoint =  loc.location;
    [output removeAllObjects];
    [output addObject:prevPoint];
    
    for (int i = 1; i < len; i++) {
        point = [locations objectAtIndex:i];
        if ([self distSq:point location1: prevPoint ] > sqTolerance) {
            [output addObject:point];
            prevPoint = point;
        }
    }
    if (prevPoint!=point) {
        [output addObject:point];
    }
    
}




-(float) distSq:(CLLocation *) l1 location1:(CLLocation *) l2
{
    CLLocationCoordinate2D p1=l1.coordinate;
    CLLocationCoordinate2D p2=l2.coordinate;
    float dx = p1.latitude - p2.latitude, dy = p1.longitude - p2.longitude;
    return dx * dx + dy * dy;
}





-(NSMutableArray *)convertDictToLoc:(NSMutableArray *)arrPoints{
    
    NSMutableArray *arrTemp1 =[[NSMutableArray alloc]init];
    for (NSDictionary *dict in arrPoints) {
        
        CLLocation *loc1 = [[CLLocation alloc]initWithLatitude:[[dict objectForKey:@"lat"]floatValue] longitude:[[dict objectForKey:@"lng"]floatValue]];
        [arrTemp1 addObject:loc1];
    }
    return arrTemp1;
}

-(void)drawReRoute:(NSMutableArray *)arrFiltered{
    CLLocationCoordinate2D coordinates[arrFiltered.count];
    
    int coordinatesIndex = 0;
    
    for (NSDictionary * dict in arrFiltered) {
        
        double x = [[dict objectForKey:@"lat"] doubleValue];
        double y = [[dict valueForKey:@"lng"] doubleValue];
        
        CLLocationCoordinate2D coordinate;
        coordinate.latitude = x;
        coordinate.longitude = y;
        
        //Put this coordinate in the C array...
        coordinates[coordinatesIndex] = coordinate;
        
        coordinatesIndex++;
    }
    
    
    
    //C array is ready, create the polyline...
    MKPolyline *polyline = [MKPolyline polylineWithCoordinates:coordinates count:arrFiltered.count];
    NSArray *arrayRemove;
    if(self.routeDestinationCV)
    {
        polyline.title=@"cv";
        for (id<MKOverlay> overlay in self.mapView.overlays) {
            if([overlay.title isEqualToString:@"cv"])
            {
                [self.mapView removeOverlay:overlay];
            }
        }
        
    }else
    {
        arrayRemove=[[NSArray alloc] initWithArray:self.mapView.overlays];
        
//        [self.mapView removeOverlays:self.mapView.overlays];
    }
    
     if(arrFiltered.count>0)
     {
        
         NSDictionary * dict  =[arrFiltered lastObject];
             
             double x = [[dict objectForKey:@"lat"] doubleValue];
             double y = [[dict valueForKey:@"lng"] doubleValue];
        pathLast=[[CLLocation alloc]  initWithLatitude:x longitude:y];
         NSDictionary * dict1  =[arrFiltered firstObject];
         
         double x1 = [[dict1 objectForKey:@"lat"] doubleValue];
         double y1= [[dict1 valueForKey:@"lng"] doubleValue];
         pathFirst=[[CLLocation alloc]  initWithLatitude:x1 longitude:y1];
     }

    [_mapView addOverlay:polyline level:MKOverlayLevelAboveRoads];
     [self.mapView removeOverlays:arrayRemove];
}
- (void) CenterMapRegionForShot {
    
    if (!self.isMapDraged) {
        AppDelegate *delegate = APP_DELEGATE;
        CLLocation *myLocation = [[CLLocation alloc]initWithLatitude:delegate.currLoc.coordinate.latitude longitude:delegate.currLoc.coordinate.longitude];
        _mapView.camera.centerCoordinate = myLocation.coordinate;
        if (!self.isFirstLoad) {
            MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(delegate.currLoc.coordinate, 600, 600);
            _mapView.region =region;
        }
        [self.mapView setCamera:self.mapView.camera];
    }
}
@end
