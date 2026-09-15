//
//  RecargasViewController.m
//  Conrra
//

#import "RecargasViewController.h"
#import "RecargaEstilo.h"
#import "RecargaC2PViewController.h"
#import "RecargaBotonViewController.h"
#import "AboutUsViewController.h"
#import "Utilities.h"
#import "CityModel.h"
#import "UserProfile.h"
#import "LanguageHelper.h"
#import "WebCallConstants.h"
// StoryBoardUtiles es Swift: entra por Conrra-Swift.h, que ya trae BaseViewController.h.

@interface RecargasViewController ()
@property (nonatomic, strong) UILabel *lblSaldo;
@property (nonatomic, strong) UILabel *lblTasa;
@end

@implementation RecargasViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [RecargaEstilo fondo];
    [self montarVistas];
    [self mostrarTasa];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    // Al volver de una recarga el saldo pudo cambiar. Es el mismo onResume de Android.
    [self mostrarSaldo];
}

#pragma mark - Montaje

- (void)montarVistas {
    UIView *cabecera = [RecargaEstilo cabeceraEn:self
                                          titulo:[LanguageHelper getStringWithKey:@"k_s10_recarga_titulo"
                                                                     defaultValue:@"Recargar saldo"]
                                          accion:@selector(volver)];

    UILabel *rotuloSaldo = [RecargaEstilo rotulo:[LanguageHelper getStringWithKey:@"k_s10_recarga_saldo"
                                                                    defaultValue:@"Saldo actual"]];
    rotuloSaldo.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:rotuloSaldo];

    self.lblSaldo = [[UILabel alloc] init];
    self.lblSaldo.translatesAutoresizingMaskIntoConstraints = NO;
    self.lblSaldo.font = FONTS_NOTO_BOLD(20) ?: [UIFont boldSystemFontOfSize:20];
    self.lblSaldo.textColor = [RecargaEstilo textoPrincipal];
    self.lblSaldo.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.lblSaldo];

    UILabel *rotuloMetodo = [RecargaEstilo rotulo:[LanguageHelper getStringWithKey:@"k_s10_recarga_como"
                                                                     defaultValue:@"¿Cómo quieres recargar?"]];
    [self.view addSubview:rotuloMetodo];

    UIView *filaC2P = [self filaConIcono:@"iphone"
                                 recurso:nil
                                  titulo:[LanguageHelper getStringWithKey:@"k_s10_recarga_c2p"
                                                            defaultValue:@"Pago móvil C2P"]
                               subtitulo:[LanguageHelper getStringWithKey:@"k_s10_recarga_c2p_sub"
                                                            defaultValue:@"Al instante, desde tu banco"]
                                  accion:@selector(abrirC2P)];

    UIView *filaTarjeta = [self filaConIcono:@"creditcard"
                                     recurso:@"ic_card_p"
                                      titulo:[LanguageHelper getStringWithKey:@"k_s10_recarga_tarjeta"
                                                                defaultValue:@"Tarjeta de crédito o débito"]
                                   subtitulo:[LanguageHelper getStringWithKey:@"k_s10_recarga_tarjeta_sub"
                                                                defaultValue:@"Pago seguro en el portal del banco"]
                                      accion:@selector(abrirTarjeta)];

    UIView *filaTransferencia = [self filaConIcono:@"building.columns"
                                           recurso:@"menu_icon_wallet"
                                            titulo:[LanguageHelper getStringWithKey:@"k_s10_recarga_transf"
                                                                      defaultValue:@"Transferencia bancaria"]
                                         subtitulo:[LanguageHelper getStringWithKey:@"k_s10_recarga_transf_sub"
                                                                      defaultValue:@"Reporta tu pago y lo verificamos"]
                                            accion:@selector(abrirTransferencia)];

    self.lblTasa = [RecargaEstilo ayuda:@""];
    self.lblTasa.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.lblTasa];

    UILayoutGuide *seguro = self.view.safeAreaLayoutGuide;
    CGFloat margen = 24;   // screen_padding_horizontal de Android

    [NSLayoutConstraint activateConstraints:@[
        [rotuloSaldo.topAnchor      constraintEqualToAnchor:cabecera.bottomAnchor constant:24],
        [rotuloSaldo.leadingAnchor  constraintEqualToAnchor:self.view.leadingAnchor constant:margen],
        [rotuloSaldo.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-margen],

        [self.lblSaldo.topAnchor      constraintEqualToAnchor:rotuloSaldo.bottomAnchor constant:2],
        [self.lblSaldo.leadingAnchor  constraintEqualToAnchor:self.view.leadingAnchor constant:margen],
        [self.lblSaldo.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-margen],

        [rotuloMetodo.topAnchor      constraintEqualToAnchor:self.lblSaldo.bottomAnchor constant:24],
        [rotuloMetodo.leadingAnchor  constraintEqualToAnchor:self.view.leadingAnchor constant:margen],
        [rotuloMetodo.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-margen],

        [filaC2P.topAnchor      constraintEqualToAnchor:rotuloMetodo.bottomAnchor constant:12],
        [filaC2P.leadingAnchor  constraintEqualToAnchor:self.view.leadingAnchor constant:margen],
        [filaC2P.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-margen],

        [filaTarjeta.topAnchor      constraintEqualToAnchor:filaC2P.bottomAnchor constant:12],
        [filaTarjeta.leadingAnchor  constraintEqualToAnchor:self.view.leadingAnchor constant:margen],
        [filaTarjeta.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-margen],

        [filaTransferencia.topAnchor      constraintEqualToAnchor:filaTarjeta.bottomAnchor constant:12],
        [filaTransferencia.leadingAnchor  constraintEqualToAnchor:self.view.leadingAnchor constant:margen],
        [filaTransferencia.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-margen],

        [self.lblTasa.bottomAnchor   constraintEqualToAnchor:seguro.bottomAnchor constant:-20],
        [self.lblTasa.leadingAnchor  constraintEqualToAnchor:self.view.leadingAnchor constant:margen],
        [self.lblTasa.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-margen],
    ]];
}

/**
 Una fila del selector: icono amarillo, titulo, subtitulo y flecha.

 El icono se pide primero a SF Symbols y solo se cae al recurso del catalogo si no
 existiera, porque los simbolos del sistema se tiñen y escalan solos con el texto.
 */
- (UIView *)filaConIcono:(NSString *)simbolo
                 recurso:(NSString * _Nullable)recurso
                  titulo:(NSString *)titulo
               subtitulo:(NSString *)subtitulo
                  accion:(SEL)accion {

    UIView *fila = [RecargaEstilo tarjeta];
    [self.view addSubview:fila];

    UIImageView *icono = [[UIImageView alloc] init];
    icono.translatesAutoresizingMaskIntoConstraints = NO;
    icono.contentMode = UIViewContentModeScaleAspectFit;
    UIImage *img = [UIImage systemImageNamed:simbolo];
    if (img == nil && recurso.length > 0) {
        img = [[UIImage imageNamed:recurso] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    icono.image = img;
    icono.tintColor = [RecargaEstilo amarillo];
    [fila addSubview:icono];

    UILabel *lblTitulo = [[UILabel alloc] init];
    lblTitulo.translatesAutoresizingMaskIntoConstraints = NO;
    lblTitulo.text = titulo;
    lblTitulo.font = FONTS_NOTO_BOLD(14) ?: [UIFont boldSystemFontOfSize:14];
    lblTitulo.textColor = [RecargaEstilo textoPrincipal];
    lblTitulo.numberOfLines = 1;
    // El titulo mas largo -- "Tarjeta de crédito o débito" -- se queda al borde en una
    // pantalla de 4,7 pulgadas. Antes de partirlo en dos lineas, que encoja un poco.
    lblTitulo.adjustsFontSizeToFitWidth = YES;
    lblTitulo.minimumScaleFactor = 0.85f;
    [fila addSubview:lblTitulo];

    UILabel *lblSub = [[UILabel alloc] init];
    lblSub.translatesAutoresizingMaskIntoConstraints = NO;
    lblSub.text = subtitulo;
    lblSub.font = FONTS_NOTO_REGULAR(12) ?: [UIFont systemFontOfSize:12];
    lblSub.textColor = [RecargaEstilo textoTerciario];
    lblSub.numberOfLines = 2;
    [fila addSubview:lblSub];

    UIImageView *flecha = [[UIImageView alloc] init];
    flecha.translatesAutoresizingMaskIntoConstraints = NO;
    flecha.contentMode = UIViewContentModeScaleAspectFit;
    flecha.image = [UIImage systemImageNamed:@"chevron.right"]
                   ?: [[UIImage imageNamed:@"right_chevron"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    flecha.tintColor = [RecargaEstilo textoTerciario];
    [fila addSubview:flecha];

    UITapGestureRecognizer *toque = [[UITapGestureRecognizer alloc] initWithTarget:self action:accion];
    [fila addGestureRecognizer:toque];

    [NSLayoutConstraint activateConstraints:@[
        [icono.leadingAnchor constraintEqualToAnchor:fila.leadingAnchor constant:16],
        [icono.centerYAnchor constraintEqualToAnchor:fila.centerYAnchor],
        [icono.widthAnchor   constraintEqualToConstant:24],
        [icono.heightAnchor  constraintEqualToConstant:24],

        [lblTitulo.leadingAnchor  constraintEqualToAnchor:icono.trailingAnchor constant:16],
        [lblTitulo.trailingAnchor constraintEqualToAnchor:flecha.leadingAnchor constant:-12],
        [lblTitulo.topAnchor      constraintEqualToAnchor:fila.topAnchor constant:16],

        [lblSub.leadingAnchor  constraintEqualToAnchor:lblTitulo.leadingAnchor],
        [lblSub.trailingAnchor constraintEqualToAnchor:lblTitulo.trailingAnchor],
        [lblSub.topAnchor      constraintEqualToAnchor:lblTitulo.bottomAnchor constant:2],
        [lblSub.bottomAnchor   constraintEqualToAnchor:fila.bottomAnchor constant:-16],

        [flecha.trailingAnchor constraintEqualToAnchor:fila.trailingAnchor constant:-16],
        [flecha.centerYAnchor  constraintEqualToAnchor:fila.centerYAnchor],
        [flecha.widthAnchor    constraintEqualToConstant:20],
        [flecha.heightAnchor   constraintEqualToConstant:20],
    ]];
    return fila;
}

#pragma mark - Datos

- (void)mostrarSaldo {
    float saldo = [RecargaEstilo saldo];
    CityModel *ciudad = [CityModel getCityByCityId:[UserProfile shared].loggedCityID];
    NSString *conMoneda = [Utilities formatAmountAndCurrency:saldo currency:ciudad.city_cur];
    self.lblSaldo.text = conMoneda.length > 0 ? conMoneda
                                              : [NSString stringWithFormat:@"$%.2f", saldo];
}

- (void)mostrarTasa {
    float tasa = [RecargaEstilo tasa];
    if (tasa > 0) {
        self.lblTasa.text = [NSString stringWithFormat:@"%@ Bs %@ %@",
            [LanguageHelper getStringWithKey:@"k_s10_recarga_tasa_hoy" defaultValue:@"Tasa de hoy:"],
            [RecargaEstilo enFormatoLocal:tasa],
            [LanguageHelper getStringWithKey:@"k_s10_recarga_por_dolar" defaultValue:@"por dólar"]];
    } else {
        self.lblTasa.text = @"";
    }
}

#pragma mark - Acciones

- (void)abrirC2P {
    [self.navigationController pushViewController:[[RecargaC2PViewController alloc] init] animated:YES];
}

/**
 Tarjeta y debito inmediato van al Boton de Pagos Web de Mercantil.

 El cliente teclea la tarjeta en el dominio del banco, asi que el numero y el CVV no pasan
 nunca por Conrra. El resultado tampoco vuelve por el app: lo avisa Mercantil al webhook
 notificacion.php, y por eso al volver aqui solo se refresca el saldo.
 */
- (void)abrirTarjeta {
    [self.navigationController pushViewController:[[RecargaBotonViewController alloc] init] animated:YES];
}

- (void)abrirTransferencia {
    [self abrirWebConMetodo:@"transferencia"];
}

/**
 La pagina de recargas ya existia y era el unico metodo antes de esto. Se le pasa el metodo
 elegido para que abra la pestaña correcta, igual que hace Android.
 */
- (void)abrirWebConMetodo:(NSString *)metodo {
    NSString *base = [Utilities urlDeRecargas];
    NSString *separador = [base containsString:@"?"] ? @"&" : @"?";
    NSString *url = [NSString stringWithFormat:@"%@%@metodo=%@", base, separador, metodo];

    UIViewController *vc = [StoryBoardUtiles viewContollerWithIdentifier:@"AboutUsViewController"
                                                                   name:StoryBoardUtiles.STORYBOARD_USER];
    if ([vc isKindOfClass:[AboutUsViewController class]]) {
        AboutUsViewController *web = (AboutUsViewController *)vc;
        web.isCustomUrl = YES;
        web.customTitle = [LanguageHelper getStringWithKey:@"k_s10_recarga_titulo" defaultValue:@"Recargar saldo"];
        web.customUrl   = url;
        [self.navigationController pushViewController:web animated:YES];
    }
}

- (void)volver {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
