//
//  ConrraSaldoBilletera.h
//  Conrra
//
//  Equivalente de com.conrra.merged.common.pagos.SaldoBilletera (Android).
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 La regla de "¿le alcanza la billetera?", escrita UNA sola vez.

 POR QUE EXISTE ESTA CLASE. El saldo se comprobaba en un solo sitio -- al aceptar la oferta
 de un conductor -- con la cuenta hecha a mano alli mismo. Pero el importe de un viaje puede
 subir DESPUES de pedirlo, y hay tres sitios mas donde el pasajero compromete dinero y
 ninguno volvia a mirar:

     1. Al pedir el viaje (UHomeViewController, los dos createTripWith).
     2. Al aceptar la oferta de un conductor.            <- el unico que ya miraba
     3. Al subir su propia oferta mientras espera (enviarOferta).

 Con el saldo justo para el precio de salida, 1 y 3 arrancaban un viaje que no se podia
 pagar, y el pasajero se enteraba AL FINAL, cuando ya habia hecho el trayecto.

 Repartir la misma cuenta por cuatro pantallas es como se llega otra vez a eso: basta con que
 alguien añada un quinto sitio donde el precio cambie y se olvide de copiarla. Aqui esta una
 vez y cada punto la llama.

 LOS NOMBRES DE SWIFT VAN FIJADOS A MANO (NS_SWIFT_NAME). La pantalla de ofertas es Swift,
 y el importador de Objective-C reescribe los nombres de los metodos por su cuenta --
 recorta preposiciones, mueve etiquetas-- con reglas pensadas para el ingles. Con nombres en
 castellano el resultado no es predecible leyendo el codigo, y un nombre distinto del que
 espera el llamante no compila. Asi queda dicho cual es, y no depende de esas reglas.

 ESTO NO SUSTITUYE AL SERVIDOR. El endpoint que crea y acepta viajes admite cualquier importe
 sin mirar saldo, asi que un cliente modificado se salta todo esto. Cerrarlo de verdad es
 trabajo de backend; esto cierra lo que se puede cerrar desde el telefono.
 */
@interface ConrraSaldoBilletera : NSObject

/** ¿Este viaje se paga con la billetera de la app? */
+ (BOOL)esBilletera:(nullable NSString *)modoDePago;

/** Lo que hay ahora mismo. Si no se puede leer, cero: nunca se supone saldo a favor. */
+ (float)saldo;

/**
 La pregunta que importa: ¿se puede cerrar este viaje por ese importe?

 Con un modo de pago que no sea billetera devuelve YES siempre: el efectivo y el pago movil
 no dependen de este saldo, y bloquearlos aqui seria impedir viajes que si se pueden pagar.
 */
+ (BOOL)alcanza:(nullable NSString *)modoDePago
        importe:(float)importe NS_SWIFT_NAME(alcanza(_:importe:));

/** Cuanto falta para llegar. Cero si ya alcanza. */
+ (float)falta:(float)importe;

/**
 Le dice que no le alcanza, con las dos cifras delante.

 Sin los numeros el aviso no sirve de nada: lo primero que se pregunta quien lee "saldo
 insuficiente" es cuanto le falta.
 */
+ (void)avisarEn:(nullable UIViewController *)vc
         importe:(float)importe
          moneda:(nullable NSString *)moneda NS_SWIFT_NAME(avisarEn(_:importe:moneda:));

@end

NS_ASSUME_NONNULL_END
