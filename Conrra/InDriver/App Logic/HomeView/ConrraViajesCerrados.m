//
//  ConrraViajesCerrados.m
//  Conrra
//

#import "ConrraViajesCerrados.h"
#import <GIKit/GIKit.h>

static NSString *const kClave = @"conrra_viajes_cerrados";
static const NSUInteger kCuantosSeGuardan = 20;

@implementation ConrraViajesCerrados

+ (NSString *)limpio:(NSString *)tripId {
    if (![tripId isKindOfClass:[NSString class]]) {
        return @"";
    }
    return [tripId stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

+ (NSArray<NSString *> *)lista {
    id guardado = defaults_object(kClave);
    return [guardado isKindOfClass:[NSArray class]] ? guardado : @[];
}

+ (void)cerrar:(NSString *)tripId {
    NSString *id_ = [self limpio:tripId];
    if (id_.length == 0) {
        return;
    }
    NSMutableArray *lista = [NSMutableArray arrayWithArray:[self lista]];
    [lista removeObject:id_];
    // El mas reciente primero, para que el recorte se lleve siempre los mas viejos.
    [lista insertObject:id_ atIndex:0];
    while (lista.count > kCuantosSeGuardan) {
        [lista removeLastObject];
    }
    defaults_set_object(kClave, lista);
    NSLog(@"[ViajesCerrados] el conductor termino con el viaje %@", id_);
}

+ (BOOL)yaSeCerro:(NSString *)tripId {
    NSString *id_ = [self limpio:tripId];
    if (id_.length == 0) {
        return NO;
    }
    return [[self lista] containsObject:id_];
}

@end
