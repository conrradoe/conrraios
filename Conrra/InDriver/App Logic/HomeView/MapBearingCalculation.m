//
//  MapBearingCalculation.m

//
//  Created by Grepix - Baij on 04/10/19.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import "MapBearingCalculation.h"

@implementation MapBearingCalculation
{
    
    float distance;
    float prevAngle;
    CLLocationCoordinate2D preLocationApplied;
    CLLocationCoordinate2D currentLocationApplied;
//    NSMutableArray * arrayLocations;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        distance=10;
        prevAngle=0;
        
    }
    return self;
}
-(CGFloat) DegreesToRadians:(CGFloat )degrees
{
    return degrees * M_PI / 180;
}

-(CGFloat) RadiansToDegrees:(CGFloat) radians
{
    return radians * 180 / M_PI;
}


-(float) getBearing:(CLLocationCoordinate2D) preLocation currentLocation:(CLLocationCoordinate2D) currentLocation
{
    return      [self getBearing:preLocation currentLocation:currentLocation boolTest:YES];
}


-(CLLocation *) toCLLocation:(CLLocationCoordinate2D) preLocation
{
    CLLocation  * StartLocation = [[CLLocation alloc] initWithLatitude:preLocation.latitude longitude:preLocation.longitude];;
    return StartLocation;
}


-(BOOL) isAngleChanged:(CLLocationCoordinate2D) currentLocation
{
    if(preLocationApplied.latitude==0&&preLocationApplied.longitude==0)
    {
//        [arrayLocations addObject:[self toCLLocation:currentLocation]];
        preLocationApplied=currentLocation;
        return YES;
    }
    CLLocation *preLoc=[self toCLLocation:preLocationApplied];
    CLLocation *curLoc=[self toCLLocation:currentLocation];
    if([preLoc distanceFromLocation:curLoc]<distance)
    {
        
        return NO;
    }
    return YES;
}

-(float) getBearing:(CLLocationCoordinate2D) preLocation currentLocation:(CLLocationCoordinate2D) currentLocation boolTest:(BOOL) boolTest
{
    CLLocation *preLoc=[self toCLLocation:preLocationApplied];
    CLLocation *curLoc=[self toCLLocation:currentLocation];
    if([preLoc distanceFromLocation:curLoc]<distance)
    {
        return -10000;
    }
    
    double lat = fabs(preLocationApplied.latitude - currentLocation.latitude);
    double lng = fabs(preLocationApplied.longitude - currentLocation.longitude);
    //
    float anglediff=0;
    if (preLocationApplied.latitude < currentLocation.latitude && preLocationApplied.longitude < currentLocation.longitude)
    {
        preLocationApplied=currentLocation;
        return [self DegreesToRadians:anglediff]+ fabs((atan2(lng ,lat)));
    }
    else if (preLocationApplied.latitude >= currentLocation.latitude && preLocationApplied.longitude < currentLocation.longitude)
    {
        preLocationApplied=currentLocation;
        return [self DegreesToRadians:anglediff] +(([self DegreesToRadians:90] - fabs(atan2(lng , lat))) + [self DegreesToRadians:90]);
    }
    else if (preLocationApplied.latitude >= currentLocation.latitude && preLocationApplied.longitude >= currentLocation.longitude)
    {
        preLocationApplied=currentLocation;
        return [self DegreesToRadians:anglediff]+ fabs((atan2(lng , lat)) + [self DegreesToRadians:180]);
    }
    else if (preLocationApplied.latitude < currentLocation.latitude && preLocationApplied.longitude >= currentLocation.longitude)
    {
        preLocationApplied=currentLocation;
        return [self DegreesToRadians:anglediff]+ (([self DegreesToRadians:90] - fabs(atan2(lng , lat)) + [self DegreesToRadians:270]));
    }
    
    return -10000;
}

-(BOOL) inside:(float) x1 y1:(float) y1 x2:(float ) x2 y2:(float)y2 x:(float)x y:(float) y
{
    if (x > x1 && x < x2 && y > y1 && y < y2)
    {
    return YES;
    }
    return NO;
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

@end
