//
//  NIDropDownCell.h
//  Rocab Rider
//
//  Created by Grepix - Baij on 14/10/19.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NIDropDownCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lbCountryCode;
@property (weak, nonatomic) IBOutlet UILabel *lbCountryName;

@end

NS_ASSUME_NONNULL_END
