//
//  ShowWalletBalanceAndTranVC.h

//
//  Created by Grepix Infotech on 26/11/18.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "TripModel.h"
#import "TextFieldPadding.h"
@class AskTripOtpVC;
@protocol AskTripOtpVCDelegate <NSObject>

-(void) onOtpEnteredForBegin:(NSString *) otp viewController:(AskTripOtpVC *)viewController;
-(void) closeAskOtpScreen;
@end

@interface AskTripOtpVC : BaseViewController
@property (weak, nonatomic) IBOutlet UIView *cardContainerView;
@property (weak, nonatomic) IBOutlet UILabel *lblTollAmountText;
@property (weak, nonatomic) IBOutlet TextFieldPadding *txtTollAmt;
@property (weak, nonatomic) IBOutlet UIButton *btnTollAdd;
@property (weak, nonatomic) IBOutlet UILabel *lblTollCharge;
@property (weak, nonatomic) IBOutlet OTPFieldView *txtTripOTP;

@property (strong, nonatomic) TripModel *trip;
@property (weak, nonatomic) id<AskTripOtpVCDelegate>delegate;
+(AskTripOtpVC *) openWith:(TripModel *) trip viewController:(UIViewController *)viewController;
-(void)openAgainKeyboard:(BOOL)isDeleteOnly;

@end
