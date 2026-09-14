//
//  RiderCancelTripViewController.m
//  Golden Moto Driver
//
//  Created by Grepix - Baij on 19/02/20.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import "RiderCancelTripViewController.h"
#import "AppDelegate.h"
#import "WebCallConstants.h"
@interface RiderCancelTripViewController ()

@end

@implementation RiderCancelTripViewController
{
    ConstantModel  *constantModel;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    constantModel =[ConstantModel getConstantsObject];;
    self.tripModel=[[TripModel alloc] init];
    self.tripModel.trip_Id=self.tripId;
    if(self.tripId!=nil)
    {
        [self.tripModel refreshTripModelWithCompletionBlock:^(id results, NSError *error) {
            [self openTripDetail];
        } isShowLoader:YES];
    }
}

// Do any additional setup after loading the view.

-(void) openTripDetail
{
    TripDetailsViewController *details = (TripDetailsViewController *)[StoryBoardUtiles viewContollerInMainWithIdentifier:StoryBoardUtiles.TRIP_DETAIL_VC];
    details.delegate=self;
    details.trip = self.tripModel;
    [self addChildViewController:details];
    [details.view setFrame:CGRectMake(0.0f, 0.0f, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [self.view addSubview:details.view];
    [details didMoveToParentViewController:self];
}
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
- (IBAction)onBackButtonTap:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)onCloseTripDetail{
    [self.navigationController popViewControllerAnimated:YES];
}
@end
