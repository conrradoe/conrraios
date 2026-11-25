//
//  ConrraBonos.h
//  Conrra
//
//  Equivalente de com.conrra.merged.common.referral.BienvenidaBono y BonoReferido (Android).
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Los dos bonos que se celebran en la app: el de bienvenida y el de referido.

 Van juntos porque son la misma fiesta con otro texto -- en Android comparten el layout
 dialog_bono_referido -- y porque las dos se preguntan en el mismo sitio: la primera pantalla
 del pasajero al volver a primer plano. Separarlos en dos clases obligaria a enganchar dos
 veces lo mismo y a recordar las dos.

 NINGUNA DE LAS DOS MUEVE DINERO. El de bienvenida lo pone el servidor al crear la cuenta; el
 de referido lo paga conrraservices.com/taxi cuando el invitado completa su primer viaje. Aqui
 solo se celebra lo que ya esta acreditado.
 */
@interface ConrraBonos : NSObject

#pragma mark - Bienvenida

/**
 Lo llama el REGISTRO, justo antes de mandar al pasajero a su primera pantalla.

 Deja una marca con el id de la cuenta. Sin ella no se celebra nada: los usuarios que ya
 existian no pasaron por este punto, asi que no ven la bienvenida aunque tengan saldo.

 LA MARCA LLEVA EL ID a proposito: si fuera una bandera suelta, entrar con otra cuenta en el
 mismo telefono heredaria la fiesta de la primera.
 */
+ (void)marcarCuentaNueva:(nullable NSString *)usuarioId NS_SWIFT_NAME(marcarCuentaNueva(_:));

/**
 Celebra la bienvenida si toca. En la primera pantalla del pasajero.

 Se consume UNA vez, salga o no salga la fiesta: si se dejara la marca puesta cuando no hay
 saldo que celebrar, la pantalla lo reintentaria en cada vuelta.
 */
+ (void)revisarBienvenidaEn:(nullable UIViewController *)vc
    NS_SWIFT_NAME(revisarBienvenidaEn(_:));

#pragma mark - Referido

/**
 Acredita lo que toque y celebra lo pendiente.

 QUIEN PAGA. El backend original no paga nada por referir, asi que lo hace
 conrraservices.com/taxi: al preguntar, el servidor paga a los dos a quien ya cumplio la
 condicion -- el invitado completo su primer viaje -- y devuelve lo que esta persona aun no ha
 celebrado, YA marcado como visto. Por eso cada bono se celebra una sola vez, y en cada papel
 con su texto.

 SILENCIOSO ANTE CUALQUIER FALLO: esto es un extra y nunca puede romper la pantalla.
 */
+ (void)buscarYCelebrarReferidoEn:(nullable UIViewController *)vc
    NS_SWIFT_NAME(buscarYCelebrarReferidoEn(_:));

@end

NS_ASSUME_NONNULL_END
