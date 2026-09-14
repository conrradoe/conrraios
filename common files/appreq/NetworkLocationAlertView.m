//
//  NetworkLocationAlertView.m
//  HireMe Rider
//
//  Created by Grepix - Baij on 04/02/20.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import "NetworkLocationAlertView.h"
#import "LanguageHelper.h"
@implementation NetworkLocationAlertView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void)awakeFromNib{
    [super awakeFromNib];
    self.lblAlert.text=[LanguageHelper getStringWithKey:@"k_com_s18_Ooops" defaultValue:@"Ooops!"];
    self.lblMessage.text=[LanguageHelper getStringWithKey:@"k_com_s18_setting_internet_msg" defaultValue:@"Slow or no internet connection. Please check your internet settings."];
    [self.btnSetting setTitle:[LanguageHelper getStringWithKey:@"k_com_s18_check_setting" defaultValue:@"Check Settings"] forState:UIControlStateNormal];
    [self.imageInternet sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",url_base_app_images,@"no-network.jpg"]] placeholderImage:[UIImage imageNamed:@"image_no-network.jpg"]];
}


- (IBAction)onSettingButtonTap:(id)sender {
//    if (&UIApplicationOpenSettingsURLString != NULL) {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil] ;
//    }
}



@end
