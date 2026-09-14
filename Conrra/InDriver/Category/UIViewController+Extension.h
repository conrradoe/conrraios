//
//  UIViewController+Extension.h
//  Golden Moto
//
//  Created by Grepix - Baij on 14/02/20.
//  Copyright © 2023 Grepixit. All rights reserved.
//




#import <UIKit/UIKit.h>
#import "TripModel.h"
#import "CategoryModel.h"
#import "FareAmmountViewController.h"
#import "ConstantModel.h"
#import "AFHTTPRequestOperationManager.h"
#import "ChatViewController.h"
NS_ASSUME_NONNULL_BEGIN
@protocol UIViewControllerExtensionDelegate <NSObject>

-(void)goToFareSummeryScreenWhenTripCancelByRider:(TripModel *)tripModel;
@end
@interface UIViewController (Extension)
-(float) getDriverCommissionForTrip:(TripModel *)tripeModel;

//-(void) showAlert:(NSString *)messgae title:(NSString *) title;

-(void) cancelTripBeforeBeginTrip:(TripModel *) tripModel completionBlock:(void (^)(id results, NSError *error))block isShowLoader:(BOOL)isShowLoader isSendNotification:(BOOL)isSendNotification withDelegate:(id<UIViewControllerExtensionDelegate>)delegate isFromBeginTrip:(BOOL)isFromBeginTrip;


//-(BOOL) isCanShowAirportInstrauctionInTrip:(TripModel*)tripModel;
-(void)getRiderCancelTripsWithDelegate:(id<UIViewControllerExtensionDelegate>)delegate;
//-(void)showAirPortInstructionForTrip:(TripModel*)tripModel;

- (void)makeCallToNumber:(TripModel *)tripModel;

-(void)sendCancelTripNotification:(TripModel *) tripModel;
@end

NS_ASSUME_NONNULL_END
