//
//  LanguageCell.m
//  JS Rider
//
//  Created by Devineer on 25/06/18.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import "ReferralCell.h"

@implementation ReferralCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self.imageDriver.layer setCornerRadius:22];
    self.lblActivityLoader.hidden=YES;
}

-(void)prepareForReuse
{
    [super prepareForReuse];
    self.lblDriverName.hidden=NO;
    self.imageDriver.hidden=NO;
    self.lblLanguage.hidden=NO;
    self.viewStatusBg.hidden=NO;
    self.lblMessage.hidden=NO;
    self.lblActivityLoader.hidden=YES;
    [self.lblActivityLoader stopAnimating];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
