//
//  HomeViewController.h
//
//  Created by Appicial Taxi App Soutions on 22/05/17.
//  Copyright © 2023 Appicial Taxi App Soutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@class UPickupDetailViewController;
@protocol UPickupDetailViewControllerDelegate <NSObject>

-(void) controller:(UPickupDetailViewController *)controller onDetailDoneTap:(NSString *)pickupDetails;
-(void) controller:(UPickupDetailViewController *)controller onCancelTap:(UIButton *)sender;
@end


@interface UPickupDetailViewController : BaseViewController

@property (weak, nonatomic) IBOutlet UIView *viewPickupDetailCon;
@property (weak, nonatomic) IBOutlet UITextField *txtPickupDetails;
@property (weak, nonatomic) IBOutlet UILabel *lblPicupDetail;
@property (weak, nonatomic) IBOutlet UIButton *btnDone;

@property (strong, nonatomic) NSString *message;
@property (weak, nonatomic) id<UPickupDetailViewControllerDelegate>delegate;
+(UPickupDetailViewController *) openMessageViewController:(NSString *) message viewController:(UIViewController *)viewController;

@end
