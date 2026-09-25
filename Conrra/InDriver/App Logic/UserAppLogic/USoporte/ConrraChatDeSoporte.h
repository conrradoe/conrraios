//
//  ConrraChatDeSoporte.h
//  Conrra
//
//  Equivalente de com.conrra.merged.common.soporte.ChatDeSoporte (Android).
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/** Por que se abre el chat. Decide lo que se lee arriba y como empieza el mensaje. */
typedef NS_ENUM(NSInteger, ConrraMotivoDeSoporte) {
    /// Lo que abren los dos menus laterales.
    ConrraMotivoAyudaGeneral = 0,
    /// El conductor dice que no recibio el efectivo.
    ConrraMotivoPagoNoRecibido = 1,
};

/**
 El chat con soporte, UNO SOLO para los dos roles y para cualquier motivo.

 EL MOTIVO NO ES DECORACION. Es lo que le dice al usuario sobre que esta escribiendo antes
 de que escriba: la misma hoja preguntando "¿por que no recibiste el pago?" o "¿en que
 podemos ayudarte?" son dos conversaciones distintas, y quien contesta al otro lado
 necesita saber cual de las dos es sin tener que preguntarlo.

 EL MENSAJE VA FIRMADO. Empieza siempre por el nombre de quien escribe y desde que cuenta,
 porque al otro lado llega un WhatsApp de un numero suelto: sin nombre, el primer mensaje
 de vuelta siempre es "¿con quien hablo?".

 EL NUMERO ESTA EN EL BACKEND, no en el binario: asi se cambia el telefono de soporte sin
 publicar una version nueva en la App Store.
 */
@interface ConrraChatDeSoporte : NSObject

/** Chat sin viaje detras: lo que abren los dos menus laterales. */
+ (void)abrirEn:(UIViewController *)vc motivo:(ConrraMotivoDeSoporte)motivo;

/** Chat sobre un viaje concreto. `viajeId` y `monto` pueden ir vacios. */
+ (void)abrirEn:(UIViewController *)vc
         motivo:(ConrraMotivoDeSoporte)motivo
          viaje:(nullable NSString *)viajeId
          monto:(nullable NSString *)monto;

/**
 Igual que la anterior, pero avisando cuando la hoja se cierra.

 Hace falta donde el cierre de la hoja tiene que encadenar con algo mas -- por ejemplo, el
 conductor que declara que no le pagaron y a quien hay que devolver a su mapa despues. El
 bloque se llama SIEMPRE que la hoja desaparece: al cerrarla a mano y al volver de WhatsApp.
 */
+ (void)abrirEn:(UIViewController *)vc
         motivo:(ConrraMotivoDeSoporte)motivo
          viaje:(nullable NSString *)viajeId
          monto:(nullable NSString *)monto
       alCerrar:(nullable void (^)(void))alCerrar;

@end

NS_ASSUME_NONNULL_END
