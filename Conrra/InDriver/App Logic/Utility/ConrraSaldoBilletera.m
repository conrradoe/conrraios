//
//  ConrraSaldoBilletera.m
//  Conrra
//

#import "ConrraSaldoBilletera.h"
#import "Utilities.h"
#import "LanguageHelper.h"
#import "WebCallConstants.h"
#import <GIKit/GIKit.h>

@implementation ConrraSaldoBilletera

+ (BOOL)esBilletera:(NSString *)modoDePago {
    if (![modoDePago isKindOfClass:[NSString class]]) {
        return NO;
    }
    NSString *limpio = [modoDePago stringByTrimmingCharactersInSet:
                        [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return [limpio caseInsensitiveCompare:HIRE_ME_WALLET_PAY] == NSOrderedSame;
}

/**
 El saldo del monedero de la cuenta que tiene la sesion abierta.

 Se mira primero el diccionario del que entro y despues el general, en ese orden, porque es
 el mismo relé que usa RecargaEstilo para pintar el saldo: las dos pantallas tienen que
 estar diciendo el mismo numero.
 */
+ (float)saldo {
    NSDictionary *dict = defaults_object(P_USER_DICT_LOGGED);
    if (![dict isKindOfClass:[NSDictionary class]]) {
        dict = defaults_object(P_USER_DICT);
    }
    if (![dict isKindOfClass:[NSDictionary class]]) {
        return 0;
    }
    id valor = [dict objectForKey:P_USER_WAlLET_AMOUNT];
    if (valor == nil || valor == [NSNull null]) {
        return 0;
    }
    return [[NSString stringWithFormat:@"%@", valor] floatValue];
}

+ (BOOL)alcanza:(NSString *)modoDePago importe:(float)importe {
    if (![self esBilletera:modoDePago]) {
        return YES;
    }
    // Un importe que no se pudo leer no se usa para bloquear: cero o negativo quiere decir
    // "no lo se", y negar el viaje por no saberlo seria peor que dejarlo pasar, porque el
    // servidor todavia tiene su propia palabra.
    if (importe <= 0) {
        return YES;
    }
    return [self saldo] >= importe;
}

+ (float)falta:(float)importe {
    float f = importe - [self saldo];
    return f > 0 ? f : 0;
}

+ (void)avisarEn:(UIViewController *)vc importe:(float)importe moneda:(NSString *)moneda {
    if (vc == nil || vc.presentedViewController != nil) {
        return;
    }
    NSString *mon = [moneda isKindOfClass:[NSString class]] ? moneda : @"";
    NSString *pedido = [Utilities formatAmountAndCurrency:importe currency:mon];
    NSString *tengo  = [Utilities formatAmountAndCurrency:[self saldo] currency:mon];
    if (pedido.length == 0) { pedido = [NSString stringWithFormat:@"%.2f", importe]; }
    if (tengo.length  == 0) { tengo  = [NSString stringWithFormat:@"%.2f", [self saldo]]; }

    /*
     El cuerpo se arma aqui y no sale del paquete de idioma a proposito: un texto traducible
     usado como formato revienta en cuanto una traduccion cambia el %@ por otro especificador
     -- stringWithFormat leeria un argumento que no existe --, y este mensaje lleva dos.
     El titulo si va por clave, que no tiene huecos.
     */
    NSString *cuerpo = [NSString stringWithFormat:
        @"Son %@ y en tu billetera tienes %@. Recarga o elige otro método de pago.",
        pedido, tengo];

    UIAlertController *d = [UIAlertController
        alertControllerWithTitle:[LanguageHelper getStringWithKey:@"k_s10_saldo_corto_titulo"
                                                     defaultValue:@"Saldo insuficiente"]
                         message:cuerpo
                  preferredStyle:UIAlertControllerStyleAlert];
    [d addAction:[UIAlertAction actionWithTitle:[LanguageHelper getStringWithKey:@"k_18_s4_Ok"
                                                                   defaultValue:@"Entendido"]
                                          style:UIAlertActionStyleDefault
                                        handler:nil]];
    [vc presentViewController:d animated:YES completion:nil];
}

@end
