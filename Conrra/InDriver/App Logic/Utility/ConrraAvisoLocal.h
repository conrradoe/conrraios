//
//  ConrraAvisoLocal.h
//  Conrra
//
//  Equivalente de mostrarNotificacionLocal / avisarConductorEnSitio de Android
//  (riderapp/FragmentRouteNavigation.java).
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Marca que llevan en userInfo los avisos creados por la propia app.

 Hace falta porque el AppDelegate es el delegado de UNUserNotificationCenter y trata TODO
 lo que entra como si fuera un push: se lo pasa a manageRemoteNotification: despues de
 mapearlo de FCM a APNS. Un aviso nuestro no tiene ni aps ni trip_status, asi que sin esta
 marca acabaria en un manejador que no sabe que hacer con el.
 */
extern NSString * const kConrraAvisoLocalMarca;

/**
 Avisos que dispara la propia app, sin pasar por el servidor.

 POR QUE HACEN FALTA SI YA HAY PUSH. Porque el push llega tarde, o no llega. Hasta hoy los
 avisos de esta app salian por notif.conrra.com, que devuelve 500 en el 100% de las
 llamadas: el pasajero de iOS no tenia NINGUNA forma de enterarse de que el conductor habia
 llegado salvo mirando la pantalla. Android resolvio esto hace tiempo avisando desde el
 propio telefono cuando el sondeo del viaje detecta el cambio de estado.

 Y aunque el push funcione: la app sondea el estado del viaje por su cuenta, asi que muchas
 veces se entera antes que el servidor de mandarlo.
 */
@interface ConrraAvisoLocal : NSObject

/**
 Enseña un aviso del sistema.

 @param clave  Si no es nil, el aviso se enseña UNA sola vez para esa clave, para siempre.
               Android usa "aviso_llegada_<trip_id>", y aqui igual: sin eso, cada vuelta
               del sondeo volveria a avisar de la misma llegada.
 @param sonido Nombre del fichero de sonido del paquete (por ejemplo "cab_arrive.caf"), o
               nil para el sonido del sistema.
 */
+ (void)mostrarConClaveUnica:(nullable NSString *)clave
                      titulo:(NSString *)titulo
                       texto:(NSString *)texto
                      sonido:(nullable NSString *)sonido;

/** Vibra el telefono, como hace Android junto con el aviso de llegada. */
+ (void)vibrar;

@end

NS_ASSUME_NONNULL_END
