////
//  HomeViewController.m
//  Store_project
//
//  Created by Appicial Taxi App Soutions on 22/05/17.
//  Copyright © 2023 Appicial Taxi App Soutions. All rights reserved.
//

#import "PassengerViewController.h"
#import "UIView+UpdateAutoLayoutConstraints.h"
#import "ConstantModel.h"
@interface PassengerViewController ()<UITextFieldDelegate>
{
    ConstantModel * constantTaxiModel;
}


@end

@implementation PassengerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
  constantTaxiModel=[ConstantModel getConstantsObject];
    [self setUIFiels];
    [self setupTextFieldPassenger:self.txtPassengeName];
    [self setupTextFieldPassenger:self.txtPassengePhone];
    self.txtPassengePhone.delegate=self;
}

 

-(void)setupTextFieldPassenger:(UITextField*)textField{
    textField.delegate=self;
    [self setTextFieldPlaceholderColor:textField];
}



-(void) setUIFiels{
    self.lblPassengerDetails.text=[LanguageHelper getStringWithKey:@"k_s3_passenger_details"];
    self.txtPassengePhone.placeholder=[LanguageHelper getStringWithKey:@"k_s3_passenger_phone"];
    self.txtPassengeName.placeholder=[LanguageHelper getStringWithKey:@"k_s3_passenger_name"];
    [self.btnPassengeDetailsSave setTitle: [LanguageHelper getStringWithKey:@"k_34_s6_save"]   forState:UIControlStateNormal];
    [self.btnPassengeDetailsSkip setTitle: [LanguageHelper getStringWithKey:@"k_22_s8_skip"]   forState:UIControlStateNormal];
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
    [self.delegate controller:self  onSavePassengerDetail:nil isSkip:YES];
}

- (IBAction)onPassengeDetailsSaveButtonTap:(id)sender {
    NSString *trimmedFirstName = [self.txtPassengeName.text stringByTrimmingCharactersInSet:
                                  [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if(trimmedFirstName.length==0){
        [self showAlertWithMessgae:[LanguageHelper getStringWithKey:@"k_s3_please_passenger_name"]];
        return;
    }
    if(self.txtPassengePhone.text.length==0)  {
        [self showAlertWithMessgae:[LanguageHelper getStringWithKey:@"k_s3_please_passenger_phone"]];
        return;
    }
    if(self.txtPassengePhone.text.length< constantTaxiModel.min_phone_length)  {
        [self showAlertWithMessgae:[LanguageHelper getStringWithKey:@"k_21_s2_plz_enter_valid_mobile_number"]];
        return;
    }
    [self.view endEditing:YES];
    [self.delegate controller:self onSavePassengerDetail:[self pessagerDetailJson] isSkip:NO];
}



- (IBAction)onClose:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}


@end

