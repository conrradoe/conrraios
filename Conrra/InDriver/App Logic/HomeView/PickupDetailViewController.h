//
//  PickupDetailViewController.h
//  Damrei_Driver
//
//  Created by Grepix - Baij on 25/01/19.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "TripModel.h"
#import "LanguageHelper.h"

NS_ASSUME_NONNULL_BEGIN

@interface PickupDetailViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *lbTitle;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (assign, nonatomic) BOOL isPickup;
@property (assign, nonatomic) BOOL isDrop;
@property (strong, nonatomic)  TripModel *tripModel;
@end

NS_ASSUME_NONNULL_END
