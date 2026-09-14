//
//  SenderCell.m
//  HireMe Rider
//
//  Created by Prashant on 12/02/18.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import "SenderCell.h"
#import <GIKit/GIKit.h>

@implementation SenderCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.message.textContainerInset = UIEdgeInsetsMake(4,4,4,4);
    self.messageBackground.layer.cornerRadius = 7 ;
    self.messageBackground.clipsToBounds = YES;
    self.backgroundColor = [UIColor clearColor];
    [UtilityClass setCornerRadius:self.profilePic radius:self.profilePic.bounds.size.height/2 borderColor:[UIColor colorNamed:@"color_app_label"]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
