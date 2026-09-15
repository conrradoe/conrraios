//
//  RecargaC2PViewController.m
//  Conrra
//

#import "RecargaC2PViewController.h"
#import "RecargaEstilo.h"
#import "Utilities.h"
#import "CityModel.h"
#import "UserProfile.h"
#import "LanguageHelper.h"
#import "WebCallConstants.h"
#import <GIKit/GIKit.h>

static NSString *const kURLRele = @"https://www.conrraservices.com/recargas/api/c2p.php";

@interface RecargaC2PViewController () <UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) UIScrollView *scroll;
@property (nonatomic, strong) UITextField *campoMonto;
@property (nonatomic, strong) UITextField *campoBanco;
@property (nonatomic, strong) UITextField *campoCedula;
@property (nonatomic, strong) UITextField *campoTelefono;
@property (nonatomic, strong) UITextField *campoClave;
@property (nonatomic, strong) UILabel *lblConversion;
@property (nonatomic, strong) UIView *velo;
@property (nonatomic, strong) NSArray<NSArray<NSString *> *> *bancos;
@property (nonatomic, assign) NSInteger bancoElegido;
@property (nonatomic, assign) BOOL enviando;

@end

@implementation RecargaC2PViewController

/**
 Bancos venezolanos con su codigo.

 El relé lo convierte a entero, asi que "0105" llega como 105, que es lo que espera
 Mercantil. Misma lista y mismo orden que Android: si las dos apps ofrecieran bancos
 distintos, el mismo cliente podria recargar desde Android y no desde iPhone.
 */
+ (NSArray<NSArray<NSString *> *> *)listaDeBancos {
    return @[
        @[@"0102", @"Banco de Venezuela"],
        @[@"0104", @"Venezolano de Crédito"],
        @[@"0105", @"Mercantil"],
        @[@"0108", @"BBVA Provincial"],
        @[@"0114", @"Bancaribe"],
        @[@"0115", @"Exterior"],
        @[@"0128", @"Banco Caroní"],
        @[@"0134", @"Banesco"],
        @[@"0137", @"Sofitasa"],
        @[@"0138", @"Banco Plaza"],
        @[@"0146", @"Bangente"],
        @[@"0151", @"BFC Banco Fondo Común"],
        @[@"0156", @"100% Banco"],
        @[@"0157", @"DelSur"],
        @[@"0163", @"Banco del Tesoro"],
        @[@"0166", @"Banco Agrícola de Venezuela"],
        @[@"0168", @"Bancrecer"],
        @[@"0169", @"Mi Banco"],
        @[@"0171", @"Banco Activo"],
        @[@"0172", @"Bancamiga"],
        @[@"0174", @"Banplus"],
        @[@"0175", @"Banco Bicentenario"],
        @[@"0177", @"Banco Digital de los Trabajadores"],
        @[@"0191", @"BNC Banco Nacional de Crédito"],
    ];
}

/**
 Nombres de banco tal como los guarda "Contacto Pago Móvil", con su codigo.

 Alli el banco se guarda por NOMBRE, no por codigo, asi que hay que traducirlo para poder
 elegirlo en el desplegable. La comparacion es tolerante a mayusculas, acentos, parentesis
 y al prefijo "Banco", porque las dos listas no se escribieron el mismo dia.
 */
+ (NSArray<NSArray<NSString *> *> *)bancosPorNombre {
    return @[
        @[@"Banco de Venezuela", @"0102"],
        @[@"Banco Mercantil", @"0105"],
        @[@"Banco Nacional de Credito", @"0191"],
        @[@"Banco Banesco", @"0134"],
        @[@"Banesco", @"0134"],
        @[@"Banco Provincial", @"0108"],
        @[@"Banco Bancaribe", @"0114"],
        @[@"Bancaribe", @"0114"],
        @[@"Banco Digital de los Trabajadores", @"0177"],
        @[@"Banco del Tesoro", @"0163"],
        @[@"Banco Venezolano Credito", @"0104"],
        @[@"Banco Bancrecer", @"0168"],
        @[@"Banco Fondo Comun", @"0151"],
        @[@"Banco Exterior", @"0115"],
        @[@"Banco Caroni", @"0128"],
        @[@"Banco Sofitasa", @"0137"],
        @[@"Banco Plaza", @"0138"],
        @[@"Banco Activo", @"0171"],
        @[@"Banplus", @"0174"],
        @[@"Banco Bicentenario del Pueblo", @"0175"],
        @[@"Banco Agricola de Venezuela", @"0166"],
        @[@"DelSur", @"0157"],
        @[@"Mi Banco", @"0169"],
    ];
}

/** Quita acentos, mayusculas, parentesis y el prefijo "banco" para poder comparar. */
+ (NSString *)normalizar:(NSString *)texto {
    if (![texto isKindOfClass:[NSString class]]) {
        return @"";
    }
    NSString *limpio = [[texto decomposedStringWithCanonicalMapping]
        stringByFoldingWithOptions:NSDiacriticInsensitiveSearch locale:[NSLocale currentLocale]];
    limpio = [limpio.lowercaseString stringByTrimmingCharactersInSet:
              [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([limpio hasPrefix:@"banco "]) {
        limpio = [limpio substringFromIndex:6];
    }
    NSMutableString *solo = [[NSMutableString alloc] init];
    for (NSUInteger i = 0; i < limpio.length; i++) {
        unichar c = [limpio characterAtIndex:i];
        if ((c >= 'a' && c <= 'z') || (c >= '0' && c <= '9')) {
            [solo appendFormat:@"%C", c];
        }
    }
    return solo;
}

#pragma mark - Ciclo

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [RecargaEstilo fondo];
    self.bancos = [[self class] listaDeBancos];
    self.bancoElegido = 0;

    [self montarVistas];
    [self prellenarDatosGuardados];
    [self actualizarConversion];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

#pragma mark - Montaje

- (void)montarVistas {
    UIView *cabecera = [RecargaEstilo cabeceraEn:self
                                          titulo:[LanguageHelper getStringWithKey:@"k_s10_recarga_c2p"
                                                                     defaultValue:@"Pago móvil C2P"]
                                          accion:@selector(volver)];

    self.scroll = [[UIScrollView alloc] init];
    self.scroll.translatesAutoresizingMaskIntoConstraints = NO;
    self.scroll.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    self.scroll.alwaysBounceVertical = YES;
    [self.view addSubview:self.scroll];

    UIStackView *pila = [[UIStackView alloc] init];
    pila.translatesAutoresizingMaskIntoConstraints = NO;
    pila.axis = UILayoutConstraintAxisVertical;
    pila.spacing = 8;
    [self.scroll addSubview:pila];

    self.campoMonto = [RecargaEstilo campoConPista:@"0.00"];
    self.campoMonto.keyboardType = UIKeyboardTypeDecimalPad;
    self.campoMonto.font = FONTS_NOTO_BOLD(18) ?: [UIFont boldSystemFontOfSize:18];
    [self.campoMonto addTarget:self action:@selector(actualizarConversion)
              forControlEvents:UIControlEventEditingChanged];

    self.lblConversion = [RecargaEstilo ayuda:@""];

    self.campoBanco = [RecargaEstilo campoConPista:@""];
    [self montarDesplegableDeBancos];

    self.campoCedula = [RecargaEstilo campoConPista:@"V12345678"];
    self.campoCedula.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
    self.campoCedula.autocorrectionType = UITextAutocorrectionTypeNo;

    self.campoTelefono = [RecargaEstilo campoConPista:@"04141234567"];
    self.campoTelefono.keyboardType = UIKeyboardTypePhonePad;

    self.campoClave = [RecargaEstilo campoConPista:[LanguageHelper getStringWithKey:@"k_s10_recarga_clave_pista"
                                                                      defaultValue:@"8 dígitos"]];
    self.campoClave.keyboardType = UIKeyboardTypeNumberPad;
    self.campoClave.secureTextEntry = YES;

    [pila addArrangedSubview:[RecargaEstilo rotulo:[LanguageHelper getStringWithKey:@"k_s10_recarga_monto"
                                                                      defaultValue:@"Monto a recargar (USD)"]]];
    [pila addArrangedSubview:self.campoMonto];
    [pila addArrangedSubview:self.lblConversion];
    [pila setCustomSpacing:20 afterView:self.lblConversion];

    [pila addArrangedSubview:[RecargaEstilo rotulo:[LanguageHelper getStringWithKey:@"k_s10_recarga_banco"
                                                                      defaultValue:@"Tu banco"]]];
    [pila addArrangedSubview:self.campoBanco];
    [pila setCustomSpacing:20 afterView:self.campoBanco];

    [pila addArrangedSubview:[RecargaEstilo rotulo:[LanguageHelper getStringWithKey:@"k_s10_recarga_cedula"
                                                                      defaultValue:@"Cédula"]]];
    [pila addArrangedSubview:self.campoCedula];
    [pila setCustomSpacing:20 afterView:self.campoCedula];

    [pila addArrangedSubview:[RecargaEstilo rotulo:[LanguageHelper getStringWithKey:@"k_s10_recarga_telefono"
                                                                      defaultValue:@"Teléfono afiliado al pago móvil"]]];
    [pila addArrangedSubview:self.campoTelefono];
    UILabel *ayudaTelefono = [RecargaEstilo ayuda:[LanguageHelper getStringWithKey:@"k_s10_recarga_telefono_ayuda"
                                                                     defaultValue:@"Escríbelo como lo tienes en el banco, empezando por 0."]];
    [pila addArrangedSubview:ayudaTelefono];
    [pila setCustomSpacing:20 afterView:ayudaTelefono];

    [pila addArrangedSubview:[RecargaEstilo rotulo:[LanguageHelper getStringWithKey:@"k_s10_recarga_clave"
                                                                      defaultValue:@"Clave de pago C2P"]]];
    [pila addArrangedSubview:self.campoClave];
    [pila addArrangedSubview:[RecargaEstilo ayuda:[LanguageHelper getStringWithKey:@"k_s10_recarga_clave_ayuda"
                                                                     defaultValue:@"Genera esta clave en la app o el SMS de tu banco, justo antes de pagar. Suele caducar en pocos minutos."]]];

    UIButton *pagar = [RecargaEstilo botonPrincipalConTitulo:[LanguageHelper getStringWithKey:@"k_s10_recarga_pagar"
                                                                                 defaultValue:@"Pagar"]];
    [pagar addTarget:self action:@selector(confirmar) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:pagar];

    // El velo va el ultimo para quedar por encima de todo, incluido el boton.
    self.velo = [RecargaEstilo veloDeEsperaEn:self.view];

    UILayoutGuide *seguro = self.view.safeAreaLayoutGuide;
    UILayoutGuide *contenido = self.scroll.contentLayoutGuide;
    CGFloat margen = 24;

    [NSLayoutConstraint activateConstraints:@[
        [self.scroll.topAnchor      constraintEqualToAnchor:cabecera.bottomAnchor],
        [self.scroll.leadingAnchor  constraintEqualToAnchor:self.view.leadingAnchor],
        [self.scroll.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.scroll.bottomAnchor   constraintEqualToAnchor:pagar.topAnchor constant:-12],

        // Todo contra contentLayoutGuide, y el ANCHO contra frameLayoutGuide. Es la receta
        // de siempre: mezclar los bordes del scroll con los de su contenido deja el alto
        // del contenido sin definir y la pila no se desplaza.
        [pila.topAnchor      constraintEqualToAnchor:contenido.topAnchor constant:16],
        [pila.bottomAnchor   constraintEqualToAnchor:contenido.bottomAnchor constant:-24],
        [pila.leadingAnchor  constraintEqualToAnchor:contenido.leadingAnchor constant:margen],
        [pila.trailingAnchor constraintEqualToAnchor:contenido.trailingAnchor constant:-margen],
        [pila.widthAnchor    constraintEqualToAnchor:self.scroll.frameLayoutGuide.widthAnchor
                                            constant:-2 * margen],

        [pagar.leadingAnchor  constraintEqualToAnchor:self.view.leadingAnchor constant:margen],
        [pagar.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-margen],
        [pagar.bottomAnchor   constraintEqualToAnchor:seguro.bottomAnchor constant:-20],
    ]];
}

/**
 El desplegable de bancos.

 Android usa un Spinner. En iOS lo equivalente es una rueda como teclado de un campo de
 solo lectura: ocupa lo mismo que el resto de campos y no hace falta montar una hoja
 aparte para veinticuatro filas.
 */
- (void)montarDesplegableDeBancos {
    UIPickerView *rueda = [[UIPickerView alloc] init];
    rueda.dataSource = self;
    rueda.delegate = self;

    UIToolbar *barra = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 0, 44)];
    barra.items = @[
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                      target:nil action:nil],
        [[UIBarButtonItem alloc] initWithTitle:[LanguageHelper getStringWithKey:@"k_18_s4_Ok" defaultValue:@"Listo"]
                                          style:UIBarButtonItemStyleDone
                                         target:self action:@selector(cerrarTeclado)],
    ];

    self.campoBanco.inputView = rueda;
    self.campoBanco.inputAccessoryView = barra;
    self.campoBanco.tintColor = [UIColor clearColor];   // sin cursor: no se teclea
    self.campoBanco.delegate = self;
    [self pintarBancoElegido];
}

- (void)pintarBancoElegido {
    NSArray<NSString *> *banco = [self.bancos objectAtIndex:self.bancoElegido];
    self.campoBanco.text = [NSString stringWithFormat:@"%@ · %@",
                            [banco objectAtIndex:0], [banco objectAtIndex:1]];
}

- (void)cerrarTeclado {
    [self.view endEditing:YES];
}

#pragma mark - Prellenado

/**
 Rellena el formulario con los datos de pago movil que el usuario ya registro en
 "Contacto Pago Móvil".

 Mismo JSON para los dos roles -- {bank, phone, cc, idType, idNumber} -- pero en campos
 distintos: el conductor en d_bank_info y el pasajero en emergency_email_3, que en esta
 instalacion esta libre. Es el mismo contrato que respeta SettingViewController.

 Los campos quedan editables a proposito: alguien puede pagar desde otro telefono o con la
 cedula de otra persona.
 */
- (void)prellenarDatosGuardados {
    NSDictionary *dict = defaults_object(P_USER_DICT);
    if (![dict isKindOfClass:[NSDictionary class]]) {
        return;
    }
    BOOL esPasajero = [defaults_object(P_IS_USER_LOGIN) boolValue];
    NSString *guardado = esPasajero ? [dict objectForKey:@"emergency_email_3"]
                                    : [dict objectForKey:@"d_bank_info"];

    if ([guardado isKindOfClass:[NSString class]]) {
        NSString *limpio = [guardado stringByTrimmingCharactersInSet:
                            [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if ([limpio hasPrefix:@"{"]) {
            id leido = [NSJSONSerialization JSONObjectWithData:[limpio dataUsingEncoding:NSUTF8StringEncoding]
                                                        options:0 error:nil];
            if ([leido isKindOfClass:[NSDictionary class]]) {
                NSDictionary *json = (NSDictionary *)leido;

                NSString *tipo = [[NSString stringWithFormat:@"%@", [json objectForKey:@"idType"] ?: @""]
                                  uppercaseString];
                NSString *numero = [self soloDigitos:[NSString stringWithFormat:@"%@",
                                                      [json objectForKey:@"idNumber"] ?: @""]];
                // El formulario de contactos admite J y G; Mercantil no. Se deja el numero
                // para no teclearlo, pero sin una letra que el banco rechazaria.
                if (!([tipo isEqualToString:@"V"] || [tipo isEqualToString:@"E"] || [tipo isEqualToString:@"P"])) {
                    tipo = @"";
                }
                if (numero.length > 0) {
                    self.campoCedula.text = [NSString stringWithFormat:@"%@%@", tipo, numero];
                }
                [self ponerTelefono:[NSString stringWithFormat:@"%@", [json objectForKey:@"phone"] ?: @""]];
                [self elegirBancoPorNombre:[NSString stringWithFormat:@"%@", [json objectForKey:@"bank"] ?: @""]];
                return;
            }
        }
    }

    // Sin pago movil registrado: al menos el telefono de la cuenta, que suele ser el mismo.
    NSString *telefono = [dict objectForKey:esPasajero ? @"u_phone" : @"d_phone"];
    [self ponerTelefono:[NSString stringWithFormat:@"%@", telefono ?: @""]];
}

- (NSString *)soloDigitos:(NSString *)texto {
    NSMutableString *salida = [[NSMutableString alloc] init];
    for (NSUInteger i = 0; i < texto.length; i++) {
        unichar c = [texto characterAtIndex:i];
        if (c >= '0' && c <= '9') {
            [salida appendFormat:@"%C", c];
        }
    }
    return salida;
}

/** El telefono puede venir con o sin el cero inicial, o con el 58 delante. */
- (void)ponerTelefono:(NSString *)telefono {
    NSString *digitos = [self soloDigitos:telefono];
    if ([digitos hasPrefix:@"58"] && digitos.length == 12) {
        digitos = [digitos substringFromIndex:2];
    }
    if (digitos.length == 10 && ![digitos hasPrefix:@"0"]) {
        digitos = [NSString stringWithFormat:@"0%@", digitos];
    }
    if (digitos.length == 11 && [digitos hasPrefix:@"0"]) {
        self.campoTelefono.text = digitos;
    }
}

- (void)elegirBancoPorNombre:(NSString *)nombre {
    NSString *buscado = [[self class] normalizar:nombre];
    if (buscado.length == 0) {
        return;
    }
    NSString *codigo = nil;
    for (NSArray<NSString *> *fila in [[self class] bancosPorNombre]) {
        if ([[[self class] normalizar:[fila objectAtIndex:0]] isEqualToString:buscado]) {
            codigo = [fila objectAtIndex:1];
            break;
        }
    }
    if (codigo == nil) {
        return;
    }
    for (NSInteger i = 0; i < (NSInteger)self.bancos.count; i++) {
        if ([[[self.bancos objectAtIndex:i] objectAtIndex:0] isEqualToString:codigo]) {
            self.bancoElegido = i;
            [self pintarBancoElegido];
            return;
        }
    }
}

#pragma mark - Conversion

/**
 La conversion que se muestra es ORIENTATIVA.

 El monto en bolivares que se cobra lo calcula el servidor con su propia tasa. Si el app
 mandara la tasa, un cliente podria enviar 1 y recargar 100 dolares pagando 100 bolivares.
 */
- (void)actualizarConversion {
    float tasa = [RecargaEstilo tasa];
    double usd = [self montoEscrito];
    if (tasa <= 0 || usd <= 0) {
        self.lblConversion.text = @"";
        return;
    }
    self.lblConversion.text = [NSString stringWithFormat:@"%@ Bs %@ · %@ %@",
        [LanguageHelper getStringWithKey:@"k_s10_recarga_pagaras" defaultValue:@"Pagarás aprox."],
        [RecargaEstilo enFormatoLocal:usd * tasa],
        [LanguageHelper getStringWithKey:@"k_s10_recarga_tasa" defaultValue:@"tasa"],
        [RecargaEstilo enFormatoLocal:tasa]];
}

- (double)montoEscrito {
    NSString *crudo = [self.campoMonto.text stringByTrimmingCharactersInSet:
                       [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    crudo = [crudo stringByReplacingOccurrencesOfString:@"," withString:@"."];
    return [crudo doubleValue];
}

#pragma mark - Pago

- (void)confirmar {
    if (self.enviando) {
        return;
    }
    [self.view endEditing:YES];

    double usd = [self montoEscrito];
    NSString *cedula = [[self.campoCedula.text stringByTrimmingCharactersInSet:
                         [NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    NSString *telefono = [self.campoTelefono.text stringByTrimmingCharactersInSet:
                          [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *clave = [self.campoClave.text stringByTrimmingCharactersInSet:
                       [NSCharacterSet whitespaceAndNewlineCharacterSet]];

    if (usd <= 0) {
        [self avisar:[LanguageHelper getStringWithKey:@"k_s10_recarga_err_monto"
                                          defaultValue:@"Escribe cuánto quieres recargar"]];
        return;
    }
    // Mercantil solo admite V, E o P como tipo de identificacion. Ni J ni G.
    if (![self texto:cedula cumple:@"^[VEP][0-9]{6,9}$"]) {
        [self avisar:[LanguageHelper getStringWithKey:@"k_s10_recarga_err_cedula"
                                          defaultValue:@"Escribe tu cédula, por ejemplo V12345678"]];
        return;
    }
    if (![self texto:telefono cumple:@"^0[0-9]{10}$"]) {
        [self avisar:[LanguageHelper getStringWithKey:@"k_s10_recarga_err_telefono"
                                          defaultValue:@"Escribe los 11 dígitos, por ejemplo 04141234567"]];
        return;
    }
    if (clave.length < 4) {
        [self avisar:[LanguageHelper getStringWithKey:@"k_s10_recarga_err_clave"
                                          defaultValue:@"Escribe la clave que te dio tu banco"]];
        return;
    }

    CityModel *ciudad = [CityModel getCityByCityId:[UserProfile shared].loggedCityID];
    NSString *enMoneda = [Utilities formatAmountAndCurrency:(float)usd currency:ciudad.city_cur];
    if (enMoneda.length == 0) {
        enMoneda = [NSString stringWithFormat:@"$%.2f", usd];
    }

    // El cuerpo se arma pegando trozos, NO con stringWithFormat sobre un texto del
    // servidor: en Android la misma cadena lleva "%1$s", que en iOS no es un especificador
    // valido y revienta en tiempo de ejecucion. Un rotulo traducido nunca debe poder
    // tumbar el app.
    NSMutableString *mensaje = [NSMutableString stringWithFormat:@"%@ %@ %@",
        [LanguageHelper getStringWithKey:@"k_s10_recarga_vas_a_recargar" defaultValue:@"Vas a recargar"],
        enMoneda,
        [LanguageHelper getStringWithKey:@"k_s10_recarga_a_tu_saldo" defaultValue:@"a tu saldo Conrra."]];
    float tasa = [RecargaEstilo tasa];
    if (tasa > 0) {
        [mensaje appendFormat:@"\n\n%@ Bs %@.",
            [LanguageHelper getStringWithKey:@"k_s10_recarga_se_descontaran"
                                defaultValue:@"Se descontarán aprox."],
            [RecargaEstilo enFormatoLocal:usd * tasa]];
    }

    UIAlertController *dialogo = [UIAlertController
        alertControllerWithTitle:[LanguageHelper getStringWithKey:@"k_s10_recarga_confirmar"
                                                     defaultValue:@"Confirmar recarga"]
                         message:mensaje
                  preferredStyle:UIAlertControllerStyleAlert];
    [dialogo addAction:[UIAlertAction actionWithTitle:[LanguageHelper getStringWithKey:@"k_30_s6_cancel_j"
                                                                          defaultValue:@"Cancelar"]
                                                 style:UIAlertActionStyleCancel handler:nil]];
    [dialogo addAction:[UIAlertAction actionWithTitle:[LanguageHelper getStringWithKey:@"k_s10_recarga_pagar"
                                                                          defaultValue:@"Pagar"]
                                                 style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction *a) {
        [self pagar:usd cedula:cedula telefono:telefono clave:clave];
    }]];
    [self presentViewController:dialogo animated:YES completion:nil];
}

- (BOOL)texto:(NSString *)texto cumple:(NSString *)patron {
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:patron
                                                                           options:0 error:nil];
    if (regex == nil || texto == nil) {
        return NO;
    }
    return [regex numberOfMatchesInString:texto options:0 range:NSMakeRange(0, texto.length)] > 0;
}

- (void)pagar:(double)usd cedula:(NSString *)cedula telefono:(NSString *)telefono clave:(NSString *)clave {
    self.enviando = YES;
    self.velo.hidden = NO;

    NSDictionary *campos = @{
        @"monto_usd": [NSString stringWithFormat:@"%.2f", usd],
        @"cedula":    cedula,
        @"telefono":  telefono,
        @"clave":     clave,
        @"banco":     [[self.bancos objectAtIndex:self.bancoElegido] objectAtIndex:0],
    };

    // Sin reintentos: reintentar un cobro es cobrar dos veces.
    [RecargaEstilo enviarA:kURLRele campos:campos completado:^(NSDictionary *json, NSError *error) {
        self.enviando = NO;
        self.velo.hidden = YES;

        if (error != nil || json == nil) {
            // Sin respuesta NO se sabe si el banco cobro o no. Decir "fallo" seria mentir
            // si el cargo si paso.
            [self mostrarResultadoOk:NO
                             mensaje:[LanguageHelper getStringWithKey:@"k_s10_recarga_err_red"
                                                         defaultValue:@"No pudimos confirmar el resultado con el banco."]
                              dudoso:YES];
            return;
        }

        if ([[json objectForKey:@"ok"] boolValue]) {
            [self mostrarRecargaExitosa:json];
        } else {
            NSString *mensaje = [json objectForKey:@"mensaje"];
            if (![mensaje isKindOfClass:[NSString class]] || mensaje.length == 0) {
                mensaje = [LanguageHelper getStringWithKey:@"k_s10_recarga_err_generico"
                                              defaultValue:@"El banco rechazó el pago. Revisa tus datos e intenta de nuevo."];
            }
            [self mostrarResultadoOk:NO mensaje:mensaje dudoso:NO];
        }
    }];
}

#pragma mark - Resultado

/**
 Confirmacion de recarga: lo acreditado en dolares, lo pagado en bolivares y la referencia
 del banco.

 Los tres datos vienen del relé, no se calculan aqui: la conversion que se ve antes de
 pagar es orientativa, y el importe real lo fija el servidor con su propia tasa. Enseñar el
 numero del app podria no coincidir con el cargo real.

 La referencia queda pequeña abajo pero SIEMPRE visible: es lo que hace falta para reclamar
 si algo sale mal.
 */
- (void)mostrarRecargaExitosa:(NSDictionary *)json {
    NSString *montoUsd = [NSString stringWithFormat:@"%@", [json objectForKey:@"monto_usd"] ?: @""];
    NSString *montoVes = [NSString stringWithFormat:@"%@", [json objectForKey:@"monto_ves"] ?: @""];
    NSString *tasa     = [NSString stringWithFormat:@"%@", [json objectForKey:@"tasa"] ?: @""];
    NSString *ref      = [NSString stringWithFormat:@"%@", [json objectForKey:@"referencia"] ?: @""];

    UIView *velo = [[UIView alloc] initWithFrame:self.view.bounds];
    velo.backgroundColor = [UIColor colorWithWhite:0 alpha:0.55];
    velo.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:velo];

    UIView *tarjeta = [[UIView alloc] init];
    tarjeta.translatesAutoresizingMaskIntoConstraints = NO;
    tarjeta.backgroundColor = [UIColor whiteColor];
    tarjeta.layer.cornerRadius = 20;
    [velo addSubview:tarjeta];

    UIStackView *pila = [[UIStackView alloc] init];
    pila.translatesAutoresizingMaskIntoConstraints = NO;
    pila.axis = UILayoutConstraintAxisVertical;
    pila.alignment = UIStackViewAlignmentFill;
    pila.spacing = 8;
    [tarjeta addSubview:pila];

    UIImageView *tic = [[UIImageView alloc] init];
    tic.translatesAutoresizingMaskIntoConstraints = NO;
    tic.contentMode = UIViewContentModeScaleAspectFit;
    // Sin configuracion de tamaño, un simbolo del sistema se dibuja al tamaño del texto
    // por defecto y la constraint de 72 solo dejaria hueco vacio alrededor.
    tic.image = [UIImage systemImageNamed:@"checkmark.circle.fill"
                        withConfiguration:[UIImageSymbolConfiguration configurationWithPointSize:64
                                                                                          weight:UIImageSymbolWeightRegular]];
    tic.tintColor = [RecargaEstilo verde];
    [tic.heightAnchor constraintEqualToConstant:72].active = YES;
    [pila addArrangedSubview:tic];
    [pila setCustomSpacing:20 afterView:tic];

    UILabel *titulo = [[UILabel alloc] init];
    titulo.text = [LanguageHelper getStringWithKey:@"k_s10_recarga_ok_titulo" defaultValue:@"Recarga realizada"];
    titulo.font = FONTS_NOTO_BOLD(20) ?: [UIFont boldSystemFontOfSize:20];
    titulo.textColor = [RecargaEstilo textoPrincipal];
    titulo.textAlignment = NSTextAlignmentCenter;
    [pila addArrangedSubview:titulo];

    if (montoUsd.length > 0 && [montoUsd doubleValue] > 0) {
        CityModel *ciudad = [CityModel getCityByCityId:[UserProfile shared].loggedCityID];
        NSString *conMoneda = [Utilities formatAmountAndCurrency:[montoUsd floatValue] currency:ciudad.city_cur];
        UILabel *lblMonto = [[UILabel alloc] init];
        lblMonto.text = [NSString stringWithFormat:@"+ %@",
                         conMoneda.length > 0 ? conMoneda : [NSString stringWithFormat:@"$%@", montoUsd]];
        lblMonto.font = FONTS_NOTO_BOLD(34) ?: [UIFont boldSystemFontOfSize:34];
        lblMonto.textColor = [RecargaEstilo verde];
        lblMonto.textAlignment = NSTextAlignmentCenter;
        lblMonto.adjustsFontSizeToFitWidth = YES;
        lblMonto.minimumScaleFactor = 0.6f;
        [pila addArrangedSubview:lblMonto];
    }

    UILabel *cuerpo = [[UILabel alloc] init];
    cuerpo.text = [LanguageHelper getStringWithKey:@"k_s10_recarga_ok_cuerpo"
                                      defaultValue:@"Ya está disponible en tu saldo Conrra."];
    cuerpo.font = FONTS_NOTO_REGULAR(15) ?: [UIFont systemFontOfSize:15];
    cuerpo.textColor = [RecargaEstilo textoTerciario];
    cuerpo.textAlignment = NSTextAlignmentCenter;
    cuerpo.numberOfLines = 0;
    [pila addArrangedSubview:cuerpo];

    UIView *ultimoAntesDelBoton = cuerpo;

    NSMutableArray<NSString *> *detalles = [[NSMutableArray alloc] init];
    if (montoVes.length > 0 && [montoVes doubleValue] > 0) {
        [detalles addObject:[NSString stringWithFormat:@"%@ Bs %@ · %@ %@",
            [LanguageHelper getStringWithKey:@"k_s10_recarga_pagaste" defaultValue:@"Pagaste"],
            [RecargaEstilo enFormatoLocal:[montoVes doubleValue]],
            [LanguageHelper getStringWithKey:@"k_s10_recarga_tasa" defaultValue:@"tasa"],
            [RecargaEstilo enFormatoLocal:[tasa doubleValue]]]];
    }
    if (ref.length > 0 && ![ref isEqualToString:@"null"] && ![ref isEqualToString:@"(null)"]) {
        [detalles addObject:[NSString stringWithFormat:@"%@ %@",
            [LanguageHelper getStringWithKey:@"k_s10_recarga_referencia" defaultValue:@"Referencia:"], ref]];
    }
    if (detalles.count > 0) {
        UIView *caja = [RecargaEstilo tarjeta];
        UILabel *lbl = [[UILabel alloc] init];
        lbl.translatesAutoresizingMaskIntoConstraints = NO;
        lbl.text = [detalles componentsJoinedByString:@"\n"];
        lbl.font = FONTS_NOTO_REGULAR(13) ?: [UIFont systemFontOfSize:13];
        lbl.textColor = [RecargaEstilo textoTerciario];
        lbl.numberOfLines = 0;
        [caja addSubview:lbl];
        [NSLayoutConstraint activateConstraints:@[
            [lbl.topAnchor      constraintEqualToAnchor:caja.topAnchor constant:14],
            [lbl.bottomAnchor   constraintEqualToAnchor:caja.bottomAnchor constant:-14],
            [lbl.leadingAnchor  constraintEqualToAnchor:caja.leadingAnchor constant:14],
            [lbl.trailingAnchor constraintEqualToAnchor:caja.trailingAnchor constant:-14],
        ]];
        [pila setCustomSpacing:20 afterView:cuerpo];
        [pila addArrangedSubview:caja];
        ultimoAntesDelBoton = caja;
    }

    UIButton *listo = [RecargaEstilo botonPrincipalConTitulo:
                       [LanguageHelper getStringWithKey:@"k_s10_recarga_listo" defaultValue:@"Listo"]];
    [listo addTarget:self action:@selector(cerrarTrasExito:) forControlEvents:UIControlEventTouchUpInside];
    [pila addArrangedSubview:listo];
    [pila setCustomSpacing:24 afterView:ultimoAntesDelBoton];

    [NSLayoutConstraint activateConstraints:@[
        [tarjeta.centerXAnchor constraintEqualToAnchor:velo.centerXAnchor],
        [tarjeta.centerYAnchor constraintEqualToAnchor:velo.centerYAnchor],
        [tarjeta.widthAnchor   constraintEqualToAnchor:velo.widthAnchor multiplier:0.88],
        [pila.topAnchor      constraintEqualToAnchor:tarjeta.topAnchor constant:28],
        [pila.bottomAnchor   constraintEqualToAnchor:tarjeta.bottomAnchor constant:-28],
        [pila.leadingAnchor  constraintEqualToAnchor:tarjeta.leadingAnchor constant:28],
        [pila.trailingAnchor constraintEqualToAnchor:tarjeta.trailingAnchor constant:-28],
    ]];
}

- (void)cerrarTrasExito:(UIButton *)boton {
    // Volver al selector, que refresca el saldo en viewWillAppear.
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)mostrarResultadoOk:(BOOL)ok mensaje:(NSString *)mensaje dudoso:(BOOL)dudoso {
    NSString *cuerpo = mensaje;
    if (dudoso) {
        cuerpo = [NSString stringWithFormat:@"%@\n\n%@", mensaje,
            [LanguageHelper getStringWithKey:@"k_s10_recarga_revisa_saldo"
                                defaultValue:@"Revisa tu saldo antes de volver a intentarlo: si el cobro se hizo, no queremos que pagues dos veces."]];
    }
    UIAlertController *dialogo = [UIAlertController
        alertControllerWithTitle:ok ? [LanguageHelper getStringWithKey:@"k_s10_recarga_ok_titulo" defaultValue:@"Recarga realizada"]
                                    : [LanguageHelper getStringWithKey:@"k_s10_recarga_err_titulo" defaultValue:@"No se pudo completar"]
                         message:cuerpo
                  preferredStyle:UIAlertControllerStyleAlert];
    [dialogo addAction:[UIAlertAction actionWithTitle:[LanguageHelper getStringWithKey:@"k_18_s4_Ok" defaultValue:@"OK"]
                                                 style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction *a) {
        if (ok) {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }]];
    [self presentViewController:dialogo animated:YES completion:nil];
}

- (void)avisar:(NSString *)mensaje {
    UIAlertController *dialogo = [UIAlertController alertControllerWithTitle:nil
                                                                     message:mensaje
                                                              preferredStyle:UIAlertControllerStyleAlert];
    [dialogo addAction:[UIAlertAction actionWithTitle:[LanguageHelper getStringWithKey:@"k_18_s4_Ok" defaultValue:@"OK"]
                                                 style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:dialogo animated:YES completion:nil];
}

- (void)volver {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UIPickerView

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView { return 1; }

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.bancos.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSArray<NSString *> *banco = [self.bancos objectAtIndex:row];
    return [NSString stringWithFormat:@"%@ · %@", [banco objectAtIndex:0], [banco objectAtIndex:1]];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.bancoElegido = row;
    [self pintarBancoElegido];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField
    shouldChangeCharactersInRange:(NSRange)range
                replacementString:(NSString *)string {
    // El campo del banco se elige con la rueda, no se escribe.
    return textField != self.campoBanco;
}

@end
