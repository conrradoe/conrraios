//
//  ConrraTelefonoE164.m
//  Conrra
//

#import "ConrraTelefonoE164.h"

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
