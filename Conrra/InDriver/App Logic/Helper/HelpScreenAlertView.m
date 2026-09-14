//
//  NetworkLocationAlertView.m

//
//  Created by Grepix - Baij on 04/02/20.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import "HelpScreenAlertView.h"
#import "LanguageHelper.h"
@implementation HelpScreenAlertView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void)awakeFromNib{
    [super awakeFromNib];
    
}


+(HelpScreenAlertView *) showHelperScreens:(UIView *)view
{
  HelpScreenAlertView  * helpScreenAlertView=[[[NSBundle mainBundle] loadNibNamed:@"HelpScreenAlertView" owner:self options:nil] firstObject];
//    CGRect rect=[UIScreen mainScreen].bounds;
    helpScreenAlertView.frame=CGRectMake(0, 0,SCREEN_WIDTH, SCREEN_HEIGHT);
    [view addSubview:helpScreenAlertView];
    return helpScreenAlertView;
}
@end
