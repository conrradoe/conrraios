//
//  ConrraRadioDeReparto.h
//  Conrra
//
//  Equivalente de com.conrra.driverapp.utils.RadioDeReparto (Android).
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@class TripModel;

NS_ASSUME_NONNULL_BEGIN

/**
 Vuelve a aplicar el tope de distancia sobre las solicitudes, ya en el telefono.

 POR QUE HACE FALTA. El radio y su unidad son un par que el backend lee de una sola consulta,
 en ConstantModel::getDriverRadiusConstants:

     SELECT * FROM constants WHERE ckey='distance_paramiter' OR ckey='driver_radius'
     -> ['unit' => distance_paramiter, 'radius' => driver_radius]

 El numero del panel esta escrito en la unidad de distance_paramiter. Hasta ahi bien. Pero esa
 misma funcion acaba con un bloque que rompe el par:

     if ($cityID) { $return['unit'] = <cities.city_dist_unit>; }   // el radio NO se convierte

 A partir de ahi 'radius' sigue en la unidad global y 'unit' dice la de la ciudad. Y quien
 llama decide cual de los dos desajustes se lleva, porque cada camino pasa un cityID distinto:

   - DriverModel::getNearByDriverList -> getDriverRadiusConstants($row['city_id'], ...)
     La unidad sale de la CIUDAD del conductor. Con la ciudad en 'mi' la distancia se queda en
     millas y se compara contra el radio global: un radio de 6,1 pensado en km se convierte de
     hecho en 6,1 millas, 9,8 km. Esta es la lista de cercanos del PASAJERO.

   - TripModel::getRevisedTrips -> getDriverRadiusConstants(0, 0)
     Con cityID = 0 el bloque no entra y la unidad si es la global. Esta es la lista de
     solicitudes del CONDUCTOR, y por eso esa si corta donde dice el panel.

 Los dos caminos leen el MISMO numero y no cortan a la misma distancia. Y hay un tercer caso
 peor: si city_dist_unit no es exactamente 'km' ni 'mi' -- vacia, 'Km', cualquier otra cosa --
 el switch no tiene rama, $partnerRadius se queda en $value['d_miles'] con $value SIN DEFINIR,
 o sea null, y `$distance <= null` no lo cumple nadie: la lista sale vacia.

 Como el backend de produccion no se toca, el tope se vuelve a aplicar aqui, midiendo el radio
 en la unidad en la que esta escrito: distance_paramiter. Este filtro solo puede QUITAR lo que
 el servidor ya habia dado por bueno; nunca añade nada, asi que no puede ampliar el radio.

 FALLA HACIA ENSEÑAR: si no se puede medir -- sin GPS, sin coordenadas -- pasa. Perder una
 solicitud buena le cuesta dinero al conductor; ver una de mas solo le molesta.
 */
@interface ConrraRadioDeReparto : NSObject

/**
 El tope de reparto, en kilometros.

 @param programado YES para un viaje reservado, que tiene su propio radio (rl_driver_radius)
 */
+ (double)topeEnKmProgramado:(BOOL)programado;

/**
 Si la recogida del viaje cae dentro del tope.

 @param origen desde donde se mide; debe ser el MISMO punto con el que se pidio la lista
 @return NO solo cuando se puede medir Y queda fuera
 */
+ (BOOL)viaje:(TripModel *)viaje dentroDelRadioDesde:(CLLocationCoordinate2D)origen;

/** Quita de la lista los viajes que quedan fuera del tope. */
+ (NSArray *)filtrar:(NSArray *)viajes desde:(CLLocationCoordinate2D)origen;

/**
 Los conductores que de verdad estan dentro del tope, medidos desde la recogida.

 Esto es para el lado del PASAJERO. El reparto de la solicitud no lo decide el servidor:
 tripapi/sendnotificationontripsave recibe los tokens ya elegidos y se limita a mandarles el
 push. Quien elige es esta app, con la lista de cercanos que le devolvio el servidor -- y esa
 lista viene con su propio filtro, que no siempre mide en la unidad que uno espera.

 @param conductores array de DriverModel
 @param recogida    el punto desde el que se pide el viaje
 @param programado  YES si el viaje es reservado
 */
+ (NSArray *)conductores:(NSArray *)conductores
       dentroDeLaRecogida:(CLLocationCoordinate2D)recogida
               programado:(BOOL)programado;

@end

NS_ASSUME_NONNULL_END
