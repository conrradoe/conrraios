//
//  MapBearingCalculation.h

//
//  Created by Grepix - Baij on 04/10/19.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MapBearingCalculation : NSObject
-(float) getBearing:(CLLocationCoordinate2D) preLocation currentLocation:(CLLocationCoordinate2D) currentLocation;

-(BOOL) isAngleChanged:(CLLocationCoordinate2D) currentLocation;
@end

NS_ASSUME_NONNULL_END
