//
//  HomePaymentViewModel.m
//  HireMeRider
//
//  Created by Grepix Infotech on 20/09/23.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import "HomePaymentViewModel.h"
#import "LanguageHelper.h"
@implementation HomePaymentViewModel
-(instancetype)init:(int) paymentMode{
    if(self) {
        [self updatePaymentModeText:paymentMode];
    }
    return  self;
}
-(void) updatePaymentModeText:(int) paymentMode{
    [self updatePaymentModeText:paymentMode cardNumber:nil];
}

-(void) updatePaymentModeText:(int) paymentMode cardNumber:( NSString *)cardNumber{
    self.paymentMode = paymentMode;
    if (self.paymentMode == -1) {
        self.tripPayMode  = @"";
        self.paymentModeText =[LanguageHelper getStringWithKey:@"k_r35_s1_select_payment_method"];
        self.paymentModeImage = [UIImage imageNamed:@"ic_cash_theame"];
    }
    else if (self.paymentMode == 0) {
        self.tripPayMode  = CASH_PAY;
        self.paymentModeText =[LanguageHelper getStringWithKey:@"k_r39_s9_cash"];
        self.paymentModeImage = [UIImage imageNamed:@"ic_cash_theame"];
    }else if (self.paymentMode == 1) {
        self.tripPayMode  = HIRE_ME_WALLET_PAY;
        self.paymentModeText =[LanguageHelper getStringWithKey:@"k_r39_s9_wallet"];
        self.paymentModeImage = [UIImage imageNamed:@"ic_wallet_theame"];
    }else if (self.paymentMode == 2) {
        self.tripPayMode  = CARD;
        self.paymentModeText = [LanguageHelper getStringWithKey:@"k_s10_mobile_payment" defaultValue:@"Pago Móvil"];
        self.paymentModeImage = [UIImage imageNamed:@"ic_cash_theame"];
    }
}




@end
