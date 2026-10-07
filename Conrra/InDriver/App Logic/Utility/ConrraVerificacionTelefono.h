//
//  ConrraVerificacionTelefono.h
//  Conrra
//
//  Equivalente de com.conrra.merged.common.VerificacionTelefono (Android).
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Verificacion del telefono con Firebase Phone Auth.

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
 El metodo con el que se verifica el telefono, igual que Constants.Values.OTP_METODO de
 Android. Para volver a Twilio se cambia la constante del .m y nada mas.
 */
+ (BOOL)conFirebase;

/** Cuantas casillas tiene el codigo: 6 con Firebase, 4 con el camino viejo. */
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
