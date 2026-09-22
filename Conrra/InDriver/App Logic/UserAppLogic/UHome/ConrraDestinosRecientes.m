//
//  ConrraDestinosRecientes.m
//  Conrra
//

#import "ConrraDestinosRecientes.h"

/// La misma clave que usa Android para su SharedPreferences.
static NSString *const kClaveDeLaLista = @"recent_destinations";
/// Cuantos se recuerdan. Android corta en cinco.
static const NSUInteger kCuantosSeGuardan = 5;

@implementation ConrraDestinoReciente
@end


@implementation ConrraDestinosRecientes

+ (NSString *)limpia:(id)valor {
    if (![valor isKindOfClass:[NSString class]]) {
        return @"";
    }
    return [(NSString *)valor stringByTrimmingCharactersInSet:
            [NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

+ (NSArray<ConrraDestinoReciente *> *)todos {
    id crudo = [[NSUserDefaults standardUserDefaults] objectForKey:kClaveDeLaLista];
    if (![crudo isKindOfClass:[NSArray class]]) {
        return @[];
    }
    NSMutableArray<ConrraDestinoReciente *> *salida = [[NSMutableArray alloc] init];
    for (id fila in (NSArray *)crudo) {
        if (![fila isKindOfClass:[NSDictionary class]]) {
            continue;
        }
        NSDictionary *dict = (NSDictionary *)fila;
        NSString *direccion = [self limpia:[dict objectForKey:@"address"]];
        if (direccion.length == 0) {
            continue;
        }
        ConrraDestinoReciente *destino = [[ConrraDestinoReciente alloc] init];
        destino.direccion = direccion;
        destino.lat = [[dict objectForKey:@"lat"] doubleValue];
        destino.lng = [[dict objectForKey:@"lng"] doubleValue];
        [salida addObject:destino];
    }
    return salida;
}

+ (void)escribir:(NSArray<ConrraDestinoReciente *> *)lista {
    NSMutableArray *crudo = [[NSMutableArray alloc] init];
    for (ConrraDestinoReciente *destino in lista) {
        // Las mismas claves que Android, por si algun dia esto se sincroniza.
        [crudo addObject:@{ @"address": destino.direccion ?: @"",
                            @"lat": @(destino.lat),
                            @"lng": @(destino.lng) }];
    }
    [[NSUserDefaults standardUserDefaults] setObject:crudo forKey:kClaveDeLaLista];
}

+ (void)guardarDireccion:(NSString *)direccion coordenada:(CLLocationCoordinate2D)coordenada {
    NSString *limpia = [self limpia:direccion];
    if (limpia.length == 0) {
        return;
    }
    // Sin coordenada el destino no sirve para nada: al tocarlo no se podria trazar la ruta.
    if (!CLLocationCoordinate2DIsValid(coordenada) ||
        (coordenada.latitude == 0 && coordenada.longitude == 0)) {
        return;
    }

    NSMutableArray<ConrraDestinoReciente *> *lista =
        [NSMutableArray arrayWithArray:[self todos]];

    // Sin repetidos: si ya estaba, se quita de donde estuviera y sube al principio. Asi la
    // lista es de sitios distintos y no cinco veces el mismo, que es lo que pasaria con
    // quien va a diario al mismo trabajo.
    NSMutableArray<ConrraDestinoReciente *> *aQuitar = [[NSMutableArray alloc] init];
    for (ConrraDestinoReciente *destino in lista) {
        if ([destino.direccion caseInsensitiveCompare:limpia] == NSOrderedSame) {
            [aQuitar addObject:destino];
        }
    }
    [lista removeObjectsInArray:aQuitar];

    ConrraDestinoReciente *nuevo = [[ConrraDestinoReciente alloc] init];
    nuevo.direccion = limpia;
    nuevo.lat = coordenada.latitude;
    nuevo.lng = coordenada.longitude;
    [lista insertObject:nuevo atIndex:0];

    while (lista.count > kCuantosSeGuardan) {
        [lista removeLastObject];
    }
    [self escribir:lista];
}

+ (void)olvidarDireccion:(NSString *)direccion {
    NSString *limpia = [self limpia:direccion];
    if (limpia.length == 0) {
        return;
    }
    NSMutableArray<ConrraDestinoReciente *> *lista =
        [NSMutableArray arrayWithArray:[self todos]];
    NSMutableArray<ConrraDestinoReciente *> *aQuitar = [[NSMutableArray alloc] init];
    for (ConrraDestinoReciente *destino in lista) {
        if ([destino.direccion caseInsensitiveCompare:limpia] == NSOrderedSame) {
            [aQuitar addObject:destino];
        }
    }
    if (aQuitar.count == 0) {
        return;
    }
    [lista removeObjectsInArray:aQuitar];
    [self escribir:lista];
}

@end
