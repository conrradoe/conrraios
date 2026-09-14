//
//  LanguageViewController.h
//  JS Rider
//
//  Created by Devineer on 25/06/18.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import <UIKit/UIKit.h>
@import Stripe;
#import "AFHTTPRequestOperationManager.h"


@interface AddPaymentMethodViewController : UIViewController 
@property (strong, nonatomic) IBOutlet UILabel *lblHeaderTitle;
@property (weak, nonatomic) IBOutlet STPPaymentCardTextField *cardDetail;
@property (weak, nonatomic) IBOutlet UIButton *btnBackButton;
@property (assign, nonatomic) BOOL isFromRideLoginAddMethod;

@property (weak, nonatomic) IBOutlet UIView *viewTestCardDetails;
@property (weak, nonatomic) IBOutlet UILabel *lblTestCardDetails;
@property (weak, nonatomic) IBOutlet UILabel *lblCardNumber;
@property (weak, nonatomic) IBOutlet UILabel *lblExpiry;
@property (weak, nonatomic) IBOutlet UILabel *lblCVV;
@property (weak, nonatomic) IBOutlet UIButton *btnAdd;
@property (weak, nonatomic) IBOutlet UILabel *lblPinCode;
@end
