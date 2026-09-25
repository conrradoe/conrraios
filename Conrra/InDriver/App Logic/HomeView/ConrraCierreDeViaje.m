//
//  ConrraCierreDeViaje.m
//  Conrra
//

#import "ConrraCierreDeViaje.h"
#import "TripModel.h"
#import "TripNotificationHelper.h"
#import "TripTransactionManager.h"
#import "LanguageHelper.h"
#import "WebCallConstants.h"
#import "ConrraChatDeSoporte.h"
#import "CityModel.h"
#import "Utilities.h"
#import <GIKit/GIKit.h>

static NSString *const kClaveLiquidados = @"conrra_viajes_liquidados";

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

#pragma mark - Las dos liquidaciones

/** El pasajero pago: se registra el cobro y el viaje queda en Paid. */
+ (void)cobrado:(TripModel *)viaje {
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

/** El pasajero no pago: el viaje se cierra como paid_cancel, igual que en Android. */
+ (void)noCobrado:(TripModel *)viaje {
    NSString *id_ = [self limpio:viaje.trip_Id];
    if (id_.length == 0) {
        return;
    }
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{
        @"trip_id"  : id_,
        TRIP_STATUS : TS_RIDER_CANCEL_CANCEL,
    }];
    [GIC mkwu:TRIP_UPDATE d:dict isa:NO cb:^(id results, NSError *error) {
        BOOL ok = [[[results objectForKey:P_STATUS] uppercaseString] isEqualToString:@"OK"];
        NSLog(@"[CierreDeViaje] viaje %@ cerrado como NO pagado: %@", id_, ok ? @"si" : @"FALLO");
        if (ok) {
            [self avisarAlPasajeroDelCierre:viaje];
        }
    }];
}

/**
 Le dice al PASAJERO que el viaje se cerro sin cobro.

 No se usa TripNotificationHelper a proposito, y la razon es doble:

   1. Su mensaje sale de una cadena de if/else por estado que NO contempla paid_cancel, asi
      que quedaba nil y el diccionario literal reventaba al construirse:
      "attempt to insert nil object from objects[0]". Ese objects[0] era el mensaje.
   2. Aunque no reventara, ese helper manda al CONDUCTOR -- pone "to" en driver y usa el
      token del conductor -- y aqui hace falta avisar al pasajero, que es quien se queda
      mirando su recibo sin saber que el viaje ya termino.

 El texto va escrito aqui y no por clave de idioma porque no existe ninguna para este caso;
 cuando la haya, se cambia esta linea.
 */
+ (void)avisarAlPasajeroDelCierre:(TripModel *)viaje {
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
    // Si el servidor ya lo da por cobrado o por cerrado sin cobro, tampoco se pregunta.
    NSString *estadoDelPago = isEmpty(viaje.trip_pay_status);
    if ([estadoDelPago caseInsensitiveCompare:TS_PAID] == NSOrderedSame ||
        [estadoDelPago caseInsensitiveCompare:TS_RIDER_CANCEL_CANCEL] == NSOrderedSame) {
        [self apuntarLiquidado:id_];
        seguir();
        return;
    }
    if (vc == nil) {
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
        [self cobrado:viaje];
        seguir();
    }]];

    [alert addAction:[UIAlertAction actionWithTitle:[LanguageHelper getStringWithKey:@"k_22_s4_no"]
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction *action) {
        [self apuntarLiquidado:id_];
        [self noCobrado:viaje];
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
