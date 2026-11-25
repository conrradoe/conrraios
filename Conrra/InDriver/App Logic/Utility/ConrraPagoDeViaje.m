//
//  ConrraPagoDeViaje.m
//  Conrra
//

#import "ConrraPagoDeViaje.h"

/*
 Los codigos van aqui y no se escriben a mano en ningun otro sitio. Antes estaban repartidos
 como literales -- @"Cash" clavado en TripTransactionManager, HIRE_ME_WALLET_PAY en la pantalla
 del pasajero, rangeOfString:@"Wallet" en dos tarjetas -- y cada copia podia decidir distinto.
 */
static NSString *const kBilletera = @"Wallet";
static NSString *const kEfectivo  = @"Cash";

@implementation ConrraPagoDeViaje

+ (NSString *)billetera {
    return kBilletera;
}

+ (NSString *)efectivo {
    return kEfectivo;
}

/**
 El modo de pago tal y como se puede comparar: sin espacios y sin los "null" de texto.

 El servidor devuelve el modo como cadena, y por ahi llegan tres cosas que no son un modo: nil,
 la cadena vacia y el texto "null" -- que es lo que sale de formatear un nil con %@ y es la
 forma mas facil de que una comparacion diga "no es billetera" por el motivo equivocado.
 */
+ (NSString *)limpio:(NSString *)modoDePago {
    if (![modoDePago isKindOfClass:[NSString class]]) {
        return @"";
    }
    NSString *s = [modoDePago stringByTrimmingCharactersInSet:
                   [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return [s caseInsensitiveCompare:@"null"] == NSOrderedSame ? @"" : s;
}

+ (BOOL)esBilletera:(NSString *)modoDePago {
    return [[self limpio:modoDePago] caseInsensitiveCompare:kBilletera] == NSOrderedSame;
}

+ (NSString *)metodoNoBilletera:(NSString *)modoDePago {
    NSString *m = [self limpio:modoDePago];
    if (m.length == 0 || [m caseInsensitiveCompare:kBilletera] == NSOrderedSame) {
        return kEfectivo;
    }
    return m;
}

@end
