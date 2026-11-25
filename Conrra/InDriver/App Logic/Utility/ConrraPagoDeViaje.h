//
//  ConrraPagoDeViaje.h
//  Conrra
//
//  Equivalente de com.conrra.driverapp.PagoDeViaje (Android).
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 La UNICA regla de cobro de un viaje, en un solo sitio.

 ===================== QUIEN COBRA QUE =====================
 - El pasajero eligio BILLETERA: cobra el SERVIDOR al completar el viaje
   (apps.conrra.com, tripapi/updatetrip con trip_status=completed ->
   TransactionModel::stripePayment), resta al pasajero, acredita al conductor y marca el viaje
   "Paid". UNA vez. LA APP NO COBRA NUNCA.

 - El pasajero eligio EFECTIVO, Pago Movil o cualquier otro: la billetera NO se toca. Pero
   OJO, y esto es lo que se nos escapo: el servidor cobra la billetera en TODO viaje completado
   que no este "Paid" si al pasajero le alcanza, SIN mirar el metodo elegido. Por eso un viaje
   que no es de billetera se manda YA pagado en su metodo, en la MISMA peticion del completed:
   el servidor lo ve pagado y no lo cobra.
 ===========================================================

 HISTORIA, porque esto ya costo dinero dos veces. En Android la app cobraba ademas al validar
 el OTP y el pasajero pagaba dos veces: 67 viajes, borrado en su 1.0.30. En iOS el mismo
 agujero seguia abierto por otro sitio -- el pasajero se cobraba su propia billetera en la
 pantalla de la tarifa. Medido en produccion el 2026-11-24: el viaje 6431 tiene dos cobros de
 billetera con SEIS segundos de diferencia (uno de la app, otro del servidor), y los viajes
 6446 y 6451 tienen un cobro de billetera Y un registro de efectivo por el mismo viaje.

 QUE SE PREGUNTA AQUI Y QUE NO. Esta clase solo dice de que tipo es el pago. No mueve dinero,
 no habla con la red y no mira ajustes: asi se puede probar con clang suelto, que es la unica
 forma de cubrir los casos raros -- nil, "null", mayusculas, espacios -- sin arrancar la app.
 */
@interface ConrraPagoDeViaje : NSObject

/// El codigo del servidor para la billetera. Nunca se escribe "Wallet" a mano en otro sitio.
@property (class, nonatomic, readonly) NSString *billetera;

/// El codigo del servidor para el efectivo.
@property (class, nonatomic, readonly) NSString *efectivo;

/**
 ¿Eligio el pasajero pagar con billetera?

 Es la pregunta que decide si la app se aparta: si responde SI, el dinero lo mueve el servidor
 y la app no registra, no marca y no pregunta.
 */
+ (BOOL)esBilletera:(nullable NSString *)modoDePago NS_SWIFT_NAME(esBilletera(_:));

/**
 El metodo con el que se marca pagado un viaje que NO es de billetera.

 Devuelve el que eligio el pasajero -- "Pago Movil" se queda "Pago Movil" --, y efectivo
 cuando no hay nada o cuando lo que hay es billetera. Nunca devuelve billetera, a proposito:
 quien llama a esto esta a punto de registrar un cobro, y un registro con "Wallet" es el que
 hace que al pasajero le cobren dos veces.
 */
+ (NSString *)metodoNoBilletera:(nullable NSString *)modoDePago
    NS_SWIFT_NAME(metodoNoBilletera(_:));

@end

NS_ASSUME_NONNULL_END
