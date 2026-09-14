//
//  CountryViewCell.h
//  NuBai
//
//  Created by Grepix - Baij on 30/12/19.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CountryViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lbCountryName;
@property (weak, nonatomic) IBOutlet UILabel *lblCode;
@property (weak, nonatomic) IBOutlet UIImageView *imCountryImage;
@end

NS_ASSUME_NONNULL_END
