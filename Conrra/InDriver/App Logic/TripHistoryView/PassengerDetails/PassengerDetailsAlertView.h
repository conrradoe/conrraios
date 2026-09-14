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

@interface PassengerDetailsAlertView : UIView
@property (weak, nonatomic) IBOutlet UILabel *lblAlert;
@property (weak, nonatomic) IBOutlet UILabel *lblPassengerNameText;
@property (weak, nonatomic) IBOutlet UILabel *lblPassengerPhoneText;
@property (weak, nonatomic) IBOutlet UILabel *lblPassengerName;
@property (weak, nonatomic) IBOutlet UILabel *lblPassengerPhone;
@property (strong ,nonatomic)NSString * jsonString;

+(void)showPessangeDetails:(UIView *) view withData:(NSString * )jsonString;
@end

NS_ASSUME_NONNULL_END
