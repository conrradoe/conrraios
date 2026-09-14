//
//  ConrraMapaSelectorViewController.h
//  Conrra
//
//  Elegir un punto arrastrando el mapa. Equivalente de startMapSelection /
//  confirmMapSelection de Android (riderapp/MainScreenActivity.kt).
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, ConrraModoSeleccionMapa) {
    ConrraModoSeleccionRecogida = 0,
    ConrraModoSeleccionDestino  = 1,
};

@class ConrraMapaSelectorViewController;

@protocol ConrraMapaSelectorDelegate <NSObject>

/// El usuario confirmo un punto. La pantalla ya se ha cerrado cuando esto llega.
- (void)selectorDeMapa:(ConrraMapaSelectorViewController *)selector
      eligioCoordenada:(CLLocationCoordinate2D)coordenada
             direccion:(NSString *)direccion
                  modo:(ConrraModoSeleccionMapa)modo;

@end


/**
 Elegir un punto arrastrando el mapa.

 EL PIN NO SE MUEVE, SE MUEVE EL MAPA. Es lo mismo que hace Android
 (layoutMapSelectionCenterPin) y lo que hace todo el mundo: un pin clavado en el centro
 de la pantalla y el mapa desplazandose debajo. Arrastrar un pin con el dedo lo tapa
 justo cuando hay que afinar.

 POR QUE ES UNA PANTALLA APARTE y no un "modo" del mapa del home, que es como lo
 resuelve Android. Alli la busqueda de direccion vive en la misma Activity que el mapa,
 asi que meterla en modo seleccion es natural. Aqui la pantalla de ruta es un
 controlador distinto y ni siquiera tiene mapa: copiar aquel diseño obligaria a cablear
 las dos pantallas entre si. Asi se abre desde donde haga falta y devuelve un punto.

 La direccion se resuelve al parar de arrastrar, no en cada fotograma: geocodificar
 mientras el dedo se mueve es una llamada por fotograma y un contador de cuota que sube
 sin que nadie lea el resultado.
 */
@interface ConrraMapaSelectorViewController : UIViewController

@property (weak, nonatomic) id<ConrraMapaSelectorDelegate> delegado;

/// Solo cambia el rotulo de arriba y el que se devuelve al confirmar.
@property (assign, nonatomic) ConrraModoSeleccionMapa modo;

/// Donde se centra al abrir. Si es cero, se centra en la ubicacion del usuario.
@property (assign, nonatomic) CLLocationCoordinate2D centroInicial;

@end

NS_ASSUME_NONNULL_END
