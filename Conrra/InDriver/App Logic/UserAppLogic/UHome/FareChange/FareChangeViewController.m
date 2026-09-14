//
//  FareChangeViewController.m
//  InRider
//
//  Created by Grepix on 08/07/21.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import "FareChangeViewController.h"
#import "CategoryModel.h"
#import "Utilities.h"
@interface FareChangeViewController ()
@property (weak, nonatomic) IBOutlet UIView *viewFareInput;
@property (weak, nonatomic) IBOutlet UILabel *lblCurrency;
@property (weak, nonatomic) IBOutlet UITextField *txtFare;
@property (weak, nonatomic) IBOutlet UILabel *lblFare;
@property (weak, nonatomic) IBOutlet UILabel *lblFareChangeMessage;

@end

@implementation FareChangeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.viewFareInput.layer.cornerRadius =5;
    self.viewFareInput.layer.borderWidth =.5;
    self.viewFareInput.layer.borderColor =[UIColor colorNamed:@"app_border_color"].CGColor;
    self.viewFareInput.clipsToBounds=YES;
    if(self.isPromoCodeApplied){
        self.txtFare.text=[self.dictFareEstimate objectForKey:TOTAL_AMT_PROMO];
    }else{
        self.txtFare.text=[self.dictFareEstimate objectForKey:TOTAL_AMT];
    }
    // Do any additional setup after loading the view.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)onDoneButtonTap:(id)sender {
    if([self.txtFare.text floatValue]<=0){
        [self showAlertWithMessgae:@"k_r1_s6_please_enter_amount"];
        return;
    }
    NSMutableDictionary *dict=[[NSMutableDictionary alloc] initWithDictionary:self.dictFareEstimate];
    if(self.isPromoCodeApplied){
        [dict setObject:[Utilities formatAmount:[self.txtFare.text floatValue]] forKey:TOTAL_AMT_PROMO ];
        
    }else{
        [dict setObject:[Utilities formatAmount:[self.txtFare.text floatValue]] forKey:TOTAL_AMT ];
    }
    [self dismissViewControllerAnimated:YES completion:^{
        [self.delegate viewController:self onDoneButtonTap:nil dictFare:dict];
    }];
}

@end
