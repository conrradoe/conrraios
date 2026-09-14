//
//  GoogleDirectionSource.m
//  HIREME_RIDER
//
//  Created by Appicial Taxi App Soutions on 12/06/17.
//  Copyright © 2023 Appicial Taxi App Soutions. All rights reserved.
//

#import "GoogleDirectionSource.h"
// 
#import "WebCallConstants.h"
#import <GIKit/GIKit.h>
#import "AFHTTPRequestOperationManager.h"
#import "AppDelegate.h"
#import "OffRouteHelper.h"
@interface GoogleDirectionSource()
{
    int apiCounter;
}
@end


@implementation GoogleDirectionSource
-(instancetype)initWithSource:(CLLocation *) source destination:(CLLocation *) destination
{
    self=[self init];
    self.source=source;
    self.destination=destination;
    return self;
}

-(void) findDirection_isInTrip:(BOOL)isInTrip WithCompletionBlock:(void (^)(id results, NSError *error)) block
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    
    
    NSString *googleKey=[APP_DELEGATE getGoogleKey];  
    NSString *urlString = [NSString stringWithFormat:
                           @"%@?origin=%f,%f&destination=%f,%f&sensor=true&key=%@&mode=driving%@",
                           @"https://maps.googleapis.com/maps/api/directions/json",
                           self.source.coordinate.latitude,
                           self.source.coordinate.longitude,
                           self.destination.coordinate.latitude,
                           self.destination.coordinate.longitude,
                           googleKey,IS_ENABLE_TRAFFIC==1?(self.isEstimate?@"&departure_time=now":@""):@""];
    [manager GET:urlString parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             
             NSDictionary *response = [[NSDictionary alloc] initWithDictionary:responseObject];
             if ([response objectForKey:@"error_message"] /*&& !isInTrip*/){    //[[response objectForKey:@"status"] isEqualToString:@"OVER_QUERY_LIMIT"]
                 
                 if (self->apiCounter>=2) {   //  //
                     [UtilityClass swa:@"" m:[response objectForKey:@"error_message"] cbt:@"Ok" obt:nil vc:[UIApplication sharedApplication].keyWindow.rootViewController];
                     //NSError *error = nil;
                     //block(nil,error);
                     block([self directionRoute:responseObject],nil);
                 }
                 else {
                     self->apiCounter++;
                     [self findDirection_isInTrip:isInTrip WithCompletionBlock:block];
                 }
             }
             else {
                 block([self directionRoute:responseObject],nil);
             }
             
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             block(nil,error);
         }];
}

-(DirectionModel *)directionRoute:(NSDictionary *)response
{
    NSMutableArray *arrTrackedPoints =[[NSMutableArray alloc]init];
   NSMutableArray *arrManeuver =[[NSMutableArray alloc]init];
    float distanceMiles=0;
    float duration=0;
    int durationInSeconds=0;
    int duration_in_traffic=0;
    if([[[response objectForKey:P_STATUS] uppercaseString] isEqualToString:@"OK"])
    {
        NSArray * routes=[response objectForKey:@"routes"];
        for(int i=0;i<routes.count;i++){
            NSArray  *jLegs = [( (NSDictionary *)[routes objectAtIndex:i]) objectForKey:@"legs"];
            
            NSDictionary * bounds = [[routes objectAtIndex:i] objectForKey:@"bounds"];
            
            _northeast = [[CLLocation alloc]initWithLatitude:[[[bounds objectForKey:@"northeast"] objectForKey:@"lat"] doubleValue] longitude:[[[bounds objectForKey:@"northeast"] objectForKey:@"lng"] doubleValue]];
            _southwest = [[CLLocation alloc]initWithLatitude:[[[bounds objectForKey:@"southwest"] objectForKey:@"lat"] doubleValue] longitude:[[[bounds objectForKey:@"southwest"] objectForKey:@"lng"] doubleValue]];
          
            
            for(int j=0;j<jLegs.count;j++){
                NSDictionary * dictLeg=[ jLegs objectAtIndex:j];
                
                // distance and time calculation
                   distanceMiles = [[[dictLeg objectForKey:@"distance"]objectForKey:@"value"] floatValue];
                distanceMiles = distanceMiles/1000;
                // duration
                int durrationTotal=[[[dictLeg objectForKey:@"duration"]objectForKey:@"value"] intValue];
                durationInSeconds=durrationTotal;
                int second=durrationTotal%60;
                
                if(second>0) {
                    duration = durrationTotal/60+1;
                }else{
                    duration = durrationTotal/60;
                }
                
             //duration_in_traffic
                int duration_in_trafficTotal=[[[dictLeg objectForKey:@"duration_in_traffic"]objectForKey:@"value"] intValue];
                int secondTraffic=duration_in_trafficTotal%60;
                if(secondTraffic>0)  {
                    duration_in_traffic = duration_in_trafficTotal/60+1;
                }else{
                    duration_in_traffic = duration_in_trafficTotal/60;
                }
                NSArray *steps=[dictLeg objectForKey:@"steps"];
                
                
                for(int k=0;k<steps.count;k++){
                    
                    NSDictionary *step=[steps objectAtIndex:k];
                    NSString *points=   [[step objectForKey:@"polyline"]  objectForKey:@"points"];
                    //Maneuver
                    NSString *maneuver=[step objectForKey:@"maneuver"];
                    if(maneuver)
                    {
                        CLLocation *p=[[CLLocation alloc] initWithLatitude:[[[step objectForKey:@"start_location"] objectForKey:@"lat"] doubleValue] longitude:[[[step objectForKey:@"start_location"] objectForKey:@"lng"] doubleValue]];
                        NSDictionary *dict=@{@"Maneuver":[step objectForKey:@"maneuver"],@"html_instructions":[step objectForKey:@"html_instructions"],@"start_location":p};
                        
                        [arrManeuver addObject:dict];
                    }
                    NSArray * decodepoints=[self decodePoints:points];
                    for (CLLocation * lo in decodepoints) {
                        [arrTrackedPoints addObject:lo];
                    }
                }
            }
        }
    }
    else{
        
    }
    float speed=((distanceMiles*1000.0)/(durationInSeconds)*3.6);
    DirectionModel * dModel=[[DirectionModel alloc]  init];
    dModel.arrDirectionLatLng=arrTrackedPoints;
    
    OffRouteHelper * offHelper=[[OffRouteHelper alloc] init];
    [offHelper resolve:arrTrackedPoints outputArray:dModel.arrDirectionLatLngSimplified];
    dModel.arrDirectionLatLngSimplifiedChecked=[[NSMutableArray alloc] initWithArray:dModel.arrDirectionLatLngSimplified];
    
    dModel.arrManeuvers=arrManeuver;
    dModel.distance=distanceMiles;
    dModel.duration=duration;
    dModel.speed_in_kmphs=speed;
    dModel.duration_in_traffic = duration_in_traffic;
    dModel.northeast =_northeast;
    dModel.southwest = _southwest;
    [dModel printGPxDataSimply];
    return  dModel;
    
}
-( NSArray *) decodePoints:(NSString *) encoded
{
    NSMutableArray *poly=[[NSMutableArray alloc] init];
    int index = 0;
    int len = (int)encoded.length;
    int lat = 0, lng = 0;
    
    while (index < len) {
        int b, shift = 0, result = 0;
        do {
            
            //            b = encoded.charAt(index++) - 63;
            b =  [encoded characterAtIndex:index++]- 63;
            result |= (b & 0x1f) << shift;
            shift += 5;
        } while (b >= 0x20);
        int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
        lat += dlat;
        
        shift = 0;
        result = 0;
        do {
            b =  [encoded characterAtIndex:index++]- 63;
            //            b = encoded.charAt(index++) - 63;
            result |= (b & 0x1f) << shift;
            shift += 5;
        } while (b >= 0x20);
        int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
        lng += dlng;
        //        LatLng p = new LatLng((((double) lat / 1E5)),
        //                              (((double) lng / 1E5)));
        //        poly.add(p);
        CLLocation *p=[[CLLocation alloc] initWithLatitude:(((double) lat / 1E5)) longitude:(((double) lng / 1E5))];
        [poly addObject:p];
    }
    return poly;
}
-(BOOL) isSourceEmpty
{
    if(self.source==nil)
    {
        return YES;
    }
    if(self.source.coordinate.latitude==0.0&&self.source.coordinate.longitude==0.0)
    {
        return YES;
    }
    return NO;
}
-(BOOL) isDestinationEmpty
{
     if(self.destination==nil)
     {
         return YES;
     }
     if(self.destination.coordinate.latitude==0.0&&self.destination.coordinate.longitude==0.0)
     {
         return YES;
     }
    return NO;
}
@end
