//
//  RoundShapeBg.h
//  HireMe Rider
//
//  Created by Grepix - Baij on 02/04/19.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "TripModel.h"
#import "LanguageHelper.h"

NS_ASSUME_NONNULL_BEGIN

@interface RoundShapeBg : NSObject

@property(nonatomic ,assign) int pading;
@property(nonatomic ,assign) int txtWidth;
-(void)makeRound:(UIView *)view tripModel:( TripModel *)tripModel heightView:(int)heightView bottomTop:(int)bottomTop;
@end

NS_ASSUME_NONNULL_END
