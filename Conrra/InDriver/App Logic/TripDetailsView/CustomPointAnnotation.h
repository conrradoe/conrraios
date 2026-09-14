//
//  CustomPointAnnotation.h
//  HIREME_RIDER
//
//  Created by Appicial Taxi App Solutions on 20/06/17.
//  Copyright © 2023 Appicial. All rights reserved.
//

#import <MapKit/MapKit.h>
#define PIN_START @"start"
#define PIN_DROP @"drop"
#define PIN_MARKER @"marker"
#define PIN_USER @"user-pin"
#define PIN_USER_LOCATION @"user-location-pin"
@interface CustomPointAnnotation : MKPointAnnotation
@property(strong, nonatomic) NSString *type;
@property(strong, nonatomic) NSString *iconPath;
-(instancetype) initWithType:(NSString * ) type;
@property (nonatomic) float degree;

@end
