//
//  CustomPointAnnotation.m
//  HIREME_RIDER
//
//  Created by Appicial Taxi App Solutions on 20/06/17.
//  Copyright © 2023 Appicial. All rights reserved.
//

#import "CustomPointAnnotation.h"

@implementation CustomPointAnnotation

-(instancetype) initWithType:(NSString * ) type
{
    self = [super init];
    if (self) {
        self.type=type;
    }
    return self;
}
@end
