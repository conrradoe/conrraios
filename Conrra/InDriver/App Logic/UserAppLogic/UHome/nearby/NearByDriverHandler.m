//
//  NearByDriverHandler.m
//  HIREME_RIDER
//
//  Created by Appicial Taxi App Soutions on 14/06/17.
//  Copyright © 2023 Appicial Taxi App Soutions. All rights reserved.
//
#import <GIKit/GIKit.h>
#import "NearByDriverHandler.h"
#import "AppDelegate.h"
#import "WebCallConstants.h"
#import "ConstantModel.h"
#import "AFHTTPRequestOperationManager.h"
#import <Conrra-Swift.h>
@implementation NearByDriverHandler
{
    
    NSTimer *nearbyTimer;
    BOOL isStoped;
    BOOL isDeAlloc;
    BOOL isCalling;
    BOOL isCallingFake;
    GIKCommon *callapi;
    CLLocation * lastLocationForGetFake;
}

-(instancetype)init{
    self=[super init];
    self.categoryId = @"1";
    self.carCount = [ConstantModel getConstantsObject].dummy_driver_count;
    isStoped=NO;
    return  self;
}


-(void) startGettingNearByDriver{
    isStoped=NO;
    lastLocationForGetFake = nil;
    [self getNearByDrivers];
}


-(void)getNearByDrivers{
    [self   getNearByDriverIdWithCompletion:^(id results, NSError *error ) {
        if(error==nil) {
            if(self.delegate) {
                [self.delegate onRefreshNearByDriver:results];
            }
        }else{
            if(self.delegate) {
                [self.delegate onRefreshNearByDriver:[[NSMutableArray alloc] init]];
            }
        }
        if(!self->isStoped){
            [self setNewTimer];
        }
    }];
}


-(void) stopGetNearByDriver
{
    isStoped=YES;
    if(nearbyTimer)
    {
        [nearbyTimer  invalidate];
        nearbyTimer=nil;
    }
    
    if (callapi) {
        [callapi cr];
        callapi = nil;
    }
}

-(void) changePickUpLocation :(CLLocation *) picklocation
{
    isCalling=NO;
    self.pickUpLocation=picklocation;
    [self stopGetNearByDriver];
    [self startGettingNearByDriver];
}

-(void) changeCategoryId :(int) categoryId city_id:(NSString *)city_id
{
    isCalling=NO;
    self.categoryId= [NSString stringWithFormat:@"%d", categoryId];
    self.city_id=city_id;
    [self stopGetNearByDriver];
    [self startGettingNearByDriver];
}


-(void)  getNearByDriverIdWithCompletion:(void (^)(id results, NSError *error  )) block
{
    AppDelegate *appdelegate=APP_DELEGATE;
    ConstantModel *constantModel =[ConstantModel getConstantsObject];
    NSMutableDictionary *  dict =[[NSMutableDictionary alloc]init] ;
    NSDictionary *dict1 = [[NSUserDefaults standardUserDefaults]objectForKey:P_USER_DICT];
    if(dict1==nil){
        NSError *error=[[NSError alloc] init];
        block(nil,error);
        [self stopGetNearByDriver];
        return;
    }
    if([[dict1 objectForKey:P_USER_ID] intValue]==0){
        NSError *error=[[NSError alloc] init];
        block(nil,error);
        [self stopGetNearByDriver];
        return;
    }
    if(self.pickUpLocation)   {
       
        dict = [NSMutableDictionary dictionaryWithDictionary:@{
            P_USER_ID            :[dict1 objectForKey:P_USER_ID],
            P_LAT                : [NSString stringWithFormat:@"%f",self.pickUpLocation.coordinate.latitude],
            P_LNG                : [NSString stringWithFormat:@"%f",self.pickUpLocation.coordinate.longitude],
            P_CATEGORY_ID        :_categoryId,
        }];
    }
    else{
        dict = [NSMutableDictionary dictionaryWithDictionary:@{
            
            P_USER_ID            :[dict1 objectForKey:P_USER_ID],
            P_LAT                : [NSString stringWithFormat:@"%f",appdelegate.currLoc.coordinate.latitude],
            P_LNG                : [NSString stringWithFormat:@"%f",appdelegate.currLoc.coordinate.longitude],
            P_CATEGORY_ID        : _categoryId,
        }];
    }
    
    if (constantModel.constant_driver_radius == 0.0) {
        [dict setObject:@"4" forKey:@"miles"];
    }
    else{
        [dict setObject:[NSString stringWithFormat:@"%.1f",constantModel.constant_driver_radius] forKey:@"miles"];
    }
    
    callapi = [[GIKCommon alloc] init];
    if(self.delegate)
    {
        [self.delegate onStartRefreshing];
    }
    if(isCalling){
        NSError *error=[[NSError alloc] init];
        block(nil,error);
        return;
    }
    isCalling=YES;
    CLLocation *location=[[CLLocation alloc] initWithLatitude:[[dict objectForKey:P_LAT] floatValue] longitude:[[dict objectForKey:P_LNG] floatValue]];
    ;
    if ([Utilities isValidLocation:location.coordinate]) {
        [dict setObject:isEmpty(self.city_id) forKey:P_CITY_ID];
        [callapi mkwu:GET_DRIVERS_NEARBY  d:dict   isa:NO  cb:^(id results, NSError *error) {
            self->isCalling=NO;
            if ([[[results objectForKey:P_STATUS] uppercaseString] isEqualToString:@"OK"]) {
                // success
                NSMutableArray * driversArray=[DriverModel parseDirversResponse:[results objectForKey:P_RESPONSE]];
                block(driversArray,nil);
            }
            else{
                block(nil,error);
                
            }
        }];
    }else {
        isCalling=NO;
        NSError *error=[[NSError alloc] init];
        block(nil,error);
    }
}



-(void) setNewTimer{
    if(self->nearbyTimer) {
        [self->nearbyTimer  invalidate];
        self->nearbyTimer=nil;
    }
    if(!isDeAlloc){
        dispatch_async(dispatch_get_main_queue(), ^{
        self->nearbyTimer = [NSTimer scheduledTimerWithTimeInterval: 15.0 target: self selector: @selector(getNearByDrivers) userInfo: nil repeats: NO];
            [[NSRunLoop currentRunLoop] addTimer:self->nearbyTimer forMode:NSRunLoopCommonModes];
        });
    }
}




-(void)dealloc{
    isDeAlloc=YES;
    [self stopGetNearByDriver];
}

@end
