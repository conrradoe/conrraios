//
//  DatePickerViewController.m
//  PrathiCabs
//
//  Created by Grepix on 29/07/21.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import "DatePickerViewController.h"
#import "LanguageHelper.h"
#import "ConstantModel.h"
@interface DatePickerViewController ()

@end

@implementation DatePickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUiText];
    self.datePicker.minimumDate=[NSDate date];
    self.datePicker.datePickerMode=UIDatePickerModeDate;
    [self.datePicker addTarget:self action:@selector(onDatePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
    if(self.selectedDate){
        self.datePicker.date=self.selectedDate;
    }
}

-(void)setUiText{
    if(self.titleText){
        self.lblTitle.text=self.titleText;
    }else{
        self.lblTitle.text=[LanguageHelper getStringWithKey:@"k_r53_s3_plz_sel_ride_time"];
    }
}

- (void)onDatePickerValueBegin:(UIDatePicker *)datePicker
{
    self.btnSelect.hidden=YES;
}

- (void)onDatePickerValueChanged:(UIDatePicker *)datePicker
{
    self.btnSelect.hidden=NO;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)onDateSelect:(id)sender {
    
//    [UIView animateWithDuration:.4 animations:^{
//        self.viewDatePicker.alpha=0;
//    } completion:^(BOOL finished) {
//        if(finished){
            [self.delegate viewController:self dateSelected:self.datePicker.date];
//        }
//    }];
}

- (IBAction)onCancelButtonTap:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}




@end
