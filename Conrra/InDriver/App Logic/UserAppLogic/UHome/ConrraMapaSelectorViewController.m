//
//  ConrraMapaSelectorViewController.m
//  Conrra
//

#import "ConrraMapaSelectorViewController.h"
#import "Utilities.h"
#import "LanguageHelper.h"
#import "WebCallConstants.h"
#import "AppDelegate.h"

@interface ConrraMapaSelectorViewController () <MKMapViewDelegate>

@property (nonatomic, strong) MKMapView *mapa;
@property (nonatomic, strong) UIImageView *pin;
@property (nonatomic, strong) UILabel *lblTitulo;
@property (nonatomic, strong) UILabel *lblDireccion;
@property (nonatomic, strong) UIButton *btnConfirmar;
@property (nonatomic, strong) UIActivityIndicatorView *cargando;

/// Lo ultimo que se resolvio. Sin esto no se deja confirmar.
@property (nonatomic, copy) NSString *direccionActual;
@property (nonatomic, assign) BOOL primeraRegion;
/// Para no volver a centrar cada vez que el GPS se afina.
@property (nonatomic, assign) BOOL yaCentrado;

@end


@implementation ConrraMapaSelectorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.primeraRegion = YES;
    [self montarVistas];
    [self centrar];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

#pragma mark - Montaje

- (void)montarVistas {
    CGFloat sw = self.view.bounds.size.width;
    CGFloat sh = self.view.bounds.size.height;

    // El mapa ocupa toda la pantalla; lo demas flota encima.
    self.mapa = [[MKMapView alloc] initWithFrame:self.view.bounds];
    self.mapa.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.mapa.delegate = self;
    self.mapa.showsUserLocation = YES;
    // Con detalle, como el resto de los mapas: aqui el pasajero esta buscando una esquina
    // concreta y necesita los comercios y las plazas para reconocerla.
    self.mapa.mapType = MKMapTypeStandard;
    if (@available(iOS 13.0, *)) {
        self.mapa.pointOfInterestFilter = nil;
    }
    [self.view addSubview:self.mapa];

    CGFloat safeTop = self.view.safeAreaInsets.top;
    if (safeTop <= 0) { safeTop = 44; }

    // --- Tarjeta de arriba: volver, titulo y direccion resuelta ---
    CGFloat altoTarjeta = 92;
    UIView *tarjeta = [[UIView alloc] initWithFrame:CGRectMake(12, safeTop + 8, sw - 24, altoTarjeta)];
    tarjeta.backgroundColor = [UIColor colorNamed:@"color_app_box_bg"] ?: [UIColor whiteColor];
    tarjeta.layer.cornerRadius = 16;
    tarjeta.layer.shadowColor = [UIColor blackColor].CGColor;
    tarjeta.layer.shadowOpacity = 0.12f;
    tarjeta.layer.shadowRadius = 8;
    tarjeta.layer.shadowOffset = CGSizeMake(0, 2);
    [self.view addSubview:tarjeta];

    UIButton *atras = [UIButton buttonWithType:UIButtonTypeSystem];
    atras.frame = CGRectMake(4, 6, 40, 40);
    [atras setImage:[UIImage systemImageNamed:@"chevron.left"] forState:UIControlStateNormal];
    atras.tintColor = [UIColor colorNamed:@"color_app_label"] ?: [UIColor blackColor];
    [atras addTarget:self action:@selector(volver) forControlEvents:UIControlEventTouchUpInside];
    [tarjeta addSubview:atras];

    self.lblTitulo = [[UILabel alloc] initWithFrame:CGRectMake(48, 10, tarjeta.frame.size.width - 60, 22)];
    self.lblTitulo.font = FONTS_NOTO_BOLD(16);
    self.lblTitulo.textColor = [UIColor colorNamed:@"color_app_label"] ?: [UIColor blackColor];
    self.lblTitulo.text = (self.modo == ConrraModoSeleccionRecogida)
        ? [LanguageHelper getStringWithKey:@"k_s10_elige_recogida" defaultValue:@"Elige el punto de recogida"]
        : [LanguageHelper getStringWithKey:@"k_s10_elige_destino" defaultValue:@"Elige el destino"];
    [tarjeta addSubview:self.lblTitulo];

    self.lblDireccion = [[UILabel alloc] initWithFrame:CGRectMake(16, 36, tarjeta.frame.size.width - 32, 46)];
    self.lblDireccion.font = FONTS_NOTO_REGULAR(13);
    self.lblDireccion.textColor = [UIColor colorWithWhite:0.45 alpha:1];
    self.lblDireccion.numberOfLines = 2;
    self.lblDireccion.text = [LanguageHelper getStringWithKey:@"k_s10_arrastra_el_mapa"
                                                 defaultValue:@"Arrastra el mapa para mover el punto"];
    [tarjeta addSubview:self.lblDireccion];

    self.cargando = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
    self.cargando.frame = CGRectMake(tarjeta.frame.size.width - 40, 40, 20, 20);
    self.cargando.hidesWhenStopped = YES;
    [tarjeta addSubview:self.cargando];

    /*
     El pin, clavado en el centro de la pantalla.

     Antes usaba map_pin_drop, que no es un pin: es ic_dropoff, un icono cuadrado de 112x112
     que al encajarlo en un hueco de 40x48 quedaba como un circulito diminuto. Ahora usa
     pin-red, que si es la gota roja de toda la vida, y el hueco respeta su proporcion
     (28x37 -> 3 a 4) para que no salga aplastada.
     */
    UIImage *imgPin = [UIImage imageNamed:@"pin-red"]
        ?: ([UIImage imageNamed:@"ic_location_pin"] ?: [UIImage imageNamed:@"PIN"]);
    self.pin = [[UIImageView alloc] initWithImage:imgPin];
    self.pin.contentMode = UIViewContentModeScaleAspectFit;
    // Una sombra suave lo despega del mapa: un pin plano sobre una calle clara se pierde.
    self.pin.layer.shadowColor = [UIColor blackColor].CGColor;
    self.pin.layer.shadowOpacity = 0.35f;
    self.pin.layer.shadowRadius = 3;
    self.pin.layer.shadowOffset = CGSizeMake(0, 2);
    // La punta del pin es la que marca el sitio, asi que el centro de la imagen va medio
    // alto por encima del centro del mapa.
    // 36 x 48 es la proporcion del PNG. La PUNTA queda en el centro exacto de la pantalla,
    // que es el punto que se va a devolver: centrar la imagen entera dejaria el sitio
    // marcado medio pin mas abajo de donde el pasajero cree.
    self.pin.frame = CGRectMake((sw - 36) / 2.0, sh / 2.0 - 48, 36, 48);
    self.pin.userInteractionEnabled = NO;
    [self.view addSubview:self.pin];

    // --- Confirmar ---
    CGFloat safeBottom = self.view.safeAreaInsets.bottom;
    self.btnConfirmar = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btnConfirmar.frame = CGRectMake(16, sh - safeBottom - 72, sw - 32, 56);
    self.btnConfirmar.backgroundColor = [UIColor colorNamed:@"app_theame"]
        ?: [UIColor colorWithRed:235/255.0 green:181/255.0 blue:24/255.0 alpha:1];
    self.btnConfirmar.layer.cornerRadius = 16;
    self.btnConfirmar.titleLabel.font = FONTS_NOTO_BOLD(17);
    [self.btnConfirmar setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.btnConfirmar setTitle:[LanguageHelper getStringWithKey:@"k_s10_confirmar_punto"
                                                    defaultValue:@"Confirmar"]
                       forState:UIControlStateNormal];
    [self.btnConfirmar addTarget:self action:@selector(confirmar) forControlEvents:UIControlEventTouchUpInside];
    self.btnConfirmar.enabled = NO;
    self.btnConfirmar.alpha = 0.5f;
    [self.view addSubview:self.btnConfirmar];
}

/**
 Donde se abre el mapa.

 Tres niveles, y hacen falta los tres. El punto que venga de la pantalla anterior es el
 mejor, pero puede no haberlo: direction.source vale (0,0) hasta que el GPS responde.
 La ubicacion que el AppDelegate ya tiene guardada suele estar lista antes que la del
 propio MKMapView, que tarda un momento en arrancar la suya. Y si tampoco hay, se espera
 a que llegue -- ver mapView:didUpdateUserLocation:.

 Sin esto el mapa abria en la vista del mundo o en la ultima region que le quedara, y
 habia que arrastrar medio planeta para llegar a donde esta el pasajero.
 */
- (void)centrar {
    CLLocationCoordinate2D centro = self.centroInicial;

    if (![self esValida:centro]) {
        CLLocation *delDelegado = [APP_DELEGATE currLoc];
        if (delDelegado) {
            centro = delDelegado.coordinate;
        }
    }
    if (![self esValida:centro]) {
        centro = self.mapa.userLocation.coordinate;
    }
    if (![self esValida:centro]) {
        // Todavia no se sabe donde esta: se centrara solo cuando el mapa lo averigue.
        return;
    }

    [self centrarEn:centro];
}

- (void)centrarEn:(CLLocationCoordinate2D)centro {
    self.yaCentrado = YES;
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(centro, 800, 800);
    [self.mapa setRegion:region animated:NO];
}

/** (0,0) es lo que la app usa como "sin ubicacion", no un punto del golfo de Guinea. */
- (BOOL)esValida:(CLLocationCoordinate2D)c {
    return !(c.latitude == 0 && c.longitude == 0) && CLLocationCoordinate2DIsValid(c);
}

/**
 La ubicacion llego tarde: se centra una sola vez.

 Si se centrara en cada aviso, el mapa daria un salto cada vez que el GPS se afina y le
 arrancaria de las manos el punto que el pasajero estaba eligiendo.
 */
- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    if (self.yaCentrado) {
        return;
    }
    if ([self esValida:userLocation.coordinate]) {
        [self centrarEn:userLocation.coordinate];
        [self resolverDireccion];
    }
}

#pragma mark - Mapa

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    // Solo al soltar: geocodificar en cada fotograma del arrastre es una llamada por
    // fotograma y un contador de cuota que sube sin que nadie lea el resultado.
    [self resolverDireccion];
}

- (void)resolverDireccion {
    CLLocationCoordinate2D c = self.mapa.centerCoordinate;
    if (c.latitude == 0 && c.longitude == 0) {
        return;
    }
    [self.cargando startAnimating];
    self.btnConfirmar.enabled = NO;
    self.btnConfirmar.alpha = 0.5f;

    __weak typeof(self) debil = self;
    [Utilities getAddressStrinByLat:(float)c.latitude
                          longitude:(float)c.longitude
              withcompletionHandler:^(NSString *locAddress, NSString *country) {
        __strong typeof(debil) fuerte = debil;
        if (fuerte == nil) {
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [fuerte.cargando stopAnimating];
            // Si el mapa siguio moviendose mientras llegaba la respuesta, esta ya no
            // corresponde al centro: la siguiente parada la pedira de nuevo.
            if (locAddress.length == 0) {
                fuerte.lblDireccion.text = [LanguageHelper getStringWithKey:@"k_s10_sin_direccion"
                                                              defaultValue:@"No se pudo leer la dirección de este punto"];
                return;
            }
            fuerte.direccionActual = locAddress;
            fuerte.lblDireccion.text = locAddress;
            fuerte.btnConfirmar.enabled = YES;
            fuerte.btnConfirmar.alpha = 1.0f;
        });
    }];
}

#pragma mark - Acciones

- (void)confirmar {
    if (self.direccionActual.length == 0) {
        return;
    }
    CLLocationCoordinate2D c = self.mapa.centerCoordinate;
    NSString *direccion = self.direccionActual;
    ConrraModoSeleccionMapa modo = self.modo;
    id<ConrraMapaSelectorDelegate> delegado = self.delegado;

    // Se cierra primero y se avisa despues, para que quien reciba el punto pueda empujar
    // o cerrar pantallas sin pelearse con la animacion de esta.
    [self.navigationController popViewControllerAnimated:YES];
    [delegado selectorDeMapa:self eligioCoordenada:c direccion:direccion modo:modo];
}

- (void)volver {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
