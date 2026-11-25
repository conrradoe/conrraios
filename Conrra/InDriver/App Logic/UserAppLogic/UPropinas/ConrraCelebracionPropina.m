//
//  ConrraCelebracionPropina.m
//  Conrra
//

#import "ConrraCelebracionPropina.h"
#import "ConrraPropinas.h"
#import "ConrraFiesta.h"
#import "LanguageHelper.h"

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

    NSString *monto = [ConrraFiesta conMoneda:a.monto];
    NSString *deQuien = a.quien.length > 0
        ? [NSString stringWithFormat:@"%@ te dejó una propina", a.quien]
        : @"Te dejaron una propina";

    __block UITextField *campoGracias = nil;
    [ConrraFiesta celebrarEn:vc
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

    [ConrraFiesta celebrarEn:vc
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

@end
