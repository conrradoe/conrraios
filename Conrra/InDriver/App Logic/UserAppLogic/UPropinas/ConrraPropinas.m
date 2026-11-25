//
//  ConrraPropinas.m
//  Conrra
//

#import "ConrraPropinas.h"
#import "RecargaEstilo.h"
#import "Keys.h"

@implementation ConrraPropinaAviso
@end

@implementation ConrraPropinas

#pragma mark - El pasajero da

+ (void)darEnViaje:(NSString *)tripId
             monto:(double)monto
     cuandoTermine:(void (^)(BOOL, NSString *_Nullable, double))bloque {
    NSDictionary *campos = @{
        @"trip_id" : tripId.length > 0 ? tripId : @"",
        // Con punto decimal y dos cifras SIEMPRE: el servidor espera "3.50", y en un telefono
        // con el idioma en espanol un %f suelto escribe "3,50", que alli llega como 3.
        @"monto"   : [NSString stringWithFormat:@"%.2f", monto],
    };
    [RecargaEstilo enviarA:URL_TAXI_PROPINA campos:campos
                completado:^(NSDictionary *json, NSError *error) {
        if (json == nil) {
            [self responder:^{ bloque(NO, [self mensajeDe:error], -1); }];
            return;
        }
        id respuesta = json[@"response"];
        double saldo = -1;
        if ([respuesta isKindOfClass:[NSDictionary class]] && respuesta[@"saldo"] != nil) {
            saldo = [respuesta[@"saldo"] doubleValue];
        }
        /*
         Respondio: la propina se dio aunque el resto no se entienda.

         El saldo es informativo -- sirve para refrescar lo que se le ensena --, asi que no
         puede decidir si la propina salio. Tratar un saldo ilegible como fallo haria que el
         pasajero la diera otra vez.
         */
        [self responder:^{ bloque(YES, nil, saldo); }];
    }];
}

#pragma mark - El conductor ve y agradece

+ (void)pendientesDelConductor:(void (^)(NSArray<ConrraPropinaAviso *> *))bloque {
    [self pedirLista:URL_TAXI_PROPINAS_PENDIENTES claveDeQuien:@"de" cuandoTermine:bloque];
}

+ (void)cerrar:(long long)propinaId gracias:(BOOL)gracias texto:(NSString *)texto {
    NSDictionary *campos = @{
        @"propina_id" : [NSString stringWithFormat:@"%lld", propinaId],
        @"gracias"    : gracias ? @"1" : @"0",
        @"texto"      : texto.length > 0 ? texto : @"",
    };
    [RecargaEstilo enviarA:URL_TAXI_PROPINA_CERRAR campos:campos
                completado:^(NSDictionary *json, NSError *error) {
        // No hay nada que hacer con el resultado: el aviso ya se le enseno. Pero se registra,
        // porque un cerrar que falla significa que la propina volvera a salir en el siguiente
        // arranque y conviene saber por que.
        NSLog(@"[Propinas] cerrar %lld: %@", propinaId, json != nil ? @"ok" : @"FALLO");
    }];
}

+ (void)graciasDelPasajero:(void (^)(NSArray<ConrraPropinaAviso *> *))bloque {
    [self pedirLista:URL_TAXI_GRACIAS_PENDIENTES claveDeQuien:@"conductor" cuandoTermine:bloque];
}

#pragma mark - Lo comun

/**
 Las dos listas se leen igual y solo cambia de que campo sale el nombre.

 Si no hay nada que ensenar NO se llama al bloque, igual que Android: asi quien llama no tiene
 que distinguir "no hay propinas" de "no hay sesion", que para una pantalla son lo mismo --
 nada que mostrar -- y escribir el caso vacio invita a ensenar una ventana en blanco.
 */
+ (void)pedirLista:(NSString *)url
      claveDeQuien:(NSString *)claveDeQuien
     cuandoTermine:(void (^)(NSArray<ConrraPropinaAviso *> *))bloque {
    [RecargaEstilo enviarA:url campos:@{}
                completado:^(NSDictionary *json, NSError *error) {
        if (json == nil) {
            return;
        }
        id filas = json[@"response"];
        if (![filas isKindOfClass:[NSArray class]]) {
            return;
        }
        NSMutableArray<ConrraPropinaAviso *> *lista = [NSMutableArray array];
        for (id fila in (NSArray *)filas) {
            if (![fila isKindOfClass:[NSDictionary class]]) {
                continue;
            }
            ConrraPropinaAviso *a = [[ConrraPropinaAviso alloc] init];
            a.propinaId = [[self texto:fila[@"propina_id"]] longLongValue];
            a.monto     = [[self texto:fila[@"monto"]] doubleValue];
            a.quien     = [self texto:fila[claveDeQuien]];
            a.texto     = [self texto:fila[@"texto"]];
            [lista addObject:a];
        }
        if (lista.count == 0) {
            return;
        }
        [self responder:^{ bloque(lista); }];
    }];
}

/**
 Un campo del JSON como texto, venga como texto o como numero.

 El servidor devuelve los importes y los identificadores a veces entre comillas y a veces no
 -- depende de la version de PHP y de si la columna se lee del SELECT o se calcula --, y leer
 un NSNumber como si fuera NSString devuelve basura o revienta.
 */
+ (NSString *)texto:(id)valor {
    if (valor == nil || valor == [NSNull null]) {
        return @"";
    }
    return [NSString stringWithFormat:@"%@", valor];
}

/// El mensaje que el servidor escribio para el usuario, si lo hay.
+ (NSString *)mensajeDe:(NSError *)error {
    NSString *m = error.localizedDescription;
    return m.length > 0 ? m : nil;
}

/// Siempre en el hilo principal: quien llama ensena ventanas y refresca saldos.
+ (void)responder:(void (^)(void))bloque {
    if ([NSThread isMainThread]) {
        bloque();
    } else {
        dispatch_async(dispatch_get_main_queue(), bloque);
    }
}

@end
