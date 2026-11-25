//
//  ConrraBonos.m
//  Conrra
//

#import "ConrraBonos.h"
#import "ConrraFiesta.h"
#import "ConrraChatDeSoporte.h"
#import "RecargaEstilo.h"
#import "LanguageHelper.h"
#import "WebCallConstants.h"
#import "Keys.h"
#import <GIKit/GIKit.h>

/// La marca del registro, con el id de la cuenta dentro.
static NSString *const kMarcaBienvenida = @"conrra_bienvenida_pendiente_user";

@implementation ConrraBonos

#pragma mark - Bienvenida

+ (void)marcarCuentaNueva:(NSString *)usuarioId {
    NSString *id_ = [self limpio:usuarioId];
    if (id_.length == 0) {
        return;
    }
    defaults_set_object(kMarcaBienvenida, id_);
}

+ (void)revisarBienvenidaEn:(UIViewController *)vc {
    if (vc == nil || vc.view.window == nil) {
        return;
    }
    NSString *pendiente = [self limpio:defaults_object(kMarcaBienvenida)];
    if (pendiente.length == 0) {
        return;
    }
    // Al conductor no se le da la bienvenida del pasajero, aunque la marca estuviera puesta.
    if (![ConrraChatDeSoporte esPasajero]) {
        return;
    }
    NSDictionary *cuenta = defaults_object(P_USER_DICT);
    NSString *id_ = [self limpio:[NSString stringWithFormat:@"%@", [cuenta objectForKey:P_USER_ID]]];
    if (id_.length == 0) {
        return;
    }
    if (![pendiente isEqualToString:id_]) {
        // Marca de OTRA cuenta: se borra sin celebrar nada. Pasa cuando alguien se registra,
        // cierra sesion y entra con otro usuario en el mismo telefono.
        defaults_remove(kMarcaBienvenida);
        return;
    }

    /*
     SE CONSUME AQUI, antes de decidir si hay fiesta.

     Si se borrara solo cuando la fiesta sale, una cuenta nueva sin saldo -- porque el bono
     del servidor fallo, o porque ya se lo gasto -- dejaria la marca puesta y la pantalla lo
     reintentaria en cada vuelta a primer plano, para siempre.
     */
    defaults_remove(kMarcaBienvenida);

    double saldo = [[NSString stringWithFormat:@"%@",
                     [cuenta objectForKey:P_USER_WAlLET_AMOUNT]] doubleValue];
    if (saldo <= 0) {
        NSLog(@"[Bonos] cuenta nueva %@ sin saldo que celebrar", id_);
        return;
    }

    NSString *nombre = [self primerNombreDe:[cuenta objectForKey:P_U_FNAME]];
    NSString *titulo = nombre.length > 0
        ? [NSString stringWithFormat:
           [LanguageHelper getStringWithKey:@"bienvenida_titulo_nombre"
                               defaultValue:@"¡Bienvenido a Conrra, %@!"], nombre]
        : [LanguageHelper getStringWithKey:@"bienvenida_titulo"
                             defaultValue:@"¡Bienvenido a Conrra!"];

    [ConrraFiesta celebrarEn:vc
                       monto:[NSString stringWithFormat:@"+ %@", [ConrraFiesta conMoneda:saldo]]
                      titulo:titulo
                       texto:[LanguageHelper getStringWithKey:@"bienvenida_mensaje"
                                                 defaultValue:@"Te regalamos un bono de bienvenida. "
                                                               "Ya está en tu billetera para tu primer viaje."]
                    conCampo:NO
                    alMontar:nil
                    acciones:@[[LanguageHelper getStringWithKey:@"bienvenida_boton"
                                                   defaultValue:@"¡Empezar!"]]
                 alResponder:nil];
}

#pragma mark - Referido

+ (void)buscarYCelebrarReferidoEn:(UIViewController *)vc {
    if (vc == nil || vc.view.window == nil) {
        return;
    }
    // El rol va en la peticion porque el servidor paga distinto a cada lado. La api_key la
    // pone RecargaEstilo, igual que en las propinas.
    NSDictionary *campos = [ConrraChatDeSoporte esPasajero] ? @{} : @{ @"rol" : @"conductor" };

    [RecargaEstilo enviarA:URL_TAXI_REFERIDOS campos:campos
                completado:^(NSDictionary *json, NSError *error) {
        if (json == nil) {
            return;   // silencioso: es un extra
        }
        id lista = json[@"response"];
        if (![lista isKindOfClass:[NSArray class]] || [lista count] == 0) {
            return;
        }
        id fila = [lista firstObject];
        if (![fila isKindOfClass:[NSDictionary class]]) {
            return;
        }
        /*
         UNO POR VEZ. Si hubiera varios, el resto sale al volver a la pantalla: ya estan
         acreditados y marcados por el servidor, asi que no se pierde dinero -- solo la fiesta
         se reparte en varias vueltas. Encimar tres tarjetas seria peor.
         */
        double monto = [[NSString stringWithFormat:@"%@", fila[@"monto"]] doubleValue];
        NSString *otro = [self limpio:[NSString stringWithFormat:@"%@", fila[@"otro"]]];
        BOOL invito = [[self limpio:[NSString stringWithFormat:@"%@", fila[@"rol"]]]
                       isEqualToString:@"referidor"];

        NSString *texto;
        if (invito) {
            texto = otro.length > 0
                ? [NSString stringWithFormat:
                   [LanguageHelper getStringWithKey:@"bono_ref_referidor_nombre"
                     defaultValue:@"%@, a quien invitaste, completó su primer viaje. Tu bono por "
                                   "referido ya está acreditado en tu billetera."], otro]
                : [LanguageHelper getStringWithKey:@"bono_ref_referidor"
                     defaultValue:@"Tu invitado completó su primer viaje. Tu bono por referido ya "
                                   "está acreditado en tu billetera."];
        } else {
            texto = otro.length > 0
                ? [NSString stringWithFormat:
                   [LanguageHelper getStringWithKey:@"bono_ref_referido_nombre"
                     defaultValue:@"Completaste tu primer viaje con el código de %@. Tu bono por "
                                   "referido ya está acreditado en tu billetera."], otro]
                : [LanguageHelper getStringWithKey:@"bono_ref_referido"
                     defaultValue:@"Completaste tu primer viaje con un código de referido. Tu bono "
                                   "ya está acreditado en tu billetera."];
        }

        [ConrraFiesta celebrarEn:vc
                           monto:(monto > 0 ? [NSString stringWithFormat:@"+ %@",
                                               [ConrraFiesta conMoneda:monto]] : nil)
                          titulo:[LanguageHelper getStringWithKey:@"bono_ref_titulo"
                                                     defaultValue:@"¡Tu bono por referido ya llegó!"]
                           texto:texto
                        conCampo:NO
                        alMontar:nil
                        acciones:@[[LanguageHelper getStringWithKey:@"k_18_s4_Ok"
                                                       defaultValue:@"Entendido"]]
                     alResponder:nil];
    }];
}

#pragma mark - Detalles

/**
 El primer nombre, para tutear sin soltarle el apellido.

 Si no hay nombre se devuelve vacio y el titulo sale sin el: "¡Bienvenido a Conrra!" en vez de
 "¡Bienvenido a Conrra, !", que es lo que saldria formateando un vacio.
 */
+ (NSString *)primerNombreDe:(id)nombre {
    NSString *n = [self limpio:[NSString stringWithFormat:@"%@", nombre]];
    if (n.length == 0) {
        return @"";
    }
    NSArray *trozos = [n componentsSeparatedByCharactersInSet:
                       [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    for (NSString *t in trozos) {
        if (t.length > 0) {
            return t;
        }
    }
    return @"";
}

/// Sin espacios y sin los "null" de texto, que es lo que sale de formatear un nil con %@.
+ (NSString *)limpio:(id)valor {
    if (![valor isKindOfClass:[NSString class]]) {
        return @"";
    }
    NSString *s = [valor stringByTrimmingCharactersInSet:
                   [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return ([s caseInsensitiveCompare:@"null"] == NSOrderedSame
            || [s isEqualToString:@"(null)"]) ? @"" : s;
}

@end
