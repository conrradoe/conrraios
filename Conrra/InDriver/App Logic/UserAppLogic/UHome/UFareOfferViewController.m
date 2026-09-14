//
//  UFareOfferViewController.m
//  Conrra
//
//  Screen 3 — "Tarifa recomendada"
//  Fully programmatic. Transparent full-screen background so Screen 1's live map
//  (with drawn route, pins, and radar) shows through the top portion.
//

#import "UFareOfferViewController.h"
#import "CategoryModel.h"
#import "EstimatedFare.h"
#import "ConstantModel.h"
#import "UIImageView+WebCache.h"
#import "WebCallConstants.h"
#import "LanguageHelper.h"

static const CGFloat kRowH          = 76.0f; // height of each config toggle row

/**
 La regla de los pasajeros, la misma que Android (updatePassengerLogic).

 Caben cinco en un coche y uno en una moto, y a partir del cuarto se cobra un
 suplemento por cabeza. El tope de la moto no es una tarifa: es que no caben.
 */
static const NSInteger kPasajerosTopeCoche   = 5;
static const NSInteger kPasajerosTopeMoto    = 1;
static const NSInteger kPasajerosSinRecargo  = 3;
static const float     kRecargoPorPasajero   = 0.75f;
static const CGFloat kConfigContentH = 231.0f; // 1(top-sep) + 3×76 + 2×1(seps)

/// Full-screen root view that passes touch events through the transparent map area.
@interface UFareRootView : UIView
@property (assign, nonatomic) CGFloat sheetStartY;
@end
@implementation UFareRootView
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if (point.y < self.sheetStartY) return nil;
    return [super hitTest:point withEvent:event];
}
@end

@interface UFareOfferViewController ()
{
    float _currentAmount;
    BOOL  _configExpanded;
    BOOL  _didBuildLayout;
    /// La fila de la cabecera: boton de volver, titulo y chip de categoria.
    CGRect _filaDeCabecera;
    NSInteger _numPasajeros;
    /// Lo que los pasajeros de mas han añadido a _currentAmount.
    float _recargoPasajeros;
    /**
     El codigo que se acaba de mandar, para poder avisar si el servidor lo rechaza.

     Hace falta porque la estimacion no contesta "codigo invalido": responde sin
     promo_code, igual que cuando no se pidio ninguno. Sin recordar que hubo un
     intento, un codigo equivocado se quedaria callado y el pasajero creeria que se
     aplico. Es la misma razon por la que Android guarda cuponIntentado.
     */
    NSString *_cuponIntentado;
}

// Fare stepper
@property (strong, nonatomic) UILabel     *amountLabel;
// Payment row
@property (strong, nonatomic) UILabel     *paymentRowLabel;
@property (strong, nonatomic) UIImageView *paymentIconView;
// Scroll infrastructure
@property (strong, nonatomic) UIScrollView *sheetScroll;
@property (strong, nonatomic) UIView       *contentCV;
// Accordion
@property (strong, nonatomic) UIView       *configContainer;
@property (strong, nonatomic) UIView       *configContentView;
@property (strong, nonatomic) UIImageView  *configChevron;
// Sheet panels (kept for expand/collapse animation)
@property (strong, nonatomic) UIView       *sheetPanel;
@property (strong, nonatomic) UIView       *shadowPanel;
// Views below accordion that must shift on expand/collapse
@property (strong, nonatomic) UIView       *payRow;
@property (strong, nonatomic) UIButton     *pedirBtn;
// Cupon: una sola fila con tres caras, y solo una visible a la vez
@property (strong, nonatomic) UIView       *filaCupon;
@property (strong, nonatomic) UIView       *caraPedirCupon;
@property (strong, nonatomic) UIView       *caraEscribirCupon;
@property (strong, nonatomic) UITextField  *txtCupon;
@property (strong, nonatomic) UIView       *caraCuponAplicado;
@property (strong, nonatomic) UILabel      *lblCuponAplicado;
// Elige tu viaje
@property (strong, nonatomic) UILabel *lblMontoLocal;
// Chip de la categoria elegida, arriba a la derecha de la tarjeta
@property (strong, nonatomic) UILabel *lblChipCategoria;
@property (strong, nonatomic) UIImageView *imgChipCategoria;
/// El titulo de la tarjeta. Se guarda porque comparte fila con el chip y hay que
/// recolocar los dos juntos cuando el chip cambia de ancho.
@property (strong, nonatomic) UILabel *lblTituloTarifa;
@property (strong, nonatomic) NSMutableArray<UIView *> *filasCategoria;
/// Las etiquetas de precio, en el mismo orden que filasCategoria.
@property (strong, nonatomic) NSMutableArray<UILabel *> *preciosCategoria;
// Config toggle switches
@property (strong, nonatomic) UISwitch     *switchPets;
@property (strong, nonatomic) UISwitch     *switchDelivery;
// Contador de pasajeros
@property (strong, nonatomic) UILabel  *lblNumPasajeros;
/// El subtitulo de la fila: cuenta el tope o el recargo, segun toque.
@property (strong, nonatomic) UILabel  *lblDesglosePasajeros;
@property (strong, nonatomic) UIButton *btnMasPasajeros;
@property (strong, nonatomic) UIButton *btnMenosPasajeros;

@end

@implementation UFareOfferViewController

@synthesize currentAmount = _currentAmount;

#pragma mark - Config toggle accessors

- (BOOL)configPetsAllowed     { return self.switchPets.isOn; }
- (BOOL)configIsDelivery      { return self.switchDelivery.isOn; }
- (NSInteger)numeroDePasajeros { return _numPasajeros > 0 ? _numPasajeros : 1; }
- (float)recargoPorPasajeros   { return _recargoPasajeros; }

#pragma mark - Lifecycle

- (void)loadView {
    UFareRootView *root = [[UFareRootView alloc] init];
    root.backgroundColor = [UIColor clearColor];
    self.view = root;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _currentAmount = (self.recommendedFare > 0) ? self.recommendedFare : 0.0f;
    _numPasajeros  = 1;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if (!_didBuildLayout && self.view.bounds.size.width > 0) {
        _didBuildLayout = YES;
        [self buildLayout];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

#pragma mark - Layout

- (void)buildLayout {
    CGFloat sw = self.view.bounds.size.width;
    CGFloat sh = self.view.bounds.size.height;

    CGFloat sheetStartY = sh * 0.42;
    ((UFareRootView *)self.view).sheetStartY = sheetStartY;
    CGFloat sheetH = sh - sheetStartY;

    // Shared colors
    UIColor *darkText   = [UIColor colorWithRed:0.157f green:0.157f blue:0.157f alpha:1.0f];
    UIColor *grayText   = [UIColor colorWithRed:0.5f   green:0.5f   blue:0.5f   alpha:1.0f];
    UIColor *lightGray  = [UIColor colorWithRed:0.918f green:0.918f blue:0.918f alpha:1.0f];
    UIColor *borderClr  = [UIColor colorWithRed:0.878f green:0.878f blue:0.878f alpha:1.0f];

    // Shadow carrier (behind sheet, not clipped)
    UIView *shadowView = [[UIView alloc] initWithFrame:CGRectMake(0, sheetStartY, sw, sheetH)];
    shadowView.backgroundColor    = [UIColor whiteColor];
    shadowView.layer.cornerRadius = 20;
    shadowView.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
    shadowView.layer.shadowColor   = [UIColor blackColor].CGColor;
    shadowView.layer.shadowOpacity = 0.10f;
    shadowView.layer.shadowRadius  = 14.0f;
    shadowView.layer.shadowOffset  = CGSizeMake(0, -3);
    [self.view addSubview:shadowView];
    self.shadowPanel = shadowView;

    // Sheet (clips rounded corners)
    UIView *sheet = [[UIView alloc] initWithFrame:CGRectMake(0, sheetStartY, sw, sheetH)];
    sheet.backgroundColor     = [UIColor whiteColor];
    sheet.layer.cornerRadius  = 20;
    sheet.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
    sheet.clipsToBounds       = YES;
    [self.view addSubview:sheet];
    self.sheetPanel = sheet;

    // Scroll view fills the sheet so accordion can overflow
    UIScrollView *scroll = [[UIScrollView alloc] initWithFrame:sheet.bounds];
    scroll.showsVerticalScrollIndicator = NO;
    scroll.alwaysBounceVertical         = NO;
    [sheet addSubview:scroll];
    self.sheetScroll = scroll;

    // Content view inside scroll
    UIView *cv = [[UIView alloc] initWithFrame:CGRectMake(0, 0, sw, 0)];
    [scroll addSubview:cv];
    self.contentCV = cv;

    CGFloat y = 10.0;

    UIView *handle = [[UIView alloc] initWithFrame:CGRectMake((sw - 36) / 2.0, y, 36, 4)];
    handle.backgroundColor    = borderClr;
    handle.layer.cornerRadius = 2;
    [cv addSubview:handle];
    y += 4 + 16;

    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    backBtn.frame              = CGRectMake(16, y, 44, 44);
    backBtn.backgroundColor    = lightGray;
    backBtn.layer.cornerRadius = 22;
    backBtn.clipsToBounds      = YES;
    UIImage *chevronLeft = [[UIImage systemImageNamed:@"chevron.left"]
                             imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [backBtn setImage:chevronLeft forState:UIControlStateNormal];
    backBtn.tintColor = darkText;
    [backBtn addTarget:self action:@selector(backTapped) forControlEvents:UIControlEventTouchUpInside];
    [cv addSubview:backBtn];

    UILabel *titleLbl = [[UILabel alloc] init];
    titleLbl.text      = @"Tarifa recomendada";
    titleLbl.font      = [UIFont fontWithName:@"NotoSans-Bold" size:18] ?: [UIFont boldSystemFontOfSize:18];
    titleLbl.textColor = darkText;
    titleLbl.textAlignment = NSTextAlignmentCenter;
    titleLbl.adjustsFontSizeToFitWidth = YES;
    titleLbl.minimumScaleFactor = 0.72f;
    [cv addSubview:titleLbl];
    self.lblTituloTarifa = titleLbl;

    // La cabecera entera se coloca de una vez: el titulo va centrado en lo que dejan
    // el boton de volver y el chip, y el chip cambia de ancho con el nombre de la
    // categoria. Repartirlo aqui a ojo se rompia en cuanto el nombre era largo.
    _filaDeCabecera = CGRectMake(0, y, sw, 44);
    [self montarChipDeCategoriaEnVista:cv];
    [self reacomodarCabecera];
    y += 44 + 20;

    CGFloat cardW = sw - 32;
    UIView *fareCard = [[UIView alloc] initWithFrame:CGRectMake(16, y, cardW, 80)];
    fareCard.backgroundColor    = [UIColor colorWithRed:0.949f green:0.949f blue:0.949f alpha:1.0f];
    fareCard.layer.cornerRadius = 16;
    fareCard.clipsToBounds      = YES;
    [cv addSubview:fareCard];

    UIButton *minusBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    minusBtn.frame              = CGRectMake(12, 18, 44, 44);
    minusBtn.backgroundColor    = [UIColor whiteColor];
    minusBtn.layer.cornerRadius = 22;
    minusBtn.clipsToBounds      = YES;
    [minusBtn setTitle:@"−" forState:UIControlStateNormal];
    [minusBtn setTitleColor:darkText forState:UIControlStateNormal];
    minusBtn.titleLabel.font = [UIFont systemFontOfSize:24 weight:UIFontWeightMedium];
    [minusBtn addTarget:self action:@selector(minusTapped) forControlEvents:UIControlEventTouchUpInside];
    [fareCard addSubview:minusBtn];

    self.amountLabel = [[UILabel alloc] initWithFrame:CGRectMake(64, 0, cardW - 128, 80)];
    self.amountLabel.text          = [self formattedAmount:_currentAmount];
    self.amountLabel.font          = [UIFont fontWithName:@"NotoSans-Bold" size:26] ?: [UIFont boldSystemFontOfSize:26];
    self.amountLabel.textColor     = darkText;
    self.amountLabel.textAlignment = NSTextAlignmentCenter;
    self.amountLabel.adjustsFontSizeToFitWidth = YES;
    [fareCard addSubview:self.amountLabel];

    UIButton *plusBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    plusBtn.frame              = CGRectMake(cardW - 56, 18, 44, 44);
    plusBtn.backgroundColor    = [UIColor whiteColor];
    plusBtn.layer.cornerRadius = 22;
    plusBtn.clipsToBounds      = YES;
    [plusBtn setTitle:@"+" forState:UIControlStateNormal];
    [plusBtn setTitleColor:darkText forState:UIControlStateNormal];
    plusBtn.titleLabel.font = [UIFont systemFontOfSize:24 weight:UIFontWeightMedium];
    [plusBtn addTarget:self action:@selector(plusTapped) forControlEvents:UIControlEventTouchUpInside];
    [fareCard addSubview:plusBtn];

    y += 80 + 10;

    // El importe en moneda local, debajo del precio.
    //
    // Aqui habia dos pistas fijas: "Precio recomendado" y "Conversión a USD". La segunda
    // ademas mentia -- el precio YA esta en dolares, no hay nada que convertir a USD.
    // Android enseña lo que de verdad hace falta: cuantos bolivares son.
    self.lblMontoLocal = [[UILabel alloc] initWithFrame:CGRectMake(16, y, sw - 32, 22)];
    self.lblMontoLocal.font = [UIFont fontWithName:@"NotoSans-Regular" size:14] ?: [UIFont systemFontOfSize:14];
    self.lblMontoLocal.textColor = grayText;
    self.lblMontoLocal.textAlignment = NSTextAlignmentCenter;
    [cv addSubview:self.lblMontoLocal];
    [self actualizarMontoLocal];
    y += 22 + 14;

    y += [self montarEligeTuViajeEnVista:cv y:y ancho:sw] ;

    UIView *configContainer = [[UIView alloc] initWithFrame:CGRectMake(16, y, sw - 32, 52)];
    configContainer.layer.borderWidth  = 1.0f;
    configContainer.layer.borderColor  = borderClr.CGColor;
    configContainer.layer.cornerRadius = 12;
    configContainer.clipsToBounds      = YES;
    [cv addSubview:configContainer];
    self.configContainer = configContainer;

    // Header inside container
    UILabel *configLbl = [[UILabel alloc] initWithFrame:CGRectMake(16, 0, sw - 32 - 52, 52)];
    // Android lo llama "Detalles de viaje"; aqui ponia "Configuración".
    configLbl.text      = [LanguageHelper getStringWithKey:@"k_s10_trip_details" defaultValue:@"Detalles de viaje"];
    configLbl.font      = [UIFont fontWithName:@"NotoSans-Regular" size:16] ?: [UIFont systemFontOfSize:16];
    configLbl.textColor = darkText;
    [configContainer addSubview:configLbl];

    UIImageView *chevron = [[UIImageView alloc] initWithFrame:CGRectMake(sw - 32 - 36, 15, 22, 22)];
    chevron.image       = [[UIImage systemImageNamed:@"chevron.down"]
                            imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    chevron.tintColor   = grayText;
    chevron.contentMode = UIViewContentModeScaleAspectFit;
    [configContainer addSubview:chevron];
    self.configChevron = chevron;

    // Tap overlay
    UIButton *configTap = [UIButton buttonWithType:UIButtonTypeCustom];
    configTap.frame           = CGRectMake(0, 0, sw - 32, 52);
    configTap.backgroundColor = [UIColor clearColor];
    [configTap addTarget:self action:@selector(configTapped) forControlEvents:UIControlEventTouchUpInside];
    [configContainer addSubview:configTap];

    // Expandable content area (starts at height 0, clipped)
    UIView *configContent = [[UIView alloc] initWithFrame:CGRectMake(0, 52, sw - 32, 0)];
    configContent.clipsToBounds = YES;
    [configContainer addSubview:configContent];
    self.configContentView = configContent;

    // Pre-build toggle rows inside the content area
    [self buildConfigContent:configContent width:sw - 32
                    darkText:darkText grayText:grayText borderColor:borderClr];

    y += 52 + 12;

    y += [self montarFilaDeCuponEnVista:cv y:y ancho:sw];

    UIView *payRow = [[UIView alloc] initWithFrame:CGRectMake(16, y, sw - 32, 60)];
    payRow.layer.borderWidth  = 1.0f;
    payRow.layer.borderColor  = borderClr.CGColor;
    payRow.layer.cornerRadius = 12;
    payRow.clipsToBounds      = YES;
    [cv addSubview:payRow];
    self.payRow = payRow;

    self.paymentIconView = [[UIImageView alloc] initWithFrame:CGRectMake(16, 18, 24, 24)];
    UIImage *payImg = self.paymentIcon
                      ?: [[UIImage systemImageNamed:@"banknote.fill"]
                           imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.paymentIconView.image       = [payImg imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.paymentIconView.tintColor   = [UIColor colorWithRed:0.18f green:0.65f blue:0.32f alpha:1.0f];
    self.paymentIconView.contentMode = UIViewContentModeScaleAspectFit;
    [payRow addSubview:self.paymentIconView];

    self.paymentRowLabel = [[UILabel alloc] initWithFrame:CGRectMake(52, 0, sw - 32 - 52 - 96, 60)];
    self.paymentRowLabel.text      = [NSString stringWithFormat:[LanguageHelper getStringWithKey:@"k_s10_pay_with_format" defaultValue:@"Paga con %@"],
                                       self.paymentLabel.length > 0 ? self.paymentLabel : [LanguageHelper getStringWithKey:@"k_r39_s9_cash" defaultValue:@"Efectivo"]];
    self.paymentRowLabel.font      = [UIFont fontWithName:@"NotoSans-Regular" size:15] ?: [UIFont systemFontOfSize:15];
    self.paymentRowLabel.textColor = darkText;
    [payRow addSubview:self.paymentRowLabel];

    UIView *badge = [[UIView alloc] initWithFrame:CGRectMake(sw - 32 - 86, 18, 66, 24)];
    badge.backgroundColor    = lightGray;
    badge.layer.cornerRadius = 5;
    badge.clipsToBounds      = YES;
    UILabel *badgeLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 66, 24)];
    badgeLbl.text          = [LanguageHelper getStringWithKey:@"k_s10_default" defaultValue:@"Default"];
    badgeLbl.font          = [UIFont systemFontOfSize:11];
    badgeLbl.textColor     = [UIColor colorWithRed:0.4f green:0.4f blue:0.4f alpha:1.0f];
    badgeLbl.textAlignment = NSTextAlignmentCenter;
    [badge addSubview:badgeLbl];
    [payRow addSubview:badge];

    UIImageView *payChevron = [[UIImageView alloc] initWithFrame:CGRectMake(sw - 32 - 18, 18, 12, 22)];
    payChevron.image       = [[UIImage systemImageNamed:@"chevron.right"]
                               imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    payChevron.tintColor   = grayText;
    payChevron.contentMode = UIViewContentModeScaleAspectFit;
    [payRow addSubview:payChevron];

    UIButton *payTap = [UIButton buttonWithType:UIButtonTypeCustom];
    payTap.frame           = CGRectMake(0, 0, sw - 32, 60);
    payTap.backgroundColor = [UIColor clearColor];
    [payTap addTarget:self action:@selector(paymentTapped) forControlEvents:UIControlEventTouchUpInside];
    [payRow addSubview:payTap];

    y += 60 + 16;

    UIButton *pedirBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    pedirBtn.frame              = CGRectMake(16, y, sw - 32, 56);
    pedirBtn.backgroundColor    = [UIColor colorNamed:@"app_theame"]
                                  ?: [UIColor colorWithRed:0.922f green:0.710f blue:0.094f alpha:1.0f];
    pedirBtn.layer.cornerRadius = 14;
    pedirBtn.clipsToBounds      = YES;
    [pedirBtn setTitle:[LanguageHelper getStringWithKey:@"k_s10_request_taxi" defaultValue:@"Pedir Taxi"] forState:UIControlStateNormal];
    [pedirBtn setTitleColor:darkText forState:UIControlStateNormal];
    pedirBtn.titleLabel.font = [UIFont fontWithName:@"NotoSans-Bold" size:17] ?: [UIFont boldSystemFontOfSize:17];
    [pedirBtn addTarget:self action:@selector(pedirTaxiTapped) forControlEvents:UIControlEventTouchUpInside];
    [cv addSubview:pedirBtn];
    self.pedirBtn = pedirBtn;

    y += 56 + 20;

    // Finalise content view + scroll size
    cv.frame                = CGRectMake(0, 0, sw, y);
    scroll.contentSize      = CGSizeMake(sw, y);
}

#pragma mark - Config accordion content

- (void)buildConfigContent:(UIView *)cv width:(CGFloat)w
                  darkText:(UIColor *)darkText
                  grayText:(UIColor *)grayText
               borderColor:(UIColor *)borderColor {

    // Top divider separating header from content
    UIView *topLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, w, 1)];
    topLine.backgroundColor = borderColor;
    [cv addSubview:topLine];

    NSArray *rows = @[
        @{ @"icon":  @"person.3.fill",
           @"icon2": @"person.2.fill",
           @"title": [LanguageHelper getStringWithKey:@"k_s10_passengers" defaultValue:@"Pasajeros"],
           @"sub":   @"" },
        @{ @"icon":  @"pawprint.fill",
           @"icon2": @"heart.fill",
           @"title": [LanguageHelper getStringWithKey:@"k_s10_i_have_pets" defaultValue:@"Llevo mascotas"],
           @"sub":   [LanguageHelper getStringWithKey:@"k_s10_some_drivers_pet_friendly" defaultValue:@"Algunos conductores son Pet Friendly"] },
        @{ @"icon":  @"shippingbox.fill",
           @"icon2": @"cube.fill",
           @"title": [LanguageHelper getStringWithKey:@"k_s10_its_delivery" defaultValue:@"Es un delivery"],
           @"sub":   [LanguageHelper getStringWithKey:@"k_s10_sending_package" defaultValue:@"Estoy enviando un paquete a otra persona"] },
    ];

    UIColor *yellowTint = [UIColor colorNamed:@"app_theame"]
                          ?: [UIColor colorWithRed:0.922f green:0.710f blue:0.094f alpha:1.0f];
    UIColor *iconTint   = [UIColor colorWithRed:0.6f green:0.6f blue:0.6f alpha:1.0f];

    // La primera fila no lleva interruptor sino contador, asi que su hueco va vacio.
    NSArray *switches = @[
        [NSNull null],
        (self.switchPets     = [self makeSwitchWithTint:yellowTint]),
        (self.switchDelivery = [self makeSwitchWithTint:yellowTint]),
    ];

    for (NSInteger i = 0; i < (NSInteger)rows.count; i++) {
        NSDictionary *item = rows[(NSUInteger)i];
        CGFloat ry = 1.0 + i * (kRowH + 1.0); // +1 for separator slot

        // Row container
        UIView *row = [[UIView alloc] initWithFrame:CGRectMake(0, ry, w, kRowH)];
        [cv addSubview:row];

        // Icon
        UIImage *iconImg = [UIImage systemImageNamed:item[@"icon"]]
                           ?: [UIImage systemImageNamed:item[@"icon2"]];
        UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake(16, (kRowH - 28) / 2.0, 28, 28)];
        iconView.image       = [iconImg imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        iconView.tintColor   = iconTint;
        iconView.contentMode = UIViewContentModeScaleAspectFit;
        [row addSubview:iconView];

        // El ancho del mando de la derecha, sea interruptor o contador: de el sale el
        // sitio que le queda al texto.
        CGFloat swW;
        if (i == 0) {
            swW = [self montarContadorEnFila:row ancho:w];
        } else {
            UISwitch *sw = switches[(NSUInteger)i];
            [sw sizeToFit];
            swW = sw.frame.size.width;
            CGFloat swH = sw.frame.size.height;
            sw.frame = CGRectMake(w - 16 - swW, (kRowH - swH) / 2.0, swW, swH);
            [row addSubview:sw];
        }

        // Available width for title + subtitle
        CGFloat textX    = 56.0;
        CGFloat textMaxW = w - textX - swW - 28.0; // 16 gap + 12 margin

        // Title
        UILabel *titleLbl = [[UILabel alloc] init];
        titleLbl.text      = item[@"title"];
        titleLbl.font      = [UIFont fontWithName:@"NotoSans-Bold" size:15] ?: [UIFont boldSystemFontOfSize:15];
        titleLbl.textColor = darkText;
        [titleLbl sizeToFit];
        CGFloat blockH    = titleLbl.frame.size.height + 3;

        UILabel *subLbl = [[UILabel alloc] init];
        subLbl.text          = item[@"sub"];
        subLbl.font          = [UIFont fontWithName:@"NotoSans-Regular" size:12] ?: [UIFont systemFontOfSize:12];
        subLbl.textColor     = grayText;
        subLbl.numberOfLines = 2;
        subLbl.frame         = CGRectMake(textX, 0, textMaxW, 0);
        [subLbl sizeToFit];
        blockH += subLbl.frame.size.height;

        CGFloat blockY = (kRowH - blockH) / 2.0;
        titleLbl.frame = CGRectMake(textX, blockY, textMaxW, titleLbl.frame.size.height);
        subLbl.frame   = CGRectMake(textX, CGRectGetMaxY(titleLbl.frame) + 3,
                                    textMaxW, subLbl.frame.size.height);
        [row addSubview:titleLbl];
        [row addSubview:subLbl];

        if (i == 0) {
            // Este subtitulo cambia con el contador -- se guarda para reescribirlo.
            // Se le deja sitio para dos lineas fijas: si creciera al llegar el recargo,
            // empujaria al titulo y la fila daria un salto en cada toque.
            self.lblDesglosePasajeros = subLbl;
            subLbl.frame = CGRectMake(textX, CGRectGetMaxY(titleLbl.frame) + 3, textMaxW, 32);
            [self refrescarFilaDePasajeros];
        }

        // Separator below row (not after last)
        if (i < (NSInteger)rows.count - 1) {
            UIView *sep = [[UIView alloc] initWithFrame:CGRectMake(16, ry + kRowH, w - 32, 1)];
            sep.backgroundColor = borderColor;
            [cv addSubview:sep];
        }
    }
}

/**
 El "- 1 +" de la derecha. Devuelve lo que ocupa, para que el texto sepa donde acaba.
 */
- (CGFloat)montarContadorEnFila:(UIView *)fila ancho:(CGFloat)w {
    CGFloat lado   = 32.0;
    CGFloat hueco  = 34.0;   // sitio para el numero
    CGFloat ancho  = lado * 2 + hueco;
    CGFloat x      = w - 16 - ancho;
    CGFloat y      = (kRowH - lado) / 2.0;

    self.btnMenosPasajeros = [self botonDeContadorConTitulo:@"−"];
    self.btnMenosPasajeros.frame = CGRectMake(x, y, lado, lado);
    [self.btnMenosPasajeros addTarget:self action:@selector(menosPasajeros)
                     forControlEvents:UIControlEventTouchUpInside];
    [fila addSubview:self.btnMenosPasajeros];

    self.lblNumPasajeros = [[UILabel alloc] initWithFrame:CGRectMake(x + lado, y, hueco, lado)];
    self.lblNumPasajeros.font = [UIFont fontWithName:@"NotoSans-Bold" size:17] ?: [UIFont boldSystemFontOfSize:17];
    self.lblNumPasajeros.textAlignment = NSTextAlignmentCenter;
    self.lblNumPasajeros.textColor = [UIColor colorWithRed:0.157f green:0.157f blue:0.157f alpha:1.0f];
    [fila addSubview:self.lblNumPasajeros];

    self.btnMasPasajeros = [self botonDeContadorConTitulo:@"+"];
    self.btnMasPasajeros.frame = CGRectMake(x + lado + hueco, y, lado, lado);
    [self.btnMasPasajeros addTarget:self action:@selector(masPasajeros)
                   forControlEvents:UIControlEventTouchUpInside];
    [fila addSubview:self.btnMasPasajeros];

    return ancho;
}

- (UIButton *)botonDeContadorConTitulo:(NSString *)titulo {
    UIButton *b = [UIButton buttonWithType:UIButtonTypeCustom];
    b.backgroundColor    = [UIColor colorWithRed:0.949f green:0.949f blue:0.949f alpha:1.0f];
    b.layer.cornerRadius = 16;
    b.clipsToBounds      = YES;
    [b setTitle:titulo forState:UIControlStateNormal];
    [b setTitleColor:[UIColor colorWithRed:0.157f green:0.157f blue:0.157f alpha:1.0f]
            forState:UIControlStateNormal];
    [b setTitleColor:[UIColor colorWithWhite:0.75f alpha:1.0f] forState:UIControlStateDisabled];
    b.titleLabel.font = [UIFont systemFontOfSize:20 weight:UIFontWeightMedium];
    return b;
}

#pragma mark - Pasajeros

/** En moto va uno y en coche cinco: es sitio, no tarifa. */
- (NSInteger)topeDePasajeros {
    NSString *nombre = [self.categoriaElegida.cat_name lowercaseString];
    if (nombre.length > 0 && [nombre containsString:@"moto"]) {
        return kPasajerosTopeMoto;
    }
    return kPasajerosTopeCoche;
}

- (void)masPasajeros   { [self aplicarNumeroDePasajeros:_numPasajeros + 1]; }
- (void)menosPasajeros { [self aplicarNumeroDePasajeros:_numPasajeros - 1]; }

/**
 Cambia cuantos van y ajusta lo que cuesta.

 El recargo se suma AL IMPORTE, no se enseña aparte: es lo que se le va a ofrecer al
 conductor, y tiene que salir en el numero grande y en el que se manda. Por eso aqui
 se mueve la diferencia y no el total -- asi el pasajero conserva lo que hubiera
 subido o bajado a mano con las flechas.

 Los topes del ajustador tambien suben con el recargo, igual que en Android: son un
 porcentaje de la tarifa de la categoria, y el recargo no es tarifa.
 */
- (void)aplicarNumeroDePasajeros:(NSInteger)n {
    if (n < 1 || n > [self topeDePasajeros]) {
        return;
    }
    _numPasajeros = n;

    float recargoNuevo = 0.0f;
    if (n > kPasajerosSinRecargo) {
        recargoNuevo = (float)(n - kPasajerosSinRecargo) * kRecargoPorPasajero;
    }
    float diferencia  = recargoNuevo - _recargoPasajeros;
    _recargoPasajeros = recargoNuevo;

    _currentAmount += diferencia;
    [self ajustarMontoALosTopes];
    self.amountLabel.text = [self formattedAmount:_currentAmount];
    [self actualizarMontoLocal];
    [self refrescarFilaDePasajeros];
}

/** Vuelve a un pasajero y descuenta el recargo: al cambiar de categoria no se arrastra. */
- (void)quitarRecargoDePasajeros {
    _currentAmount   -= _recargoPasajeros;
    _recargoPasajeros = 0.0f;
    _numPasajeros     = 1;
}

- (void)ajustarMontoALosTopes {
    float minimo = (self.minFare > 0) ? self.minFare + _recargoPasajeros : 0.0f;
    float maximo = (self.maxFare > 0) ? self.maxFare + _recargoPasajeros : 0.0f;
    if (minimo > 0 && _currentAmount < minimo) {
        _currentAmount = minimo;
    }
    if (maximo > 0 && _currentAmount > maximo) {
        _currentAmount = maximo;
    }
    if (_currentAmount < 0) {
        _currentAmount = 0;
    }
}

/**
 El numero, el subtitulo y los botones.

 Android avisa del tope con un Toast despues de que el toque no haya hecho nada. Aqui
 el boton se apaga al llegar: se ve antes de tocar, y no hace falta interrumpir.
 */
- (void)refrescarFilaDePasajeros {
    if (self.lblNumPasajeros == nil) {
        return;
    }
    NSInteger tope = [self topeDePasajeros];
    self.lblNumPasajeros.text = [NSString stringWithFormat:@"%ld", (long)_numPasajeros];

    self.btnMenosPasajeros.enabled = (_numPasajeros > 1);
    self.btnMasPasajeros.enabled   = (_numPasajeros < tope);
    self.btnMenosPasajeros.alpha   = self.btnMenosPasajeros.enabled ? 1.0f : 0.4f;
    self.btnMasPasajeros.alpha     = self.btnMasPasajeros.enabled   ? 1.0f : 0.4f;

    NSString *texto;
    if (tope == kPasajerosTopeMoto) {
        texto = [LanguageHelper getStringWithKey:@"k_s10_moto_un_pasajero"
                                    defaultValue:@"En moto solo viaja 1 pasajero"];
    } else if (_recargoPasajeros > 0) {
        NSInteger extra = _numPasajeros - kPasajerosSinRecargo;
        texto = [NSString stringWithFormat:
                 [LanguageHelper getStringWithKey:@"k_s10_recargo_pasajeros"
                                     defaultValue:@"+ %@ por %ld pasajero(s) adicional(es)"],
                 [self formattedAmount:_recargoPasajeros], (long)extra];
    } else {
        texto = [NSString stringWithFormat:
                 [LanguageHelper getStringWithKey:@"k_s10_pasajeros_sin_recargo"
                                     defaultValue:@"Hasta %ld sin recargo, máximo %ld"],
                 (long)kPasajerosSinRecargo, (long)tope];
    }
    self.lblDesglosePasajeros.text = texto;
}

- (UISwitch *)makeSwitchWithTint:(UIColor *)tint {
    UISwitch *sw  = [[UISwitch alloc] init];
    sw.onTintColor = tint;
    sw.thumbTintColor = nil;
    return sw;
}

#pragma mark - Accordion toggle

- (void)configTapped {
    _configExpanded = !_configExpanded;
    CGFloat delta = _configExpanded ? kConfigContentH : -kConfigContentH;

    CGFloat sw = self.view.bounds.size.width;
    CGFloat sh = self.view.bounds.size.height;
    CGFloat newSheetStartY = _configExpanded ? sh * 0.10f : sh * 0.42f;
    CGFloat newSheetH      = sh - newSheetStartY;

    [UIView animateWithDuration:0.35
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
        // Slide sheet up/down to 90% / original height
        self.sheetPanel.frame  = CGRectMake(0, newSheetStartY, sw, newSheetH);
        self.shadowPanel.frame = CGRectMake(0, newSheetStartY, sw, newSheetH);
        self.sheetScroll.frame = CGRectMake(0, 0, sw, newSheetH);
        ((UFareRootView *)self.view).sheetStartY = newSheetStartY;

        // Expand / collapse container height
        CGRect cf = self.configContainer.frame;
        cf.size.height += delta;
        self.configContainer.frame = cf;

        // Resize content view inside container
        CGRect ccf = self.configContentView.frame;
        ccf.size.height += delta;
        self.configContentView.frame = ccf;

        // Rotate chevron: down→up (180°) or up→down (0°)
        self.configChevron.transform = _configExpanded
            ? CGAffineTransformMakeRotation(M_PI)
            : CGAffineTransformIdentity;

        // Shift payRow and pedirBtn down/up by delta
        CGRect cuf = self.filaCupon.frame;
        cuf.origin.y += delta;
        self.filaCupon.frame = cuf;

        CGRect pf = self.payRow.frame;
        pf.origin.y += delta;
        self.payRow.frame = pf;

        CGRect bf = self.pedirBtn.frame;
        bf.origin.y += delta;
        self.pedirBtn.frame = bf;

        // Grow / shrink the content view and scroll area
        CGRect cvf = self.contentCV.frame;
        cvf.size.height += delta;
        self.contentCV.frame = cvf;
        self.sheetScroll.contentSize = CGSizeMake(sw, cvf.size.height);
    } completion:nil];
}

#pragma mark - Hint row helper

- (void)addHintIconName:(NSString *)iconName text:(NSString *)text
                 inView:(UIView *)parent x:(CGFloat)x y:(CGFloat)y width:(CGFloat)w {
    UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectMake(x, y + 4, 16, 16)];
    icon.image       = [[UIImage systemImageNamed:iconName]
                         imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    icon.tintColor   = [UIColor colorWithRed:0.5f green:0.5f blue:0.5f alpha:1.0f];
    icon.contentMode = UIViewContentModeScaleAspectFit;
    [parent addSubview:icon];

    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(x + 20, y, w - 22, 24)];
    lbl.text      = text;
    lbl.font      = [UIFont fontWithName:@"NotoSans-Regular" size:12] ?: [UIFont systemFontOfSize:12];
    lbl.textColor = [UIColor colorWithRed:0.5f green:0.5f blue:0.5f alpha:1.0f];
    [parent addSubview:lbl];
}

#pragma mark - Amount formatting

/**
 El icono y el nombre de la categoria elegida, arriba a la derecha de la tarjeta.

 Con la lista abierta puede parecer redundante, pero no lo es: en cuanto se desplaza la
 hoja, la lista se va de la vista y el rotulo de arriba es lo unico que sigue diciendo
 que se esta pidiendo. Android lo tiene por eso mismo.

 Va dentro de la tarjeta, en la misma fila que el titulo. Estaba colgado de self.view,
 que aqui es la vista transparente a pantalla completa: eso lo dejaba flotando sobre el
 mapa, muy por encima de la tarjeta y sin relacion con el titulo al que acompaña.
 */
- (void)montarChipDeCategoriaEnVista:(UIView *)cv {
    if (self.categoriaElegida == nil) {
        return;
    }
    self.imgChipCategoria = [[UIImageView alloc] init];
    self.imgChipCategoria.contentMode = UIViewContentModeScaleAspectFit;
    [cv addSubview:self.imgChipCategoria];

    self.lblChipCategoria = [[UILabel alloc] init];
    self.lblChipCategoria.font = [UIFont fontWithName:@"NotoSans-Bold" size:15] ?: [UIFont boldSystemFontOfSize:15];
    self.lblChipCategoria.textColor = [UIColor colorWithRed:0.157f green:0.157f blue:0.157f alpha:1.0f];
    self.lblChipCategoria.adjustsFontSizeToFitWidth = YES;
    self.lblChipCategoria.minimumScaleFactor = 0.7f;
    [cv addSubview:self.lblChipCategoria];

    [self actualizarChipDeCategoria];
}

/** Lo que ocupa el chip: el icono, un hueco y el nombre, sin pasar de un tercio. */
- (CGFloat)anchoDelChip {
    if (self.categoriaElegida == nil || self.lblChipCategoria == nil) {
        return 0;
    }
    NSString *nombre = isEmpty(self.categoriaElegida.cat_name);
    CGFloat anchoTexto = ceilf([nombre sizeWithAttributes:
        @{NSFontAttributeName: self.lblChipCategoria.font}].width) + 2;
    anchoTexto = MIN(anchoTexto, _filaDeCabecera.size.width * 0.30f);
    return 34.0 + 6.0 + anchoTexto;
}

/**
 Reparte la fila: volver a la izquierda, chip a la derecha, titulo en lo que queda.

 El titulo iba centrado en el ancho ENTERO, asi que con el chip puesto se le montaba
 encima -- "Tarifa recomendada" a 18 ya ocupa casi todo lo que hay entre los dos.
 */
- (void)reacomodarCabecera {
    CGFloat sw    = _filaDeCabecera.size.width;
    CGFloat y     = _filaDeCabecera.origin.y;
    CGFloat alto  = _filaDeCabecera.size.height;
    if (sw <= 0) {
        return;
    }

    CGFloat anchoChip = [self anchoDelChip];
    if (anchoChip > 0) {
        CGFloat x = sw - 16 - anchoChip;
        CGFloat anchoTexto = anchoChip - 34.0 - 6.0;
        self.imgChipCategoria.frame = CGRectMake(x, y + (alto - 26) / 2.0, 34, 26);
        self.lblChipCategoria.frame = CGRectMake(x + 34 + 6, y + (alto - 20) / 2.0, anchoTexto, 20);
    }

    // 16 de margen + 44 del boton de volver + 8 de aire.
    CGFloat xTitulo  = 68.0;
    CGFloat finTitulo = sw - 16 - (anchoChip > 0 ? anchoChip + 8 : 0);
    self.lblTituloTarifa.frame = CGRectMake(xTitulo, y, MAX(0, finTitulo - xTitulo), alto);
}

- (void)actualizarChipDeCategoria {
    CategoryModel *cat = self.categoriaElegida;
    if (cat == nil || self.lblChipCategoria == nil) {
        return;
    }
    self.lblChipCategoria.text = isEmpty(cat.cat_name);
    UIImage *respaldo = [[cat.cat_name lowercaseString] containsString:@"moto"]
        ? [UIImage imageNamed:@"ic_vehicle_moto"]
        : ([UIImage imageNamed:@"ic_vehicle_car"] ?: [UIImage imageNamed:@"map_car_icon"]);
    [self.imgChipCategoria sd_setImageWithURL:[NSURL URLWithString:isEmpty(cat.cat_image_path)]
                             placeholderImage:respaldo];
    // El nombre nuevo puede medir otra cosa, asi que la fila se reparte otra vez.
    [self reacomodarCabecera];
}

#pragma mark - Cupon

/**
 La fila del codigo promocional, con sus tres caras.

 Una sola fila que cambia de cara -- pedirlo, escribirlo, o enseñar el que se aplico --
 en vez de tres filas apiladas. Asi el alto no cambia nunca, que importa porque esta
 pantalla coloca todo por marcos y el acordeon de arriba mueve lo de abajo por deltas:
 una fila que creciera obligaria a recalcular ese delta.

 @return el alto que ocupa, para que quien monta la pantalla siga contando.
 */
- (CGFloat)montarFilaDeCuponEnVista:(UIView *)cv y:(CGFloat)y ancho:(CGFloat)sw {
    CGFloat ancho = sw - 32;
    CGFloat alto  = 52.0;

    UIColor *darkText  = [UIColor colorWithRed:0.157f green:0.157f blue:0.157f alpha:1.0f];
    UIColor *grayText  = [UIColor colorWithWhite:0.5f alpha:1.0f];
    UIColor *borderClr = [UIColor colorWithWhite:0.878f alpha:1.0f];
    UIColor *verde     = [UIColor colorWithRed:0.18f green:0.65f blue:0.32f alpha:1.0f];

    self.filaCupon = [[UIView alloc] initWithFrame:CGRectMake(16, y, ancho, alto)];
    self.filaCupon.layer.borderWidth  = 1.0f;
    self.filaCupon.layer.borderColor  = borderClr.CGColor;
    self.filaCupon.layer.cornerRadius = 12;
    self.filaCupon.clipsToBounds      = YES;
    [cv addSubview:self.filaCupon];

    // --- Cara 1: "Añadir código promocional" ---
    self.caraPedirCupon = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ancho, alto)];
    [self.filaCupon addSubview:self.caraPedirCupon];

    UIImageView *etiqueta = [[UIImageView alloc] initWithFrame:CGRectMake(16, 15, 22, 22)];
    etiqueta.image = [[UIImage systemImageNamed:@"tag.fill"]
                      imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    etiqueta.tintColor = grayText;
    etiqueta.contentMode = UIViewContentModeScaleAspectFit;
    [self.caraPedirCupon addSubview:etiqueta];

    UILabel *pedir = [[UILabel alloc] initWithFrame:CGRectMake(48, 0, ancho - 80, alto)];
    pedir.text = [LanguageHelper getStringWithKey:@"k_s10_anadir_cupon"
                                     defaultValue:@"Añadir código promocional"];
    pedir.font = [UIFont fontWithName:@"NotoSans-Regular" size:15] ?: [UIFont systemFontOfSize:15];
    pedir.textColor = darkText;
    [self.caraPedirCupon addSubview:pedir];

    UIImageView *flecha = [[UIImageView alloc] initWithFrame:CGRectMake(ancho - 30, 15, 12, 22)];
    flecha.image = [[UIImage systemImageNamed:@"chevron.right"]
                    imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    flecha.tintColor = grayText;
    flecha.contentMode = UIViewContentModeScaleAspectFit;
    [self.caraPedirCupon addSubview:flecha];

    UIButton *tocar = [UIButton buttonWithType:UIButtonTypeCustom];
    tocar.frame = CGRectMake(0, 0, ancho, alto);
    [tocar addTarget:self action:@selector(abrirCupon) forControlEvents:UIControlEventTouchUpInside];
    [self.caraPedirCupon addSubview:tocar];

    // --- Cara 2: escribirlo ---
    self.caraEscribirCupon = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ancho, alto)];
    self.caraEscribirCupon.hidden = YES;
    [self.filaCupon addSubview:self.caraEscribirCupon];

    CGFloat anchoBoton = 92.0;
    self.txtCupon = [[UITextField alloc] initWithFrame:
        CGRectMake(16, 0, ancho - anchoBoton - 28, alto)];
    self.txtCupon.placeholder = [LanguageHelper getStringWithKey:@"k_r49_s3_enter_valid_promo_code"
                                                    defaultValue:@"Escribe tu código"];
    self.txtCupon.font = [UIFont fontWithName:@"NotoSans-Regular" size:15] ?: [UIFont systemFontOfSize:15];
    self.txtCupon.textColor = darkText;
    self.txtCupon.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
    self.txtCupon.autocorrectionType = UITextAutocorrectionTypeNo;
    self.txtCupon.returnKeyType = UIReturnKeyDone;
    [self.txtCupon addTarget:self action:@selector(aplicarCupon)
            forControlEvents:UIControlEventEditingDidEndOnExit];
    [self.caraEscribirCupon addSubview:self.txtCupon];

    UIButton *aplicar = [UIButton buttonWithType:UIButtonTypeCustom];
    aplicar.frame = CGRectMake(ancho - anchoBoton - 8, 8, anchoBoton, alto - 16);
    aplicar.backgroundColor = [UIColor colorNamed:@"app_theame"]
        ?: [UIColor colorWithRed:0.922f green:0.710f blue:0.094f alpha:1.0f];
    aplicar.layer.cornerRadius = 8;
    aplicar.titleLabel.font = [UIFont fontWithName:@"NotoSans-Bold" size:15] ?: [UIFont boldSystemFontOfSize:15];
    [aplicar setTitle:[LanguageHelper getStringWithKey:@"k_r45_s3_apply" defaultValue:@"Aplicar"]
             forState:UIControlStateNormal];
    [aplicar setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [aplicar addTarget:self action:@selector(aplicarCupon) forControlEvents:UIControlEventTouchUpInside];
    [self.caraEscribirCupon addSubview:aplicar];

    // --- Cara 3: el que se aplico ---
    self.caraCuponAplicado = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ancho, alto)];
    self.caraCuponAplicado.hidden = YES;
    [self.filaCupon addSubview:self.caraCuponAplicado];

    UIImageView *visto = [[UIImageView alloc] initWithFrame:CGRectMake(16, 15, 22, 22)];
    visto.image = [[UIImage systemImageNamed:@"checkmark.seal.fill"]
                   imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    visto.tintColor = verde;
    visto.contentMode = UIViewContentModeScaleAspectFit;
    [self.caraCuponAplicado addSubview:visto];

    self.lblCuponAplicado = [[UILabel alloc] initWithFrame:CGRectMake(48, 0, ancho - 90, alto)];
    self.lblCuponAplicado.font = [UIFont fontWithName:@"NotoSans-Bold" size:15] ?: [UIFont boldSystemFontOfSize:15];
    self.lblCuponAplicado.textColor = verde;
    self.lblCuponAplicado.adjustsFontSizeToFitWidth = YES;
    self.lblCuponAplicado.minimumScaleFactor = 0.7f;
    [self.caraCuponAplicado addSubview:self.lblCuponAplicado];

    UIButton *quitar = [UIButton buttonWithType:UIButtonTypeSystem];
    quitar.frame = CGRectMake(ancho - 44, 14, 24, 24);
    [quitar setImage:[[UIImage systemImageNamed:@"xmark.circle.fill"]
                      imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
            forState:UIControlStateNormal];
    quitar.tintColor = grayText;
    [quitar addTarget:self action:@selector(quitarCupon) forControlEvents:UIControlEventTouchUpInside];
    [self.caraCuponAplicado addSubview:quitar];

    [self pintarEstadoDelCupon];

    return alto + 12;
}

- (void)abrirCupon {
    self.caraPedirCupon.hidden    = YES;
    self.caraEscribirCupon.hidden = NO;
    [self.txtCupon becomeFirstResponder];
}

/**
 Manda el codigo a estimar. El descuento lo calcula el servidor, no el telefono.
 */
- (void)aplicarCupon {
    NSString *codigo = [[self.txtCupon.text
        stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]
        uppercaseString];

    if (codigo.length == 0) {
        [self avisar:[LanguageHelper getStringWithKey:@"k_s10_falta_el_cupon"
                                         defaultValue:@"Falta el código"]
             mensaje:[LanguageHelper getStringWithKey:@"k_r49_s3_plz_enter_valid_promo_code"
                                         defaultValue:@"Escribe tu código promocional antes de aplicarlo."]];
        return;
    }

    [self.txtCupon resignFirstResponder];
    _cuponIntentado = codigo;

    if ([self.delegate respondsToSelector:@selector(fareOfferVC:aplicarCupon:)]) {
        [self.delegate fareOfferVC:self aplicarCupon:codigo];
    }
}

- (void)quitarCupon {
    _cuponIntentado = nil;
    self.txtCupon.text = @"";

    if ([self.delegate respondsToSelector:@selector(fareOfferVCQuitarCupon:)]) {
        [self.delegate fareOfferVCQuitarCupon:self];
    }
}

/** El codigo que el servidor dio por bueno para la categoria elegida, si lo hay. */
- (NSString *)cuponDelServidor {
    EstimatedFare *est = [self estimacionDeLaCategoriaElegida];
    NSString *codigo = est.promo_code;
    return (codigo.length > 0 && ![codigo isEqualToString:@"0"]) ? codigo : nil;
}

- (EstimatedFare *)estimacionDeLaCategoriaElegida {
    if (self.categoriaElegida == nil) {
        return nil;
    }
    NSString *clave = [NSString stringWithFormat:@"%d", self.categoriaElegida.categoryId];
    return [self.estimacionesPorCategoria objectForKey:clave];
}

/**
 Pinta la cara que toca segun lo que contesto el servidor.

 Se llama SIEMPRE despues de una estimacion, con cupon o sin el: es la respuesta la que
 decide si el codigo valia, no lo que escribio el pasajero.
 */
- (void)pintarEstadoDelCupon {
    if (self.filaCupon == nil) {
        return;
    }
    NSString *aplicado = [self cuponDelServidor];

    if (aplicado.length > 0) {
        float descuento = [self estimacionDeLaCategoriaElegida].trip_promo_amt;
        self.lblCuponAplicado.text = (descuento > 0)
            ? [NSString stringWithFormat:@"%@  ·  -%@", aplicado, [self formattedAmount:descuento]]
            : [NSString stringWithFormat:
               [LanguageHelper getStringWithKey:@"k_s10_cupon_aplicado" defaultValue:@"%@ aplicado"],
               aplicado];

        self.caraPedirCupon.hidden     = YES;
        self.caraEscribirCupon.hidden  = YES;
        self.caraCuponAplicado.hidden  = NO;
        _cuponIntentado = nil;
        return;
    }

    // Sin cupon aplicado. Si veniamos de intentar uno, es que no valia.
    if (_cuponIntentado.length > 0) {
        NSString *intentado = _cuponIntentado;
        _cuponIntentado = nil;
        [self avisar:[LanguageHelper getStringWithKey:@"k_s10_cupon_no_valido"
                                         defaultValue:@"Código no válido"]
             mensaje:[NSString stringWithFormat:
                      [LanguageHelper getStringWithKey:@"k_s10_cupon_no_valido_texto"
                                          defaultValue:@"No pudimos aplicar el código %@."],
                      intentado]];
    }

    self.caraPedirCupon.hidden    = NO;
    self.caraEscribirCupon.hidden = YES;
    self.caraCuponAplicado.hidden = YES;
}

- (void)avisar:(NSString *)titulo mensaje:(NSString *)mensaje {
    UIAlertController *alerta = [UIAlertController alertControllerWithTitle:titulo
                                                                   message:mensaje
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alerta addAction:[UIAlertAction
        actionWithTitle:[LanguageHelper getStringWithKey:@"k_18_s4_Ok" defaultValue:@"OK"]
        style:UIAlertActionStyleDefault
        handler:nil]];
    [self presentViewController:alerta animated:YES completion:nil];
}

#pragma mark - Refresco

/**
 Vuelve a pintar con una estimacion recien traida.

 Los precios de TODAS las categorias cambian a la vez, porque el servidor las devuelve
 todas en la misma llamada: por eso se repintan las filas enteras y no solo la elegida.

 El recargo por pasajeros se conserva: no depende del cupon ni de la estimacion, lo
 puso el pasajero y sigue puesto.
 */
- (void)refrescarConEstimaciones:(NSDictionary *)estimaciones {
    if (estimaciones != nil) {
        self.estimacionesPorCategoria = estimaciones;
    }

    float recomendado = [self precioDeCategoria:self.categoriaElegida];
    if (recomendado > 0) {
        CategoryModel *cat = self.categoriaElegida;
        self.recommendedFare = recomendado;
        self.minFare = (cat.min_offer_perc > 0) ? recomendado * (1.0f - cat.min_offer_perc / 100.0f) : 0.0f;
        self.maxFare = (cat.max_offer_perc > 0) ? recomendado * (1.0f + cat.max_offer_perc / 100.0f) : 0.0f;
        _currentAmount = recomendado + _recargoPasajeros;
        [self ajustarMontoALosTopes];
        self.amountLabel.text = [self formattedAmount:_currentAmount];
        [self actualizarMontoLocal];
    }

    [self repintarPreciosDeLasCategorias];
    [self pintarEstadoDelCupon];
}

- (void)repintarPreciosDeLasCategorias {
    for (NSInteger i = 0; i < (NSInteger)self.filasCategoria.count; i++) {
        if (i >= (NSInteger)self.categorias.count) {
            break;
        }
        UIView  *fila   = [self.filasCategoria objectAtIndex:(NSUInteger)i];
        UILabel *precio = [self.preciosCategoria objectAtIndex:(NSUInteger)i];
        if (precio == nil || fila == nil) {
            continue;
        }
        CategoryModel *cat = [self.categorias objectAtIndex:(NSUInteger)i];
        precio.text = [self formattedAmount:[self precioDeCategoria:cat]];
    }
}

#pragma mark - Elige tu viaje

/**
 La lista de categorias con su precio.

 SE ENSEÑA SIEMPRE ABIERTA, a diferencia de Android, que la pliega con un resumen. Son
 dos o tres filas y es la eleccion principal de esta pantalla: plegarla obliga a un toque
 de mas para ver lo unico que el pasajero viene a comparar. Ademas, el acordeon de abajo
 mueve las vistas por deltas y meter un segundo plegable encima complica ese calculo sin
 ganar nada.

 El precio de cada una sale de estimacionesPorCategoria, el diccionario que BookingModel
 ya tenia: tripapi/estimatetripfare devuelve una estimacion por CADA categoria en una
 sola llamada.

 @return el alto que ha ocupado, para que quien monta la pantalla siga contando.
 */
- (CGFloat)montarEligeTuViajeEnVista:(UIView *)cv y:(CGFloat)y ancho:(CGFloat)sw {
    if (self.categorias.count == 0) {
        return 0;
    }
    self.filasCategoria   = [[NSMutableArray alloc] init];
    self.preciosCategoria = [[NSMutableArray alloc] init];

    UIColor *darkText  = [UIColor colorWithRed:0.157f green:0.157f blue:0.157f alpha:1.0f];
    UIColor *grayText  = [UIColor colorWithWhite:0.45f alpha:1.0f];
    UIColor *borderClr = [UIColor colorWithWhite:0.878f alpha:1.0f];
    UIColor *amarillo  = [UIColor colorNamed:@"app_theame"]
        ?: [UIColor colorWithRed:235/255.0 green:181/255.0 blue:24/255.0 alpha:1];

    CGFloat alto0 = y;
    CGFloat filaH = 64.0;

    UILabel *titulo = [[UILabel alloc] initWithFrame:CGRectMake(16, y, sw - 32, 22)];
    titulo.text = [LanguageHelper getStringWithKey:@"k_s10_elige_tu_viaje" defaultValue:@"Elige tu viaje"];
    titulo.font = [UIFont fontWithName:@"NotoSans-Bold" size:16] ?: [UIFont boldSystemFontOfSize:16];
    titulo.textColor = darkText;
    [cv addSubview:titulo];
    y += 22 + 10;

    for (NSInteger i = 0; i < (NSInteger)self.categorias.count; i++) {
        CategoryModel *cat = [self.categorias objectAtIndex:(NSUInteger)i];
        BOOL elegida = (self.categoriaElegida
                        && cat.categoryId == self.categoriaElegida.categoryId);

        UIView *fila = [[UIView alloc] initWithFrame:CGRectMake(16, y, sw - 32, filaH)];
        fila.layer.cornerRadius = 12;
        fila.layer.borderWidth = elegida ? 2.0f : 1.0f;
        fila.layer.borderColor = (elegida ? amarillo : borderClr).CGColor;
        fila.backgroundColor = elegida
            ? [UIColor colorWithRed:1.0f green:0.984f blue:0.918f alpha:1.0f]
            : [UIColor whiteColor];
        fila.tag = i;
        fila.userInteractionEnabled = YES;
        [fila addGestureRecognizer:[[UITapGestureRecognizer alloc]
            initWithTarget:self action:@selector(tocarFilaCategoria:)]];
        [cv addSubview:fila];
        [self.filasCategoria addObject:fila];

        UIImageView *icono = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 56, 44)];
        icono.contentMode = UIViewContentModeScaleAspectFit;
        UIImage *respaldo = [[cat.cat_name lowercaseString] containsString:@"moto"]
            ? [UIImage imageNamed:@"ic_vehicle_moto"]
            : ([UIImage imageNamed:@"ic_vehicle_car"] ?: [UIImage imageNamed:@"map_car_icon"]);
        [icono sd_setImageWithURL:[NSURL URLWithString:isEmpty(cat.cat_image_path)]
                 placeholderImage:respaldo];
        [fila addSubview:icono];

        UILabel *nombre = [[UILabel alloc] initWithFrame:CGRectMake(76, 12, 140, 22)];
        nombre.text = isEmpty(cat.cat_name);
        nombre.font = [UIFont fontWithName:@"NotoSans-Bold" size:17] ?: [UIFont boldSystemFontOfSize:17];
        nombre.textColor = darkText;
        [fila addSubview:nombre];

        // Cuantas personas caben. Android lo enseña con el icono de personas al lado.
        if (cat.cat_max_size > 0) {
            UIImageView *personas = [[UIImageView alloc] initWithFrame:CGRectMake(76, 38, 18, 16)];
            personas.image = [[UIImage systemImageNamed:@"person.2.fill"]
                              imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            personas.tintColor = grayText;
            personas.contentMode = UIViewContentModeScaleAspectFit;
            [fila addSubview:personas];

            UILabel *cuantas = [[UILabel alloc] initWithFrame:CGRectMake(98, 36, 40, 20)];
            cuantas.text = [NSString stringWithFormat:@"%d", cat.cat_max_size];
            cuantas.font = [UIFont fontWithName:@"NotoSans-Regular" size:13] ?: [UIFont systemFontOfSize:13];
            cuantas.textColor = grayText;
            [fila addSubview:cuantas];
        }

        UILabel *precio = [[UILabel alloc] initWithFrame:CGRectMake(sw - 32 - 130, 20, 118, 24)];
        precio.text = [self formattedAmount:[self precioDeCategoria:cat]];
        precio.font = [UIFont fontWithName:@"NotoSans-Bold" size:18] ?: [UIFont boldSystemFontOfSize:18];
        precio.textColor = darkText;
        precio.textAlignment = NSTextAlignmentRight;
        precio.adjustsFontSizeToFitWidth = YES;
        precio.minimumScaleFactor = 0.7f;
        [fila addSubview:precio];
        [self.preciosCategoria addObject:precio];

        y += filaH + 8;
    }

    return (y - alto0) + 6;
}

/** El precio estimado de una categoria, o 0 si el servidor no lo mando. */
- (float)precioDeCategoria:(CategoryModel *)cat {
    if (cat == nil) {
        return 0;
    }
    NSString *clave = [NSString stringWithFormat:@"%d", cat.categoryId];
    EstimatedFare *est = [self.estimacionesPorCategoria objectForKey:clave];
    if (est == nil) {
        return 0;
    }
    // El mismo campo que usa presentScreen3 para el precio recomendado.
    return est.trip_pay_amount_without_share_discount_without_promo;
}

- (void)tocarFilaCategoria:(UITapGestureRecognizer *)gesto {
    NSInteger i = gesto.view.tag;
    if (i < 0 || i >= (NSInteger)self.categorias.count) {
        return;
    }
    CategoryModel *cat = [self.categorias objectAtIndex:(NSUInteger)i];
    if (self.categoriaElegida && cat.categoryId == self.categoriaElegida.categoryId) {
        return;
    }
    self.categoriaElegida = cat;

    // Repintar el marcado sin rehacer la pantalla entera.
    UIColor *borderClr = [UIColor colorWithWhite:0.878f alpha:1.0f];
    UIColor *amarillo  = [UIColor colorNamed:@"app_theame"]
        ?: [UIColor colorWithRed:235/255.0 green:181/255.0 blue:24/255.0 alpha:1];
    for (NSInteger j = 0; j < (NSInteger)self.filasCategoria.count; j++) {
        UIView *fila = [self.filasCategoria objectAtIndex:(NSUInteger)j];
        BOOL esta = (j == i);
        fila.layer.borderWidth = esta ? 2.0f : 1.0f;
        fila.layer.borderColor = (esta ? amarillo : borderClr).CGColor;
        fila.backgroundColor = esta
            ? [UIColor colorWithRed:1.0f green:0.984f blue:0.918f alpha:1.0f]
            : [UIColor whiteColor];
    }

    // El recargo por pasajeros era de la categoria anterior, y ademas la nueva puede
    // no admitir tantos -- una moto lleva uno. Se descuenta ANTES de tocar el precio,
    // que es cuando _currentAmount todavia lo incluye.
    [self quitarRecargoDePasajeros];

    // El precio de arriba pasa a ser el de la categoria elegida, y con el se recalculan
    // los topes del ajustador: son un porcentaje de SU tarifa, no de la anterior.
    float recomendado = [self precioDeCategoria:cat];
    if (recomendado > 0) {
        self.recommendedFare = recomendado;
        self.minFare = (cat.min_offer_perc > 0) ? recomendado * (1.0f - cat.min_offer_perc / 100.0f) : 0.0f;
        self.maxFare = (cat.max_offer_perc > 0) ? recomendado * (1.0f + cat.max_offer_perc / 100.0f) : 0.0f;
        _currentAmount = recomendado;
        self.amountLabel.text = [self formattedAmount:_currentAmount];
        [self actualizarMontoLocal];
    }

    self.amountLabel.text = [self formattedAmount:_currentAmount];
    [self actualizarMontoLocal];
    [self actualizarChipDeCategoria];
    [self refrescarFilaDePasajeros];
    // El cupon se aplica por categoria: el servidor pudo darlo por bueno en una y no
    // en otra, asi que la cara del cupon se vuelve a mirar con la que ahora esta.
    [self pintarEstadoDelCupon];

    if ([self.delegate respondsToSelector:@selector(fareOfferVC:eligioCategoria:)]) {
        [self.delegate fareOfferVC:self eligioCategoria:cat];
    }
}

/** "Monto en bs: Bs 1.937,06". Se calla si no hay tasa configurada. */
- (void)actualizarMontoLocal {
    float tasa = [ConstantModel tasaDolarALocal];
    if (tasa <= 0) {
        self.lblMontoLocal.text = @"";
        return;
    }
    NSNumberFormatter *formato = [[NSNumberFormatter alloc] init];
    formato.numberStyle = NSNumberFormatterDecimalStyle;
    formato.minimumFractionDigits = 2;
    formato.maximumFractionDigits = 2;
    self.lblMontoLocal.text = [NSString stringWithFormat:
        [LanguageHelper getStringWithKey:@"k_s10_monto_en_bs" defaultValue:@"Monto en bs: Bs %@"],
        [formato stringFromNumber:@(_currentAmount * tasa)]];
}

- (NSString *)formattedAmount:(float)amount {
    NSString *cur = self.currency.length > 0 ? self.currency : @"$";
    if (cur.length <= 1) return [NSString stringWithFormat:@"%.2f%@", amount, cur];
    return [NSString stringWithFormat:@"%.2f %@", amount, cur];
}

#pragma mark - Stepper actions

- (void)minusTapped {
    _currentAmount -= [self stepAmount];
    [self ajustarMontoALosTopes];
    self.amountLabel.text = [self formattedAmount:_currentAmount];
    [self actualizarMontoLocal];
}

- (void)plusTapped {
    _currentAmount += [self stepAmount];
    [self ajustarMontoALosTopes];
    self.amountLabel.text = [self formattedAmount:_currentAmount];
    [self actualizarMontoLocal];
}

/// Step = 5% of recommended fare, rounded to nearest 0.25 (min 0.25)
- (float)stepAmount {
    if (self.recommendedFare <= 0) return 0.25f;
    float raw     = self.recommendedFare * 0.05f;
    float rounded = (float)(round(raw * 4.0) / 4.0);
    return rounded > 0 ? rounded : 0.25f;
}

#pragma mark - Button actions

- (void)backTapped {
    [self.delegate fareOfferDidTapBack:self];
}

- (void)paymentTapped {
    [self.delegate fareOfferVCDidTapPayment:self];
}

- (void)pedirTaxiTapped {
    [self.delegate fareOfferVC:self didRequestTripWithAmount:_currentAmount];
}

#pragma mark - Public update

- (void)updatePaymentLabel:(NSString *)label icon:(UIImage *)icon {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.paymentRowLabel.text = [NSString stringWithFormat:[LanguageHelper getStringWithKey:@"k_s10_pay_with_format" defaultValue:@"Paga con %@"],
                                      label.length > 0 ? label : [LanguageHelper getStringWithKey:@"k_r39_s9_cash" defaultValue:@"Efectivo"]];
        if (icon) {
            self.paymentIconView.image = [icon imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        }
    });
}

@end
