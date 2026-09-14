//
//  NetworkLocationAlertView.h
//  HireMe Rider
//
//  Created by Grepix - Baij on 04/02/20.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageView+WebCache.h"
NS_ASSUME_NONNULL_BEGIN

@interface NetworkLocationAlertView : UIView
@property (weak, nonatomic) IBOutlet UILabel *lblAlert;
@property (weak, nonatomic) IBOutlet UILabel *lblMessage;
@property (weak, nonatomic) IBOutlet UIButton *btnSetting;
@property (weak, nonatomic) IBOutlet UIImageView *imageInternet;

@end

NS_ASSUME_NONNULL_END
