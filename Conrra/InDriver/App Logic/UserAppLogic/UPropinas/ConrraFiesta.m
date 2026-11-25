//
//  ConrraFiesta.m
//  Conrra
//

#import "ConrraFiesta.h"
#import "ConrraAvisoLocal.h"
#import "Utilities.h"
// Para objc_setAssociatedObject: el bloque de respuesta se guarda en el boton.
#import <objc/runtime.h>

@implementation ConrraFiesta

+ (void)celebrarEn:(UIViewController *)anfitrion
             monto:(NSString *)monto
            titulo:(NSString *)titulo
             texto:(NSString *)texto
          conCampo:(BOOL)conCampo
          alMontar:(void (^)(UITextField *))alMontar
          acciones:(NSArray<NSString *> *)acciones
       alResponder:(void (^)(NSInteger))alResponder {

    if (anfitrion == nil || anfitrion.view.window == nil) {
        // Una fiesta sobre una pantalla que no esta en pantalla no se ve y deja el bloque sin
        // llamar. Quien celebra ya comprueba lo suyo; esto es el ultimo seguro.
        if (alResponder) {
            alResponder(-1);
        }
        return;
    }

    UIViewController *ventana = [[UIViewController alloc] init];
    ventana.modalPresentationStyle = UIModalPresentationOverFullScreen;
    ventana.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    ventana.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.55];

    CAEmitterLayer *confeti = [self confetiPara:ventana.view.bounds];
    [ventana.view.layer addSublayer:confeti];

    UIView *tarjeta = [[UIView alloc] init];
    tarjeta.translatesAutoresizingMaskIntoConstraints = NO;
    tarjeta.backgroundColor = [UIColor whiteColor];
    tarjeta.layer.cornerRadius = 20;
    [ventana.view addSubview:tarjeta];

    UIStackView *pila = [[UIStackView alloc] init];
    pila.translatesAutoresizingMaskIntoConstraints = NO;
    pila.axis = UILayoutConstraintAxisVertical;
    pila.spacing = 12;
    pila.alignment = UIStackViewAlignmentFill;
    [tarjeta addSubview:pila];

    UILabel *lblMonto = nil;
    if (monto.length > 0) {
        lblMonto = [[UILabel alloc] init];
        lblMonto.text = monto;
        lblMonto.textAlignment = NSTextAlignmentCenter;
        lblMonto.font = [UIFont boldSystemFontOfSize:40];
        lblMonto.textColor = [self amarillo];
        [pila addArrangedSubview:lblMonto];
    }

    if (titulo.length > 0) {
        UILabel *lbl = [[UILabel alloc] init];
        lbl.text = titulo;
        lbl.numberOfLines = 0;
        lbl.textAlignment = NSTextAlignmentCenter;
        lbl.font = [UIFont boldSystemFontOfSize:17];
        [pila addArrangedSubview:lbl];
    }

    if (texto.length > 0) {
        UILabel *lbl = [[UILabel alloc] init];
        lbl.text = texto;
        lbl.numberOfLines = 0;
        lbl.textAlignment = NSTextAlignmentCenter;
        lbl.font = [UIFont systemFontOfSize:15];
        lbl.textColor = [UIColor colorWithWhite:0.35 alpha:1];
        [pila addArrangedSubview:lbl];
    }

    if (conCampo) {
        UITextField *campo = [[UITextField alloc] init];
        campo.placeholder = @"Escribe unas gracias (opcional)";
        campo.borderStyle = UITextBorderStyleRoundedRect;
        campo.returnKeyType = UIReturnKeyDone;
        [campo addTarget:campo action:@selector(resignFirstResponder)
        forControlEvents:UIControlEventEditingDidEndOnExit];
        [campo.heightAnchor constraintEqualToConstant:44].active = YES;
        [pila addArrangedSubview:campo];
        if (alMontar) {
            alMontar(campo);
        }
    }

    [acciones enumerateObjectsUsingBlock:^(NSString *nombre, NSUInteger i, BOOL *parar) {
        UIButton *b = [UIButton buttonWithType:UIButtonTypeSystem];
        [b setTitle:nombre forState:UIControlStateNormal];
        b.titleLabel.font = (i == 0) ? [UIFont boldSystemFontOfSize:17]
                                     : [UIFont systemFontOfSize:16];
        if (i == 0) {
            b.backgroundColor = [self amarillo];
            [b setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            b.layer.cornerRadius = 12;
        } else {
            [b setTitleColor:[UIColor colorWithWhite:0.4 alpha:1] forState:UIControlStateNormal];
        }
        [b.heightAnchor constraintEqualToConstant:(i == 0 ? 50 : 40)].active = YES;
        b.tag = (NSInteger)i;
        [b addTarget:self action:@selector(su_pulsaron:) forControlEvents:UIControlEventTouchUpInside];
        /*
         El bloque y la ventana viajan colgados del boton.

         Sin esto el bloque muere al salir de este metodo y pulsar no haria nada: no hay
         delegado ni objeto que los sostenga, porque la ventana se monta y se olvida. Es la
         pieza menos obvia de todo esto, de ahi el comentario.
         */
        objc_setAssociatedObject(b, @selector(su_pulsaron:),
                                 @[alResponder ? [alResponder copy] : [^(NSInteger c){} copy], ventana],
                                 OBJC_ASSOCIATION_RETAIN);
        [pila addArrangedSubview:b];
    }];

    [NSLayoutConstraint activateConstraints:@[
        [tarjeta.centerXAnchor constraintEqualToAnchor:ventana.view.centerXAnchor],
        [tarjeta.centerYAnchor constraintEqualToAnchor:ventana.view.centerYAnchor],
        [tarjeta.leadingAnchor constraintEqualToAnchor:ventana.view.leadingAnchor constant:28],
        [tarjeta.trailingAnchor constraintEqualToAnchor:ventana.view.trailingAnchor constant:-28],
        [pila.topAnchor      constraintEqualToAnchor:tarjeta.topAnchor constant:24],
        [pila.bottomAnchor   constraintEqualToAnchor:tarjeta.bottomAnchor constant:-20],
        [pila.leadingAnchor  constraintEqualToAnchor:tarjeta.leadingAnchor constant:20],
        [pila.trailingAnchor constraintEqualToAnchor:tarjeta.trailingAnchor constant:-20],
    ]];

    [ConrraAvisoLocal vibrar];
    [anfitrion presentViewController:ventana animated:YES completion:^{
        if (lblMonto != nil) {
            // El monto entra de golpe y rebota: es lo primero que tiene que ver.
            lblMonto.transform = CGAffineTransformMakeScale(0.3, 0.3);
            [UIView animateWithDuration:0.65 delay:0.15
                 usingSpringWithDamping:0.45 initialSpringVelocity:0.6
                                options:0
                             animations:^{ lblMonto.transform = CGAffineTransformIdentity; }
                             completion:nil];
        }
    }];
}

+ (void)su_pulsaron:(UIButton *)boton {
    NSArray *guardado = objc_getAssociatedObject(boton, @selector(su_pulsaron:));
    void (^alResponder)(NSInteger) = guardado.firstObject;
    UIViewController *ventana = guardado.lastObject;
    [ventana dismissViewControllerAnimated:YES completion:^{
        if (alResponder) {
            alResponder(boton.tag);
        }
    }];
}

#pragma mark - El confeti

/**
 El confeti, con CAEmitterLayer.

 Sin dependencias y sin imagenes: las piezas son rectangulos de color dibujados al vuelo. En
 Android hay una ConfettiView propia; aqui el sistema ya trae el emisor.

 Se apaga a los dos segundos: un emisor que no se para sigue calculando particulas mientras la
 ventana este abierta, y la de la propina espera a que alguien escriba unas gracias.
 */
+ (CAEmitterLayer *)confetiPara:(CGRect)marco {
    CAEmitterLayer *e = [CAEmitterLayer layer];
    e.frame = marco;
    e.emitterPosition = CGPointMake(CGRectGetMidX(marco), -10);
    e.emitterSize = CGSizeMake(CGRectGetWidth(marco), 1);
    e.emitterShape = kCAEmitterLayerLine;
    e.beginTime = CACurrentMediaTime();

    NSArray<UIColor *> *colores = @[
        [self amarillo],
        [UIColor colorWithRed:0x4C/255.0 green:0xAF/255.0 blue:0x50/255.0 alpha:1],
        [UIColor colorWithRed:0x21/255.0 green:0x96/255.0 blue:0xF3/255.0 alpha:1],
        [UIColor colorWithRed:0xE9/255.0 green:0x1E/255.0 blue:0x63/255.0 alpha:1],
    ];
    NSMutableArray *celdas = [NSMutableArray array];
    for (UIColor *c in colores) {
        CAEmitterCell *celda = [CAEmitterCell emitterCell];
        celda.contents = (__bridge id)[self piezaDe:c].CGImage;
        celda.birthRate = 6;
        celda.lifetime = 4.0;
        celda.velocity = 180;
        celda.velocityRange = 90;
        celda.emissionLongitude = M_PI;      // hacia abajo
        celda.emissionRange = M_PI_4;
        celda.spin = 3.5;
        celda.spinRange = 4.0;
        celda.scale = 1.0;
        celda.scaleRange = 0.4;
        [celdas addObject:celda];
    }
    e.emitterCells = celdas;

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{ e.birthRate = 0; });
    return e;
}

/// Un rectangulo de color, que es una pieza de confeti.
+ (UIImage *)piezaDe:(UIColor *)color {
    CGSize t = CGSizeMake(8, 14);
    UIGraphicsBeginImageContextWithOptions(t, NO, 0);
    [color setFill];
    UIRectFill(CGRectMake(0, 0, t.width, t.height));
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

#pragma mark - Detalles

+ (UIColor *)amarillo {
    return [UIColor colorNamed:@"app_theame"]
        ?: [UIColor colorWithRed:0xEB/255.0 green:0xB5/255.0 blue:0x18/255.0 alpha:1];
}

+ (NSString *)conMoneda:(double)monto {
    NSString *s = [Utilities formatAmountAndCurrency:(float)monto currency:nil];
    return s.length > 0 ? s : [NSString stringWithFormat:@"%.2f", monto];
}

@end
