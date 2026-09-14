//
//  ConrraAvisoLocal.m
//  Conrra
//

#import "ConrraAvisoLocal.h"
#import <UserNotifications/UserNotifications.h>
#import <AudioToolbox/AudioToolbox.h>

NSString * const kConrraAvisoLocalMarca = @"conrra_aviso_local";

@implementation ConrraAvisoLocal

+ (void)mostrarConClaveUnica:(NSString *)clave
                      titulo:(NSString *)titulo
                       texto:(NSString *)texto
                      sonido:(NSString *)sonido {

    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    if (clave.length > 0) {
        if ([[prefs objectForKey:clave] boolValue]) {
            return;
        }
        [prefs setObject:@YES forKey:clave];
        [prefs synchronize];
    }

    UNMutableNotificationContent *contenido = [[UNMutableNotificationContent alloc] init];
    contenido.title = titulo ?: @"";
    contenido.body  = texto ?: @"";
    contenido.userInfo = @{ kConrraAvisoLocalMarca : @YES };

    if (sonido.length > 0) {
        contenido.sound = [UNNotificationSound soundNamed:sonido];
    } else {
        contenido.sound = [UNNotificationSound defaultSound];
    }

    // Sin disparador: se enseña en cuanto se entrega.
    NSString *identificador = clave.length > 0
        ? clave
        : [NSString stringWithFormat:@"conrra_aviso_%f", [[NSDate date] timeIntervalSince1970]];

    UNNotificationRequest *peticion =
        [UNNotificationRequest requestWithIdentifier:identificador
                                             content:contenido
                                             trigger:nil];

    [[UNUserNotificationCenter currentNotificationCenter]
        addNotificationRequest:peticion
         withCompletionHandler:^(NSError *error) {
        if (error) {
            NSLog(@"[AvisoLocal] no se pudo enseñar: %@", error.localizedDescription);
        }
    }];
}

+ (void)vibrar {
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}

@end
