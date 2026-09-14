//
//  CategoryCell.m
//  DemoMap
//
//  Created by Devineer on 19/01/18.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import "CategoryCell.h"

@implementation CategoryCell

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(instancetype)initFromNib{
    return [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self.class) owner:nil options:nil] firstObject];
}
- (IBAction)onFareInoButtonTaped:(id)sender {
    [self.deleate onFareInfoButtonTaped:self];
}

@end
