//
//  ConrraDestinoDePlan.h
//  Conrra
//
//  Equivalente de com.conrra.riderapp.planes.DestinoDePlan (Android).
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 El destino que la seccion Planes deja preparado para la pantalla de pedir viaje.

 POR QUE UN BUZON ESTATICO Y NO UNA PROPIEDAD QUE SE PASA. Al pulsar IR hay que volver a
 UHomeViewController, que casi siempre ya existe en la pila: no se crea de nuevo, asi que
 no pasa por viewDidLoad. Un buzon que se lee en viewWillAppear funciona tanto si la
 pantalla se rehace como si solo se desapila.

 SE CONSUME UNA SOLA VEZ, a proposito. Si se quedara guardado, cada vuelta a la pantalla
 principal -- cerrar el menu lateral, volver de la pantalla de pago -- reescribiria el
 destino y le pisaria al pasajero el que hubiera puesto a mano despues.
 */
@interface ConrraDestinoDePlan : NSObject

/** Deja el destino preparado. Lo llama la seccion Planes justo antes de salir. */
+ (void)dejarSitio:(NSString *)sitio
               lat:(CLLocationDegrees)lat
               lng:(CLLocationDegrees)lng;

+ (BOOL)hayPendiente;

+ (nullable NSString *)sitio;
+ (CLLocationDegrees)lat;
+ (CLLocationDegrees)lng;

/** Vacia el buzon. Hay que llamarlo SIEMPRE que se lea, se use o no. */
+ (void)consumir;

@end

NS_ASSUME_NONNULL_END
