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
        /*
         "Pago Movil", no CARD.

         Este es el valor que viaja en trip_pay_mode y lo lee TODO lo demas: el
         distintivo del conductor, la fila de metodo de pago del viaje en curso, la
         tarjeta con los datos bancarios, los informes. Android escribe "Pago Movil" y
         aqui se escribia "Card", asi que el mismo metodo se llamaba de dos formas y
         un viaje pedido desde un iPhone salia como "Tarjeta" en la app del conductor.

         CARD sigue usandose donde toca: el cobro con tarjeta de Stripe al final del
         viaje, que es otra cosa y lo pone UFareSummeryViewController.
         */
        self.tripPayMode  = PAGO_MOVIL_PAY;
        self.paymentModeText = [LanguageHelper getStringWithKey:@"k_s10_mobile_payment" defaultValue:@"Pago Móvil"];
        self.paymentModeImage = [UIImage imageNamed:@"ic_cash_theame"];
    }
}




@end
