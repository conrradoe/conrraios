////
//  HomeViewController.m
//
//  Created by Appicial Taxi App Soutions on 22/05/17.
//  Copyright © 2023 Appicial Taxi App Soutions. All rights reserved.
//

#import "EstimateFareInfoViewController.h"
#import "UIView+UpdateAutoLayoutConstraints.h"
#import "AboutUsViewController.h"
#import "Utilities.h"
#import "ConstantModel.h"
@interface EstimateFareInfoViewController ()
{
  
}

@end

@implementation EstimateFareInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUIFiels];
    [self setfareDetails];
}


 




-(void) setUIFiels{
    self.lblDetails.text = Localise(@"k_r70_s3_fare_details");
    self.lblYourTrip.text = Localise(@"k_s3_fare_esti");
    self.lblFarePerKm.text = Localise(@"k_r1_s6_max_cpcity");
    self.lblFarePerMin.text = Localise(@"k_4_s11_est_duration");
    self.lblTotalDistance.text = Localise(@"k_r67_s3_total_dist");
    self.lblTotalDistance.text = Localise(@"k_4_s11_est_distance");
    [self.dismissFareDetailOutlet setTitle: Localise(@"k_r69_s3_got_it")   forState:UIControlStateNormal];
    [self.btnShowFarePolicy setTitle: Localise(@"k_s3_show_fare_policy")  forState:UIControlStateNormal];
    self.lblTotalFare.text=Localise(@"k_r68_s3_total_fare_chnge_if_change");
    if([self  isRTL]){
        self.lblPerKM.textAlignment=NSTextAlignmentLeft;
        self.lblPerMin.textAlignment=NSTextAlignmentLeft;
        self.lblDistance.textAlignment=NSTextAlignmentLeft;
        self.lblEstimate.textAlignment=NSTextAlignmentLeft;
        self.lblExpectedTime.textAlignment=NSTextAlignmentLeft;
    }else{
        self.lblPerKM.textAlignment=NSTextAlignmentRight;
        self.lblPerMin.textAlignment=NSTextAlignmentRight;
        self.lblDistance.textAlignment=NSTextAlignmentRight;
        self.lblEstimate.textAlignment=NSTextAlignmentRight;
        self.lblExpectedTime.textAlignment=NSTextAlignmentRight;
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}


-(void) viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}





#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    //  Get the new view controller using [segue destinationViewController].
    //  Pass the selected object to the new view controller.
}








-(void)setfareDetails{
    NSString *dis;
    NSString *tripDis;
    float distanceConvertedInUnit=0.0;
    if (isDistanceUnitKm(self.bookingModel.cityModel.city_dist_unit)) {
        dis =self.bookingModel.cityModel.city_dist_unit;
        tripDis =[Utilities formatDistance:self.bookingModel.totalDistance];
        distanceConvertedInUnit =self.bookingModel.totalDistance;
    }
    else{
        dis =self.bookingModel.cityModel.city_dist_unit;
        float miles = self.bookingModel.totalDistance*0.621371192;
        tripDis = [Utilities formatDistance:miles];
        distanceConvertedInUnit = self.bookingModel.totalDistance*0.621371192;
    }
    float tripDistanceConvertedInUnit=distanceConvertedInUnit;
    _lblPerKM.text=[NSString stringWithFormat:@"%d %@",self.bookingModel.category.cat_max_size,Localise(@"k_s3_psngr")];

    
    _lblDistance.text =[NSString stringWithFormat:@"%@ %@",tripDis,dis];
    NSString *fare = [self.bookingModel.fareEstimated objectForKey:@"trip_pay_amount_without_share_discount_without_promo"];
//    EstimatedFare * estimatedFare=[self.bookingModel getEstimateFareForCategory:self.bookingModel.category.categoryId];
    self.lblEstimate.text =[Utilities formatAmountAndCurrency:[fare floatValue] currency:isEmpty(self.bookingModel.cityModel.city_cur)];
    self.lblPerMin.text =  [NSString stringWithFormat:@"%d %@",self.bookingModel.totalTime,Localise(self.bookingModel.totalTime<=1?@"k_17_s4_min":@"k_17_s4_mins")];
    if(self.bookingModel.category.is_share&&[[ConstantModel getConstantsObject] getCValueFK:ckey_rds]){
        if(self.bookingModel.isRiderSahre){
            [self.btnShowFarePolicy setHidden:NO];
            [self.btnShowFarePolicy setConstraintConstant:30 forAttribute:NSLayoutAttributeHeight];
        }else{
            [self.btnShowFarePolicy setHidden:YES];
            [self.btnShowFarePolicy setConstraintConstant:0 forAttribute:NSLayoutAttributeHeight];
        }
    }else{
        [self.btnShowFarePolicy setHidden:YES];
        [self.btnShowFarePolicy setConstraintConstant:0 forAttribute:NSLayoutAttributeHeight];
    }
  
    if(self.bookingModel.directionModel.duration_in_traffic>0){
        int duration11=(int)((self.bookingModel.totalTime*110)/100.0);
        int duration15=(int)((self.bookingModel.totalTime*150)/100.0);
        if(self.bookingModel.directionModel.duration_in_traffic<=duration11){
            self.lblTraficMode.text=Localise(@"k_s1_323_normal");
            self.viewTraficStatus.backgroundColor=[UIColor greenColor];
        }else if(self.bookingModel.directionModel.duration_in_traffic>duration11&&self.bookingModel.directionModel.duration_in_traffic<duration15) {
            self.lblTraficMode.text=Localise(@"k_s1_323_moderate");
            self.viewTraficStatus.backgroundColor=[UIColor orangeColor];
        }else  if(self.bookingModel.directionModel.duration_in_traffic==0&&self.bookingModel.directionModel.duration==0){
            self.lblTraficMode.text=Localise(@"k_s1_323_normal");
            self.viewTraficStatus.backgroundColor=[UIColor greenColor];
        }
        else{
            self.lblTraficMode.text=Localise(@"k_s1_323_high");
            self.viewTraficStatus.backgroundColor=[UIColor redColor];
        }
    }else{
        if(self.bookingModel.directionModel.speed_in_kmphs>40) {
            self.lblTraficMode.text=Localise(@"k_s1_323_normal");
            self.viewTraficStatus.backgroundColor=[Utilities colorWithHexString:@"99cc00"];
        }else if(self.bookingModel.directionModel.speed_in_kmphs>=20) {
            self.lblTraficMode.text=Localise(@"k_s1_323_moderate");
            self.viewTraficStatus.backgroundColor=[Utilities colorWithHexString:@"ffbb33"];
        }else{
            self.lblTraficMode.text=Localise(@"k_s1_323_high");
            self.viewTraficStatus.backgroundColor=[Utilities colorWithHexString:@"ff4444"];
        }
    }
   
}







- (IBAction)ButtonDismissFareDetail:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}


- (IBAction)onFarePolicyButtonTap:(id)sender {
//    AboutUsViewController *viewController=(AboutUsViewController *)[StoryBoardUtiles viewContollerInMainWithIdentifier:StoryBoardUtiles.ABOUT_US ];
//    viewController.isAboutUs=NO;
//    viewController.isFarePolicy=YES;
//    viewController.modalPresentationStyle=UIModalPresentationFullScreen;
//    [self presentViewController:viewController animated:YES completion:^{
//
//    }];
    [self.delegate openFarePolicyUrl:self];
//    [self.navigationController pushViewController:viewController animated:YES];
}



-(NSAttributedString *) formattedFareText:(float) actucalFare discountedFare:(float) discountedFare isMuiltiLine:(BOOL) isMulitiLine{
    
    NSString * stringPriceWithPromocode=[Utilities formatAmountAndCurrency:discountedFare currency:isEmpty(self.bookingModel.cityModel.city_cur)];

    
    NSString * stringPriceWithOutPromocode=@"";
    
    
    if(isMulitiLine)
    {
        stringPriceWithOutPromocode=[NSString stringWithFormat:@"%@\n",[Utilities formatAmountAndCurrency:actucalFare currency:isEmpty(self.bookingModel.cityModel.city_cur)]];
    }else
    {
        stringPriceWithOutPromocode=[Utilities formatAmountAndCurrency:actucalFare currency:isEmpty(self.bookingModel.cityModel.city_cur)];
    }
    NSMutableAttributedString * finalAttributedString=[[NSMutableAttributedString alloc] initWithString:@""];
     
    NSAttributedString *theAttributedString1;
    theAttributedString1 = [[NSAttributedString alloc] initWithString:stringPriceWithPromocode
                                                           attributes:@{NSFontAttributeName:
                                                                            FONTS_THEME_REGULAR(isMulitiLine?13:16),NSForegroundColorAttributeName:RGB(0, 210, 0)}];
    NSAttributedString *theAttributedString;
    theAttributedString = [[NSAttributedString alloc] initWithString:stringPriceWithOutPromocode
                                                          attributes:@{NSStrikethroughStyleAttributeName:
                                                                           [NSNumber numberWithInteger:NSUnderlineStyleSingle],NSFontAttributeName: FONTS_THEME_REGULAR(isMulitiLine?8:16),NSForegroundColorAttributeName:RGB(255, 0, 0)}];
    [finalAttributedString appendAttributedString:theAttributedString];
     [finalAttributedString appendAttributedString:theAttributedString1];
    return  finalAttributedString;
}
@end

