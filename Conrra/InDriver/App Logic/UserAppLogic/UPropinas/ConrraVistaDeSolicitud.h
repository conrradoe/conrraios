//
//  ConrraVistaDeSolicitud.h
//  Conrra
//
//  Equivalente de com.conrra.riderapp.bidModule.VistaDeSolicitud (Android).
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 "N conductores vieron tu solicitud": los dos lados del dato.

 El conductor avisa cuando una solicitud le aparece en la lista; el pasajero pregunta cuantos
 van, mientras espera.

 ============ POR QUE NO SALE DE LA BASE DEL TAXI ============
 Va contra conrraservices.com por dos razones. Una, apps.conrra.com no se puede modificar. Y
 dos, la que de verdad importa: `trip_requests` dice a quien se le MANDO la solicitud, no quien
 la tuvo delante. Son numeros distintos -- a un conductor con la app cerrada se le manda y no la
 ve -- y el que le sirve al pasajero es el segundo: le dice si hay gente mirando o esta solo.
 =============================================================

 ES UN ADORNO DE LA ESPERA, no parte del pedido. Si algo de aqui falla, la solicitud sigue
 exactamente igual, asi que NINGUN fallo se le ensena a nadie. Y si el servidor no contesta no
 se llama al bloque: la pantalla se queda con el ultimo numero que tenia, que es mejor que
 enseñar un cero que no es verdad.
 */
@interface ConrraVistaDeSolicitud : NSObject

/**
 El conductor avisa de que esta solicitud le aparecio.

 UNA VEZ POR SOLICITUD, y no es una optimizacion: la celda de la lista se dibuja muchas veces
 por la misma fila -- al aparecer, al desplazar, al refrescar -- y sin esto el mismo conductor
 contaria diez veces. El pasajero veria "10 conductores" habiendo uno.
 */
+ (void)avisarQueLaVioElConductor:(nullable NSString *)tripId
    NS_SWIFT_NAME(avisarQueLaVioElConductor(_:));

/**
 Cuantos conductores la han visto. Para la espera del pasajero.

 El bloque solo se llama si el servidor contesto con un numero.
 */
+ (void)cuantosLaVieron:(nullable NSString *)tripId
           cuandoLlegue:(void (^)(NSInteger conductores))bloque
    NS_SWIFT_NAME(cuantosLaVieron(_:cuandoLlegue:));

@end

NS_ASSUME_NONNULL_END
