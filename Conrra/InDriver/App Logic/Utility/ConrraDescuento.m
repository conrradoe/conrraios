//
//  ConrraDescuento.m
//  Conrra
//

#import "ConrraDescuento.h"
#import "TripModel.h"
#import "CityModel.h"
#import "Utilities.h"

/// Tope de cordura para la tasa deducida. Una tasa de impuesto del 100% o mas no existe; si
/// sale eso, los datos del viaje son incoherentes -- hay viajes viejos donde trip_pay_amount
/// no cuadra con trip_base_fare -- y es mejor dar tasa 0 que inventarse un original
/// disparatado.
static const float kTasaMaxima = 1.0f;

/// Gris del original tachado.
#define CONRRA_GRIS_TACHADO [UIColor colorWithRed:0x8A/255.0 green:0x8A/255.0 blue:0x8E/255.0 alpha:1]

@interface ConrraDescuento ()
@property (nonatomic, assign) BOOL hay;
@property (nonatomic, assign) float paga;
@property (nonatomic, assign) float ahorro;
@property (nonatomic, assign) float original;
@property (nonatomic, copy)   NSString *moneda;
@end

@implementation ConrraDescuento

#pragma mark - La aritmetica

+ (float)numero:(NSString *)crudo {
    if (![crudo isKindOfClass:[NSString class]]) {
        // Un NSNumber tambien vale: algunos campos llegan ya convertidos.
        if ([crudo isKindOfClass:[NSNumber class]]) {
            return [(NSNumber *)crudo floatValue];
        }
        return 0;
    }
    NSString *t = [crudo stringByTrimmingCharactersInSet:
                   [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (t.length == 0 || [t caseInsensitiveCompare:@"null"] == NSOrderedSame) {
        return 0;
    }
    float v = [t floatValue];
    return (isnan(v) || isinf(v)) ? 0 : v;
}

+ (BOOL)hayDescuento:(float)promo {
    return promo > 0;
}

+ (float)tasaImpuesto:(float)impuestoCobrado base:(float)baseDescontada {
    if (baseDescontada <= 0 || impuestoCobrado <= 0) {
        return 0;
    }
    float tasa = impuestoCobrado / baseDescontada;
    if (isnan(tasa) || isinf(tasa) || tasa >= kTasaMaxima) {
        return 0;
    }
    return tasa;
}

+ (float)ahorroDePromo:(float)promo base:(float)baseDescontada impuesto:(float)impuestoCobrado {
    if (![self hayDescuento:promo]) {
        return 0;
    }
    return promo * (1 + [self tasaImpuesto:impuestoCobrado base:baseDescontada]);
}

#pragma mark - Leer el viaje

+ (instancetype)deViaje:(TripModel *)viaje {
    ConrraDescuento *d = [[ConrraDescuento alloc] init];
    d.moneda = @"";
    if (viaje == nil) {
        return d;
    }

    float promo     = [self numero:viaje.trip_promo_amt];
    /*
     trip_fare ES trip_pay_amount: TripModel.m lo asigna asi al leer el viaje, y el servidor
     lo guarda YA con el descuento aplicado. Ese detalle es el que se escapaba: restarle el
     promo encima descuenta dos veces.
     */
    float paga      = [self numero:viaje.trip_fare];
    float base      = [self numero:viaje.trip_base_fare];
    float impuesto  = [self numero:viaje.tax_amount];

    d.hay      = [self hayDescuento:promo];
    d.paga     = paga;
    d.ahorro   = [self ahorroDePromo:promo base:base impuesto:impuesto];
    /*
     El original se ancla en lo que PAGA, no en la base guardada. `paga` es el numero que se
     cobra y el que aparece al lado en la pantalla, asi que de esta forma los tres importes
     siempre restan bien. Reconstruirlo desde trip_base_fare daria, en los viajes viejos
     donde los campos no cuadran entre si, un original que no casa con el total.
     */
    d.original = paga + d.ahorro;

    CityModel *ciudad = [CityModel getCityByCityId:viaje.city_id];
    NSString *cur = ciudad.city_cur;
    d.moneda = [cur isKindOfClass:[NSString class]] ? cur : @"";
    return d;
}

#pragma mark - Pintar

- (NSAttributedString *)comoTexto {
    NSString *moneda = self.moneda;
    return [self comoTextoFormateandoCon:^NSString *(float importe) {
        NSString *t = [Utilities formatAmountAndCurrency:importe currency:moneda];
        return t.length > 0 ? t : [NSString stringWithFormat:@"%.2f", importe];
    }];
}

- (NSAttributedString *)comoTextoFormateandoCon:(NSString * (^)(float))formato {
    NSString *loQuePaga = formato ? formato(self.paga) : [NSString stringWithFormat:@"%.2f", self.paga];
    if (loQuePaga == nil) {
        loQuePaga = @"";
    }
    if (!self.hay) {
        return [[NSAttributedString alloc] initWithString:loQuePaga];
    }
    NSString *loOriginal = formato ? formato(self.original) : [NSString stringWithFormat:@"%.2f", self.original];
    if (loOriginal.length == 0) {
        return [[NSAttributedString alloc] initWithString:loQuePaga];
    }

    NSMutableAttributedString *sb = [[NSMutableAttributedString alloc] initWithString:loOriginal];
    NSRange r = NSMakeRange(0, loOriginal.length);
    [sb addAttributes:@{
        NSStrikethroughStyleAttributeName : @(NSUnderlineStyleSingle),
        NSForegroundColorAttributeName    : CONRRA_GRIS_TACHADO,
    } range:r];
    [sb appendAttributedString:[[NSAttributedString alloc] initWithString:@"  "]];
    [sb appendAttributedString:[[NSAttributedString alloc] initWithString:loQuePaga]];
    return sb;
}

+ (void)pintarEn:(UILabel *)label viaje:(TripModel *)viaje {
    if (label == nil) {
        return;
    }
    ConrraDescuento *d = [self deViaje:viaje];
    if (!d.hay) {
        // Sin descuento se deja el texto llano: asi el label conserva su fuente y su color,
        // que es lo que ya tenia puesto la pantalla.
        NSString *t = [Utilities formatAmountAndCurrency:d.paga currency:d.moneda];
        label.text = t.length > 0 ? t : [NSString stringWithFormat:@"%.2f", d.paga];
        return;
    }
    /*
     Con descuento se usa texto atribuido, y el tachado hereda la fuente del label porque el
     NSAttributedString no la fija: solo pone el tachado, el gris y el espacio. Asi una
     pantalla con fuente propia -- y hay varias -- no se descoloca.
     */
    label.attributedText = [d comoTexto];
}

@end
