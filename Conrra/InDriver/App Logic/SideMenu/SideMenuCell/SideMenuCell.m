//
//  SideMenuCell.m
//  Store_project
//
//  Created by  Appicial on 22/02/17.
//  Copyright © 2023 Appicial. All rights reserved.
//

#import "SideMenuCell.h"
#import "WebCallConstants.h"


@implementation SideMenuCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self.lblMenu setFont:FONTS_THEME_REGULAR(17)];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
