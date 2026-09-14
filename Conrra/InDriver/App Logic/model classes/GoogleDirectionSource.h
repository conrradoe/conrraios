//
//  GoogleDirectionSource.h
//  HIREME_RIDER
//
//  Created by Appicial Taxi App Soutions on 12/06/17.
//  Copyright © 2023 Appicial Taxi App Soutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "DirectionModel.h"
#import "LanguageHelper.h"

@interface GoogleDirectionSource : NSObject
@property(strong,nonatomic) CLLocation * source;
@property(strong,nonatomic) CLLocation * destination;
@property(strong,nonatomic) NSString * dropAddress;
@property(strong,nonatomic) NSString * pickAddress;
@property(strong,nonatomic) NSString * pickCountry;
@property(strong,nonatomic) NSString * dropCountry;
@property(strong,nonatomic) CLLocation * northeast;
@property(strong,nonatomic) CLLocation * southwest;
@property(assign,nonatomic) BOOL  isEstimate;
-(instancetype)initWithSource:(CLLocation *) sourse destination:(CLLocation *) destination;
-( NSArray *) decodePoints:(NSString *) encoded;
-(void) findDirection_isInTrip:(BOOL)isInTrip WithCompletionBlock:(void (^)(id results, NSError *error)) block;
-(BOOL) isSourceEmpty;
-(BOOL) isDestinationEmpty;
@end
