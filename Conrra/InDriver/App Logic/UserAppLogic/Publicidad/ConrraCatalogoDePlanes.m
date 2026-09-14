//
//  ConrraCatalogoDePlanes.m
//  Conrra
//

#import "ConrraCatalogoDePlanes.h"
#import "Keys.h"

#pragma mark - ConrraPlan

@interface ConrraPlan ()

@property (nonatomic, copy) NSString *identificador;
@property (nonatomic, copy) NSString *titulo;
@property (nonatomic, copy) NSString *cliente;
@property (nonatomic, copy) NSString *imagen;
@property (nonatomic, copy) NSString *plan;
@property (nonatomic, copy) NSString *categoria;
@property (nonatomic, copy) NSString *etiqueta;
@property (nonatomic, copy) NSString *detalle;
@property (nonatomic, copy) NSString *horario;
@property (nonatomic, copy) NSString *nota;
@property (nonatomic, assign) CLLocationDegrees lat;
@property (nonatomic, assign) CLLocationDegrees lng;
@property (nonatomic, copy) NSString *sitio;
@property (nonatomic, copy) NSString *direccion;

/**
 Testigo firmado por el rele que autoriza a contar la vista y el toque de IR de este plan
 en esta visita. El app no lo genera ni lo entiende: solo lo devuelve tal cual. Sin el, el
 servidor rechaza el evento.
 */
@property (nonatomic, copy) NSString *ticket;

@end


@implementation ConrraPlan

- (BOOL)esPremium {
    return [self.plan caseInsensitiveCompare:@"premium"] == NSOrderedSame;
}

- (NSString *)destinoLegible {
    NSCharacterSet *blancos = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *sitio = [self.sitio stringByTrimmingCharactersInSet:blancos] ?: @"";
    NSString *dir   = [self.direccion stringByTrimmingCharactersInSet:blancos] ?: @"";
    if (dir.length > 0) {
        return [NSString stringWithFormat:@"%@, %@", sitio, dir];
    }
    return sitio;
}

- (NSString *)paraBuscar {
    NSString *todo = [NSString stringWithFormat:@"%@ %@ %@ %@ %@ %@ %@",
                      self.titulo, self.cliente, self.detalle, self.etiqueta,
                      self.sitio, self.direccion, self.categoria];
    return [todo lowercaseString];
}

@end


#pragma mark - ConrraCatalogoDePlanes

/**
 Catalogo de la seccion Planes: lugares y ofertas a los que se puede ir en Conrra.

 EN QUE SE DIFERENCIA DEL CARRUSEL DE BANNERS. Un banner lleva a una web y se abre el
 navegador. Un plan lleva a un PUNTO: al pulsar IR no se abre nada, se pone ese local como
 destino del viaje y el pasajero vuelve a la pantalla de pedir taxi con la ruta ya
 calculada. Por eso aqui cada ficha trae coordenadas y no URL.

 EL ORDEN NO SE DECIDE AQUI. Llega ya resuelto del rele: premium delante, basicos detras, y
 sorteado dentro de cada grupo. Ponerlo en el telefono significaria que cambiar quien sale
 primero exige publicar una version nueva.

 SOBRE LAS IMPRESIONES. Se cuenta UNA por plan y por visita a la pantalla, no una por vez
 que la ficha vuelve a pasar por delante al desplazar: contarlas todas inflaria el numero
 que se le factura al anunciante. El rele impone lo mismo por su cuenta, porque el testigo
 se gasta a la primera.

 Todo falla hacia no molestar: si el rele no responde o la lista viene vacia, la pantalla
 enseña su mensaje de "todavia no hay planes" y no un error.
 */
@interface ConrraCatalogoDePlanes ()

@property (nonatomic, strong) NSMutableSet<NSString *> *impresionesContadas;

@end


@implementation ConrraCatalogoDePlanes

- (instancetype)init {
    self = [super init];
    if (self) {
        _impresionesContadas = [NSMutableSet set];
    }
    return self;
}

#pragma mark - Publico

- (void)cargarConCiudad:(NSString *)ciudadId
                    dia:(NSString *)dia
             alTerminar:(void (^)(NSArray<ConrraPlan *> *planes))alTerminar {

    NSMutableArray<NSString *> *consulta = [NSMutableArray array];
    NSCharacterSet *permitidos = [NSCharacterSet URLQueryAllowedCharacterSet];
    NSCharacterSet *blancos = [NSCharacterSet whitespaceAndNewlineCharacterSet];

    NSString *ciudad = [ciudadId stringByTrimmingCharactersInSet:blancos];
    if (ciudad.length > 0) {
        [consulta addObject:[NSString stringWithFormat:@"ciudad=%@",
                             [ciudad stringByAddingPercentEncodingWithAllowedCharacters:permitidos]]];
    }
    NSString *elDia = [dia stringByTrimmingCharactersInSet:blancos];
    if (elDia.length > 0) {
        [consulta addObject:[NSString stringWithFormat:@"dia=%@",
                             [elDia stringByAddingPercentEncodingWithAllowedCharacters:permitidos]]];
    }

    NSMutableString *cadena = [NSMutableString stringWithString:URL_PLANES];
    if (consulta.count > 0) {
        [cadena appendFormat:@"?%@", [consulta componentsJoinedByString:@"&"]];
    }

    NSURL *url = [NSURL URLWithString:cadena];
    if (url == nil) {
        alTerminar(@[]);
        return;
    }

    NSURLSessionDataTask *tarea =
    [[NSURLSession sharedSession] dataTaskWithURL:url
                                completionHandler:^(NSData *datos, NSURLResponse *respuesta, NSError *error) {
        NSArray<ConrraPlan *> *lista = @[];
        if (error == nil && datos != nil) {
            id raiz = [NSJSONSerialization JSONObjectWithData:datos options:0 error:nil];
            if ([raiz isKindOfClass:[NSDictionary class]]) {
                lista = [ConrraCatalogoDePlanes leer:(NSDictionary *)raiz];
            } else {
                NSLog(@"[Planes] respuesta ilegible");
            }
        } else {
            NSLog(@"[Planes] el rele no contesto");
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            alTerminar(lista);
        });
    }];
    [tarea resume];
}

- (void)alAsomarse:(ConrraPlan *)plan {
    if (plan == nil || plan.identificador.length == 0) {
        return;
    }
    if ([self.impresionesContadas containsObject:plan.identificador]) {
        return;
    }
    [self.impresionesContadas addObject:plan.identificador];
    [self reportar:plan tipo:@"impresion"];
}

- (void)alPulsarIr:(ConrraPlan *)plan {
    [self reportar:plan tipo:@"clic"];
}

- (void)olvidarImpresiones {
    [self.impresionesContadas removeAllObjects];
}

#pragma mark - Internos

+ (NSArray<ConrraPlan *> *)leer:(NSDictionary *)raiz {
    NSMutableArray<ConrraPlan *> *lista = [NSMutableArray array];
    id arr = [raiz objectForKey:@"planes"];
    if (![arr isKindOfClass:[NSArray class]]) {
        return lista;
    }

    for (id elemento in (NSArray *)arr) {
        if (![elemento isKindOfClass:[NSDictionary class]]) {
            continue;
        }
        NSDictionary *o = (NSDictionary *)elemento;

        // El rele ya filtra los que no tienen punto. Se vuelve a mirar aqui porque una
        // ficha cuyo boton IR no lleva a ninguna parte es peor que no enseñarla.
        id destino = [o objectForKey:@"destino"];
        if (![destino isKindOfClass:[NSDictionary class]]) {
            continue;
        }
        NSDictionary *d = (NSDictionary *)destino;

        ConrraPlan *p = [[ConrraPlan alloc] init];
        p.identificador = [self cadenaDe:o clave:@"id"];
        p.titulo        = [self cadenaDe:o clave:@"titulo"];
        p.cliente       = [self cadenaDe:o clave:@"cliente"];
        p.imagen        = [self cadenaDe:o clave:@"imagen"];
        p.plan          = [self cadenaDe:o clave:@"plan"];
        p.categoria     = [self cadenaDe:o clave:@"categoria"];
        p.etiqueta      = [self cadenaDe:o clave:@"etiqueta"];
        p.detalle       = [self cadenaDe:o clave:@"detalle"];
        p.horario       = [self cadenaDe:o clave:@"horario"];
        p.nota          = [self cadenaDe:o clave:@"nota"];
        p.ticket        = [self cadenaDe:o clave:@"ticket"];
        p.sitio         = [self cadenaDe:d clave:@"sitio"];
        p.direccion     = [self cadenaDe:d clave:@"direccion"];
        p.lat           = [[d objectForKey:@"lat"] doubleValue];
        p.lng           = [[d objectForKey:@"lng"] doubleValue];

        if (p.plan.length == 0)      p.plan = @"basico";
        if (p.categoria.length == 0) p.categoria = @"otro";

        NSCharacterSet *blancos = [NSCharacterSet whitespaceAndNewlineCharacterSet];
        if ([[p.identificador stringByTrimmingCharactersInSet:blancos] length] == 0) continue;
        if ([[p.imagen stringByTrimmingCharactersInSet:blancos] length] == 0) continue;
        if (p.lat == 0 && p.lng == 0) continue;

        [lista addObject:p];
    }
    return lista;
}

- (void)reportar:(ConrraPlan *)plan tipo:(NSString *)tipo {
    if (plan == nil || plan.identificador.length == 0) {
        return;
    }
    // Sin testigo el rele rechaza el evento, asi que ni se molesta en llamar.
    if (plan.ticket.length == 0) {
        NSLog(@"[Planes] el plan %@ vino sin testigo; no se cuenta", plan.identificador);
        return;
    }

    NSURL *url = [NSURL URLWithString:URL_PLAN_EVENTO];
    if (url == nil) {
        return;
    }
    NSMutableURLRequest *peticion = [NSMutableURLRequest requestWithURL:url];
    peticion.HTTPMethod = @"POST";
    [peticion setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];

    NSCharacterSet *permitidos = [NSCharacterSet URLQueryAllowedCharacterSet];
    NSString *cuerpo = [NSString stringWithFormat:@"id=%@&tipo=%@&ticket=%@",
                        [plan.identificador stringByAddingPercentEncodingWithAllowedCharacters:permitidos],
                        [tipo stringByAddingPercentEncodingWithAllowedCharacters:permitidos],
                        [plan.ticket stringByAddingPercentEncodingWithAllowedCharacters:permitidos]];
    peticion.HTTPBody = [cuerpo dataUsingEncoding:NSUTF8StringEncoding];

    // Sin escuchar la respuesta: que el contador falle no puede afectar a la pantalla.
    [[[NSURLSession sharedSession] dataTaskWithRequest:peticion
                                     completionHandler:^(NSData *d, NSURLResponse *r, NSError *e) {
    }] resume];
}

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

@end
