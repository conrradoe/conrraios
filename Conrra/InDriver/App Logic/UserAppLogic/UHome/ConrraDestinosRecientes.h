//
//  ConrraDestinosRecientes.h
//  Conrra
//
//  Equivalente de saveToHistory / initRecentDestinations de MainScreenActivity (Android).
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN

/** Un sitio al que el pasajero ya fue. */
@interface ConrraDestinoReciente : NSObject
@property (nonatomic, copy) NSString *direccion;
@property (nonatomic, assign) double lat;
@property (nonatomic, assign) double lng;
@end


/**
 Los ultimos sitios a los que fue el pasajero.

 MISMO ALMACEN Y MISMAS REGLAS QUE ANDROID, para que la lista se lea igual en las dos
 aplicaciones: se guarda una lista de {address, lat, lng}, sin repetidos por direccion, el
 ultimo primero, y como mucho cinco.

 SE GUARDA AL PEDIR EL VIAJE, no al elegir el destino en el buscador. Android lo llama justo
 antes de callTripApi y tiene sentido: la lista se llama "ultimos destinos", no "ultimas
 cosas que escribiste". Un sitio que se tecleo y luego se descarto no fue a ninguna parte.

 VIVE EN EL TELEFONO, no en el servidor. Es la misma decision de Android, y trae una
 consecuencia que conviene saber: cambiar de telefono empieza la lista de cero.
 */
@interface ConrraDestinosRecientes : NSObject

/// Los guardados, del mas reciente al mas antiguo. Nunca nil.
+ (NSArray<ConrraDestinoReciente *> *)todos;

/// Guarda uno. Si ya estaba esa direccion, sube al principio en vez de duplicarse.
+ (void)guardarDireccion:(NSString *)direccion
              coordenada:(CLLocationCoordinate2D)coordenada;

/// Quita uno de la lista.
+ (void)olvidarDireccion:(NSString *)direccion;

@end

NS_ASSUME_NONNULL_END
