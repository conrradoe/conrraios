//
//  ConrraPagoPreferido.m
//  Conrra
//

#import "ConrraPagoPreferido.h"
#import "WebCallConstants.h"
#import <GIKit/GIKit.h>

static NSString *const kClaveModo    = @"conrra_pago_preferido_modo_";
static NSString *const kClaveTarjeta = @"conrra_pago_preferido_tarjeta_";
static NSString *const kClaveVisible = @"conrra_pago_preferido_visible_";

@implementation ConrraPagoPreferido

#pragma mark - La cuenta

+ (NSDictionary *)cuenta {
    NSDictionary *dict = defaults_object(P_USER_DICT_LOGGED);
    if (![dict isKindOfClass:[NSDictionary class]]) {
        dict = defaults_object(P_USER_DICT);
    }
    return [dict isKindOfClass:[NSDictionary class]] ? dict : @{};
}

+ (NSString *)texto:(id)valor {
    if (valor == nil || valor == [NSNull null]) {
        return @"";
    }
    NSString *t = [NSString stringWithFormat:@"%@", valor];
    t = [t stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return [t caseInsensitiveCompare:@"null"] == NSOrderedSame ? @"" : t;
}

/// "" cuando no hay sesion: sin usuario no hay preferencia que recordar.
+ (NSString *)idUsuario {
    return [self texto:[[self cuenta] objectForKey:P_USER_ID]];
}

#pragma mark - Guardar

+ (void)recordarModo:(NSString *)modo tarjeta:(NSString *)pmId visible:(NSString *)visible {
    NSString *limpio = [self texto:modo];
    NSString *uid = [self idUsuario];
    if (limpio.length == 0 || uid.length == 0) {
        return;
    }
    defaults_set_object(([kClaveModo stringByAppendingString:uid]), limpio);
    defaults_set_object(([kClaveTarjeta stringByAppendingString:uid]), pmId ?: @"");
    defaults_set_object(([kClaveVisible stringByAppendingString:uid]), visible ?: @"");
    [self avisarAlServidor:limpio];
}

#pragma mark - Leer

+ (NSString *)modo {
    NSString *uid = [self idUsuario];
    if (uid.length > 0) {
        NSString *local = [self texto:defaults_object([kClaveModo stringByAppendingString:uid])];
        if (local.length > 0) {
            return local;
        }
    }
    // La semilla del backend, para quien estrena telefono.
    return [self texto:[[self cuenta] objectForKey:P_USER_DEFAULT_PAY_MODE]];
}

+ (NSString *)tarjeta {
    NSString *uid = [self idUsuario];
    if (uid.length == 0) {
        return nil;
    }
    NSString *v = [self texto:defaults_object([kClaveTarjeta stringByAppendingString:uid])];
    return v.length > 0 ? v : nil;
}

+ (NSString *)tarjetaVisible {
    NSString *uid = [self idUsuario];
    if (uid.length == 0) {
        return nil;
    }
    NSString *v = [self texto:defaults_object([kClaveVisible stringByAppendingString:uid])];
    return v.length > 0 ? v : nil;
}

/**
 El nombre del modo, traducido al numero que usa HomePaymentViewModel.

 La tabla vive aqui y no en la pantalla para que el nombre guardado -- que es lo que entiende
 el servidor -- y el numero -- que es un detalle de ese selector -- no se desincronicen.

 Card cae en el 2, que es lo que ya hace onPaymentIntentSelected. Y si el modo guardado fuera
 Card pero no quedara el identificador de la tarjeta, no se restaura: enseñar "tarjeta" sin
 saber cual seria mandar al pasajero a un pago que no se puede cobrar.
 */
+ (int)modoParaElSelectorOPorOmision:(int)porOmision {
    NSString *m = [self modo];
    if (m.length == 0) {
        return porOmision;
    }
    if ([m caseInsensitiveCompare:CASH_PAY] == NSOrderedSame) {
        return 0;
    }
    if ([m caseInsensitiveCompare:HIRE_ME_WALLET_PAY] == NSOrderedSame) {
        return 1;
    }
    if ([m caseInsensitiveCompare:PAGO_MOVIL_PAY] == NSOrderedSame) {
        return 2;
    }
    if ([m caseInsensitiveCompare:CARD] == NSOrderedSame) {
        return [self tarjeta] != nil ? 2 : porOmision;
    }
    return porOmision;
}

#pragma mark - El perfil

/**
 Sube el modo al perfil. Va sin bloquear y sin avisar de fallos a proposito: esto es una
 comodidad, no parte de pedir el viaje. Si no sube, la preferencia local sigue funcionando en
 este telefono y el intento se repetira en el viaje siguiente.
 */
+ (void)avisarAlServidor:(NSString *)modo {
    NSDictionary *cuenta = [self cuenta];
    NSString *uid    = [self texto:[cuenta objectForKey:P_USER_ID]];
    NSString *apiKey = [self texto:[cuenta objectForKey:P_API_KEY]];
    if (uid.length == 0 || apiKey.length == 0) {
        return;
    }
    // Ya esta asi arriba: no hace falta la llamada.
    if ([[self texto:[cuenta objectForKey:P_USER_DEFAULT_PAY_MODE]] isEqualToString:modo]) {
        return;
    }

    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{
        P_API_KEY               : apiKey,
        P_USER_ID               : uid,
        P_USER_DEFAULT_PAY_MODE : modo,
    }];
    [GIC mkwu:UPDATE_USER_PROFILE d:dict isa:NO cb:^(id results, NSError *error) {
        BOOL ok = [[[results objectForKey:P_STATUS] uppercaseString] isEqualToString:@"OK"];
        if (!ok) {
            NSLog(@"[PagoPreferido] no se pudo guardar u_pay_mode=%@ en el perfil: %@",
                  modo, error.localizedDescription);
            return;
        }
        /*
         Se refresca la copia local del usuario para que la proxima vez no se vuelva a mandar
         la misma actualizacion. Sin esto, cada viaje repetiria la llamada.
         */
        NSMutableDictionary *nueva = [NSMutableDictionary dictionaryWithDictionary:[self cuenta]];
        [nueva setObject:modo forKey:P_USER_DEFAULT_PAY_MODE];
        if ([defaults_object(P_USER_DICT_LOGGED) isKindOfClass:[NSDictionary class]]) {
            defaults_set_object(P_USER_DICT_LOGGED, nueva);
        } else {
            defaults_set_object(P_USER_DICT, nueva);
        }
    }];
}

@end
