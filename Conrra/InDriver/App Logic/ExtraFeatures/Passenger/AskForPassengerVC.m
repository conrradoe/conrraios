////
//  HomeViewController.m
//  Store_project
//
//  Created by Appicial Taxi App Soutions on 22/05/17.
//  Copyright © 2023 Appicial Taxi App Soutions. All rights reserved.
//

#import "AskForPassengerVC.h"
#import "UIView+UpdateAutoLayoutConstraints.h"
#import "ConstantModel.h"
@interface AskForPassengerVC ()<UITextFieldDelegate>
{
    ConstantModel * constantTaxiModel;
}


@end

@implementation AskForPassengerVC

- (void)viewDidLoad {
    [super viewDidLoad];
    constantTaxiModel=[ConstantModel getConstantsObject];
    [self setUIFiels];
    [self setupTextFieldPassenger:self.txtPassengeName];
    [self setupTextFieldPassenger:self.txtPassengePhone];
    self.txtPassengePhone.delegate=self;
    [self setupNewDesign];
}

-(void)setupNewDesign {
    UIColor *yellow = [UIColor colorNamed:@"app_theame"]
                      ?: [UIColor colorWithRed:235/255.0 green:181/255.0 blue:24/255.0 alpha:1];
    UIColor *darkText = [UIColor colorNamed:@"color_app_label"] ?: [UIColor colorWithWhite:0.15 alpha:1];

    // Dim the background overlay
    UIView *overlay = self.view.subviews.firstObject;
    if (overlay && ![overlay isKindOfClass:[UITextField class]] && ![overlay isKindOfClass:[UILabel class]]) {
        overlay.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    }

    // Find the card container (superview of the Yes button)
    UIView *card = self.btnPassengeDetailsSkip.superview;
    if (card) {
        card.backgroundColor = UIColor.whiteColor;
        card.layer.cornerRadius = 20;
        card.layer.masksToBounds = NO;
        card.layer.shadowColor = UIColor.blackColor.CGColor;
        card.layer.shadowOpacity = 0.15;
        card.layer.shadowOffset = CGSizeMake(0, 4);
        card.layer.shadowRadius = 12;
        card.clipsToBounds = NO;
    }

    // Message label
    self.lblTextMsg.font = [UIFont fontWithName:@"NotoSans-Regular" size:15]
                           ?: [UIFont systemFontOfSize:15];
    self.lblTextMsg.textColor = darkText;
    self.lblTextMsg.textAlignment = NSTextAlignmentCenter;
    self.lblTextMsg.numberOfLines = 0;

    // Passenger details label (title)
    self.lblPassengerDetails.font = [UIFont fontWithName:@"NotoSans-Bold" size:17]
                                    ?: [UIFont boldSystemFontOfSize:17];
    self.lblPassengerDetails.textColor = darkText;
    self.lblPassengerDetails.textAlignment = NSTextAlignmentCenter;

    // Style text fields
    UIColor *fieldBg = [UIColor colorWithWhite:0.96 alpha:1];
    NSMutableArray *_tfList = [NSMutableArray array];
    if (self.txtPassengeName) [_tfList addObject:self.txtPassengeName];
    if (self.txtPassengePhone) [_tfList addObject:self.txtPassengePhone];
    for (UITextField *tf in _tfList) {
        tf.backgroundColor = fieldBg;
        tf.layer.cornerRadius = 10;
        tf.layer.masksToBounds = YES;
        tf.borderStyle = UITextBorderStyleNone;
        tf.font = [UIFont fontWithName:@"NotoSans-Regular" size:15] ?: [UIFont systemFontOfSize:15];
        tf.textColor = darkText;
        // Left padding
        UIView *pad = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 12, 1)];
        tf.leftView = pad;
        tf.leftViewMode = UITextFieldViewModeAlways;
    }

    // Yes button — primary yellow
    self.btnPassengeDetailsSkip.backgroundColor = yellow;
    self.btnPassengeDetailsSkip.layer.cornerRadius = 12;
    self.btnPassengeDetailsSkip.layer.masksToBounds = YES;
    self.btnPassengeDetailsSkip.titleLabel.font = [UIFont fontWithName:@"NotoSans-Bold" size:15]
                                                  ?: [UIFont boldSystemFontOfSize:15];
    [self.btnPassengeDetailsSkip setTitleColor:UIColor.blackColor forState:UIControlStateNormal];

    // No button — gray secondary
    self.btnPassengeDetailsSave.backgroundColor = [UIColor colorWithWhite:0.91 alpha:1];
    self.btnPassengeDetailsSave.layer.cornerRadius = 12;
    self.btnPassengeDetailsSave.layer.masksToBounds = YES;
    self.btnPassengeDetailsSave.titleLabel.font = [UIFont fontWithName:@"NotoSans-Regular" size:15]
                                                  ?: [UIFont systemFontOfSize:15];
    [self.btnPassengeDetailsSave setTitleColor:darkText forState:UIControlStateNormal];
}
 

-(void)setupTextFieldPassenger:(UITextField*)textField{
    textField.delegate=self;
    [self setTextFieldPlaceholderColor:textField];
}



-(void) setUIFiels{
    //    UIAlertController * alertViewController=[UIAlertController alertControllerWithTitle:@"" message:[LanguageHelper getStringWithKey:@"k_6_s12_ride_booking_msg"] preferredStyle:UIAlertControllerStyleAlert];
    //
    //    [alertViewController addAction:[UIAlertAction actionWithTitle:[LanguageHelper getStringWithKey:@"k_21_s4_yes"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    //        [self openPassengerDetailInputVc:tripdate isRiderLater:YES];
    //    }]];
    //    [alertViewController addAction:[UIAlertAction actionWithTitle:[LanguageHelper getStringWithKey:@"k_22_s4_no"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    //        [self createTripWith:tripdate passengerDetail:nil];
    //    }]];
    //    [self.navigationController presentViewController:alertViewController animated:YES completion:^{
    //
    //    }];
    self.lblTextMsg.text=[LanguageHelper getStringWithKey:@"k_6_s12_ride_booking_msg"];
    self.txtPassengePhone.placeholder=[LanguageHelper getStringWithKey:@"k_s3_passenger_phone"];
    self.txtPassengeName.placeholder=[LanguageHelper getStringWithKey:@"k_s3_passenger_name"];
    [self.btnPassengeDetailsSave setTitle: [LanguageHelper getStringWithKey:@"k_22_s4_no"]   forState:UIControlStateNormal];
    [self.btnPassengeDetailsSkip setTitle: [LanguageHelper getStringWithKey:@"k_21_s4_yes"]   forState:UIControlStateNormal];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self setUIFiels];
    [self checkAndShowAlertWith];
}






#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
}


#pragma -mark UITextField delegate method


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
  
    if (textField ==self.txtPassengePhone && textField.text.length >= constantTaxiModel.max_phone_length && range.length == 0) {
        return NO; // return NO to not change text
    }
    else  {
        return YES;
        
    }
}







-(NSString *) pessagerDetailJson{
    NSDictionary * dictPassenger=@{@"p_name":self.txtPassengeName.text,@"p_phone":self.txtPassengePhone.text};
    NSString * passengerDetail=@"";
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictPassenger
                                                       options:0
                                                         error:&error];
    
    if (! jsonData) {
        NSLog(@"%s: error: %@", __func__, error.localizedDescription);
        //                @"[]";
    } else {
        passengerDetail= [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    
    return passengerDetail;
}







- (IBAction)onPassengerDetailsCloseButtonTap:(id)sender {
    [self.view endEditing:YES];
    [self.delegate controller:self  isYes:YES];
}

- (IBAction)onPassengeDetailsSaveButtonTap:(id)sender {
    [self.delegate controller:self isYes:NO];
}



- (IBAction)onCloseButtonTap:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end

