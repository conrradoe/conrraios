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
            self.otp_off=[[dict objectForKey:@"cvalue"] boolValue];
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
    self.is_stripe_live = NO;
    self.otp_off = YES;
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


+(ConstantModel *) getConstantsObject{
    if(instance!=nil){
        return instance;
    }
    NSArray * arr = defaults_object(@"constantResponse");
    if([arr isKindOfClass:[NSArray class]]&&arr.count>0) {
        arrayConstants=arr;
        instance =[[ConstantModel alloc]initItemWithDict:arr];
        
        [instance manageCP];
        return instance;
    }
    return nil;
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
