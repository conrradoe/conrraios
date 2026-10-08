//
//  ConrraVerificacionDidit.h
//  Conrra
//
//  Equivalente de com.conrra.merged.common.VerificacionDidit (Android).
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Verificacion del telefono por WhatsApp (o SMS de respaldo) a traves del rele de Didit.

 ========================= POR QUE PASA POR UN RELE =========================
 El app NO habla con Didit. Habla con conrraservices.com/verificacion/, que es quien guarda
 la clave de la API.

 Esa clave es de servidor: metida en el ejecutable la extrae cualquiera y manda mensajes con
 cargo a tu cuenta. Y ademas, si el app llamara a Didit directamente, volveria a ser juez de
 su propia verificacion -- el mismo agujero que tenia el camino viejo de Twilio, donde el
 codigo se generaba en el telefono.
 ============================================================================

 EL CONTRATO DEL RELE, tal y como lo escribe su index.php:

     POST ?a=enviar     { telefono }           -> { ok, estado, vida_seg, intentos }
     POST ?a=comprobar  { telefono, codigo }   -> { ok, aprobado, token }

 LO QUE NO HAY QUE CONFUNDIR: el rele responde HTTP 200 tanto cuando el codigo es correcto
 como cuando NO lo es -- "codigo incorrecto", "caducado" y "sin intentos" salen con 200 y
 `ok:false`, porque no son errores de transporte sino respuestas legitimas. El veredicto
 esta en el cuerpo, nunca en el codigo HTTP. Mirar solo el HTTP daria por verificado a
 cualquiera.

 Y al reves: un 400 o un 429 TAMBIEN traen cuerpo con el motivo escrito para el usuario, asi
 que hay que leerlo antes de dar un mensaje generico.

 EL ESTADO VA ATADO AL NUMERO, no suelto: la sesion de un telefono no sirve para otro. Es la
 misma leccion que costo encontrar en ConrraVerificacionTelefono.

 POR QUE NO SE PIDE POR GIKit: ese envoltorio es el de Grepix y espera el sobre de respuesta
 de su propia API. El rele contesta su propio JSON, asi que se pide con NSURLSession directo,
 igual que la publicidad.
 */
@interface ConrraVerificacionDidit : NSObject

/**
 Pide el codigo. El canal lo decide el rele: WhatsApp, y SMS si no hay WhatsApp.

 @param telefonoE164 en formato internacional con el mas: +50766314100
 */
+ (void)enviarA:(nullable NSString *)telefonoE164
  cuandoTermine:(void (^)(BOOL enviado, NSString *_Nullable error))bloque
    NS_SWIFT_NAME(enviarA(_:cuandoTermine:));

/**
 Comprueba el codigo que tecleo el usuario.

 UNA DIFERENCIA CON ANDROID QUE NO ES UN OLVIDO: alli el numero se le pasa otra vez a
 comprobar, y aqui se usa el que se guardo al enviar. Es a proposito -- asi no hay forma de
 pedir el codigo para un numero y comprobarlo contra otro --, y de paso la firma queda igual
 que la de ConrraVerificacionTelefono, para que la pantalla no tenga que saber cual de los
 dos esta detras.
 */
+ (void)comprobar:(nullable NSString *)codigo
    cuandoTermine:(void (^)(BOOL verificado, NSString *_Nullable error))bloque
    NS_SWIFT_NAME(comprobar(_:cuandoTermine:));

/** ¿Hay un envio vivo PARA ESTE numero? El numero es obligatorio, a proposito. */
+ (BOOL)hayEnvioEnCursoPara:(nullable NSString *)telefonoE164
    NS_SWIFT_NAME(hayEnvioEnCursoPara(_:));

/**
 El vale de un solo uso de la ultima verificacion aprobada, o nil.

 Hoy no lo consume nadie. Dura 15 minutos y lo exigira la fase 2, cuando se pueda tocar
 apps.conrra.com y el registro lo valide contra la tabla del rele. Mientras tanto la
 verificacion es REAL -- el codigo lo genera y lo comprueba Didit -- pero no es EXIGIBLE:
 un cliente modificado podria saltarse el paso. Eso se cierra en la fase 2, no antes.
 */
+ (nullable NSString *)token;

+ (void)limpiar;

@end

NS_ASSUME_NONNULL_END
