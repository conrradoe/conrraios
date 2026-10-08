//
//  OTPVerifyViewController.m
//  HireMe Rider
//
//  Created by Grepix Infotech on 30/01/19.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import "OTPVerifyViewController.h"
#import "WebCallConstants.h"
#import <GIKit/GIKit.h>
#import "AppDelegate.h"
#import "MainViewController.h"
#import "ChangePasswordViewController.h"
#import "HomeViewController.h"
#import "UploadDocumentViewController.h"
#import "Utilities.h"
#import "ConstantModel.h"
#define  PHONE_NUMBER_FORMAT @"#         #        #         #"
#import "IQKeyboardManager.h"
#import <MessageUI/MFMailComposeViewController.h>
#import "AboutUsViewController.h"
#import "SettingsModel.h"
#import "ConrraButton.h"
#import "ConrraFotoDeRegistro.h"
#import "ConrraVerificacionTelefono.h"
#import "ConrraTelefonoE164.h"
@interface OTPVerifyViewController ()<UITextFieldDelegate,OTPFieldViewDelegate,MFMailComposeViewControllerDelegate>{
    int smsCode;
    CGRect frameOrignal;
    BOOL isTimeSet;
    int otpAttempCount;
    
    
}

@end

@implementation OTPVerifyViewController
{
    NSTimer * timer;
    NSDate * dateTimer;
    NSDate * dateTimerForExit;
    NSTimer * timerForExit;
    BOOL isExitMessageShow;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    isTimeSet=NO;
    otpAttempCount=2;
    [self.txtTerms addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapOnLabel:)]];
    self.txtTerms.userInteractionEnabled=YES;
    if (@available(iOS 11.0, *)) {
        UIWindow *window = UIApplication.sharedApplication.windows.firstObject;
        CGFloat topPadding = window.safeAreaInsets.top;
        CGFloat bottomPadding = window.safeAreaInsets.bottom;
        self->frameOrignal=CGRectMake(0,0,SCREEN_WIDTH,SCREEN_HEIGHT-topPadding-bottomPadding);
    }else{
        self->frameOrignal=CGRectMake(0,0,SCREEN_WIDTH,SCREEN_HEIGHT);
    }
    
//    self->frameOrignal=self.scrollView.frame;
    [self setUIFields];
    [self setInitialUi];
    [self startResendTimer];
    
    // Firebase manda SEIS digitos; el camino viejo generaba cuatro.
    self.txtOtpView.fieldsCount = (int)[ConrraVerificacionTelefono casillas];
    self.txtOtpView.fieldBorderWidth = 1;
    self.txtOtpView.fieldSize=46;
    self.txtOtpView.defaultBorderColor=[UIColor colorNamed:@"app_theame"];
    self.txtOtpView.filledBorderColor=[UIColor colorNamed:@"app_theame"];
    self.txtOtpView.displayType=DisplayTypeRoundedCorner;
    self.txtOtpView.separatorSpace=10;
    self.txtOtpView.delegate=self;
    [self.txtOtpView initializeUI];
//    [self.scrollView setTranslatesAutoresizingMaskIntoConstraints:YES];
//    self.scrollView.frame=frameOrignal;
//    double delayInSeconds = 1.6;
//    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
//    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
////        [UIView animateWithDuration:0.3 animations:^{
//
//            self->frameOrignal=self.scrollView.frame;
//            CGRect rect=self->frameOrignal;
//            rect.size.height=rect.size.height-290;
//            self.scrollView.frame=rect;
////            self.scrollView.contentOffset=CGPointMake(0, 290);
//
//            self->isTimeSet=NO;
//
////        }];
//    });
                    [((OTPTextField *)[self.txtOtpView viewWithTag:1]) becomeFirstResponder];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
//    [self.otpTextfield becomeFirstResponder];
    [self setOtp];
    // Do any additional setup after loading the view.

    [self setupOTPScreenLayout];

    /*
     ============ EL PRIMER CODIGO SE PIDE AQUI ============

     Y hasta ahora NO SE PEDIA EN NINGUNA PARTE. verifyMobileNo solo lo llamaban los dos
     botones de reenviar -- el de la ruedecita y el enlace del texto --, asi que con un
     proveedor de fuera el usuario llegaba a esta pantalla, veia seis casillas vacias y no
     recibia nada hasta que se le ocurria pulsar "reenviar". Visto desde el telefono eso es
     indistinguible de "el mensaje no llega".

     Antes no se notaba porque el codigo lo generaba el app y lo mandaba la pantalla
     ANTERIOR: aqui no habia nada que pedir. Al pasar el envio a Firebase se quito de alli
     sin ponerlo en ningun sitio, y el hueco quedo abierto.

     EL GUARDIA NO ES ADORNO. Sin el, volver atras y entrar otra vez pide un codigo nuevo:
     cada envio se paga, y repetir es justo lo que dispara el antifraude de Didit -- que
     contesta "Blocked" y, dice su rele, no se debe reintentar. Se pregunta por el NUMERO y
     no por "¿hay alguna sesion?", que es como se acaba verificando un telefono y entrando
     con otro.

     Con el OTP apagado no se pide nada, claro: no hay codigo que esperar.
     */
    if ([ConrraVerificacionTelefono loVerificaElServidor]
        && ![self otpApagado]
        && ![ConrraVerificacionTelefono hayEnvioEnCursoPara:[self telefonoE164]]) {
        [self verifyMobileNo];
    }
}

-(void)appWillEnterForeground:(NSNotification *)paramNotification
{
    [self stopResendTimer];
    timer=[NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(updateTimer) userInfo:nil repeats:YES];
    NSRunLoop *runner = [NSRunLoop currentRunLoop];
    [runner addTimer: timer forMode: NSDefaultRunLoopMode];
}

-(void)startForExit{
    if(dateTimerForExit==nil){
        dateTimerForExit=[NSDate date];
    }
    [self stopExitTimer];
    
    int diffSec=5*60-([[NSDate date] timeIntervalSince1970]-[dateTimerForExit timeIntervalSince1970]);
    if(diffSec<=0){
        [self timeForExitMethod];
    }else{
        timerForExit=[NSTimer timerWithTimeInterval:diffSec target:self selector:@selector(timeForExitMethod) userInfo:nil repeats:NO];
        NSRunLoop *runner = [NSRunLoop currentRunLoop];
        [runner addTimer: timerForExit forMode: NSDefaultRunLoopMode];
    }
}
-(void) timeForExitMethod{
    if(isExitMessageShow){
        return;
    }
    isExitMessageShow=YES;
    [self showAlertWithOk:@"" message:[LanguageHelper getStringWithKey:@"k_2_s12_isu_rtry" defaultValue:@"You are facing some issue  in get otp . Please try later"] handler:^(UIAlertAction * _Nonnull action) {
        [self btnBack:self.btnBack];
    }];
}
-(void)stopExitTimer{
    if(timerForExit){
        [timerForExit invalidate];
        timerForExit=nil;
    }
}

-(void)startResendTimer{
    [self stopResendTimer];
    timer=[NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(updateTimer) userInfo:nil repeats:YES];
    NSRunLoop *runner = [NSRunLoop currentRunLoop];
    [runner addTimer: timer forMode: NSDefaultRunLoopMode];
    dateTimer=[NSDate date];
    self.resendView.hidden=YES;
    [self updateTimer];
}

/**
 Con la verificacion apagada la pantalla se rellena sola y sigue.

 LOS DIGITOS LOS MANDAN LAS CASILLAS, no el codigo. Estaban escritas las cuatro a mano, una
 linea por casilla, porque el camino viejo eran cuatro digitos. Con Firebase son seis: se
 llenaban las cuatro primeras, las otras dos se quedaban vacias y la pantalla parecia
 esperando algo que nadie iba a teclear.

 La condicion tambien se leia aqui otra vez (otp_off e is_test, a mano). Es la misma regla
 que otpApagado, asi que se pregunta ahi: dos copias de una regla acaban separandose.
 */
-(void)setOtp{
    if (![self otpApagado]) {
        return;
    }
    NSTimeInterval delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        NSString *codigo = [self codigoSimulado];
        for (NSInteger i = 1; i <= (NSInteger)codigo.length; i++) {
            OTPTextField *casilla = (OTPTextField *)[self.txtOtpView viewWithTag:i];
            [casilla setText:[codigo substringWithRange:NSMakeRange(i - 1, 1)]];
        }
        [self validateAfterDelay];
    });
}

/**
 Un codigo de exactamente tantos digitos como casillas haya.

 El backend sigue mandando CUATRO -- es el codigo del camino viejo, lo genera el servidor --
 y las casillas de Firebase son SEIS. Los dos que faltan se rellenan con ceros.

 Y eso no falsea nada: con la verificacion apagada validateOTP sale por su primera rama sin
 mirar el codigo, asi que esto es lo que se VE, no lo que se comprueba. Si algun dia se
 comprueba, aqui esta escrito que los ultimos digitos eran relleno.

 Recortar tambien hace falta, no solo rellenar: characterAtIndex: sobre un codigo mas corto
 que las casillas no deja un hueco en blanco, lanza una excepcion de rango y la app se
 cierra. Con otp_off y sin codigo del servidor, verificationCode es 0: un solo caracter.
 */
-(NSString *)codigoSimulado {
    const NSInteger casillas = [ConrraVerificacionTelefono casillas];
    NSMutableString *codigo = [NSMutableString stringWithFormat:@"%d", self.verificationCode];
    if ((NSInteger)codigo.length > casillas) {
        return [codigo substringToIndex:casillas];
    }
    while ((NSInteger)codigo.length < casillas) {
        [codigo appendString:@"0"];
    }
    return codigo;
}

-(void) validateAfterDelay{
    NSTimeInterval delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        // Se valida lo que hay en las casillas, que es lo que el usuario tiene delante.
        // Antes se mandaba el codigo con %d, que deja de ser lo mismo en cuanto los
        // digitos del codigo y el numero de casillas no coinciden -- o sea, ahora.
        [self validateOTP:[self codigoEnLasCasillas]];
    });
}

-(void)stopResendTimer{
    if(timer){
        [timer invalidate];
        timer=nil;
    }
}

-(void) updateTimer{
    int diffSec=[[NSDate date] timeIntervalSince1970]-[dateTimer timeIntervalSince1970];
    if(diffSec>=30){
        self.lblResendOtpTimer.text=@"";
        self.resendView.hidden=NO;
        if(isTimeSet==NO){
            isTimeSet=YES;
        self.scrollView.contentOffset=CGPointMake(0, 190);
        }
    }else{
        NSString * attempText=[LanguageHelper getStringWithKey:@"k_2_s12_atmp_reming" defaultValue:@"attemp remaining"];
        self.lblResendOtpTimer.text=[NSString stringWithFormat:@"%@ %@%02d\n(%d %@)",[LanguageHelper getStringWithKey:@"k_s7_timer_msg"], [LanguageHelper getStringWithKey:@"00:"],(30 - diffSec),otpAttempCount,attempText];
//        self.lblResendOtpTimer.text=[NSString stringWithFormat:@"%@%02d",[LanguageHelper getStringWithKey:@"00:"],(30- diffSec)];
    }
}



-(void) setUIFields{
    self.lblHeader.text = [Utilities stringByStrippingHTML:[LanguageHelper getStringWithKey:@"k_r1_s6_verification"]];
    self.imgGroup.image = [UIImage imageNamed:@"Group 115"];
    self.lblMsg1.text = [Utilities stringByStrippingHTML:[LanguageHelper getStringWithKey:@"k_2_s12_we_have_sent_you_an_access_code"]];
    self.lblMsg2.text = [Utilities stringByStrippingHTML:[LanguageHelper getStringWithKey:@"k_3_s12_via_sms_for_mobile_number_verification"]];
    self.lblMsg3.text = [Utilities stringByStrippingHTML:[LanguageHelper getStringWithKey:@"k_4_s12_enter_code_here"]];
    self.lblMsg4.text = [Utilities stringByStrippingHTML:[LanguageHelper getStringWithKey:@"k_5_s12_by_entering_sms_code_i_agree_with"]];
    self.txtTerms.attributedText = [self formatViewContactTextForTerms:[LanguageHelper getStringWithKey:@"k_6_s12_i_read_and_agree"]];
    self.txtTerms.textAlignment  = NSTextAlignmentCenter;
    self.resendLbl.text = [Utilities stringByStrippingHTML:[LanguageHelper getStringWithKey:@"k_7_s12_resend_code"]];
    self.txtDidNotGetOtp.attributedText = [self formatViewContactText:[LanguageHelper getStringWithKey:@"k_2_s12_sms_contct" defaultValue:@"Didn't receive SMS?"]];
       self.txtDidNotGetOtp.textAlignment  = NSTextAlignmentCenter;
       [self.txtDidNotGetOtp setEditable:NO];
       [self.txtDidNotGetOtp setSelectable:NO];
       [self.txtDidNotGetOtp addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapOnLabel:)]];;
       self.txtDidNotGetOtp.userInteractionEnabled=YES;
    
}

-(NSAttributedString *) formatViewContactTextForTerms:(NSString *)string {
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@""]];
    BOOL isSmallDevice = NO;
    if (SCREEN_WIDTH == 320) {
        isSmallDevice = YES;
    }
    UIColor *foregroundColor = nil;
    foregroundColor = [UIColor colorNamed:@"color_app_label"];
    [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ ", string]
                                                                             attributes:@{ NSFontAttributeName: FONTS_THEME_REGULAR_NO_SCALE(isSmallDevice ? 12 : 15),
                                                                                           NSForegroundColorAttributeName: foregroundColor }]];
//    
    [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:[LanguageHelper getStringWithKey:@"k_6_s12_terms_and_conditions_title"]
                                                                             attributes:@{ NSFontAttributeName: FONTS_THEME_REGULAR_NO_SCALE(isSmallDevice ? 12 : 15), NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle),
                                                                                           NSForegroundColorAttributeName: [UIColor colorNamed:@"color_terms_text"],
                                                                                           @"object_terms": @"viewDetails" }]];
    NSAttributedString * attrStrAnd = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@ ",[LanguageHelper getStringWithKey:@"k_2_s4_and"]] attributes:@{ NSFontAttributeName:FONTS_THEME_REGULAR_NO_SCALE(14), NSForegroundColorAttributeName:[UIColor colorNamed:@"color_app_label"]}];
    [attributedString appendAttributedString:attrStrAnd];
    
    [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:[LanguageHelper getStringWithKey:@"k_2_s4_privacy"] attributes:@{ NSFontAttributeName:FONTS_THEME_REGULAR_NO_SCALE(15), NSForegroundColorAttributeName:[UIColor colorNamed:@"color_terms_text"], NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle), @"object3":@"viewDetails3"}]];
    return attributedString;
}

-(NSAttributedString *) formatViewContactText:(NSString *)string{
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@""]];
    BOOL isSmallDevice=NO;
    if(SCREEN_WIDTH== 320){
        isSmallDevice=YES;
    }
    [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ ",string]
                                                                             attributes:@{
                                                                                 NSFontAttributeName:FONTS_THEME_REGULAR_NO_SCALE(isSmallDevice?12:15),NSForegroundColorAttributeName:[UIColor colorNamed:@"color_app_label"]}]];
    
    [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:[LanguageHelper getStringWithKey:@"k_11_s4_a1_contact_us" defaultValue:@"Contact Us"]
                                                                             attributes:@{
                                                                                 NSFontAttributeName:FONTS_THEME_BOLD_NO_SCALE(isSmallDevice?12:15),NSForegroundColorAttributeName:[UIColor colorNamed:@"app_theame"],@"object2":@"viewDetails"}]];
    return attributedString;
}

-(void)setInitialUi{
    [self.resendView.layer setCornerRadius: self.resendLbl.frame.size.width / 2];
   [self.resendLbl.layer setBorderColor:[UIColor colorNamed:@"app_theame"].CGColor];
    [self.resendLbl.layer setCornerRadius: self.resendLbl.frame.size.width / 2];
    [self.resendLbl.layer setBorderWidth:1];
    self.resendLbl.backgroundColor = [UIColor clearColor];
    self.resendView.backgroundColor = [UIColor colorNamed:@"app_theame"];
}

- (IBAction)btnBack:(id)sender {
    [self stopResendTimer];
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)btnResend:(id)sender {
    [self verifyMobileNo];
}
-(void)setupTextView:(UITextView*)textView{
    textView.backgroundColor=[UIColor clearColor];
    [textView.layer setBorderWidth:1];
    [textView.layer setBorderColor:[UIColor colorNamed:@"app_theame"].CGColor];
    [textView.layer setCornerRadius:5];
    textView.textContainerInset = UIEdgeInsetsMake(10, 0, 0, 0);
//    textView.hidden = YES;
}

-(void)registerMeWithInfo{
    NSMutableDictionary *dictApi=[[NSMutableDictionary alloc ] initWithDictionary:self.usersigmUpDict];
//    [dictApi setObject:@"9411623083" forKey:P_MOBILE];
    [dictApi setObject:default_fire_password forKey:@"fire_password"];
    [dictApi setObject:@"1" forKey:P_IS_USER_LOGIN];
    /*
     La foto que el pasajero eligio en el formulario, que es OTRA pantalla.

     Viaja por ConrraFotoDeRegistro y no por una propiedad de este controlador: el alta la
     hace esta pantalla pero la foto se elige en la anterior, y es el mismo reparto que usa
     Android. image_description va vacio pero va: UserAPI lo lee sin comprobar que exista.
     */
    if ([ConrraFotoDeRegistro hay]) {
        [dictApi setObject:[ConrraFotoDeRegistro base64] forKey:@"user_image"];
        [dictApi setObject:@"jpg" forKey:@"image_type"];
        [dictApi setObject:@"" forKey:@"image_description"];
    }
    [UtilityClass setLH:NO wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
    [GIC mkwerwu:USER_PH_SIGNUP d:dictApi cb:^(id results, NSError *error) {
           if (isStatusOk(results)) {
               // La cuenta ya existe con su foto: no hace falta seguir guardandola.
               [ConrraFotoDeRegistro olvidar];
               defaults_set_object(P_API_KEY, [[results objectForKey:P_RESPONSE] objectForKey:P_API_KEY]);
               defaults_set_object(P_USER_DICT, [results objectForKey:P_RESPONSE]);
               defaults_set_object(P_USER_DICT_LOGGED, [results objectForKey:P_RESPONSE]);
               defaults_set_object(@"isFBLogin", @"No");
               defaults_set_object(P_IS_USER_LOGIN, @"1");
               [self loadUserHomeViewController];
           } else if (isStatusError(results)) {
               [self showAlertWithMessgae:[LanguageHelper getStringWithKey:errorMessage(results)]];
           }
           else{
                [Utilities handleError:error viewController:self defaultMessage:[LanguageHelper getStringWithKey:@"k_r37_s8_email_exist"]];
           }
           [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
       }];
}

-(void) navigateHome {
    defaults_set_object(P_IS_USER_LOGIN,@"1");
    NSDictionary * dict=defaults_object(P_USER_DICT);
    if(dict){
        defaults_set_object(P_USER_DICT_LOGGED,dict );
        [self loadUserHomeViewController];
        [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
    }
}


// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:StoryBoardUtiles.UPLOAD_DOCUMENT]) {
        UploadDocumentViewController *view =(UploadDocumentViewController *)[segue destinationViewController];
        
        view.isfromProfile = NO;
    }
}

//- (BOOL)textField:(UITextField *)textField
//shouldChangeCharactersInRange:(NSRange)range
//replacementString:(NSString *)string {
//
//    if(self.otpTextfield== textField)
//    {
//        if (!(self.otpTextfield == textField)) {
//            if ([self.otpTextfield.text isEqualToString:@"("]) {
//                self.otpTextfield.text = @"";
//            }
//            return YES;
//        }
//        //    NSString *filter = @"###-###-####";
//
//        if (!PHONE_NUMBER_FORMAT)
//            return YES; // No filter provided, allow anything
//
//        NSString *changedString =
//        [textField.text stringByReplacingCharactersInRange:range
//                                                withString:string];
//
//        if (range.length == 1 && // Only do for single deletes
//            string.length < range.length &&
//            [[textField.text substringWithRange:range]
//             rangeOfCharacterFromSet:
//             [NSCharacterSet characterSetWithCharactersInString:@"0123456789"]]
//            .location == NSNotFound) {
//            // Something was deleted.  Delete past the previous number
//            NSInteger location = changedString.length - 1;
//            if (location > 0) {
//                for (; location > 0; location--) {
//                    if (isdigit([changedString characterAtIndex:location])) {
//                        break;
//                    }
//                }
//                changedString = [changedString substringToIndex:location];
//            }
//        }
//
//        textField.text = [self filteredPhoneStringFromString:changedString withFilter:PHONE_NUMBER_FORMAT];
//        NSString *trimmed = [ textField.text  stringByReplacingOccurrencesOfString:@" " withString:@""];
//         if(trimmed.length>=4)  {
//             [self validateOTP: textField.text];
//         }
//        return NO;
//    }
//
//    else
//        return YES;
//}

#pragma mark - Private Methods
//- (NSMutableString *)filteredPhoneStringFromString:(NSString *)string
//                                        withFilter:(NSString *)filter {
//    NSUInteger onOriginal = 0, onFilter = 0, onOutput = 0;
//    char outputString[([filter length])];
//    BOOL done = NO;
//
//    while (onFilter < [filter length] && !done) {
//        char filterChar = [filter characterAtIndex:onFilter];
//        char originalChar = onOriginal >= string.length
//        ? '\0'
//        : [string characterAtIndex:onOriginal];
//        switch (filterChar) {
//            case '#':
//                if (originalChar == '\0') {
//                    // We have no more input numbers for the filter.  We're done.
//                    done = YES;
//                    break;
//                }
//                if (isdigit(originalChar)) {
//                    outputString[onOutput] = originalChar;
//                    onOriginal++;
//                    onFilter++;
//                    onOutput++;
//                } else {
//                    onOriginal++;
//                }
//                break;
//            default:
//                // Any other character will automatically be inserted for the user as they
//                // type (spaces, - etc..) or deleted as they delete if there are more
//                // numbers to come.
//                outputString[onOutput] = filterChar;
//                onOutput++;
//                onFilter++;
//                if (originalChar == filterChar)
//                    onOriginal++;
//                break;
//        }
//    }
//    outputString[onOutput] = '\0'; // Cap the output string
//    return [NSMutableString stringWithUTF8String:outputString];
//}

-(void)enteredOTPWithOtp:(NSString *)otp{
    [self validateOTP:otp];
}

-(BOOL)shouldBecomeFirstResponderForOTPWithOtpTextFieldIndex:(NSInteger)index{
    return YES;
}

-(BOOL)hasEnteredAllOTPWithHasEnteredAll:(BOOL)hasEnteredAll{
    return hasEnteredAll;
}


/**
 El numero de esta pantalla en formato internacional. Un solo sitio que lo arma.

 Al recuperar contraseña el numero llega ya con su prefijo en self.phoneNum; en registro y
 entrada vienen por separado el prefijo del pais y lo que tecleo el usuario.

 QUITAR LO QUE NO ES DIGITO NO BASTA, y era lo unico que se hacia aqui. En Venezuela -- el
 90% del volumen -- se marca `0424 645 4012`, con el cero de troncal delante: pegado daba
 `+5804246454012`, trece digitos que pasan cualquier comprobacion de forma y no son ningun
 telefono. El rele de verificacion lo rechaza con `numero_invalido` en cuanto ve que el
 nacional empieza por cero, asi que el venezolano no podia pasar de esta pantalla.

 La regla vive en ConrraTelefonoE164, no aqui: la misma clase, la misma tabla de casos y la
 misma respuesta que en Android, y se puede probar sin arrancar la app.

 Devuelve cadena vacia y no un numero a medias cuando no hay numero: quien llama ya
 comprueba el largo antes de mandar nada.
 */
-(NSString *)telefonoE164 {
    if (self.isRestPassword) {
        // Aqui el prefijo ya viene dentro, asi que no hay nada que pegar: se parte el
        // numero en codigo de pais y resto no, se pasa entero como nacional y
        // ConrraTelefonoE164 se queda con los digitos.
        NSString *crudo = isEmpty(self.phoneNum);
        NSString *digitos = [ConrraTelefonoE164 soloDigitos:crudo];
        return digitos.length > 0 ? [@"+" stringByAppendingString:digitos] : @"";
    }
    NSString *nacional = [NSString stringWithFormat:@"%@", [_usersigmUpDict objectForKey:P_MOBILE]];
    NSString *armado = [ConrraTelefonoE164 de:isEmpty(self.countryDialCode) nacional:isEmpty(nacional)];
    return armado.length > 0 ? armado : @"";
}

/**
 ¿Esta apagado el paso de verificacion?

 Dos fuentes, y las dos significan "no hay codigo que esperar": la constante `otp_off` del
 backend, que se enciende y se apaga a mano, y `is_test` para las cuentas de prueba.

 VALE PARA CUALQUIER METODO, y eso es el arreglo. Esto solo lo miraba el camino viejo, asi
 que con Firebase la constante no apagaba nada: el usuario se quedaba delante de unas
 casillas que nadie iba a rellenar, porque no se habia pedido ningun codigo.
 */
-(BOOL)otpApagado {
    ConstantModel *constantes = [ConstantModel getConstantsObject];
    BOOL esDePrueba = NO;
    if (self.usersigmUpDict) {
        esDePrueba = [[self.usersigmUpDict objectForKey:@"is_test"] boolValue];
    }
    return constantes.otp_off || esDePrueba;
}

/// Lo que pasa cuando el numero queda verificado, venga del camino que venga.
-(void)continuarTrasVerificar {
    [self stopResendTimer];
    if(self.isRestPassword){
        [self updatePasswordScreen];
    }else if(self.isFormLogin){
        [self loginUser:self.usersigmUpDict];
    }
    else{
        [self registerMeWithInfo];
    }
}

-(void) validateOTP:(NSString *) string{
    [self.view endEditing:YES];

    /*
     Apagado: se pasa sin comprobar nada, con el metodo que sea. Va ANTES de la rama de
     Firebase a proposito -- es el mismo orden que puso Android --, porque si no, con
     otp_off encendido el usuario se queda encerrado: no se pidio codigo, luego no hay
     codigo que teclear ni que validar.
     */
    if ([self otpApagado]) {
        [self continuarTrasVerificar];
        return;
    }

    /*
     Lo verifica el servidor: Didit o Firebase, da igual cual. ConrraVerificacionTelefono
     reparte. Antes esto preguntaba `conFirebase` y por tanto, al pasar el predeterminado a
     Didit, se habria ido por el camino viejo: comparar el codigo con uno que el app se
     invento, que es exactamente lo que se quito.
     */
    if ([ConrraVerificacionTelefono loVerificaElServidor]) {
        NSString *escrito = [string stringByReplacingOccurrencesOfString:@" " withString:@""];
        if (escrito.length == 0) {
            [self showWarningWithMessgae:[LanguageHelper getStringWithKey:@"k_r12_s6_invalid_otp"]];
            return;
        }
        NSString *espera = [LanguageHelper getStringWithKey:@"k_r30_s3_loading"];
        [UtilityClass setLH:NO wt:espera];
        [ConrraVerificacionTelefono comprobar:escrito cuandoTermine:^(BOOL verificado, NSString *error) {
            [UtilityClass setLH:YES wt:espera];
            if (!verificado) {
                // El motivo viene traducido de ConrraVerificacionTelefono: distingue
                // "codigo equivocado" de "falta la clave de APNs", que no es culpa suya.
                [self showWarningWithMessgae:error.length > 0 ? error
                    : [LanguageHelper getStringWithKey:@"k_r12_s6_invalid_otp"]];
                return;
            }
            [self continuarTrasVerificar];
        }];
        return;
    }

    // ---- El camino viejo: la app compara el codigo consigo misma. ----
    NSString *trimmed = [string stringByReplacingOccurrencesOfString:@" " withString:@""];
    int trimmedInr = [trimmed intValue];
    BOOL isTestAccount=NO;
    if(self.usersigmUpDict){
        isTestAccount=[[self.usersigmUpDict objectForKey:@"is_test"]boolValue];
    }
    if ( trimmedInr == _verificationCode||(trimmedInr==9009&&isTestAccount==YES))  {
        [self continuarTrasVerificar];
    } else {
        [self showWarningWithMessgae:[LanguageHelper getStringWithKey:@"k_r12_s6_invalid_otp"]];
        return;
    }
}


/**
 El codigo que hay escrito en las casillas, sean cuatro o seis.

 El boton Validar lo armaba leyendo d1 d2 d3 d4 y pegandolos con %@%@%@%@. Con seis
 casillas eso manda CUATRO digitos a Firebase, que los rechaza siempre: el usuario teclea
 bien el codigo, le dice que es invalido, y no hay forma de que funcione tecleando mejor.
 */
-(NSString *)codigoEnLasCasillas {
    NSMutableString *codigo = [NSMutableString string];
    for (NSInteger i = 1; i <= [ConrraVerificacionTelefono casillas]; i++) {
        OTPTextField *casilla = (OTPTextField *)[self.txtOtpView viewWithTag:i];
        [codigo appendString:casilla.text ?: @""];
    }
    return codigo;
}

-(void)setEmptyOTP{
    // En bucle y no cuatro lineas: con Firebase hay seis casillas, y dejar dos sin vaciar
    // es que el codigo viejo se queda escrito debajo del nuevo.
    for (NSInteger i = 1; i <= [ConrraVerificacionTelefono casillas]; i++) {
        [((OTPTextField *)[self.txtOtpView viewWithTag:i]) setText:@""];
    }
}


-(void) loginUser:(NSDictionary *)dict{
    [UtilityClass setLH:NO wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
    [GIC mkwerwu:USER_PH_SIGNIN
                                    d:dict
              cb:^(id results, NSError *error) {
        if ([[[results objectForKey:P_STATUS] uppercaseString] isEqualToString:@"OK"]) {
            NSObject * userDictObject=[results objectForKey:@"response"];
            if([userDictObject isKindOfClass:[NSDictionary class]]){
                NSDictionary *userDict =(NSDictionary *)userDictObject;
                BOOL isVerified=[[userDict objectForKey:P_DRIVER_VERIFIED] boolValue];
                isVerified =YES;
                if([[userDict objectForKey:P_DRIVER_AVAILAILITY] boolValue]==NO){
                    defaults_set_object(is_availability_on, @"0");
                }else{
                    defaults_set_object(is_availability_on, @"1");
                }
                if (isVerified==YES) {
                    defaults_set_object(P_API_KEY, [[results objectForKey:P_RESPONSE] objectForKey:P_API_KEY]);
                    defaults_set_object(P_USER_DICT, [results objectForKey:P_RESPONSE]);
                    defaults_set_object(P_USER_DICT_LOGGED, [results objectForKey:P_RESPONSE]);
                    NSString *language=[[results objectForKey:P_RESPONSE] objectForKey:@"u_language"];
                    if(language!=nil&&language.length>0)   {
                        NSString * location=[[LanguageHelper sharedInstance] getlcidForCode:language];
                        [[NSUserDefaults standardUserDefaults] setObject:[NSArray arrayWithObjects:location, nil] forKey:@"AppleLanguages"];
                        [[NSUserDefaults standardUserDefaults] setObject:language forKey:@"language"];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                        [[LanguageHelper  sharedInstance] setCunnrentLanguage:language];
                        [[LanguageHelper  sharedInstance] configureLanguage];
                    }
                    [self updateDeviceToken];
                }
                else{
                    [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
                    [self showWarningWithMessgae:[LanguageHelper getStringWithKey:@"k_d_msg_un_verified" defaultValue:@""]];
                }
            }
            
        }else if([[[results objectForKey:P_STATUS] uppercaseString] isEqualToString:@"ERROR"]){
            [self hidePleaseWaitLoader];
            NSObject * userDictObject=[results objectForKey:@"response"];
            if([userDictObject isKindOfClass:[NSDictionary class]]){
                NSDictionary *userDict =(NSDictionary *)userDictObject;
                
                [self showAlertWithMessgae:[userDict objectForKey:@"message"]];
                [self showAlertWithOk:@"" message:[userDict objectForKey:@"message"] handler:^(UIAlertAction * _Nonnull action) {
                    [self.navigationController popViewControllerAnimated:YES];
                }];
            }else{
                [self showAlertWithOk:@"" message:[results objectForKey:@"message"] handler:^(UIAlertAction * _Nonnull action) {
                    [self.navigationController popViewControllerAnimated:YES];
                }];
            }
        }
        else{
            [self hidePleaseWaitLoader];
            NSDictionary *dictError=[Utilities handleErrorDict:error ];
            [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
            if(dictError!=nil){
                [self showWarningWithMessgae:[dictError objectForKey:@"message"]];
            }else{
                [Utilities  handleError:error viewController:self defaultMessage:@""];
            }
        }
    }];
}




-(void)updateDeviceToken{
    NSString * deviceToken=[[NSUserDefaults standardUserDefaults] objectForKey:P_DEVICE_TOKEN];
    NSDictionary * dictUser= defaults_object(P_USER_DICT_LOGGED);
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{
        P_USER_ID   :[NSString stringWithFormat:@"%d",[[dictUser objectForKey:P_USER_ID]intValue]],
        @"fire_password":default_fire_password
    }];
    if (deviceToken) {
        [dict addEntriesFromDictionary:@{
            P_DEVICE_TOKEN :deviceToken,
            P_DEVICE_TYPE   :IOS,
        }];
    }
    [dict setObject:@"1" forKey:@"is_user_login"];
    [dict addEntriesFromDictionary:[Utilities appBuildVersionAndOsInfo]];
    [GIC mkwu:UPDATE_USER_PROFILE
                  d:dict
      isa:NO
           cb:^(id results, NSError *error) {
        [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
        if ([[[results objectForKey:P_STATUS] uppercaseString] isEqualToString:@"OK"]) {
            defaults_set_object(P_USER_DICT, [results objectForKey:P_RESPONSE]);
            defaults_set_object(P_USER_DICT_LOGGED, [results objectForKey:P_RESPONSE]);
        }
        [self navigateHome];
    }];
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
//    NSString *trimmed = [textField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
//    int trimmedInr = [trimmed intValue];    if ( trimmedInr == _verificationCode||trimmedInr==9009)  {
//        [self stopResendTimer];
//        if(self.isRestPassword)
//        {
//            [self updatePasswordScreen];
//        }else{
//            [self registerMeWithInfo];
//        }
//    } else {
//        [self showWarningWithMessgae:[LanguageHelper getStringWithKey:@"k_r12_s6_invalid_otp"]];
//        return;
//    }
}



-(void) updatePasswordScreen{
    ChangePasswordViewController *vc = (ChangePasswordViewController *)[StoryBoardUtiles viewContollerWithIdentifier:StoryBoardUtiles.CHANGE_PASSWORD_VC name:StoryBoardUtiles.STORYBOARD_SIGNUP];
    vc.dictUserRestPassword = self.usersigmUpDict;
    vc.isRestPassword=YES;
    NSMutableArray *arr=[self.navigationController.viewControllers mutableCopy];
    [arr removeObjectAtIndex:arr.count-1];
    [arr addObject:vc];
//    [self.navigationController setViewControllers:arr animated:YES];
     [self presentViewController:vc animated:YES completion:nil];
//    [self.navigationController pushViewController: vc animated:YES];
}



/**
 Pide el codigo. Se llama al abrir la pantalla y al pulsar reenviar.
 */
-(void)verifyMobileNo{
    /*
     EL CODIGO NO LO GENERA LA APP.

     Se lo pide al proveedor de turno -- hoy Didit, antes Firebase --, que lo manda y lo
     comprueba. El app no lo conoce nunca, y por eso esto prueba de verdad que quien se
     registra tiene ese numero. Cual de los dos sea se decide en un solo sitio:
     ConrraVerificacionTelefono.
     */
    if ([ConrraVerificacionTelefono loVerificaElServidor] && ![self otpApagado]) {
        NSString *telefono = [self telefonoE164];
        if (telefono.length < 8) {
            [self showAlertWithMessgae:[LanguageHelper getStringWithKey:@"k_17_s3_phone_number_does_not_exists"]];
            return;
        }
        NSString *espera = [LanguageHelper getStringWithKey:@"k_r30_s3_loading"];
        [UtilityClass setLH:NO wt:espera];
        [ConrraVerificacionTelefono enviarA:telefono cuandoTermine:^(BOOL enviado, NSString *error) {
            [UtilityClass setLH:YES wt:espera];
            if (!enviado) {
                [self showAlertWithMessgae:error.length > 0 ? error
                    : [LanguageHelper getStringWithKey:@"k_17_s3_phone_number_does_not_exists"]];
                return;
            }
            self->isTimeSet = NO;
            self.scrollView.contentOffset = CGPointMake(0, 50);
            [self setOtp];
            [self setEmptyOTP];
            [self startResendTimer];
        }];
        return;
    }

    smsCode = [Utilities getRandomNumberBetween:1000 to:9999];
    ConstantModel *consModel=[ConstantModel getConstantsObject];
    BOOL isTestAccount=NO;
    if(self.usersigmUpDict){
        isTestAccount=[[self.usersigmUpDict objectForKey:@"is_test"]boolValue];
    }
    if(consModel.otp_off||isTestAccount){
        [self startResendTimer];
        [self setOtp];
        [self setEmptyOTP];
        isTimeSet=NO;
        self.scrollView.contentOffset=CGPointMake(0, 50);
        return ;
    }
    NSDictionary *dict;
    if(self.isRestPassword)
    {
        NSString *otpMessage =[Utilities formatOtpMessageWithOtp:smsCode isResetPassword:YES];
        dict = @{
            @"msg": otpMessage,
            @"ph" : self.phoneNum,
        };
    }else{
        NSString *otpMessage =[Utilities formatOtpMessageWithOtp:smsCode isResetPassword:NO];
        NSString *phoneNum = [NSString stringWithFormat:@"%@",[_usersigmUpDict objectForKey:P_MOBILE]];
        phoneNum = [NSString stringWithFormat:@"%@%@",self.countryDialCode,phoneNum];
        dict = @{
            @"msg": otpMessage,
            @"ph" : phoneNum
        };
    }
    
    
    [UtilityClass setLH:NO wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
    [GIC mk:enabledEncy?BASE_URL_OTP:[Utilities encodedOTPUrl:dict] to:@"" d:enabledEncy?dict:nil isa:NO
                    cb:^(id results, NSError *error) {
        [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
        // El backend devuelve status = "OK" tambien cuando Twilio falla, asi que hay que
        // mirar code. Ver +[Utilities seEnvioElSms:].
        if (![Utilities seEnvioElSms:results]) {
            [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
            [self showAlertWithMessgae:[LanguageHelper getStringWithKey:@"k_17_s3_phone_number_does_not_exists"]];
            return ;
        }

        // EL CODIGO QUE SE COMPARA TIENE QUE SER EL QUE SE ACABA DE MANDAR.
        //
        // verifyMobileNo genera un smsCode nuevo en cada reenvio, pero validateOTP compara
        // contra self.verificationCode, que solo se asignaba UNA vez: cuando la pantalla
        // anterior empujaba esta (vc.verificationCode = smsCode, en los tres llamadores).
        // Sin esta linea el codigo reenviado no podia validar nunca y el unico que servia
        // era el primero. Justo quien no recibia el primer SMS -- que es quien pulsa
        // reenviar -- se quedaba encerrado.
        self.verificationCode = self->smsCode;

        self->isTimeSet=NO;
        self.scrollView.contentOffset=CGPointMake(0, 50);
        [self setOtp];
        [self setEmptyOTP];
        [self startResendTimer];
    }];
}




-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
//    self->frameOrignal=self.scrollView.frame;
    [[IQKeyboardManager sharedManager] setEnable:NO];
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:NO];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[IQKeyboardManager sharedManager] setEnable:YES];
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark - Keyboard Notifications
-(void)keyboardWillShow:(NSNotification *)notification {
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    int height = keyboardSize.height;
    if (@available(iOS 11.0, *)) {
        UIWindow *window = UIApplication.sharedApplication.windows.firstObject;
        CGFloat topPadding = window.safeAreaInsets.top;
        height-=topPadding;
//        CGFloat bottomPadding = window.safeAreaInsets.bottom;
    }
    self.bottomScroll.constant=height*-1;
    self.scrollView.contentOffset=CGPointMake(0, 50);
    [UIView animateWithDuration:.3 animations:^{
        [self.view layoutIfNeeded];
    }];
//    if(!isTimeSet){
//        isTimeSet=YES;
//        double delayInSeconds = 0.6;
//        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
//        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//            [UIView animateWithDuration:0.3 animations:^{
//                CGRect rect=self->frameOrignal;
//                rect.size.height=rect.size.height-height;
//                self.scrollView.contentOffset=CGPointMake(0, height);
//                self.scrollView.frame=rect;
//                self->isTimeSet=NO;
//            }];
//        });
//    }
}


-(void)keyboardWillHide:(NSNotification *)notification {
    [UIView animateWithDuration:0.3 animations:^{
        self.scrollView.frame=self->frameOrignal;
        self.scrollView.contentOffset=CGPointMake(0, 50);
    }];
}

- (void)handleTapOnLabel:(UITapGestureRecognizer *)gesture{
    UITextView *textView = (UITextView *)gesture.view;
    //    int tag = (int)[textView tag];
    NSLayoutManager *layoutManager = textView.layoutManager;
    CGPoint location = [gesture locationInView:textView];
    location.x -= textView.textContainerInset.left;
    location.y -= textView.textContainerInset.top;
    NSUInteger characterIndex;
    characterIndex = [layoutManager characterIndexForPoint:location
                                           inTextContainer:textView.textContainer
                  fractionOfDistanceBetweenInsertionPoints:NULL];
    
    if (characterIndex < textView.textStorage.length) {
        NSRange range;
        NSDictionary *attributes =
        [textView.textStorage attributesAtIndex:characterIndex
                                 effectiveRange:&range];
        if ([attributes objectForKey:@"object"]) {
            [self verifyMobileNo];
        }else if ([attributes objectForKey:@"object2"]) {
            [self openMailComposer];
//
        }else if ([attributes objectForKey:@"object3"]) {
            AboutUsViewController *viewController=[[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"AboutUsViewController"];
            viewController.isCustomUrl = YES;
            viewController.customUrl=[SettingsModel getSettignsObject].privacyUrl
            ;
            viewController.customTitle=[LanguageHelper getStringWithKey:@"k_2_s4_privacy"];
            [self.navigationController pushViewController:viewController animated:YES];
        } else if ([attributes objectForKey:@"object_terms"]) {
            AboutUsViewController *viewController=[[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"AboutUsViewController"];
            viewController.isCustomUrl = YES;
            viewController.customUrl=[SettingsModel getSettignsObject].tnc;
            viewController.customTitle=[LanguageHelper getStringWithKey:@"k_6_s12_terms_and_conditions_title"];
            [self.navigationController pushViewController:viewController animated:YES];
        }
    }
}

//-(void)openMailComposer{
    // placeholder — email contact not configured
//
//if([MFMailComposeViewController canSendMail]) {
//    MFMailComposeViewController *mailCont = [[MFMailComposeViewController alloc] init];
//    mailCont.mailComposeDelegate = self;        // Required to invoke mailComposeController when send
//    ConstantModel *  constantModel =[ConstantModel getConstantsObject];;
//    NSString * supportEmail = isEmpty(constantModel.support_email);
//    NSMutableArray  *arrayEmails=[[NSMutableArray alloc]  init];
//    [arrayEmails addObject:supportEmail];
//    [mailCont setToRecipients:arrayEmails];
//    /*
//     [mailCont setSubject:@""];
//     NSMutableString *body = [NSMutableString string];
//     NSString *url = [NSString stringWithFormat:@"http://maps.google.com?q=%f,%f",[APP_DELEGATE currLoc].latitude,[APP_DELEGATE currLoc].longitude];
//     [body appendString:[NSString stringWithFormat:@"Please help, I am in danger and need assistance.Follow my location,<a href=\"%@\">Click Here</a> \n ",url]];
//     [mailCont setMessageBody:body isHTML:YES];
//     */
//    [self presentViewController:mailCont animated:YES completion:nil];
//}
//else
//{
//    [UtilityClass swa:@"Whoops!" m:[LanguageHelper getStringWithKey:@"k_65_s4_config_mail"] cbt:[LanguageHelper getStringWithKey:@"k_18_s4_Ok"] obt:nil vc:self];
//}
//}
//- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
//if(error!= nil)
//{
//    [self showAlert:@"Whoops!" message:[NSString stringWithFormat:@" ERROR %@",error]];
//    return;
//}
//[controller dismissViewControllerAnimated:YES completion:nil];
//}

#pragma mark - New UI Layout

- (void)setupOTPScreenLayout {
    self.topView.hidden    = YES;
    self.scrollView.hidden = YES;

    self.view.backgroundColor = [UIColor blackColor];
    UIImage *bgImage = [UIImage imageNamed:@"login_bg"];
    if (bgImage) {
        UIImageView *bgIV = [[UIImageView alloc] initWithImage:bgImage];
        bgIV.translatesAutoresizingMaskIntoConstraints = NO;
        bgIV.contentMode = UIViewContentModeScaleAspectFill;
        bgIV.clipsToBounds = YES;
        [self.view insertSubview:bgIV atIndex:0];
        [NSLayoutConstraint activateConstraints:@[
            [bgIV.topAnchor      constraintEqualToAnchor:self.view.topAnchor],
            [bgIV.leadingAnchor  constraintEqualToAnchor:self.view.leadingAnchor],
            [bgIV.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
            [bgIV.bottomAnchor   constraintEqualToAnchor:self.view.bottomAnchor],
        ]];
        UIView *overlay = [[UIView alloc] init];
        overlay.translatesAutoresizingMaskIntoConstraints = NO;
        overlay.backgroundColor = [UIColor colorWithWhite:0 alpha:0.40f];
        [self.view insertSubview:overlay atIndex:1];
        [NSLayoutConstraint activateConstraints:@[
            [overlay.topAnchor      constraintEqualToAnchor:self.view.topAnchor],
            [overlay.leadingAnchor  constraintEqualToAnchor:self.view.leadingAnchor],
            [overlay.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
            [overlay.bottomAnchor   constraintEqualToAnchor:self.view.bottomAnchor],
        ]];
    } else {
        UIView *bgView = [[UIView alloc] init];
        bgView.translatesAutoresizingMaskIntoConstraints = NO;
        bgView.backgroundColor = [UIColor colorWithWhite:0.12f alpha:1];
        [self.view insertSubview:bgView atIndex:0];
        [NSLayoutConstraint activateConstraints:@[
            [bgView.topAnchor      constraintEqualToAnchor:self.view.topAnchor],
            [bgView.leadingAnchor  constraintEqualToAnchor:self.view.leadingAnchor],
            [bgView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
            [bgView.bottomAnchor   constraintEqualToAnchor:self.view.bottomAnchor],
        ]];
    }

    UIView *cardView = [[UIView alloc] init];
    cardView.translatesAutoresizingMaskIntoConstraints = NO;
    cardView.backgroundColor = [UIColor whiteColor];
    cardView.layer.cornerRadius = 24;
    cardView.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
    cardView.clipsToBounds = YES;
    [self.view addSubview:cardView];
    [NSLayoutConstraint activateConstraints:@[
        [cardView.leadingAnchor  constraintEqualToAnchor:self.view.leadingAnchor],
        [cardView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [cardView.bottomAnchor   constraintEqualToAnchor:self.view.bottomAnchor],
        [cardView.heightAnchor   constraintEqualToAnchor:self.view.heightAnchor multiplier:0.90f],
    ]];

    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    backBtn.translatesAutoresizingMaskIntoConstraints = NO;
    backBtn.backgroundColor = [UIColor colorWithRed:240/255.0f green:240/255.0f blue:240/255.0f alpha:1.0f];
    backBtn.layer.cornerRadius = 18;
    backBtn.clipsToBounds = YES;
    UIImage *backIcon = [UIImage systemImageNamed:@"chevron.left"];
    if (backIcon) {
        [backBtn setImage:[backIcon imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    } else {
        [backBtn setTitle:@"‹" forState:UIControlStateNormal];
        backBtn.titleLabel.font = [UIFont systemFontOfSize:20];
    }
    backBtn.tintColor = [UIColor colorWithWhite:0.25f alpha:1];
    [backBtn addTarget:self action:@selector(btnBack:) forControlEvents:UIControlEventTouchUpInside];
    [cardView addSubview:backBtn];

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    titleLabel.text = [Utilities stringByStrippingHTML:[LanguageHelper getStringWithKey:@"k_18_s4_plz_enter_otp" defaultValue:@"Código OTP"]];
    titleLabel.font = FONTS_NOTO_BOLD(20);
    if (!titleLabel.font) titleLabel.font = [UIFont boldSystemFontOfSize:20];
    titleLabel.textColor = [UIColor colorWithWhite:0.1f alpha:1];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [cardView addSubview:titleLabel];

    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    closeBtn.translatesAutoresizingMaskIntoConstraints = NO;
    UIImage *xIcon = [UIImage systemImageNamed:@"xmark"];
    if (xIcon) {
        [closeBtn setImage:[xIcon imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    } else {
        [closeBtn setTitle:@"✕" forState:UIControlStateNormal];
    }
    closeBtn.tintColor = [UIColor colorWithWhite:0.25f alpha:1];
    [closeBtn addTarget:self action:@selector(btnBack:) forControlEvents:UIControlEventTouchUpInside];
    [cardView addSubview:closeBtn];

    [NSLayoutConstraint activateConstraints:@[
        [backBtn.topAnchor      constraintEqualToAnchor:cardView.topAnchor constant:20],
        [backBtn.leadingAnchor  constraintEqualToAnchor:cardView.leadingAnchor constant:20],
        [backBtn.widthAnchor    constraintEqualToConstant:36],
        [backBtn.heightAnchor   constraintEqualToConstant:36],

        [titleLabel.centerXAnchor constraintEqualToAnchor:cardView.centerXAnchor],
        [titleLabel.centerYAnchor constraintEqualToAnchor:backBtn.centerYAnchor],

        [closeBtn.centerYAnchor  constraintEqualToAnchor:backBtn.centerYAnchor],
        [closeBtn.trailingAnchor constraintEqualToAnchor:cardView.trailingAnchor constant:-20],
        [closeBtn.widthAnchor    constraintEqualToConstant:32],
        [closeBtn.heightAnchor   constraintEqualToConstant:32],
    ]];

    UILabel *subtitleLabel = [[UILabel alloc] init];
    subtitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    NSString *langCode = [LanguageHelper sharedInstance].cunnrentLanguage ?: @"";
    BOOL isES = [langCode hasPrefix:@"es"];
    NSString *esDefault = @"📩 Te hemos enviado un código de acceso vía SMS para validar tu teléfono";
    NSString *enDefault = @"📩 We have sent you an access code via SMS to validate your phone";
    subtitleLabel.text = [Utilities stringByStrippingHTML:[LanguageHelper getStringWithKey:@"k_18_s4_plz_ask_psngr_fr_otp"
                                             defaultValue:(isES ? esDefault : enDefault)]];
    subtitleLabel.font = FONTS_NOTO_REGULAR(16);
    if (!subtitleLabel.font) subtitleLabel.font = [UIFont systemFontOfSize:16];
    subtitleLabel.textColor = [UIColor colorWithWhite:0.2f alpha:1];
    subtitleLabel.numberOfLines = 0;
    [cardView addSubview:subtitleLabel];
    [NSLayoutConstraint activateConstraints:@[
        [subtitleLabel.topAnchor      constraintEqualToAnchor:backBtn.bottomAnchor constant:24],
        [subtitleLabel.leadingAnchor  constraintEqualToAnchor:cardView.leadingAnchor  constant:20],
        [subtitleLabel.trailingAnchor constraintEqualToAnchor:cardView.trailingAnchor constant:-20],
    ]];

    /*
     EL ANCHO SE CALCULA, NO SE ESCRIBE.

     El diseño eran cuatro casillas de 68 con 12 de hueco: 308 puntos de ancho total. Con
     Firebase son SEIS, y seis de 68 son 468: no caben ni en un telefono grande, asi que
     Auto Layout los sacaria del borde o los apretaria sin control.

     Se mantiene el ancho total y se reparte entre las casillas que haya. Con cuatro sale
     exactamente el diseño de antes (68 y 12); con seis, 44 y 8.
     */
    const NSInteger otpCasillas = [ConrraVerificacionTelefono casillas];
    const CGFloat otpFieldH = 52;
    const CGFloat otpAnchoDisponible = 308;
    const CGFloat otpSepSpace = (otpCasillas > 4) ? 8 : 12;
    const CGFloat otpFieldW = floorf((otpAnchoDisponible - (otpCasillas - 1) * otpSepSpace) / otpCasillas);
    const CGFloat otpTotalW = otpCasillas * otpFieldW + (otpCasillas - 1) * otpSepSpace;

    [self.txtOtpView removeFromSuperview];
    [cardView addSubview:self.txtOtpView];

    self.txtOtpView.fieldSize              = otpFieldH;      // height
    self.txtOtpView.fieldWidth             = otpFieldW;      // width (non-square)
    self.txtOtpView.separatorSpace         = otpSepSpace;
    self.txtOtpView.fieldBorderWidth       = 0;
    self.txtOtpView.defaultBackgroundColor = [UIColor colorWithRed:243/255.0f green:243/255.0f blue:243/255.0f alpha:1.0f];
    self.txtOtpView.filledBackgroundColor  = [UIColor colorWithRed:243/255.0f green:243/255.0f blue:243/255.0f alpha:1.0f];
    self.txtOtpView.displayType            = DisplayTypeRoundedCorner;
    // Set frame with correct size so initializeUI positions fields properly;
    // layoutSubviews override will re-position again once Auto Layout finalises bounds
    self.txtOtpView.translatesAutoresizingMaskIntoConstraints = YES;
    self.txtOtpView.frame = CGRectMake(0, 0, otpTotalW, otpFieldH);
    [self.txtOtpView initializeUI];
    self.txtOtpView.translatesAutoresizingMaskIntoConstraints = NO;

    [NSLayoutConstraint activateConstraints:@[
        [self.txtOtpView.topAnchor     constraintEqualToAnchor:subtitleLabel.bottomAnchor constant:32],
        [self.txtOtpView.centerXAnchor constraintEqualToAnchor:cardView.centerXAnchor],
        [self.txtOtpView.widthAnchor   constraintEqualToConstant:otpTotalW],
        [self.txtOtpView.heightAnchor  constraintEqualToConstant:otpFieldH],
    ]];

    UILabel *timerLbl = [[UILabel alloc] init];
    timerLbl.translatesAutoresizingMaskIntoConstraints = NO;
    timerLbl.textAlignment = NSTextAlignmentCenter;
    timerLbl.numberOfLines = 0;
    timerLbl.font = FONTS_NOTO_REGULAR(14);
    if (!timerLbl.font) timerLbl.font = [UIFont systemFontOfSize:14];
    timerLbl.textColor = [UIColor colorWithWhite:0.45f alpha:1];
    [cardView addSubview:timerLbl];
    self.lblResendOtpTimer = timerLbl;
    [NSLayoutConstraint activateConstraints:@[
        [timerLbl.topAnchor      constraintEqualToAnchor:self.txtOtpView.bottomAnchor constant:16],
        [timerLbl.leadingAnchor  constraintEqualToAnchor:cardView.leadingAnchor  constant:20],
        [timerLbl.trailingAnchor constraintEqualToAnchor:cardView.trailingAnchor constant:-20],
    ]];

    UIView *resendSection = [[UIView alloc] init];
    resendSection.translatesAutoresizingMaskIntoConstraints = NO;
    resendSection.hidden = YES;
    [cardView addSubview:resendSection];
    self.resendView = resendSection;

    UILabel *noRecibisteLabel = [[UILabel alloc] init];
    noRecibisteLabel.translatesAutoresizingMaskIntoConstraints = NO;
    noRecibisteLabel.text = [Utilities stringByStrippingHTML:[LanguageHelper getStringWithKey:@"k_2_s12_sms_contct"
                                                    defaultValue:@"No recibiste el código OTP?"]];
    noRecibisteLabel.textAlignment = NSTextAlignmentCenter;
    noRecibisteLabel.font = FONTS_NOTO_REGULAR(15);
    if (!noRecibisteLabel.font) noRecibisteLabel.font = [UIFont systemFontOfSize:15];
    noRecibisteLabel.textColor = [UIColor colorWithWhite:0.25f alpha:1];
    [resendSection addSubview:noRecibisteLabel];

    UIButton *resendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    resendBtn.translatesAutoresizingMaskIntoConstraints = NO;
    resendBtn.backgroundColor = [UIColor colorWithRed:254/255.0f green:243/255.0f blue:199/255.0f alpha:1.0f];
    resendBtn.layer.cornerRadius = 14;
    resendBtn.titleLabel.font = FONTS_NOTO_BOLD(17);
    if (!resendBtn.titleLabel.font) resendBtn.titleLabel.font = [UIFont boldSystemFontOfSize:17];
    [resendBtn setTitle:[Utilities stringByStrippingHTML:[LanguageHelper getStringWithKey:@"k_7_s12_resend_code" defaultValue:@"Reenviar Código"]]
                 forState:UIControlStateNormal];
    [resendBtn setTitleColor:[UIColor colorWithWhite:0.15f alpha:1] forState:UIControlStateNormal];
    [resendBtn addTarget:self action:@selector(btnResend:) forControlEvents:UIControlEventTouchUpInside];
    [resendSection addSubview:resendBtn];

    [NSLayoutConstraint activateConstraints:@[
        [noRecibisteLabel.topAnchor      constraintEqualToAnchor:resendSection.topAnchor],
        [noRecibisteLabel.leadingAnchor  constraintEqualToAnchor:resendSection.leadingAnchor],
        [noRecibisteLabel.trailingAnchor constraintEqualToAnchor:resendSection.trailingAnchor],

        [resendBtn.topAnchor      constraintEqualToAnchor:noRecibisteLabel.bottomAnchor constant:12],
        [resendBtn.leadingAnchor  constraintEqualToAnchor:resendSection.leadingAnchor],
        [resendBtn.trailingAnchor constraintEqualToAnchor:resendSection.trailingAnchor],
        [resendBtn.heightAnchor   constraintEqualToConstant:56],
        [resendBtn.bottomAnchor   constraintEqualToAnchor:resendSection.bottomAnchor],

        [resendSection.topAnchor      constraintEqualToAnchor:timerLbl.bottomAnchor constant:16],
        [resendSection.leadingAnchor  constraintEqualToAnchor:cardView.leadingAnchor  constant:20],
        [resendSection.trailingAnchor constraintEqualToAnchor:cardView.trailingAnchor constant:-20],
    ]];

    UIButton *validateBtn = [ConrraButton buttonWithStyle:ConrraButtonStylePrimary];
    validateBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [validateBtn setTitle:[Utilities stringByStrippingHTML:[LanguageHelper getStringWithKey:@"k_18_s4_otp_apply" defaultValue:@"Validar"]]
                 forState:UIControlStateNormal];
    [validateBtn addTarget:self action:@selector(onValidateButtonTap:) forControlEvents:UIControlEventTouchUpInside];
    [cardView addSubview:validateBtn];
    [NSLayoutConstraint activateConstraints:@[
        [validateBtn.leadingAnchor  constraintEqualToAnchor:cardView.leadingAnchor  constant:20],
        [validateBtn.trailingAnchor constraintEqualToAnchor:cardView.trailingAnchor constant:-20],
        [validateBtn.heightAnchor   constraintEqualToConstant:56],
        [validateBtn.bottomAnchor   constraintEqualToAnchor:cardView.bottomAnchor   constant:-20],
    ]];
}

- (IBAction)onValidateButtonTap:(id)sender {
    [self validateOTP:[self codigoEnLasCasillas]];
}

@end
