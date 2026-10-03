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

/**
 La tabla de bancos, como parejas {nombre, codigo}.

 Se expone porque la recarga para estudiantes tiene que traducir el MISMO nombre de banco
 al MISMO codigo. Dos tablas que hay que mantener a la vez acaban distintas, y el sintoma
 seria una recarga rechazada por un codigo viejo. Ver ConrraRecargaEstudiantes.
 */
+ (NSArray<NSArray<NSString *> *> *)bancosPorNombre;

/** Un nombre de banco comparable: sin acentos, sin mayusculas y sin adornos. */
+ (NSString *)normalizar:(NSString *)texto;

@end

NS_ASSUME_NONNULL_END
