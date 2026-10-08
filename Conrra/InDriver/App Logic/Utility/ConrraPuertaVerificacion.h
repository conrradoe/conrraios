//
//  ConrraPuertaVerificacion.h
//  Conrra
//
//  Equivalente de com.conrra.merged.common.PuertaVerificacion (Android).
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Decide si a esta sesion hay que pedirle que verifique el telefono antes de seguir.

 ===================== EL HUECO QUE CIERRA =====================
 El codigo solo se pide en registro, recuperar contrasena e inicio de sesion. Un usuario que
 YA tiene sesion viva no pasa por ninguno de los tres: se descarga la actualizacion y no
 cambia nada para el. Medido en produccion: 4.867 usuarios y 0 con el telefono verificado,
 porque hasta ahora no habia ni donde apuntarlo.
 ===============================================================

 LA DECISION ES PURA. Esta clase no mira ajustes, ni red, ni pantallas: recibe los cuatro
 datos y responde si pasa o no. Asi se pueden probar las DIECISEIS combinaciones con clang
 suelto, sin simulador -- cuatro booleanos son un espacio que cabe entero, y una tabla de
 verdad completa no deja sitio donde esconderse.

 Misma clase, mismos nombres y misma tabla que PuertaVerificacion.java, a proposito: la
 decision tiene que ser la misma en los dos telefonos, y el modo de asegurarse es que las
 dos respondan lo mismo a las mismas dieciseis preguntas.
 */
@interface ConrraPuertaVerificacion : NSObject

/**
 ¿Hay que verificar antes de dejarle seguir?

 @param puertaEncendida la constante `verificacion_obligatoria` del servidor
 @param haySesion       el usuario esta dentro (si no, ya pasara por el inicio de sesion)
 @param yaVerificado    consta que este usuario demostro su numero
 @param numeroE164      su numero en E.164, o nil si no se puede formar
 */
+ (BOOL)hayQueVerificarConPuerta:(BOOL)puertaEncendida
                       haySesion:(BOOL)haySesion
                    yaVerificado:(BOOL)yaVerificado
                      numeroE164:(nullable NSString *)numeroE164
    NS_SWIFT_NAME(hayQueVerificar(puerta:haySesion:yaVerificado:numeroE164:));

/**
 ¿Se le queda sin salida? Tiene sesion, la puerta esta puesta, no ha verificado y su numero
 no da ni para un E.164.

 Existe porque en Android midieron cuantos eran: 1 de 4.867, por un c_code corrupto. A ese NO
 se le bloquea -- `hayQueVerificar` responde NO -- porque bloquear a alguien que no PUEDE
 verificar es dejarlo sin app y sin nada que pueda hacer. Se le deja pasar y queda en el log
 para arreglarle la fila.

 La version anterior de esa regla bloqueaba a 55 personas: comprobaba longitudes por pais y
 rechazaba numeros venezolanos de 9 y 11 digitos, raros pero reales. Un numero raro vale mas
 que una regla bonita.
 */
+ (BOOL)seQuedaSinSalidaConPuerta:(BOOL)puertaEncendida
                        haySesion:(BOOL)haySesion
                     yaVerificado:(BOOL)yaVerificado
                       numeroE164:(nullable NSString *)numeroE164
    NS_SWIFT_NAME(seQuedaSinSalida(puerta:haySesion:yaVerificado:numeroE164:));

/** La clave donde se apunta que ESTE usuario ya verifico. Por usuario, nunca global. */
+ (nullable NSString *)claveDe:(nullable NSString *)usuarioId NS_SWIFT_NAME(claveDe(_:));

@end

NS_ASSUME_NONNULL_END
