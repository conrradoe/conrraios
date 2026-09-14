//
//  ConrraCatalogoDePlanes.h
//  Conrra
//
//  Equivalente de com.conrra.riderapp.planes.CatalogoDePlanes (Android).
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN

/** Una ficha del catalogo. */
@interface ConrraPlan : NSObject

@property (nonatomic, copy, readonly) NSString *identificador;
@property (nonatomic, copy, readonly) NSString *titulo;
@property (nonatomic, copy, readonly) NSString *cliente;
@property (nonatomic, copy, readonly) NSString *imagen;
@property (nonatomic, copy, readonly) NSString *plan;
@property (nonatomic, copy, readonly) NSString *categoria;
@property (nonatomic, copy, readonly) NSString *etiqueta;
@property (nonatomic, copy, readonly) NSString *detalle;
@property (nonatomic, copy, readonly) NSString *horario;
@property (nonatomic, copy, readonly) NSString *nota;

/** El punto al que se pedira el viaje. */
@property (nonatomic, assign, readonly) CLLocationDegrees lat;
@property (nonatomic, assign, readonly) CLLocationDegrees lng;
@property (nonatomic, copy, readonly) NSString *sitio;
@property (nonatomic, copy, readonly) NSString *direccion;

- (BOOL)esPremium;

/**
 Lo que se escribira en el campo de destino del viaje.

 Se prefiere "Local, calle" porque el pasajero reconoce el nombre y el conductor necesita
 la calle. Si no hay direccion basta el nombre: las coordenadas son las que mandan de
 todos modos, el texto solo es para leerlo.
 */
- (NSString *)destinoLegible;

/** Texto, en minusculas, sobre el que busca la lupa de la pantalla. */
- (NSString *)paraBuscar;

@end


@interface ConrraCatalogoDePlanes : NSObject

/**
 Pide el catalogo.

 @param ciudadId city_id del pasajero, o nil para no filtrar por ciudad.
 @param dia      AAAA-MM-DD que el pasajero eligio arriba, o nil para hoy.
 @param alTerminar Llega en el hilo principal. Lista vacia si el rele no contesto o si no
                   hay nada que enseñar: la pantalla distingue los dos casos por su cuenta.
 */
- (void)cargarConCiudad:(nullable NSString *)ciudadId
                    dia:(nullable NSString *)dia
             alTerminar:(void (^)(NSArray<ConrraPlan *> *planes))alTerminar;

/**
 Apunta que este plan se vio. Una sola vez por plan y por visita a la pantalla.

 Lo llama la celda cuando aparece de verdad en pantalla, no al recibir la lista: contar
 como vista algo que se quedo diez fichas mas abajo y nadie llego a mirar seria cobrarle
 al anunciante por nada.
 */
- (void)alAsomarse:(nullable ConrraPlan *)plan;

/** Apunta el toque de IR. Lo demas -- fijar el destino -- lo hace la pantalla. */
- (void)alPulsarIr:(nullable ConrraPlan *)plan;

/** Al volver a entrar en la pantalla, las vistas se cuentan otra vez. */
- (void)olvidarImpresiones;

@end

NS_ASSUME_NONNULL_END
