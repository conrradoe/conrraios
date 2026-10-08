//
//  ConrraPuertaVerificacion.m
//  Conrra
//

#import "ConrraPuertaVerificacion.h"

@implementation ConrraPuertaVerificacion

+ (BOOL)hayQueVerificarConPuerta:(BOOL)puertaEncendida
                       haySesion:(BOOL)haySesion
                    yaVerificado:(BOOL)yaVerificado
                      numeroE164:(NSString *)numeroE164 {
    if (!puertaEncendida) {
        return NO;      // el interruptor manda sobre todo lo demas
    }
    if (!haySesion) {
        return NO;      // sin sesion, el inicio de sesion ya pide el codigo
    }
    if (yaVerificado) {
        return NO;
    }
    // Sin numero NO se bloquea: ver seQuedaSinSalida.
    return numeroE164.length > 0;
}

+ (BOOL)seQuedaSinSalidaConPuerta:(BOOL)puertaEncendida
                        haySesion:(BOOL)haySesion
                     yaVerificado:(BOOL)yaVerificado
                       numeroE164:(NSString *)numeroE164 {
    return puertaEncendida && haySesion && !yaVerificado && numeroE164.length == 0;
}

+ (NSString *)claveDe:(NSString *)usuarioId {
    if (![usuarioId isKindOfClass:[NSString class]]) {
        return nil;
    }
    NSString *limpio = [usuarioId stringByTrimmingCharactersInSet:
                        [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (limpio.length == 0) {
        return nil;
    }
    /*
     El mismo nombre de clave que Android (verificacion_hecha_<id>), aunque cada plataforma
     guarde en su propio almacen y nunca se lean entre si. Vale para que al depurar un caso
     concreto se busque lo mismo en los dos sitios.
     */
    return [@"verificacion_hecha_" stringByAppendingString:limpio];
}

@end
