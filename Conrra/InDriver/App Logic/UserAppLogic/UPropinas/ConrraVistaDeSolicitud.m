//
//  ConrraVistaDeSolicitud.m
//  Conrra
//

#import "ConrraVistaDeSolicitud.h"
#import "RecargaEstilo.h"
#import "Keys.h"

/**
 Las solicitudes que este conductor ya aviso.

 Vive en memoria y no en los ajustes a proposito: lo que evita es contar diez veces la misma
 fila en la misma sesion, y una solicitud dura cinco minutos. Guardarlo en disco seria una lista
 que crece para siempre y que habria que limpiar.
 */
static NSMutableSet<NSString *> *gYaAvisadas = nil;

@implementation ConrraVistaDeSolicitud

+ (void)avisarQueLaVioElConductor:(NSString *)tripId {
    NSString *id_ = [self limpio:tripId];
    if (id_.length == 0) {
        return;
    }
    // Sincronizado porque la lista de solicitudes se refresca desde varios sitios y dos celdas
    // podrian preguntar a la vez: sin esto, las dos pasarian el filtro y el aviso saldria doble.
    @synchronized ([ConrraVistaDeSolicitud class]) {
        if (gYaAvisadas == nil) {
            gYaAvisadas = [NSMutableSet set];
        }
        if ([gYaAvisadas containsObject:id_]) {
            return;
        }
        [gYaAvisadas addObject:id_];
    }
    [RecargaEstilo enviarA:URL_TAXI_VISTA campos:@{ @"trip_id" : id_ }
                completado:^(NSDictionary *json, NSError *error) {
        // Al log y nada mas: el conductor no tiene que saber que este apunte existe.
        NSLog(@"[VistaSolicitud] avisado %@: %@", id_, json != nil ? @"ok" : @"FALLO");
    }];
}

+ (void)cuantosLaVieron:(NSString *)tripId cuandoLlegue:(void (^)(NSInteger))bloque {
    NSString *id_ = [self limpio:tripId];
    if (id_.length == 0 || bloque == nil) {
        return;
    }
    [RecargaEstilo enviarA:URL_TAXI_VISTAS campos:@{ @"trip_id" : id_ }
                completado:^(NSDictionary *json, NSError *error) {
        id respuesta = json[@"response"];
        if (![respuesta isKindOfClass:[NSDictionary class]]) {
            return;
        }
        id vistas = respuesta[@"vistas"];
        if (vistas == nil || vistas == [NSNull null]) {
            /*
             Sin el campo no se llama al bloque, y eso es deliberado: la pantalla se queda con
             el ultimo numero que tenia. Pasar un cero cuando el servidor no dijo nada seria
             decirle al pasajero que nadie la ha visto, que es una afirmacion distinta de "no lo
             se" y mucho peor -- con ella cancelaria un viaje que si estaban mirando.
             */
            return;
        }
        NSInteger n = [[NSString stringWithFormat:@"%@", vistas] integerValue];
        if ([NSThread isMainThread]) {
            bloque(n);
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{ bloque(n); });
        }
    }];
}

+ (NSString *)limpio:(NSString *)texto {
    if (![texto isKindOfClass:[NSString class]]) {
        return @"";
    }
    NSString *s = [texto stringByTrimmingCharactersInSet:
                   [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return ([s caseInsensitiveCompare:@"null"] == NSOrderedSame || [s isEqualToString:@"0"])
        ? @"" : s;
}

@end
