//
//  LanguageCell.h
//  JS Rider
//
//  Created by Devineer on 25/06/18.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReferralCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *lblLanguage;
@property (weak, nonatomic) IBOutlet UILabel *lblMessage;
@property (weak, nonatomic) IBOutlet UIImageView *imageDriver;
@property (weak, nonatomic) IBOutlet UILabel *lblDriverName;
@property (weak, nonatomic) IBOutlet UIView *viewStatusBg;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *lblActivityLoader;

@end
