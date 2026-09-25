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

 POR QUE HACE FALTA. El backend filtra en TripModel.php, getRevisedTrips():

     $distance = $this->distance(...);              // CoreModel::distance DEVUELVE MILLAS
     switch ($rl_miles['unit']) {
         case 'km': $distance = $this->distanceWebKM(...); break;   // solo aqui pasa a km
         case 'mi': break;
     }
     if ($distance <= $riderRadius)                 // el "miles" que manda el app

 La distancia solo se convierte a kilometros si la constante global distance_paramiter vale
 EXACTAMENTE "km". Con esa constante en "mi", vacia o ausente, un radio de 5 se compara
 contra millas: 5 millas son 8,05 km. De ahi que entren solicitudes muy por encima del tope
 que dice el panel.

 Y hay un segundo desajuste: esa llamada es getDriverRadiusConstants(0, 0), con cityID = 0,
 asi que nunca llega a leer el city_dist_unit de la ciudad. La unidad del filtro sale solo
 de la constante global, mientras que todo lo que el conductor ve en pantalla usa la unidad
 de su ciudad. Son dos ajustes distintos y nada obliga a que coincidan.

 Como el backend de produccion no se toca, el tope se vuelve a aplicar aqui, medido en la
 unidad que el conductor tiene delante. Este filtro solo puede QUITAR viajes que el servidor
 ya habia dado por buenos; nunca añade ninguno, asi que no puede ampliar el radio.

 FALLA HACIA ENSEÑAR: si no se puede medir -- sin GPS, sin coordenadas de recogida, sin
 ciudad -- el viaje pasa. Perder una solicitud buena le cuesta dinero al conductor; ver una
 de mas solo le molesta.
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

@end

NS_ASSUME_NONNULL_END
