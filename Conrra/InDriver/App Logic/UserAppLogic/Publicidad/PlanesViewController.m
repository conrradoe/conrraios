//
//  PlanesViewController.m
//  Conrra
//

#import "PlanesViewController.h"
#import "ConrraCatalogoDePlanes.h"
#import "ConrraDestinoDePlan.h"
#import "ConstantModel.h"
#import "CityModel.h"
#import "LanguageHelper.h"
#import "WebCallConstants.h"
#import "AppDelegate.h"
#import "UIImageView+WebCache.h"
#import <GIKit/GIKit.h>

/** Cuantos dias se ofrecen arriba, contando hoy. */
static const NSInteger kDiasALaVista = 7;
static const NSInteger kColumnas = 2;

#pragma mark - Ficha de filtro

/**
 Las fichas de arriba: categoria y dia.

 Una sola clase para las dos filas porque hacen lo mismo -- una fila horizontal donde solo
 una esta elegida -- y lo unico que cambia es que el dia lleva numero debajo. Dos clases
 gemelas se separan en cuanto alguien arregla el contraste de la elegida en una y se olvida
 de la otra.
 */
@interface ConrraFicha : NSObject
@property (nonatomic, copy) NSString *clave;    ///< "todos", "promo", o un AAAA-MM-DD
@property (nonatomic, copy) NSString *rotulo;
@property (nonatomic, copy) NSString *numero;   ///< solo los dias
@end

@implementation ConrraFicha
@end


#pragma mark - Celda

@interface ConrraPlanCell : UICollectionViewCell
@property (nonatomic, strong) UIImageView *foto;
@property (nonatomic, strong) UILabel *etiqueta;
@property (nonatomic, strong) UILabel *titulo;
@property (nonatomic, strong) UILabel *sitio;
@property (nonatomic, strong) UILabel *detalle;
@property (nonatomic, strong) UILabel *pie;
@property (nonatomic, strong) UIButton *boton;
/** El plan que esta celda esta enseñando ahora mismo. */
@property (nonatomic, strong) ConrraPlan *plan;
@end


@implementation ConrraPlanCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.contentView.backgroundColor = [UIColor colorNamed:@"color_app_box_bg"]
                                           ?: [UIColor whiteColor];
        self.contentView.layer.cornerRadius = 14;
        self.contentView.clipsToBounds = YES;

        UIColor *amarillo = [UIColor colorNamed:@"app_theame"]
                            ?: [UIColor colorWithRed:235/255.0 green:181/255.0 blue:24/255.0 alpha:1];
        UIColor *texto = [UIColor colorNamed:@"color_app_label"] ?: [UIColor blackColor];

        _foto = [[UIImageView alloc] init];
        _foto.contentMode = UIViewContentModeScaleAspectFill;
        _foto.clipsToBounds = YES;
        _foto.backgroundColor = [UIColor colorWithWhite:0.90 alpha:1];
        [self.contentView addSubview:_foto];

        _etiqueta = [[UILabel alloc] init];
        _etiqueta.font = FONTS_NOTO_BOLD(11);
        _etiqueta.textColor = [UIColor blackColor];
        _etiqueta.backgroundColor = amarillo;
        _etiqueta.textAlignment = NSTextAlignmentCenter;
        _etiqueta.layer.cornerRadius = 8;
        _etiqueta.clipsToBounds = YES;
        [self.contentView addSubview:_etiqueta];

        _titulo = [[UILabel alloc] init];
        _titulo.font = FONTS_NOTO_BOLD(15);
        _titulo.textColor = texto;
        _titulo.numberOfLines = 2;
        [self.contentView addSubview:_titulo];

        _sitio = [[UILabel alloc] init];
        _sitio.font = FONTS_NOTO_REGULAR(13);
        _sitio.textColor = [UIColor colorWithWhite:0.45 alpha:1];
        _sitio.numberOfLines = 1;
        [self.contentView addSubview:_sitio];

        _detalle = [[UILabel alloc] init];
        _detalle.font = FONTS_NOTO_REGULAR(12);
        _detalle.textColor = [UIColor colorWithWhite:0.45 alpha:1];
        _detalle.numberOfLines = 2;
        [self.contentView addSubview:_detalle];

        _pie = [[UILabel alloc] init];
        _pie.font = FONTS_NOTO_REGULAR(11);
        _pie.textColor = [UIColor colorWithWhite:0.55 alpha:1];
        _pie.numberOfLines = 1;
        [self.contentView addSubview:_pie];

        _boton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_boton setTitle:@"IR" forState:UIControlStateNormal];
        [_boton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _boton.titleLabel.font = FONTS_NOTO_BOLD(14);
        _boton.backgroundColor = amarillo;
        _boton.layer.cornerRadius = 10;
        _boton.clipsToBounds = YES;
        // El toque lo recoge el collection view entero (didSelectItem), igual que en
        // Android, donde la tarjeta y el boton hacen lo mismo. Aqui el boton solo pinta.
        _boton.userInteractionEnabled = NO;
        [self.contentView addSubview:_boton];
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.plan = nil;
    // sd_setImageWithURL: ya cancela por su cuenta la carga anterior de esta misma vista,
    // asi que basta con vaciar la imagen para que no se vea la del plan anterior mientras
    // llega la nueva.
    self.foto.image = nil;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat w = self.contentView.bounds.size.width;
    CGFloat pad = 10;
    CGFloat altoFoto = roundf(w * 0.52f);

    self.foto.frame = CGRectMake(0, 0, w, altoFoto);

    CGSize tamEtiqueta = [self.etiqueta sizeThatFits:CGSizeMake(w - 2 * pad, 20)];
    CGFloat anchoEtiqueta = MIN(w - 2 * pad, tamEtiqueta.width + 16);
    self.etiqueta.frame = CGRectMake(pad, altoFoto - 26, anchoEtiqueta, 18);
    self.etiqueta.hidden = (self.etiqueta.text.length == 0);

    CGFloat y = altoFoto + 8;
    CGFloat anchoTexto = w - 2 * pad;

    self.titulo.frame = CGRectMake(pad, y, anchoTexto, 0);
    [self.titulo sizeToFit];
    self.titulo.frame = CGRectMake(pad, y, anchoTexto, MIN(self.titulo.frame.size.height, 38));
    y = CGRectGetMaxY(self.titulo.frame) + 2;

    self.sitio.frame = CGRectMake(pad, y, anchoTexto, 16);
    y += 18;

    if (!self.detalle.hidden) {
        self.detalle.frame = CGRectMake(pad, y, anchoTexto, 15);
        y += 17;
    }
    if (!self.pie.hidden) {
        self.pie.frame = CGRectMake(pad, y, anchoTexto, 14);
        y += 16;
    }

    CGFloat altoBoton = 34;
    CGFloat yBoton = self.contentView.bounds.size.height - altoBoton - pad;
    self.boton.frame = CGRectMake(pad, MAX(y + 4, yBoton), anchoTexto, altoBoton);
}

@end


#pragma mark - Pantalla

@interface PlanesViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITextFieldDelegate>

@property (nonatomic, strong) ConrraCatalogoDePlanes *catalogo;
@property (nonatomic, strong) NSMutableArray<ConrraPlan *> *recibidos;
@property (nonatomic, strong) NSMutableArray<ConrraPlan *> *visibles;

@property (nonatomic, strong) NSArray<ConrraFicha *> *categorias;
@property (nonatomic, strong) NSArray<ConrraFicha *> *dias;
@property (nonatomic, assign) NSInteger categoriaElegida;
@property (nonatomic, assign) NSInteger diaElegido;

@property (nonatomic, strong) UILabel *lblCiudad;
@property (nonatomic, strong) UITextField *txtBuscar;
@property (nonatomic, strong) UIScrollView *filaCategorias;
@property (nonatomic, strong) UIScrollView *filaDias;
@property (nonatomic, strong) UICollectionView *rejilla;
@property (nonatomic, strong) UILabel *lblVacio;
@property (nonatomic, strong) UIActivityIndicatorView *barra;

@end


@implementation PlanesViewController

#pragma mark - Puerta de entrada

+ (BOOL)estaHabilitada {
    BOOL esPasajero = [defaults_object(P_IS_USER_LOGIN) boolValue];
    if (!esPasajero) {
        return NO;
    }
    // El lector de constantes vive en ConstantModel: lo necesita tambien el recibo
    // para la tasa de cambio, y dos copias de lo mismo acaban separandose.
    return [[ConstantModel valorDeConstantePorClave:@"enable_sitios"] isEqualToString:@"1"];
}



#pragma mark - Ciclo de vida

- (void)viewDidLoad {
    [super viewDidLoad];

    // Esconder la entrada del menu no es un control: a una pantalla se llega tambien desde
    // un atajo viejo o desde una notificacion. Si el backend la apago, o si quien esta
    // dentro es un conductor, aqui se acaba.
    if (![PlanesViewController estaHabilitada]) {
        [self.navigationController popViewControllerAnimated:NO];
        return;
    }

    self.view.backgroundColor = [UIColor colorNamed:@"color_app_bg"] ?: [UIColor whiteColor];
    self.catalogo  = [[ConrraCatalogoDePlanes alloc] init];
    self.recibidos = [NSMutableArray array];
    self.visibles  = [NSMutableArray array];
    self.categoriaElegida = 0;
    self.diaElegido = 0;

    [self prepararCategorias];
    [self prepararDias];
    [self montarVistas];
    [self ponerCiudad];

    [self pedirPlanes];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    // Al volver a entrar las vistas vuelven a contar: es otra visita, y el rele emite
    // testigos nuevos en cada listado de todos modos.
    [self.catalogo olvidarImpresiones];
}

#pragma mark - Montaje

- (void)montarVistas {
    CGFloat w = self.view.bounds.size.width;
    CGFloat safeTop = self.view.safeAreaInsets.top;
    if (safeTop <= 0) { safeTop = 44; }

    UIColor *texto = [UIColor colorNamed:@"color_app_label"] ?: [UIColor blackColor];

    UIButton *atras = [UIButton buttonWithType:UIButtonTypeSystem];
    [atras setImage:[UIImage systemImageNamed:@"chevron.left"] forState:UIControlStateNormal];
    atras.tintColor = texto;
    atras.frame = CGRectMake(8, safeTop + 4, 40, 40);
    [atras addTarget:self action:@selector(volver) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:atras];

    UILabel *titulo = [[UILabel alloc] initWithFrame:CGRectMake(52, safeTop + 4, w - 104, 26)];
    titulo.text = [LanguageHelper getStringWithKey:@"k_s10_planes_titulo" defaultValue:@"Sitios"];
    titulo.font = FONTS_NOTO_BOLD(20);
    titulo.textColor = texto;
    [self.view addSubview:titulo];

    self.lblCiudad = [[UILabel alloc] initWithFrame:CGRectMake(52, safeTop + 30, w - 104, 16)];
    self.lblCiudad.font = FONTS_NOTO_REGULAR(12);
    self.lblCiudad.textColor = [UIColor colorWithWhite:0.5 alpha:1];
    [self.view addSubview:self.lblCiudad];

    CGFloat y = safeTop + 54;

    self.txtBuscar = [[UITextField alloc] initWithFrame:CGRectMake(16, y, w - 32, 44)];
    self.txtBuscar.placeholder = [LanguageHelper getStringWithKey:@"k_s10_planes_buscar"
                                                     defaultValue:@"¿Qué te provoca hacer hoy?"];
    self.txtBuscar.font = FONTS_NOTO_REGULAR(14);
    self.txtBuscar.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1];
    self.txtBuscar.layer.cornerRadius = 12;
    self.txtBuscar.clipsToBounds = YES;
    self.txtBuscar.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 12, 44)];
    self.txtBuscar.leftViewMode = UITextFieldViewModeAlways;
    self.txtBuscar.returnKeyType = UIReturnKeyDone;
    self.txtBuscar.delegate = self;
    [self.txtBuscar addTarget:self action:@selector(repintar) forControlEvents:UIControlEventEditingChanged];
    [self.view addSubview:self.txtBuscar];
    y += 54;

    self.filaCategorias = [self filaConFichas:self.categorias
                                            y:y
                                       accion:@selector(tocarCategoria:)
                                     elegidaEn:self.categoriaElegida
                                     conNumero:NO];
    [self.view addSubview:self.filaCategorias];
    y += 44;

    self.filaDias = [self filaConFichas:self.dias
                                      y:y
                                 accion:@selector(tocarDia:)
                               elegidaEn:self.diaElegido
                               conNumero:YES];
    [self.view addSubview:self.filaDias];
    y += 60;

    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumInteritemSpacing = 12;
    layout.minimumLineSpacing = 12;
    layout.sectionInset = UIEdgeInsetsMake(4, 16, 24, 16);

    self.rejilla = [[UICollectionView alloc] initWithFrame:CGRectMake(0, y, w, self.view.bounds.size.height - y)
                                     collectionViewLayout:layout];
    self.rejilla.backgroundColor = [UIColor clearColor];
    self.rejilla.dataSource = self;
    self.rejilla.delegate = self;
    self.rejilla.alwaysBounceVertical = YES;
    self.rejilla.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    [self.rejilla registerClass:[ConrraPlanCell class] forCellWithReuseIdentifier:@"plan"];
    [self.view addSubview:self.rejilla];

    self.lblVacio = [[UILabel alloc] initWithFrame:CGRectMake(32, y + 60, w - 64, 60)];
    self.lblVacio.font = FONTS_NOTO_REGULAR(14);
    self.lblVacio.textColor = [UIColor colorWithWhite:0.5 alpha:1];
    self.lblVacio.textAlignment = NSTextAlignmentCenter;
    self.lblVacio.numberOfLines = 3;
    self.lblVacio.hidden = YES;
    [self.view addSubview:self.lblVacio];

    self.barra = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
    self.barra.center = CGPointMake(w / 2, y + 60);
    self.barra.hidesWhenStopped = YES;
    [self.view addSubview:self.barra];
}

/** Una fila horizontal de fichas. Los botones llevan el indice en el tag. */
- (UIScrollView *)filaConFichas:(NSArray<ConrraFicha *> *)fichas
                              y:(CGFloat)y
                         accion:(SEL)accion
                      elegidaEn:(NSInteger)elegida
                      conNumero:(BOOL)conNumero {

    CGFloat alto = conNumero ? 52 : 36;
    UIScrollView *fila = [[UIScrollView alloc] initWithFrame:
                          CGRectMake(0, y, self.view.bounds.size.width, alto)];
    fila.showsHorizontalScrollIndicator = NO;

    CGFloat x = 16;
    for (NSInteger i = 0; i < (NSInteger)fichas.count; i++) {
        ConrraFicha *f = [fichas objectAtIndex:(NSUInteger)i];
        UIButton *b = [UIButton buttonWithType:UIButtonTypeCustom];
        b.tag = i;
        b.titleLabel.font = FONTS_NOTO_BOLD(13);
        b.titleLabel.textAlignment = NSTextAlignmentCenter;
        b.titleLabel.numberOfLines = conNumero ? 2 : 1;
        b.layer.cornerRadius = conNumero ? 14 : 18;
        b.clipsToBounds = YES;
        [b addTarget:self action:accion forControlEvents:UIControlEventTouchUpInside];

        NSString *rotulo = conNumero && f.numero.length > 0
            ? [NSString stringWithFormat:@"%@\n%@", f.rotulo, f.numero]
            : f.rotulo;
        [b setTitle:rotulo forState:UIControlStateNormal];

        CGFloat ancho = MAX(conNumero ? 52 : 74,
                            [rotulo sizeWithAttributes:@{NSFontAttributeName: b.titleLabel.font}].width + 28);
        b.frame = CGRectMake(x, 0, ancho, alto - 6);
        [self pintarFicha:b elegida:(i == elegida)];
        [fila addSubview:b];
        x += ancho + 8;
    }
    fila.contentSize = CGSizeMake(x + 8, alto);
    return fila;
}

- (void)pintarFicha:(UIButton *)b elegida:(BOOL)elegida {
    UIColor *amarillo = [UIColor colorNamed:@"app_theame"]
                        ?: [UIColor colorWithRed:235/255.0 green:181/255.0 blue:24/255.0 alpha:1];
    if (elegida) {
        b.backgroundColor = amarillo;
        // Negro sobre amarillo de marca: el blanco sobre este amarillo no llega al
        // contraste minimo y la ficha elegida se lee peor que las demas.
        [b setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    } else {
        b.backgroundColor = [UIColor colorWithWhite:0.94 alpha:1];
        [b setTitleColor:[UIColor colorWithWhite:0.35 alpha:1] forState:UIControlStateNormal];
    }
}

- (void)prepararCategorias {
    NSArray *pares = @[
        @[@"todos",       [LanguageHelper getStringWithKey:@"k_s10_planes_cat_todos"       defaultValue:@"Todos"]],
        @[@"restaurante", [LanguageHelper getStringWithKey:@"k_s10_planes_cat_restaurante" defaultValue:@"Restaurantes"]],
        @[@"promo",       [LanguageHelper getStringWithKey:@"k_s10_planes_cat_promo"       defaultValue:@"Promos"]],
        @[@"evento",      [LanguageHelper getStringWithKey:@"k_s10_planes_cat_evento"      defaultValue:@"Eventos"]],
    ];
    NSMutableArray *lista = [NSMutableArray array];
    for (NSArray *par in pares) {
        ConrraFicha *f = [[ConrraFicha alloc] init];
        f.clave  = par[0];
        f.rotulo = par[1];
        [lista addObject:f];
    }
    self.categorias = lista;
}

- (void)prepararDias {
    NSMutableArray *lista = [NSMutableArray array];
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDate *dia = [NSDate date];

    NSDateFormatter *clave = [[NSDateFormatter alloc] init];
    clave.dateFormat = @"yyyy-MM-dd";
    clave.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];

    NSArray *nombres = @[@"", @"DOM", @"LUN", @"MAR", @"MIÉ", @"JUE", @"VIE", @"SÁB"];

    for (NSInteger i = 0; i < kDiasALaVista; i++) {
        ConrraFicha *f = [[ConrraFicha alloc] init];
        f.clave = [clave stringFromDate:dia];
        NSDateComponents *c = [cal components:(NSCalendarUnitWeekday | NSCalendarUnitDay) fromDate:dia];
        f.rotulo = (i == 0)
            ? [LanguageHelper getStringWithKey:@"k_s10_planes_hoy" defaultValue:@"HOY"]
            : [nombres objectAtIndex:(NSUInteger)c.weekday];
        f.numero = [NSString stringWithFormat:@"%ld", (long)c.day];
        [lista addObject:f];
        dia = [cal dateByAddingUnit:NSCalendarUnitDay value:1 toDate:dia options:0];
    }
    self.dias = lista;
}

- (void)ponerCiudad {
    NSString *nombre = [self nombreDeLaCiudad];
    self.lblCiudad.text = nombre ?: @"";
    self.lblCiudad.hidden = (nombre.length == 0);
}

/** El nombre de la ciudad del pasajero, o nil si no se sabe. */
- (NSString *)nombreDeLaCiudad {
    NSString *idCiudad = [self ciudadId];
    if (idCiudad.length == 0) {
        return nil;
    }
    // Sin lista de ciudades cargada se queda sin subtitulo. No es motivo para dejar de
    // enseñar los planes.
    @try {
        CityModel *ciudad = [CityModel getCityByCityId:[idCiudad intValue]];
        return ciudad.city_name;
    } @catch (NSException *e) {
        return nil;
    }
}

- (NSString *)ciudadId {
    NSDictionary *dict = defaults_object(P_USER_DICT);
    id valor = [dict objectForKey:@"city_id"];
    if ([valor isKindOfClass:[NSString class]]) {
        return (NSString *)valor;
    }
    if ([valor isKindOfClass:[NSNumber class]]) {
        return [(NSNumber *)valor stringValue];
    }
    return nil;
}

#pragma mark - Datos

- (void)pedirPlanes {
    [self.barra startAnimating];
    self.lblVacio.hidden = YES;

    ConrraFicha *dia = [self.dias objectAtIndex:(NSUInteger)self.diaElegido];
    __weak typeof(self) debil = self;
    [self.catalogo cargarConCiudad:[self ciudadId]
                               dia:dia.clave
                        alTerminar:^(NSArray<ConrraPlan *> *planes) {
        __strong typeof(debil) fuerte = debil;
        if (fuerte == nil) { return; }
        [fuerte.barra stopAnimating];
        [fuerte.recibidos removeAllObjects];
        [fuerte.recibidos addObjectsFromArray:planes];
        [fuerte repintar];
    }];
}

/** Aplica categoria y busqueda sobre lo ya recibido y pinta. */
- (void)repintar {
    NSString *buscado = [[self.txtBuscar.text stringByTrimmingCharactersInSet:
                          [NSCharacterSet whitespaceAndNewlineCharacterSet]] lowercaseString];
    NSString *categoria = [self.categorias objectAtIndex:(NSUInteger)self.categoriaElegida].clave;

    [self.visibles removeAllObjects];
    for (ConrraPlan *p in self.recibidos) {
        if (![categoria isEqualToString:@"todos"]
            && [p.categoria caseInsensitiveCompare:categoria] != NSOrderedSame) {
            continue;
        }
        if (buscado.length > 0 && [[p paraBuscar] rangeOfString:buscado].location == NSNotFound) {
            continue;
        }
        [self.visibles addObject:p];
    }

    [self.rejilla reloadData];

    if (self.visibles.count == 0) {
        // Se distingue "no hay nada este dia" de "tu filtro no deja pasar nada": con un
        // solo mensaje, quien escribio mal una palabra cree que la seccion esta vacia.
        BOOL filtrando = (buscado.length > 0) || ![categoria isEqualToString:@"todos"];
        self.lblVacio.text = filtrando
            ? [LanguageHelper getStringWithKey:@"k_s10_planes_sin_resultados"
                                  defaultValue:@"Ningún sitio coincide con lo que buscas."]
            : [LanguageHelper getStringWithKey:@"k_s10_planes_vacio"
                                  defaultValue:@"Todavía no hay sitios para este día. Prueba con otro día o con otra categoría."];
        self.lblVacio.hidden = NO;
    } else {
        self.lblVacio.hidden = YES;
    }
}

#pragma mark - Fichas

- (void)tocarCategoria:(UIButton *)boton {
    self.categoriaElegida = boton.tag;
    for (UIView *v in self.filaCategorias.subviews) {
        if ([v isKindOfClass:[UIButton class]]) {
            [self pintarFicha:(UIButton *)v elegida:(v.tag == boton.tag)];
        }
    }
    [self repintar];
}

- (void)tocarDia:(UIButton *)boton {
    self.diaElegido = boton.tag;
    for (UIView *v in self.filaDias.subviews) {
        if ([v isKindOfClass:[UIButton class]]) {
            [self pintarFicha:(UIButton *)v elegida:(v.tag == boton.tag)];
        }
    }
    // Cambiar de dia SI vuelve a preguntar al rele: la vigencia de cada campaña vive en el
    // servidor, y adivinarla aqui con las fechas de la ficha seria reimplementar esa regla
    // en el telefono.
    [self pedirPlanes];
}

#pragma mark - Rejilla

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return (NSInteger)self.visibles.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ConrraPlanCell *celda = [collectionView dequeueReusableCellWithReuseIdentifier:@"plan"
                                                                     forIndexPath:indexPath];
    ConrraPlan *p = [self.visibles objectAtIndex:(NSUInteger)indexPath.item];
    celda.plan = p;

    celda.etiqueta.text = p.etiqueta.length > 0
        ? [NSString stringWithFormat:@"  %@  ", p.etiqueta]
        : [NSString stringWithFormat:@"  %@  ", [p.categoria uppercaseString]];
    celda.titulo.text = p.titulo;
    celda.sitio.text  = p.sitio.length > 0 ? p.sitio : p.cliente;

    celda.detalle.text = p.detalle;
    celda.detalle.hidden = (p.detalle.length == 0);

    // Horario y disponibilidad ocupan la misma linea: en una ficha de media pantalla no
    // caben dos, y por separado cada una se quedaba en una linea casi vacia.
    NSString *pie = [PlanesViewController unir:p.horario con:p.nota];
    celda.pie.text = pie;
    celda.pie.hidden = (pie.length == 0);

    // SDWebImage ya cancela la peticion anterior al reutilizar la celda (ver
    // prepareForReuse), asi que no hace falta el truco del tag que usa Android con Volley.
    // Foto rota o sin red: la ficha se queda con el hueco gris y el resto de la oferta se
    // lee igual. Esconderla entera seria perder el plan por una imagen.
    [celda.foto sd_setImageWithURL:[NSURL URLWithString:p.imagen] placeholderImage:nil];

    [celda setNeedsLayout];
    return celda;
}

/**
 La vista se cuenta AQUI y no al construir la celda.

 UICollectionView prepara celdas por delante del borde de la pantalla para que el
 desplazamiento no se atasque. Contarlas al construirlas seria cobrarle al anunciante por
 fichas que nadie llego a ver. willDisplayCell es el momento honesto: la celda esta a punto
 de entrar en pantalla. El reparto de una sola vez por plan lo lleva ConrraCatalogoDePlanes.
 */
- (void)collectionView:(UICollectionView *)collectionView
       willDisplayCell:(UICollectionViewCell *)cell
    forItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.item < (NSInteger)self.visibles.count) {
        [self.catalogo alAsomarse:[self.visibles objectAtIndex:(NSUInteger)indexPath.item]];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat ancho = collectionView.bounds.size.width - 32;
    ConrraPlan *p = [self.visibles objectAtIndex:(NSUInteger)indexPath.item];
    // Los premium ocupan las dos columnas. Sin esto se les da media fila igual que a los
    // demas y el sitio de arriba deja de notarse.
    if ([p esPremium]) {
        return CGSizeMake(ancho, roundf(ancho * 0.52f) + 128);
    }
    CGFloat anchoCelda = floorf((ancho - 12 * (kColumnas - 1)) / kColumnas);
    return CGSizeMake(anchoCelda, roundf(anchoCelda * 0.52f) + 128);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self irAlPlan:[self.visibles objectAtIndex:(NSUInteger)indexPath.item]];
}

#pragma mark - El boton IR

/**
 Deja este sitio puesto como destino y vuelve a la pantalla de pedir viaje.

 El destino viaja por ConrraDestinoDePlan y no por una propiedad porque UHomeViewController
 casi siempre ya existe en la pila: al desapilar no pasa por viewDidLoad. Ver la nota de esa
 clase.
 */
- (void)irAlPlan:(ConrraPlan *)plan {
    if (plan == nil) {
        return;
    }
    [self.catalogo alPulsarIr:plan];
    [ConrraDestinoDePlan dejarSitio:[plan destinoLegible] lat:plan.lat lng:plan.lng];

    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)volver {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Teclado

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Utilidades

+ (NSString *)unir:(NSString *)a con:(NSString *)b {
    NSCharacterSet *blancos = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *ta = [a stringByTrimmingCharactersInSet:blancos] ?: @"";
    NSString *tb = [b stringByTrimmingCharactersInSet:blancos] ?: @"";
    if (ta.length > 0 && tb.length > 0) {
        return [NSString stringWithFormat:@"%@ · %@", ta, tb];
    }
    if (ta.length > 0) { return ta; }
    return tb;
}

@end
