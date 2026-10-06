//
//  ConrraCaraEnLaFoto.h
//  Conrra
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Cuenta las caras que hay en una foto, con Vision.

 PARA QUE. La selfie del registro sirve para que el conductor reconozca a quien recoge.
 Cerrar la galeria quita la via facil de meter una imagen que no es tuya, pero no la cierra:
 el boton de girar camara de iOS sigue ahi, asi que con la camara trasera se puede
 fotografiar una pared, un carnet o la foto de otra persona en una pantalla. Lo que de
 verdad cierra eso es mirar si hay UNA cara.

 NO ES RECONOCIMIENTO FACIAL. No identifica a nadie ni compara con nada: solo dice cuantos
 rectangulos con forma de cara hay. No sale del telefono, no se guarda y no se manda.

 Y NO DISTINGUE UNA CARA DE LA FOTO DE UNA CARA. Si alguien enseña a la camara una foto
 impresa o la pantalla de otro telefono, Vision ve una cara y la cuenta. Detectar eso --
 prueba de vida -- es otra cosa y bastante mas obra. Esto sube el escalon, no lo cierra.
 */
@interface ConrraCaraEnLaFoto : NSObject

/**
 Cuenta las caras y avisa EN EL HILO PRINCIPAL.

 @param sePudoMirar NO cuando Vision no pudo analizar la imagen. Importa distinguirlo de
                    "cero caras": quien llame no debe rechazar una foto por un fallo
                    tecnico. "No lo se" no es "no hay nadie".
 */
+ (void)contarCarasEn:(nullable UIImage *)imagen
        cuandoTermine:(void (^)(NSInteger caras, BOOL sePudoMirar))bloque;

@end

NS_ASSUME_NONNULL_END
