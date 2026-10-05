//
//  ConrraFotoDeRegistro.h
//  Conrra
//
//  Equivalente de Controller.setRegistroFotoBase64 (Android).
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 La foto que el pasajero elige MIENTRAS se registra, guardada hasta que se crea la cuenta.

 POR QUE NO VIAJA EN LA PANTALLA. El alta no termina en el formulario: el formulario lleva al
 OTP, y es el OTP el que crea la cuenta (OTPVerifyViewController.registerMeWithInfo). O sea
 que la foto se elige en una pantalla y se manda desde otra.

 Android lo resuelve igual y por un motivo mas duro: alli un Base64 de cientos de kB metido
 en el Bundle de un Intent revienta con TransactionTooLargeException. En iOS no hay ese
 limite, pero el reparto es el mismo y pasarla por una propiedad del controlador siguiente
 ataria las dos pantallas sin necesidad.

 SE OLVIDA al crear la cuenta y al salirse del registro. Si no, una foto elegida y abandonada
 se le acabaria pegando al siguiente que se registre en el mismo telefono.

 Vive en memoria y no en las preferencias a proposito: es un dato de un minuto, y escribir en
 disco una imagen que se va a tirar no aporta nada.
 */
@interface ConrraFotoDeRegistro : NSObject

/**
 Guarda la foto elegida: la encoge, la pasa a JPEG y se queda con el Base64.

 300 x 300 y calidad 0,85, lo mismo que la foto de perfil de la app y lo mismo que Android.
 JPEG y no PNG: el servidor guarda estos bytes en un .jpg de todas formas, y un PNG de ese
 tamaño son cientos de kB de mas en una subida que ocurre con datos moviles.
 */
+ (void)guardarImagen:(nullable UIImage *)imagen;

/** ¿Eligio foto? */
+ (BOOL)hay;

/** El Base64 listo para `user_image`, o "" si no hay. */
+ (NSString *)base64;

/** La imagen ya encogida, para repintar el circulo del formulario. */
+ (nullable UIImage *)imagen;

/** Se tira la foto. Al crear la cuenta y al abandonar el registro. */
+ (void)olvidar;

@end

NS_ASSUME_NONNULL_END
