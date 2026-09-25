//
//  ConrraRadioDeReparto.m
//  Conrra
//

#import "ConrraRadioDeReparto.h"
#import "ConstantModel.h"
#import "TripModel.h"
#import "WebCallConstants.h"
#import "AppDelegate.h"
#import <GIKit/GIKit.h>

static const double kKmPorMilla = 1.609344;

/// Los mismos respaldos que usa Android al pedir la lista, para no ser mas estricto que ella.
static const double kRadioInmediatoPorDefecto  = 50.0;
static const double kRadioProgramadoPorDefecto = 100.0;

@implementation ConrraRadioDeReparto

/**
 Si el radio del panel esta escrito en kilometros.

 La unidad del radio es distance_paramiter, NO el city_dist_unit de la ciudad. Esto no es una
 suposicion: getDriverRadiusConstants lee las DOS claves en la misma consulta y las devuelve
 juntas, ['unit' => distance_paramiter, 'radius' => driver_radius]. Son un par: el numero y la
 unidad en la que ese numero esta escrito. Lo que rompe el par es el bloque `if ($cityID)` que
 viene despues y machaca 'unit' con el city_dist_unit de la ciudad, dejando el radio en una
 unidad y la medida en otra.

 Por defecto km. Suponer millas multiplicaria el tope por 1,6 y el filtro dejaria pasar de
 mas, que es justo lo que se viene a arreglar.
 */
+ (BOOL)elRadioEstaEnKm {
    NSString *unidad = [ConstantModel valorDeConstantePorClave:@"distance_paramiter"];
    if (![unidad isKindOfClass:[NSString class]] || unidad.length == 0) {
        return YES;
    }
    unidad = [unidad stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return [unidad caseInsensitiveCompare:@"mi"] != NSOrderedSame;
}

+ (double)topeEnKmProgramado:(BOOL)programado {
    double radio = 0;
    if (programado) {
        NSString *crudo = [ConstantModel valorDeConstantePorClave:@"rl_driver_radius"];
        radio = [[crudo stringByReplacingOccurrencesOfString:@"," withString:@"."] doubleValue];
    } else {
        radio = [ConstantModel getConstantsObject].constant_driver_radius;
    }
    if (radio <= 0) {
        radio = programado ? kRadioProgramadoPorDefecto : kRadioInmediatoPorDefecto;
    }
    // Aqui se mide siempre en km, asi que si el panel esta en millas hay que convertir.
    return [self elRadioEstaEnKm] ? radio : radio * kKmPorMilla;
}

+ (BOOL)viaje:(TripModel *)viaje dentroDelRadioDesde:(CLLocationCoordinate2D)origen {
    if (viaje == nil) {
        return YES;
    }
    // Sin posicion no hay nada que medir.
    if (!CLLocationCoordinate2DIsValid(origen) ||
        (origen.latitude == 0 && origen.longitude == 0)) {
        return YES;
    }

    NSString *latTexto = isEmpty(viaje.trip_pick_lat);
    NSString *lngTexto = isEmpty(viaje.trip_pick_long);
    if (latTexto.length == 0 || lngTexto.length == 0) {
        return YES;
    }
    double lat = [latTexto doubleValue];
    double lng = [lngTexto doubleValue];
    if (lat == 0 && lng == 0) {
        return YES;
    }

    CLLocation *desde = [[CLLocation alloc] initWithLatitude:origen.latitude longitude:origen.longitude];
    CLLocation *hasta = [[CLLocation alloc] initWithLatitude:lat longitude:lng];
    double km = [desde distanceFromLocation:hasta] / 1000.0;
    double tope = [self topeEnKmProgramado:viaje.is_ride_later];
    BOOL dentro = (km <= tope);

    /*
     Una linea por solicitud evaluada, con TODO lo que hace falta para decidir por que entro
     un viaje: la distancia en LINEA RECTA -- que es la que mide el servidor, no la de
     carretera que se pinta en la fila --, el tope aplicado, si es reservado (esos usan
     rl_driver_radius) y los valores crudos de las constantes. Con esto se cierra el
     diagnostico sin entrar a la base de datos.
     */
    if (!dentro) {
        NSLog(@"[RadioDeReparto] viaje %@ recta=%.2f km, tope=%.2f km, FUERA | reservado=%d "
              @"driver_radius=%@ rl_driver_radius=%@ distance_paramiter=%@ radio_en_km=%d",
              isEmpty(viaje.trip_Id), km, tope, viaje.is_ride_later,
              [ConstantModel valorDeConstantePorClave:@"driver_radius"],
              [ConstantModel valorDeConstantePorClave:@"rl_driver_radius"],
              [ConstantModel valorDeConstantePorClave:@"distance_paramiter"],
              [self elRadioEstaEnKm]);
    }
    return dentro;
}

+ (void)laSolicitud:(NSString *)tripId meritaAvisar:(void (^)(BOOL avisar))respuesta {
    if (respuesta == nil) {
        return;
    }
    void (^contestar)(BOOL) = ^(BOOL avisar) {
        if ([NSThread isMainThread]) {
            respuesta(avisar);
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{ respuesta(avisar); });
        }
    };

    NSString *id_ = [isEmpty(tripId) stringByTrimmingCharactersInSet:
                     [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (id_.length == 0) {
        contestar(YES);
        return;
    }
    CLLocationCoordinate2D aqui = [APP_DELEGATE currLoc].coordinate;
    if (!CLLocationCoordinate2DIsValid(aqui) || (aqui.latitude == 0 && aqui.longitude == 0)) {
        contestar(YES);
        return;
    }

    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:id_ forKey:@"trip_id"];
    [[[GIKCommon alloc] init] mkwu:TRIP_GETTRIP d:dict isa:NO cb:^(id results, NSError *error) {
        if (error != nil ||
            ![[[results objectForKey:P_STATUS] uppercaseString] isEqualToString:@"OK"] ||
            ![[results objectForKey:P_RESPONSE] isKindOfClass:[NSArray class]]) {
            contestar(YES);
            return;
        }
        NSArray *viajes = [results objectForKey:P_RESPONSE];
        for (id crudo in viajes) {
            if (![crudo isKindOfClass:[NSDictionary class]]) {
                continue;
            }
            TripModel *viaje = [[TripModel alloc] initItemWithDict:crudo];
            if ([isEmpty(viaje.trip_Id) caseInsensitiveCompare:id_] != NSOrderedSame) {
                continue;
            }
            contestar([self viaje:viaje dentroDelRadioDesde:aqui]);
            return;
        }
        // El viaje no venia en la respuesta: no se ha podido comprobar, asi que suena.
        contestar(YES);
    }];
}

+ (NSArray *)conductores:(NSArray *)conductores
      dentroDeLaRecogida:(CLLocationCoordinate2D)recogida
              programado:(BOOL)programado {
    if (![conductores isKindOfClass:[NSArray class]] || conductores.count == 0) {
        return conductores ?: @[];
    }
    if (!CLLocationCoordinate2DIsValid(recogida) ||
        (recogida.latitude == 0 && recogida.longitude == 0)) {
        return conductores;
    }

    double tope = [self topeEnKmProgramado:programado];
    CLLocation *desde = [[CLLocation alloc] initWithLatitude:recogida.latitude
                                                    longitude:recogida.longitude];
    NSMutableArray *dentro = [[NSMutableArray alloc] init];
    for (id elemento in conductores) {
        if (![elemento respondsToSelector:@selector(lat)] ||
            ![elemento respondsToSelector:@selector(lng)]) {
            [dentro addObject:elemento];
            continue;
        }
        double lat = [[elemento valueForKey:@"lat"] doubleValue];
        double lng = [[elemento valueForKey:@"lng"] doubleValue];
        if (lat == 0 && lng == 0) {
            // Sin posicion no se puede medir: se deja pasar, como todo lo demas aqui.
            [dentro addObject:elemento];
            continue;
        }
        CLLocation *hasta = [[CLLocation alloc] initWithLatitude:lat longitude:lng];
        double km = [desde distanceFromLocation:hasta] / 1000.0;
        if (km <= tope) {
            [dentro addObject:elemento];
        } else {
            NSLog(@"[RadioDeReparto] conductor %@ a %.2f km de la recogida, tope %.2f km: NO se le avisa",
                  [elemento valueForKey:@"driverId"], km, tope);
        }
    }
    return dentro;
}

+ (NSArray *)filtrar:(NSArray *)viajes desde:(CLLocationCoordinate2D)origen {
    if (![viajes isKindOfClass:[NSArray class]] || viajes.count == 0) {
        return viajes ?: @[];
    }
    NSMutableArray *dentro = [[NSMutableArray alloc] init];
    for (id elemento in viajes) {
        if (![elemento isKindOfClass:[TripModel class]]) {
            // Lo que no se sabe leer se deja pasar: este filtro solo quita, nunca inventa.
            [dentro addObject:elemento];
            continue;
        }
        if ([self viaje:(TripModel *)elemento dentroDelRadioDesde:origen]) {
            [dentro addObject:elemento];
        }
    }
    return dentro;
}

@end
