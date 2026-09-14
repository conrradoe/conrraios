//
//  PlanesViewController.h
//  Conrra
//
//  Equivalente de com.conrra.riderapp.planes.PlanesActivity (Android).
//

#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

/**
 Seccion Planes: lugares y ofertas a los que ir en Conrra.

 LO QUE LA HACE DISTINTA DE UNA CARTELERA. El boton IR no abre la web del anunciante: pone
 ese local como destino del viaje y devuelve al pasajero a la pantalla de pedir taxi con la
 ruta ya calculada, a un toque de pedirlo. Ese es el punto entero de la seccion -- el
 anunciante no compra una visita a su pagina, compra que alguien vaya a su local.

 NO SE PIDE EL VIAJE SOLO, a proposito. Se deja el destino puesto y la tarifa a la vista, y
 el pasajero decide. Lanzar una solicitud desde un anuncio seria pedir un taxi en nombre de
 alguien que solo estaba mirando.

 DOS FILTROS QUE TRABAJAN EN SITIOS DISTINTOS: el dia se manda al rele, porque la vigencia
 de cada campaña la sabe el servidor; la categoria y la busqueda se aplican aqui sobre lo ya
 recibido, porque son recortes de una lista que ya esta en la mano y pedirla de nuevo solo
 añadiria una espera por cada toque.

 SE LLAMA "SITIOS" PARA EL PASAJERO. En el panel y en la API la familia se llama "planes", y
 asi siguen los nombres de clase: cambiarlos seria tocar backend, API y app para renombrar
 un rotulo.

 SOLO PARA EL PASAJERO, y solo si la constante `enable_sitios` del backend vale 1.
 */
@interface PlanesViewController : BaseViewController

/** YES si el backend tiene encendida la seccion y quien esta dentro es un pasajero. */
+ (BOOL)estaHabilitada;

@end

NS_ASSUME_NONNULL_END
