//
//  ConrraRecargaEstudiantes.h
//  Conrra
//
//  Equivalente de com.conrra.merged.common.recarga.RecargaEstudiantes (Android).
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 El boton de "recarga para estudiantes" del selector de recargas, armado desde la tabla
 `constants` del backend.

 POR QUE DESDE CONSTANTES Y NO DESDE EL APK. El convenio con cada escuela se abre y se
 cierra en semanas, y la pagina de recarga puede mudarse de dominio. Si el rotulo y la
 direccion vivieran dentro del binario, cambiar una coma obligaria a publicar una version
 nueva y a esperar la revision de App Store. Asi se edita una fila y el cambio llega al
 telefono en la siguiente sincronizacion de constantes.

 LAS CLAVES, en la tabla `constants`:
   recarga_estudiantes_titulo      rotulo del boton. Vacio = boton escondido.
   recarga_estudiantes_url         pagina que se abre. Vacia = boton escondido.
   recarga_estudiantes_subtitulo   linea de apoyo, opcional.

 NO HAY UNA CLAVE APARTE DE ENCENDIDO/APAGADO a proposito: el boton existe cuando hay
 rotulo Y direccion. Una tercera clave solo añade un estado incoherente -- encendido sin
 direccion -- que se traduce en un boton que no lleva a ninguna parte.

 SOLO https. La direccion la abre un WKWebView con JavaScript activado; dejar pasar http:
 seria servir la pagina de recargas en claro, y dejar pasar javascript: convertiria una
 fila de base de datos en ejecucion de codigo dentro de la sesion del usuario. Si la fila
 no empieza por https://, el boton no aparece.

 SOLO PASAJERO, y no es una decision de producto sino de correccion. Esta pantalla la
 comparten los dos roles, pero el id del conductor y el del pasajero son numeraciones
 DISTINTAS: el conductor 55 y el pasajero 55 son dos personas. La pagina de recarga
 resuelve el id contra userapi/getusers, o sea contra la tabla de pasajeros, asi que
 abrirla como conductor no fallaria limpiamente -- enseñaria el nombre de OTRO y
 acreditaria su billetera. Una recarga para estudiantes tampoco tiene sentido para un
 conductor, asi que el boton no existe para ese rol.
 */
@interface ConrraRecargaEstudiantes : NSObject

/** Rotulo del boton, de la tabla `constants`. Vacio si no esta configurado. */
+ (NSString *)titulo;

/** Linea de apoyo, opcional. */
+ (NSString *)subtitulo;

/** La direccion cruda de la fila, sin la identidad pegada. */
+ (NSString *)url;

/** El boton se enseña solo al pasajero, y solo si hay rotulo y una direccion https. */
+ (BOOL)disponible;

/**
 La direccion con la identidad de la cuenta detras, que es lo que la pagina necesita para
 saber a que billetera acreditar.

 NO VA LA api_key. El endpoint que acredita (transactionapi/addtranswithouttrip) no
 comprueba que la api_key corresponda al user_id que recibe, asi que el servidor que
 acredita puede usar la suya propia y no gana nada con la del pasajero; y una api_key en un
 parametro de URL acaba escrita en el log de accesos del servidor web y en la cabecera
 Referer de cada recurso que cargue la pagina.

 Se respeta el ? que ya traiga la fila: la direccion de una escuela puede venir con su
 propio parametro de campus.
 */
+ (NSString *)urlConIdentidad;

/**
 El cuerpo del POST con el que se abre la pagina, o nil si no hay nada que mandar.

 LLEVA LOS DATOS DE PAGO MOVIL QUE EL PASAJERO YA REGISTRO en "Contacto Pago Móvil", para
 que no tenga que volver a teclear su cedula, su telefono y su banco delante de un
 formulario de pago. Es el mismo prellenado que ya hace RecargaC2PViewController de forma
 nativa, y sale del mismo sitio: el JSON de emergency_email_3.

 ================== POR QUE EN EL CUERPO Y NO EN LA DIRECCION ==================
 La cedula y el telefono son datos personales. Un parametro de URL acaba escrito en el log
 de accesos del servidor web, en el historial del WebView y en la cabecera Referer de cada
 recurso que cargue la pagina -- una fuente, una imagen --, o sea en sitios donde nadie los
 va a ir a borrar. El cuerpo de un POST no aparece en ninguno de los tres.

 El user_id SI se queda en la direccion, y eso es deliberado: es un identificador opaco de
 cuenta, es lo que ya hacia la pantalla de recargas de siempre, y asi, si el cuerpo se
 perdiera -- un redirect 30x convierte un POST en GET --, la pagina sigue sabiendo a quien
 recargar y lo unico que se pierde es la comodidad.
 ==============================================================================

 NO SE MANDA LO QUE NO SIRVE. Un banco que no esta en la lista, un telefono a medias o una
 cedula sin numero salen vacios y no se incluyen: prellenar un campo con algo que el banco
 va a rechazar es peor que dejarlo en blanco, porque el usuario lo da por bueno y el rechazo
 no explica donde estaba el error.
 */
+ (nullable NSData *)cuerpoPost;

@end

NS_ASSUME_NONNULL_END
