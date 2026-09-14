//
//  SuggestedLocationCell.m
//  Conrra
//

#import "SuggestedLocationCell.h"

@implementation SuggestedLocationCell

- (void)awakeFromNib {
    [super awakeFromNib];

    self.backgroundColor = [UIColor whiteColor];
    self.selectionStyle  = UITableViewCellSelectionStyleNone;

    self.imageLocationIcon.hidden = YES;

    self.lbLocation.font      = [UIFont fontWithName:@"NotoSans-Regular" size:14]
                                ?: [UIFont systemFontOfSize:14];
    self.lbLocation.textColor = [UIColor colorWithRed:0.157f green:0.157f blue:0.157f alpha:1.0f];
    self.lbLocation.numberOfLines = 2;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
