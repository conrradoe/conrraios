//
//  HomeViewController.h
//  Store_project
//
//  Created by Appicial Taxi App Soutions on 22/05/17.
//  Copyright © 2023 Appicial Taxi App Soutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "BookingModel.h"
@class EstimateFareInfoViewController;
@protocol EstimateFareInfoViewControllerDelegate <NSObject>

-(void)openFarePolicyUrl:(EstimateFareInfoViewController *)controller;

@end
@interface EstimateFareInfoViewController : BaseViewController

@property (strong, nonatomic) IBOutlet UILabel *lblPerKM;
@property (strong, nonatomic) IBOutlet UILabel *lblPerMin;
@property (strong, nonatomic) IBOutlet UILabel *lblDistance;
@property (strong, nonatomic) IBOutlet UILabel *lblEstimate;
@property (strong, nonatomic) IBOutlet UILabel *lblExpectedTime;

@property (weak, nonatomic) IBOutlet UIView *fareDetailBgView;
@property (weak, nonatomic) IBOutlet UIButton *dismissFareDetailOutlet;
@property (weak, nonatomic) IBOutlet UILabel *lblDetails;
@property (weak, nonatomic) IBOutlet UILabel *lblYourTrip;
@property (weak, nonatomic) IBOutlet UILabel *lblFarePerKm;
@property (weak, nonatomic) IBOutlet UILabel *lblFarePerMin;
@property (weak, nonatomic) IBOutlet UILabel *lblTotalDistance;
@property (weak, nonatomic) IBOutlet UILabel *lblTotalFare;
@property (weak, nonatomic) IBOutlet UIButton *btnShowFarePolicy;
@property (weak, nonatomic) IBOutlet UILabel *lblTraficMode;
@property (weak, nonatomic) IBOutlet UIView *viewTraficStatus;
@property(strong,nonatomic)BookingModel *bookingModel;
- (IBAction)ButtonDismissFareDetail:(id)sender;
@property(weak,nonatomic) id<EstimateFareInfoViewControllerDelegate>delegate;

@end
