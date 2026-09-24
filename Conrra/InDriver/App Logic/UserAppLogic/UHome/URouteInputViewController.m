//
//  URouteInputViewController.m
//  Conrra
//
//  Screen 2 — "Ingresa tu Ruta"
//  Fully programmatic. No storyboard/xib. Push from UHomeViewController.
//

#import "URouteInputViewController.h"
#import "SuggestedLocationDataSource.h"
#import "SuggestedLocationCell.h"
#import "ConrraDestinosRecientes.h"
#import "UIViewController+LGSideMenuController.h"
#import "AppDelegate.h"
#import "Utilities.h"
#import "LanguageHelper.h"
#import "UIImageView+WebCache.h"
#import "ConrraMapaSelectorViewController.h"

@interface URouteInputViewController () <SuggestedLocationDataSourceDelegate, ConrraMapaSelectorDelegate, UITableViewDataSource, UITableViewDelegate>
{
    SuggestedLocationDataSource *locationDataSourcePickup;
    SuggestedLocationDataSource *locationDataSourceDrop;
}

@property (strong, nonatomic) UITextField *pickupField;
@property (strong, nonatomic) UITextField *destinationField;
@property (strong, nonatomic) UITableView *pickupTableView;
@property (strong, nonatomic) UITableView *destinationTableView;
@property (strong, nonatomic) UIView      *destContainer; // for border styling
/// Los ultimos destinos, debajo de los campos mientras no haya sugerencias.
@property (strong, nonatomic) UITableView *tablaRecientes;
@property (strong, nonatomic) NSArray<ConrraDestinoReciente *> *recientes;

@end

@implementation URouteInputViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self buildLayout];
    [self setupDataSources];
}

- (void)viewWillAppear:(BOOL)animated {
    [self refrescarRecientes];
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    // Auto-fill pickup from GPS if no address was passed (e.g. after trip cancel)
    if (self.pickupField.text.length == 0) {
        AppDelegate *app = APP_DELEGATE;
        CLLocationCoordinate2D coord = app.currLoc.coordinate;
        if (coord.latitude != 0) {
            [Utilities getAddressStrinByLat:coord.latitude
                                  longitude:coord.longitude
                      withcompletionHandler:^(NSString *address, NSString *shortAddress) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSString *display = address.length > 0 ? address : shortAddress;
                    if (display.length > 0) {
                        self.pickupField.text      = display;
                        self.direction.pickAddress  = display;
                        self.direction.source       = app.currLoc;
                    }
                });
            }];
        }
    }

    [self.destinationField becomeFirstResponder];
}

#pragma mark - Layout

- (void)buildLayout {
    CGFloat sw      = self.view.bounds.size.width;
    CGFloat sh      = self.view.bounds.size.height;
    CGFloat statusH = [self statusBarHeight];
    CGFloat topBarH = 52.0;

    UIView *topBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, sw, statusH + topBarH)];
    topBar.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:topBar];

    // Back button — gray circle with chevron
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    CGFloat btnY = statusH + (topBarH - 44.0) / 2.0;
    backBtn.frame = CGRectMake(16, btnY, 44, 44);
    backBtn.backgroundColor = [UIColor colorWithRed:0.918f green:0.918f blue:0.918f alpha:1.0f];
    backBtn.layer.cornerRadius = 22;
    backBtn.clipsToBounds = YES;
    UIImage *chevron = [UIImage systemImageNamed:@"chevron.left"];
    [backBtn setImage:chevron forState:UIControlStateNormal];
    backBtn.tintColor = [UIColor colorWithRed:0.157f green:0.157f blue:0.157f alpha:1.0f];
    [backBtn addTarget:self action:@selector(backTapped) forControlEvents:UIControlEventTouchUpInside];
    [topBar addSubview:backBtn];

    // Hamburger button — right side, mirrors back button
    UIButton *menuBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    menuBtn.frame = CGRectMake(sw - 16 - 44, btnY, 44, 44);
    menuBtn.backgroundColor = [UIColor colorWithRed:0.918f green:0.918f blue:0.918f alpha:1.0f];
    menuBtn.layer.cornerRadius = 22;
    menuBtn.clipsToBounds = YES;
    UIImage *hamburger = [UIImage systemImageNamed:@"line.3.horizontal"];
    [menuBtn setImage:hamburger forState:UIControlStateNormal];
    menuBtn.tintColor = [UIColor colorWithRed:0.157f green:0.157f blue:0.157f alpha:1.0f];
    [menuBtn addTarget:self action:@selector(menuTapped) forControlEvents:UIControlEventTouchUpInside];
    [topBar addSubview:menuBtn];

    // Title label — centered
    UILabel *titleLbl = [[UILabel alloc] init];
    titleLbl.text = @"Ingresa tu Ruta";
    titleLbl.font = [UIFont fontWithName:@"NotoSans-Bold" size:18]
                    ?: [UIFont boldSystemFontOfSize:18];
    titleLbl.textColor = [UIColor colorWithRed:0.157f green:0.157f blue:0.157f alpha:1.0f];
    [titleLbl sizeToFit];
    CGFloat titleX = (sw - titleLbl.frame.size.width) / 2.0;
    CGFloat titleY = statusH + (topBarH - titleLbl.frame.size.height) / 2.0;
    titleLbl.frame = CGRectMake(titleX, titleY,
                                titleLbl.frame.size.width, titleLbl.frame.size.height);
    [topBar addSubview:titleLbl];

    // Bottom separator on top bar
    UIView *topSep = [[UIView alloc] initWithFrame:CGRectMake(0, statusH + topBarH - 0.5, sw, 0.5)];
    topSep.backgroundColor = [UIColor colorWithRed:0.88f green:0.88f blue:0.88f alpha:1.0f];
    [topBar addSubview:topSep];

    CGFloat currentY = statusH + topBarH + 16.0;

    currentY += [self buildSelectorDeMapaAtY:currentY width:sw] + 16.0;

    CGFloat vehicleRowH = [self buildVehicleCardsAtY:currentY width:sw];
    currentY += vehicleRowH + 16.0;

    // Thin divider below cards
    UIView *divider = [[UIView alloc] initWithFrame:CGRectMake(0, currentY, sw, 0.5)];
    divider.backgroundColor = [UIColor colorWithRed:0.90f green:0.90f blue:0.90f alpha:1.0f];
    [self.view addSubview:divider];
    currentY += 0.5 + 20.0;

    UIView *pickupContainer = [[UIView alloc] initWithFrame:CGRectMake(16, currentY, sw - 32, 52)];
    pickupContainer.backgroundColor = [UIColor colorWithRed:0.949f green:0.949f blue:0.949f alpha:1.0f];
    pickupContainer.layer.cornerRadius = 12;
    pickupContainer.clipsToBounds = YES;
    [self.view addSubview:pickupContainer];

    // Yellow circle with person icon
    UIView *personBg = [[UIView alloc] initWithFrame:CGRectMake(10, 10, 32, 32)];
    personBg.layer.cornerRadius = 16;
    personBg.backgroundColor = [UIColor colorNamed:@"app_theame"]
                                ?: [UIColor colorWithRed:0.922f green:0.710f blue:0.094f alpha:1.0f];
    personBg.clipsToBounds = YES;
    [pickupContainer addSubview:personBg];

    UIImageView *personIcon = [[UIImageView alloc] initWithFrame:CGRectMake(6, 6, 20, 20)];
    personIcon.image = [[UIImage systemImageNamed:@"person.fill"]
                        imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    personIcon.tintColor = [UIColor whiteColor];
    personIcon.contentMode = UIViewContentModeScaleAspectFit;
    [personBg addSubview:personIcon];

    // Pickup text field
    CGFloat fieldX = 52.0;
    // 40 puntos reservados a la derecha para el boton de mapa, que va DENTRO del contenedor
    // y no como rightView del campo: el rightView y el boton de borrar se disputan el mismo
    // hueco y solo se ve uno de los dos.
    CGFloat huecoMapa = 40.0;
    self.pickupField = [[UITextField alloc] initWithFrame:CGRectMake(fieldX, 0, sw - 32 - fieldX - 8 - huecoMapa, 52)];
    self.pickupField.text = self.direction.pickAddress ?: @"";
    self.pickupField.placeholder = [LanguageHelper getStringWithKey:@"k_s10_your_location" defaultValue:@"Tu ubicación"];
    self.pickupField.font = [UIFont fontWithName:@"NotoSans-Regular" size:15]
                            ?: [UIFont systemFontOfSize:15];
    self.pickupField.textColor = [UIColor colorWithRed:0.157f green:0.157f blue:0.157f alpha:1.0f];
    self.pickupField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.pickupField.borderStyle = UITextBorderStyleNone;
    self.pickupField.backgroundColor = [UIColor clearColor];
    self.pickupField.returnKeyType = UIReturnKeySearch;
    [pickupContainer addSubview:self.pickupField];
    [pickupContainer addSubview:[self botonDeMapaEnX:(sw - 32 - huecoMapa)
                                              accion:@selector(irAlMapaDesdeLaRecogida)]];

    currentY += 52.0 + 12.0;

    self.destContainer = [[UIView alloc] initWithFrame:CGRectMake(16, currentY, sw - 32, 52)];
    self.destContainer.backgroundColor = [UIColor whiteColor];
    self.destContainer.layer.cornerRadius = 12;
    self.destContainer.layer.borderWidth = 1.5f;
    self.destContainer.layer.borderColor = [UIColor colorWithRed:0.157f green:0.157f blue:0.157f alpha:1.0f].CGColor;
    self.destContainer.clipsToBounds = YES;
    [self.view addSubview:self.destContainer];

    // Search icon left view
    UIView *iconContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 44, 52)];
    UIImageView *searchIcon = [[UIImageView alloc] initWithFrame:CGRectMake(12, 16, 20, 20)];
    searchIcon.image = [[UIImage systemImageNamed:@"magnifyingglass"]
                        imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    searchIcon.tintColor = [UIColor colorWithRed:0.62f green:0.62f blue:0.62f alpha:1.0f];
    searchIcon.contentMode = UIViewContentModeScaleAspectFit;
    [iconContainer addSubview:searchIcon];

    self.destinationField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, sw - 32 - huecoMapa, 52)];
    self.destinationField.leftView = iconContainer;
    self.destinationField.leftViewMode = UITextFieldViewModeAlways;
    self.destinationField.placeholder = @"Hacia:";
    self.destinationField.font = [UIFont fontWithName:@"NotoSans-Regular" size:15]
                                 ?: [UIFont systemFontOfSize:15];
    self.destinationField.textColor = [UIColor colorWithRed:0.157f green:0.157f blue:0.157f alpha:1.0f];
    self.destinationField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.destinationField.borderStyle = UITextBorderStyleNone;
    self.destinationField.backgroundColor = [UIColor clearColor];
    self.destinationField.returnKeyType = UIReturnKeySearch;
    [self.destContainer addSubview:self.destinationField];
    [self.destContainer addSubview:[self botonDeMapaEnX:(sw - 32 - huecoMapa)
                                                 accion:@selector(irAlMapaDesdeElDestino)]];

    currentY += 52.0 + 8.0;

    CGFloat tableH = sh - currentY;

    self.pickupTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, currentY, sw, tableH)
                                                        style:UITableViewStylePlain];
    self.pickupTableView.hidden = YES;
    self.pickupTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.pickupTableView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.pickupTableView];

    self.destinationTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, currentY, sw, tableH)
                                                             style:UITableViewStylePlain];
    self.destinationTableView.hidden = YES;
    self.destinationTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.destinationTableView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.destinationTableView];

    /*
     Los ultimos destinos van en el MISMO hueco que las sugerencias, no debajo.

     Es un hueco que solo se llena mientras se escribe; el resto del tiempo estaba vacio, y
     es justo donde el pasajero esta mirando cuando entra a poner un destino. Se turnan: si
     hay sugerencias mandan ellas, y si no, los recientes.
     */
    self.tablaRecientes = [[UITableView alloc] initWithFrame:CGRectMake(0, currentY, sw, tableH)
                                                       style:UITableViewStylePlain];
    self.tablaRecientes.hidden = YES;
    self.tablaRecientes.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tablaRecientes.backgroundColor = [UIColor whiteColor];
    self.tablaRecientes.dataSource = self;
    self.tablaRecientes.delegate = self;
    self.tablaRecientes.rowHeight = 56;
    [self.view addSubview:self.tablaRecientes];

    // Register suggestion cell XIB for both tables
    UINib *cellNib = [UINib nibWithNibName:@"SuggestedLocationCell" bundle:nil];
    [self.pickupTableView      registerNib:cellNib forCellReuseIdentifier:@"SuggestedLocationCell"];
    [self.destinationTableView registerNib:cellNib forCellReuseIdentifier:@"SuggestedLocationCell"];
}

/**
 Las categorias, las que mande el servidor.

 Dos cosas estaban mal. Cortaba en DOS (MIN(count, 2)), asi que en Panama, donde el
 backend devuelve Taxi, Envio y Luxor, la tercera no se veia. Y el icono se elegia por
 posicion -- i == 0 ? moto : car --, de modo que la primera categoria salia siempre con
 una moto aunque fuera un taxi.

 Lo que YA estaba bien y se conserva: la comparacion por categoryId con selectedCategory,
 que es lo que marca la que el pasajero eligio en la pantalla anterior.

 Las tarjetas siguen siendo indicativas, sin toque: cambiar aqui la categoria obligaria a
 propagar la eleccion de vuelta al home, y eso es otro asunto.
 */
/**
 El boton de "Seleccionar en el mapa".

 Hay direcciones que no se pueden escribir: un portal sin numero, una entrada de
 servicio, el sitio exacto de un descampado. Android lo resuelve con este mismo boton
 (btnSelectOnMapSearch) y un mapa con el pin fijo en el centro.
 */
- (CGFloat)buildSelectorDeMapaAtY:(CGFloat)y width:(CGFloat)sw {
    CGFloat alto = 56.0;
    UIColor *verde = [UIColor colorWithRed:0.18f green:0.65f blue:0.27f alpha:1.0f];

    UIButton *boton = [UIButton buttonWithType:UIButtonTypeCustom];
    boton.frame = CGRectMake(16, y, sw - 32, alto);
    boton.backgroundColor = [verde colorWithAlphaComponent:0.10f];
    boton.layer.cornerRadius = 14;
    boton.clipsToBounds = YES;
    [boton addTarget:self action:@selector(abrirSelectorDeMapa) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:boton];

    UIImageView *icono = [[UIImageView alloc] initWithFrame:CGRectMake(16, (alto - 24) / 2.0, 24, 24)];
    icono.image = [[UIImage systemImageNamed:@"mappin.and.ellipse"]
                   imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    icono.tintColor = verde;
    icono.contentMode = UIViewContentModeScaleAspectFit;
    [boton addSubview:icono];

    UILabel *texto = [[UILabel alloc] initWithFrame:CGRectMake(52, 0, sw - 32 - 68, alto)];
    texto.text = [LanguageHelper getStringWithKey:@"k_s10_seleccionar_en_el_mapa"
                                     defaultValue:@"Seleccionar en el mapa"];
    texto.font = [UIFont fontWithName:@"NotoSans-Bold" size:16] ?: [UIFont boldSystemFontOfSize:16];
    texto.textColor = verde;
    [boton addSubview:texto];

    return alto;
}

/**
 El boton que lleva al mapa con lo que la caja tenga escrito.

 Va junto al aspa de borrar, no en su lugar: son dos cosas distintas -- una vacia la caja y
 la otra lleva a afinar el punto -- y quitar una para poner la otra obligaria a borrar y
 reescribir para cambiar la esquina.
 */
- (UIButton *)botonDeMapaEnX:(CGFloat)x accion:(SEL)accion {
    UIButton *boton = [UIButton buttonWithType:UIButtonTypeSystem];
    boton.frame = CGRectMake(x, 0, 40, 52);
    // El mismo pin que el boton de "Seleccionar en el mapa" de arriba: los dos llevan al
    // mismo sitio, y con dos iconos distintos pareceria que hacen cosas distintas.
    [boton setImage:[[UIImage systemImageNamed:@"mappin.and.ellipse"]
                     imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
           forState:UIControlStateNormal];
    boton.tintColor = [UIColor colorWithRed:0.18f green:0.65f blue:0.27f alpha:1.0f];
    [boton addTarget:self action:accion forControlEvents:UIControlEventTouchUpInside];
    return boton;
}

- (void)irAlMapaDesdeLaRecogida {
    [self irAlMapaConElTextoDe:self.pickupField modo:ConrraModoSeleccionRecogida];
}

- (void)irAlMapaDesdeElDestino {
    [self irAlMapaConElTextoDe:self.destinationField modo:ConrraModoSeleccionDestino];
}

/**
 Abre el mapa centrado en la direccion escrita en la caja.

 Se geocodifica con CLGeocoder y no con el camino de Google que usan las sugerencias,
 porque aqui NO hay place_id: lo que hay es texto suelto, puede que a medio escribir o
 corregido a mano despues de elegir.

 Si no se puede resolver -- texto vacio, sin red, direccion que no existe -- el mapa se abre
 igual donde este el pasajero. Es mejor que un boton que no responde: desde ahi puede
 arrastrar hasta el sitio, que es justo para lo que sirve esta pantalla.
 */
- (void)irAlMapaConElTextoDe:(UITextField *)campo modo:(ConrraModoSeleccionMapa)modo {
    [self.view endEditing:YES];
    self.pickupTableView.hidden      = YES;
    self.destinationTableView.hidden = YES;

    NSString *texto = [campo.text stringByTrimmingCharactersInSet:
                       [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    CLLocationCoordinate2D respaldo = self.direction.source.coordinate;
    if (respaldo.latitude == 0 && respaldo.longitude == 0) {
        respaldo = [APP_DELEGATE currLoc].coordinate;
    }

    if (texto.length == 0) {
        [self abrirMapaEn:respaldo texto:@"" modo:modo];
        return;
    }

    [UtilityClass setLH:NO wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
    [[[CLGeocoder alloc] init] geocodeAddressString:texto
                                  completionHandler:^(NSArray<CLPlacemark *> *sitios, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
            CLLocation *encontrado = [[sitios firstObject] location];
            [self abrirMapaEn:(encontrado ? encontrado.coordinate : respaldo)
                        texto:texto
                         modo:modo];
        });
    }];
}

/**
 Abre el mapa para elegir el punto.

 El modo sale de que campo se estaba usando: si el pasajero estaba tocando el de
 recogida, el punto es la recogida; si no, el destino. Es la misma regla que Android
 (isPickUpSearching).
 */
- (void)abrirSelectorDeMapa {
    [self.view endEditing:YES];

    ConrraMapaSelectorViewController *vc = [[ConrraMapaSelectorViewController alloc] init];
    vc.delegado = self;
    vc.modo = [self.pickupField isFirstResponder]
        ? ConrraModoSeleccionRecogida
        : ConrraModoSeleccionDestino;
    // Se abre donde ya esta el pasajero. Ojo: direction.source existe como objeto
    // desde el principio, pero vale (0,0) hasta que el GPS responde -- pasarlo asi
    // mandaria el mapa al golfo de Guinea. Si no sirve, el selector se apaña solo.
    CLLocationCoordinate2D origen = self.direction.source.coordinate;
    if (!(origen.latitude == 0 && origen.longitude == 0)) {
        vc.centroInicial = origen;
    }
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - ConrraMapaSelectorDelegate

- (void)selectorDeMapa:(ConrraMapaSelectorViewController *)selector
      eligioCoordenada:(CLLocationCoordinate2D)coordenada
             direccion:(NSString *)direccion
                  modo:(ConrraModoSeleccionMapa)modo {

    if (modo == ConrraModoSeleccionRecogida) {
        self.pickupField.text = direccion;
        if (self.direction) {
            self.direction.pickAddress = direccion;
        }
        if ([self.delegate respondsToSelector:@selector(routeInputVC:eligioRecogidaEn:direccion:)]) {
            [self.delegate routeInputVC:self eligioRecogidaEn:coordenada direccion:direccion];
        }
        /*
         La recogida no cierra la pantalla: todavia falta el destino, y el foco se va solo a
         su caja. Es el paso que encadena los dos puntos sin que el pasajero tenga que
         buscar donde tocar.

         Con retardo: se vuelve de una animacion de navegacion, y pedir el teclado mientras
         la transicion corre lo deja a medias o no lo saca.
         */
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.35 * NSEC_PER_SEC)),
                       dispatch_get_main_queue(), ^{
            [self.destinationField becomeFirstResponder];
        });
        return;
    }

    self.destinationField.text = direccion;
    if ([self.delegate respondsToSelector:@selector(routeInputVC:eligioDestinoEn:direccion:)]) {
        // Igual que con las sugerencias: avisar ANTES de cerrar, para que el home pueda
        // ponerse en modo "vuelvo de la ruta" y no se reinicie al reaparecer.
        [self.delegate routeInputVC:self eligioDestinoEn:coordenada direccion:direccion];
    }
    [self.navigationController popViewControllerAnimated:YES];
}


- (CGFloat)buildVehicleCardsAtY:(CGFloat)y width:(CGFloat)sw {
    NSInteger count = (NSInteger)self.categories.count;
    if (count == 0) return 0;

    CGFloat cardH   = 80.0;
    CGFloat cardW   = 80.0;
    CGFloat spacing = 12.0;
    CGFloat totalW  = count * cardW + (count - 1) * spacing;
    // Con muchas categorias la fila se saldria por los lados: a partir de ahi se pega al
    // margen izquierdo en vez de centrarse fuera de la pantalla.
    CGFloat startX  = (totalW < sw - 32.0) ? (sw - totalW) / 2.0 : 16.0;

    UIColor *selectedBorder = [UIColor colorNamed:@"app_theame"]
                              ?: [UIColor colorWithRed:0.922f green:0.710f blue:0.094f alpha:1.0f];
    UIColor *selectedBg     = [UIColor colorWithRed:1.0f green:0.984f blue:0.918f alpha:1.0f];
    UIColor *normalBorder   = [UIColor colorWithRed:0.878f green:0.878f blue:0.878f alpha:1.0f];

    for (NSInteger i = 0; i < count; i++) {
        CategoryModel *cat = self.categories[i];
        BOOL isSelected = self.selectedCategory
                          && cat.categoryId == self.selectedCategory.categoryId;

        CGFloat cardX = startX + i * (cardW + spacing);
        UIView *card = [[UIView alloc] initWithFrame:CGRectMake(cardX, y, cardW, cardH)];
        card.backgroundColor    = isSelected ? selectedBg : [UIColor whiteColor];
        card.layer.cornerRadius = 12;
        card.layer.borderWidth  = 1.5f;
        card.layer.borderColor  = (isSelected ? selectedBorder : normalBorder).CGColor;
        card.clipsToBounds      = YES;
        [self.view addSubview:card];

        // Si la imagen del servidor no carga, queda el icono del paquete que mas se
        // parezca por el nombre: mejor una silueta generica que un hueco en blanco.
        UIImage *respaldo = [[cat.cat_name lowercaseString] containsString:@"moto"]
            ? [UIImage imageNamed:@"ic_vehicle_moto"]
            : ([UIImage imageNamed:@"ic_vehicle_car"] ?: [UIImage imageNamed:@"map_car_icon"]);
        CGFloat   iconSize  = 48.0;
        UIImageView *iconIV = [[UIImageView alloc] initWithFrame:
            CGRectMake((cardW - iconSize) / 2.0, (cardH - iconSize) / 2.0, iconSize, iconSize)];
        iconIV.contentMode = UIViewContentModeScaleAspectFit;
        [iconIV sd_setImageWithURL:[NSURL URLWithString:isEmpty(cat.cat_image_path)]
                  placeholderImage:respaldo];
        [card addSubview:iconIV];
    }

    return cardH;
}

- (void)setupDataSources {
    locationDataSourcePickup = [[SuggestedLocationDataSource alloc]
        initWithTableView:self.pickupTableView textFiled:self.pickupField];
    locationDataSourcePickup.delegate = self;

    locationDataSourceDrop = [[SuggestedLocationDataSource alloc]
        initWithTableView:self.destinationTableView textFiled:self.destinationField];
    locationDataSourceDrop.delegate = self;
}

#pragma mark - Helpers

- (CGFloat)statusBarHeight {
    if (@available(iOS 13.0, *)) {
        UIWindowScene *scene = (UIWindowScene *)[UIApplication.sharedApplication.connectedScenes anyObject];
        return scene.statusBarManager.statusBarFrame.size.height;
    }
    return UIApplication.sharedApplication.statusBarFrame.size.height;
}

#pragma mark - Actions

- (void)backTapped {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)menuTapped {
    [self.sideMenuController showLeftViewAnimated:YES completionHandler:nil];
}

#pragma mark - Ultimos destinos

/**
 Decide si se enseñan los ultimos destinos.

 LA VERSION ANTERIOR LOS DEJABA TAPANDO LA BUSQUEDA, y era culpa mia. Miraba el `hidden` de
 las tablas de sugerencias para saber si el hueco estaba libre, pero ese `hidden` se apaga
 de forma ASINCRONA: SuggestedLocationDataSource solo enseña su tabla cuando CONTESTA
 Google. Al empezar a escribir, la tabla de sugerencias seguia escondida, asi que esto
 decidia "hueco libre" y sacaba los recientes; cuando llegaba la respuesta de Google, la
 tabla de sugerencias se enseñaba DEBAJO de los recientes y nadie volvia a mirar. Resultado:
 se escribia una direccion nueva y no habia forma de elegirla.

 Ahora la regla no depende de ninguna respuesta de red: los recientes se enseñan cuando NO
 se esta escribiendo. En cuanto el pasajero toca un campo desaparecen, y vuelven si lo
 vacia. Ademas se mandan al fondo, para que ni con un estado raro puedan quedar por encima
 de las sugerencias.
 */
- (void)refrescarRecientes {
    self.recientes = [ConrraDestinosRecientes todos];
    // La regla es el CONTENIDO de la caja de destino, no quien tiene el foco: la pantalla
    // enfoca el destino nada mas abrirse, y atar los recientes al foco los dejaria sin
    // salir nunca, que era justo lo contrario de lo que hacen falta.
    BOOL hayQueBuscar = (self.destinationField.text.length == 0);
    self.tablaRecientes.hidden = !(hayQueBuscar && self.recientes.count > 0);
    // Al fondo SIEMPRE: las tablas de sugerencias ocupan este mismo hueco y son opacas, asi
    // que en cuanto Google conteste tapan los recientes sin que haga falta coordinarlos.
    // Esa coordinacion es justo lo que estaba roto antes.
    [self.view sendSubviewToBack:self.tablaRecientes];
    [self.tablaRecientes reloadData];
}

/** Esconde los recientes ya, sin esperar a nada. */
- (void)esconderRecientes {
    self.tablaRecientes.hidden = YES;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (NSInteger)self.recientes.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 34;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *cabecera = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 34)];
    cabecera.backgroundColor = [UIColor whiteColor];
    UILabel *titulo = [[UILabel alloc] initWithFrame:CGRectMake(16, 8, tableView.bounds.size.width - 32, 20)];
    titulo.text = [LanguageHelper getStringWithKey:@"k_s10_ultimos_destinos"
                                      defaultValue:@"Últimos destinos"];
    titulo.font = [UIFont fontWithName:@"NotoSans-Bold" size:13] ?: [UIFont boldSystemFontOfSize:13];
    titulo.textColor = [UIColor colorWithWhite:0.45f alpha:1.0f];
    [cabecera addSubview:titulo];
    return cabecera;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *reuso = @"ConrraDestinoReciente";
    UITableViewCell *celda = [tableView dequeueReusableCellWithIdentifier:reuso];
    if (celda == nil) {
        celda = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuso];
        celda.selectionStyle = UITableViewCellSelectionStyleDefault;

        UIImageView *reloj = [[UIImageView alloc] initWithFrame:CGRectMake(16, 18, 20, 20)];
        reloj.tag = 801;
        reloj.image = [[UIImage systemImageNamed:@"clock.arrow.circlepath"]
                       imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        reloj.tintColor = [UIColor colorWithWhite:0.45f alpha:1.0f];
        reloj.contentMode = UIViewContentModeScaleAspectFit;
        [celda.contentView addSubview:reloj];

        UILabel *texto = [[UILabel alloc] init];
        texto.tag = 802;
        texto.font = [UIFont fontWithName:@"NotoSans-Regular" size:15] ?: [UIFont systemFontOfSize:15];
        texto.textColor = [UIColor colorWithRed:0.157f green:0.157f blue:0.157f alpha:1.0f];
        texto.numberOfLines = 2;
        [celda.contentView addSubview:texto];

        UIButton *olvidar = [UIButton buttonWithType:UIButtonTypeSystem];
        olvidar.tag = 803;
        [olvidar setImage:[[UIImage systemImageNamed:@"xmark"]
                           imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
                 forState:UIControlStateNormal];
        olvidar.tintColor = [UIColor colorWithWhite:0.6f alpha:1.0f];
        [olvidar addTarget:self action:@selector(olvidarReciente:)
          forControlEvents:UIControlEventTouchUpInside];
        [celda.contentView addSubview:olvidar];
    }

    CGFloat ancho = tableView.bounds.size.width;
    UILabel *texto = (UILabel *)[celda.contentView viewWithTag:802];
    texto.frame = CGRectMake(48, 8, ancho - 48 - 52, 40);
    UIButton *olvidar = (UIButton *)[celda.contentView viewWithTag:803];
    olvidar.frame = CGRectMake(ancho - 48, 16, 32, 24);
    // El indice viaja en el tag del boton: la celda se recicla y guardar el objeto en una
    // propiedad daria la direccion de otra fila.
    olvidar.tag = 803;
    [olvidar setAccessibilityValue:[NSString stringWithFormat:@"%ld", (long)indexPath.row]];

    ConrraDestinoReciente *destino = [self.recientes objectAtIndex:(NSUInteger)indexPath.row];
    texto.text = destino.direccion;
    return celda;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row >= (NSInteger)self.recientes.count) {
        return;
    }
    ConrraDestinoReciente *destino = [self.recientes objectAtIndex:(NSUInteger)indexPath.row];
    CLLocationCoordinate2D punto = CLLocationCoordinate2DMake(destino.lat, destino.lng);

    self.destinationField.text = destino.direccion;
    [self.view endEditing:YES];
    [self esconderRecientes];

    /*
     Un reciente pasa por el mapa igual que una sugerencia.

     Podria ir directo -- ya trae coordenada y no hace falta preguntarle nada a Google --,
     pero entonces habria dos maneras de elegir destino en la MISMA pantalla: una que
     enseña el mapa y otra que no. Y la parada exacta no se hereda de la vez anterior: hoy
     quiero la puerta de atras del mismo edificio al que fui ayer.

     Ademas, sin mapa este camino se saltaria el paso de confirmar, que es donde el pasajero
     comprueba lo que va a pedir.
     */
    [self abrirMapaEn:punto texto:destino.direccion modo:ConrraModoSeleccionDestino];
}

- (void)olvidarReciente:(UIButton *)boton {
    NSInteger fila = [boton.accessibilityValue integerValue];
    if (fila < 0 || fila >= (NSInteger)self.recientes.count) {
        return;
    }
    ConrraDestinoReciente *destino = [self.recientes objectAtIndex:(NSUInteger)fila];
    [ConrraDestinosRecientes olvidarDireccion:destino.direccion];
    [self refrescarRecientes];
}

#pragma mark - SuggestedLocationDataSourceDelegate

/**
 Elegida una sugerencia, se va al mapa a confirmarla.

 ES EL CAMBIO DE METODOLOGIA. Antes, tocar una sugerencia de destino cerraba la pantalla y
 daba el punto por bueno; el de recogida ni siquiera abria nada. Ahora los dos siguen el
 mismo camino: se rellena la caja, se abre el mapa centrado en esa direccion con el pin
 encima, y solo al CONFIRMAR se da el punto por elegido.

 El mapa no sobra aunque la direccion sea correcta: Google devuelve el centro del portal o
 de la manzana, y quien pide un taxi suele querer la esquina, la entrada de atras o el lado
 bueno de una avenida. Esos metros son la diferencia entre que el conductor te encuentre o
 te llame.

 La caja se rellena ANTES de ir al mapa, no al volver: si el geocodificado tarda o falla, el
 pasajero ya ve escrito lo que eligio en vez de una caja que no reacciona.
 */
- (void)source:(SuggestedLocationDataSource *)soure onSelectLocation:(NSDictionary *)dictLocation {
    BOOL esRecogida = (soure == locationDataSourcePickup);
    NSString *direccion = [dictLocation objectForKey:@"description"] ?: @"";
    NSString *placeId   = [dictLocation objectForKey:@"place_id"] ?: @"";

    if (esRecogida) {
        self.pickupField.text = direccion;
        if (self.direction) {
            self.direction.pickAddress = direccion;
        }
    } else {
        self.destinationField.text = direccion;
    }
    [self.view endEditing:YES];
    self.pickupTableView.hidden      = YES;
    self.destinationTableView.hidden = YES;
    [self esconderRecientes];

    if (placeId.length == 0) {
        return;
    }

    [UtilityClass setLH:NO wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
    [Utilities getLocationFromAddressStringPlaceId:placeId
                             withcompletionHandler:^(CLLocationCoordinate2D punto) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
            [self abrirMapaEn:punto
                        texto:direccion
                         modo:(esRecogida ? ConrraModoSeleccionRecogida : ConrraModoSeleccionDestino)];
        });
    }];
}

/**
 Abre el mapa centrado en un punto concreto.

 Si el punto no sirve -- Google no contesto, o devolvio (0,0) -- se abre igual y el selector
 se centra donde este el pasajero. Es peor no abrir nada: quedaria un toque que no hace
 nada y sin explicacion.
 */
- (void)abrirMapaEn:(CLLocationCoordinate2D)punto
              texto:(NSString *)direccion
               modo:(ConrraModoSeleccionMapa)modo {
    ConrraMapaSelectorViewController *vc = [[ConrraMapaSelectorViewController alloc] init];
    vc.delegado = self;
    vc.modo = modo;
    if (!(punto.latitude == 0 && punto.longitude == 0)) {
        vc.centroInicial = punto;
    }
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)onAddressStartEditingsource:(SuggestedLocationDataSource *)soure {
    [self refrescarRecientes];
    /*
     La tabla del campo activo NO se enseña aqui.

     Se hacia, y lo que se enseñaba era una tabla VACIA: blanca, del alto de la pantalla y
     tapando todo lo que hubiera debajo. La enseña sola SuggestedLocationDataSource cuando
     llegan resultados de Google, que es cuando hay algo que enseñar. Asi, con la caja
     vacia, el hueco lo ocupan los ultimos destinos.
     */
    if (soure == locationDataSourcePickup) {
        self.destinationTableView.hidden = YES;
        // Highlight destination border to inactive style while pickup is active
        self.destContainer.layer.borderColor =
            [UIColor colorWithRed:0.878f green:0.878f blue:0.878f alpha:1.0f].CGColor;
    } else {
        self.pickupTableView.hidden      = YES;
        // Active border on destination container
        self.destContainer.layer.borderColor =
            [UIColor colorWithRed:0.157f green:0.157f blue:0.157f alpha:1.0f].CGColor;
    }
}

- (void)onAddressEndEditingsource:(SuggestedLocationDataSource *)soure {
    [self performSelector:@selector(refrescarRecientes) withObject:nil afterDelay:0.05];
    if (soure == locationDataSourcePickup) {
        self.pickupTableView.hidden = YES;
    } else {
        self.destinationTableView.hidden = YES;
        // Reset dest border
        self.destContainer.layer.borderColor =
            [UIColor colorWithRed:0.157f green:0.157f blue:0.157f alpha:1.0f].CGColor;
    }
}

- (void)onAddressShouldClear:(SuggestedLocationDataSource *)soure {
    [self performSelector:@selector(refrescarRecientes) withObject:nil afterDelay:0.05];
    if (soure == locationDataSourcePickup) {
        if (self.direction) self.direction.pickAddress = @"";
        self.pickupTableView.hidden = YES;
    } else {
        self.destinationTableView.hidden = YES;
    }
}

- (void)onAddressEmptyShouldClear:(SuggestedLocationDataSource *)soure {
    [self performSelector:@selector(refrescarRecientes) withObject:nil afterDelay:0.05];
    if (soure == locationDataSourcePickup) {
        self.pickupTableView.hidden = YES;
    } else {
        self.destinationTableView.hidden = YES;
    }
}

@end
