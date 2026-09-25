//
//  ConrraSolicitudesPersistentes.m
//  Conrra
//

#import "ConrraSolicitudesPersistentes.h"
#import "TripModel.h"
#import <GIKit/GIKit.h>

/// Los mismos cinco ciclos que aguanta Android, que con su sondeo son alrededor de un minuto.
static const NSInteger kCiclosQueAguanta = 5;

@implementation ConrraSolicitudesPersistentes

/** Cuantos ciclos lleva ausente cada solicitud. La clave es el trip_id. */
+ (NSMutableDictionary<NSString *, NSNumber *> *)ausencias {
    static NSMutableDictionary *ausencias = nil;
    static dispatch_once_t unaVez;
    dispatch_once(&unaVez, ^{
        ausencias = [[NSMutableDictionary alloc] init];
    });
    return ausencias;
}

+ (NSString *)idDe:(id)elemento {
    if (![elemento isKindOfClass:[TripModel class]]) {
        return @"";
    }
    return [isEmpty(((TripModel *)elemento).trip_Id) stringByTrimmingCharactersInSet:
            [NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

+ (void)olvidar:(NSString *)tripId {
    NSString *id_ = [isEmpty(tripId) stringByTrimmingCharactersInSet:
                     [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (id_.length > 0) {
        [[self ausencias] removeObjectForKey:id_];
    }
}

+ (void)olvidarTodas {
    [[self ausencias] removeAllObjects];
}

+ (NSArray *)fusionar:(NSArray *)delServidor conPantalla:(NSArray *)enPantalla {
    NSArray *deFuera = [delServidor isKindOfClass:[NSArray class]] ? delServidor : @[];
    NSArray *deAntes = [enPantalla isKindOfClass:[NSArray class]] ? enPantalla : @[];
    if (deAntes.count == 0) {
        // Nada que aguantar: la primera respuesta manda tal cual.
        return deFuera;
    }

    NSMutableSet *idsDelServidor = [[NSMutableSet alloc] init];
    for (id elemento in deFuera) {
        NSString *id_ = [self idDe:elemento];
        if (id_.length > 0) {
            [idsDelServidor addObject:id_];
            // Volvio a aparecer: se le borra la cuenta, para que la proxima ausencia empiece
            // de cero. Sin esto, una solicitud que parpadea varias veces agotaria sus ciclos
            // aunque el servidor la siga dando por buena.
            [[self ausencias] removeObjectForKey:id_];
        }
    }

    NSMutableArray *resultado = [NSMutableArray arrayWithArray:deFuera];
    for (id elemento in deAntes) {
        NSString *id_ = [self idDe:elemento];
        if (id_.length == 0 || [idsDelServidor containsObject:id_]) {
            continue;
        }
        NSInteger ciclos = [[[self ausencias] objectForKey:id_] integerValue] + 1;
        if (ciclos <= kCiclosQueAguanta) {
            [[self ausencias] setObject:@(ciclos) forKey:id_];
            [resultado addObject:elemento];
            NSLog(@"[Solicitudes] la %@ no vino en esta respuesta; se aguanta (%ld de %ld)",
                  id_, (long)ciclos, (long)kCiclosQueAguanta);
        } else {
            [[self ausencias] removeObjectForKey:id_];
            NSLog(@"[Solicitudes] la %@ lleva %ld ciclos sin aparecer: se quita",
                  id_, (long)kCiclosQueAguanta);
        }
    }
    return resultado;
}

@end
