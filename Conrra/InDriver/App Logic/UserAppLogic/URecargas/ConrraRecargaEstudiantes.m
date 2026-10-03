//
//  ConrraRecargaEstudiantes.m
//  Conrra
//

#import "ConrraRecargaEstudiantes.h"
#import "RecargaC2PViewController.h"
#import "ConstantModel.h"
#import "WebCallConstants.h"
#import <GIKit/GIKit.h>

@implementation ConrraRecargaEstudiantes

static NSString *const kClaveTitulo    = @"recarga_estudiantes_titulo";
static NSString *const kClaveUrl       = @"recarga_estudiantes_url";
static NSString *const kClaveSubtitulo = @"recarga_estudiantes_subtitulo";

#pragma mark - La fila de constantes

+ (NSString *)valor:(NSString *)clave {
    NSString *v = [ConstantModel valorDeConstantePorClave:clave];
    return [v isKindOfClass:[NSString class]]
        ? [v stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]
        : @"";
}

+ (NSString *)titulo    { return [self valor:kClaveTitulo]; }
+ (NSString *)subtitulo { return [self valor:kClaveSubtitulo]; }
+ (NSString *)url       { return [self valor:kClaveUrl]; }

+ (BOOL)disponible {
    if ([self esConductor]) {
        return NO;
    }
    return [self titulo].length != 0
        && [[[self url] lowercaseString] hasPrefix:@"https://"];
}

/// Si no se puede saber el rol se asume conductor: esconder el boton es recuperable,
/// acreditarle a otro no.
+ (BOOL)esConductor {
    id bandera = defaults_object(P_IS_USER_LOGIN);
    if (bandera == nil) {
        return YES;
    }
    return ![bandera boolValue];
}

#pragma mark - La cuenta

/// El diccionario del PASAJERO. No hay rama para el conductor a proposito: ver disponible().
+ (NSDictionary *)pasajero {
    NSDictionary *dict = defaults_object(P_USER_DICT);
    return [dict isKindOfClass:[NSDictionary class]] ? dict : @{};
}

+ (NSString *)textoDe:(id)valor {
    if (valor == nil || valor == [NSNull null]) {
        return @"";
    }
    return [[NSString stringWithFormat:@"%@", valor]
            stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

/// Conjunto conservador: todo lo que no sea alfanumerico o de los cuatro sin reservar se
/// escapa. Vale igual para un parametro de la direccion y para el cuerpo del POST.
+ (NSString *)escapado:(NSString *)crudo {
    NSCharacterSet *permitidos = [NSCharacterSet characterSetWithCharactersInString:
        @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._~"];
    return [crudo stringByAddingPercentEncodingWithAllowedCharacters:permitidos] ?: @"";
}

#pragma mark - La direccion

+ (NSString *)urlConIdentidad {
    NSString *base = [self url];
    NSString *separador = [base containsString:@"?"] ? @"&" : @"?";
    NSDictionary *cuenta = [self pasajero];

    return [NSString stringWithFormat:@"%@%@user_id=%@&city_id=%@&rol=pasajero",
            base, separador,
            [self escapado:[self textoDe:[cuenta objectForKey:P_USER_ID]]],
            [self escapado:[self textoDe:[cuenta objectForKey:P_CITY_ID]]]];
}

#pragma mark - El cuerpo

+ (NSData *)cuerpoPost {
    if ([self esConductor]) {
        return nil;   // el boton no existe para el conductor; ver disponible()
    }
    NSDictionary *cuenta = [self pasajero];
    if (cuenta.count == 0) {
        return nil;
    }

    NSMutableString *cuerpo = [[NSMutableString alloc] init];
    [self agregar:cuerpo clave:@"user_id" valor:[self textoDe:[cuenta objectForKey:P_USER_ID]]];
    [self agregar:cuerpo clave:@"city_id" valor:[self textoDe:[cuenta objectForKey:P_CITY_ID]]];

    NSDictionary *pagoMovil = [self pagoMovilGuardado:cuenta];
    if (pagoMovil != nil) {
        [self agregar:cuerpo clave:@"cedula"
                valor:[self cedulaDeTipo:[self textoDe:[pagoMovil objectForKey:@"idType"]]
                                  numero:[self textoDe:[pagoMovil objectForKey:@"idNumber"]]]];
        [self agregar:cuerpo clave:@"telefono"
                valor:[self telefonoNormalizado:[self textoDe:[pagoMovil objectForKey:@"phone"]]]];
        [self agregar:cuerpo clave:@"banco"
                valor:[self codigoDeBanco:[self textoDe:[pagoMovil objectForKey:@"bank"]]]];
    } else {
        // Sin pago movil registrado, al menos el telefono de la cuenta, que suele ser el
        // mismo. Es lo que ya hace RecargaC2PViewController.
        [self agregar:cuerpo clave:@"telefono"
                valor:[self telefonoNormalizado:[self textoDe:[cuenta objectForKey:@"u_phone"]]]];
    }

    if (cuerpo.length == 0) {
        return nil;
    }
    return [cuerpo dataUsingEncoding:NSUTF8StringEncoding];
}

/// Agrega clave=valor al cuerpo, saltandose los vacios.
+ (void)agregar:(NSMutableString *)cuerpo clave:(NSString *)clave valor:(NSString *)valor {
    if (valor.length == 0) {
        return;
    }
    if (cuerpo.length > 0) {
        [cuerpo appendString:@"&"];
    }
    [cuerpo appendFormat:@"%@=%@", clave, [self escapado:valor]];
}

/**
 El JSON de pago movil del pasajero, o nil si no tiene.

 Vive en emergency_email_3, que en esta instalacion esta libre; el conductor lo tiene en
 d_bank_info. Es el mismo contrato que respetan SettingViewController y el C2P.
 */
+ (NSDictionary *)pagoMovilGuardado:(NSDictionary *)cuenta {
    NSString *guardado = [self textoDe:[cuenta objectForKey:P_EMERGENCY_CEMAIL_3]];
    if (![guardado hasPrefix:@"{"]) {
        return nil;
    }
    id leido = [NSJSONSerialization JSONObjectWithData:[guardado dataUsingEncoding:NSUTF8StringEncoding]
                                               options:0
                                                 error:nil];
    return [leido isKindOfClass:[NSDictionary class]] ? (NSDictionary *)leido : nil;
}

#pragma mark - Las tres normalizaciones

/**
 La cedula como la quiere el banco: una letra de las que acepta y los digitos.

 El formulario de contactos admite J y G; Mercantil no. Se manda el numero para no
 teclearlo, pero sin una letra que el banco rechazaria.
 */
+ (NSString *)cedulaDeTipo:(NSString *)tipo numero:(NSString *)numero {
    NSString *letra = [tipo uppercaseString];
    if (!([letra isEqualToString:@"V"] || [letra isEqualToString:@"E"] || [letra isEqualToString:@"P"])) {
        letra = @"";
    }
    NSString *digitos = [self soloDigitos:numero];
    if (digitos.length == 0) {
        return @"";
    }
    return [NSString stringWithFormat:@"%@%@", letra, digitos];
}

/**
 El telefono en el formato del pago movil: once digitos empezando por cero.

 Misma regla que ponerTelefono del C2P: puede venir con el 58 delante o sin el cero. Si al
 final no cuadra, se devuelve vacio -- prellenar un telefono a medias es peor que dejarlo
 en blanco, porque el usuario lo da por bueno.
 */
+ (NSString *)telefonoNormalizado:(NSString *)telefono {
    NSString *digitos = [self soloDigitos:telefono];
    if ([digitos hasPrefix:@"58"] && digitos.length == 12) {
        digitos = [digitos substringFromIndex:2];
    }
    if (digitos.length == 10 && ![digitos hasPrefix:@"0"]) {
        digitos = [NSString stringWithFormat:@"0%@", digitos];
    }
    return (digitos.length == 11 && [digitos hasPrefix:@"0"]) ? digitos : @"";
}

/**
 El codigo del banco a partir de su nombre.

 La tabla de bancos NO se copia aqui: se usa la del C2P, que es la que de verdad se manda a
 Mercantil. Dos tablas que hay que mantener a la vez acaban distintas, y el sintoma seria
 una recarga rechazada por un codigo viejo.
 */
+ (NSString *)codigoDeBanco:(NSString *)nombre {
    NSString *buscado = [RecargaC2PViewController normalizar:nombre];
    if (buscado.length == 0) {
        return @"";
    }
    for (NSArray<NSString *> *fila in [RecargaC2PViewController bancosPorNombre]) {
        if (fila.count >= 2
            && [[RecargaC2PViewController normalizar:[fila objectAtIndex:0]] isEqualToString:buscado]) {
            return [fila objectAtIndex:1];
        }
    }
    return @"";
}

+ (NSString *)soloDigitos:(NSString *)texto {
    NSMutableString *salida = [[NSMutableString alloc] init];
    for (NSUInteger i = 0; i < texto.length; i++) {
        unichar c = [texto characterAtIndex:i];
        if (c >= '0' && c <= '9') {
            [salida appendFormat:@"%C", c];
        }
    }
    return salida;
}

@end
