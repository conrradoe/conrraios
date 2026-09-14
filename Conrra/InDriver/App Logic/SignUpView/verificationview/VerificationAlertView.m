//
//  NetworkLocationAlertView.m
//  HireMe Rider
//
//  Created by Grepix - Baij on 04/02/20.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import "VerificationAlertView.h"
#import "LanguageHelper.h"
@implementation VerificationAlertView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void)awakeFromNib{
    [super awakeFromNib];
    UIImage * ima=[self.imageUnVerified.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.imageUnVerified.tintColor=[UIColor colorNamed:@"app_theame"];
    self.imageUnVerified.image=ima;
    self.lblAlert.text=[LanguageHelper getStringWithKey:@"k_1_s5_unverified_driver" defaultValue:@"You are not verified"];
    self.lblMessage.text=[LanguageHelper getStringWithKey:@"k_1_s5_due_to_reason" defaultValue:@"Slow or no internet connection. Please check your internet settings."];
    [self.btnUploadDoc setTitle:[LanguageHelper getStringWithKey:@"k_1_s5_doc_upload" defaultValue:@"Upload Documents"] forState:UIControlStateNormal];
    [self.btnSetting setTitle:[LanguageHelper getStringWithKey:@"k_11_s4_a1_contact_us" defaultValue:@"Contact Us"] forState:UIControlStateNormal];
    [self.btnBackToRider setTitle:[LanguageHelper getStringWithKey:@"k_1_s5_back_to_rider" defaultValue:@"Back To Rider"] forState:UIControlStateNormal];
     
    NSString *htmlString=[LanguageHelper getStringWithKey:@"k_1_s5_driver_verification"];
    NSAttributedString * attrStr = [[NSAttributedString alloc] initWithData:[htmlString dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
    [ self.txtUnVerified addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapOnLabel:)]];
    self.txtUnVerified.attributedText = attrStr;
    self.txtUnVerified.font=FONTS_THEME_REGULAR_NO_SCALE(15);
    self.txtUnVerified.textColor = [UIColor colorNamed:@"color_app_label"];
}





- (IBAction)onSettingButtonTap:(id)sender {
    [self.delegate openMailComposer];
//    if (&UIApplicationOpenSettingsURLString != NULL) {
//    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@""]];
//    }
}



+(VerificationAlertView *) showView:(UIView *)view
{
    VerificationAlertView *  _verificationAlertView=[[[NSBundle mainBundle] loadNibNamed:@"VerificationAlertView" owner:self options:nil] firstObject];
    CGRect rect=[UIScreen mainScreen].bounds;
    _verificationAlertView.frame=CGRectMake(0, 0, rect.size.width, rect.size.height);
    [view addSubview:_verificationAlertView];
    return _verificationAlertView;
}


- (IBAction)onRefreshButtonTap:(id)sender {
    
    NSDictionary *dictUser = [[NSUserDefaults standardUserDefaults]objectForKey:P_USER_DICT];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{
        P_API_KEY :[dictUser objectForKey:P_API_KEY],
        
    }];
    
    
    [UtilityClass setLH:NO wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
    
    [GIC mkwu:GET_DRIVER_PROFILE
                  d:dict
      isa:NO
           cb:^(id results, NSError *error) {
        [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
        if ([[results objectForKey:P_STATUS] isEqualToString:@"OK"]) {
            // success
            NSObject * dictResponse=[results objectForKey:P_RESPONSE];
            NSDictionary * dictUser;
            if([dictResponse isKindOfClass:[NSDictionary class ]]) {
                dictUser= (NSDictionary *)dictResponse;
            }else{
                dictUser = [((NSArray *)dictResponse) objectAtIndex:0];
            }
            BOOL isVerified=[[dictUser objectForKey:P_DRIVER_VERIFIED] boolValue];
            [[NSUserDefaults standardUserDefaults]setObject:dictUser  forKey:P_USER_DICT];
            [[NSUserDefaults standardUserDefaults]synchronize];
            if(isVerified)
            {
                [self removeFromSuperview];
                [self.delegate onRefreshDriverVerified];
              
            }
        }
    }];
    
}


- (IBAction)onUpdateDocumentButtonTap:(id)sender {
    
    [self.delegate openUpdateDocument];
}
- (IBAction)onBackToRiderButtonTap:(id)sender {
    [self.delegate backToRider];
}



- (void)handleTapOnLabel:(UITapGestureRecognizer *)gesture
{
    UITextView *textView = (UITextView *)gesture.view;
    //    int tag = (int)[textView tag];
    NSLayoutManager *layoutManager = textView.layoutManager;
    CGPoint location = [gesture locationInView:textView];
    location.x -= textView.textContainerInset.left;
    location.y -= textView.textContainerInset.top;
    NSUInteger characterIndex;
    characterIndex = [layoutManager characterIndexForPoint:location
                                           inTextContainer:textView.textContainer
                  fractionOfDistanceBetweenInsertionPoints:NULL];
    
    if (characterIndex < textView.textStorage.length) {
        
        NSRange range;
        NSDictionary *attributes =
        [textView.textStorage attributesAtIndex:characterIndex
                                 effectiveRange:&range];
        if ([attributes objectForKey:@"NSLink"]) {
           
            NSString * pURL=[NSString stringWithFormat:@"%@",[attributes objectForKey:@"NSLink"]];
  

            if( [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:pURL]]){
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:pURL] options:@{} completionHandler:nil];
        }
//            NSURL *URL = [NSURL URLWithString:url];
            
        }
    }
}


@end
