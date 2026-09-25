//
//  ConrraSolicitudesPersistentes.h
//  Conrra
//
//  Calco de la persistencia de RequestFragment (Android).
//

#import <Foundation/Foundation.h>

@class TripModel;

NS_ASSUME_NONNULL_BEGIN

/**
 Aguanta una solicitud en pantalla unos ciclos despues de que el servidor deje de devolverla.

 POR QUE. La lista de solicitudes se pide cada pocos segundos y se sustituye entera con lo
 que conteste el servidor. Pero esa respuesta parpadea: la misma solicitud desaparece en un
 sondeo y vuelve en el siguiente. Pasa por varios motivos a la vez -- el filtro de distancia
 se evalua contra la posicion del conductor, que cambia mientras conduce, asi que en el borde
 del radio entra y sale sola; y el servidor deja de listar un viaje en cuanto otro conductor
 abre una oferta sobre el, aunque no la haya cerrado.

 El efecto en pantalla es que la tarjeta se borra y reaparece. Si el conductor iba a tocarla,
 ya no esta. Android lo resolvio aguantandola cinco ciclos, y el comentario que dejo -- "~60
 segundos" -- dice que lo midio con el sondeo delante.

 ESTO NO INVENTA SOLICITUDES. Solo puede mantener un poco mas de tiempo una que el servidor ya
 habia dado por buena, y como mucho cinco ciclos. Pasados esos, se va.

 Y SE VA ANTES si el conductor decide: al rechazarla o aceptarla se olvida en el acto, que es
 lo que evita el otro sintoma -- una solicitud rechazada que sigue en la lista un minuto.
 */
@interface ConrraSolicitudesPersistentes : NSObject

/**
 Mezcla lo que contesta el servidor con lo que ya habia en pantalla.

 @param delServidor las solicitudes de esta respuesta, ya filtradas por radio
 @param enPantalla  las que se estaban enseñando
 @return las del servidor, mas las que faltan pero aun no han agotado sus ciclos
 */
+ (NSArray *)fusionar:(nullable NSArray *)delServidor
          conPantalla:(nullable NSArray *)enPantalla;

/** Olvida una solicitud: el conductor ya decidio sobre ella. */
+ (void)olvidar:(nullable NSString *)tripId;

/** Olvida todas. Se llama al desconectarse o al empezar un viaje. */
+ (void)olvidarTodas;

@end

NS_ASSUME_NONNULL_END
