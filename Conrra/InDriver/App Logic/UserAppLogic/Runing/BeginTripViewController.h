;//
//  BeginTripViewController.h
//  HIREME_RIDER
//
//  Created by Appicial Taxi App Soutions on 15/06/17.
//  Copyright © 2023 Appicial Taxi App Soutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "TripModel.h"
#import "ConstantModel.h"
#import "LanguageHelper.h"
#import "UIViewController+Location.h"
#import "UIViewController+Extension.h"
#import "MIBadgeButton.h"
#import "BaseViewController.h"
#import "UIImage+GIF.h"
@interface BeginTripViewController : BaseViewController<MKMapViewDelegate,CLLocationManagerDelegate,UIGestureRecognizerDelegate,UIViewControllerExtensionDelegate>
@property(nonatomic, retain) CLLocationManager *locationManager;

//chat
@property (nonatomic, strong) NSDictionary *dictEstimate;

- (IBAction)onMyLocationButtonTap:(id)sender;

@property (nonatomic, assign) BOOL isFromrequest;
@property(strong,nonatomic) TripModel * currentTrip;
@property(strong,nonatomic) ConstantModel * constantModel;

-(void)stopLocationUpdate;
@end
