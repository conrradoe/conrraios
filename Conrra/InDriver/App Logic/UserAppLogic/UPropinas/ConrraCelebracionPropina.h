//
//  ConrraCelebracionPropina.h
//  Conrra
//
//  Equivalente de com.conrra.merged.common.propina.CelebracionPropina (Android).
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 La ventana de la propina: confeti, el monto que entra rebotando, quien la envia y la opcion de
 dar las gracias. Y su pareja para el pasajero: "te dio las gracias".

 ============ COMO SE ENTERA, Y POR QUE NO SE FIA DEL PUSH ============
 El servidor manda un aviso push, pero esto NO depende de el. La pantalla pregunta las
 pendientes cada vez que vuelve a primer plano, y el push solo hace que pregunte YA si esta
 abierta.

 Esa es la parte que importa: una propina que llega con el telefono apagado, o con el push
 perdido -- que en iOS pasa --, sale igual la proxima vez que el conductor abre la app. Si la
 ventana colgara del push, esa propina no se veria nunca y nadie lo sabria.
 ======================================================================

 LAS PROPINAS SE ENSENAN DE UNA EN UNA. Si hay tres sin ver salen las tres, en cola, no las
 tres encimadas: cada una tiene su monto y su "gracias", y apiladas no se podria responder a
 ninguna.
 */
@interface ConrraCelebracionPropina : NSObject

/**
 En viewWillAppear. Pregunta ya y queda atenta a los avisos.

 @param esConductor SI mira las propinas que le han dado; NO, las gracias que ha recibido.
 */
+ (void)atender:(nullable UIViewController *)vc
   comoConductor:(BOOL)esConductor NS_SWIFT_NAME(atender(_:comoConductor:));

/// En viewWillDisappear.
+ (void)desatender:(nullable UIViewController *)vc NS_SWIFT_NAME(desatender(_:));

/// Lo llama el AppDelegate al recibir el push: si hay pantalla atenta, que pregunte ya.
+ (void)llegoAviso;

@end

NS_ASSUME_NONNULL_END
