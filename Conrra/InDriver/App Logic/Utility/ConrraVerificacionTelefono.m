//
//  ConrraVerificacionTelefono.m
//  Conrra
//

#import "ConrraVerificacionTelefono.h"
#import "ConrraVerificacionDidit.h"
#import "ConstantModel.h"
@import Firebase;

/**
 Como se verifica el telefono. Una linea, y es la unica que hay que tocar para cambiarlo.

   "didit"    - Didit por WhatsApp, con SMS de respaldo automatico, a traves del rele de
                conrraservices.com. El codigo lo genera y lo comprueba Didit; el app no lo
                conoce. Es el unico que funciona en Panama, donde Firebase no entrega el SMS
                (Error code 39, 2026-10-06). PREDETERMINADO.
   "firebase" - Firebase Phone Auth. El codigo lo genera y lo comprueba Google, el app no lo
                conoce nunca. Prueba igual de bien que quien se registra tiene ese numero;
                lo que falla en Panama es la ENTREGA, no el metodo.
   "sms"      - El camino viejo con Twilio: el app generaba el codigo, pedia al servidor que
                lo mandara y lo comparaba consigo mismo. Se paga y no verifica nada. Se
                conserva solo para poder volver atras.

 "sim" no esta, y ya tampoco en Android: era el Phone Number Hint de Google leyendo el numero
 de la SIM, solo funcionaba en algunos telefonos y su pantalla se quito el 2026-10-07. iOS
 nunca pudo ofrecerlo -- Apple no da el numero del abonado.
 */
static NSString *const kMetodo = @"didit";

/// La sesion de verificacion y EL NUMERO AL QUE PERTENECE. Los dos juntos, siempre.
static NSString *gIdVerificacion = nil;
static NSString *gTelefonoDelEnvio = nil;

@implementation ConrraVerificacionTelefono

+ (BOOL)conFirebase {
    return [kMetodo isEqualToString:@"firebase"];
}

+ (BOOL)conDidit {
    return [kMetodo isEqualToString:@"didit"];
}

+ (BOOL)loGeneraElApp {
    // En positivo: solo el camino viejo. Ver el porque en la cabecera.
    return [kMetodo isEqualToString:@"sms"];
}

+ (BOOL)loVerificaElServidor {
    return ![self loGeneraElApp];
}

+ (BOOL)apagadaPara:(NSDictionary *)usuario {
    // La constante no se reinterpreta aqui: ConstantModel ya la lee con esta misma regla, "1" y
    // nada mas, y devolverla a texto para volver a compararla solo daria dos sitios que pueden
    // separarse. Si getConstantsObject da nil, una propiedad de nil vale 0 y sale NO, que es el
    // lado seguro: mejor pedir un codigo de mas que dejar entrar sin comprobar.
    if ([ConstantModel getConstantsObject].otp_off) {
        return YES;
    }
    return [self esCuentaDePrueba:usuario];
}

+ (BOOL)esCuentaDePrueba:(NSDictionary *)usuario {
    if (![usuario isKindOfClass:[NSDictionary class]]) {
        return NO;
    }
    return [self unoExacto:[usuario objectForKey:@"is_test"]];
}

/// Exactamente "1", venga como texto o como numero.
+ (BOOL)unoExacto:(id)valor {
    NSString *texto = [NSString stringWithFormat:@"%@", valor];
    return [[texto stringByTrimmingCharactersInSet:
             [NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@"1"];
}

+ (NSInteger)casillas {
    // Didit y Firebase mandan seis digitos; el camino viejo generaba cuatro.
    return ([self conDidit] || [self conFirebase]) ? 6 : 4;
}

+ (NSString *)limpio:(NSString *)texto {
    if (![texto isKindOfClass:[NSString class]]) {
        return @"";
    }
    return [texto stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

#pragma mark - Mandar el codigo

+ (void)enviarA:(NSString *)telefonoE164
  cuandoTermine:(void (^)(BOOL, NSString *_Nullable))bloque {
    if ([self conDidit]) {
        [ConrraVerificacionDidit enviarA:telefonoE164 cuandoTermine:bloque];
        return;
    }
    NSString *telefono = [self limpio:telefonoE164];
    if (telefono.length == 0) {
        [self responder:bloque ok:NO error:@"Número de teléfono vacío"];
        return;
    }

    // La sesion que empieza aqui pertenece a ESTE numero y a ningun otro.
    gTelefonoDelEnvio = telefono;
    gIdVerificacion = nil;

    /*
     UIDelegate a nil: Firebase usa la ventana activa si tiene que enseñar el reCAPTCHA.

     Y tendria que enseñarlo solo cuando el push silencioso de APNs no funciona, que es
     justo el sintoma de que falta subir la clave de APNs a la consola. Si aparece un
     navegador aqui, el problema es de configuracion, no del usuario.
     */
    [[FIRPhoneAuthProvider provider] verifyPhoneNumber:telefono
                                            UIDelegate:nil
                                            completion:^(NSString *_Nullable idVerificacion,
                                                         NSError *_Nullable error) {
        if (error != nil || idVerificacion.length == 0) {
            NSLog(@"[VerificacionTelefono] no se pudo pedir el codigo: %@", error.localizedDescription);
            [self responder:bloque ok:NO error:[self traducir:error]];
            return;
        }
        gIdVerificacion = idVerificacion;
        [self responder:bloque ok:YES error:nil];
    }];
}

#pragma mark - Comprobarlo

+ (void)comprobar:(NSString *)codigo
    cuandoTermine:(void (^)(BOOL, NSString *_Nullable))bloque {
    if ([self conDidit]) {
        [ConrraVerificacionDidit comprobar:codigo cuandoTermine:bloque];
        return;
    }
    if (gIdVerificacion.length == 0) {
        [self responder:bloque ok:NO error:@"Pide el código otra vez"];
        return;
    }
    NSString *escrito = [self limpio:codigo];
    if (escrito.length == 0) {
        [self responder:bloque ok:NO error:@"Escribe el código"];
        return;
    }

    FIRAuthCredential *credencial =
        [[FIRPhoneAuthProvider provider] credentialWithVerificationID:gIdVerificacion
                                                    verificationCode:escrito];
    /*
     ENTRAR ES LA UNICA FORMA DE COMPROBAR. Firebase no tiene un "valida esto y no me metas":
     la credencial se canjea con signInWithCredential, y eso abre sesion con el telefono.

     CONSECUENCIA, para que quede dicha: esa sesion SUSTITUYE la de Firebase que el app use
     para el chat (FireAnonymousSigupHelper entra con correo y contraseña). En los tres
     caminos que llegan aqui -- registro, entrada y recuperar contraseña -- la entrada por
     correo ocurre despues y la restituye, asi que no se nota. Android hace lo mismo.
     */
    [[FIRAuth auth] signInWithCredential:credencial
                              completion:^(FIRAuthDataResult *_Nullable resultado,
                                           NSError *_Nullable error) {
        if (error != nil) {
            NSLog(@"[VerificacionTelefono] el codigo no paso: %@", error.localizedDescription);
            [self responder:bloque ok:NO error:[self traducir:error]];
            return;
        }
        [self limpiar];
        [self responder:bloque ok:YES error:nil];
    }];
}

#pragma mark - El estado

+ (BOOL)hayEnvioEnCursoPara:(NSString *)telefonoE164 {
    if ([self conDidit]) {
        return [ConrraVerificacionDidit hayEnvioEnCursoPara:telefonoE164];
    }
    if (gIdVerificacion.length == 0 || gTelefonoDelEnvio.length == 0) {
        return NO;
    }
    return [gTelefonoDelEnvio isEqualToString:[self limpio:telefonoE164]];
}

/**
 Se limpian LOS DOS, sin preguntar por el metodo.

 Limpiar de mas no rompe nada -- borrar una sesion que no existe no hace daño -- y limpiar de
 menos deja estado vivo del proveedor que no esta en uso. Si algun dia se cambia la constante
 con el app en marcha, esto es lo que evita que una sesion vieja conteste por la nueva.
 */
+ (void)limpiar {
    gIdVerificacion = nil;
    gTelefonoDelEnvio = nil;
    [ConrraVerificacionDidit limpiar];
}

#pragma mark - Los avisos

/// Siempre en el hilo principal: quien llama pinta pantalla con esto.
+ (void)responder:(void (^)(BOOL, NSString *_Nullable))bloque
               ok:(BOOL)ok
            error:(NSString *)error {
    if (bloque == nil) {
        return;
    }
    if ([NSThread isMainThread]) {
        bloque(ok, error);
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{ bloque(ok, error); });
    }
}

/**
 Los mensajes de Firebase vienen en ingles y hablan de "credential" y "quota". Lo que el
 usuario necesita saber es si se equivoco de codigo o si el problema es de la app.

 SE MIRA EL TEXTO Y NO EL CODIGO DE ERROR, igual que en Android. Las constantes de
 FIRAuthErrorCode viven en los Pods, que no estan en este repositorio: no puedo comprobar
 como se escriben exactamente y un nombre mal puesto no compila. El texto lo da la misma
 libreria y es estable. Cuando se tengan los Pods delante, esto se puede cambiar a
 error.code y queda mas firme.
 */
+ (NSString *)traducir:(NSError *)error {
    NSString *bruto = error.localizedDescription ?: @"";
    NSString *b = [bruto lowercaseString];

    if ([b containsString:@"invalid verification code"] || [b containsString:@"invalid_code"]) {
        return @"El código no es correcto";
    }
    if ([b containsString:@"expired"] || [b containsString:@"session-expired"]) {
        return @"El código caducó. Pide uno nuevo";
    }
    if ([b containsString:@"invalid phone number"] || [b containsString:@"invalid-phone-number"]) {
        return @"El número no parece válido. Revisa el país y los dígitos";
    }
    if ([b containsString:@"quota"] || [b containsString:@"too many"] || [b containsString:@"blocked"]) {
        return @"Demasiados intentos. Espera unos minutos e inténtalo de nuevo";
    }
    if ([b containsString:@"network"] || [b containsString:@"offline"]) {
        return @"Sin conexión. Revisa tus datos o el wifi";
    }
    /*
     El fallo de configuracion mas comun, y en iOS es la clave de APNs sin subir, no una
     huella SHA. Conviene distinguirlo porque no tiene nada que ver con el usuario: su
     telefono y su numero estan bien.
     */
    if ([b containsString:@"notification"] || [b containsString:@"apns"]
        || [b containsString:@"app is not verified"] || [b containsString:@"not authorized"]
        || [b containsString:@"captcha"]) {
        return @"La app no está autorizada para verificar teléfonos. Falta subir la clave de APNs a Firebase";
    }
    return bruto.length > 0 ? bruto : @"No se pudo verificar el teléfono";
}

@end
