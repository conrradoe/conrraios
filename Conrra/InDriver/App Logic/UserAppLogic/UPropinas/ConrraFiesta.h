//
//  ConrraFiesta.h
//  Conrra
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 La tarjeta de celebracion de la app: confeti, un monto que entra rebotando, un titulo, un
 texto y los botones que hagan falta.

 ============ POR QUE ESTA SUELTA ============
 La usan tres fiestas -- la propina, el bono de bienvenida y el de referido -- y en Android son
 el MISMO dialogo (dialog_bono_referido, reusado por las tres). Si cada una montara la suya,
 el confeti, la animacion del monto y la vibracion estarian escritos tres veces, y en cuanto
 alguien ajustara uno los otros dos se quedarian distintos sin que nadie lo note: son fiestas,
 nadie las prueba.
 =============================================

 NO SABE DE DINERO. Recibe textos ya formateados y devuelve que boton se pulso. Quien decide
 que se celebra y quien mueve el saldo es otro -- el servidor, siempre.
 */
@interface ConrraFiesta : NSObject

/**
 Ensena la tarjeta.

 @param monto       ya formateado y con su signo ("+ 3,00"), o nil si esta fiesta no lleva cifra.
 @param conCampo    SI añade un campo de texto (lo usa el "gracias" de la propina).
 @param alMontar    recibe ese campo para poder leerlo despues.
 @param acciones    los titulos de los botones. El PRIMERO va destacado.
 @param alResponder el indice del boton pulsado, ya cerrada la tarjeta.
 */
+ (void)celebrarEn:(nullable UIViewController *)anfitrion
             monto:(nullable NSString *)monto
            titulo:(nullable NSString *)titulo
             texto:(nullable NSString *)texto
          conCampo:(BOOL)conCampo
          alMontar:(nullable void (^)(UITextField *campo))alMontar
          acciones:(NSArray<NSString *> *)acciones
       alResponder:(nullable void (^)(NSInteger cual))alResponder;

/// Un importe con su moneda, o a secas si no se pudo formatear. Para quien arma los textos.
+ (NSString *)conMoneda:(double)monto NS_SWIFT_NAME(conMoneda(_:));

@end

NS_ASSUME_NONNULL_END
