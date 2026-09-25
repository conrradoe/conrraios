//
//  ConrraVoyEnCamino.m
//  Conrra
//

#import "ConrraVoyEnCamino.h"
#import "TripModel.h"
#import "TripModel+Helper.h"
#import "WebCallConstants.h"
#import "LanguageHelper.h"
#import "FireBaseModel.h"
#import <GIKit/GIKit.h>

@implementation ConrraVoyEnCamino

#pragma mark - La marca, por viaje

+ (NSString *)claveDelViaje:(NSString *)tripId {
    NSString *id_ = [isEmpty(tripId) stringByTrimmingCharactersInSet:
                     [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return id_.length > 0 ? [NSString stringWithFormat:@"voy_en_camino_%@", id_] : @"";
}

+ (BOOL)yaAvisoEnElViaje:(NSString *)tripId {
    NSString *clave = [self claveDelViaje:tripId];
    if (clave.length == 0) {
        return NO;
    }
    return [[NSString stringWithFormat:@"%@", defaults_object(clave) ?: @""] isEqualToString:@"1"];
}

+ (void)olvidarElViaje:(NSString *)tripId {
    NSString *clave = [self claveDelViaje:tripId];
    if (clave.length > 0) {
        defaults_remove(clave);
    }
}

#pragma mark - Los datos del coche

/** Deja una cadena util, o vacia: recorta y trata "null" como si no hubiera nada. */
+ (NSString *)util:(id)valor {
    if (![valor isKindOfClass:[NSString class]]) {
        return @"";
    }
    NSString *t = [(NSString *)valor stringByTrimmingCharactersInSet:
                   [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return [t caseInsensitiveCompare:@"null"] == NSOrderedSame ? @"" : t;
}

/**
 El coche, con la misma prioridad que Android: car_name, luego marca+modelo, luego la
 categoria, y "Vehículo" si no hay nada. El pasajero tiene que poder reconocerlo en la calle,
 asi que vale mas un dato aproximado que un hueco.
 */
+ (NSString *)cocheDe:(TripModel *)viaje {
    DriverModel *conductor = viaje.driver;
    NSString *coche = [self util:conductor.car_name];
    if (coche.length == 0) {
        NSString *marca = [self util:conductor.car_make];
        NSString *modelo = [self util:conductor.car_model];
        if (marca.length > 0) {
            coche = modelo.length > 0 ? [NSString stringWithFormat:@"%@ %@", marca, modelo] : marca;
        }
    }
    if (coche.length == 0) {
        coche = [self util:viaje.cat_name];
    }
    return coche.length > 0 ? coche : @"Vehículo";
}

+ (NSString *)placaDe:(TripModel *)viaje {
    NSString *placa = [self util:viaje.driver.car_registration_no];
    return placa.length > 0 ? placa : @"S/P";
}

+ (NSString *)nombreDelConductor:(TripModel *)viaje {
    NSString *nombre = [self util:viaje.driver.d_fname];
    NSString *apellido = [self util:viaje.driver.d_lname];
    if (nombre.length > 0 && apellido.length > 0) {
        return [NSString stringWithFormat:@"%@ %@", nombre, apellido];
    }
    if (nombre.length > 0 || apellido.length > 0) {
        return nombre.length > 0 ? nombre : apellido;
    }
    NSDictionary *dict = defaults_object(P_USER_DICT);
    return [dict isKindOfClass:[NSDictionary class]] ? [self util:[dict objectForKey:@"d_name"]] : @"";
}

#pragma mark - El aviso

+ (void)avisarDesdeElViaje:(TripModel *)viaje {
    if (viaje == nil) {
        return;
    }
    NSString *tripId = [isEmpty(viaje.trip_Id) stringByTrimmingCharactersInSet:
                        [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (tripId.length == 0) {
        return;
    }
    if ([self yaAvisoEnElViaje:tripId]) {
        NSLog(@"[VoyEnCamino] ya se aviso en el viaje %@, no se repite", tripId);
        return;
    }
    // La marca se pone ANTES de mandar nada. Si se pusiera despues, dos toques seguidos --
    // que es exactamente lo que pasaba en Android -- mandarian el aviso dos veces.
    defaults_set_object([self claveDelViaje:tripId], @"1");

    [self mandarElPush:viaje];
    [self escribirEnElChat:viaje];
}

/**
 El push informativo al pasajero.

 Va con type "notif" a proposito. El manejador del pasajero en iOS
 (AppDelegate manageRemoteNotificationUser:) mira `type` ANTES que `trip_status`: si viene,
 enseña el aviso y sale sin tocar el estado de la pantalla. Es lo que se quiere -- avisar sin
 mover el viaje. Y trip_status va como "go", que no es un estado real del viaje sino la
 etiqueta que usa Android para este aviso.
 */
+ (void)mandarElPush:(TripModel *)viaje {
    NSString *token = isEmpty(viaje.user.deviceToken);
    if (token.length == 0) {
        NSLog(@"[VoyEnCamino] el pasajero del viaje %@ no tiene token: no hay push",
              isEmpty(viaje.trip_Id));
        return;
    }
    NSString *color = [self util:viaje.driver.car_color];
    NSString *coche = [self cocheDe:viaje];
    NSString *cocheConColor = color.length > 0
        ? [NSString stringWithFormat:@"%@ %@", coche, [color uppercaseString]]
        : coche;
    NSString *mensaje = [NSString stringWithFormat:@"¡Tu conductor va en camino en un %@ (%@)!",
                         cocheConColor, [self placaDe:viaje]];

    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{
        @"message"           : mensaje,
        TRIP_STATUS          : @"go",
        TRIP_ID              : isEmpty(viaje.trip_Id),
        @"to"                : @"user",
        @"type"              : @"notif",
        @"content-available" : @"1",
    }];
    // userId es un int en UserModel, no una cadena: isEmpty() no vale aqui.
    if (viaje.user.userId > 0) {
        [dict setObject:[NSString stringWithFormat:@"%d", viaje.user.userId] forKey:@"user_id"];
    }
    [dict setObject:token forKey:([viaje.user.deviceType isEqualToString:IOS] ? IOS_TOKEN : ANDROID_TOKEN)];

    [GIC mk:url_notification to:send_user_notification d:dict isa:NO cb:^(id results, NSError *error) {
        BOOL ok = [[[results objectForKey:P_STATUS] uppercaseString] isEqualToString:@"OK"];
        NSLog(@"[VoyEnCamino] push al pasajero del viaje %@: %@",
              isEmpty(viaje.trip_Id), ok ? @"enviado" : @"FALLO");
    }];
}

/**
 El mensaje automatico en el chat del viaje.

 El diccionario es el mismo que escribe ChatViewController al mandar a mano, para que el
 mensaje se pinte igual que cualquier otro. Ojo con `isUser`: Android lo escribe a YES y iOS
 a NO para el MISMO actor, pero da igual, porque ninguna de las dos lo usa para decidir el
 lado de la burbuja -- eso se decide comparando `from` con el fire_id de quien mira. Se deja
 como lo escribe iOS para no introducir una tercera convencion.
 */
+ (void)escribirEnElChat:(TripModel *)viaje {
    NSDictionary *dictConductor = defaults_object(P_USER_DICT);
    if (![dictConductor isKindOfClass:[NSDictionary class]]) {
        return;
    }
    NSString *deQuien = [self util:[dictConductor objectForKey:P_FIRE_ID]];
    NSString *paraQuien = [self util:viaje.user.fire_id];
    if (deQuien.length == 0 || paraQuien.length == 0) {
        NSLog(@"[VoyEnCamino] sin fire_id (conductor '%@', pasajero '%@'): no hay mensaje de chat",
              deQuien, paraQuien);
        return;
    }

    NSString *color = [self util:viaje.driver.car_color];
    NSString *texto = [NSString stringWithFormat:
        @"Hola, soy el conductor %@. Voy en camino en un Vehículo color %@, %@, placa (%@). "
        @"Confírmame el sitio de recogida.",
        [self nombreDelConductor:viaje],
        color.length > 0 ? color : @"desconocido",
        [self cocheDe:viaje],
        [self placaDe:viaje]];

    NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
    data[@"timeStamp"] = [FIRServerValue timestamp];
    data[@"text"]      = texto;
    data[@"user_name"] = isEmpty([dictConductor objectForKey:@"d_name"]);
    data[@"isUser"]    = @(NO);
    data[@"is_read"]   = @(NO);
    data[@"trip_id"]   = isEmpty(viaje.trip_Id);
    data[@"id"]        = isEmpty([dictConductor objectForKey:P_DRIVER_ID]);
    data[@"from"]      = deQuien;
    data[@"to"]        = paraQuien;

    FireBaseModel *fire = [[FireBaseModel alloc] initFirebaseWithChannelID:isEmpty(viaje.trip_Id)];
    [fire sendChat:data withCompletion:^(id result, NSError *error) {
        if (error != nil) {
            NSLog(@"[VoyEnCamino] no se pudo escribir en el chat del viaje %@", isEmpty(viaje.trip_Id));
            return;
        }
        // El push del chat va aparte: sin el, el mensaje queda esperando a que el pasajero
        // abra la conversacion por su cuenta, que es lo mismo que no mandarlo.
        [viaje sendChatNotificationToUser:texto];
    }];
}

@end
