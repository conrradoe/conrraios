//
//  ConrraNumeroVerificado.m
//  Conrra
//

#import "ConrraNumeroVerificado.h"
#import "ConrraVerificacionTelefono.h"
#import "ConrraTelefonoE164.h"
#import "ConrraPuertaVerificacion.h"
#import "ConstantModel.h"
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
+ (NSString *)idDelUsuario {
    NSDictionary *usuario = [self usuario];
    if (usuario == nil) {
        return nil;
    }
    NSString *id_ = [NSString stringWithFormat:@"%@", [usuario objectForKey:P_USER_ID]];
    id_ = [id_ stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return (id_.length == 0 || [id_ isEqualToString:@"(null)"]) ? nil : id_;
}

+ (NSString *)clave {
    // El nombre de la clave lo da la puerta, que es la misma en las dos plataformas.
    return [ConrraPuertaVerificacion claveDe:[self idDelUsuario]];
}

+ (BOOL)haceFalta {
    /*
     LA DECISION NO SE TOMA AQUI: la toma ConrraPuertaVerificacion, que es pura y tiene sus
     dieciseis combinaciones probadas. Aqui solo se reunen los cuatro datos.

     Lo que SI se decide aqui son dos cosas que no son de la puerta: que con el camino viejo
     no se pide nada -- un codigo que la propia app se inventa no prueba nada, asi que
     bloquear por el seria molestar sin ganar nada -- y que con la verificacion apagada
     tampoco, porque no habria codigo que esperar.
     */
    if (![ConrraVerificacionTelefono loVerificaElServidor]) {
        return NO;
    }
    if ([ConrraVerificacionTelefono apagadaPara:[self usuario]]) {
        return NO;
    }

    const BOOL encendida = [ConstantModel getConstantsObject].verificacion_obligatoria;
    NSString *id_ = [self idDelUsuario];
    const BOOL haySesion = (id_ != nil);
    NSString *clave = [self clave];
    const BOOL yaVerificado = haySesion && [defaults_object(clave) boolValue];
    NSString *numero = [self telefonoDelUsuario];

    if ([ConrraPuertaVerificacion seQuedaSinSalidaConPuerta:encendida
                                                 haySesion:haySesion
                                              yaVerificado:yaVerificado
                                                numeroE164:numero]) {
        /*
         Se le deja pasar. En Android lo midieron: 1 de 4.867 usuarios tiene el telefono
         guardado de forma que no da ni para un E.164, por un c_code corrupto. Bloquear a
         quien NO PUEDE verificar es dejarlo sin app y sin nada que hacer; queda en el log
         para arreglarle la fila.
         */
        NSLog(@"[NumeroVerificado] el usuario %@ no puede formar un E.164: se le deja pasar"
              @" y hay que arreglarle la fila", id_);
    }
    if (haySesion && clave == nil) {
        NSLog(@"[NumeroVerificado] el usuario en sesion no trae %@: no se pide nada", P_USER_ID);
        return NO;
    }
    return [ConrraPuertaVerificacion hayQueVerificarConPuerta:encendida
                                                   haySesion:haySesion
                                                yaVerificado:yaVerificado
                                                  numeroE164:numero];
}

+ (void)anotarVerificado {
    [self anotarVerificadoDelUsuario:[self idDelUsuario]];
}

+ (void)anotarVerificadoDelUsuario:(NSString *)usuarioId {
    NSString *clave = [ConrraPuertaVerificacion claveDe:usuarioId];
    if (clave == nil) {
        NSLog(@"[NumeroVerificado] no hay id de usuario: la verificacion no queda apuntada");
        return;
    }
    defaults_set_object(clave, @YES);
}

+ (NSString *)idEnSesion {
    return [self idDelUsuario];
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
