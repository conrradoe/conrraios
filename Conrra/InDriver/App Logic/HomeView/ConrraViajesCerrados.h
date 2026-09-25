//
//  ConrraViajesCerrados.h
//  Conrra
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Los viajes que el conductor ya dio por terminados. Para no volver a meterle el recibo.

 EL BUCLE QUE ARREGLA. El sondeo de la pantalla del conductor (gettripDetails:) pregunta por
 DRIVER_ID, sin id de viaje: el servidor le devuelve lo que tenga pendiente. Y un viaje
 completado pero SIN COBRAR sigue contando como pendiente -- entre otras cosas porque el
 backend solo devuelve d_is_available = 1 cuando trip_pay_status es 'Paid'. Al llegar esa
 respuesta, el bloque de TS_END hace un segue al recibo.

 Asi que: el conductor cierra el recibo, cae en el mapa, el mapa sondea, el servidor le
 devuelve el mismo viaje, y el mapa lo manda otra vez al recibo. Sin salida, y sin que borrar
 TRIP_ID en local sirva de nada, porque la consulta ni lo usa.

 COMO LO HACE ANDROID. Con la bandera isFareSummary y, sobre todo, con finish(): la pantalla
 que sondea se DESTRUYE al abrir el recibo, asi que no puede volver a sondear. En iOS esa
 pantalla se reconstruye y sigue viva, de modo que la bandera tiene que sobrevivir a ella. De
 ahi que esto se guarde por id de viaje y en disco.

 Se guardan los ultimos veinte. Son cadenas cortas y veinte cubre de sobra una jornada; el
 tope existe para que la lista no crezca sin fin.
 */
@interface ConrraViajesCerrados : NSObject

/** Apunta que el conductor ya termino con este viaje. */
+ (void)cerrar:(nullable NSString *)tripId;

/** Si el conductor ya lo dio por terminado. */
+ (BOOL)yaSeCerro:(nullable NSString *)tripId;

@end

NS_ASSUME_NONNULL_END
