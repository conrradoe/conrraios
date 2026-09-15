//
//  RecargaC2PViewController.h
//  Conrra
//
//  Equivalente de com.conrra.merged.common.recarga.RecargaC2PActivity (Android).
//

#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

/**
 Recarga por pago movil C2P.

 El app NO habla con Mercantil. Manda los datos al relé de conrraservices.com, que es el
 unico que conoce las credenciales del comercio; un IPA se abre con unzip.

 Tampoco hay paso de "solicitar clave": Mercantil no habilito el endpoint scp en
 produccion, asi que el cliente genera la clave C2P en la app de SU banco y la escribe
 aqui. Suele caducar en pocos minutos, y por eso el rotulo lo avisa.
 */
@interface RecargaC2PViewController : BaseViewController

@end

NS_ASSUME_NONNULL_END
