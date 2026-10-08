//
//  PruebaPuertaVerificacion.m
//  Conrra -- comprobador suelto, NO va en el target de la app.
//
//  SE CORRE EN EL MAC, con una linea y sin abrir Xcode:
//
//      cd ~/Documents/conrraios
//      clang -fobjc-arc -framework Foundation \
//            "pruebas/PruebaPuertaVerificacion.m" \
//            "Conrra/InDriver/App Logic/Utility/ConrraPuertaVerificacion.m" \
//            -I "Conrra/InDriver/App Logic/Utility" -o /tmp/prueba_puerta && /tmp/prueba_puerta
//
//  LAS 16 COMBINACIONES. Son cuatro booleanos -- contando "el numero forma E.164 o no" --,
//  asi que el espacio entero son 16 casos y se recorren todos. Una tabla de verdad completa
//  no deja sitio donde esconderse: no hay combinacion sin comprobar.
//
//  Misma tabla que pruebas-app/PruebaPuertaVerificacion.java de Android, a proposito: la
//  decision tiene que ser la misma en los dos telefonos, y el modo de asegurarse es que las
//  dos respondan lo mismo a las mismas dieciseis preguntas.
//

#import <Foundation/Foundation.h>
#import "ConrraPuertaVerificacion.h"

static int fallos = 0;

static void igual(NSString *que, BOOL esperado, BOOL dado) {
    if (esperado == dado) {
        printf("  ok     %s -> %s\n", que.UTF8String, dado ? "SI" : "no");
    } else {
        printf("  FALLO  %s esperaba %s y dio %s\n", que.UTF8String,
               esperado ? "SI" : "no", dado ? "SI" : "no");
        fallos++;
    }
}

static BOOL verificar(BOOL puerta, BOOL sesion, BOOL hecho, NSString *num) {
    return [ConrraPuertaVerificacion hayQueVerificarConPuerta:puerta
                                                   haySesion:sesion
                                                yaVerificado:hecho
                                                  numeroE164:num];
}

static BOOL sinSalida(BOOL puerta, BOOL sesion, BOOL hecho, NSString *num) {
    return [ConrraPuertaVerificacion seQuedaSinSalidaConPuerta:puerta
                                                    haySesion:sesion
                                                 yaVerificado:hecho
                                                   numeroE164:num];
}

int main(void) {
    @autoreleasepool {
        NSString *const NUM = @"+584246454012";

        printf("\n--- el interruptor manda sobre todo lo demas ---\n");
        // Apagada: da igual lo que valga el resto. Es el seguro para apagarla sin publicar
        // una version nueva si el WhatsApp dejara de entregar.
        for (int i = 0; i < 8; i++) {
            BOOL sesion = (i & 1) != 0;
            BOOL hecho  = (i & 2) != 0;
            NSString *num = ((i & 4) != 0) ? NUM : nil;
            igual([NSString stringWithFormat:@"apagada (sesion=%d verificado=%d numero=%d)",
                   sesion, hecho, num != nil], NO, verificar(NO, sesion, hecho, num));
        }

        printf("\n--- encendida: las 8 combinaciones ---\n");
        igual(@"sesion, sin verificar, con numero  -> VERIFICA", YES, verificar(YES, YES, NO,  NUM));
        igual(@"sesion, YA verificado              -> pasa",     NO,  verificar(YES, YES, YES, NUM));
        igual(@"sin sesion (el login ya lo pide)   -> pasa",     NO,  verificar(YES, NO,  NO,  NUM));
        igual(@"sin sesion y verificado            -> pasa",     NO,  verificar(YES, NO,  YES, NUM));
        igual(@"sesion, sin verificar, SIN numero  -> pasa",     NO,  verificar(YES, YES, NO,  nil));
        igual(@"sesion, verificado, sin numero     -> pasa",     NO,  verificar(YES, YES, YES, nil));
        igual(@"sin sesion, sin verificar, sin num -> pasa",     NO,  verificar(YES, NO,  NO,  nil));
        igual(@"sin sesion, verificado, sin numero -> pasa",     NO,  verificar(YES, NO,  YES, nil));

        printf("\n--- quien se quedaria sin salida (1 de 4.867, medido) ---\n");
        igual(@"sesion, sin verificar, sin numero  -> SI, hay que avisar",
              YES, sinSalida(YES, YES, NO, nil));
        igual(@"con numero no se queda sin salida",  NO, sinSalida(YES, YES, NO,  NUM));
        igual(@"con la puerta apagada, nadie",       NO, sinSalida(NO,  YES, NO,  nil));
        igual(@"ya verificado, no se queda sin salida", NO, sinSalida(YES, YES, YES, nil));

        printf("\n--- la cadena vacia cuenta como 'sin numero', no como numero ---\n");
        // En iOS una cadena vacia aparece donde Java pondria null, asi que las dos tienen
        // que significar lo mismo. Si no, un "" se tomaria por un numero bueno y se
        // bloquearia a quien no puede verificar: justo lo que la regla evita.
        igual(@"vacia no bloquea",            NO,  verificar(YES, YES, NO, @""));
        igual(@"vacia deja sin salida",       YES, sinSalida(YES, YES, NO, @""));

        printf("\n--- la propiedad que importa: nunca las dos a la vez ---\n");
        // Si las dos dieran SI, se le estaria bloqueando a la vez que se dice que no puede
        // verificar. Son 16 casos: se comprueban todos, no una muestra.
        BOOL choque = NO;
        for (int i = 0; i < 16; i++) {
            BOOL puerta = (i & 1) != 0;
            BOOL sesion = (i & 2) != 0;
            BOOL hecho  = (i & 4) != 0;
            NSString *num = ((i & 8) != 0) ? NUM : nil;
            if (verificar(puerta, sesion, hecho, num) && sinSalida(puerta, sesion, hecho, num)) {
                choque = YES;
                printf("  FALLO  las dos a la vez en puerta=%d sesion=%d hecho=%d numero=%d\n",
                       puerta, sesion, hecho, num != nil);
                fallos++;
            }
        }
        igual(@"ninguna de las 16 da las dos a la vez", NO, choque);

        printf("\n--- la clave es por usuario, nunca global ---\n");
        igual(@"con id, hay clave",   YES, [ConrraPuertaVerificacion claveDe:@"1849"] != nil);
        igual(@"ids distintos, claves distintas", YES,
              ![[ConrraPuertaVerificacion claveDe:@"1"]
                isEqualToString:[ConrraPuertaVerificacion claveDe:@"2"]]);
        igual(@"sin id, no hay clave", YES, [ConrraPuertaVerificacion claveDe:nil] == nil);
        igual(@"id vacio, no hay clave", YES, [ConrraPuertaVerificacion claveDe:@"   "] == nil);

        printf("\n");
        if (fallos == 0) {
            printf("  PUERTA DE VERIFICACION: todas en verde\n\n");
            return 0;
        }
        printf("  SUSPENDE: %d fallo(s)\n\n", fallos);
        return 1;
    }
}
