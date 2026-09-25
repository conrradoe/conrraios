//
//  ConrraCierreDeViaje.h
//  Conrra
//

#import <UIKit/UIKit.h>

@class TripModel;

NS_ASSUME_NONNULL_BEGIN

/**
 Pregunta por el pago y deja el viaje LIQUIDADO en el servidor. Para los dos lados.

 POR QUE EXISTE. Un viaje terminado no esta cerrado hasta que el servidor sabe si se cobro.
 Mientras siga en "completed" sin trip_pay_status, el PASAJERO se queda mirando su recibo sin
 salida -- da igual lo bien que se porte la app del conductor.

 Y esa liquidacion estaba atada a la pantalla del recibo del conductor: si el recibo no
 aparecia, o aparecia con los botones del diseño viejo tapados, no se preguntaba nada y el
 viaje se quedaba a medias. Atar el cierre de un viaje a que cierta pantalla se pinte es
 fragil: la pantalla es de un solo telefono, y el viaje es de dos.

 Asi que la pregunta vive aqui, y se hace en cuanto el conductor da el viaje por terminado --
 que es donde la hace Android -- sin depender de que despues se vea ningun recibo.

 LAS DOS RESPUESTAS CIERRAN. Lo que se decide es si el dinero llego, no si el viaje termino:

     Si  -> trip_pay_status = Paid
     No  -> trip_status = paid_cancel, que es lo que usa Android para "el pasajero no pago"

 En los dos casos se avisa al pasajero, porque su pantalla tampoco se entera sola.

 NO SE ESPERA RESPUESTA PARA CONTINUAR. El bloque de vuelta se llama en cuanto el conductor
 contesta, no cuando el servidor conteste. Una llamada lenta no puede dejar a nadie encerrado;
 si falla, queda la traza y el conductor ya tiene abierta la via de soporte.
 */
@interface ConrraCierreDeViaje : NSObject

/**
 Hace la pregunta y liquida segun la respuesta.

 @param vc         desde donde se enseña la pregunta
 @param viaje      el viaje que se cierra
 @param alTerminar se llama SIEMPRE, en el hilo principal, haya contestado lo que haya
                   contestado y aunque no se pudiera preguntar
 */
+ (void)preguntarPorElPagoDesde:(UIViewController *)vc
                          viaje:(nullable TripModel *)viaje
                     alTerminar:(nullable void (^)(void))alTerminar;

/**
 Vuelve a intentar los cierres que quedaron sin confirmar.

 Se llama al volver la app a primer plano. Un viaje que no se pudo cerrar deja al PASAJERO
 atrapado en su recibo, asi que la insistencia no es cosmetica.
 */
+ (void)reintentarCierresPendientes;

/** Si este viaje ya se liquido en esta sesion, para no preguntar dos veces. */
+ (BOOL)yaSeLiquido:(nullable NSString *)tripId;

@end

NS_ASSUME_NONNULL_END
