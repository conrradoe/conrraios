//
//  LanguageViewController.h
//  JS Rider
//
//  Created by Devineer on 25/06/18.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "AboutUsViewController.h"

@interface BecomeDriverVC : BaseViewController

@property (weak, nonatomic) IBOutlet UIImageView *imgMain;
@property (weak, nonatomic) IBOutlet UIButton *btnApplyForDriver;
@property (weak, nonatomic) IBOutlet UITextView *txtMeesgae;
@property (weak, nonatomic) IBOutlet UIButton *btnBack;
@end
