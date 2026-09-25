//
//  ConrraVoyEnCamino.h
//  Conrra
//
//  El primer paso del ciclo del conductor, calcado de SlideMainActivity (Android).
//

#import <Foundation/Foundation.h>

@class TripModel;

NS_ASSUME_NONNULL_BEGIN

/**
 El aviso de "voy en camino", que en iOS no existia.

 EL CICLO DE ANDROID. Un solo boton recorre cuatro pasos (SlideMainActivity,
 fullButtonClickListener y updateTripStatusUI):

     accept            -> "Voy en camino!"   el estado del viaje NO cambia
     accept + marca    -> "Estoy llegando!"  updateTripStatusApi(ARRIVE)
     arrive            -> "Recoger Cliente"  clientPickedUpView, u OTP si ya confirmo
     begin             -> "Fin del viaje"    updateTripStatusApi(END)

 LO QUE HACIA iOS. Se saltaba el primero entero: el primer toque llamaba ya a
 updateTripStatus:TS_ARRIVE. O sea que el conductor decia "voy en camino" y al pasajero le
 constaba que YA HABIA LLEGADO, con su sonido de cab_arrive y todo, cuando el coche acababa
 de arrancar. No era el rotulo lo que estaba mal: era el estado del viaje, adelantado un paso.

 QUE MANDA ESTE PASO. Ni toca el estado ni llama a updatetripstatus. Manda dos cosas al
 pasajero, las mismas que Android:

   1. Un push informativo, con type "notif" y trip_status "go". Ese type importa: el
      manejador del pasajero en iOS mira `type` ANTES que `trip_status` y, si viene, enseña
      el aviso y sale. Que es justo lo que se quiere aqui -- avisar sin mover nada.

   2. Un mensaje automatico en el chat del viaje, con el nombre del conductor, el color, el
      modelo y la placa. Es lo que permite reconocer el coche desde la acera.

 UNA VEZ POR VIAJE. La marca se guarda por trip_id, no como una bandera global. Android
 aprendio esto por las malas: el boton revertia, cada pulsacion repetia el envio y hubo
 pasajeros recibiendo el mismo mensaje cuatro veces. Por viaje ademas sobrevive a que la
 pantalla se reconstruya, a que la app se reinicie, y no se arrastra al viaje siguiente.
 */
@interface ConrraVoyEnCamino : NSObject

/** Si en ESTE viaje el conductor ya dijo que va en camino. */
+ (BOOL)yaAvisoEnElViaje:(nullable NSString *)tripId;

/**
 Marca el viaje y manda el aviso: push al pasajero y mensaje al chat.

 No hace nada si ya se aviso en este viaje. Es seguro llamarla de mas.
 */
+ (void)avisarDesdeElViaje:(nullable TripModel *)viaje;

/** Borra la marca. Se llama al cerrar o cancelar el viaje, para no arrastrarla. */
+ (void)olvidarElViaje:(nullable NSString *)tripId;

@end

NS_ASSUME_NONNULL_END
