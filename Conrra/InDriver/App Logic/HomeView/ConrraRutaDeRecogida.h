//
//  ConrraRutaDeRecogida.h
//  Conrra
//
//  Calco de com.conrra.driverapp.utils.RutaRecogida (Android).
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN

/// Se publica cuando llega una medida nueva. Quien pinta una distancia se suscribe y repinta.
extern NSString *const ConrraRutaDeRecogidaActualizada;

/** Una medida real de carretera. */
@interface ConrraMedidaDeRuta : NSObject
@property (nonatomic, assign) double km;
@property (nonatomic, assign) NSInteger minutos;
@end

/**
 Distancia y tiempo hasta un punto POR CARRETERA, con cache.

 POR QUE EXISTE. La app medía la recogida en LINEA RECTA y el viaje por CARRETERA, las dos con
 la misma etiqueta "km". En ciudad la recta se queda cerca de la mitad, porque no ve sentidos
 unicos ni rodeos ni rios. Asi que al conductor se le enseñaba un viaje mas cercano de lo que
 estaba, y decidia si aceptarlo con una cifra que le mentia a la baja. Android ya paso por
 esto: con el conductor parado en el destino de un viaje, el mismo trayecto salia 1,9 km como
 recogida y 3,98 km como viaje.

 NO BLOQUEA Y NO GUARDA A NADIE. consultar... devuelve lo que ya sabe -- aunque este caducado --
 y como mucho deja pedida una ruta. No acepta bloques de vuelta a proposito: esto se llama
 desde el pintado de tarjetas, que ocurre muchas veces por segundo, y quedarse con un bloque
 que lleve la vista dentro es acumular basura sin freno. Android lo sufrio: el heap llego a
 501 MB de 512 y el recolector congelaba el hilo principal.

 Cuando la medida llega se publica ConrraRutaDeRecogidaActualizada y quien pinte esa cifra
 vuelve a pintarla. Esa es toda la comunicacion de vuelta.

 LAS DEFENSAS, todas heredadas de Android:

   - Freno global entre peticiones: pregunte quien pregunte, a la red se sale a ritmo fijo.
   - Cache con techo, porque el conductor recorre puntos distintos toda la jornada.
   - Una peticion que no vuelve caduca sola, para que su clave no quede bloqueada.
   - Se devuelve la ultima medida conocida aunque haya caducado: alternar entre la buena y la
     linea recta mientras llega la nueva hace parpadear la cifra en pantalla.
 */
@interface ConrraRutaDeRecogida : NSObject

/**
 La medida por carretera, si ya se conoce.

 @return la ultima conocida, aunque este caducada, o nil si no hay ninguna todavia
 */
+ (nullable ConrraMedidaDeRuta *)consultarDesde:(CLLocationCoordinate2D)origen
                                          hasta:(CLLocationCoordinate2D)destino;

/**
 El texto listo para pintar, con la carretera si se sabe y la linea recta mientras tanto.

 Dejar el hueco en blanco esperando a la medida buena es peor que enseñar la recta: el
 conductor necesita una cifra AHORA para decidir. La recta se queda corta, pero orienta.

 @param prefijo lo que va delante, por ejemplo "Recogida a". Puede ir vacio.
 @return "Recogida a 3.4 km", o cadena vacia si no hay nada que medir
 */
+ (NSString *)textoDesde:(CLLocationCoordinate2D)origen
                   hasta:(CLLocationCoordinate2D)destino
                 prefijo:(nullable NSString *)prefijo;

@end

NS_ASSUME_NONNULL_END
