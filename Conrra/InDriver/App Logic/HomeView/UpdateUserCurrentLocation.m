//
//  UpdateUserCurrentLocation.m
//  TeamJoe
//
//  Created by Appicial Taxi App Solutions on 24/05/16.
//  Copyright © 2016 ZappDesignTemplates. All rights reserved.
//
#import <GIKit/GIKit.h>
#import "UpdateUserCurrentLocation.h"
#import <MapKit/MapKit.h>
#import "AppDelegate.h"
#import "WebCallConstants.h"
#import "LeftViewController.h"

@implementation UpdateUserCurrentLocation
{
    float distance;
    NSTimer *aTimer;
    int secondCount;
    int apiCount;
    CLLocation *preLocation;
    float angle;
//    NSString  *isAvailable;
    
    
    
}
+ (UpdateUserCurrentLocation *)sharedInstance {
    static UpdateUserCurrentLocation *_sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[self alloc] init];
        _sharedInstance.driverDegree=0;
    });
    
    
    return _sharedInstance;
}

-(void) startUpdateCurrentLocation
{
//    isAvailable=@"1";
    
    angle=0;
    distance=0;
    [self stopUpdateCurrentLocation];
   
    NSString *isAvailabilityLocalOn=defaults_object(is_availability_on);
    NSString * tripID=defaults_object(TRIP_ID);
    if(tripID!=nil&&[tripID intValue]>0)  {
        isAvailabilityLocalOn=@"1";
    }
    if([isAvailabilityLocalOn boolValue]){
        //    [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler];
        aTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                  target:self
                                                selector:@selector(updateLocation)
                                                userInfo:nil
                                                 repeats:YES];
        
        
        [[NSRunLoop currentRunLoop] addTimer:aTimer forMode:NSRunLoopCommonModes];
        [self updateLocationAfterFiveM];
    }
    //[self updateLocationAfterFiveM];
}



-(void) updateLocation{
    NSDictionary *dict1 = [[NSUserDefaults standardUserDefaults]objectForKey:P_USER_DICT_LOGGED];
    if(dict1==nil) {
        [self stopUpdateCurrentLocation];
        return;
    }
    angle=0;
    secondCount++;
    if([Utilities isValidLocation:[APP_DELEGATE currLoc].coordinate]){
        CLLocation * loc=[[CLLocation alloc]  initWithLatitude:[APP_DELEGATE currLoc].coordinate.latitude longitude:[APP_DELEGATE currLoc].coordinate.longitude];
        if(preLocation!=nil) {
            distance =[self calculateDistanceInMilesFrom:preLocation to:loc];
        }
        if(preLocation==nil || distance>30.0)  {
            if([Utilities isValidLocation:[APP_DELEGATE currLoc].coordinate]) {
                preLocation=loc;
                if (loc !=nil /*&& city.length>0 && country.length>0*/) {
                    NSString *driverID = isEmpty([dict1 objectForKey:P_USER_ID]);
                    
                    NSDictionary *dict;
                    BOOL is_user_login = [defaults_object(P_IS_USER_LOGIN) boolValue];
                    if(is_user_login){
                        dict=@{P_USER_LAT:isEmpty(@(preLocation.coordinate.latitude)),
                               P_USER_LNG:isEmpty(@(preLocation.coordinate.longitude)),
                               P_USER_ID:driverID,
                               //                               P_DRIVER_AVAILAILITY:isEmpty(isAvailable),
//                               @"u_degree":isEmpty(@(self.driverDegree)),
                        };
                        [GIC mkwu:UPDATE_USER_PROFILE
                                      d:dict
                          isa:NO
                               cb:^(id results, NSError *error) {
                            self->apiCount++;
                            if ([[[results objectForKey:P_STATUS] uppercaseString] isEqualToString:@"OK"]) {
                                self->secondCount=0;
                                self->apiCount =0;
                                
                            }
                            else{
                                if (self->apiCount<3) {
                                    
                                    [self updateLocation];
                                }
                            }
                        }];

                    }else{
                        NSDictionary *dictLoggedDriver = [[NSUserDefaults standardUserDefaults]objectForKey:P_USER_DICT];
                        dict=@{P_DRIVER_LAT:isEmpty(@(preLocation.coordinate.latitude)),
                               P_DRIVER_LNG:isEmpty(@(preLocation.coordinate.longitude)),
                               P_DRIVER_ID:isEmpty([dictLoggedDriver objectForKey:P_DRIVER_ID]),
                               @"d_degree":isEmpty(@(self.driverDegree)),
                               @"usr_ref_id":isEmpty(driverID)
                        };
                         
                        [GIC mkwu:UPDATE_DRIVER_PROFILE
                                      d:dict
                          isa:NO
                               cb:^(id results, NSError *error) {
                            self->apiCount++;
                            if ([[[results objectForKey:P_STATUS] uppercaseString] isEqualToString:@"OK"]) {
                                self->secondCount=0;
                                self->apiCount =0;
                                
                            }
                            else{
                                if (self->apiCount<3) {
                                    
                                    [self updateLocation];
                                }
                            }
                        }];

                    }
                                        
                }
                
            }
        }
        else{
            [self checkAndUpdateLocation];
        }
    }
    else{
        [self checkAndUpdateLocation];
    }
}

-(void)  checkAndUpdateLocation
{
    if(secondCount>(60*5))
    {
        [self updateLocationAfterFiveM];
        secondCount=0;
    }
}



-(void) updateLocationAfterFiveM{
    apiCount =0;
    CLLocation * loc=[[CLLocation alloc]  initWithLatitude:[APP_DELEGATE currLoc].coordinate.latitude longitude:[APP_DELEGATE currLoc].coordinate.longitude];
    preLocation=loc;
    if ([Utilities isValidLocation:loc.coordinate]) {
        NSDictionary *dict1 = [[NSUserDefaults standardUserDefaults]objectForKey:P_USER_DICT_LOGGED];
        NSString *driverID = isEmpty([dict1 objectForKey:P_USER_ID]);
        NSDictionary *dict;
        BOOL is_user_login = [defaults_object(P_IS_USER_LOGIN) boolValue];
        if(is_user_login){
            dict=@{P_USER_LAT:isEmpty(@(preLocation.coordinate.latitude)),
                   P_USER_LNG:isEmpty(@(preLocation.coordinate.longitude)),
                   P_USER_ID:driverID,
//                   @"u_degree":isEmpty(@(self.driverDegree)),
            };
            [GIC mkwu:UPDATE_USER_PROFILE
                    d:dict
                  isa:NO
                   cb:^(id results, NSError *error) {
                if ([[[results objectForKey:P_STATUS]  uppercaseString]isEqualToString:@"OK"]) {
                    self->secondCount=0;
                }
            }];
        }else{
            NSDictionary *dictLoggedDriver = [[NSUserDefaults standardUserDefaults]objectForKey:P_USER_DICT];
            dict=@{P_DRIVER_LAT:isEmpty(@(preLocation.coordinate.latitude)),
                   P_DRIVER_LNG:isEmpty(@(preLocation.coordinate.longitude)),
                   P_DRIVER_ID:isEmpty([dictLoggedDriver objectForKey:P_DRIVER_ID]),
                   @"d_degree":isEmpty(@(self.driverDegree)),
                   @"usr_ref_id":isEmpty(driverID)
            };
            [GIC mkwu:UPDATE_DRIVER_PROFILE
                    d:dict
                  isa:NO
                   cb:^(id results, NSError *error) {
                if ([[[results objectForKey:P_STATUS]  uppercaseString]isEqualToString:@"OK"]) {
                    self->secondCount=0;
                }
            }];
        }
    }
}


-(void) updateLocationWhenLogin{
    NSDictionary *dict1 = [[NSUserDefaults standardUserDefaults]objectForKey:P_USER_DICT_LOGGED];
    NSString *driverID = isEmpty([dict1 objectForKey:P_USER_ID]);
    NSDictionary *dict;
    if([Utilities isValidLocation:[APP_DELEGATE currLoc].coordinate])  {
        CLLocation * cLocation=[[CLLocation alloc]  initWithLatitude:[APP_DELEGATE currLoc].coordinate.latitude longitude:[APP_DELEGATE currLoc].coordinate.longitude];
        BOOL is_user_login = [defaults_object(P_IS_USER_LOGIN) boolValue];
        if(is_user_login){
            dict=@{P_USER_LAT:isEmpty(@(cLocation.coordinate.latitude)),
                   P_USER_LNG:isEmpty(@(cLocation.coordinate.longitude)),
                   //               @"u_degree":isEmpty(@(self.driverDegree)),
//                   P_DRIVER_DEGREE: isEmpty(@([APP_DELEGATE driver_angle])),
                   P_USER_ID:driverID};
            [GIC mkwu:UPDATE_USER_PROFILE
                    d:dict
                  isa:NO
                   cb:^(id results, NSError *error) {
                if ([[[results objectForKey:P_STATUS]  uppercaseString]isEqualToString:@"OK"]) {
                }
            }];
        }else{
            NSDictionary *dictLoggedDriver = [[NSUserDefaults standardUserDefaults]objectForKey:P_USER_DICT];
            dict=@{P_DRIVER_LAT:isEmpty(@(cLocation.coordinate.latitude)),
                   P_DRIVER_LNG:isEmpty(@(cLocation.coordinate.longitude)),
                   P_DRIVER_DEGREE:isEmpty(@(self.driverDegree)),
                   @"usr_ref_id":isEmpty(driverID),
                   P_DRIVER_ID:[dictLoggedDriver objectForKey:P_DRIVER_ID]};
            
            [GIC mkwu:UPDATE_DRIVER_PROFILE
                    d:dict
                  isa:NO
                   cb:^(id results, NSError *error) {
                if ([[[results objectForKey:P_STATUS]  uppercaseString]isEqualToString:@"OK"]) {
                }
            }];
        }
    }
}





-(void) updateDriverAvailablity:(NSString *)available{
    NSDictionary *dict1 = [[NSUserDefaults standardUserDefaults]objectForKey:P_USER_DICT];
    NSString *driverID = isEmpty([dict1 objectForKey:P_DRIVER_ID]);
    NSDictionary *dict;
    dict=@{
        P_DRIVER_AVAILAILITY:isEmpty(available), P_DRIVER_ID:driverID
    };
    [GIC mkwu:UPDATE_DRIVER_PROFILE    d:dict     isa:NO     cb:^(id results, NSError *error) {
        if ([[[results objectForKey:P_STATUS] uppercaseString] isEqualToString:@"OK"]) {
            NSObject * dictResponse=[results objectForKey:P_RESPONSE];
            NSDictionary * dictUser;
            if([dictResponse isKindOfClass:[NSDictionary class ]]) {
                dictUser= (NSDictionary *)dictResponse;
            }else{
                dictUser = [((NSArray *)dictResponse) objectAtIndex:0];
            }
            defaults_set_object(P_USER_DICT, dictUser);
            [[NSNotificationCenter defaultCenter] postNotificationName:@"change_switch_home" object:nil];
        }
    }];
}


-(void) updateDriverAvailablity:(NSString *)available completionBlock:(void (^)(id results, NSError *error))block{
    NSDictionary *dict1 = [[NSUserDefaults standardUserDefaults]objectForKey:P_USER_DICT];
    
    NSString *driverID = isEmpty([dict1 objectForKey:P_DRIVER_ID]);
    NSDictionary *dict;
    dict=@{
        P_DRIVER_AVAILAILITY:isEmpty(available), P_DRIVER_ID:driverID};
    [GIC mkwu:UPDATE_DRIVER_PROFILE
                  d:dict
      isa:YES
           cb:^(id results, NSError *error) {
        if ([[[results objectForKey:P_STATUS]  uppercaseString]isEqualToString:@"OK"]) {
            defaults_set_object(P_USER_DICT, [results objectForKey:P_RESPONSE]);
        }
        block(results,error);
    }];
}

-(void) updateDriverActivityLogAvailablity:(NSString *)available type:(NSString * )type completionBlock:(void (^)(id results, NSError *error))block{
    NSDictionary *dict=@{
         P_DRIVER_AVAILAILITY:available,
         @"type":type,
     };
    [GIC mkwu:UPDATE_DRIVER_ACTIVITY
                  d:dict
      isa:YES
           cb:^(id results, NSError *error) {
        if ([[[results objectForKey:P_STATUS]  uppercaseString]isEqualToString:@"OK"]) {
            defaults_set_object(P_USER_DICT, [results objectForKey:P_RESPONSE]);;
        }
        block(results,error);
    }];
}


-(void)getLocation:(CLLocation *)locations withcompletionHandler : (void(^)(NSArray *arr))completionHandler{
    
    
    
    CLGeocoder *geocoder = [CLGeocoder new];
    [geocoder reverseGeocodeLocation:locations completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks,
                                                                   NSError * _Nullable error) {
        
        completionHandler(placemarks);
        
    }];
    
}


- (float)calculateDistanceInMilesFrom:(CLLocation *)currentLocation
                                   to:(CLLocation *)destinationLocation {
    
    float distanceCovered =
    [currentLocation distanceFromLocation:destinationLocation];
    
    return distanceCovered;
}
-(void) stopUpdateCurrentLocation
{
    NSString * tripID=defaults_object(TRIP_ID);
    if(tripID!=nil&&[tripID intValue]>0)  {
    }
    if([aTimer isValid])
    {
        [aTimer  invalidate];
        aTimer=nil;
    }
    preLocation=nil;
}
@end
