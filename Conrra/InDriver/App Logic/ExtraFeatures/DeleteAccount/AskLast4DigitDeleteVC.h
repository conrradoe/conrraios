//
//  ShowWalletBalanceAndTranVC.h

//
//  Created by Grepix Infotech on 26/11/18.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
@class AskLast4DigitDeleteVC;
@protocol AskLast4DigitDeleteVCDelegate <NSObject>

-(void) onOtpEnteredForBegin:(NSString *) otp;

@end

@interface AskLast4DigitDeleteVC : BaseViewController
@property (weak, nonatomic) IBOutlet UILabel *lblTollAmountText;
@property (weak, nonatomic) IBOutlet UIButton *btnTollAdd;
@property (weak, nonatomic) IBOutlet UILabel *lblTollCharge;
@property (weak, nonatomic) IBOutlet OTPFieldView *txtTripOTP;
 
@property (weak, nonatomic) id<AskLast4DigitDeleteVCDelegate>delegate;

+(AskLast4DigitDeleteVC *) openWithViewController:(UIViewController *)viewController;


@end
