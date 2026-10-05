//
//  ConrraPagoPreferido.h
//  Conrra
//
//  Equivalente de com.conrra.merged.common.pagos.PagoPreferido (Android).
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 El ultimo metodo de pago que uso el pasajero, para que sea el predeterminado.

 ANTES DE ESTO el home arrancaba SIEMPRE con billetera, a mano:

     paymentViewModel = [[HomePaymentViewModel alloc] init:1];   // 1 = Wallet

 Asi que quien paga en efectivo todos los dias tenia que cambiarlo en cada viaje. Y el
 u_pay_mode del perfil no servia de nada porque lo unico que escribia ahi era la pantalla
 de tarjetas, y siempre ponia "card".

 ========================= DONDE SE GUARDA Y POR QUE =========================
 En DOS sitios, y no por duplicar:

   - En las preferencias del telefono: es lo que se lee al abrir el home. Instantaneo y sin
     red; el pasajero no tiene que esperar al servidor para ver su metodo puesto.
   - En users.u_pay_mode del backend: para que le siga al cambiar de telefono o reinstalar.

 Si las dos discrepan manda la local, que es la del ultimo viaje hecho en ESTE telefono. El
 servidor solo se usa como semilla cuando aun no hay nada guardado aqui.

 La clave lleva el id del usuario: dos cuentas en el mismo telefono no se heredan el modo
 una de otra.
 =============================================================================

 Los modos son los que de verdad existen en trips.trip_pay_mode: Cash, Pago Movil, Wallet y
 Card. Se guarda el NOMBRE y no el numero de HomePaymentViewModel porque el numero es un
 detalle de esa pantalla -- hoy 0/1/2 -- y el nombre es lo que entiende el servidor.
 */
@interface ConrraPagoPreferido : NSObject

/**
 Guarda el metodo que acaba de elegir el pasajero.

 @param modo   Cash, Pago Movil, Wallet o Card. Vacio no se guarda: un "ninguno" no es una
               preferencia, es la ausencia de una.
 @param pmId   el identificador de la tarjeta de Stripe, o nil. Solo tiene sentido con Card:
               sin el, al restaurar no se sabria QUE tarjeta era.
 @param visible los cuatro digitos que se enseñan ("****4242"), o nil.
 */
+ (void)recordarModo:(nullable NSString *)modo
             tarjeta:(nullable NSString *)pmId
             visible:(nullable NSString *)visible;

/**
 El modo recordado, o "" si no hay ninguno.

 Primero el telefono; si aqui no hay nada, lo que diga el perfil del backend. Asi un pasajero
 que estrena telefono se encuentra su metodo de siempre.
 */
+ (NSString *)modo;

/** El identificador de la tarjeta recordada, o nil. Solo se rellena cuando el modo es Card. */
+ (nullable NSString *)tarjeta;

/** Los cuatro digitos de la tarjeta recordada, o nil. */
+ (nullable NSString *)tarjetaVisible;

/**
 El numero de modo de HomePaymentViewModel que corresponde al modo recordado.

 Devuelve el que se le pase como respaldo cuando no hay nada guardado, para que quien llame
 no tenga que repetir la tabla.
 */
+ (int)modoParaElSelectorOPorOmision:(int)porOmision;

@end

NS_ASSUME_NONNULL_END
