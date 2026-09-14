//
//  UpdateUserCurrentLocation.h
//  TeamJoe
//
//  Created by Appicial Taxi App Solutions on 24/05/16.
//  Copyright © 2016 ZappDesignTemplates. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Utilities.h"
@interface UpdateUserCurrentLocation : NSObject
@property(assign,nonatomic ) float driverDegree;
+ (UpdateUserCurrentLocation *)sharedInstance ;

-(void) startUpdateCurrentLocation;
-(void) stopUpdateCurrentLocation;
-(void)updateLocationWhenLogin;
-(void) updateDriverAvailablity:(NSString *)available;
-(void) updateDriverAvailablity:(NSString *)available completionBlock:(void (^)(id results, NSError *error))block;
-(void) updateDriverActivityLogAvailablity:(NSString *)available type:(NSString * )type completionBlock:(void (^)(id results, NSError *error))block;
@end
