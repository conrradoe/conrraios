//
//  RatingViewController.h
//  TaxiDriver
//
//  Created by  Appicial on 24/05/17.
//  Copyright © 2023 Appicial. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LanguageHelper.h"

@interface RatingViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIView *viewHeader;
@property (strong, nonatomic) IBOutlet UILabel *lblHeader;
@property (strong, nonatomic) IBOutlet UIView *viewtemp;
@property (weak, nonatomic) IBOutlet UIButton *btnBack;
@property (weak, nonatomic) IBOutlet UIImageView *ratingView;

@end
