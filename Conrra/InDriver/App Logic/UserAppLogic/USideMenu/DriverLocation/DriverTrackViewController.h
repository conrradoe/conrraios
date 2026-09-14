//
//  PickupDetailViewController.h
//  Damrei_Driver
//
//  Created by Grepix - Baij on 25/01/19.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "DriverModel.h"
#import "WebCallConstants.h"
#import <GIKit/GIKit.h>
#import "WebCallConstants.h"

NS_ASSUME_NONNULL_BEGIN

@interface DriverTrackViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *lbTitle;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (assign, nonatomic) BOOL isPickup;
@property (assign, nonatomic) BOOL isDrop;
@property (weak, nonatomic) IBOutlet UIView *viewTrackingMessage;
@property (weak, nonatomic) IBOutlet UIButton *butBookingDetails;
@property (strong, nonatomic)  DriverModel *driverModel;
@property(nonatomic, retain) CLLocationManager *locationManager;
@end

NS_ASSUME_NONNULL_END
