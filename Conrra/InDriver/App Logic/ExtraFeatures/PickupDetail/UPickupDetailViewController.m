////
//  HomeViewController.m
//  Store_project
//
//  Created by Appicial Taxi App Soutions on 22/05/17.
//  Copyright © 2023 Appicial Taxi App Soutions. All rights reserved.
//

#import "UPickupDetailViewController.h"
#import "WebCallConstants.h"
#import "LanguageHelper.h"
@interface UPickupDetailViewController ()
{
}

@end

@implementation UPickupDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.txtPickupDetails.text=isEmpty(self.message);
    [self setTextFieldPlaceholderColor:self.txtPickupDetails];
    [self setUIFiels];
  
   
    
}
 


-(void) setUIFiels{
//    txtPickupDetails
    [self.btnDone setTitle: [LanguageHelper getStringWithKey:@"k_r35_s9_done"]   forState:UIControlStateNormal];
    self.lblPicupDetail.text = [LanguageHelper getStringWithKey:@"k_r72_s3_pikup_details"];
    self.txtPickupDetails.placeholder = [LanguageHelper getStringWithKey:@"k_75_s4_entr_det"];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
   
    [self setUIFiels];

}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
   
}



- (IBAction)onAddPickupDetailDoneButTap:(id)sender {
    [self.view endEditing:YES];
    [self.delegate controller:self onDetailDoneTap:self.txtPickupDetails.text];
}


+(UPickupDetailViewController *) openMessageViewController:(NSString *) message viewController:(UIViewController *)viewController{
    UPickupDetailViewController *vc=[[UIStoryboard storyboardWithName:@"ExtraFeature" bundle:nil] instantiateViewControllerWithIdentifier:@"UPickupDetailViewController"];
    vc.modalPresentationStyle=UIModalPresentationOverCurrentContext;
    vc.modalTransitionStyle=UIModalTransitionStyleCrossDissolve;
    vc.message=message;
    [viewController presentViewController:vc animated:YES completion:^{
      
    }];
    return  vc;
}



@end

