//
//  ConrraNumeroVerificado.m
//  Conrra
//

#import "ConrraNumeroVerificado.h"
#import "ConrraVerificacionTelefono.h"
#import "ConrraTelefonoE164.h"
#import "WebCallConstants.h"
#import <GIKit/GIKit.h>

@implementation ConrraNumeroVerificado

/// El usuario que hay en sesion, o nil.
+ (NSDictionary *)usuario {
    NSDictionary *dict = defaults_object(P_USER_DICT);
    return [dict isKindOfClass:[NSDictionary class]] ? dict : nil;
}

/**
 La marca va POR USUARIO, no suelta.

 Si fuera una sola bandera, verificar con una cuenta dejaria verificada la siguiente que
 entrara en ese telefono. Es la misma leccion que costo encontrar en el estado del envio:
 atar el dato a quien pertenece, siempre.
 */
+ (NSString *)clave {
    NSDictionary *usuario = [self usuario];
    NSString *id_ = [NSString stringWithFormat:@"%@", [usuario objectForKey:P_USER_ID]];
    id_ = [id_ stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (id_.length == 0 || [id_ isEqualToString:@"(null)"]) {
        return nil;
    }
    return [@"conrra_numero_verificado_" stringByAppendingString:id_];
}

+ (BOOL)haceFalta {
    NSDictionary *usuario = [self usuario];
    if (usuario == nil) {
        return NO;                       // nadie en sesion: ya pasara por entrar
    }
    NSString *clave = [self clave];
    if (clave == nil) {
        NSLog(@"[NumeroVerificado] el usuario en sesion no trae %@: no se pide nada", P_USER_ID);
        return NO;                       // sin id no se puede recordar nada
    }
    if ([defaults_object(clave) boolValue]) {
        return NO;                       // ya lo hizo
    }
    if (![ConrraVerificacionTelefono loVerificaElServidor]) {
        return NO;                       // el camino viejo no prueba nada: no vale pedirlo
    }
    if ([ConrraVerificacionTelefono apagadaPara:usuario]) {
        return NO;                       // apagada: no hay codigo que esperar
    }
    /*
     SIN NUMERO NO SE BLOQUEA, y esto es lo que evita dejar a alguien encerrado.

     Si del usuario guardado no sale un E.164 -- le falta el prefijo, o el telefono --, pedirle
     un codigo es pedirle algo que no puede llegar: se queda ante seis casillas para siempre y
     sin forma de salir salvo borrar el app. Se deja pasar y queda en el log.
     */
    if ([self telefonoDelUsuario].length == 0) {
        NSLog(@"[NumeroVerificado] del usuario en sesion no sale un numero E.164: se deja pasar");
        return NO;
    }
    return YES;
}

+ (void)anotarVerificado {
    NSString *clave = [self clave];
    if (clave == nil) {
        return;
    }
    defaults_set_object(clave, @YES);
}

+ (NSString *)prefijoDelUsuario {
    NSDictionary *usuario = [self usuario];
    NSString *prefijo = [NSString stringWithFormat:@"%@", [usuario objectForKey:P_C_CODE]];
    return [ConrraTelefonoE164 soloDigitos:prefijo];
}

+ (NSString *)telefonoDelUsuario {
    return [ConrraTelefonoE164 de:[self prefijoDelUsuario]
                          nacional:[ConrraTelefonoE164 nacionalDe:[self usuario]]];
}

+ (void)olvidar {
    NSString *clave = [self clave];
    if (clave != nil) {
        defaults_remove(clave);
    }
}

@end
