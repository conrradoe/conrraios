//
//  ConrraCarruselBanners.h
//  Conrra
//
//  Carrusel de publicidad para la espera de "Buscando Conductor".
//  Equivalente de com.conrra.riderapp.banners.CarruselBanners (Android).
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/** Un anuncio del catalogo. */
@interface ConrraBanner : NSObject

@property (nonatomic, copy, readonly) NSString *identificador;
@property (nonatomic, copy, readonly) NSString *titulo;
@property (nonatomic, copy, readonly) NSString *imagen;
@property (nonatomic, copy, readonly) NSString *url;
@property (nonatomic, copy, readonly) NSString *plan;

/** Un banner sin URL se ve pero no lleva a ningun sitio. */
- (BOOL)esPulsable;

@end


@protocol ConrraCarruselBannersDelegate <NSObject>

/** Toca pintar este. Llega siempre en el hilo principal. */
- (void)carruselAlMostrarBanner:(ConrraBanner *)banner NS_SWIFT_NAME(carruselAlMostrar(banner:));

/** No hay nada que enseñar: esconde el hueco. */
- (void)carruselAlQuedarSinBanners NS_SWIFT_NAME(carruselAlQuedarSinBanners());

@end


/**
 Carrusel de publicidad para la espera de "Buscando Conductor".

 El orden NO se decide aqui. Llega ya resuelto desde el rele: premium delante, basicos
 detras, y sorteado dentro de cada grupo. Ponerlo en el telefono habria significado que
 cambiar quien sale primero exige publicar una version nueva en la App Store, y que cada
 build viejo siguiera repartiendo con las reglas del mes pasado.

 SOBRE LAS IMPRESIONES. Se cuenta UNA por banner y por espera, no una por vuelta del
 carrusel: si un pasajero espera cuatro minutos, el mismo banner pasa varias veces y
 contarlas todas inflaria el numero que se le factura al anunciante.

 Todo falla hacia no molestar: si el rele no responde, si la lista viene vacia o si una
 imagen no carga, el hueco simplemente no aparece y la pantalla queda como estaba.

 El rele de publicidad NO va cifrado, a diferencia del resto de la API: lo que devuelve es
 publicidad, o sea justo lo que queremos que vea todo el mundo. Por eso aqui se usa
 NSURLSession directamente y no GIKit.
 */
@interface ConrraCarruselBanners : NSObject

- (instancetype)initConDelegado:(id<ConrraCarruselBannersDelegate>)delegado NS_SWIFT_NAME(init(delegado:));

/**
 Pide el catalogo y arranca la rotacion en cuanto llegue.

 @param ciudadId city_id del pasajero, o nil. Sirve para campañas de una sola ciudad; si
                 va nil el rele no filtra por ciudad.
 */
- (void)cargarYArrancarConCiudad:(nullable NSString *)ciudadId NS_SWIFT_NAME(cargarYArrancar(ciudad:));

/** Detiene la rotacion. Hay que llamarlo al salir de la pantalla o el reloj sigue vivo. */
- (void)parar;

/**
 Apunta el clic y devuelve a donde hay que llevar al usuario.

 @return la URL, o nil si ese banner no es pulsable.
 */
- (nullable NSString *)alPulsar:(nullable ConrraBanner *)banner NS_SWIFT_NAME(alPulsar(_:));

@end

NS_ASSUME_NONNULL_END
