//
//  LanguageHelper.m

//
//  Created by Grepix - Baij on 27/01/20.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import "LanguageHelper.h"

@implementation LanguageHelper
{
    NSMutableDictionary * arrLanguageData;
    NSArray * arrLanguageList;
}

-(NSArray *) getLanguageList
{
    return arrLanguageList;
}
+ (instancetype)sharedInstance
{
    static LanguageHelper *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[LanguageHelper alloc] init];
        
        NSString *lng = [[NSUserDefaults standardUserDefaults]objectForKey:@"language"];
        if (lng.length ==0) {
            sharedInstance.cunnrentLanguage=@"en";
        }else{
            sharedInstance.cunnrentLanguage=lng;
        }
        sharedInstance->arrLanguageList=defaults_object(@"language_dict_list");
        NSDictionary * dictData=defaults_object(@"language_dict_data");
        sharedInstance->arrLanguageData=[[NSMutableDictionary alloc] initWithDictionary:dictData];
        // Do any other initialisation stuff here
    });
    return sharedInstance;
}

-(void)setLanguageListData:(NSArray *)array{
    if([array isKindOfClass:[NSArray class]]){
        self->arrLanguageList=array;
        NSString *lng = [[NSUserDefaults standardUserDefaults]objectForKey:@"language"];
        if (lng.length ==0) {
            NSString *deviceLanguage = [[[NSBundle mainBundle] preferredLocalizations] objectAtIndex:0];
            for (NSDictionary * dict in self->arrLanguageList) {
//                if([[dict objectForKey:@"is_default"] boolValue])
                if([[dict objectForKey:@"code"] isEqualToString:deviceLanguage]) {
                    self.cunnrentLanguage=[dict objectForKey:@"code"];
                    break;
                }
            }
        }
        defaults_set_object(@"language_dict_list", array);
    }
}


//-(void) getLanguageFromServerWithCompletionBlock:(void (^)(id results, NSError *error)) block
//{
//    [GIC mkwerwu:@"localisationapi/getlocalisations"
//                                    d:nil /*@{@"type":@"r"}*/
//            cb:^(id results, NSError *error) {
//        if([[results objectForKey:P_RESPONSE] isKindOfClass:[NSDictionary class]])
//        {
//            self->arrLanguageData=[results objectForKey:P_RESPONSE];
//            defaults_set_object(@"language_dict_data", self->arrLanguageData);
////            [self getLanguageListWithCompletionBlock:block];
//            block(results,error);
//        }else{
//            block(results,error);
//        }
//    }];
//}

-(void) getLanguageFromServerWithCompletionBlock:(void (^)(id results, NSError *error)) block
{
    NSString * version = defaults_object(@"language_ver");
    NSMutableDictionary *dict=[[NSMutableDictionary alloc] init];
//    version=@"116";
    if(version.length){
        [dict setObject:version forKey:@"ver"];
    }
    [GIC mkwerwu:@"localisationapi/getlocalisations"
                                    d:dict/*@{@"type":@"r"}*/
                         cb:^(id results, NSError *error) {
        if([[results objectForKey:P_RESPONSE] isKindOfClass:[NSDictionary class]])
        {
            NSString * version = [results objectForKey:@"latest_version"];
            if(version){
                defaults_set_object(@"language_ver", [results objectForKey:@"latest_version"]);
            }
            NSDictionary *dictLanguageTemp= [results objectForKey:P_RESPONSE];
//            NSArray *allOldKeys=[self->arrLanguageData allKeys];
            NSArray *allNewKeys=[dictLanguageTemp allKeys];
            for (NSString *key in allNewKeys) {
                [self->arrLanguageData setObject:[dictLanguageTemp objectForKey:key] forKey:key];
            }
            defaults_set_object(@"language_dict_data", self->arrLanguageData);

            // Debug helper: verify ES values match the UI defaultValue strings we used for new designs.
            // This can only be verified at runtime because `language_dict_data` comes from the backend.
            // Enable the flag below temporarily if you need to confirm mismatches.
            BOOL kValidateESAgainstDefaultValues = NO;
            if(kValidateESAgainstDefaultValues){
                NSString *targetLang = self.cunnrentLanguage ?: @"es";
                if([targetLang hasPrefix:@"es"]) {
                    NSDictionary *expected = @{
                        // OTP SignUp referral
                        @"k_s10_referral_desc": @"Si tienes un código de Referido escríbelo aquí para continuar",
                        @"k_s10_referral_code_optional": @"Código de Referido (Opcional)",

                        // Edit profile placeholders (values used as fallbacks in code)
                        @"k_13_s1_email": @"Correo electrónico",
                        @"k_2_s1_mobile_number_hint": @"Número de teléfono",

                        // Settings / mobile payment
                        @"k_s10_mobile_payment_data": @"DATOS PARA PAGO MÓVIL",
                        @"k_s10_data_shown_to_passenger": @"Estos datos serán mostrados a tu pasajero",
                        @"k_s10_select_bank": @"Seleccione Banco",
                        @"k_s10_phone_example": @"Ej. 4129876543",
                        @"k_s10_id_doc_type": @"Tipo de Documento ID",
                        @"k_s10_doc_number_example": @"Ej. 15800645",

                        // Route input
                        @"k_s10_your_location": @"Tu ubicación",
                        @"k_s10_where_are_you_going": @"¿A dónde vas?",

                        // Payment method selection
                        @"k_s10_payment_methods": @"Métodos de pago",
                        @"k_r39_s9_cash": @"Efectivo",
                        @"k_s10_pay_bs_usd": @"Paga en Bs. o USD",
                        @"k_s10_mobile_payment": @"Pago Móvil",
                        @"k_s10_transfer_and_report": @"Transfiere y reporta tu pago",
                        @"k_s10_my_wallet": @"Mi Billetera",
                        @"k_s10_balance_format": @"Saldo: $%.2f",

                        // Fare offer / extras
                        @"k_s10_recommended_price": @"Precio recomendado",
                        @"k_s10_conversion_usd": @"Conversión a USD",
                        @"k_s10_settings": @"Configuración",
                        @"k_s10_pay_with_format": @"Paga con %@",
                        @"k_s10_default": @"Default",
                        @"k_s10_request_taxi": @"Pedir Taxi",
                        @"k_s10_more_than_4_passengers": @"Llevo más de 4 Personas",
                        @"k_s10_4_passengers_limit": @"4 Personas es el límite por vehículo",
                        @"k_s10_i_have_pets": @"Llevo mascotas",
                        @"k_s10_some_drivers_pet_friendly": @"Algunos conductores son Pet Friendly",
                        @"k_s10_its_delivery": @"Es un delivery",
                        @"k_s10_sending_package": @"Estoy enviando un paquete a otra persona",

                        // Onboarding
                        @"k_s10_onboarding_1_title": @"Elige tu punto de recogida 📍",
                        @"k_s10_onboarding_1_body": @"Indica dónde quieres que te busquemos y te asignamos al conductor más cercano, ya sea en moto o carro.",
                        @"k_s10_onboarding_2_title": @"Viajes rápidos y seguros 🔐",
                        @"k_s10_onboarding_2_body": @"Conductores verificados, precios claros y recorridos en tiempo real para que llegues seguro y sin complicaciones.",
                        @"k_s10_onboarding_3_title": @"Negocia tu tarifa antes de salir 💰",
                        @"k_s10_onboarding_3_body": @"Propón tu precio, recibe ofertas de conductores y elige la opción que mejor se ajuste a tu presupuesto y a tu tiempo.",
                        @"k_s10_onboarding_4_title": @"Moto o Carro, tú decides 🚖",
                        @"k_s10_onboarding_4_body": @"Elige el tipo de vehículo que mejor se adapte a tu tiempo, presupuesto y ruta del día.",
                    };

                    NSInteger mismatchCount = 0;
                    for (NSString *key in expected) {
                        NSDictionary *dictLn = [self->arrLanguageData objectForKey:key];
                        NSString *serverVal = nil;
                        if([dictLn isKindOfClass:[NSDictionary class]]) {
                            serverVal = [dictLn objectForKey:targetLang];
                            if(!serverVal) serverVal = [dictLn objectForKey:@"en"];
                        }
                        NSString *exp = [expected objectForKey:key];
                        BOOL matches = serverVal && [serverVal isKindOfClass:[NSString class]] && exp && [serverVal isEqualToString:exp];
                        if(!matches) {
                            mismatchCount++;
                            NSLog(@"[LangCheck][ESMismatch] key=%@ lang=%@ server='%@' expected='%@'",
                                  key, targetLang, (serverVal ?: @"<nil>"), (exp ?: @"<nil>"));
                        }
                    }
                    NSLog(@"[LangCheck] done. mismatchCount=%ld targetLang=%@", (long)mismatchCount, targetLang);
                }
            }

            block(results,error);
        }else{
            block(results,error);
        }
    }];
}

//-(void) getLanguageListWithCompletionBlock:(void (^)(id results, NSError *error)) block
//{
//    [GIC mkwerwu:@"localisationapi/getlanguages"
//                                    d:nil
//            cb:^(id results, NSError *error) {
//        if([[results objectForKey:P_RESPONSE] isKindOfClass:[NSArray class]])
//        {
//            self->arrLanguageList=[results objectForKey:P_RESPONSE];
//            NSString *lng = [[NSUserDefaults standardUserDefaults]objectForKey:@"language"];
//            if (lng.length ==0) {
//                for (NSDictionary * dict in self->arrLanguageList) {
//                    if([[dict objectForKey:@"is_default"] boolValue])
//                    {
//                        self.cunnrentLanguage=[dict objectForKey:@"code"];
//
//                        break;
//                    }
//                }
//            }
//            defaults_set_object(@"language_dict_list", self->arrLanguageList);
//        }
//        block(results,error);
//    }];
//}


-(NSString *) getStringWithKey:(NSString *) key currentLanguage:(NSString * ) language
{
    
    NSDictionary * dictLn=[arrLanguageData objectForKey:key];
    if(dictLn&&[dictLn isKindOfClass:[NSDictionary class]])
    {
        NSString * string=[dictLn objectForKey:self.cunnrentLanguage];
        if(string)
        {
            return string;
        }
        NSString * stringDefault=[dictLn objectForKey:@"en"];
        if(stringDefault)
        {
            return stringDefault;
        }
        return key;
    }
    return key;
}


-(NSString *) getStringWithKey:(NSString *) key currentLanguage:(NSString * ) language defaultValue:(NSString*) defaultValue
{
    
    NSDictionary * dictLn=[arrLanguageData objectForKey:key];
    if(dictLn&&[dictLn isKindOfClass:[NSDictionary class]])
    {
        // For the new design copy (k_s10_* keys), force Spanish to use the in-code fallback strings.
        // This guarantees the UI matches the design text even if the server translations differ.
        static NSSet<NSString *> *kNewDesignKeysForceFallbackInES;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            kNewDesignKeysForceFallbackInES = [NSSet setWithArray:@[
                // Driver availability toggle copy (must match UI logic)
                @"k_2_s14_go_online_accept_ride",  // defaultValue: Iniciar actividad
                @"k_9_s8_go_offline",              // defaultValue: Detenerme

                // Offline paragraph (driver main screen)
                @"k_1_s14_you_are_offline",

                // Driver trip pill copy
                @"k_s10_in_trip",

                // OTP subtitle (login OTP)
                @"k_18_s4_plz_ask_psngr_fr_otp",

                // OTP SignUp referral
                @"k_s10_referral_desc",
                @"k_s10_referral_code_optional",

                // Settings / mobile payment
                @"k_s10_mobile_payment_data",
                @"k_s10_data_shown_to_passenger",
                @"k_s10_select_bank",
                @"k_s10_phone_example",
                @"k_s10_id_doc_type",
                @"k_s10_doc_number_example",

                // Route input / home
                @"k_s10_your_location",
                @"k_s10_where_are_you_going",

                // Payment method selection
                @"k_s10_payment_methods",
                @"k_s10_pay_bs_usd",
                @"k_s10_mobile_payment",
                @"k_s10_transfer_and_report",
                @"k_s10_my_wallet",
                @"k_s10_balance_format",

                // Fare offer / extras
                @"k_s10_recommended_price",
                @"k_s10_conversion_usd",
                @"k_s10_settings",
                @"k_s10_pay_with_format",
                @"k_s10_default",
                @"k_s10_request_taxi",
                @"k_s10_more_than_4_passengers",
                @"k_s10_4_passengers_limit",
                @"k_s10_i_have_pets",
                @"k_s10_some_drivers_pet_friendly",
                @"k_s10_its_delivery",
                @"k_s10_sending_package",

                // Onboarding
                @"k_s10_onboarding_1_title",
                @"k_s10_onboarding_1_body",
                @"k_s10_onboarding_2_title",
                @"k_s10_onboarding_2_body",
                @"k_s10_onboarding_3_title",
                @"k_s10_onboarding_3_body",
                @"k_s10_onboarding_4_title",
                @"k_s10_onboarding_4_body",
            ]];
        });
        NSString *langCode = self.cunnrentLanguage ?: @"";
        if (defaultValue.length > 0 &&
            [langCode hasPrefix:@"es"] &&
            [kNewDesignKeysForceFallbackInES containsObject:key]) {
            return defaultValue;
        }

        NSString * string=[dictLn objectForKey:self.cunnrentLanguage];
        if(string)
        {
            return string;
        }
        NSString * stringDefault=[dictLn objectForKey:@"en"];
        if(stringDefault)
        {
            return stringDefault;
        }
        return defaultValue;
    }
    return defaultValue;
}


+(NSString *) getStringWithKey:(NSString *) key defaultValue:(NSString*) defaultValue
{
    return  [[LanguageHelper sharedInstance] getStringWithKey:key currentLanguage:@"en" defaultValue:defaultValue];
}

+(NSString *) getStringWithKey:(NSString *) key
{
    return  [[LanguageHelper sharedInstance] getStringWithKey:key currentLanguage:@"en"];
}

+(NSString *) loginScreenTitle
{
    NSString *s = [[LanguageHelper sharedInstance] getStringWithKey:@"k_6_s1_login" currentLanguage:[LanguageHelper sharedInstance].cunnrentLanguage defaultValue:@"Iniciar sesión"];
    return [s isEqualToString:@"Acceso"] ? @"Iniciar sesión" : s;
}

-(void) configureLanguage
{
    NSString *lng = [[NSUserDefaults standardUserDefaults]objectForKey:@"language"];
    if (lng.length ==0) {
        NSString *deviceLanguage = [[[NSBundle mainBundle] preferredLocalizations] objectAtIndex:0];
        for (NSDictionary * dict in [[LanguageHelper sharedInstance] getLanguageList]) {
            
//            if([[dict objectForKey:@"is_default"] boolValue])
            if([[dict objectForKey:@"code"] isEqualToString:deviceLanguage])
            {
                if([[dict objectForKey:@"is_rtl"] boolValue])
                {
                    [[UIView appearance] setSemanticContentAttribute:UISemanticContentAttributeForceRightToLeft];
                }else{
                    [[UIView appearance] setSemanticContentAttribute:UISemanticContentAttributeForceLeftToRight];
                }
                break;
            }
        }
    }else{
        for (NSDictionary * dict in [[LanguageHelper sharedInstance] getLanguageList]) {
            if([[dict objectForKey:@"code"] isEqualToString:lng])
            {
                if([[dict objectForKey:@"is_rtl"] boolValue])
                {
                    [[UIView appearance] setSemanticContentAttribute:UISemanticContentAttributeForceRightToLeft];
                }else{
                    [[UIView appearance] setSemanticContentAttribute:UISemanticContentAttributeForceLeftToRight];
                }
                break;
            }
        }
    }
}

-(NSString *) getlcidForCode:(NSString*)code{
    for (NSDictionary * dict in [[LanguageHelper sharedInstance] getLanguageList]) {
        if([[dict objectForKey:@"code"] isEqualToString:code])   {
            return [dict objectForKey:@"lcid"];
            break;
        }
    }
    return code;
}
+(NSString *) getlcidCurrent{
    return [[LanguageHelper sharedInstance] getlcidForCode:[LanguageHelper sharedInstance].cunnrentLanguage];
}
@end

