//
//  ConrraRutaDeRecogida.m
//  Conrra
//

#import "ConrraRutaDeRecogida.h"
#import "AppDelegate.h"
// APP_DELEGATE es una macro de aqui, no de AppDelegate.h.
#import "WebCallConstants.h"

NSString *const ConrraRutaDeRecogidaActualizada = @"ConrraRutaDeRecogidaActualizada";

/// Cuanto vale una medida antes de volver a preguntar.
static const NSTimeInterval kVigencia = 60.0;
/// Ritmo maximo de salida a la red, pregunte quien pregunte y cuantas veces sea.
static const NSTimeInterval kEsperaEntrePeticiones = 1.5;
/// Una peticion que tarda mas que esto se da por perdida y su clave se libera.
static const NSTimeInterval kPaciencia = 30.0;
/// Techo de la cache: cada punto distinto ocupa una entrada.
static const NSUInteger kMaximoEnCache = 64;

@implementation ConrraMedidaDeRuta
@end

/// Lo guardado: la medida y cuando se tomo.
@interface ConrraEntradaDeRuta : NSObject
@property (nonatomic, strong) ConrraMedidaDeRuta *medida;
@property (nonatomic, assign) NSTimeInterval momento;
@end
@implementation ConrraEntradaDeRuta
@end


@implementation ConrraRutaDeRecogida

+ (NSMutableDictionary<NSString *, ConrraEntradaDeRuta *> *)cache {
    static NSMutableDictionary *cache = nil;
    static dispatch_once_t unaVez;
    dispatch_once(&unaVez, ^{ cache = [[NSMutableDictionary alloc] init]; });
    return cache;
}

/// Orden de uso, para saber a quien echar cuando la cache se llena.
+ (NSMutableArray<NSString *> *)ordenDeUso {
    static NSMutableArray *orden = nil;
    static dispatch_once_t unaVez;
    dispatch_once(&unaVez, ^{ orden = [[NSMutableArray alloc] init]; });
    return orden;
}

+ (NSMutableDictionary<NSString *, NSNumber *> *)enVuelo {
    static NSMutableDictionary *enVuelo = nil;
    static dispatch_once_t unaVez;
    dispatch_once(&unaVez, ^{ enVuelo = [[NSMutableDictionary alloc] init]; });
    return enVuelo;
}

/// Todo el estado compartido se toca desde aqui, para no sincronizar a mano.
+ (dispatch_queue_t)turno {
    static dispatch_queue_t turno = nil;
    static dispatch_once_t unaVez;
    dispatch_once(&unaVez, ^{
        turno = dispatch_queue_create("conrra.ruta.recogida", DISPATCH_QUEUE_SERIAL);
    });
    return turno;
}

/**
 Tres decimales son unos 100 m. El GPS parado tiembla menos que eso, asi que un conductor
 quieto reutiliza siempre la misma clave y no gasta llamadas.
 */
+ (NSString *)claveDesde:(CLLocationCoordinate2D)origen hasta:(CLLocationCoordinate2D)destino {
    return [NSString stringWithFormat:@"%.3f,%.3f>%.4f,%.4f",
            origen.latitude, origen.longitude, destino.latitude, destino.longitude];
}

+ (BOOL)vale:(CLLocationCoordinate2D)punto {
    return CLLocationCoordinate2DIsValid(punto) && !(punto.latitude == 0 && punto.longitude == 0);
}

#pragma mark - Consulta

+ (ConrraMedidaDeRuta *)consultarDesde:(CLLocationCoordinate2D)origen
                                 hasta:(CLLocationCoordinate2D)destino {
    if (![self vale:origen] || ![self vale:destino]) {
        return nil;
    }
    NSString *clave = [self claveDesde:origen hasta:destino];
    NSTimeInterval ahora = [[NSDate date] timeIntervalSince1970];

    __block ConrraEntradaDeRuta *conocida = nil;
    dispatch_sync([self turno], ^{
        conocida = [[self cache] objectForKey:clave];
        if (conocida) {
            // Recien usada: se va al final de la cola de descarte.
            [[self ordenDeUso] removeObject:clave];
            [[self ordenDeUso] addObject:clave];
        }
    });
    if (conocida && (ahora - conocida.momento) < kVigencia) {
        return conocida.medida;
    }

    [self pedirSiTocaConClave:clave origen:origen destino:destino ahora:ahora];
    return conocida.medida;   // la vieja mientras llega la nueva; nil si no hay ninguna
}

+ (void)pedirSiTocaConClave:(NSString *)clave
                     origen:(CLLocationCoordinate2D)origen
                    destino:(CLLocationCoordinate2D)destino
                      ahora:(NSTimeInterval)ahora {
    static NSTimeInterval ultimaPeticion = 0;
    __block BOOL sePide = NO;
    dispatch_sync([self turno], ^{
        NSNumber *lanzada = [[self enVuelo] objectForKey:clave];
        if (lanzada != nil && (ahora - lanzada.doubleValue) < kPaciencia) {
            return;   // ya se esta preguntando esto mismo
        }
        if ((ahora - ultimaPeticion) < kEsperaEntrePeticiones) {
            return;   // demasiado seguido: se pedira en el siguiente repintado
        }
        [[self enVuelo] setObject:@(ahora) forKey:clave];
        ultimaPeticion = ahora;
        sePide = YES;
    });
    if (!sePide) {
        return;
    }

    NSString *llave = [APP_DELEGATE getGoogleKey] ?: @"";
    NSString *url = [NSString stringWithFormat:
        @"https://maps.googleapis.com/maps/api/directions/json?origin=%f,%f&destination=%f,%f&mode=driving&key=%@",
        origen.latitude, origen.longitude, destino.latitude, destino.longitude, llave];

    /*
     Se pide en crudo y en silencio, no con GoogleDirectionSource.

     Esa clase, ante un error de la API, ENSEÑA UNA ALERTA y reintenta. Sirve para dibujar la
     ruta del viaje, donde el conductor espera algo. Aqui no: esto corre solo para rellenar una
     cifra en una tarjeta, y una alerta modal cada vez que Google tiene un mal dia seria
     insufrible. Si no se puede medir, no se mide y se sigue con la linea recta.
     */
    NSURLSessionDataTask *tarea = [[NSURLSession sharedSession]
        dataTaskWithURL:[NSURL URLWithString:url]
      completionHandler:^(NSData *datos, NSURLResponse *respuesta, NSError *error) {
        ConrraMedidaDeRuta *medida = [self leer:datos];
        dispatch_async([self turno], ^{
            [[self enVuelo] removeObjectForKey:clave];
            if (medida == nil) {
                return;
            }
            ConrraEntradaDeRuta *entrada = [[ConrraEntradaDeRuta alloc] init];
            entrada.medida = medida;
            entrada.momento = [[NSDate date] timeIntervalSince1970];
            [[self cache] setObject:entrada forKey:clave];
            [[self ordenDeUso] removeObject:clave];
            [[self ordenDeUso] addObject:clave];
            while ([self ordenDeUso].count > kMaximoEnCache) {
                NSString *masVieja = [[self ordenDeUso] firstObject];
                [[self cache] removeObjectForKey:masVieja];
                [[self ordenDeUso] removeObjectAtIndex:0];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:ConrraRutaDeRecogidaActualizada
                                                                    object:nil];
            });
        });
    }];
    [tarea resume];
}

+ (ConrraMedidaDeRuta *)leer:(NSData *)datos {
    if (datos.length == 0) {
        return nil;
    }
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:datos options:0 error:nil];
    if (![json isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    NSArray *rutas = [json objectForKey:@"routes"];
    if (![rutas isKindOfClass:[NSArray class]] || rutas.count == 0) {
        return nil;
    }
    NSArray *tramos = [[rutas firstObject] objectForKey:@"legs"];
    if (![tramos isKindOfClass:[NSArray class]] || tramos.count == 0) {
        return nil;
    }
    // Se suman los tramos: con un solo destino solo hay uno, pero sumar no cuesta y no miente
    // si algun dia se pide con paradas intermedias.
    double metros = 0;
    double segundos = 0;
    for (NSDictionary *tramo in tramos) {
        if (![tramo isKindOfClass:[NSDictionary class]]) continue;
        metros   += [[[tramo objectForKey:@"distance"] objectForKey:@"value"] doubleValue];
        segundos += [[[tramo objectForKey:@"duration"] objectForKey:@"value"] doubleValue];
    }
    if (metros <= 0) {
        return nil;
    }
    ConrraMedidaDeRuta *medida = [[ConrraMedidaDeRuta alloc] init];
    medida.km = metros / 1000.0;
    medida.minutos = MAX(1, (NSInteger)round(segundos / 60.0));
    return medida;
}

#pragma mark - El texto

+ (NSString *)textoDesde:(CLLocationCoordinate2D)origen
                   hasta:(CLLocationCoordinate2D)destino
                 prefijo:(NSString *)prefijo {
    if (![self vale:origen] || ![self vale:destino]) {
        return @"";
    }
    ConrraMedidaDeRuta *medida = [self consultarDesde:origen hasta:destino];
    double km;
    if (medida != nil) {
        km = medida.km;
    } else {
        CLLocation *a = [[CLLocation alloc] initWithLatitude:origen.latitude longitude:origen.longitude];
        CLLocation *b = [[CLLocation alloc] initWithLatitude:destino.latitude longitude:destino.longitude];
        km = [a distanceFromLocation:b] / 1000.0;
    }
    NSString *cifra = [NSString stringWithFormat:@"%.1f km", km];
    NSString *delante = [prefijo stringByTrimmingCharactersInSet:
                         [NSCharacterSet whitespaceAndNewlineCharacterSet]] ?: @"";
    return delante.length > 0 ? [NSString stringWithFormat:@"%@ %@", delante, cifra] : cifra;
}

@end
