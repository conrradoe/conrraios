//
//  PruebaPagoDeViaje.m
//  Conrra -- comprobador suelto, NO va en el target de la app.
//
//  SE CORRE EN EL MAC, con una linea y sin abrir Xcode:
//
//      cd ~/Documents/conrraios
//      clang -fobjc-arc -framework Foundation \
//            "pruebas/PruebaPagoDeViaje.m" \
//            "Conrra/InDriver/App Logic/Utility/ConrraPagoDeViaje.m" \
//            -I "Conrra/InDriver/App Logic/Utility" -o /tmp/prueba_pago && /tmp/prueba_pago
//
//  POR QUE ESTA REGLA TIENE PRUEBA. Decide si la app cobra o se aparta, y equivocarse cuesta
//  dinero de verdad: en Android fueron 67 viajes cobrados dos veces, y en produccion el
//  2026-11-24 el viaje 6431 tenia dos cobros de billetera con seis segundos de diferencia.
//  Es la clase mas pequeña del proyecto y la que mas caro sale si falla.
//
//  Misma tabla de casos que PagoDeViaje.java de Android: las dos plataformas tienen que
//  contestar lo mismo al mismo modo de pago.
//

#import <Foundation/Foundation.h>
#import "ConrraPagoDeViaje.h"

static int fallos = 0;

static void igualBool(NSString *que, BOOL esperado, BOOL dado) {
    if (esperado == dado) {
        printf("  ok     %s -> %s\n", que.UTF8String, dado ? "SI" : "no");
    } else {
        printf("  FALLO  %s esperaba %s y dio %s\n", que.UTF8String,
               esperado ? "SI" : "no", dado ? "SI" : "no");
        fallos++;
    }
}

static void igual(NSString *que, NSString *esperado, NSString *dado) {
    if ([esperado isEqualToString:dado]) {
        printf("  ok     %s -> %s\n", que.UTF8String, dado.UTF8String);
    } else {
        printf("  FALLO  %s esperaba %s y dio %s\n", que.UTF8String,
               esperado.UTF8String, dado.UTF8String);
        fallos++;
    }
}

int main(void) {
    @autoreleasepool {
        printf("\n--- es billetera: solo cuando lo es de verdad ---\n");
        igualBool(@"Wallet",            YES, [ConrraPagoDeViaje esBilletera:@"Wallet"]);
        igualBool(@"wallet minuscula",  YES, [ConrraPagoDeViaje esBilletera:@"wallet"]);
        igualBool(@"WALLET mayusculas", YES, [ConrraPagoDeViaje esBilletera:@"WALLET"]);
        igualBool(@"con espacios",      YES, [ConrraPagoDeViaje esBilletera:@"  Wallet  "]);
        igualBool(@"Cash",               NO, [ConrraPagoDeViaje esBilletera:@"Cash"]);
        igualBool(@"Pago Movil",         NO, [ConrraPagoDeViaje esBilletera:@"Pago Movil"]);
        igualBool(@"Card",               NO, [ConrraPagoDeViaje esBilletera:@"Card"]);
        igualBool(@"nil",                NO, [ConrraPagoDeViaje esBilletera:nil]);
        igualBool(@"vacia",              NO, [ConrraPagoDeViaje esBilletera:@""]);
        // El "null" de texto es lo que sale de formatear un nil con %@, y colarse por aqui
        // seria decidir "no es billetera" por el motivo equivocado.
        igualBool(@"el texto null",      NO, [ConrraPagoDeViaje esBilletera:@"null"]);
        igualBool(@"Walletito no es Wallet", NO, [ConrraPagoDeViaje esBilletera:@"Walletito"]);

        printf("\n--- el metodo con que se marca pagado: NUNCA billetera ---\n");
        // Esta es la que evita el cobro doble: quien llama esta a punto de registrar un cobro.
        igual(@"de Wallet sale efectivo",  @"Cash", [ConrraPagoDeViaje metodoNoBilletera:@"Wallet"]);
        igual(@"de wallet tambien",        @"Cash", [ConrraPagoDeViaje metodoNoBilletera:@"wallet"]);
        igual(@"de nil, efectivo",         @"Cash", [ConrraPagoDeViaje metodoNoBilletera:nil]);
        igual(@"de vacia, efectivo",       @"Cash", [ConrraPagoDeViaje metodoNoBilletera:@""]);
        igual(@"del texto null, efectivo", @"Cash", [ConrraPagoDeViaje metodoNoBilletera:@"null"]);
        // Y lo que NO hay que perder: el metodo elegido se respeta tal cual.
        igual(@"Cash se queda Cash",       @"Cash", [ConrraPagoDeViaje metodoNoBilletera:@"Cash"]);
        igual(@"Pago Movil se respeta",    @"Pago Movil",
              [ConrraPagoDeViaje metodoNoBilletera:@"Pago Movil"]);
        igual(@"Card se respeta",          @"Card", [ConrraPagoDeViaje metodoNoBilletera:@"Card"]);
        igual(@"se limpian los espacios",  @"Pago Movil",
              [ConrraPagoDeViaje metodoNoBilletera:@"  Pago Movil  "]);

        printf("\n--- la propiedad que importa: lo que sale de aqui no es billetera NUNCA ---\n");
        NSArray *todos = @[@"Wallet", @"wallet", @"WALLET", @"  Wallet ", @"Cash", @"Pago Movil",
                           @"Card", @"", @"null", @"Walletito", @"Transferencia"];
        BOOL alguna = NO;
        for (NSString *m in todos) {
            if ([ConrraPagoDeViaje esBilletera:[ConrraPagoDeViaje metodoNoBilletera:m]]) {
                printf("  FALLO  de '%s' salio billetera\n", m.UTF8String);
                alguna = YES;
                fallos++;
            }
        }
        igualBool(@"ninguno de los 11 modos devuelve billetera", NO, alguna);
        igualBool(@"tampoco nil", NO,
                  [ConrraPagoDeViaje esBilletera:[ConrraPagoDeViaje metodoNoBilletera:nil]]);

        printf("\n--- los codigos, por si alguien los cambia sin querer ---\n");
        igual(@"billetera", @"Wallet", ConrraPagoDeViaje.billetera);
        igual(@"efectivo",  @"Cash",   ConrraPagoDeViaje.efectivo);

        printf("\n");
        if (fallos == 0) {
            printf("  PAGO DE VIAJE: todas en verde\n\n");
            return 0;
        }
        printf("  SUSPENDE: %d fallo(s)\n\n", fallos);
        return 1;
    }
}
