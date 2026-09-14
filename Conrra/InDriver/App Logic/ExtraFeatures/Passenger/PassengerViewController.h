//
//  HomeViewController.h
//  Store_project
//
//  Created by Appicial Taxi App Soutions on 22/05/17.
//  Copyright © 2023 Appicial Taxi App Soutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LanguageHelper.h"
#import "BaseViewController.h"

@class PassengerViewController;

@protocol PassengerViewControllerDelegate
-(void) controller:(PassengerViewController*) controller onSavePassengerDetail:(NSString *)passengerDetail isSkip:(BOOL)isSkip;
@end

@interface PassengerViewController : BaseViewController

@property (weak, nonatomic) IBOutlet UITextField *txtPassengeName;
@property (weak, nonatomic) IBOutlet UITextField *txtPassengePhone;
@property (weak, nonatomic) IBOutlet UILabel *lblPassengerDetails;
@property (weak, nonatomic) IBOutlet UIButton *btnPassengeDetailsSave;
@property (weak, nonatomic) IBOutlet UIButton *btnPassengeDetailsSkip;
@property (assign, nonatomic)BOOL isRiderLater ;
@property (strong, nonatomic)NSDate * tripDate ;
@property (weak, nonatomic)id<PassengerViewControllerDelegate> delegate;
@end
