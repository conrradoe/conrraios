//
//  NetworkLocationAlertView.m
//  HireMe Rider
//
//  Created by Grepix - Baij on 04/02/20.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import "PassengerDetailsAlertView.h"
#import "LanguageHelper.h"
#import "Utilities.h"
@implementation PassengerDetailsAlertView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void)awakeFromNib{
    [super awakeFromNib];
    self.lblAlert.text=[LanguageHelper getStringWithKey:@"k_s3_passenger_details" ];
    self.lblPassengerNameText.text=[LanguageHelper getStringWithKey:@"k_s3_passenger_name"];
    self.lblPassengerPhoneText.text=[LanguageHelper getStringWithKey:@"k_s3_passenger_phone"];
}


+(void)showPessangeDetails:(UIView *) view withData:(NSString * )jsonString
{
    PassengerDetailsAlertView *_networkLocationAlertView=[[[NSBundle mainBundle] loadNibNamed:@"PassengerDetailsAlertView" owner:self options:nil] firstObject];
    _networkLocationAlertView.jsonString=jsonString;
    CGRect rect=[UIScreen mainScreen].bounds;
    _networkLocationAlertView.frame=CGRectMake(0, 0, rect.size.width, rect.size.height);
    [view addSubview:_networkLocationAlertView];
    
    NSError *jsonError;
    NSData *objectData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:objectData
                                          options:NSJSONReadingMutableContainers
                                            error:&jsonError];
     if(json)
     {
         _networkLocationAlertView.lblPassengerName.text=[json objectForKey:@"p_name"];
         _networkLocationAlertView.lblPassengerPhone.text=[json objectForKey:@"p_phone"];
     }
}

- (IBAction)onCloseButtonTap:(id)sender {
    [self removeFromSuperview];
}



-(void) doSimpleNativeCall:(NSString *)phone
{
    NSString  * phoneWithCode=phone;
    NSURL *phoneUrl = [NSURL URLWithString:[@"telprompt://"stringByAppendingString:phoneWithCode]];
    NSURL *phoneFallbackUrl = [NSURL URLWithString:[@"tel://" stringByAppendingString:phoneWithCode]];
    
    
    if ([UIApplication.sharedApplication canOpenURL:phoneUrl]) {
        [[UIApplication sharedApplication] openURL:phoneUrl options:@{} completionHandler:nil];
    } else if ([UIApplication.sharedApplication canOpenURL:phoneFallbackUrl]) {
        [UIApplication.sharedApplication openURL:phoneFallbackUrl options:@{} completionHandler:nil];
    } else {
        [UtilityClass swa:nil
                               m:[LanguageHelper getStringWithKey:@"k_r33_s8_no_call_facility"]
                     cbt:@"Ok"
                      obt:nil ];
    }
}
- (IBAction)onCallButtonTap:(id)sender {
    NSDictionary * dict=[Utilities idFormJsonString:self.jsonString];
    if(dict==nil){
        return;
    }
    NSString *phoneWithCode=[dict objectForKey:@"p_phone"];
    [self doSimpleNativeCall:phoneWithCode];
}

@end
