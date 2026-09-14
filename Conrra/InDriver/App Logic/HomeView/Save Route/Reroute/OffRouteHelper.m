//
//  OffRouteHelper.m
//  LTS Driver
//
//  Created by Grepix on 05/02/21.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import "OffRouteHelper.h"

@implementation OffRouteHelper

-(void)resolve:(NSMutableArray *) arrayPoint  outputArray:(NSMutableArray *) output
{
    NSMutableArray *tmp=[[NSMutableArray alloc] init];
    int iterations=2;
    [output removeAllObjects];
    if (arrayPoint.count<=2) { //simple copy
        [output addObjectsFromArray:arrayPoint];
        return;
    }
    float simplifyTolerance=30/*70.0*/;
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

        CLLocation *p0 =[arrayPoint objectAtIndex:i];
        CLLocation *p1 = [arrayPoint objectAtIndex:i+1];
        
        CLLocation *Q = [[CLLocation alloc] initWithLatitude:0.75f * p0.coordinate.latitude + 0.25f * p1.coordinate.latitude longitude: 0.75f * p0.coordinate.longitude + 0.25f * p1.coordinate.longitude];
        
        CLLocation *R =[[CLLocation alloc] initWithLatitude:0.25f * p0.coordinate.latitude + 0.75f * p1.coordinate.latitude longitude:0.25f * p0.coordinate.longitude + 0.75f * p1.coordinate.longitude];
        
//        LocationModel  *loc0Q= [[LocationModel alloc] init];
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
    
//    CLLocation *loc = [locations objectAtIndex:0];
    CLLocation *prevPoint =  [locations objectAtIndex:0];
    [output removeAllObjects];
//    LocationModel *pointLoc2 =[[LocationModel alloc]  init];
//    pointLoc2.location=prevPoint;
    [output addObject:prevPoint];
    
    for (int i = 1; i < len; i++) {
        point = [locations objectAtIndex:i];
//        point =pointLoc.location ;
        
        if ([self distSq:point location1: prevPoint ] > sqTolerance) {
//            LocationModel *pointLoc1 =[[LocationModel alloc]  init];
//            pointLoc1.location=point;
            [output addObject:point];
            prevPoint = point;
        }
    }
    if (prevPoint!=point) {
//        LocationModel *pointLoc =[[LocationModel alloc]  init];
//        pointLoc.location=point;
        [output addObject:point];
    }
    
}




-(float) distSq:(CLLocation *) l1 location1:(CLLocation *) l2
{
    if([l1 isKindOfClass:[CLLocation class]]&&[l2 isKindOfClass:[CLLocation class]])
    {
        return [l1 distanceFromLocation:l2];
    }
    return 0;
    //    CLLocationCoordinate2D p1=l1.coordinate;
    //    CLLocationCoordinate2D p2=l2.coordinate;
    //    float dx = p1.latitude - p2.latitude, dy = p1.longitude - p2.longitude;
    //    return dx * dx + dy * dy;
}
@end
