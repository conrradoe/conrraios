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

@class AskForPassengerVC;

@protocol AskForPassengerVCDelegate
-(void) controller:(AskForPassengerVC*) controller isYes:(BOOL)isYes;
@end

@interface AskForPassengerVC : BaseViewController

@property (weak, nonatomic) IBOutlet UITextField *txtPassengeName;
@property (weak, nonatomic) IBOutlet UITextField *txtPassengePhone;
@property (weak, nonatomic) IBOutlet UILabel *lblPassengerDetails;
@property (weak, nonatomic) IBOutlet UIButton *btnPassengeDetailsSave;
@property (weak, nonatomic) IBOutlet UIButton *btnPassengeDetailsSkip;
@property (weak, nonatomic) IBOutlet UILabel *lblTextMsg;

@property (assign, nonatomic)BOOL isRiderLater ;
@property (strong, nonatomic)NSDate * tripDate ;
@property (weak, nonatomic)id<AskForPassengerVCDelegate> delegate;
@end
