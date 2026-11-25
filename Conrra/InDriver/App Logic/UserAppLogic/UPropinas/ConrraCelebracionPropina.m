//
//  ConrraCelebracionPropina.m
//  Conrra
//

#import "ConrraCelebracionPropina.h"
#import "ConrraPropinas.h"
#import "ConrraAvisoLocal.h"
#import "LanguageHelper.h"
#import "Utilities.h"
// Para objc_setAssociatedObject: el bloque de respuesta se guarda en el boton.
#import <objc/runtime.h>

/*
 La pantalla que esta atenta, en DEBIL.

 Si fuera fuerte, esta variable de clase mantendria viva la ultima pantalla del conductor para
 siempre: no se libera nunca porque nadie la pone a nil cuando el sistema la descarta. Debil se
 queda en nil sola, y revisar() ya comprueba que siga puesta.
 */
static __weak UIViewController *gAtenta = nil;
static BOOL gAtentaEsConductor = NO;

/// Solo una ventana a la vez: la cola espera a que se cierre la anterior.
static BOOL gMostrando = NO;

@implementation ConrraCelebracionPropina

#pragma mark - Quien esta atento

+ (void)atender:(UIViewController *)vc comoConductor:(BOOL)esConductor {
    if (vc == nil) {
        return;
    }
    gAtenta = vc;
    gAtentaEsConductor = esConductor;
    [self revisar];
}

+ (void)desatender:(UIViewController *)vc {
    if (gAtenta == vc) {
        gAtenta = nil;
    }
}

+ (void)llegoAviso {
    // Sin pantalla atenta no se hace nada: la propina sigue pendiente en el servidor y saldra
    // en el siguiente primer plano. Eso es lo que hace que perder un push no cueste nada.
    if (gAtenta == nil) {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{ [self revisar]; });
}

+ (void)revisar {
    UIViewController *vc = gAtenta;
    if (vc == nil || vc.view.window == nil) {
        return;
    }
    if (gAtentaEsConductor) {
        [ConrraPropinas pendientesDelConductor:^(NSArray<ConrraPropinaAviso *> *avisos) {
            [self mostrarEnCola:[avisos mutableCopy]];
        }];
    } else {
        [ConrraPropinas graciasDelPasajero:^(NSArray<ConrraPropinaAviso *> *avisos) {
            [self mostrarGracias:avisos.firstObject];
        }];
    }
}

#pragma mark - El conductor: una propina detras de otra

+ (void)mostrarEnCola:(NSMutableArray<ConrraPropinaAviso *> *)cola {
    UIViewController *vc = gAtenta;
    if (vc == nil || vc.view.window == nil || gMostrando || cola.count == 0) {
        return;
    }
    gMostrando = YES;
    ConrraPropinaAviso *a = cola.firstObject;
    [cola removeObjectAtIndex:0];

    NSString *monto = [self conMoneda:a.monto];
    NSString *deQuien = a.quien.length > 0
        ? [NSString stringWithFormat:@"%@ te dejó una propina", a.quien]
        : @"Te dejaron una propina";

    __block UITextField *campoGracias = nil;
    [self mostrarTarjetaEn:vc
                     monto:[NSString stringWithFormat:@"+ %@", monto]
                    titulo:deQuien
                     texto:nil
                conCampo:YES
                  alMontar:^(UITextField *campo) { campoGracias = campo; }
                  acciones:@[@"Dar las gracias", @"Cerrar"]
               alResponder:^(NSInteger cual) {
        // 0 = gracias con su texto, 1 = cerrar sin mas. Las dos CIERRAN la propina en el
        // servidor: si no se cerrara, la misma volveria a salir en cada arranque.
        [ConrraPropinas cerrar:a.propinaId
                       gracias:(cual == 0)
                         texto:(cual == 0 ? campoGracias.text : @"")];
        gMostrando = NO;
        [self mostrarEnCola:cola];
    }];
}

#pragma mark - El pasajero: las gracias

+ (void)mostrarGracias:(ConrraPropinaAviso *)a {
    UIViewController *vc = gAtenta;
    if (a == nil || vc == nil || vc.view.window == nil || gMostrando) {
        return;
    }
    gMostrando = YES;
    NSString *titulo = a.quien.length > 0
        ? [NSString stringWithFormat:@"%@ te dio las gracias", a.quien]
        : @"Tu conductor te dio las gracias";
    // Entre comillas y solo si escribio algo: unas comillas vacias parecen un fallo.
    NSString *texto = a.texto.length > 0
        ? [NSString stringWithFormat:@"“%@”", a.texto] : nil;

    [self mostrarTarjetaEn:vc
                     monto:nil
                    titulo:titulo
                     texto:texto
                  conCampo:NO
                  alMontar:nil
                  acciones:@[[LanguageHelper getStringWithKey:@"k_18_s4_Ok" defaultValue:@"De nada"]]
               alResponder:^(NSInteger cual) {
        gMostrando = NO;
    }];
}

#pragma mark - La tarjeta

/**
 La ventana, montada a mano y con confeti.

 Se monta en vez de usar un UIAlertController por el confeti: una alerta del sistema no deja
 pintar nada encima, y la celebracion ES el confeti. El campo de las gracias si lo soporta una
 alerta, pero no las dos cosas a la vez.

 ALERTA DE PROPOSITO SOBRE EL TAMANO: la vista del confeti cubre la pantalla entera, no la
 tarjeta, igual que en Android. Un confeti del tamano de la tarjeta no se ve.
 */
+ (void)mostrarTarjetaEn:(UIViewController *)anfitrion
                   monto:(NSString *)monto
                  titulo:(NSString *)titulo
                   texto:(NSString *)texto
                conCampo:(BOOL)conCampo
                alMontar:(void (^)(UITextField *campo))alMontar
                acciones:(NSArray<NSString *> *)acciones
             alResponder:(void (^)(NSInteger cual))alResponder {

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
        lblMonto.textColor = [UIColor colorNamed:@"app_theame"]
            ?: [UIColor colorWithRed:0xEB/255.0 green:0xB5/255.0 blue:0x18/255.0 alpha:1];
        [pila addArrangedSubview:lblMonto];
    }

    UILabel *lblTitulo = [[UILabel alloc] init];
    lblTitulo.text = titulo;
    lblTitulo.numberOfLines = 0;
    lblTitulo.textAlignment = NSTextAlignmentCenter;
    lblTitulo.font = [UIFont boldSystemFontOfSize:17];
    [pila addArrangedSubview:lblTitulo];

    if (texto.length > 0) {
        UILabel *lblTexto = [[UILabel alloc] init];
        lblTexto.text = texto;
        lblTexto.numberOfLines = 0;
        lblTexto.textAlignment = NSTextAlignmentCenter;
        lblTexto.font = [UIFont italicSystemFontOfSize:15];
        lblTexto.textColor = [UIColor colorWithWhite:0.35 alpha:1];
        [pila addArrangedSubview:lblTexto];
    }

    UITextField *campo = nil;
    if (conCampo) {
        campo = [[UITextField alloc] init];
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
            b.backgroundColor = [UIColor colorNamed:@"app_theame"]
                ?: [UIColor colorWithRed:0xEB/255.0 green:0xB5/255.0 blue:0x18/255.0 alpha:1];
            [b setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            b.layer.cornerRadius = 12;
        } else {
            [b setTitleColor:[UIColor colorWithWhite:0.4 alpha:1] forState:UIControlStateNormal];
        }
        [b.heightAnchor constraintEqualToConstant:(i == 0 ? 50 : 40)].active = YES;
        b.tag = (NSInteger)i;
        [b addTarget:self action:@selector(su_pulsaron:) forControlEvents:UIControlEventTouchUpInside];
        [pila addArrangedSubview:b];
    }];

    // El bloque y la ventana se guardan en el boton: sin esto el bloque muere al salir de
    // aqui y pulsar no haria nada. Es lo mismo que resolver un delegado, con menos piezas.
    for (UIView *v in pila.arrangedSubviews) {
        if ([v isKindOfClass:[UIButton class]]) {
            objc_setAssociatedObject(v, @selector(su_pulsaron:),
                                     @[[alResponder copy], ventana],
                                     OBJC_ASSOCIATION_RETAIN);
        }
    }

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

/**
 El confeti, con CAEmitterLayer.

 Sin dependencias y sin imagenes: las piezas son rectangulos de color dibujados al vuelo. En
 Android hay una ConfettiView propia; aqui el sistema ya trae el emisor y añadir una vista de
 particulas a mano seria mas codigo para el mismo efecto.

 Se apaga a los dos segundos: un emisor que no se para sigue calculando particulas mientras la
 ventana este abierta, y esa ventana espera a que alguien escriba unas gracias.
 */
+ (CAEmitterLayer *)confetiPara:(CGRect)marco {
    CAEmitterLayer *e = [CAEmitterLayer layer];
    e.frame = marco;
    e.emitterPosition = CGPointMake(CGRectGetMidX(marco), -10);
    e.emitterSize = CGSizeMake(CGRectGetWidth(marco), 1);
    e.emitterShape = kCAEmitterLayerLine;
    e.beginTime = CACurrentMediaTime();

    NSArray<UIColor *> *colores = @[
        [UIColor colorWithRed:0xEB/255.0 green:0xB5/255.0 blue:0x18/255.0 alpha:1],
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

/// El importe con su moneda, o a secas si no se pudo formatear.
+ (NSString *)conMoneda:(double)monto {
    NSString *s = [Utilities formatAmountAndCurrency:(float)monto currency:nil];
    return s.length > 0 ? s : [NSString stringWithFormat:@"%.2f", monto];
}

@end
