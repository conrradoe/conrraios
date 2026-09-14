//
//  ConrraCarruselBanners.m
//  Conrra
//

#import "ConrraCarruselBanners.h"
#import "Keys.h"

/** Si el rele no dice otra cosa. */
static const NSInteger kSegundosPorDefecto = 6;
static const NSInteger kSegundosMinimo     = 3;
static const NSInteger kSegundosMaximo     = 30;

#pragma mark - ConrraBanner

@interface ConrraBanner ()

@property (nonatomic, copy) NSString *identificador;
@property (nonatomic, copy) NSString *titulo;
@property (nonatomic, copy) NSString *imagen;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *plan;

/**
 Testigo firmado por el rele que autoriza a contar la vista y el clic de este banner en
 esta espera. El app no lo genera ni lo entiende: solo lo devuelve tal cual. Sin el, el
 servidor rechaza el evento.
 */
@property (nonatomic, copy) NSString *ticket;

@end


@implementation ConrraBanner

- (BOOL)esPulsable {
    return [[self.url stringByTrimmingCharactersInSet:
             [NSCharacterSet whitespaceAndNewlineCharacterSet]] length] > 0;
}

@end


#pragma mark - ConrraCarruselBanners

@interface ConrraCarruselBanners ()

@property (nonatomic, weak)   id<ConrraCarruselBannersDelegate> delegado;
@property (nonatomic, strong) NSMutableArray<ConrraBanner *> *lista;
@property (nonatomic, strong) NSMutableSet<NSString *> *impresionesContadas;
@property (nonatomic, strong) NSTimer *reloj;
@property (nonatomic, assign) NSInteger indice;
@property (nonatomic, assign) NSInteger segundos;
@property (nonatomic, assign) BOOL andando;

@end


@implementation ConrraCarruselBanners

- (instancetype)initConDelegado:(id<ConrraCarruselBannersDelegate>)delegado {
    self = [super init];
    if (self) {
        _delegado            = delegado;
        _lista               = [NSMutableArray array];
        _impresionesContadas = [NSMutableSet set];
        _indice              = -1;
        _segundos            = kSegundosPorDefecto;
        _andando             = NO;
    }
    return self;
}

- (void)dealloc {
    [_reloj invalidate];
}

#pragma mark - Publico

- (void)cargarYArrancarConCiudad:(NSString *)ciudadId {
    NSMutableString *cadena = [NSMutableString stringWithString:URL_BANNERS];
    NSString *ciudad = [ciudadId stringByTrimmingCharactersInSet:
                        [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (ciudad.length > 0) {
        [cadena appendFormat:@"?ciudad=%@",
         [ciudad stringByAddingPercentEncodingWithAllowedCharacters:
          [NSCharacterSet URLQueryAllowedCharacterSet]]];
    }

    NSURL *url = [NSURL URLWithString:cadena];
    if (url == nil) {
        [self avisarVacio];
        return;
    }

    __weak typeof(self) debil = self;
    NSURLSessionDataTask *tarea =
    [[NSURLSession sharedSession] dataTaskWithURL:url
                                completionHandler:^(NSData *datos, NSURLResponse *respuesta, NSError *error) {
        __strong typeof(debil) fuerte = debil;
        if (fuerte == nil) {
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error != nil || datos == nil) {
                [fuerte avisarVacio];
                return;
            }
            NSError *errJson = nil;
            id raiz = [NSJSONSerialization JSONObjectWithData:datos options:0 error:&errJson];
            if (errJson != nil || ![raiz isKindOfClass:[NSDictionary class]]) {
                [fuerte avisarVacio];
                return;
            }
            [fuerte leer:(NSDictionary *)raiz];
            if (fuerte.lista.count == 0) {
                [fuerte avisarVacio];
                return;
            }
            [fuerte arrancar];
        });
    }];
    [tarea resume];
}

- (void)parar {
    self.andando = NO;
    [self.reloj invalidate];
    self.reloj = nil;
}

- (NSString *)alPulsar:(ConrraBanner *)banner {
    if (banner == nil || ![banner esPulsable]) {
        return nil;
    }
    [self reportar:banner tipo:@"clic"];
    return [banner.url stringByTrimmingCharactersInSet:
            [NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

#pragma mark - Internos

- (void)leer:(NSDictionary *)raiz {
    [self.lista removeAllObjects];
    [self.impresionesContadas removeAllObjects];

    NSInteger s = kSegundosPorDefecto;
    id crudo = [raiz objectForKey:@"segundos"];
    if ([crudo respondsToSelector:@selector(integerValue)]) {
        s = [crudo integerValue];
    }
    // Un intervalo absurdo dejaria el carrusel congelado o parpadeando; se acota aqui para
    // que un error de dedo en el catalogo no se note en la pantalla del pasajero.
    self.segundos = MAX(kSegundosMinimo, MIN(kSegundosMaximo, s));

    id arr = [raiz objectForKey:@"banners"];
    if (![arr isKindOfClass:[NSArray class]]) {
        return;
    }
    for (id elemento in (NSArray *)arr) {
        if (![elemento isKindOfClass:[NSDictionary class]]) {
            continue;
        }
        NSDictionary *o = (NSDictionary *)elemento;
        NSString *imagen = [ConrraCarruselBanners cadenaDe:o clave:@"imagen"];
        if ([[imagen stringByTrimmingCharactersInSet:
              [NSCharacterSet whitespaceAndNewlineCharacterSet]] length] == 0) {
            continue;
        }
        ConrraBanner *banner = [[ConrraBanner alloc] init];
        banner.identificador = [ConrraCarruselBanners cadenaDe:o clave:@"id"];
        banner.titulo        = [ConrraCarruselBanners cadenaDe:o clave:@"titulo"];
        banner.imagen        = imagen;
        banner.url           = [ConrraCarruselBanners cadenaDe:o clave:@"url"];
        banner.plan          = [ConrraCarruselBanners cadenaDe:o clave:@"plan"];
        banner.ticket        = [ConrraCarruselBanners cadenaDe:o clave:@"ticket"];
        if (banner.plan.length == 0) {
            banner.plan = @"basico";
        }
        [self.lista addObject:banner];
    }
}

- (void)arrancar {
    if (self.andando) {
        return;
    }
    self.andando = YES;
    self.indice  = -1;
    [self siguiente];
}

- (void)siguiente {
    if (!self.andando || self.lista.count == 0) {
        return;
    }

    self.indice = (self.indice + 1) % (NSInteger)self.lista.count;
    ConrraBanner *banner = [self.lista objectAtIndex:(NSUInteger)self.indice];
    [self.delegado carruselAlMostrarBanner:banner];

    // Una sola impresion por banner en toda la espera. Ver la nota de la cabecera. El rele
    // impone lo mismo por su cuenta -- el testigo se gasta a la primera -- asi que esto es
    // cortesia, no la garantia.
    if (banner.identificador.length > 0
        && ![self.impresionesContadas containsObject:banner.identificador]) {
        [self.impresionesContadas addObject:banner.identificador];
        [self reportar:banner tipo:@"impresion"];
    }

    // Con un solo banner no hay nada que rotar: se deja quieto y se ahorra el reloj.
    [self.reloj invalidate];
    self.reloj = nil;
    if (self.lista.count > 1) {
        self.reloj = [NSTimer scheduledTimerWithTimeInterval:(NSTimeInterval)self.segundos
                                                      target:self
                                                    selector:@selector(siguiente)
                                                    userInfo:nil
                                                     repeats:NO];
    }
}

- (void)avisarVacio {
    [self parar];
    [self.delegado carruselAlQuedarSinBanners];
}

- (void)reportar:(ConrraBanner *)banner tipo:(NSString *)tipo {
    if (banner == nil || banner.identificador.length == 0) {
        return;
    }
    // Sin testigo el rele rechaza el evento, asi que ni se molesta en llamar.
    if (banner.ticket.length == 0) {
        NSLog(@"[CarruselBanners] el banner %@ vino sin testigo; no se cuenta",
              banner.identificador);
        return;
    }

    NSURL *url = [NSURL URLWithString:URL_BANNER_EVENTO];
    if (url == nil) {
        return;
    }
    NSMutableURLRequest *peticion = [NSMutableURLRequest requestWithURL:url];
    peticion.HTTPMethod = @"POST";
    [peticion setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    peticion.HTTPBody = [[ConrraCarruselBanners cuerpoConCampos:@{
        @"id"     : banner.identificador,
        @"tipo"   : tipo,
        @"ticket" : banner.ticket,
    }] dataUsingEncoding:NSUTF8StringEncoding];

    // Sin escuchar la respuesta: que el contador falle no puede afectar a la pantalla.
    [[[NSURLSession sharedSession] dataTaskWithRequest:peticion
                                     completionHandler:^(NSData *d, NSURLResponse *r, NSError *e) {
    }] resume];
}

#pragma mark - Utilidades

/** Lee una clave como cadena, tolerando que venga nula, numerica o de otro tipo. */
+ (NSString *)cadenaDe:(NSDictionary *)dict clave:(NSString *)clave {
    id valor = [dict objectForKey:clave];
    if ([valor isKindOfClass:[NSString class]]) {
        return (NSString *)valor;
    }
    if ([valor isKindOfClass:[NSNumber class]]) {
        return [(NSNumber *)valor stringValue];
    }
    return @"";
}

+ (NSString *)cuerpoConCampos:(NSDictionary<NSString *, NSString *> *)campos {
    NSMutableArray<NSString *> *partes = [NSMutableArray array];
    NSCharacterSet *permitidos = [NSCharacterSet URLQueryAllowedCharacterSet];
    for (NSString *clave in campos) {
        NSString *valor = [campos objectForKey:clave];
        [partes addObject:[NSString stringWithFormat:@"%@=%@",
                           [clave stringByAddingPercentEncodingWithAllowedCharacters:permitidos],
                           [valor stringByAddingPercentEncodingWithAllowedCharacters:permitidos]]];
    }
    return [partes componentsJoinedByString:@"&"];
}

@end
