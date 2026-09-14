//
//  HandleAlertViewController.h
//  HireMe Rider
//
//  Created by Grepix - Baij on 05/02/20.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "UIImageView+WebCache.h"
NS_ASSUME_NONNULL_BEGIN

@interface HandleAlertViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *lblAlert;
@property (weak, nonatomic) IBOutlet UILabel *lblMessage;
@property (weak, nonatomic) IBOutlet UIButton *btnTitle;
@property (weak, nonatomic) IBOutlet UIButton *btnBack;
@property(nonatomic, retain) CLLocationManager *locationManager;
@end

NS_ASSUME_NONNULL_END
