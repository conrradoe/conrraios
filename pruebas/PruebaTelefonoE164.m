//
//  PruebaTelefonoE164.m
//  Conrra -- comprobador suelto, NO va en el target de la app.
//
//  SE CORRE EN EL MAC, con una linea y sin abrir Xcode:
//
//      cd ~/Documents/conrraios
//      clang -fobjc-arc -framework Foundation \
//            "pruebas/PruebaTelefonoE164.m" \
//            "Conrra/InDriver/App Logic/Utility/ConrraTelefonoE164.m" \
//            -I "Conrra/InDriver/App Logic/Utility" -o /tmp/prueba_e164 && /tmp/prueba_e164
//
//  ENLAZA LA IMPLEMENTACION DE VERDAD. Eso no es un detalle: una prueba que reescribe por
//  su cuenta lo que deberia comprobar no comprueba nada, solo que sabe escribirlo dos
//  veces. Si el codigo de produccion llama a +de:nacional:, la prueba llama a
//  +de:nacional:, y si alguien la rompe, esto suspende.
//
//  La tabla de casos es la MISMA que pruebas-app/PruebaTelefonoE164.java de Android, a
//  proposito: las dos plataformas tienen que contestar lo mismo al mismo numero, y el
//  unico modo de saberlo es preguntarles lo mismo.
//

#import <Foundation/Foundation.h>
#import "ConrraTelefonoE164.h"

static int fallos = 0;

static void igual(NSString *que, NSString *esperado, NSString *dado) {
    BOOL bien = (esperado == nil) ? (dado == nil) : [esperado isEqualToString:dado];
    if (bien) {
        printf("  ok     %s -> %s\n", que.UTF8String, dado ? dado.UTF8String : "nil");
    } else {
        printf("  FALLO  %s esperaba %s y dio %s\n", que.UTF8String,
               esperado ? esperado.UTF8String : "nil", dado ? dado.UTF8String : "nil");
        fallos++;
    }
}

int main(void) {
    @autoreleasepool {
        printf("\n--- el caso que motivo la clase ---\n");
        igual(@"Venezuela como se marca alli (0424...)",
              @"+584246454012", [ConrraTelefonoE164 de:@"58" nacional:@"04246454012"]);
        igual(@"Venezuela ya en E.164",
              @"+584246454012", [ConrraTelefonoE164 de:@"58" nacional:@"4246454012"]);
        igual(@"los dos tienen que dar LO MISMO",
              [ConrraTelefonoE164 de:@"58" nacional:@"4246454012"],
              [ConrraTelefonoE164 de:@"58" nacional:@"04246454012"]);

        // Los paises que de verdad hay en la base, con sus usuarios: es la MISMA tabla que
        // pruebas-panel/telefono_java_vs_php.php de Android, que compara el calculo de Java
        // con el de PHP. Ahora hay TRES implementaciones del mismo calculo -- Java, PHP y
        // esta --, y tres implementaciones se separan solas si nadie les pregunta lo mismo.
        igual(@"Venezuela (4.777 usuarios)", @"+584246454012",
              [ConrraTelefonoE164 de:@"58" nacional:@"4246454012"]);
        igual(@"Panama (31)", @"+50766314100",
              [ConrraTelefonoE164 de:@"507" nacional:@"66314100"]);
        igual(@"India (21)", @"+919876543210",
              [ConrraTelefonoE164 de:@"91" nacional:@"9876543210"]);
        igual(@"Chile (8)", @"+56912345678",
              [ConrraTelefonoE164 de:@"56" nacional:@"912345678"]);
        igual(@"EEUU (7), con un cero DENTRO del area", @"+12025551234",
              [ConrraTelefonoE164 de:@"1" nacional:@"2025551234"]);
        igual(@"Peru (5)", @"+51987654321",
              [ConrraTelefonoE164 de:@"51" nacional:@"987654321"]);
        igual(@"Espana (4)", @"+34600123456",
              [ConrraTelefonoE164 de:@"34" nacional:@"600123456"]);
        igual(@"Colombia (4)", @"+573001234567",
              [ConrraTelefonoE164 de:@"57" nacional:@"3001234567"]);
        igual(@"Venezuela de 9 digitos, raro pero real", @"+58424645401",
              [ConrraTelefonoE164 de:@"58" nacional:@"00424645401"]);

        printf("\n--- lo que la gente teclea ---\n");
        igual(@"Panama normal", @"+50766314100", [ConrraTelefonoE164 de:@"507" nacional:@"66314100"]);
        igual(@"codigo con el mas", @"+50766314100", [ConrraTelefonoE164 de:@"+507" nacional:@"66314100"]);
        igual(@"con espacios", @"+584246454012", [ConrraTelefonoE164 de:@"58" nacional:@"424 645 4012"]);
        igual(@"con guiones", @"+50766314100", [ConrraTelefonoE164 de:@"507" nacional:@"6631-4100"]);
        igual(@"con parentesis", @"+584246454012", [ConrraTelefonoE164 de:@"58" nacional:@"(0424) 645-4012"]);
        igual(@"doble cero por error", @"+584246454012", [ConrraTelefonoE164 de:@"58" nacional:@"00424 6454012"]);

        printf("\n--- lo que NO es un numero: nil, no una cadena a medias ---\n");
        igual(@"sin codigo de pais", nil, [ConrraTelefonoE164 de:@"" nacional:@"4246454012"]);
        igual(@"codigo de pais nulo", nil, [ConrraTelefonoE164 de:nil nacional:@"4246454012"]);
        igual(@"sin numero", nil, [ConrraTelefonoE164 de:@"58" nacional:@""]);
        igual(@"numero nulo", nil, [ConrraTelefonoE164 de:@"58" nacional:nil]);
        igual(@"solo el cero de troncal", nil, [ConrraTelefonoE164 de:@"58" nacional:@"0"]);
        igual(@"demasiado corto", nil, [ConrraTelefonoE164 de:@"58" nacional:@"12345"]);
        igual(@"codigo de pais que empieza por cero", nil, [ConrraTelefonoE164 de:@"058" nacional:@"4246454012"]);
        igual(@"codigo de pais de 4 digitos", nil, [ConrraTelefonoE164 de:@"5812" nacional:@"4246454012"]);
        igual(@"pasa de 15 digitos en total", nil, [ConrraTelefonoE164 de:@"58" nacional:@"12345678901234"]);

        printf("\n--- los dos ayudantes, por separado ---\n");
        igual(@"soloDigitos quita todo lo que no es digito",
              @"5076631410", [ConrraTelefonoE164 soloDigitos:@"+507 (663) 1-410"]);
        igual(@"soloDigitos con nil", @"", [ConrraTelefonoE164 soloDigitos:nil]);
        igual(@"sinCeroDeTroncal quita los ceros de delante",
              @"4246454012", [ConrraTelefonoE164 sinCeroDeTroncal:@"004246454012"]);
        igual(@"sinCeroDeTroncal no toca los ceros de dentro",
              @"4006454012", [ConrraTelefonoE164 sinCeroDeTroncal:@"04006454012"]);
        igual(@"sinCeroDeTroncal con todo ceros", @"", [ConrraTelefonoE164 sinCeroDeTroncal:@"000"]);

        printf("\n--- la clave del telefono: el fallo que dejo sin enviar a Didit ---\n");
        // Leia `d_phone` (conductor) y las pantallas mandan `u_phone` (pasajero): salia
        // vacio y no se pedia ningun codigo. Estas suspenden si alguien lo deshace.
        igual(@"la del pasajero, que es la que llega",
              @"4246454012", [ConrraTelefonoE164 nacionalDe:@{@"u_phone": @"4246454012"}]);
        igual(@"la del conductor, si es la unica",
              @"66314100", [ConrraTelefonoE164 nacionalDe:@{@"d_phone": @"66314100"}]);
        igual(@"con las dos, manda la del pasajero",
              @"4246454012", [ConrraTelefonoE164 nacionalDe:@{@"u_phone": @"4246454012",
                                                              @"d_phone": @"66314100"}]);
        igual(@"si viene como numero y no como texto",
              @"4246454012", [ConrraTelefonoE164 nacionalDe:@{@"u_phone": @(4246454012)}]);
        igual(@"ninguna de las dos", @"",
              [ConrraTelefonoE164 nacionalDe:@{@"email": @"a@b.c"}]);
        igual(@"diccionario nulo", @"", [ConrraTelefonoE164 nacionalDe:nil]);
        igual(@"cadena vacia no cuenta como clave puesta",
              @"66314100", [ConrraTelefonoE164 nacionalDe:@{@"u_phone": @"",
                                                            @"d_phone": @"66314100"}]);

        printf("\n--- de punta a punta, como lo hace la pantalla del codigo ---\n");
        NSDictionary *delRegistro = @{@"u_phone": @"04246454012", @"c_code": @"58"};
        igual(@"usuario venezolano tal y como llega del registro",
              @"+584246454012",
              [ConrraTelefonoE164 de:delRegistro[@"c_code"]
                               nacional:[ConrraTelefonoE164 nacionalDe:delRegistro]]);

        printf("\n");
        if (fallos == 0) {
            printf("  TELEFONO E.164: todas en verde\n\n");
            return 0;
        }
        printf("  SUSPENDE: %d fallo(s)\n\n", fallos);
        return 1;
    }
}
