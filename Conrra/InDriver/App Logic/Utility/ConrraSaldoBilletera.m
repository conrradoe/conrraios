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
        /*
         Con efectivo o Pago Movil se viaja aunque la billetera este en negativo: esos no
         dependen de este saldo, y bloquearlos aqui seria impedir viajes que SI se pueden
         pagar. Decision de Android del 2026-11-18.
         */
        return YES;
    }
    /*
     LA DEUDA SE MIRA ANTES QUE EL IMPORTE, y ese orden es el arreglo.

     Debajo estaba el escape de "importe desconocido": con cero o negativo se dejaba pasar,
     porque no saber cuanto cuesta no es razon para negar un viaje. Razonable por si solo, y
     mal colocado: un pasajero con la billetera en NEGATIVO y un importe que no se pudo leer
     se colaba a pagar con billetera. Un saldo negativo no alcanza para nada, ni para un
     importe cero ni para uno desconocido, asi que la deuda decide primero.
     */
    if ([self tieneDeuda]) {
        return NO;
    }
    // Ahora si: no saber el importe no bloquea. El servidor tiene su propia palabra.
    if (importe <= 0) {
        return YES;
    }
    return [self saldo] >= importe;
}

+ (BOOL)tieneDeuda {
    /*
     El margen no es decoracion. El saldo llega como texto y se convierte a float, y ahi un
     cero puede volver como -0.0000001: comparar con < 0 a secas convertiria en deudor a
     alguien que tiene exactamente cero. Medio centimo es mas pequeno que cualquier deuda
     real y mas grande que cualquier resto de la conversion. Mismo margen que Android.
     */
    return [self saldo] < -0.004f;
}

+ (NSString *)mensajeDeDeuda {
    NSString *mon = nil;
    NSString *cuanto = [Utilities formatAmountAndCurrency:-[self saldo] currency:mon];
    if (cuanto.length == 0) {
        cuanto = [NSString stringWithFormat:@"%.2f", -[self saldo]];
    }
    // Se dice CUANTO debe y QUE puede hacer: un "no puedes pagar asi" sin salida deja al
    // pasajero mirando la pantalla sin saber que le piden.
    return [NSString stringWithFormat:
            @"Tu billetera tiene un saldo negativo de %@, así que no puedes pagar este viaje "
            @"con billetera. Recarga o elige otro método de pago (efectivo o Pago Móvil).",
            cuanto];
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

    /*
     EN NEGATIVO NO SE DICE "TE FALTAN", se dice que DEBE.

     Con saldo negativo el texto de arriba sale raro -- "tienes -3,20" -- y sobre todo describe
     mal la situacion: no es que no llegue para este viaje, es que la billetera esta en deuda y
     no sirve para ninguno hasta recargar. Son dos problemas distintos y la salida tambien:
     ahi recargar no es opcional.
     */
    if ([self tieneDeuda]) {
        cuerpo = [self mensajeDeDeuda];
    }

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
