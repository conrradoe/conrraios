//
//  ConstantModel.m
//  HireMe Rider
//
//  Created by  Appicial on 04/09/17.
//  Copyright © 2023 Appicial. All rights reserved.
//

#import "ConstantModel.h"
#import "CityModel.h"
#import <GIKit/GIKit.h>
#import "WebCallConstants.h"
#import "Keys.h"
static NSArray *arrayConstants;
static ConstantModel *instance;
static NSDictionary *enableInfo;
@implementation ConstantModel


- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.constant_driver_radius =4.0;
        self.max_phone_length=MOBILE_DIGIT;
        self.min_phone_length=Mobile_Min_Length;
        self.min_password_length=Password_Length;
        self.max_time_span=60;
    }
    return self;
}

-(instancetype)initItemWithDict:(NSArray *)array;
{
    self = [super init];
    if (self) {
        self.max_time_span=60;
        [self parserData:array];
    }
    
    return self;
    
}


-(void) parserData:(NSArray *)array{
    BOOL is_stripe_live_key_found = NO; 
    self.max_decimal_allowed=1;
    self.dummy_driver_count = 10;
    self.dummy_driver_radius = 1;
    for (NSDictionary *dict in array) {
        if ([[dict objectForKey:@"ckey"]isEqualToString:@"driver_radius"]){ 
            float constntValue = [[dict objectForKey:@"cvalue"] floatValue];
            self.constant_driver_radius=constntValue;
        }
        else if ([[dict objectForKey:@"ckey"]isEqualToString:@"enable_aboutus"]){
            self.enable_aboutus=[[dict objectForKey:@"cvalue"] boolValue];
        }
        else if ([[dict objectForKey:@"ckey"]isEqualToString:@"enable_pp"]){
            self.enable_pp=[[dict objectForKey:@"cvalue"] boolValue];
        }
        else if ([[dict objectForKey:@"ckey"]isEqualToString:@"otp_end"]){
            self.otp_end=[[dict objectForKey:@"cvalue"] boolValue];
        }
        else if ([[dict objectForKey:@"ckey"]isEqualToString:@"otp_start"]){
            self.otp_start=[[dict objectForKey:@"cvalue"] boolValue]; 
        }
        else if ([[dict objectForKey:@"ckey"]isEqualToString:@"gkey"]){
            self.gKey=[dict objectForKey:@"cvalue"] ;
        }  else if ([[dict objectForKey:@"ckey"]isEqualToString:@"ios_driver_app_ver"]){
            self.ios_app_ver=[dict objectForKey:@"cvalue"] ; 
        }else if ([[dict objectForKey:@"ckey"]isEqualToString:@"support_email"]){
            self.support_email=[dict objectForKey:@"cvalue"] ;
        }else if ([[dict objectForKey:@"ckey"]isEqualToString:@"share_text_driver"]){
            self.share_text=[dict objectForKey:@"cvalue"] ;
        }
        else if ([[dict objectForKey:@"ckey"]isEqualToString:@"app_prefix"]){
            self.app_prefix=[dict objectForKey:@"cvalue"] ;
        }
        else if ([[dict objectForKey:@"ckey"]isEqualToString:@"min_password_length"]){
            self.min_password_length=[[dict objectForKey:@"cvalue"] intValue];
        }
        else if ([[dict objectForKey:@"ckey"]isEqualToString:@"min_phone_length"]){
            self.min_phone_length=[[dict objectForKey:@"cvalue"] intValue];
        }
        else if ([[dict objectForKey:@"ckey"]isEqualToString:@"max_phone_length"]){
            self.max_phone_length=[[dict objectForKey:@"cvalue"] intValue];
        }
        else if ([[dict objectForKey:@"ckey"]isEqualToString:@"enable_share"]){
            self.enable_share=[[dict objectForKey:@"cvalue"] boolValue];
        }
        else if ([[dict objectForKey:@"ckey"]isEqualToString:@"enable_contactus"]){
            self.enable_contactus=[[dict objectForKey:@"cvalue"] boolValue];
        }
          else if ([[dict objectForKey:@"ckey"]isEqualToString:@"max_time_span"]){
            self.max_time_span=[[dict objectForKey:@"cvalue"] intValue];
        }else if ([[dict objectForKey:@"ckey"]isEqualToString:@"stripe_s_key"]){
            self.stripe_s_key=[dict objectForKey:@"cvalue"] ;
        }
        else if ([[dict objectForKey:@"ckey"]isEqualToString:@"stripe_p_key"]){
            self.stripe_p_key=[dict objectForKey:@"cvalue"] ;
        }
        else if ([[dict objectForKey:@"ckey"]isEqualToString:@"stripe_s_dev_key"]){
            self.stripe_s_dev_key=[dict objectForKey:@"cvalue"] ;
        }  
        else if ([[dict objectForKey:@"ckey"]isEqualToString:@"stripe_p_dev_key"]){
            self.stripe_p_dev_key=[dict objectForKey:@"cvalue"] ;
        }
        else if ([[dict objectForKey:@"ckey"]isEqualToString:@"is_stripe_live"]){
            self.is_stripe_live=[[dict objectForKey:@"cvalue"] boolValue] ;
            is_stripe_live_key_found= YES;
        }  else if ([[dict objectForKey:@"ckey"]isEqualToString:@"currency_conversion"]){
            self.currency_conversion=[dict objectForKey:@"cvalue"] ;
        } else if ([[dict objectForKey:@"ckey"]isEqualToString:@"otp_off"]){
            /*
             SE LEE COMO LO LEE ANDROID: apagado solo si el valor es exactamente "1".

             Estaba con boolValue, y eso no es lo mismo. boolValue dice SI para "true", "yes",
             "t", "y" o cualquier digito que no sea cero; Android compara con "1" y nada mas
             (OTPActivity.otpApagado). O sea que un `otp_off` puesto a "true" en la tabla
             apagaria la verificacion en iOS y la dejaria encendida en Android, con el mismo
             servidor. Divergencias asi son las que mandan a buscar el fallo al sitio
             equivocado.

             Se pasa por stringWithFormat antes de comparar porque cvalue puede llegar como
             numero y no como texto segun el JSON, y isEqualToString con un NSNumber no
             compara nada.
             */
            NSString *valor = [NSString stringWithFormat:@"%@", [dict objectForKey:@"cvalue"]];
            self.otp_off = [[valor stringByTrimmingCharactersInSet:
                             [NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@"1"];
        }else if ([[dict objectForKey:@"ckey"]isEqualToString:@"exp_time"]){
            self.exp_time=[[dict objectForKey:@"cvalue"] intValue];
        }else if ([[dict objectForKey:@"ckey"]isEqualToString:@"common_api_ver"]){
            self.common_api_ver=[[dict objectForKey:@"cvalue"] intValue];
        }else if ([[dict objectForKey:@"ckey"]isEqualToString:@"enable_chat"]){
            self.enable_chat=[[dict objectForKey:@"cvalue"] boolValue];
        }
        else if ([[dict objectForKey:@"ckey"]isEqualToString:@"is_demo"]){
            self.is_demo=[[dict objectForKey:@"cvalue"] boolValue];
            
        }
        else if ([[dict objectForKey:@"ckey"]isEqualToString:@"offer_step_amount"]){
           self.offer_step_amount=[[dict objectForKey:@"cvalue"] floatValue];
       }else if ([[dict objectForKey:@"ckey"]isEqualToString:@"dummy_driver_count"]){
           self.dummy_driver_count=[[dict objectForKey:@"cvalue"] intValue];
       }
       else if ([[dict objectForKey:@"ckey"]isEqualToString:@"dummy_driver_radius"]){
           self.dummy_driver_radius=[[dict objectForKey:@"cvalue"] floatValue];
       }
        else if ([[dict objectForKey:@"ckey"]isEqualToString:@"def_location"]){
            NSString * def_location=[dict objectForKey:@"cvalue"];
            NSArray *array=[def_location componentsSeparatedByString:@"|"];
            if(array.count>1){
                float lat=[[array objectAtIndex:0] floatValue];
                float lng=[[array objectAtIndex:1] floatValue];
                self.def_location=[[CLLocation alloc] initWithLatitude:lat longitude:lng];
            }
        }else if ([[dict objectForKey:@"ckey"]isEqualToString:@"max_decimal_allowed"]){
            self.max_decimal_allowed=[[dict objectForKey:@"cvalue"] intValue];
        }else if(  [[dict objectForKey:@"ckey"] isEqualToString:@"car_brands"]){
            self.car_brands = [dict objectForKey:@"cvalue"];
        }
    }
#if TARGET_OS_SIMULATOR
    /*
     AQUI YA NO SE APAGA EL OTP, y antes si: habia un `self.otp_off = YES;`.

     Eso pisaba la constante del servidor sin decir nada. Con la verificacion ENCENDIDA en el
     backend, el app se comportaba como si estuviera apagada: no le pedia el codigo a nadie,
     rellenaba las casillas con un numero que ella misma se inventaba y dejaba pasar. Android
     no tiene ese atajo, asi que el mismo backend daba dos comportamientos y el de iOS parecia
     un fallo del proveedor.

     Una bandera local que contradice al servidor es una mentira que se cuenta el propio
     programa, y se paga buscando el fallo en el sitio equivocado -- aqui, en el rele.

     Lo que se pierde: en el simulador ya hay que teclear el codigo de verdad, el que llega
     por WhatsApp al telefono que se registra. Es lo mismo que hay que hacer en un aparato,
     que es donde se prueba lo que se va a publicar.

     is_stripe_live SI se queda: no inventa nada, solo evita cobrar de verdad mientras se
     desarrolla.
     */
    self.is_stripe_live = NO;
#else

#endif
    
    if(is_stripe_live_key_found){
        if(self.is_stripe_live==NO){
            self.stripe_p_key=self.stripe_p_dev_key;
            self.stripe_s_key=self.stripe_s_dev_key;
        }
    }else{
        self.is_stripe_live = YES;
    }
    
}

-(void) refreshObject{
    NSArray * arr = defaults_object(@"constantResponse");
    if([arr isKindOfClass:[NSArray class]]&&arr.count>0) {
        [self parserData:arr];
    }
}


/**
 Las constantes del servidor, y FRESCAS.

 ================== POR QUE SE COMPRUEBA SI CAMBIARON ==================
 Antes esto devolvia el objeto en cuanto existia, sin volver a mirar el disco. Y el objeto se
 construye la PRIMERA vez que alguien lo pide, que es antes de que LoadingViewController haya
 traido las constantes del servidor y las haya guardado. O sea: durante todo el arranque se
 leia la copia GUARDADA de la vez anterior, y despues ya nadie volvia a construirlo. El valor
 de la vez anterior se quedaba puesto hasta matar la app.

 Eso produce una diferencia feisima entre un aparato y un simulador recien instalado. En el
 simulador no hay copia guardada: devolvia nil, y como en Objective-C una propiedad de nil
 vale 0, `otp_off` salia NO y la verificacion se pedia bien. En un telefono que ya se habia
 usado se leia el `otp_off` guardado de otra epoca, y si ahi estaba a 1 el app se saltaba la
 verificacion entera. Mismo codigo, mismo servidor, dos comportamientos.

 El resto de esta clase ya desconfiaba del singleton: hay tres metodos mas abajo que releen
 `constantResponse` del disco en CADA llamada. Esto los pone de acuerdo.

 Cuesta poco: NSUserDefaults sirve de memoria despues de la primera lectura, y el array son
 unas docenas de entradas.
 =======================================================================

 SIGUE DEVOLVIENDO nil cuando no hay constantes, y conviene saber por que no es un descuido:
 con nil, `constantes.otp_off` vale NO y la verificacion se da por ENCENDIDA. Si hay que
 equivocarse, es mejor pedir un codigo de mas que dejar entrar sin comprobar nada.
 */
+(ConstantModel *) getConstantsObject{
    NSArray * arr = defaults_object(@"constantResponse");
    BOOL hayGuardadas = [arr isKindOfClass:[NSArray class]] && arr.count > 0;

    // Lo que ya hay sirve solo si no han cambiado las de disco.
    if (instance != nil && (!hayGuardadas || [arr isEqualToArray:arrayConstants])) {
        return instance;
    }
    if (hayGuardadas) {
        arrayConstants = arr;
        instance = [[ConstantModel alloc] initItemWithDict:arr];
        [instance manageCP];
        return instance;
    }
    return instance;
}


-(void)manageCP{
    NSDictionary *enb=[self isUserContainEnableJson];
    if(enb){
        enableInfo=[[NSDictionary alloc] initWithDictionary:enb];
    }else{
        NSDictionary * dicCp = defaults_object(@"constants_p");
        if(dicCp){
            NSObject *jsonString = [dicCp objectForKey:@"json"];
            if([jsonString isKindOfClass:[NSDictionary class]]){
                enableInfo=(NSDictionary *)jsonString;
            }else{
                if(jsonString&&[jsonString isKindOfClass:[NSString class]]){
                    NSData *data = [(NSString *)jsonString dataUsingEncoding:NSUTF8StringEncoding];
                    if(data){
                        enableInfo = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                    }
                }
            }
        }
    }
}

-(NSDictionary *)isUserContainEnableJson{
    NSDictionary * dictUser=defaults_object(P_USER_DICT); 
    if(dictUser==nil){
        return nil;
    }
    if([dictUser isKindOfClass:[NSString class]]){
        return nil;
    }
    NSObject *jsonString = [dictUser objectForKey:@"per_json"];
    if([jsonString isKindOfClass:[NSDictionary class]]){
        return (NSDictionary *)jsonString;
    }else{
        if(jsonString&&[jsonString isKindOfClass:[NSString class]]){
            NSData *data = [(NSString *)jsonString dataUsingEncoding:NSUTF8StringEncoding];
            if(data){
                return  [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            }
        }
    }
    return nil;
}

-(BOOL) getBoolValueForKey:(NSString *) key{
    for (NSDictionary *dict in arrayConstants) {
        if ([[dict objectForKey:@"ckey"]isEqualToString:key]){
            return [[dict objectForKey:@"cvalue"] boolValue];
        }
    }
    return NO;
}

+(NSString *) valorDeConstantePorClave:(NSString *) clave {
    NSArray *arr = defaults_object(@"constantResponse");
    if (![arr isKindOfClass:[NSArray class]] || clave.length == 0) {
        return @"";
    }
    NSCharacterSet *blancos = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *buscada = [[clave stringByTrimmingCharactersInSet:blancos] lowercaseString];
    NSString *buscadaConEspacios = [buscada stringByReplacingOccurrencesOfString:@"_" withString:@" "];

    for (id elemento in arr) {
        if (![elemento isKindOfClass:[NSDictionary class]]) {
            continue;
        }
        id ckey = [(NSDictionary *)elemento objectForKey:@"ckey"];
        if (![ckey isKindOfClass:[NSString class]]) {
            continue;
        }
        NSString *actual = [[(NSString *)ckey stringByTrimmingCharactersInSet:blancos] lowercaseString];
        if ([actual isEqualToString:buscada]
            || [[actual stringByReplacingOccurrencesOfString:@"_" withString:@" "]
                isEqualToString:buscadaConEspacios]) {
            id valor = [(NSDictionary *)elemento objectForKey:@"cvalue"];
            if ([valor isKindOfClass:[NSString class]]) {
                return [(NSString *)valor stringByTrimmingCharactersInSet:blancos];
            }
            if ([valor isKindOfClass:[NSNumber class]]) {
                return [(NSNumber *)valor stringValue];
            }
            return @"";
        }
    }
    return @"";
}

+(float) tasaDolarALocal {
    // Mismo orden que Controller.getDollarToLocalRate de Android, con "bs" primero.
    NSArray *candidatos = @[@"bs", @"tasa", @"tasa_bs", @"taza", @"taza_bs",
                            @"conversion_rate", @"rate", @"currency_conversion"];
    for (NSString *candidato in candidatos) {
        NSString *crudo = [self valorDeConstantePorClave:candidato];
        if (crudo.length == 0) {
            continue;
        }
        // Hay instalaciones que escriben la tasa con coma decimal.
        float tasa = [[crudo stringByReplacingOccurrencesOfString:@"," withString:@"."] floatValue];
        if (tasa > 0) {
            return tasa;
        }
    }
    return 0;
}

/**
 Si una funcion esta encendida.

 Mira PRIMERO la tabla `constants` del backend propio y solo despues las banderas del
 servicio de licencias de Grepix. Es el orden de Android (Controller.isReferralEnabled), y
 aqui hacia falta de verdad:

 `enableInfo` se llena desde `constants_p`, que LoadingViewController escribe solo cuando
 en la respuesta de licencias hay una fila cuyo `bundleId` coincide con el del app. El
 bundle de iOS es "com.conrraapp.driver.test" y el registrado no lo es, asi que no coincide
 ninguna, `constants_p` nunca se escribe y TODAS estas banderas contestan que no. Se veia en
 el menu del pasajero: las opciones que salen de la tabla `constants` aparecian y las cinco
 que salen de aqui -- notificaciones, metodo de pago, info de tarifas, referidos y legal --
 no. En Android si salen porque su paquete si esta registrado.

 Solo se acepta el valor propio si es exactamente "1" o "0"; cualquier otra cosa sigue de
 largo hacia las licencias. Eso lo hace inmune a una colision de nombres: una constante con
 ckey "en" y cvalue "English" no puede encender ni apagar nada por accidente.
 */
-(BOOL) getCValueFK:(NSString *) key{
    NSString *propia = [ConstantModel valorDeConstantePorClave:key];
    if ([propia isEqualToString:@"1"]) {
        return YES;
    }
    if ([propia isEqualToString:@"0"]) {
        return NO;
    }
    if ([enableInfo isKindOfClass:[NSDictionary class] ]){
        return [[enableInfo objectForKey:key] boolValue];
    }
    return NO;
}
@end
