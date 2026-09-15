//
//  RecargaBotonViewController.h
//  Conrra
//
//  Equivalente de com.conrra.merged.common.recarga.RecargaBotonActivity (Android).
//

#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

/**
 Recarga con tarjeta o debito inmediato, via Boton de Pagos Web de Mercantil.

 El app no pide NUNCA el numero de tarjeta: solo el monto. El relé devuelve un enlace a la
 pasarela alojada de Mercantil y el cliente teclea la tarjeta en el dominio del banco. Asi
 el PAN y el CVV no pasan por Conrra y el app queda fuera del alcance PCI-DSS.

 El resultado del pago no vuelve por aqui: Mercantil lo avisa por webhook a
 notificacion.php, que es quien acredita. Al volver del navegador solo se le dice al
 usuario que revise su saldo, porque es literalmente lo unico que se sabe.
 */
@interface RecargaBotonViewController : BaseViewController

@end

NS_ASSUME_NONNULL_END
