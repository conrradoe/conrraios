//
//  ConrraVerificacionDidit.m
//  Conrra
//

#import "ConrraVerificacionDidit.h"
#import "Keys.h"

/** Lo que tarda en rendirse. Un envio por WhatsApp no deberia pasar de unos segundos. */
static const NSTimeInterval kEspera = 25.0;

/** A que numero pertenece el envio en curso. nil = no hay ninguno. */
static NSString *gTelefonoDelEnvio = nil;

/** El vale de un solo uso que devuelve el rele al aprobar. Lo exigira la fase 2. */
static NSString *gToken = nil;

@implementation ConrraVerificacionDidit

#pragma mark - Lo que usa la pantalla

+ (void)enviarA:(NSString *)telefonoE164
  cuandoTermine:(void (^)(BOOL, NSString *_Nullable))bloque {
    NSString *telefono = [self limpio:telefonoE164];
    if (telefono.length == 0) {
        [self responder:bloque ok:NO error:@"Falta el número de teléfono."];
        return;
    }

    // La sesion que empieza aqui es de ESTE numero y de ningun otro.
    gTelefonoDelEnvio = telefono;
    gToken = nil;

    [self pedir:@"enviar"
         campos:@{ @"telefono" : telefono }
  cuandoTermine:^(NSDictionary *cuerpo, NSString *falloDeRed) {
        if (cuerpo == nil) {
            gTelefonoDelEnvio = nil;
            [self responder:bloque ok:NO error:falloDeRed];
            return;
        }
        if ([self verdad:cuerpo[@"ok"]]) {
            [self responder:bloque ok:YES error:nil];
            return;
        }
        // No se pudo enviar: la sesion no existe, asi que no se deja a medias.
        gTelefonoDelEnvio = nil;
        [self responder:bloque ok:NO
                  error:[self mensajeDe:cuerpo porOmision:@"No se pudo enviar el código."]];
    }];
}

+ (void)comprobar:(NSString *)codigo
    cuandoTermine:(void (^)(BOOL, NSString *_Nullable))bloque {
    NSString *escrito = [self limpio:codigo];
    if (gTelefonoDelEnvio.length == 0) {
        [self responder:bloque ok:NO error:@"Pide el código otra vez"];
        return;
    }
    if (escrito.length == 0) {
        [self responder:bloque ok:NO error:@"Escribe el código"];
        return;
    }

    [self pedir:@"comprobar"
         campos:@{ @"telefono" : gTelefonoDelEnvio, @"codigo" : escrito }
  cuandoTermine:^(NSDictionary *cuerpo, NSString *falloDeRed) {
        if (cuerpo == nil) {
            [self responder:bloque ok:NO error:falloDeRed];
            return;
        }
        /*
         LAS DOS CONDICIONES, no una.

         `ok` dice que la pregunta se pudo hacer y `aprobado` es el veredicto de Didit. El
         rele contesta 200 con ok:false cuando el codigo es incorrecto o caduco, asi que
         quedarse con el HTTP -- o con `ok` a secas -- daria por bueno un codigo malo.
         */
        if ([self verdad:cuerpo[@"ok"]] && [self verdad:cuerpo[@"aprobado"]]) {
            id vale = cuerpo[@"token"];
            gToken = [vale isKindOfClass:[NSString class]] ? vale : nil;
            [self responder:bloque ok:YES error:nil];
            return;
        }
        [self responder:bloque ok:NO
                  error:[self mensajeDe:cuerpo porOmision:@"El código no es correcto."]];
    }];
}

+ (void)confirmarUsuario:(NSString *)usuarioId
           cuandoTermine:(void (^)(BOOL, NSString *_Nullable))bloque {
    NSString *usuario = [self limpio:usuarioId];
    if (gToken.length == 0) {
        [self responder:bloque ok:NO error:@"No hay una verificación reciente que confirmar."];
        return;
    }
    if (usuario.length == 0) {
        [self responder:bloque ok:NO error:@"Falta el usuario."];
        return;
    }
    [self pedir:@"confirmar"
         campos:@{ @"token" : gToken, @"usuario" : usuario }
  cuandoTermine:^(NSDictionary *cuerpo, NSString *falloDeRed) {
        if (cuerpo == nil) {
            [self responder:bloque ok:NO error:falloDeRed];
            return;
        }
        if ([self verdad:cuerpo[@"ok"]] && [self verdad:cuerpo[@"verificado"]]) {
            /*
             El vale es de UN SOLO USO y el rele ya lo gasto: guardarlo seria quedarse con
             una llave que no abre. Y peor, invitaria a reintentar con el mismo vale, que el
             rele ya rechaza -- y cada reintento parece un fallo nuevo en el log.
             */
            gToken = nil;
            [self responder:bloque ok:YES error:nil];
            return;
        }
        [self responder:bloque ok:NO
                  error:[self mensajeDe:cuerpo porOmision:@"No se pudo confirmar la verificación."]];
    }];
}

+ (BOOL)hayEnvioEnCursoPara:(NSString *)telefonoE164 {
    NSString *telefono = [self limpio:telefonoE164];
    if (gTelefonoDelEnvio.length == 0 || telefono.length == 0) {
        return NO;
    }
    return [gTelefonoDelEnvio isEqualToString:telefono];
}

+ (NSString *)token {
    return gToken;
}

+ (void)limpiar {
    gTelefonoDelEnvio = nil;
    gToken = nil;
}

#pragma mark - La peticion

/**
 POST al rele, y el cuerpo JSON de vuelta pase lo que pase con el HTTP.

 El bloque recibe el cuerpo si se pudo leer, o nil Y un motivo si no hubo manera. Un 400 o
 un 429 del rele NO son "no hubo manera": traen el motivo escrito para el usuario, asi que
 se entregan como cuerpo igual que un 200.
 */
+ (void)pedir:(NSString *)accion
       campos:(NSDictionary<NSString *, NSString *> *)campos
cuandoTermine:(void (^)(NSDictionary *_Nullable cuerpo, NSString *_Nullable falloDeRed))bloque {
    NSString *texto = [NSString stringWithFormat:@"%@/?a=%@", VERIFICACION_HOST, accion];
    NSURL *url = [NSURL URLWithString:texto];
    if (url == nil) {
        bloque(nil, @"No hay conexión con el servidor de verificación.");
        return;
    }

    NSMutableURLRequest *peticion = [NSMutableURLRequest requestWithURL:url];
    peticion.HTTPMethod = @"POST";
    peticion.timeoutInterval = kEspera;
    [peticion setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    peticion.HTTPBody = [[self cuerpoDeFormulario:campos] dataUsingEncoding:NSUTF8StringEncoding];

    [[[NSURLSession sharedSession] dataTaskWithRequest:peticion
                                    completionHandler:^(NSData *datos,
                                                        NSURLResponse *respuesta,
                                                        NSError *error) {
        NSDictionary *cuerpo = [self jsonDe:datos];
        if (cuerpo != nil) {
            /*
             Lo que contesto el rele, siempre. Sin esto, "no llega el codigo" es un sintoma
             sin dato: no se distingue un numero que Didit rechaza de un bloqueo del
             antifraude, de una clave mal puesta en el servidor o de que la peticion no
             llego a salir. El cuerpo ya viene sin nada sensible -- el rele no devuelve el
             telefono ni su clave de API -- y el numero no se escribe aqui.
             */
            NSLog(@"[VerificacionDidit] %@ -> HTTP %ld %@", accion,
                  (long)[(NSHTTPURLResponse *)respuesta statusCode], cuerpo);
            bloque(cuerpo, nil);
            return;
        }
        NSLog(@"[VerificacionDidit] %@: sin cuerpo legible (%@)", accion,
              error != nil ? error.localizedDescription : @"respuesta vacia");
        bloque(nil, @"No hay conexión con el servidor de verificación.");
    }] resume];
}

/**
 El cuerpo del formulario, con cada valor escapado.

 ESCAPAR NO ES OPCIONAL, y aqui se nota mas que en ningun otro sitio: en
 x-www-form-urlencoded el mas significa ESPACIO. Si el telefono se pegara tal cual,
 `telefono=+584246454012` le llegaria a PHP como ` 584246454012` -- con un espacio delante y
 sin el mas --, y telefonoValido() lo rechazaria por no empezar por mas. El numero seria
 correcto y el rele diria que no.

 Por eso el conjunto permitido son solo letras y digitos: asi el mas sale como %2B, que es
 lo que PHP vuelve a convertir en mas.
 */
+ (NSString *)cuerpoDeFormulario:(NSDictionary<NSString *, NSString *> *)campos {
    NSCharacterSet *permitidos = [NSCharacterSet alphanumericCharacterSet];
    NSMutableArray<NSString *> *partes = [NSMutableArray array];
    for (NSString *clave in campos) {
        NSString *valor = campos[clave] ?: @"";
        [partes addObject:[NSString stringWithFormat:@"%@=%@",
            [clave stringByAddingPercentEncodingWithAllowedCharacters:permitidos],
            [valor stringByAddingPercentEncodingWithAllowedCharacters:permitidos]]];
    }
    return [partes componentsJoinedByString:@"&"];
}

+ (NSDictionary *)jsonDe:(NSData *)datos {
    if (datos.length == 0) {
        return nil;
    }
    id leido = [NSJSONSerialization JSONObjectWithData:datos options:0 error:nil];
    return [leido isKindOfClass:[NSDictionary class]] ? leido : nil;
}

#pragma mark - Detalles

/**
 Un si o un no del JSON, venga como booleano, como numero o como texto.

 PHP serializa true/false como booleano JSON, pero no se da por supuesto: un `"1"` o un `1`
 significan lo mismo y un cambio en el rele no deberia dar por invalido un codigo bueno.
 */
+ (BOOL)verdad:(id)valor {
    if ([valor isKindOfClass:[NSNumber class]]) {
        return [valor boolValue];
    }
    if ([valor isKindOfClass:[NSString class]]) {
        return [valor boolValue] || [[valor lowercaseString] isEqualToString:@"true"];
    }
    return NO;
}

/** El mensaje que el rele escribio para el usuario, que ya viene en español. */
+ (NSString *)mensajeDe:(NSDictionary *)cuerpo porOmision:(NSString *)porOmision {
    id mensaje = cuerpo[@"mensaje"];
    if ([mensaje isKindOfClass:[NSString class]] && [mensaje length] > 0) {
        return mensaje;
    }
    return porOmision;
}

+ (NSString *)limpio:(NSString *)texto {
    if (![texto isKindOfClass:[NSString class]]) {
        return @"";
    }
    return [texto stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

/** Siempre en el hilo principal: quien llama enseña avisos y quita la ruedecita. */
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

@end
