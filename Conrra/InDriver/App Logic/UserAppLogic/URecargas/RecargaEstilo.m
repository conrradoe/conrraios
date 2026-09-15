//
//  RecargaEstilo.m
//  Conrra
//

#import "RecargaEstilo.h"
#import "ConstantModel.h"
#import "CityModel.h"
#import "UserProfile.h"
#import "WebCallConstants.h"
#import <GIKit/GIKit.h>

@implementation RecargaEstilo

#pragma mark - Paleta

/** El color del catalogo si existe; si no, el literal que usa Android. */
+ (UIColor *)color:(NSString *)nombre rojo:(int)r verde:(int)g azul:(int)b {
    UIColor *delCatalogo = [UIColor colorNamed:nombre];
    if (delCatalogo) {
        return delCatalogo;
    }
    return [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1];
}

+ (UIColor *)fondo           { return [self color:@"color_app_bg"         rojo:255 verde:255 azul:255]; }
+ (UIColor *)textoPrincipal  { return [self color:@"color_app_label"      rojo:0x21 verde:0x21 azul:0x21]; }
+ (UIColor *)textoSecundario { return [self color:@"color_app_label_gray" rojo:0x5A verde:0x5A azul:0x5A]; }
+ (UIColor *)textoTerciario  { return [self color:@"app_dark_gray"        rojo:0x69 verde:0x69 azul:0x69]; }
+ (UIColor *)amarillo        { return [self color:@"app_theame"           rojo:0xEB verde:0xB5 azul:0x18]; }
+ (UIColor *)borde           { return [self color:@"color_border"         rojo:0xEF verde:0xEF azul:0xEF]; }
+ (UIColor *)verde           { return [self color:@"color_trip_paid"      rojo:0x54 verde:0xAB azul:0x47]; }

#pragma mark - Piezas

+ (UILabel *)rotulo:(NSString *)texto {
    UILabel *l = [[UILabel alloc] init];
    l.translatesAutoresizingMaskIntoConstraints = NO;
    l.text = texto;
    l.font = FONTS_NOTO_REGULAR(12) ?: [UIFont systemFontOfSize:12];
    l.textColor = [self textoSecundario];
    l.numberOfLines = 0;
    return l;
}

+ (UILabel *)ayuda:(NSString *)texto {
    UILabel *l = [self rotulo:texto];
    l.textColor = [self textoTerciario];
    return l;
}

+ (UITextField *)campoConPista:(NSString *)pista {
    UITextField *c = [[UITextField alloc] init];
    c.translatesAutoresizingMaskIntoConstraints = NO;
    c.placeholder = pista;
    c.font = FONTS_NOTO_REGULAR(15) ?: [UIFont systemFontOfSize:15];
    c.textColor = [self textoPrincipal];
    c.backgroundColor = [UIColor whiteColor];
    c.layer.cornerRadius = 12;
    c.layer.borderWidth = 1;
    c.layer.borderColor = [self borde].CGColor;
    // UITextField no tiene padding propio: sin esto el texto pega en el borde.
    c.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 14, 1)];
    c.leftViewMode = UITextFieldViewModeAlways;
    c.rightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 14, 1)];
    c.rightViewMode = UITextFieldViewModeAlways;
    [c.heightAnchor constraintEqualToConstant:48].active = YES;
    return c;
}

+ (UIView *)tarjeta {
    UIView *v = [[UIView alloc] init];
    v.translatesAutoresizingMaskIntoConstraints = NO;
    v.backgroundColor = [UIColor whiteColor];
    v.layer.cornerRadius = 12;
    v.layer.borderWidth = 1;
    v.layer.borderColor = [self borde].CGColor;
    return v;
}

+ (UIButton *)botonPrincipalConTitulo:(NSString *)titulo {
    UIButton *b = [UIButton buttonWithType:UIButtonTypeCustom];
    b.translatesAutoresizingMaskIntoConstraints = NO;
    [b setTitle:titulo forState:UIControlStateNormal];
    [b setTitleColor:[self textoPrincipal] forState:UIControlStateNormal];
    b.titleLabel.font = FONTS_NOTO_BOLD(16) ?: [UIFont boldSystemFontOfSize:16];
    b.backgroundColor = [self amarillo];
    b.layer.cornerRadius = 12;
    [b.heightAnchor constraintEqualToConstant:48].active = YES;
    return b;
}

+ (UIView *)cabeceraEn:(UIViewController *)vc
                titulo:(NSString *)titulo
                accion:(SEL)accionVolver {
    UIView *cabecera = [[UIView alloc] init];
    cabecera.translatesAutoresizingMaskIntoConstraints = NO;
    [vc.view addSubview:cabecera];

    UIButton *atras = [UIButton buttonWithType:UIButtonTypeSystem];
    atras.translatesAutoresizingMaskIntoConstraints = NO;
    UIImage *flecha = [UIImage systemImageNamed:@"chevron.left"]
                      ?: [UIImage imageNamed:@"backward-arrow"];
    [atras setImage:flecha forState:UIControlStateNormal];
    atras.tintColor = [self textoPrincipal];
    [atras addTarget:vc action:accionVolver forControlEvents:UIControlEventTouchUpInside];
    [cabecera addSubview:atras];

    UILabel *rotulo = [[UILabel alloc] init];
    rotulo.translatesAutoresizingMaskIntoConstraints = NO;
    rotulo.text = titulo;
    rotulo.font = FONTS_NOTO_BOLD(18) ?: [UIFont boldSystemFontOfSize:18];
    rotulo.textColor = [self textoPrincipal];
    rotulo.textAlignment = NSTextAlignmentCenter;
    [cabecera addSubview:rotulo];

    UILayoutGuide *seguro = vc.view.safeAreaLayoutGuide;
    [NSLayoutConstraint activateConstraints:@[
        [cabecera.topAnchor      constraintEqualToAnchor:seguro.topAnchor],
        [cabecera.leadingAnchor  constraintEqualToAnchor:vc.view.leadingAnchor],
        [cabecera.trailingAnchor constraintEqualToAnchor:vc.view.trailingAnchor],
        [cabecera.heightAnchor   constraintEqualToConstant:56],

        [atras.leadingAnchor constraintEqualToAnchor:cabecera.leadingAnchor constant:12],
        [atras.centerYAnchor constraintEqualToAnchor:cabecera.centerYAnchor],
        [atras.widthAnchor   constraintEqualToConstant:44],
        [atras.heightAnchor  constraintEqualToConstant:44],

        // El titulo va centrado en la pantalla, como en Android, pero sin llegar nunca
        // debajo de la flecha: de ahi el margen de 64 a los dos lados.
        [rotulo.centerXAnchor constraintEqualToAnchor:cabecera.centerXAnchor],
        [rotulo.centerYAnchor constraintEqualToAnchor:cabecera.centerYAnchor],
        [rotulo.leadingAnchor constraintGreaterThanOrEqualToAnchor:cabecera.leadingAnchor constant:64],
        [rotulo.trailingAnchor constraintLessThanOrEqualToAnchor:cabecera.trailingAnchor constant:-64],
    ]];
    return cabecera;
}

+ (UIView *)veloDeEsperaEn:(UIView *)vista {
    UIView *velo = [[UIView alloc] init];
    velo.translatesAutoresizingMaskIntoConstraints = NO;
    velo.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
    velo.hidden = YES;
    // Se traga los toques: mientras el banco contesta no se puede volver a pulsar Pagar.
    velo.userInteractionEnabled = YES;
    [vista addSubview:velo];

    UIActivityIndicatorView *rueda =
        [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
    rueda.translatesAutoresizingMaskIntoConstraints = NO;
    rueda.color = [UIColor whiteColor];
    [rueda startAnimating];
    [velo addSubview:rueda];

    [NSLayoutConstraint activateConstraints:@[
        [velo.topAnchor      constraintEqualToAnchor:vista.topAnchor],
        [velo.bottomAnchor   constraintEqualToAnchor:vista.bottomAnchor],
        [velo.leadingAnchor  constraintEqualToAnchor:vista.leadingAnchor],
        [velo.trailingAnchor constraintEqualToAnchor:vista.trailingAnchor],
        [rueda.centerXAnchor constraintEqualToAnchor:velo.centerXAnchor],
        [rueda.centerYAnchor constraintEqualToAnchor:velo.centerYAnchor],
    ]];
    return velo;
}

#pragma mark - Dinero

+ (float)tasa {
    return [ConstantModel tasaDolarALocal];
}

+ (NSString *)enFormatoLocal:(double)cantidad {
    NSNumberFormatter *formato = [[NSNumberFormatter alloc] init];
    formato.numberStyle = NSNumberFormatterDecimalStyle;
    formato.minimumFractionDigits = 2;
    formato.maximumFractionDigits = 2;
    // Miles con punto y decimales con coma, como en Venezuela. Android lo consigue
    // pasandole Locale.GERMANY a String.format, que reparte igual los separadores.
    formato.groupingSeparator = @".";
    formato.decimalSeparator  = @",";
    return [formato stringFromNumber:@(cantidad)] ?: @"";
}

+ (float)saldo {
    NSDictionary *dict = defaults_object(P_USER_DICT_LOGGED);
    if (![dict isKindOfClass:[NSDictionary class]]) {
        dict = defaults_object(P_USER_DICT);
    }
    if (![dict isKindOfClass:[NSDictionary class]]) {
        return 0;
    }
    return [[dict objectForKey:P_USER_WAlLET_AMOUNT] floatValue];
}

#pragma mark - Relé

/** El diccionario de la cuenta que ha iniciado sesion, sea pasajero o conductor. */
+ (NSDictionary *)cuenta {
    NSDictionary *dict = defaults_object(P_USER_DICT_LOGGED);
    if (![dict isKindOfClass:[NSDictionary class]]) {
        dict = defaults_object(P_USER_DICT);
    }
    return [dict isKindOfClass:[NSDictionary class]] ? dict : @{};
}

/** Lee una clave como texto aunque el servidor la mande como numero. */
+ (NSString *)texto:(NSDictionary *)dict clave:(NSString *)clave {
    id valor = [dict objectForKey:clave];
    if ([valor isKindOfClass:[NSString class]]) {
        return (NSString *)valor;
    }
    if ([valor isKindOfClass:[NSNumber class]]) {
        return [(NSNumber *)valor stringValue];
    }
    return @"";
}

+ (void)enviarA:(NSString *)url
         campos:(NSDictionary<NSString *, NSString *> *)campos
     completado:(void (^)(NSDictionary * _Nullable, NSError * _Nullable))completado {

    NSMutableDictionary *todos = [NSMutableDictionary dictionaryWithDictionary:campos];
    NSDictionary *cuenta = [self cuenta];

    // La api_key vive en dos sitios -- suelta y dentro del diccionario de la cuenta -- y
    // segun por donde se haya entrado puede faltar en uno de los dos.
    NSString *llave = [self texto:cuenta clave:P_API_KEY];
    if (llave.length == 0) {
        id suelta = defaults_object(P_API_KEY);
        llave = [suelta isKindOfClass:[NSString class]] ? (NSString *)suelta : @"";
    }
    [todos setObject:llave forKey:@"api_key"];
    [todos setObject:[self texto:cuenta clave:P_USER_ID] forKey:@"user_id"];

    NSString *idCiudad = [self texto:cuenta clave:P_CITY_ID];
    if (idCiudad.length == 0) {
        idCiudad = [NSString stringWithFormat:@"%d", [UserProfile shared].loggedCityID];
    }
    [todos setObject:idCiudad forKey:@"city_id"];

    // La moneda que espera el relé es la de la pasarela de la ciudad (pg_cur: VES, PAB...),
    // no "USD". La lista de ciudades la tiene el app, no el relé, asi que va desde aqui.
    CityModel *ciudad = [CityModel getCityByCityId:[idCiudad intValue]];
    NSString *moneda = ciudad.pg_cur;
    if (![moneda isKindOfClass:[NSString class]] || moneda.length == 0) {
        moneda = ciudad.city_cur ?: @"";
    }
    [todos setObject:moneda forKey:@"currency"];

    // El swagger de Mercantil pide modelo y version dentro de client_identify.mobile.
    UIDevice *dispositivo = [UIDevice currentDevice];
    [todos setObject:@"Apple" forKey:@"dev_fabricante"];
    [todos setObject:dispositivo.model ?: @"iPhone" forKey:@"dev_modelo"];
    [todos setObject:[NSString stringWithFormat:@"iOS %@", dispositivo.systemVersion ?: @""]
              forKey:@"dev_version"];

    NSURL *destino = [NSURL URLWithString:url];
    if (destino == nil) {
        completado(nil, [NSError errorWithDomain:@"conrra.recarga" code:-1 userInfo:nil]);
        return;
    }

    NSMutableURLRequest *peticion = [NSMutableURLRequest requestWithURL:destino];
    peticion.HTTPMethod = @"POST";
    [peticion setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    // 90 segundos: un C2P puede tardar mucho, y cortar antes deja al cliente sin saber si
    // le cobraron. Android usa exactamente el mismo plazo.
    peticion.timeoutInterval = 90;

    NSCharacterSet *permitidos = [NSCharacterSet characterSetWithCharactersInString:
        @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._~"];
    NSMutableArray *partes = [[NSMutableArray alloc] init];
    for (NSString *clave in todos) {
        NSString *valor = [NSString stringWithFormat:@"%@", [todos objectForKey:clave]];
        [partes addObject:[NSString stringWithFormat:@"%@=%@",
            [clave stringByAddingPercentEncodingWithAllowedCharacters:permitidos],
            [valor stringByAddingPercentEncodingWithAllowedCharacters:permitidos]]];
    }
    peticion.HTTPBody = [[partes componentsJoinedByString:@"&"] dataUsingEncoding:NSUTF8StringEncoding];

    [[[NSURLSession sharedSession] dataTaskWithRequest:peticion
                                     completionHandler:^(NSData *datos, NSURLResponse *r, NSError *error) {
        NSDictionary *json = nil;
        if (datos.length > 0) {
            id leido = [NSJSONSerialization JSONObjectWithData:datos options:0 error:nil];
            if ([leido isKindOfClass:[NSDictionary class]]) {
                json = (NSDictionary *)leido;
            }
        }
        NSError *fallo = error;
        if (fallo == nil && json == nil) {
            // Respuesta que no es JSON: para quien llama es lo mismo que no haber
            // contestado, y hay que tratarla con la misma prudencia.
            fallo = [NSError errorWithDomain:@"conrra.recarga" code:-2 userInfo:nil];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            completado(json, fallo);
        });
    }] resume];
}

@end
