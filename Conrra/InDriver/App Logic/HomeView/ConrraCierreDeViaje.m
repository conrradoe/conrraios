//
//  ConrraCierreDeViaje.m
//  Conrra
//

#import "ConrraCierreDeViaje.h"
#import "TripModel.h"
#import "TripTransactionManager.h"
#import "LanguageHelper.h"
#import "WebCallConstants.h"
#import "ConrraChatDeSoporte.h"
#import "CityModel.h"
#import "Utilities.h"
#import <GIKit/GIKit.h>

/// Viajes cuya pregunta del pago ya se hizo, para no preguntar dos veces.
static NSString *const kClaveLiquidados = @"conrra_viajes_liquidados";
/// Viajes que hay que cerrar y todavia no se ha podido. Sobrevive a cerrar la app.
static NSString *const kClavePendientes = @"conrra_cierres_pendientes";

/// Lo que contesto el conductor, tal como se guarda en la lista de pendientes.
static NSString *const kCobrado      = @"cobrado";
static NSString *const kNoCobrado    = @"no_cobrado";
static NSString *const kSinRespuesta = @"sin_respuesta";

/// Cuanto se le deja al conductor para contestar antes de cerrar el viaje por el.
static const NSTimeInterval kMargenParaContestar = 120.0;

@implementation ConrraCierreDeViaje

/// El gestor de cobro se retiene mientras su llamada esta en vuelo: la pantalla que lo pidio
/// puede haberse ido ya, y sin esto la cadena de dos pasos se cortaria por el medio.
static NSMutableArray *gCobrosEnVuelo = nil;

+ (NSString *)limpio:(NSString *)tripId {
    if (![tripId isKindOfClass:[NSString class]]) {
        return @"";
    }
    return [tripId stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

#pragma mark - Los que ya se preguntaron

+ (BOOL)yaSeLiquido:(NSString *)tripId {
    NSString *id_ = [self limpio:tripId];
    if (id_.length == 0) {
        return NO;
    }
    id guardado = defaults_object(kClaveLiquidados);
    return [guardado isKindOfClass:[NSArray class]] && [guardado containsObject:id_];
}

+ (void)apuntarLiquidado:(NSString *)tripId {
    NSString *id_ = [self limpio:tripId];
    if (id_.length == 0) {
        return;
    }
    id guardado = defaults_object(kClaveLiquidados);
    NSMutableArray *lista = [guardado isKindOfClass:[NSArray class]]
        ? [NSMutableArray arrayWithArray:guardado] : [NSMutableArray array];
    [lista removeObject:id_];
    [lista insertObject:id_ atIndex:0];
    while (lista.count > 20) {
        [lista removeLastObject];
    }
    defaults_set_object(kClaveLiquidados, lista);
}

#pragma mark - El cierre

/**
 Deja el viaje LIQUIDADO en el servidor. Es la unica via de cierre: las dos respuestas pasan
 por aqui, y tambien el viaje que se quedo sin contestar.

 QUE SIGNIFICA CERRADO. No lo decide esta app. Lo decide el servidor y lo repiten las dos
 pantallas de Android, y en los dos sitios el campo que cierra un viaje es
 `trip_pay_status = Paid`:

     TripAPI.php:719   if ($trresult['trip_pay_status'] == 'Paid')  ->  d_is_available = 1
     TripAPI.php:507   " (trip_status = 'completed') AND trip_pay_status = 'Paid' "

     riderapp/utils/Utils.java:243   Paid && (paid_cancel || completed)      ->  "Completado"
     riderapp/utils/Utils.java:245   paid_cancel || (!Paid && completed)     ->  "Pago pendiente"

 De ahi venia el fallo. Cerrar con `trip_status = paid_cancel` A SECAS -- que es lo que hace
 Android en su rama de impago (FareSummaryActivity.java:953) -- cae en la segunda linea: "pago
 pendiente". El viaje no queda cerrado, queda esperando dinero, y el PASAJERO se queda mirando
 su recibo. Medido en el viaje 4039: la peticion entro a la PRIMERA y el pasajero siguio
 atrapado, asi que nunca fue un problema de red.

 Las dos respuestas escriben entonces `trip_pay_status = Paid`, y lo que cambia entre ellas es
 el `trip_status`, que es donde queda el REGISTRO de lo que paso:

     cobrado     ->  completed     el dinero llego
     no cobrado  ->  paid_cancel   el conductor no recibio el pago

 Con el pago marcado, esa pareja cae en la PRIMERA linea de Utils.java: cerrado para los dos
 lados, sin perder cual de los dos casos fue.

 NO SE TOCA `trip_pay_mode`. El viaje ya lo trae con lo que eligio el pasajero -- "Pago Movil"
 en la ultima prueba -- y sobreescribirlo borraria como se pago de verdad.
 */
+ (void)liquidar:(NSString *)tripId
           viaje:(TripModel *)viaje
         cobrado:(BOOL)cobrado
         intento:(NSInteger)intento {
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{
        @"trip_id"         : tripId,
        @"trip_pay_status" : TS_PAID,
        @"trip_pay_date"   : [Utilities getStringFromDate:[NSDate date]],
        TRIP_STATUS        : (cobrado ? TS_END : TS_RIDER_CANCEL_CANCEL),
    }];
    [GIC mkwu:TRIP_UPDATE d:dict isa:NO cb:^(id results, NSError *error) {
        BOOL ok = [[[results objectForKey:P_STATUS] uppercaseString] isEqualToString:@"OK"];
        if (ok) {
            [self olvidarPendiente:tripId];
            NSLog(@"[CierreDeViaje] viaje %@ CERRADO (%@, trip_pay_status=Paid) en el intento %ld",
                  tripId, (cobrado ? @"cobrado" : @"NO cobrado"), (long)intento);
            if (!cobrado && viaje != nil) {
                [self avisarAlPasajeroDeQueNoHuboCobro:viaje];
            }
            return;
        }
        // El motivo del servidor, escrito entero: es lo unico que distingue "no llego la
        // peticion" de "llego y la rechazo", y sin eso se diagnostica a ciegas.
        NSLog(@"[CierreDeViaje] FALLO al cerrar el viaje %@ (intento %ld). error=%@ respuesta=%@",
              tripId, (long)intento, error.localizedDescription, results);
        if (intento < 3) {
            NSTimeInterval espera = intento * 2.0;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(espera * NSEC_PER_SEC)),
                           dispatch_get_main_queue(), ^{
                [self liquidar:tripId viaje:viaje cobrado:cobrado intento:intento + 1];
            });
        } else {
            NSLog(@"[CierreDeViaje] el viaje %@ queda PENDIENTE: se reintentara al volver a la app",
                  tripId);
        }
    }];
}

#pragma mark - Los que quedaron pendientes

/// La lista de pendientes, siempre como diccionario: id -> { respuesta, cuando }.
+ (NSMutableDictionary *)pendientes {
    id guardado = defaults_object(kClavePendientes);
    if ([guardado isKindOfClass:[NSDictionary class]]) {
        return [NSMutableDictionary dictionaryWithDictionary:guardado];
    }
    // La version anterior guardaba una lista de ids, y todos querian decir "no cobrado".
    NSMutableDictionary *migrada = [NSMutableDictionary dictionary];
    if ([guardado isKindOfClass:[NSArray class]]) {
        for (id id_ in guardado) {
            if ([id_ isKindOfClass:[NSString class]] && [id_ length] > 0) {
                migrada[id_] = @{ @"r" : kNoCobrado, @"t" : @0 };
            }
        }
    }
    return migrada;
}

+ (void)apuntarPendiente:(NSString *)tripId respuesta:(NSString *)respuesta {
    NSString *id_ = [self limpio:tripId];
    if (id_.length == 0) {
        return;
    }
    NSMutableDictionary *lista = [self pendientes];
    lista[id_] = @{ @"r" : respuesta,
                    @"t" : @([[NSDate date] timeIntervalSince1970]) };
    defaults_set_object(kClavePendientes, lista);
}

+ (void)olvidarPendiente:(NSString *)tripId {
    NSMutableDictionary *lista = [self pendientes];
    if (lista[tripId] == nil) {
        return;
    }
    [lista removeObjectForKey:tripId];
    defaults_set_object(kClavePendientes, lista);
}

/**
 Vuelve a intentar los cierres que quedaron sin confirmar.

 Aqui entra tambien el caso incomodo: el conductor termino el viaje y NO contesto la pregunta
 -- se fue a WhatsApp desde la hoja de soporte, cerro la app, se quedo sin bateria. Pasado el
 margen para contestar, ese viaje se cierra como NO cobrado, que es el registro honesto: nadie
 confirmo que el dinero llegase. Lo que no puede pasar es que se quede abierto, porque el que
 lo paga es el pasajero, que sigue mirando un recibo que no avanza.
 */
+ (void)reintentarCierresPendientes {
    NSMutableDictionary *lista = [self pendientes];
    if (lista.count == 0) {
        return;
    }
    NSTimeInterval ahora = [[NSDate date] timeIntervalSince1970];
    for (NSString *tripId in [lista allKeys]) {
        NSDictionary *fila = lista[tripId];
        if (![fila isKindOfClass:[NSDictionary class]]) {
            continue;
        }
        NSString *respuesta = fila[@"r"];
        NSTimeInterval cuando = [fila[@"t"] doubleValue];

        if ([respuesta isEqualToString:kSinRespuesta]) {
            if (ahora - cuando < kMargenParaContestar) {
                // La pregunta puede estar todavia en pantalla. Se le deja contestar.
                continue;
            }
            NSLog(@"[CierreDeViaje] el viaje %@ termino sin respuesta: se cierra como NO cobrado",
                  tripId);
            [self liquidar:tripId viaje:nil cobrado:NO intento:1];
            continue;
        }
        // Sin el objeto del viaje no se puede avisar al pasajero por push, pero el estado en el
        // servidor es lo que de verdad lo libera: su recibo lo sondea cada diez segundos.
        NSLog(@"[CierreDeViaje] se reintenta el cierre del viaje %@ (%@)", tripId, respuesta);
        [self liquidar:tripId viaje:nil cobrado:[respuesta isEqualToString:kCobrado] intento:1];
    }
}

#pragma mark - El aviso al pasajero

/**
 Le dice al PASAJERO que el viaje se cerro sin cobro.

 No se usa TripNotificationHelper a proposito, y la razon es doble:

   1. Su mensaje sale de una cadena de if/else por estado que NO contempla paid_cancel, asi
      que quedaba nil y el diccionario literal reventaba al construirse:
      "attempt to insert nil object from objects[0]". Ese objects[0] era el mensaje.
   2. Aunque no reventara, ese helper manda al CONDUCTOR -- pone "to" en driver y usa el
      token del conductor -- y aqui hace falta avisar al pasajero, que es quien se queda
      mirando su recibo sin saber que el viaje ya termino.

 El aviso es una cortesia, NO el cierre. Si se pierde -- y en la ultima prueba se perdio, sale
 "FALLO" en el log --, el recibo del pasajero sondea el viaje cada diez segundos
 (FareActivity.java, RepeatTimerManager a 10000 ms) y vera el estado nuevo igualmente. Lo que
 libera al pasajero es la fila en la base de datos, no este push.

 El texto va escrito aqui y no por clave de idioma porque no existe ninguna para este caso;
 cuando la haya, se cambia esta linea.
 */
+ (void)avisarAlPasajeroDeQueNoHuboCobro:(TripModel *)viaje {
    NSString *token = isEmpty(viaje.user.deviceToken);
    if (token.length == 0) {
        NSLog(@"[CierreDeViaje] el pasajero no tiene token: no se le puede avisar del cierre");
        return;
    }
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{
        @"message"           : @"El conductor cerró el viaje como no pagado. Si ya pagaste, escríbenos.",
        TRIP_STATUS          : TS_RIDER_CANCEL_CANCEL,
        TRIP_ID              : isEmpty(viaje.trip_Id),
        @"to"                : @"user",
        @"content-available" : @"1",
    }];
    [dict setObject:token forKey:([viaje.user.deviceType isEqualToString:IOS] ? IOS_TOKEN : ANDROID_TOKEN)];
    [GIC mk:url_notification to:send_user_notification d:dict isa:NO cb:^(id results, NSError *error) {
        BOOL ok = [[[results objectForKey:P_STATUS] uppercaseString] isEqualToString:@"OK"];
        NSLog(@"[CierreDeViaje] aviso de cierre al pasajero: %@", ok ? @"enviado" : @"FALLO");
    }];
}

#pragma mark - La contabilidad del cobro

/**
 Registra la transaccion del cobro: comision del conductor y apunte en la cartera.

 VA SUELTA, DESPUES DEL CIERRE, Y A PROPOSITO. Antes el cierre colgaba de esto:
 payWithCashDetectComssion llama a GET_WALLET_ADD_TRIP_TRAN y SOLO si esa responde OK pasa a
 escribir trip_pay_status (TripTransactionManager.m:45-58). Con lo cual un fallo en el apunte
 de la cartera dejaba el viaje sin cerrar y al pasajero encerrado -- por un problema de
 contabilidad, no de viaje. La rama del "Si" tenia el mismo agujero que la del "No".

 Son dos cosas distintas y ahora van en ese orden: primero se cierra el viaje, luego se cuadran
 las cuentas. Si el apunte falla, falta un registro que se puede rehacer; si el cierre falla,
 hay una persona atrapada en su telefono.
 */
+ (void)registrarElCobro:(TripModel *)viaje {
    if (gCobrosEnVuelo == nil) {
        gCobrosEnVuelo = [[NSMutableArray alloc] init];
    }
    TripTransactionManager *gestor = [[TripTransactionManager alloc] initWithTrip:viaje];
    [gCobrosEnVuelo addObject:gestor];
    [gestor payWithCashDetectComssion];
    // Se suelta a los treinta segundos: para entonces la cadena de dos pasos ya termino, y
    // guardarlo mas tiempo solo seria memoria retenida sin motivo.
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(30.0 * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
        [gCobrosEnVuelo removeObject:gestor];
    });
}

#pragma mark - La pregunta

+ (void)preguntarPorElPagoDesde:(UIViewController *)vc
                          viaje:(TripModel *)viaje
                     alTerminar:(void (^)(void))alTerminar {
    void (^seguir)(void) = ^{
        if (alTerminar == nil) {
            return;
        }
        if ([NSThread isMainThread]) {
            alTerminar();
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{ alTerminar(); });
        }
    };

    NSString *id_ = [self limpio:viaje.trip_Id];
    // Sin viaje, sin id, o ya liquidado: no hay nada que preguntar y se sigue. Nunca se deja
    // al que llama esperando un bloque que no llega.
    if (viaje == nil || id_.length == 0 || [self yaSeLiquido:id_]) {
        seguir();
        return;
    }
    // Si el servidor ya lo da por cobrado, tampoco se pregunta. Se mira SOLO el pago: un
    // trip_status en paid_cancel sin el pago marcado es justo el viaje a medias que hay que
    // acabar de cerrar, no una razon para no preguntar.
    if ([isEmpty(viaje.trip_pay_status) caseInsensitiveCompare:TS_PAID] == NSOrderedSame) {
        [self apuntarLiquidado:id_];
        seguir();
        return;
    }

    /*
     EL VIAJE SE APUNTA ANTES DE PREGUNTAR.

     Desde este momento hay un viaje terminado y sin liquidar, y eso tiene a alguien esperando
     al otro lado. Si el conductor no llega a contestar, reintentarCierresPendientes lo cierra
     por el al volver la app a primer plano. La pregunta decide QUE se registra, no SI se
     cierra: el viaje se cierra en cualquier caso.
     */
    [self apuntarPendiente:id_ respuesta:kSinRespuesta];

    if (vc == nil) {
        // No hay donde preguntar. Se cierra igual, con el registro conservador.
        [self apuntarLiquidado:id_];
        [self apuntarPendiente:id_ respuesta:kNoCobrado];
        [self liquidar:id_ viaje:viaje cobrado:NO intento:1];
        seguir();
        return;
    }

    UIAlertController *alert = [UIAlertController
        alertControllerWithTitle:@""
                         message:[LanguageHelper getStringWithKey:@"k_19_s8_pregunta_pago"
                                                     defaultValue:@"¿Recibiste el Pago del Pasajero?"]
                  preferredStyle:UIAlertControllerStyleAlert];

    [alert addAction:[UIAlertAction actionWithTitle:[LanguageHelper getStringWithKey:@"k_21_s4_yes"]
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction *action) {
        [self apuntarLiquidado:id_];
        [self apuntarPendiente:id_ respuesta:kCobrado];
        [self liquidar:id_ viaje:viaje cobrado:YES intento:1];
        [self registrarElCobro:viaje];
        seguir();
    }]];

    [alert addAction:[UIAlertAction actionWithTitle:[LanguageHelper getStringWithKey:@"k_22_s4_no"]
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction *action) {
        [self apuntarLiquidado:id_];
        [self apuntarPendiente:id_ respuesta:kNoCobrado];
        [self liquidar:id_ viaje:viaje cobrado:NO intento:1];
        // Soporte se abre con el viaje y el importe ya escritos, y el ciclo sigue en cuanto
        // esa hoja se cierre. Decir que no te pagaron no puede costarte quedarte parado.
        NSString *monto = @"";
        NSString *crudo = isEmpty(viaje.trip_fare);
        if (crudo.length > 0) {
            CityModel *ciudad = [CityModel getCityByCityId:viaje.city_id];
            NSString *conMoneda = [Utilities formatAmountAndCurrency:[crudo floatValue]
                                                            currency:ciudad.city_cur];
            monto = conMoneda.length > 0 ? conMoneda : crudo;
        }
        [ConrraChatDeSoporte abrirEn:vc
                              motivo:ConrraMotivoPagoNoRecibido
                               viaje:id_
                               monto:monto
                            alCerrar:^{ seguir(); }];
    }]];

    dispatch_async(dispatch_get_main_queue(), ^{
        [vc presentViewController:alert animated:YES completion:nil];
    });
}

@end
