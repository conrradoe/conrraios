//
//  TripOfferAcceptHelper.h
//  TruckPagerDriver
//
//  Created by Grepix Infotech on 28/03/22.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TripModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface TripOfferAcceptHelper : NSObject
@property(strong,nonatomic) NSObject *tripOffer;
@property(weak,nonatomic) UIViewController *viewController;
- (void)onAccetOfferWithAmountCb:(void (^)(id results, NSError *error))b;
@end

NS_ASSUME_NONNULL_END
