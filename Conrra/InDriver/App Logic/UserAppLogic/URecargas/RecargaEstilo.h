//
//  RecargaEstilo.h
//  Conrra
//
//  Lo que comparten las tres pantallas de recarga.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Paleta, piezas y el relé, en un solo sitio.

 Las tres pantallas de recarga -- el selector, el C2P y el botón de Mercantil -- llevan la
 misma cabecera, los mismos campos y la misma llamada al relé. Repetir eso tres veces es
 pedir que dentro de un mes el margen de un campo no coincida con el de al lado, que es
 justo lo que pasa cuando cada pantalla se pinta sola.

 Los colores son los de Android por valor, no por parecido: neutral_900 #212121,
 neutral_600 #5A5A5A, neutral_500 #696969, neutral_150 #EFEFEF, brand_yellow_400 #EBB518 y
 state_success #54AB47. Se leen antes del catalogo de colores del app y solo se usa el
 literal si el nombre no existe, para que un cambio de tema siga mandando.
 */
@interface RecargaEstilo : NSObject

#pragma mark - Paleta

+ (UIColor *)fondo;              ///< color_background
+ (UIColor *)textoPrincipal;     ///< neutral_900
+ (UIColor *)textoSecundario;    ///< neutral_600
+ (UIColor *)textoTerciario;     ///< neutral_500
+ (UIColor *)amarillo;           ///< brand_yellow_400
+ (UIColor *)borde;              ///< neutral_150
+ (UIColor *)verde;              ///< state_success

#pragma mark - Piezas

/** Rotulo de campo: 12 puntos, gris medio. Android: TextAppearance.Conrra.Label.Small. */
+ (UILabel *)rotulo:(NSString *)texto;

/** Linea de ayuda debajo de un campo: 12 puntos, gris claro. */
+ (UILabel *)ayuda:(NSString *)texto;

/** Caja de texto con el fondo redondeado de Android (bg_request_inner). */
+ (UITextField *)campoConPista:(NSString *)pista;

/** Caja blanca con borde y esquinas de 12, el bg_request_inner de Android. */
+ (UIView *)tarjeta;

/** Boton amarillo de 48 de alto, el estilo de accion principal del app. */
+ (UIButton *)botonPrincipalConTitulo:(NSString *)titulo;

/**
 Monta la cabecera de Android: flecha de volver a la izquierda y titulo centrado a su
 altura. Devuelve la vista contenedora ya anclada al area segura.
 */
+ (UIView *)cabeceraEn:(UIViewController *)vc
                titulo:(NSString *)titulo
                accion:(SEL)accionVolver;

/** Velo oscuro con rueda, para mientras el banco contesta. Empieza escondido. */
+ (UIView *)veloDeEsperaEn:(UIView *)vista;

#pragma mark - Dinero

/** Bolivares por dolar, o 0 si el servidor no la publica. */
+ (float)tasa;

/** Un numero en el formato venezolano: 1.234,56 */
+ (NSString *)enFormatoLocal:(double)cantidad;

/** El saldo del monedero del usuario que ha iniciado sesion. */
+ (float)saldo;

#pragma mark - Relé

/**
 POST de formulario al relé de recargas.

 La app NO habla con Mercantil: manda los datos a conrraservices.com, que es el unico que
 conoce las credenciales del comercio. Un IPA se abre con unzip, asi que meter aqui esas
 credenciales seria repartirlas.

 `campos` son los propios de cada pantalla; los de la cuenta -- api_key, user_id, city_id,
 currency -- los añade este metodo, porque son los mismos siempre y olvidar uno da un
 rechazo del relé que parece un fallo del banco.

 El bloque vuelve SIEMPRE en el hilo principal.
 */
+ (void)enviarA:(NSString *)url
         campos:(NSDictionary<NSString *, NSString *> *)campos
     completado:(void (^)(NSDictionary * _Nullable json, NSError * _Nullable error))completado;

@end

NS_ASSUME_NONNULL_END
