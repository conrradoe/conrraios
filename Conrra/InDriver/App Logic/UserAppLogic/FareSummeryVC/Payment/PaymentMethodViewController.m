//
//  PaymentMethodViewController.m
//  Conrra
//
//  Shows Efectivo / Pago Móvil / Mi Billetera based on cityModel.city_pay_options.
//
//  Icon assets needed in Assets.xcassets:
//    pm_icon_cash    — Efectivo (green cash illustration, ~96×96px @2x)
//    pm_icon_mobile  — Pago Móvil (blue mobile payment illustration, ~96×96px @2x)
//    pm_icon_wallet  — Mi Billetera (yellow wallet illustration, ~96×96px @2x)
//

#import "PaymentMethodViewController.h"
#import "WebCallConstants.h"
#import "LanguageHelper.h"
#import "Utilities.h"

@interface PMRow : NSObject
@property (strong) NSString *title;
@property (strong) NSString *subtitle;
@property (strong) NSString *iconName;  // asset name
@property (assign) int       mode;      // 0=Cash, 1=Wallet, 2=PagoMóvil
@property (assign) BOOL      isDefault;
+ (instancetype)title:(NSString *)t subtitle:(NSString *)s icon:(NSString *)icon mode:(int)m;
@end
@implementation PMRow
+ (instancetype)title:(NSString *)t subtitle:(NSString *)s icon:(NSString *)icon mode:(int)m {
    PMRow *r = [PMRow new];
    r.title = t; r.subtitle = s; r.iconName = icon; r.mode = m;
    return r;
}
@end

@interface PMRowCell : UITableViewCell
@property (strong) UIImageView *iconView;
@property (strong) UILabel     *titleLabel;
@property (strong) UILabel     *subtitleLabel;
@property (strong) UIView      *defaultPill;
@property (strong) UILabel     *defaultPillLabel;
@property (strong) UIImageView *checkmark;
- (void)configureWith:(PMRow *)row selected:(BOOL)selected;
@end

@implementation PMRowCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) [self buildUI];
    return self;
}

- (void)buildUI {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = UIColor.whiteColor;

    // Icon — no background, just the image
    _iconView = [[UIImageView alloc] init];
    _iconView.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:_iconView];

    // Title
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.font = [UIFont fontWithName:@"NotoSans-Bold" size:16] ?: [UIFont boldSystemFontOfSize:16];
    _titleLabel.textColor = [UIColor colorWithRed:0.094f green:0.094f blue:0.094f alpha:1.0f];
    [self.contentView addSubview:_titleLabel];

    // Subtitle
    _subtitleLabel = [[UILabel alloc] init];
    _subtitleLabel.font = [UIFont fontWithName:@"NotoSans-Regular" size:13] ?: [UIFont systemFontOfSize:13];
    _subtitleLabel.textColor = [UIColor colorWithRed:0.53f green:0.53f blue:0.53f alpha:1.0f];
    [self.contentView addSubview:_subtitleLabel];

    // Default pill
    _defaultPill = [[UIView alloc] init];
    _defaultPill.backgroundColor = [UIColor colorWithRed:0.91f green:0.91f blue:0.91f alpha:1.0f];
    _defaultPill.layer.cornerRadius = 8;
    _defaultPill.hidden = YES;
    [self.contentView addSubview:_defaultPill];

    _defaultPillLabel = [[UILabel alloc] init];
    _defaultPillLabel.font = [UIFont fontWithName:@"NotoSans-Regular" size:12] ?: [UIFont systemFontOfSize:12];
    _defaultPillLabel.textColor = [UIColor colorWithRed:0.3f green:0.3f blue:0.3f alpha:1.0f];
    _defaultPillLabel.text = @"🔒 Default";
    [_defaultPill addSubview:_defaultPillLabel];

    // Checkmark
    _checkmark = [[UIImageView alloc] init];
    _checkmark.contentMode = UIViewContentModeScaleAspectFit;
    if (@available(iOS 13.0, *)) {
        _checkmark.image = [UIImage systemImageNamed:@"checkmark"];
        _checkmark.tintColor = [UIColor colorNamed:@"app_theame"] ?: [UIColor colorWithRed:0.922f green:0.710f blue:0.094f alpha:1.0f];
    } else {
        _checkmark.image = [UIImage imageNamed:@"radio-selected"];
    }
    _checkmark.hidden = YES;
    [self.contentView addSubview:_checkmark];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat w   = self.contentView.bounds.size.width;
    CGFloat rowH = self.contentView.bounds.size.height;
    CGFloat iconSize = 38; // 20% smaller than original 48pt

    // Icon: left-aligned, vertically centered, no background
    _iconView.frame = CGRectMake(20, (rowH - iconSize) / 2, iconSize, iconSize);

    // Checkmark: right side
    CGFloat ckSize = 22;
    CGFloat ckX = w - 20 - ckSize;
    _checkmark.frame = CGRectMake(ckX, (rowH - ckSize) / 2, ckSize, ckSize);

    // Default pill: just left of checkmark
    [_defaultPillLabel sizeToFit];
    CGFloat pillW = _defaultPillLabel.frame.size.width + 16;
    CGFloat pillH = 24;
    CGFloat pillX = _defaultPill.hidden ? ckX : ckX - pillW - 8;
    _defaultPill.frame = CGRectMake(pillX, (rowH - pillH) / 2, pillW, pillH);
    _defaultPillLabel.frame = CGRectMake(8, (pillH - _defaultPillLabel.frame.size.height) / 2,
                                         _defaultPillLabel.frame.size.width,
                                         _defaultPillLabel.frame.size.height);

    // Text between icon and right elements (20 left + 38 icon + 16 gap = 74)
    CGFloat textX      = 74;
    CGFloat rightBound = _defaultPill.hidden ? ckX - 8 : pillX - 8;
    CGFloat textW      = rightBound - textX;

    _titleLabel.frame    = CGRectMake(textX, (rowH / 2) - 22, textW, 22);
    _subtitleLabel.frame = CGRectMake(textX, (rowH / 2) + 2,  textW, 18);
}

- (void)configureWith:(PMRow *)row selected:(BOOL)selected {
    _iconView.image     = [UIImage imageNamed:row.iconName];
    _titleLabel.text    = row.title;
    _subtitleLabel.text = row.subtitle;
    _defaultPill.hidden = !row.isDefault;
    _checkmark.hidden   = !selected;
    [self setNeedsLayout];
}

@end

@interface PaymentMethodViewController () <UITableViewDataSource, UITableViewDelegate>
{
    UITableView    *_tableView;
    NSMutableArray *_rows;      // PMRow objects
    int             _selected;  // current selected mode
}
@end

@implementation PaymentMethodViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _selected = self.selectedMode;
    [self buildRows];
    [self buildUI];
}


- (void)buildRows {
    _rows = [NSMutableArray array];

    NSMutableArray *options = [NSMutableArray array];
    if (self.cityModel && self.cityModel.city_pay_options.length > 0) {
        [options addObjectsFromArray:[self.cityModel.city_pay_options componentsSeparatedByString:@"|"]];
    } else {
        [options addObjectsFromArray:@[@"cash", @"stripe", @"wallet"]];
    }

    NSDictionary *userDict    = [[NSUserDefaults standardUserDefaults] objectForKey:P_USER_DICT];
    NSString     *defaultMode = [userDict objectForKey:P_USER_DEFAULT_PAY_MODE] ?: @"";

    float balance = self.walletBalance;
    if (balance == 0) {
        NSDictionary *d = [[NSUserDefaults standardUserDefaults] objectForKey:P_USER_DICT];
        balance = [[d objectForKey:P_USER_WAlLET_AMOUNT] floatValue];
    }
    NSString *balanceStr = [NSString stringWithFormat:[LanguageHelper getStringWithKey:@"k_s10_balance_format" defaultValue:@"Saldo: $%.2f"], balance];

    for (NSString *opt in options) {
        if ([opt isEqualToString:@"cash"]) {
            PMRow *r = [PMRow title:[LanguageHelper getStringWithKey:@"k_r39_s9_cash" defaultValue:@"Efectivo"]
                          subtitle:[LanguageHelper getStringWithKey:@"k_s10_pay_bs_usd" defaultValue:@"Paga en Bs. o USD"]
                              icon:@"pm_icon_cash"
                              mode:0];
            r.isDefault = [defaultMode isEqualToString:CASH_PAY] || [defaultMode isEqualToString:@"cash"];
            [_rows addObject:r];
        } else if ([opt isEqualToString:@"stripe"]) {
            PMRow *r = [PMRow title:[LanguageHelper getStringWithKey:@"k_s10_mobile_payment" defaultValue:@"Pago Móvil"]
                          subtitle:[LanguageHelper getStringWithKey:@"k_s10_transfer_and_report" defaultValue:@"Transfiere y reporta tu pago"]
                              icon:@"pm_icon_mobile"
                              mode:2];
            r.isDefault = [defaultMode isEqualToString:CARD] || [defaultMode isEqualToString:@"card"];
            [_rows addObject:r];
        } else if ([opt isEqualToString:@"wallet"]) {
            PMRow *r = [PMRow title:[LanguageHelper getStringWithKey:@"k_s10_my_wallet" defaultValue:@"Mi Billetera"]
                          subtitle:balanceStr
                              icon:@"pm_icon_wallet"
                              mode:1];
            r.isDefault = [defaultMode isEqualToString:HIRE_ME_WALLET_PAY] || [defaultMode isEqualToString:@"wallet"];
            [_rows addObject:r];
        }
    }

    if (_selected == -1 && _rows.count > 0) {
        _selected = ((PMRow *)_rows[0]).mode;
    }
    // First row always shows the Default tag (Efectivo is the app default)
    if (_rows.count > 0) {
        ((PMRow *)_rows[0]).isDefault = YES;
    }
}


- (void)buildUI {
    self.view.backgroundColor = UIColor.whiteColor;

    // Title label
    UILabel *titleLbl = [[UILabel alloc] init];
    titleLbl.text = [LanguageHelper getStringWithKey:@"k_s10_payment_methods" defaultValue:@"Métodos de pago"];
    titleLbl.font = [UIFont fontWithName:@"NotoSans-Bold" size:18] ?: [UIFont boldSystemFontOfSize:18];
    titleLbl.textColor = [UIColor colorWithRed:0.094f green:0.094f blue:0.094f alpha:1.0f];
    titleLbl.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:titleLbl];

    // Close button
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    if (@available(iOS 13.0, *)) {
        [closeBtn setImage:[UIImage systemImageNamed:@"xmark"] forState:UIControlStateNormal];
    } else {
        [closeBtn setTitle:@"✕" forState:UIControlStateNormal];
        closeBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    }
    closeBtn.tintColor = [UIColor colorWithRed:0.094f green:0.094f blue:0.094f alpha:1.0f];
    [closeBtn addTarget:self action:@selector(onClose) forControlEvents:UIControlEventTouchUpInside];
    closeBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:closeBtn];

    [NSLayoutConstraint activateConstraints:@[
        [closeBtn.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:16],
        [closeBtn.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
        [closeBtn.widthAnchor constraintEqualToConstant:36],
        [closeBtn.heightAnchor constraintEqualToConstant:36],
        [titleLbl.centerYAnchor constraintEqualToAnchor:closeBtn.centerYAnchor],
        [titleLbl.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
    ]];

    // TableView
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.dataSource      = self;
    _tableView.delegate        = self;
    _tableView.separatorStyle  = UITableViewCellSeparatorStyleSingleLine;
    _tableView.separatorInset  = UIEdgeInsetsMake(0, 84, 0, 0);
    _tableView.separatorColor  = [UIColor colorWithRed:0.9f green:0.9f blue:0.9f alpha:1.0f];
    _tableView.tableFooterView = [[UIView alloc] init];
    _tableView.scrollEnabled   = NO;
    _tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [_tableView registerClass:[PMRowCell class] forCellReuseIdentifier:@"PMRowCell"];
    [self.view addSubview:_tableView];

    [NSLayoutConstraint activateConstraints:@[
        [_tableView.topAnchor constraintEqualToAnchor:closeBtn.bottomAnchor constant:16],
        [_tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [_tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [_tableView.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor],
    ]];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _rows.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PMRowCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PMRowCell" forIndexPath:indexPath];
    PMRow     *row  = _rows[indexPath.row];
    [cell configureWith:row selected:(row.mode == _selected)];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    PMRow *row = _rows[indexPath.row];

    // Billetera sin saldo bastante: no se elige, y se ofrece salida.
    if (row.mode == 1) {
        float fare = self.tripFare;
        if (fare > 0 && [self saldoDeLaBilletera] < fare) {
            [self avisarSaldoInsuficienteParaTarifa:fare];
            return;
        }
    }

    // Efectivo: se piden el billete y el vuelto ANTES de dar por elegido el metodo.
    // El conductor rara vez lleva cambio de un billete grande, y enterarse al llegar
    // es justo cuando ya no tiene arreglo.
    if (row.mode == 0) {
        [self pedirDetallesDelEfectivoYLuego:^{
            [self elegirFila:row enTabla:tableView];
        }];
        return;
    }

    // Pago Movil: primero se cuenta como funciona, porque no se cobra dentro del app.
    if (row.mode == 2) {
        [self explicarPagoMovilYLuego:^{
            [self elegirFila:row enTabla:tableView];
        }];
        return;
    }

    [self elegirFila:row enTabla:tableView];
}

/**
 El billete con el que se paga y el vuelto que hace falta.

 Android lo exige no vacio (showCashDetailsDialog: "Por favor ingrese los detalles del
 billete y vuelto"). Aqui se deja seguir sin escribir nada -- el boton de omitir --
 porque hay quien paga justo y no tiene nada que pedir; obligar a escribir algo solo
 conseguiria que pusieran un punto.
 */
- (void)pedirDetallesDelEfectivoYLuego:(void (^)(void))despues {
    UIAlertController *cuadro = [UIAlertController
        alertControllerWithTitle:[LanguageHelper getStringWithKey:@"k_s10_detalle_efectivo"
                                                     defaultValue:@"Monto del billete e instrucciones del vuelto"]
        message:nil
        preferredStyle:UIAlertControllerStyleAlert];

    [cuadro addTextFieldWithConfigurationHandler:^(UITextField *campo) {
        campo.placeholder = [LanguageHelper getStringWithKey:@"k_s10_detalle_efectivo_ejemplo"
                                               defaultValue:@"Ej: Pago con $20, necesito vuelto en Bs."];
        campo.autocapitalizationType = UITextAutocapitalizationTypeSentences;
        campo.text = self.instruccionesDeEfectivo ?: @"";
    }];

    __weak typeof(self) debil = self;
    [cuadro addAction:[UIAlertAction
        actionWithTitle:[LanguageHelper getStringWithKey:@"k_18_s4_Ok" defaultValue:@"Aceptar"]
        style:UIAlertActionStyleDefault
        handler:^(UIAlertAction *accion) {
            __strong typeof(debil) fuerte = debil;
            if (fuerte == nil) {
                return;
            }
            NSString *texto = [cuadro.textFields.firstObject.text
                stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            fuerte.instruccionesDeEfectivo = texto.length > 0 ? texto : nil;
            if ([fuerte.delegate respondsToSelector:@selector(paymentSheet:instruccionesDeEfectivo:)]) {
                [fuerte.delegate paymentSheet:fuerte instruccionesDeEfectivo:fuerte.instruccionesDeEfectivo];
            }
            if (despues) {
                despues();
            }
        }]];

    [cuadro addAction:[UIAlertAction
        actionWithTitle:[LanguageHelper getStringWithKey:@"k_30_s6_cancel_j" defaultValue:@"Cancelar"]
        style:UIAlertActionStyleCancel
        handler:nil]];

    [self presentViewController:cuadro animated:YES completion:nil];
}

- (void)elegirFila:(PMRow *)row enTabla:(UITableView *)tableView {
    // Cambiar a otro metodo borra lo que se hubiera escrito del efectivo: si no, un
    // pasajero que se pasa a billetera seguiria mandandole al conductor instrucciones
    // de vuelto que ya no vienen a cuento.
    if (row.mode != 0 && self.instruccionesDeEfectivo != nil) {
        self.instruccionesDeEfectivo = nil;
        if ([self.delegate respondsToSelector:@selector(paymentSheet:instruccionesDeEfectivo:)]) {
            [self.delegate paymentSheet:self instruccionesDeEfectivo:nil];
        }
    }

    _selected = row.mode;
    [tableView reloadData];

    if (self.delegate) {
        [self.delegate paymentSheet:self didSelectMode:_selected];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (float)saldoDeLaBilletera {
    float balance = self.walletBalance;
    if (balance == 0) {
        NSDictionary *d = [[NSUserDefaults standardUserDefaults] objectForKey:P_USER_DICT];
        balance = [[d objectForKey:P_USER_WAlLET_AMOUNT] floatValue];
    }
    return balance;
}

/**
 Que hacer cuando la billetera no llega.

 Aqui habia un aviso con un solo boton de OK: el pasajero se enteraba de que no puede
 pagar y se quedaba igual, sin manera de arreglarlo desde el app. Android ofrece las
 dos salidas que de verdad existen -- recargar o pagar de otra forma -- y son las que
 se ponen.

 Recargar sale del app hacia la pagina de recargas, asi que la hoja se cierra antes:
 quien la abrio es el que tiene navegacion para empujar la pagina.
 */
- (void)avisarSaldoInsuficienteParaTarifa:(float)tarifa {
    NSString *msg = [NSString stringWithFormat:
        [LanguageHelper getStringWithKey:@"k_s10_saldo_insuficiente"
                            defaultValue:@"Tu saldo es insuficiente para pagar esta carrera ($%.2f). ¿Deseas recargar?"],
        tarifa];

    UIAlertController *alert = [UIAlertController
        alertControllerWithTitle:[LanguageHelper getStringWithKey:@"k_33_s7_alert" defaultValue:@"Alerta"]
        message:msg
        preferredStyle:UIAlertControllerStyleAlert];

    __weak typeof(self) debil = self;
    [alert addAction:[UIAlertAction
        actionWithTitle:[LanguageHelper getStringWithKey:@"k_s10_recargar" defaultValue:@"Recargar"]
        style:UIAlertActionStyleDefault
        handler:^(UIAlertAction *accion) {
            __strong typeof(debil) fuerte = debil;
            if (fuerte == nil) {
                return;
            }
            id<PaymentMethodViewControllerDelegate> delegado = fuerte.delegate;
            [fuerte dismissViewControllerAnimated:YES completion:^{
                if ([delegado respondsToSelector:@selector(paymentSheetDidRequestWalletTopUp:)]) {
                    [delegado paymentSheetDidRequestWalletTopUp:fuerte];
                }
            }];
        }]];

    // Cambiar de metodo es justamente quedarse aqui: esta pantalla ES la lista.
    [alert addAction:[UIAlertAction
        actionWithTitle:[LanguageHelper getStringWithKey:@"k_s10_cambiar_metodo_pago"
                                            defaultValue:@"Cambiar método de pago"]
        style:UIAlertActionStyleCancel
        handler:nil]];

    [self presentViewController:alert animated:YES completion:nil];
}

/**
 El aviso de Pago Movil, con el texto de Android (dialog_pago_movil_info).

 Hace falta porque Pago Movil no cobra nada dentro del app: el pasajero transfiere por
 su cuenta cuando el conductor acepte, y despues reporta. Sin decirlo, elegir este
 metodo parece dejar el viaje pagado.
 */
- (void)explicarPagoMovilYLuego:(void (^)(void))despues {
    UIAlertController *hoja = [UIAlertController
        alertControllerWithTitle:[LanguageHelper getStringWithKey:@"k_s10_info_pago_movil"
                                                     defaultValue:@"Información de Pago Móvil"]
        message:[LanguageHelper getStringWithKey:@"k_s10_info_pago_movil_texto"
                                    defaultValue:@"Al ser aceptado tu viaje, verás aquí los datos bancarios del conductor para realizar la transferencia.\n\nRecuerda que debes reportar tu pago al finalizar el recorrido."]
        preferredStyle:UIAlertControllerStyleAlert];

    [hoja addAction:[UIAlertAction
        actionWithTitle:[LanguageHelper getStringWithKey:@"k_s10_entendido" defaultValue:@"Entendido"]
        style:UIAlertActionStyleDefault
        handler:^(UIAlertAction *accion) {
            if (despues) {
                despues();
            }
        }]];

    [self presentViewController:hoja animated:YES completion:nil];
}


- (void)onClose {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
