//
//  ConrraPropinas.h
//  Conrra
//
//  Equivalente de com.conrra.merged.common.propina.PropinasRemotas (Android).
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/** Una propina por ver (conductor) o unas gracias por ver (pasajero). */
@interface ConrraPropinaAviso : NSObject

@property (nonatomic, assign) long long propinaId;
@property (nonatomic, assign) double    monto;

/// Conductor: quien la envia. Pasajero: el conductor que agradece.
@property (nonatomic, copy)   NSString *quien;

/// Solo en las gracias: lo que escribio el conductor.
@property (nonatomic, copy)   NSString *texto;

@end

/**
 Las propinas del taxi: el pasajero la da, el conductor la ve y da las gracias si quiere, y el
 pasajero ve esas gracias.

 ===================== EL DINERO LO MUEVE EL SERVIDOR =====================
 Aqui solo se pide y se cuenta. El traspaso de una billetera a la otra lo hace
 conrraservices.com/taxi, igual que el cobro del viaje lo hace apps.conrra.com.

 Y eso no es un detalle de reparto: esta app ya cobro dos veces la billetera de un pasajero
 por hacer con dinero lo que le tocaba al servidor -- 67 viajes en Android y los que se
 midieron en iOS el 2026-11-24. Una propina que la app descontara por su cuenta seria el
 mismo error con otro nombre. Ver ConrraPagoDeViaje.
 ==========================================================================

 LA FIRMA NO SE INVENTA AQUI. Las cuatro llamadas van por RecargaEstilo, que ya pone la
 api_key de la cuenta en sesion -- y sabe que vive en dos sitios segun por donde se haya
 entrado. Es lo mismo que hace SesionPasajero.firmar en Android, y ya estaba resuelto en iOS:
 escribir un segundo cliente para conrraservices seria una copia que se desvia.
 */
@interface ConrraPropinas : NSObject

/**
 El pasajero da la propina: sale de su billetera y entra en la del conductor.

 @param saldo lo que le queda al pasajero, o -1 si el servidor no lo dijo.
 */
+ (void)darEnViaje:(nullable NSString *)tripId
             monto:(double)monto
     cuandoTermine:(void (^)(BOOL ok, NSString *_Nullable error, double saldo))bloque
    NS_SWIFT_NAME(darEnViaje(_:monto:cuandoTermine:));

/**
 Las propinas que el conductor todavia no ha visto.

 Sin sesion no sale a la red: el bloque no se llama, igual que en Android. Asi la pantalla no
 tiene que saber si hay sesion para preguntar.
 */
+ (void)pendientesDelConductor:(void (^)(NSArray<ConrraPropinaAviso *> *avisos))bloque
    NS_SWIFT_NAME(pendientesDelConductor(_:));

/// El conductor cierra el aviso; con gracias=YES se las manda al pasajero.
+ (void)cerrar:(long long)propinaId
       gracias:(BOOL)gracias
         texto:(nullable NSString *)texto NS_SWIFT_NAME(cerrar(_:gracias:texto:));

/// Las gracias que el pasajero todavia no ha visto.
+ (void)graciasDelPasajero:(void (^)(NSArray<ConrraPropinaAviso *> *avisos))bloque
    NS_SWIFT_NAME(graciasDelPasajero(_:));

@end

NS_ASSUME_NONNULL_END
