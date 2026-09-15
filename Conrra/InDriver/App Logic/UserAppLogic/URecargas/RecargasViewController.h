//
//  RecargasViewController.h
//  Conrra
//
//  Equivalente de com.conrra.merged.common.recarga.RecargaActivity (Android).
//

#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

/**
 Selector de metodo de recarga, el mismo para pasajero y conductor.

 REPARTO DELIBERADO, no capricho de diseño (ver backend-pagos/README.md):

  - C2P nativo: no toca datos de tarjeta, solo cedula, telefono y la clave que el cliente
    genera en su banco. Eso queda fuera del alcance PCI-DSS.
  - Tarjeta por web: si el numero y el CVV pasaran por el app, Conrra entraria en alcance
    PCI-DSS, que es una obligacion de auditoria real, no un tramite.
  - Transferencia por web: Mercantil no habilito transfer-search en produccion, asi que no
    hay forma de verificarla automaticamente; se queda donde ya se concilia a mano.

 Antes de esto, iOS mandaba las tres a la pagina web de recargas. Esta pantalla es la que
 le faltaba para igualar a Android.
 */
@interface RecargasViewController : BaseViewController

@end

NS_ASSUME_NONNULL_END
