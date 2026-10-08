//
//  ConrraNumeroVerificado.h
//  Conrra
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 ¿Ha demostrado este usuario que el telefono es suyo?

 ======================== EL HUECO QUE ESTO TAPA ========================
 La verificacion solo ocurre en tres puertas: registro, entrada y recuperar contrasena. Quien
 ya tenia la sesion abierta y se limita a ACTUALIZAR el app no pasa por ninguna, asi que de
 toda la base instalada no hay prueba de que el numero exista ni de que sea suyo -- se dieron
 de alta cuando el codigo lo generaba el propio telefono, que no probaba nada.

 Asi que la primera vez que se abre el app actualizado con sesion abierta se pide el codigo, y
 hasta que no llegue bien no se entra. Despues la sesion sigue normal y no se vuelve a pedir.
 ========================================================================

 DONDE VIVE EL DATO, y por que aqui y no en el servidor. La marca es local y va por usuario.
 Eso basta para lo que se pidio -- bloquear una vez al actualizar y no volver a molestar --, y
 no toca el backend de produccion.

 LO QUE ESTO NO ES: no es una prueba que el servidor pueda exigir. Un cliente modificado puede
 escribirse la marca y saltarse el paso. La verificacion en si es REAL (el codigo lo genera y
 lo comprueba Didit, el app no lo ve nunca), pero no es EXIGIBLE hasta que el registro valide
 el vale del rele contra su tabla -- la fase 2 que el propio rele documenta. Esto cierra el
 hueco para el usuario honesto, que es el 99,9%, y queda listo para apretarse luego.

 NO HACE FALTA BORRARLA AL CERRAR SESION. Quien vuelve a entrar pasa por la pantalla de
 entrada, que ya verifica con el proveedor y vuelve a anotar. Enganchar ademas cada sitio
 donde se cierra sesion seria una lista mas que mantener, y olvidar uno es dejar un usuario
 sin verificar sin que nadie se entere.
 */
@interface ConrraNumeroVerificado : NSObject

/**
 ¿Hay que pedir el codigo AHORA, antes de dejar entrar?

 La decision la toma ConrraPuertaVerificacion, que es pura y tiene sus dieciseis
 combinaciones probadas; aqui solo se reunen los datos. Dice NO -- y deja pasar -- en todos
 los casos en los que pedirlo seria encerrar al usuario: con la puerta apagada desde el
 servidor (`verificacion_obligatoria`), sin sesion, si el proveedor no verifica, si la
 verificacion esta apagada, si ya se verifico, o si del usuario guardado no sale un numero al
 que mandar nada.

 SE LLAMA CUANDO LAS CONSTANTES YA HAN LLEGADO, no antes. El interruptor vive en ellas, y
 leerlo de la copia de la sesion anterior es decidir con datos viejos.
 */
+ (BOOL)haceFalta;

/// Se acaba de verificar el numero del usuario que hay en sesion.
+ (void)anotarVerificado;

/**
 Lo mismo, pero para un usuario del que todavia no hay sesion guardada.

 Hace falta porque en el registro el telefono se verifica ANTES de que la cuenta exista: el
 id aparece por primera vez en la respuesta del alta, cuando el diccionario de sesion aun no
 se ha escrito. Sin esto, quien acaba de registrarse no quedaria apuntado y la puerta se lo
 volveria a pedir en el siguiente arranque.
 */
+ (void)anotarVerificadoDelUsuario:(nullable NSString *)usuarioId
    NS_SWIFT_NAME(anotarVerificadoDelUsuario(_:));

/// El numero al que hay que mandar el codigo, en E.164, o nil si no se puede armar.
+ (nullable NSString *)telefonoDelUsuario;

/// El prefijo de pais del usuario guardado, para la pantalla del codigo.
+ (nullable NSString *)prefijoDelUsuario;

/// El id del usuario que hay en sesion, o nil. Lo necesita quien ata el vale al usuario.
+ (nullable NSString *)idEnSesion;

/// Vuelve a exigirlo. Para pruebas, y para el dia que haya que forzar una ronda nueva.
+ (void)olvidar;

@end

NS_ASSUME_NONNULL_END
