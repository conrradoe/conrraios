//
//  PaymentTableViewCell.h
//  Golden Moto
//
//  Created by Grepix - Baij on 10/12/19.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PaymentTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lbCard;
@property (weak, nonatomic) IBOutlet UILabel *lbCardType;
@property (weak, nonatomic) IBOutlet UIImageView *lbRadio;

@property (weak, nonatomic) IBOutlet UILabel *lbExpiry;
@end

NS_ASSUME_NONNULL_END
