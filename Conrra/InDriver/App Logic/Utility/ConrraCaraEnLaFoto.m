//
//  ConrraCaraEnLaFoto.m
//  Conrra
//

#import "ConrraCaraEnLaFoto.h"
#import <Vision/Vision.h>
#import <ImageIO/ImageIO.h>

@implementation ConrraCaraEnLaFoto

+ (void)contarCarasEn:(UIImage *)imagen
        cuandoTermine:(void (^)(NSInteger, BOOL))bloque {
    if (bloque == nil) {
        return;
    }
    void (^responder)(NSInteger, BOOL) = ^(NSInteger caras, BOOL sePudoMirar) {
        if ([NSThread isMainThread]) {
            bloque(caras, sePudoMirar);
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{ bloque(caras, sePudoMirar); });
        }
    };

    CGImageRef cg = [self imagenDeMapaDeBits:imagen];
    if (cg == NULL) {
        responder(0, NO);
        return;
    }
    CGImagePropertyOrientation orientacion = [self orientacionDe:imagen.imageOrientation];

    /*
     Fuera del hilo principal: Vision tarda unas decimas en una foto de camara, y en el
     principal eso es la pantalla congelada justo despues de cerrar el selector.
     */
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
        VNDetectFaceRectanglesRequest *peticion = [[VNDetectFaceRectanglesRequest alloc] init];
        VNImageRequestHandler *manejador =
            [[VNImageRequestHandler alloc] initWithCGImage:cg
                                               orientation:orientacion
                                                   options:@{}];
        NSError *error = nil;
        BOOL hecho = [manejador performRequests:@[peticion] error:&error];
        CGImageRelease(cg);

        if (!hecho || error != nil) {
            NSLog(@"[CaraEnLaFoto] Vision no pudo mirar la imagen: %@", error.localizedDescription);
            responder(0, NO);
            return;
        }
        NSArray *resultados = peticion.results;
        responder((NSInteger)resultados.count, YES);
    });
}

/**
 Un CGImage sobre el que Vision pueda trabajar, retenido por quien lo recibe.

 Una UIImage puede venir respaldada por un CIImage y no por un CGImage -- pasa con imagenes
 que han pasado por un filtro --, y entonces .CGImage es NULL. En ese caso se repinta.
 */
+ (CGImageRef)imagenDeMapaDeBits:(UIImage *)imagen CF_RETURNS_RETAINED {
    if (imagen == nil) {
        return NULL;
    }
    if (imagen.CGImage != NULL) {
        return CGImageRetain(imagen.CGImage);
    }
    if (imagen.size.width <= 0 || imagen.size.height <= 0) {
        return NULL;
    }
    UIGraphicsBeginImageContextWithOptions(imagen.size, NO, imagen.scale);
    [imagen drawInRect:CGRectMake(0, 0, imagen.size.width, imagen.size.height)];
    UIImage *repintada = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return repintada.CGImage != NULL ? CGImageRetain(repintada.CGImage) : NULL;
}

/**
 La orientacion de UIKit traducida a la de EXIF, que es la que entiende Vision.

 ESTO NO ES UN DETALLE. Los dos enumerados tienen los mismos nombres pero NO los mismos
 numeros: UIImageOrientationLeft vale 2 y kCGImagePropertyOrientationLeft vale 8. Pasar el
 numero de UIKit tal cual le dice a Vision una orientacion distinta de la real.

 Y aqui importa mas que en otros sitios: una selfie sale de la camara frontal como
 leftMirrored o rightMirrored, casi nunca como up. Con la orientacion equivocada Vision
 busca la cara girada y puede no encontrarla -- o sea que el validador rechazaria fotos
 perfectamente buenas, y pareceria que la camara o la cara estan mal.
 */
+ (CGImagePropertyOrientation)orientacionDe:(UIImageOrientation)orientacion {
    switch (orientacion) {
        case UIImageOrientationUp:            return kCGImagePropertyOrientationUp;
        case UIImageOrientationUpMirrored:    return kCGImagePropertyOrientationUpMirrored;
        case UIImageOrientationDown:          return kCGImagePropertyOrientationDown;
        case UIImageOrientationDownMirrored:  return kCGImagePropertyOrientationDownMirrored;
        case UIImageOrientationLeft:          return kCGImagePropertyOrientationLeft;
        case UIImageOrientationLeftMirrored:  return kCGImagePropertyOrientationLeftMirrored;
        case UIImageOrientationRight:         return kCGImagePropertyOrientationRight;
        case UIImageOrientationRightMirrored: return kCGImagePropertyOrientationRightMirrored;
    }
    return kCGImagePropertyOrientationUp;
}

@end
