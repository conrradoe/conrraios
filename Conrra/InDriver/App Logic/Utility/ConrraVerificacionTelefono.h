//
//  ConrraVerificacionTelefono.h
//  Conrra
//
//  Equivalente de com.conrra.merged.common.VerificacionTelefono (Android).
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Verificacion del telefono: de donde sale el codigo y quien dice si es bueno.

 ESTA CLASE ES EL REPARTIDOR. La pantalla no sabe quien esta detras: pide `enviarA:` y
 `comprobar:` aqui, y aqui se decide si eso va a Didit o a Firebase. Añadir un proveedor es
 tocar este fichero, no las cuatro pantallas que lo usan.

 EL PREDETERMINADO ES DIDIT desde el 2026-10-08, por WhatsApp con SMS de respaldo, a traves
 del rele de conrraservices.com. El motivo no es una preferencia: en Panama Firebase NO
 entrega el SMS (Error code 39, visto el 2026-10-06), asi que alli Phone Auth no sirve
 aunque este bien configurado. Ver ConrraVerificacionDidit.

 Lo de abajo describe el camino de Firebase, que sigue entero y a un cambio de constante.

 ================================ QUE ARREGLA ================================
 Hasta ahora el codigo lo generaba LA PROPIA APP:

     smsCode = [Utilities getRandomNumberBetween:1000 to:9999];   // OTPVerifyViewController

 le pedia al servidor que lo mandara por SMS con Twilio, y despues lo comparaba consigo
 misma. O sea: el codigo nunca salia del telefono que se estaba registrando, asi que no
 probaba NADA. Cualquiera podia darse de alta con el numero de otra persona, y encima se
 pagaba el SMS.

 Con Firebase el codigo lo genera y lo comprueba GOOGLE. La app no lo conoce nunca: solo
 envia lo que el usuario teclea y recibe un si o un no. Eso si prueba que quien se registra
 tiene ese numero.

 De paso deja de usarse Twilio.
 =============================================================================

 UNA DIFERENCIA CON ANDROID QUE NO ES UN OLVIDO. Alli Firebase lee el SMS por su cuenta y el
 numero queda verificado sin que el usuario teclee nada (onVerificationCompleted). En iOS eso
 NO existe: Apple no deja leer los SMS, asi que el codigo siempre hay que escribirlo. Por eso
 aqui no hay un aviso de "verificado solo".

 LO QUE HACE FALTA EN LA CONSOLA, y sin esto no sale ni un SMS:
   - Firebase > Authentication > Sign-in method: activar "Phone".
   - Subir la clave de APNs del proyecto a Firebase. Phone Auth comprueba que quien pide el
     SMS es de verdad esta app mandandole un push silencioso; sin la clave cae a reCAPTCHA en
     un navegador, y si eso tampoco esta configurado, falla. Es el equivalente iOS de las
     huellas SHA que pide Android.
 */
@interface ConrraVerificacionTelefono : NSObject

/**
 Con que proveedor se verifica, igual que Constants.Values.OTP_METODO de Android. Para
 cambiarlo se toca la constante del .m y nada mas.
 */
+ (BOOL)conFirebase;
+ (BOOL)conDidit;

/**
 ¿Conoce el app el codigo? Solo en el camino viejo, donde lo generaba el propio telefono.

 VA EN POSITIVO A PROPOSITO, y esto no es estilo: en Android el autorrelleno se cerraba con
 `!OTP_CON_FIREBASE`, una lista de negaciones que hay que acordarse de ampliar. Al entrar
 Didit se quedo abierta y la pantalla escribia el aleatorio de 4 digitos del app en las 6
 casillas de Didit. Preguntando en positivo, un proveedor nuevo nace SIN relleno y SIN SMS
 de pago, que es el lado seguro del olvido.
 */
+ (BOOL)loGeneraElApp;

/**
 Lo contrario, para que quien llama no tenga que escribir la negacion.

 Responde SI con Firebase y con Didit: en los dos el codigo lo genera y lo comprueba otro,
 el app solo manda lo que el usuario teclea. Es la pregunta que de verdad quieren hacer las
 pantallas -- "¿me ocupo yo del codigo o no?" --, y la unica que sigue siendo correcta
 cuando se añade un proveedor.
 */
+ (BOOL)loVerificaElServidor;

/**
 ¿Esta apagado el paso de verificacion para este usuario?

 Dos fuentes, y las dos significan "no hay codigo que esperar": la constante `otp_off` del
 backend, que se enciende y se apaga a mano, y `is_test` de la cuenta.

 Las dos se leen como las lee Android: apagado solo si el valor es exactamente "1". Con
 boolValue no era lo mismo -- decia SI para "true", "yes" o cualquier digito que no fuera
 cero --, y con el mismo valor en la tabla una plataforma apagaba la verificacion y la otra no.

 Vive aqui porque lo pregunta mas de una pantalla, y una regla de seguridad escrita dos veces
 acaba contestando cosas distintas.
 */
+ (BOOL)apagadaPara:(nullable NSDictionary *)usuario NS_SWIFT_NAME(apagadaPara(_:));

/** Cuantas casillas tiene el codigo: 6 con Firebase y con Didit, 4 con el camino viejo. */
+ (NSInteger)casillas;

/**
 Pide a Firebase que mande el codigo. Reenviar es volver a llamar aqui.

 @param telefonoE164 en formato internacional con el mas: +50761234567
 */
+ (void)enviarA:(nullable NSString *)telefonoE164
  cuandoTermine:(void (^)(BOOL enviado, NSString *_Nullable error))bloque;

/** Comprueba el codigo que tecleo el usuario. */
+ (void)comprobar:(nullable NSString *)codigo
    cuandoTermine:(void (^)(BOOL verificado, NSString *_Nullable error))bloque;

/**
 ¿Hay un envio en curso PARA ESTE numero al que responder?

 El numero es obligatorio a proposito. Preguntar solo "¿hay alguna sesion viva?" es
 exactamente la forma de que alguien verifique un telefono y entre con otro: el estado es
 estatico, y el segundo intento con un numero distinto validaria contra el primero. Es un
 fallo que Android ya tuvo y corrigio.
 */
+ (BOOL)hayEnvioEnCursoPara:(nullable NSString *)telefonoE164;

/** Olvida la sesion de verificacion. */
+ (void)limpiar;

@end

NS_ASSUME_NONNULL_END
