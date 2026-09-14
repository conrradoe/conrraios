//
//  ReceiverCell.m
//  HireMe Rider
//
//  Created by Prashant on 12/02/18.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import "ReceiverCell.h"

@implementation ReceiverCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.message.textContainerInset = UIEdgeInsetsMake(4, 4, 4, 4);
    self.messageBackground.layer.cornerRadius = 7;
    self.messageBackground.clipsToBounds = YES;
    self.backgroundColor = [UIColor clearColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
