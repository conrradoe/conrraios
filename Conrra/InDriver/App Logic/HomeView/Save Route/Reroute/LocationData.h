//
//  LocationData.h
//  LTS Driver
//
//  Created by Grepix on 15/03/21.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
NS_ASSUME_NONNULL_BEGIN

@interface LocationData : NSObject
@property(assign,nonatomic) int index;
@property(assign,nonatomic) BOOL isValid;
@property(strong,nonatomic) CLLocation * location;
@end

NS_ASSUME_NONNULL_END
