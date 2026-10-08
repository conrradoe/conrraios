//
//  ConrraTelefonoE164.h
//  Conrra
//
//  Equivalente de com.conrra.merged.common.TelefonoE164 (Android).
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Convierte lo que la gente teclea en un numero E.164 de verdad.

 ============================== POR QUE EXISTE ==============================
 El numero se montaba concatenando a pelo y quitando lo que no era digito:

     "+" + codigoDePais + loQueTecleoElUsuario

 Y eso produce numeros que PARECEN validos y no existen. El caso que importa es Venezuela,
 que es el 90% del volumen: alli se marca `0424 645 4012`, con un cero de troncal delante.
 Concatenado sale `+5804246454012` -- trece digitos que empiezan por 5, asi que pasa
 cualquier comprobacion de forma.

 Con el rele de verificacion eso NO es cosmetico: index.php rechaza el numero con
 `numero_invalido` en cuanto ve que el nacional empieza por cero, asi que el venezolano no
 puede registrarse. Y antes de que el rele lo comprobara era peor, porque fallaba en
 SILENCIO: Didit aceptaba el numero, el WhatsApp no llegaba a ninguna parte y el envio se
 cobraba igual.
 ===========================================================================

 REGLA DE E.164: el numero nacional NUNCA lleva el prefijo de troncal. El cero que se marca
 dentro del pais se quita al poner el codigo internacional. Eso vale para TODOS los paises,
 no solo para Venezuela, asi que aqui no hay tabla de paises que mantener.

 Es una clase PURA: no toca pantalla, ni red, ni ajustes. Se puede razonar de un vistazo y
 se puede probar sin arrancar la app.
 */
@interface ConrraTelefonoE164 : NSObject

/**
 El numero en E.164, o nil si lo que hay no da para uno.

 Devuelve nil y no una cadena a medias a proposito: quien llama tiene que poder distinguir
 "no tengo numero" de "tengo este", y un "+58" suelto se cuela en cualquier concatenacion
 sin que nadie se entere.
 */
+ (nullable NSString *)de:(nullable NSString *)codigoPais
                 nacional:(nullable NSString *)nacional NS_SWIFT_NAME(de(_:nacional:));

/** Quita todo lo que no sea digito: el mas, los espacios, los guiones, los parentesis. */
+ (NSString *)soloDigitos:(nullable NSString *)texto NS_SWIFT_NAME(soloDigitos(_:));

/**
 Quita el prefijo de troncal: los ceros de delante del numero nacional.

 Quita TODOS los ceros iniciales, no solo uno. Nadie tiene un numero nacional que empiece
 por cero, asi que no se pierde nada; y si alguien teclea `00424...` por error, se arregla
 en vez de mandar basura.
 */
+ (NSString *)sinCeroDeTroncal:(nullable NSString *)nacional NS_SWIFT_NAME(sinCeroDeTroncal(_:));

@end

NS_ASSUME_NONNULL_END
