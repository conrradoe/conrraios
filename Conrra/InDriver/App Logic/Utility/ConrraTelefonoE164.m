//
//  ConrraTelefonoE164.m
//  Conrra
//

#import "ConrraTelefonoE164.h"

/*
 LAS DOS CLAVES, A MANO Y NO POR EL MACRO, y es a proposito.

 Son P_U_MOBILE y P_MOBILE de WebCallConstants.h. Importar esa cabecera arrastra Keys.h,
 LanguageHelper.h y GIKit entera, y entonces esta clase deja de poder compilarse sola -- que
 es justo lo que permite probarla con clang suelto, sin Xcode y sin simulador
 (pruebas/PruebaTelefonoE164.m).

 Perder la unica prueba ejecutable del proyecto para ahorrar dos cadenas seria un mal cambio.
 Y estas dos no son un detalle de implementacion que se mueva: son los nombres de columna del
 backend, los mismos que usa Android.
 */
static NSString *const kClaveTelefonoPasajero  = @"u_phone";
static NSString *const kClaveTelefonoConductor = @"d_phone";

/** Mas corto que esto no es un telefono en ningun sitio. */
static const NSInteger kMinimoNacional = 6;

/** E.164 topa en 15 digitos contando el codigo de pais. */
static const NSInteger kMaximoTotal = 15;

@implementation ConrraTelefonoE164

+ (NSString *)de:(NSString *)codigoPais nacional:(NSString *)nacional {
    NSString *pais = [self soloDigitos:codigoPais];
    NSString *numero = [self sinCeroDeTroncal:[self soloDigitos:nacional]];

    if (pais.length < 1 || pais.length > 3) {
        return nil;
    }
    if ([pais characterAtIndex:0] == '0') {
        return nil;                                  // ningun pais empieza por cero
    }
    if ((NSInteger)numero.length < kMinimoNacional) {
        return nil;
    }
    if ((NSInteger)(pais.length + numero.length) > kMaximoTotal) {
        return nil;
    }
    return [NSString stringWithFormat:@"+%@%@", pais, numero];
}

+ (NSString *)soloDigitos:(NSString *)texto {
    if (![texto isKindOfClass:[NSString class]]) {
        return @"";
    }
    NSMutableString *digitos = [NSMutableString stringWithCapacity:texto.length];
    for (NSUInteger i = 0; i < texto.length; i++) {
        unichar c = [texto characterAtIndex:i];
        if (c >= '0' && c <= '9') {
            [digitos appendFormat:@"%C", c];
        }
    }
    return digitos;
}

+ (NSString *)nacionalDe:(NSDictionary *)usuario {
    if (![usuario isKindOfClass:[NSDictionary class]]) {
        return @"";
    }
    for (NSString *clave in @[kClaveTelefonoPasajero, kClaveTelefonoConductor]) {
        id valor = [usuario objectForKey:clave];
        if ([valor isKindOfClass:[NSString class]] && [valor length] > 0) {
            return valor;
        }
        // Por si alguna respuesta del servidor lo manda como numero y no como texto.
        if ([valor isKindOfClass:[NSNumber class]]) {
            return [valor stringValue];
        }
    }
    return @"";
}

+ (NSString *)sinCeroDeTroncal:(NSString *)nacional {
    if (![nacional isKindOfClass:[NSString class]]) {
        return @"";
    }
    NSUInteger i = 0;
    while (i < nacional.length && [nacional characterAtIndex:i] == '0') {
        i++;
    }
    return [nacional substringFromIndex:i];
}

@end
