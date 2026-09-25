//
//  ConrraRadioDeReparto.m
//  Conrra
//

#import "ConrraRadioDeReparto.h"
#import "ConstantModel.h"
#import "CityModel.h"
#import "TripModel.h"
#import "WebCallConstants.h"
#import <GIKit/GIKit.h>

static const double kKmPorMilla = 1.609344;

/// Los mismos respaldos que usa Android al pedir la lista, para no ser mas estricto que ella.
static const double kRadioInmediatoPorDefecto  = 50.0;
static const double kRadioProgramadoPorDefecto = 100.0;

@implementation ConrraRadioDeReparto

/** El diccionario del conductor que tiene la sesion abierta. */
+ (NSDictionary *)conductor {
    NSDictionary *dict = defaults_object(P_USER_DICT);
    return [dict isKindOfClass:[NSDictionary class]] ? dict : @{};
}

/**
 Si la ciudad del conductor mide en kilometros.

 Por defecto SI. Es lo que hace Android cuando no hay ciudad, y es lo prudente aqui: dar por
 supuestas millas multiplicaria el tope por 1,6 y el filtro dejaria pasar de mas, que es
 justo el problema que se viene a arreglar.
 */
+ (BOOL)laCiudadMideEnKm {
    id crudo = [[self conductor] objectForKey:P_CITY_ID];
    int idCiudad = [[NSString stringWithFormat:@"%@", crudo ?: @"0"] intValue];
    if (idCiudad <= 0) {
        return YES;
    }
    CityModel *ciudad = [CityModel getCityByCityId:idCiudad];
    NSString *unidad = ciudad.city_dist_unit;
    if (![unidad isKindOfClass:[NSString class]] || unidad.length == 0) {
        return YES;
    }
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
    // El numero del panel esta en la unidad de la ciudad. Aqui se mide en km, asi que si la
    // ciudad va en millas hay que convertirlo antes de comparar.
    return [self laCiudadMideEnKm] ? radio : radio * kKmPorMilla;
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
              @"driver_radius=%@ rl_driver_radius=%@ distance_paramiter=%@ ciudad_en_km=%d",
              isEmpty(viaje.trip_Id), km, tope, viaje.is_ride_later,
              [ConstantModel valorDeConstantePorClave:@"driver_radius"],
              [ConstantModel valorDeConstantePorClave:@"rl_driver_radius"],
              [ConstantModel valorDeConstantePorClave:@"distance_paramiter"],
              [self laCiudadMideEnKm]);
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
