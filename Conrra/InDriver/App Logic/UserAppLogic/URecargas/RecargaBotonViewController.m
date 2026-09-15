//
//  RecargaBotonViewController.m
//  Conrra
//

#import "RecargaBotonViewController.h"
#import "RecargaEstilo.h"
#import "LanguageHelper.h"
#import "WebCallConstants.h"
#import <GIKit/GIKit.h>

static NSString *const kURLRele = @"https://www.conrraservices.com/recargas/api/boton.php";

@interface RecargaBotonViewController ()
@property (nonatomic, strong) UITextField *campoMonto;
@property (nonatomic, strong) UILabel *lblConversion;
@property (nonatomic, strong) UIView *velo;
@property (nonatomic, assign) BOOL pidiendoEnlace;
@property (nonatomic, assign) BOOL fueAlBanco;
@end

@implementation RecargaBotonViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [RecargaEstilo fondo];
    [self montarVistas];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (!self.fueAlBanco) {
        return;
    }
    self.fueAlBanco = NO;
    // No se sabe el resultado: lo confirma Mercantil por webhook, no el regreso del
    // navegador. Decir "recarga realizada" aqui seria inventarselo.
    UIAlertController *dialogo = [UIAlertController
        alertControllerWithTitle:[LanguageHelper getStringWithKey:@"k_s10_recarga_proceso_titulo"
                                                     defaultValue:@"Pago en proceso"]
                         message:[LanguageHelper getStringWithKey:@"k_s10_recarga_proceso_cuerpo"
                                                     defaultValue:@"Si completaste el pago, tu saldo se actualizará en cuanto el banco nos lo confirme. Revísalo en unos minutos."]
                  preferredStyle:UIAlertControllerStyleAlert];
    [dialogo addAction:[UIAlertAction actionWithTitle:[LanguageHelper getStringWithKey:@"k_18_s4_Ok" defaultValue:@"OK"]
                                                 style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction *a) {
        [self.navigationController popViewControllerAnimated:YES];
    }]];
    [self presentViewController:dialogo animated:YES completion:nil];
}

#pragma mark - Montaje

- (void)montarVistas {
    UIView *cabecera = [RecargaEstilo cabeceraEn:self
                                          titulo:[LanguageHelper getStringWithKey:@"k_s10_recarga_tarjeta"
                                                                     defaultValue:@"Tarjeta de crédito o débito"]
                                          accion:@selector(volver)];

    UIStackView *pila = [[UIStackView alloc] init];
    pila.translatesAutoresizingMaskIntoConstraints = NO;
    pila.axis = UILayoutConstraintAxisVertical;
    pila.spacing = 8;
    [self.view addSubview:pila];

    self.campoMonto = [RecargaEstilo campoConPista:@"0.00"];
    self.campoMonto.keyboardType = UIKeyboardTypeDecimalPad;
    self.campoMonto.font = FONTS_NOTO_BOLD(18) ?: [UIFont boldSystemFontOfSize:18];
    [self.campoMonto addTarget:self action:@selector(actualizarConversion)
              forControlEvents:UIControlEventEditingChanged];

    self.lblConversion = [RecargaEstilo ayuda:@""];

    [pila addArrangedSubview:[RecargaEstilo rotulo:[LanguageHelper getStringWithKey:@"k_s10_recarga_monto"
                                                                      defaultValue:@"Monto a recargar (USD)"]]];
    [pila addArrangedSubview:self.campoMonto];
    [pila addArrangedSubview:self.lblConversion];
    [pila setCustomSpacing:24 afterView:self.lblConversion];
    [pila addArrangedSubview:[RecargaEstilo ayuda:[LanguageHelper getStringWithKey:@"k_s10_recarga_tarjeta_ayuda"
                                                                     defaultValue:@"Te llevaremos a la página segura de Mercantil para que introduzcas los datos de tu tarjeta. Conrra no los recibe ni los guarda."]]];

    UIButton *continuar = [RecargaEstilo botonPrincipalConTitulo:
                           [LanguageHelper getStringWithKey:@"k_s10_recarga_continuar"
                                               defaultValue:@"Continuar al banco"]];
    [continuar addTarget:self action:@selector(pedirEnlace) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:continuar];

    self.velo = [RecargaEstilo veloDeEsperaEn:self.view];

    UILayoutGuide *seguro = self.view.safeAreaLayoutGuide;
    CGFloat margen = 24;
    [NSLayoutConstraint activateConstraints:@[
        [pila.topAnchor      constraintEqualToAnchor:cabecera.bottomAnchor constant:16],
        [pila.leadingAnchor  constraintEqualToAnchor:self.view.leadingAnchor constant:margen],
        [pila.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-margen],

        [continuar.leadingAnchor  constraintEqualToAnchor:self.view.leadingAnchor constant:margen],
        [continuar.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-margen],
        [continuar.bottomAnchor   constraintEqualToAnchor:seguro.bottomAnchor constant:-20],
    ]];
}

#pragma mark - Conversion

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

#pragma mark - Pasarela

- (void)pedirEnlace {
    if (self.pidiendoEnlace) {
        return;
    }
    [self.view endEditing:YES];

    double usd = [self montoEscrito];
    if (usd <= 0) {
        [self avisar:[LanguageHelper getStringWithKey:@"k_s10_recarga_err_monto"
                                          defaultValue:@"Escribe cuánto quieres recargar"]];
        return;
    }

    self.pidiendoEnlace = YES;
    self.velo.hidden = NO;

    NSDictionary *cuenta = defaults_object(P_USER_DICT_LOGGED);
    if (![cuenta isKindOfClass:[NSDictionary class]]) {
        cuenta = defaults_object(P_USER_DICT);
    }
    NSString *nombre = @"";
    if ([cuenta isKindOfClass:[NSDictionary class]]) {
        id leido = [cuenta objectForKey:@"u_name"] ?: [cuenta objectForKey:@"d_name"];
        nombre = [leido isKindOfClass:[NSString class]] ? (NSString *)leido : @"";
    }

    [RecargaEstilo enviarA:kURLRele
                    campos:@{ @"monto_usd": [NSString stringWithFormat:@"%.2f", usd],
                              @"nombre":    nombre }
                completado:^(NSDictionary *json, NSError *error) {
        self.pidiendoEnlace = NO;
        self.velo.hidden = YES;

        if (error != nil || json == nil) {
            [self avisar:[LanguageHelper getStringWithKey:@"k_s10_recarga_err_red"
                                             defaultValue:@"No pudimos confirmar el resultado con el banco."]];
            return;
        }
        if (![[json objectForKey:@"ok"] boolValue]) {
            NSString *mensaje = [json objectForKey:@"mensaje"];
            [self avisar:([mensaje isKindOfClass:[NSString class]] && mensaje.length > 0)
                          ? mensaje
                          : [LanguageHelper getStringWithKey:@"k_s10_recarga_err_generico"
                                                defaultValue:@"El banco rechazó el pago. Revisa tus datos e intenta de nuevo."]];
            return;
        }
        NSString *destino = [json objectForKey:@"url"];
        if (![destino isKindOfClass:[NSString class]] || destino.length == 0) {
            [self avisar:[LanguageHelper getStringWithKey:@"k_s10_recarga_err_generico"
                                             defaultValue:@"El banco rechazó el pago. Revisa tus datos e intenta de nuevo."]];
            return;
        }
        [self abrirPasarela:destino];
    }];
}

/**
 Safari, no un WebView propio.

 Cuanto menos toque Conrra el formulario de la tarjeta, mejor: en Safari el cliente ve el
 candado y el dominio del banco, y el app no puede leer lo que escribe ni por accidente.
 */
- (void)abrirPasarela:(NSString *)url {
    NSURL *destino = [NSURL URLWithString:url];
    if (destino == nil) {
        [self avisar:[LanguageHelper getStringWithKey:@"k_s10_recarga_err_generico"
                                         defaultValue:@"El banco rechazó el pago. Revisa tus datos e intenta de nuevo."]];
        return;
    }
    self.fueAlBanco = YES;
    [[UIApplication sharedApplication] openURL:destino options:@{} completionHandler:^(BOOL abierto) {
        if (!abierto) {
            self.fueAlBanco = NO;
        }
    }];
}

- (void)avisar:(NSString *)mensaje {
    UIAlertController *dialogo = [UIAlertController
        alertControllerWithTitle:[LanguageHelper getStringWithKey:@"k_s10_recarga_err_titulo"
                                                     defaultValue:@"No se pudo completar"]
                         message:mensaje
                  preferredStyle:UIAlertControllerStyleAlert];
    [dialogo addAction:[UIAlertAction actionWithTitle:[LanguageHelper getStringWithKey:@"k_18_s4_Ok" defaultValue:@"OK"]
                                                 style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:dialogo animated:YES completion:nil];
}

- (void)volver {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
