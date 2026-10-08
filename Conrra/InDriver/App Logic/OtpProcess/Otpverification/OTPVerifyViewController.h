//
//  OTPVerifyViewController.h
//  HireMe Rider
//
//  Created by Grepix Infotech on 30/01/19.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LanguageHelper.h"
#import "BaseViewController.h"
#import <Conrra-Swift.h>
NS_ASSUME_NONNULL_BEGIN

@interface OTPVerifyViewController : BaseViewController


@property (weak, nonatomic) IBOutlet UIView *resendView;
@property (weak, nonatomic) IBOutlet UILabel *resendLbl;
@property (weak, nonatomic) IBOutlet UIButton *resendOutLet;
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UILabel *lblHeader;
@property (weak, nonatomic) IBOutlet UIButton *btnBack;
@property (weak, nonatomic) IBOutlet UIImageView *imgGroup;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *verifyView;
@property (weak, nonatomic) IBOutlet UILabel *lblMsg1;
@property (weak, nonatomic) IBOutlet UILabel *lblMsg2;
@property (weak, nonatomic) IBOutlet UILabel *lblMsg3;
@property (weak, nonatomic) IBOutlet UIView *codeSepView2;
@property (weak, nonatomic) IBOutlet UITextView *txtTerms;
@property (weak, nonatomic) IBOutlet UILabel *lblMsg4; 
@property (weak, nonatomic) IBOutlet OTPFieldView *txtOtpView;

/**
 Esta pantalla esta verificando el numero de una sesion YA ABIERTA, no un alta ni una entrada.

 Es el bloqueo al actualizar: quien ya estaba dentro nunca paso por ninguna de las tres puertas
 que verifican, asi que se le pide el codigo una vez y despues sigue su sesion normal. En este
 modo no se registra a nadie ni se vuelve a entrar: se anota que el numero quedo verificado y
 se abre la casa. Ver ConrraNumeroVerificado.
 */
@property (nonatomic, assign) BOOL esVerificacionDeSesion;
@property (weak, nonatomic) IBOutlet UILabel *lblResendOtpTimer;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomScroll;
@property (weak, nonatomic) IBOutlet UITextView *txtDidNotGetOtp;

- (IBAction)btnBack:(id)sender;
- (IBAction)btnResend:(id)sender;

@property (assign,nonatomic) BOOL isFormLogin;
@property(strong , nonatomic) NSDictionary *usersigmUpDict;
@property(assign , nonatomic) int verificationCode;
@property(assign , nonatomic) BOOL isRestPassword;
@property(strong , nonatomic) NSString * countryDialCode;
@property(strong , nonatomic) NSString *phoneNum;

@end

NS_ASSUME_NONNULL_END

