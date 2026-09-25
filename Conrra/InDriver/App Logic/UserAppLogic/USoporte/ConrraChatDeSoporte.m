//
//  ConrraChatDeSoporte.m
//  Conrra
//

#import "ConrraChatDeSoporte.h"
#import "ConstantModel.h"
#import "LanguageHelper.h"
#import "WebCallConstants.h"
#import <GIKit/GIKit.h>

/*
 Lo que la hoja necesita de la clase principal.

 Va en una extension y no en la cabecera porque es maquinaria interna: quien usa el chat
 solo tiene que saber abrirlo. Y hace falta declararlo aqui arriba porque la hoja se
 implementa ANTES que la clase principal, y sin esto el compilador no conoce los metodos.
 */
@interface ConrraChatDeSoporte ()
+ (BOOL)esPasajero;
+ (NSString *)nombreDeQuienEscribe;
+ (void)abrirWhatsAppDesde:(UIViewController *)vc mensaje:(NSString *)mensaje;
+ (void)abrir:(NSURL *)url luegoSiFalla:(NSURL *)reserva desde:(UIViewController *)vc numero:(NSString *)digitos;
+ (void)noSePudoAbrirDesde:(UIViewController *)vc numero:(NSString *)digitos;
@end


#pragma mark - Los textos de cada motivo

/** Lo que cambia entre un motivo y otro: cuatro cadenas, nada mas. */
@interface ConrraTextoDeMotivo : NSObject
@property (nonatomic, copy) NSString *titulo;
@property (nonatomic, copy) NSString *subtitulo;
@property (nonatomic, copy) NSString *pista;
@property (nonatomic, copy) NSString *apertura;
@property (nonatomic, copy) NSString *avisoVacio;
@end

@implementation ConrraTextoDeMotivo
@end


#pragma mark - La hoja

@interface ConrraHojaDeSoporte : UIViewController <UITextViewDelegate>
@property (nonatomic, assign) ConrraMotivoDeSoporte motivo;
@property (nonatomic, strong) ConrraTextoDeMotivo *textos;
@property (nonatomic, copy)   NSString *viajeId;
@property (nonatomic, copy)   NSString *monto;
@property (nonatomic, strong) UIView *tarjeta;
@property (nonatomic, strong) UITextView *campo;
@property (nonatomic, strong) UILabel *pistaDelCampo;
@property (nonatomic, strong) NSLayoutConstraint *bordeInferior;
@end


@implementation ConrraHojaDeSoporte

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.45];

    UITapGestureRecognizer *fuera = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                            action:@selector(cerrar)];
    fuera.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:fuera];

    [self montarTarjeta];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(tecladoCambia:)
                                                 name:UIKeyboardWillChangeFrameNotification
                                               object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)montarTarjeta {
    UIColor *oscuro = [UIColor colorNamed:@"color_app_label"]
                      ?: [UIColor colorWithRed:0x21/255.0 green:0x21/255.0 blue:0x21/255.0 alpha:1];
    UIColor *gris   = [UIColor colorNamed:@"app_dark_gray"]
                      ?: [UIColor colorWithRed:0x69/255.0 green:0x69/255.0 blue:0x69/255.0 alpha:1];
    UIColor *borde  = [UIColor colorNamed:@"color_border"]
                      ?: [UIColor colorWithRed:0xEF/255.0 green:0xEF/255.0 blue:0xEF/255.0 alpha:1];
    UIColor *amarillo = [UIColor colorNamed:@"app_theame"]
                        ?: [UIColor colorWithRed:0xEB/255.0 green:0xB5/255.0 blue:0x18/255.0 alpha:1];

    UIView *tarjeta = [[UIView alloc] init];
    tarjeta.translatesAutoresizingMaskIntoConstraints = NO;
    tarjeta.backgroundColor = [UIColor whiteColor];
    tarjeta.layer.cornerRadius = 20;
    tarjeta.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
    tarjeta.clipsToBounds = YES;
    // Se traga los toques: sin esto, tocar dentro de la hoja la cerraria, porque el gesto
    // del fondo tambien recibe los toques de sus hijas.
    [tarjeta addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(noHacerNada)]];
    [self.view addSubview:tarjeta];
    self.tarjeta = tarjeta;

    UIView *asa = [[UIView alloc] init];
    asa.translatesAutoresizingMaskIntoConstraints = NO;
    asa.backgroundColor = [UIColor colorWithWhite:0.78 alpha:1];
    asa.layer.cornerRadius = 2.5;
    [tarjeta addSubview:asa];

    UILabel *titulo = [[UILabel alloc] init];
    titulo.translatesAutoresizingMaskIntoConstraints = NO;
    titulo.text = self.textos.titulo;
    titulo.font = FONTS_NOTO_BOLD(17) ?: [UIFont boldSystemFontOfSize:17];
    titulo.textColor = oscuro;
    titulo.numberOfLines = 0;
    [tarjeta addSubview:titulo];

    UILabel *subtitulo = [[UILabel alloc] init];
    subtitulo.translatesAutoresizingMaskIntoConstraints = NO;
    subtitulo.text = self.textos.subtitulo;
    subtitulo.font = FONTS_NOTO_REGULAR(14) ?: [UIFont systemFontOfSize:14];
    subtitulo.textColor = gris;
    subtitulo.numberOfLines = 0;
    [tarjeta addSubview:subtitulo];

    UITextView *campo = [[UITextView alloc] init];
    campo.translatesAutoresizingMaskIntoConstraints = NO;
    campo.font = FONTS_NOTO_REGULAR(15) ?: [UIFont systemFontOfSize:15];
    campo.textColor = oscuro;
    campo.backgroundColor = [UIColor whiteColor];
    campo.layer.cornerRadius = 12;
    campo.layer.borderWidth = 1;
    campo.layer.borderColor = borde.CGColor;
    campo.textContainerInset = UIEdgeInsetsMake(12, 10, 12, 10);
    campo.delegate = self;
    [tarjeta addSubview:campo];
    self.campo = campo;

    // UITextView no tiene placeholder propio: se pone una etiqueta encima y se esconde al
    // escribir. Es el apaño de siempre y es menos fragil que cambiar el texto real, que se
    // acabaria enviando si el usuario no lo borra.
    UILabel *pista = [[UILabel alloc] init];
    pista.translatesAutoresizingMaskIntoConstraints = NO;
    pista.text = self.textos.pista;
    pista.font = FONTS_NOTO_REGULAR(15) ?: [UIFont systemFontOfSize:15];
    pista.textColor = [UIColor colorWithWhite:0.65 alpha:1];
    pista.numberOfLines = 0;
    pista.userInteractionEnabled = NO;
    [tarjeta addSubview:pista];
    self.pistaDelCampo = pista;

    UIButton *enviar = [UIButton buttonWithType:UIButtonTypeCustom];
    enviar.translatesAutoresizingMaskIntoConstraints = NO;
    [enviar setTitle:[LanguageHelper getStringWithKey:@"k_s10_soporte_whatsapp"
                                         defaultValue:@"Escribir por WhatsApp"]
            forState:UIControlStateNormal];
    [enviar setTitleColor:oscuro forState:UIControlStateNormal];
    enviar.titleLabel.font = FONTS_NOTO_BOLD(16) ?: [UIFont boldSystemFontOfSize:16];
    enviar.backgroundColor = amarillo;
    enviar.layer.cornerRadius = 12;
    [enviar addTarget:self action:@selector(enviar) forControlEvents:UIControlEventTouchUpInside];
    [tarjeta addSubview:enviar];

    UIButton *cerrar = [UIButton buttonWithType:UIButtonTypeSystem];
    cerrar.translatesAutoresizingMaskIntoConstraints = NO;
    [cerrar setTitle:[LanguageHelper getStringWithKey:@"k_s10_cerrar" defaultValue:@"Cerrar"]
            forState:UIControlStateNormal];
    [cerrar setTitleColor:gris forState:UIControlStateNormal];
    cerrar.titleLabel.font = FONTS_NOTO_REGULAR(16) ?: [UIFont systemFontOfSize:16];
    [cerrar addTarget:self action:@selector(cerrar) forControlEvents:UIControlEventTouchUpInside];
    [tarjeta addSubview:cerrar];

    self.bordeInferior = [tarjeta.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor];

    [NSLayoutConstraint activateConstraints:@[
        [tarjeta.leadingAnchor  constraintEqualToAnchor:self.view.leadingAnchor],
        [tarjeta.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        self.bordeInferior,

        [asa.topAnchor      constraintEqualToAnchor:tarjeta.topAnchor constant:10],
        [asa.centerXAnchor  constraintEqualToAnchor:tarjeta.centerXAnchor],
        [asa.widthAnchor    constraintEqualToConstant:40],
        [asa.heightAnchor   constraintEqualToConstant:5],

        [titulo.topAnchor      constraintEqualToAnchor:asa.bottomAnchor constant:16],
        [titulo.leadingAnchor  constraintEqualToAnchor:tarjeta.leadingAnchor constant:20],
        [titulo.trailingAnchor constraintEqualToAnchor:tarjeta.trailingAnchor constant:-20],

        [subtitulo.topAnchor      constraintEqualToAnchor:titulo.bottomAnchor constant:6],
        [subtitulo.leadingAnchor  constraintEqualToAnchor:titulo.leadingAnchor],
        [subtitulo.trailingAnchor constraintEqualToAnchor:titulo.trailingAnchor],

        [campo.topAnchor      constraintEqualToAnchor:subtitulo.bottomAnchor constant:16],
        [campo.leadingAnchor  constraintEqualToAnchor:titulo.leadingAnchor],
        [campo.trailingAnchor constraintEqualToAnchor:titulo.trailingAnchor],
        [campo.heightAnchor   constraintEqualToConstant:110],

        [pista.topAnchor      constraintEqualToAnchor:campo.topAnchor constant:12],
        [pista.leadingAnchor  constraintEqualToAnchor:campo.leadingAnchor constant:15],
        [pista.trailingAnchor constraintEqualToAnchor:campo.trailingAnchor constant:-15],

        [enviar.topAnchor      constraintEqualToAnchor:campo.bottomAnchor constant:16],
        [enviar.leadingAnchor  constraintEqualToAnchor:titulo.leadingAnchor],
        [enviar.trailingAnchor constraintEqualToAnchor:titulo.trailingAnchor],
        [enviar.heightAnchor   constraintEqualToConstant:50],

        [cerrar.topAnchor      constraintEqualToAnchor:enviar.bottomAnchor constant:4],
        [cerrar.leadingAnchor  constraintEqualToAnchor:titulo.leadingAnchor],
        [cerrar.trailingAnchor constraintEqualToAnchor:titulo.trailingAnchor],
        [cerrar.heightAnchor   constraintEqualToConstant:44],
        [cerrar.bottomAnchor   constraintEqualToAnchor:tarjeta.safeAreaLayoutGuide.bottomAnchor constant:-8],
    ]];
}

- (void)noHacerNada { }

- (void)textViewDidChange:(UITextView *)textView {
    self.pistaDelCampo.hidden = textView.text.length > 0;
}

/** Sube la hoja para que el teclado no la tape. */
- (void)tecladoCambia:(NSNotification *)aviso {
    CGRect marco = [aviso.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat tapado = MAX(0, CGRectGetHeight(self.view.bounds) - CGRectGetMinY(marco));
    self.bordeInferior.constant = -tapado;
    [UIView animateWithDuration:0.25 animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)cerrar {
    [self.view endEditing:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)enviar {
    NSString *escrito = [self.campo.text stringByTrimmingCharactersInSet:
                         [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (escrito.length == 0) {
        // Sin esto se abriria WhatsApp con la plantilla y nada mas, y soporte recibiria un
        // mensaje que no dice cual es el problema.
        [self avisar:self.textos.avisoVacio];
        return;
    }
    [self.view endEditing:YES];
    [ConrraChatDeSoporte abrirWhatsAppDesde:self
                                    mensaje:[self redactar:escrito]];
}

/**
 La plantilla, en lenguaje natural y firmada.

 Sale algo asi:

   Hola, soy Juan Perez. Les escribo desde mi cuenta de conductor en CONRRA.

   No recibi el pago del viaje #3512 por 2.30$. Esto fue lo que paso:
   el pasajero se bajo sin pagar
 */
- (NSString *)redactar:(NSString *)escrito {
    BOOL esPasajero = [ConrraChatDeSoporte esPasajero];
    NSMutableString *m = [NSMutableString stringWithString:@"Hola"];

    NSString *nombre = [ConrraChatDeSoporte nombreDeQuienEscribe];
    if (nombre.length > 0) {
        [m appendFormat:@", soy %@", nombre];
    }
    [m appendFormat:@". Les escribo desde mi cuenta de %@ en CONRRA.\n\n",
        esPasajero ? @"pasajero" : @"conductor"];

    [m appendString:self.textos.apertura];
    if (self.motivo == ConrraMotivoPagoNoRecibido) {
        if (self.viajeId.length > 0) {
            [m appendFormat:@" #%@", self.viajeId];
        }
        if (self.monto.length > 0) {
            [m appendFormat:@" por %@", self.monto];
        }
        [m appendString:@". Esto fue lo que pasó:"];
    }
    [m appendFormat:@"\n%@", escrito];

    return m;
}

- (void)avisar:(NSString *)mensaje {
    UIAlertController *d = [UIAlertController alertControllerWithTitle:nil
                                                               message:mensaje
                                                        preferredStyle:UIAlertControllerStyleAlert];
    [d addAction:[UIAlertAction actionWithTitle:[LanguageHelper getStringWithKey:@"k_18_s4_Ok" defaultValue:@"OK"]
                                          style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:d animated:YES completion:nil];
}

@end


#pragma mark - La puerta de entrada

@implementation ConrraChatDeSoporte

+ (ConrraTextoDeMotivo *)textosPara:(ConrraMotivoDeSoporte)motivo {
    ConrraTextoDeMotivo *t = [[ConrraTextoDeMotivo alloc] init];
    if (motivo == ConrraMotivoPagoNoRecibido) {
        t.titulo     = [LanguageHelper getStringWithKey:@"k_s10_soporte_pago_titulo"
                                           defaultValue:@"¿Por qué no recibiste el pago?"];
        t.subtitulo  = [LanguageHelper getStringWithKey:@"k_s10_soporte_pago_sub"
                                           defaultValue:@"Cuéntanos qué pasó para poder ayudarte a resolverlo."];
        t.pista      = [LanguageHelper getStringWithKey:@"k_s10_soporte_pago_pista"
                                           defaultValue:@"Ej: el pasajero se bajó sin pagar"];
        t.apertura   = @"No recibí el pago del viaje";
        t.avisoVacio = [LanguageHelper getStringWithKey:@"k_s10_soporte_pago_vacio"
                                           defaultValue:@"Cuéntanos por qué no recibiste el pago"];
    } else {
        t.titulo     = [LanguageHelper getStringWithKey:@"k_s10_soporte_ayuda_titulo"
                                           defaultValue:@"¿En qué podemos ayudarte?"];
        t.subtitulo  = [LanguageHelper getStringWithKey:@"k_s10_soporte_ayuda_sub"
                                           defaultValue:@"Cuéntanos qué necesitas y te respondemos por WhatsApp."];
        t.pista      = [LanguageHelper getStringWithKey:@"k_s10_soporte_ayuda_pista"
                                           defaultValue:@"Ej: no me llegó el recibo de un viaje"];
        t.apertura   = @"Necesito ayuda con lo siguiente:";
        t.avisoVacio = [LanguageHelper getStringWithKey:@"k_s10_soporte_ayuda_vacio"
                                           defaultValue:@"Cuéntanos en qué podemos ayudarte"];
    }
    return t;
}

+ (void)abrirEn:(UIViewController *)vc motivo:(ConrraMotivoDeSoporte)motivo {
    [self abrirEn:vc motivo:motivo viaje:nil monto:nil];
}

+ (void)abrirEn:(UIViewController *)vc
         motivo:(ConrraMotivoDeSoporte)motivo
          viaje:(NSString *)viajeId
          monto:(NSString *)monto {
    if (vc == nil) {
        return;
    }
    ConrraHojaDeSoporte *hoja = [[ConrraHojaDeSoporte alloc] init];
    hoja.motivo  = motivo;
    hoja.textos  = [self textosPara:motivo];
    hoja.viajeId = isEmpty(viajeId);
    hoja.monto   = isEmpty(monto);
    // OverFullScreen y no FullScreen: la pantalla de debajo tiene que seguir en la ventana,
    // porque al cerrar la hoja un viewWillAppear de mas reinicia cosas que no toca.
    hoja.modalPresentationStyle = UIModalPresentationOverFullScreen;
    hoja.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [vc presentViewController:hoja animated:YES completion:nil];
}

#pragma mark - Quien escribe

+ (BOOL)esPasajero {
    return [defaults_object(P_IS_USER_LOGIN) boolValue];
}

+ (NSString *)limpio:(id)valor {
    if (![valor isKindOfClass:[NSString class]]) {
        return @"";
    }
    NSString *t = [(NSString *)valor stringByTrimmingCharactersInSet:
                   [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return [t caseInsensitiveCompare:@"null"] == NSOrderedSame ? @"" : t;
}

+ (NSString *)unir:(id)a con:(id)b {
    NSString *x = [self limpio:a];
    NSString *y = [self limpio:b];
    if (x.length > 0 && y.length > 0) {
        return [NSString stringWithFormat:@"%@ %@", x, y];
    }
    return x.length > 0 ? x : y;
}

/**
 El nombre de quien escribe, o cadena vacia si no se sabe.

 Vacia y no "Usuario": un saludo que diga "soy Usuario" es peor que uno que no diga nombre,
 porque parece un mensaje automatico.
 */
+ (NSString *)nombreDeQuienEscribe {
    NSDictionary *dict = defaults_object(P_USER_DICT_LOGGED);
    if (![dict isKindOfClass:[NSDictionary class]]) {
        dict = defaults_object(P_USER_DICT);
    }
    if (![dict isKindOfClass:[NSDictionary class]]) {
        return @"";
    }
    if ([self esPasajero]) {
        NSString *n = [self unir:[dict objectForKey:P_U_FNAME] con:[dict objectForKey:P_U_LNAME]];
        return n.length > 0 ? n : [self limpio:[dict objectForKey:@"u_name"]];
    }
    NSString *n = [self unir:[dict objectForKey:@"d_fname"] con:[dict objectForKey:@"d_lname"]];
    return n.length > 0 ? n : [self limpio:[dict objectForKey:@"d_name"]];
}

#pragma mark - WhatsApp

/**
 Abre WhatsApp con el numero de soporte del backend.

 La clave se pide como "support number" con espacio a proposito, igual que en Android:
 valorDeConstantePorClave trata "_" y " " como lo mismo, asi que encuentra la fila real, que
 se llama support_number.
 */
+ (void)abrirWhatsAppDesde:(UIViewController *)vc mensaje:(NSString *)mensaje {
    NSString *numero = [ConstantModel valorDeConstantePorClave:@"support number"];
    NSMutableString *digitos = [[NSMutableString alloc] init];
    for (NSUInteger i = 0; i < numero.length; i++) {
        unichar c = [numero characterAtIndex:i];
        if (c >= '0' && c <= '9') {
            [digitos appendFormat:@"%C", c];
        }
    }

    if (digitos.length == 0) {
        // Sin numero no se puede hacer nada, pero al menos se le da el correo en vez de
        // dejarlo mirando una pantalla que no reacciona.
        NSString *correo = isEmpty([ConstantModel getConstantsObject].support_email);
        NSString *aviso = correo.length > 0
            ? [NSString stringWithFormat:@"El número de soporte no está configurado. Escríbenos a %@", correo]
            : @"El número de soporte no está configurado. Avisa a la central.";
        UIAlertController *d = [UIAlertController alertControllerWithTitle:nil
                                                                   message:aviso
                                                            preferredStyle:UIAlertControllerStyleAlert];
        [d addAction:[UIAlertAction actionWithTitle:[LanguageHelper getStringWithKey:@"k_18_s4_Ok" defaultValue:@"OK"]
                                              style:UIAlertActionStyleDefault handler:nil]];
        [vc presentViewController:d animated:YES completion:nil];
        NSLog(@"[Soporte] falta la constante 'support_number' en el backend");
        return;
    }

    NSCharacterSet *permitidos = [NSCharacterSet characterSetWithCharactersInString:
        @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._~"];
    NSString *texto = [mensaje stringByAddingPercentEncodingWithAllowedCharacters:permitidos] ?: @"";

    /*
     El esquema propio primero, wa.me solo de reserva.

     Android abre https://wa.me/... y le vale, porque alli la resolucion de intents casa ese
     host con el filtro que declara WhatsApp. En iOS ese mismo enlace es un universal link, y
     un universal link solo llega a la app si la asociacion resuelve en ese momento: si no
     -- WhatsApp no instalado, el usuario eligio una vez "abrir en Safari" desde la miga de
     pan de wa.me, o la asociacion esta en cache vieja tras reinstalar -- iOS abre Safari y
     enseña la pagina "Continue to Chat". Que es justo lo que se ve: no abre WhatsApp.

     whatsapp://send no depende de nada de eso: va directo a la app. Para poder preguntar por
     el con canOpenURL hay que declarar el esquema en LSApplicationQueriesSchemes del
     Info.plist; sin esa linea canOpenURL devuelve NO aunque WhatsApp este instalado.
     */
    NSURL *directo = [NSURL URLWithString:[NSString stringWithFormat:
                        @"whatsapp://send?phone=%@&text=%@", digitos, texto]];
    NSURL *porWeb  = [NSURL URLWithString:[NSString stringWithFormat:
                        @"https://wa.me/%@?text=%@", digitos, texto]];

    UIApplication *app = [UIApplication sharedApplication];
    NSURL *primera = (directo != nil && [app canOpenURL:directo]) ? directo : porWeb;
    NSURL *segunda = (primera == directo) ? porWeb : nil;

    [self abrir:primera luegoSiFalla:segunda desde:vc numero:digitos];
}

/**
 Abre la primera direccion y, si no se puede, prueba la segunda.

 Lo importante no es el orden sino que NUNCA se acabe sin hacer nada: antes, si openURL
 devolvia NO, el boton se quedaba mudo y no habia forma de saber por que. Un boton que no
 responde parece la app rota.
 */
+ (void)abrir:(NSURL *)url
  luegoSiFalla:(NSURL *)reserva
        desde:(UIViewController *)vc
       numero:(NSString *)digitos {
    if (url == nil) {
        [self noSePudoAbrirDesde:vc numero:digitos];
        return;
    }
    [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL abierto) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (abierto) {
                [vc dismissViewControllerAnimated:YES completion:nil];
                return;
            }
            NSLog(@"[Soporte] no se pudo abrir %@", url.scheme);
            if (reserva != nil) {
                [self abrir:reserva luegoSiFalla:nil desde:vc numero:digitos];
                return;
            }
            [self noSePudoAbrirDesde:vc numero:digitos];
        });
    }];
}

/// Ni la app ni la web: se le da el numero para que escriba a mano.
+ (void)noSePudoAbrirDesde:(UIViewController *)vc numero:(NSString *)digitos {
    // El texto traducible NO se usa como formato: si una traduccion cambiara el %@ por otro
    // especificador, stringWithFormat leeria un argumento que no existe y reventaria.
    NSString *base = [LanguageHelper getStringWithKey:@"k_s10_soporte_sin_whatsapp"
                                         defaultValue:@"No se pudo abrir WhatsApp. Escríbenos al"];
    NSString *aviso = [NSString stringWithFormat:@"%@ +%@", base, digitos];
    UIAlertController *d = [UIAlertController alertControllerWithTitle:nil
                                                               message:aviso
                                                        preferredStyle:UIAlertControllerStyleAlert];
    [d addAction:[UIAlertAction actionWithTitle:[LanguageHelper getStringWithKey:@"k_18_s4_Ok" defaultValue:@"OK"]
                                          style:UIAlertActionStyleDefault handler:nil]];
    [vc presentViewController:d animated:YES completion:nil];
}

@end
