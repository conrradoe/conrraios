//
//  ConrraFotoDeRegistro.m
//  Conrra
//

#import "ConrraFotoDeRegistro.h"
#import "Utilities.h"

static UIImage  *gImagen = nil;
static NSString *gBase64 = nil;

@implementation ConrraFotoDeRegistro

+ (void)guardarImagen:(UIImage *)imagen {
    if (imagen == nil) {
        return;
    }
    UIImage *encogida = [Utilities imageWithImageHeight:imagen scaledToWidth:300 scaledToHeight:300];
    if (encogida == nil) {
        encogida = imagen;
    }
    NSString *b64 = [Utilities encodeImageToBase64String:encogida quality:0.85f];
    if (b64.length == 0) {
        // Sin Base64 no hay nada que mandar, asi que tampoco se guarda la imagen: dejar el
        // circulo con foto y el envio sin ella seria peor que no haberla aceptado.
        NSLog(@"[FotoDeRegistro] no se pudo codificar la foto elegida");
        return;
    }
    gImagen = encogida;
    gBase64 = b64;
}

+ (BOOL)hay {
    return gBase64.length > 0;
}

+ (NSString *)base64 {
    return gBase64 ?: @"";
}

+ (UIImage *)imagen {
    return gImagen;
}

+ (void)olvidar {
    gImagen = nil;
    gBase64 = nil;
}

@end
