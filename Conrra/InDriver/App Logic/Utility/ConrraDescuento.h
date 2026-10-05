//
//  ConrraDescuento.h
//  Conrra
//
//  Equivalente de com.conrra.merged.common.Descuento y DescuentoCalculo (Android).
//

#import <UIKit/UIKit.h>

@class TripModel;

NS_ASSUME_NONNULL_BEGIN

/**
 El descuento de un viaje, listo para pintar.

 Existe para que las diez pantallas que enseñan un importe den TODAS el mismo numero. Hoy no
 lo dan: tripHistoryCell restaba el promo a trip_fare, y trip_fare ya ES trip_pay_amount, que
 el servidor guarda CON el descuento aplicado -- o sea que esa celda descontaba dos veces y
 enseñaba menos de lo que el pasajero pago.

 Quien absorbe el descuento es la plataforma, no el conductor: al conductor se le dice que el
 viaje es promocional, y los dos importes se enseñan igual en las dos aplicaciones.

 ======================= DE DONDE SALE CADA NUMERO =======================
 El backend (model/TripModel.php, calculateTripFareVer1) hace esto:

     baseAntesDeImpuesto = tarifa / (1 + impuesto/100)
     promo               = descuento, calculado sobre esa base
     baseDescontada      = baseAntesDeImpuesto - promo
     impuestoCobrado     = baseDescontada * impuesto/100      <- SOBRE LA DESCONTADA
     aPagar              = baseDescontada + impuestoCobrado + peajes

 y guarda:  trip_base_fare = baseDescontada,  tax_amt = impuestoCobrado,
 trip_promo_amt = promo,  trip_pay_amount = aPagar.

 Sin descuento, con la MISMA formula, habria pagado:

     aPagarSinPromo = baseAntesDeImpuesto * (1 + impuesto/100) + peajes

 Restando las dos:   aPagarSinPromo - aPagar = promo * (1 + impuesto/100).

 O sea: el descuento tambien ahorra el impuesto de ese tramo. Por eso el ahorro que se enseña
 NO es `trip_promo_amt` a secas, sino `promo * (1 + tasa)`. Asi, en pantalla,
 original - ahorro = pagas SIEMPRE, exacto. Pintar el promo crudo daria tres numeros que no
 restan, y eso en una pantalla de dinero se ve a la primera.

 Hoy todas las ciudades tienen impuesto 0, asi que la tasa sale 0 y el ahorro coincide con el
 promo. Pero hay viajes con tax_amt distinto de cero: el impuesto NO siempre fue 0, y un
 viaje viejo tiene que seguir cuadrando.
 =========================================================================

 La tasa se saca del viaje mismo (impuesto cobrado / base descontada) y no de la ciudad: asi
 un viaje de cuando la ciudad tenia otro impuesto sigue dando su numero.
 */
@interface ConrraDescuento : NSObject

/** ¿Lleva descuento? Un promo de 0 o negativo no lo es. */
@property (nonatomic, readonly) BOOL hay;
/** Lo que se paga: trip_pay_amount tal cual lo guardo el servidor. */
@property (nonatomic, readonly) float paga;
/** Lo que se ahorra de verdad: promo mas el impuesto que no paga. */
@property (nonatomic, readonly) float ahorro;
/** Lo que habria pagado sin descuento: paga + ahorro. */
@property (nonatomic, readonly) float original;
/** La moneda de la ciudad del viaje, para los textos. */
@property (nonatomic, readonly, copy) NSString *moneda;

+ (instancetype)deViaje:(nullable TripModel *)viaje;

/**
 "6,40  5,40" con el primero tachado y en gris, o solo "5,40" si no hay descuento.

 Los dos importes en el MISMO label a proposito: asi cualquier pantalla enseña los dos sin
 tocar su diseño.
 */
- (NSAttributedString *)comoTexto;

/**
 Igual, pero formateando los importes con el bloque que le pase la pantalla.

 Hace falta porque tres pantallas no formatean como las demas: el recibo del pasajero y el
 del conductor enseñan dolares Y bolivares, y el panel en viaje monta un texto atribuido de
 dos lineas. Imponerles el formato de aqui les quitaria los bolivares.
 */
- (NSAttributedString *)comoTextoFormateandoCon:(NSString * (^)(float importe))formato;

/** El importe en el label, tachando el original si el viaje lleva descuento. */
+ (void)pintarEn:(nullable UILabel *)label viaje:(nullable TripModel *)viaje;

#pragma mark - La aritmetica, suelta y comprobable

/** Lo que venga del backend a numero: manda importes como cadena, y a veces "null". */
+ (float)numero:(nullable NSString *)crudo;
/** ¿Hay descuento? */
+ (BOOL)hayDescuento:(float)promo;
/** La tasa de impuesto de ESTE viaje, deducida de sus propios numeros. 0 si no se puede. */
+ (float)tasaImpuesto:(float)impuestoCobrado base:(float)baseDescontada;
/** promo * (1 + tasa). */
+ (float)ahorroDePromo:(float)promo base:(float)baseDescontada impuesto:(float)impuestoCobrado;

@end

NS_ASSUME_NONNULL_END
