//
//  TripTransactionManager.m
//  GetRide
//
//  Created by Grepix Infotech on 09/05/24.
//

#import "TripTransactionManager.h"
#import "CityModel.h"
#import "Utilities.h"
#import "ConrraPagoDeViaje.h"
@implementation TripTransactionManager
- (instancetype)initWithTrip:(TripModel*) trip{
    self = [super init];
    if (self) {
        self.trip = trip;
    }
    return self;
}


/**
 Registra el cobro del viaje: la comision del conductor y el apunte en la contabilidad.

 DOS COSAS QUE NO HACIA Y COSTABAN DINERO:

 1. Mandaba pay_mode clavado en "Cash". Un viaje de Pago Movil se registraba como efectivo, y
    si llegaba aqui un viaje de billetera se registraba un cobro en efectivo de un viaje que el
    servidor ya habia cobrado del saldo. Ahora el metodo lo da ConrraPagoDeViaje, que respeta
    "Pago Movil" y nunca devuelve billetera.

 2. No miraba si el viaje ya estaba pagado. El servidor marca Paid al cobrar la billetera, y
    desde el 1.0.19 el propio completed llega ya pagado cuando no es billetera. Registrar
    encima es un apunte de mas por el mismo viaje. Android lo comprueba igual en
    FareSummaryActivity.payWithCashOnHand.
 */
-(void) payWithCashDetectComssion{
    if ([ConrraPagoDeViaje esBilletera:self.trip.trip_pay_mode]) {
        // La billetera la cobra el servidor. Desde aqui no se registra NADA.
        NSLog(@"[Cobro] viaje %@ es de billetera: lo cobra el servidor, no se registra aqui",
              self.trip.trip_Id);
        [self.delegate onCashPaymentCompleted];
        return;
    }
    if ([isEmpty(self.trip.trip_pay_status) caseInsensitiveCompare:TS_PAID] == NSOrderedSame) {
        NSLog(@"[Cobro] viaje %@ ya estaba pagado: no se registra otra vez", self.trip.trip_Id);
        [self.delegate onCashPaymentCompleted];
        return;
    }
    NSDictionary *dict1 = [[NSUserDefaults standardUserDefaults]objectForKey:P_USER_DICT];
    CityModel *  cityModel= [CityModel getCityByCityId:self.trip.city_id];
    float driverCommission=0;
    if(cityModel){
        driverCommission =[self.trip.trip_fare doubleValue]*(100-cityModel.city_comm)/100;
    }
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{
        @"user_id":[NSString stringWithFormat:@"%d",self.trip.user.userId],
        @"total_amt":[Utilities formatAmount:[self.trip.trip_fare floatValue]],
        @"rider_amt":[Utilities formatAmount:[self.trip.trip_fare floatValue]],
        @"pay_amount":[Utilities formatAmount:[self.trip.trip_fare floatValue]],
        @"trip_id":[NSString stringWithFormat:@"%@",self.trip.trip_Id],
        P_DRIVER_ID:[NSString stringWithFormat:@"%@",self.trip.driver.driverId],
        @"city_id":[NSString stringWithFormat:@"%d",self.trip.city_id],
        @"pay_status":TS_PAID,
        @"trip_driver_commision":[Utilities formatAmount:driverCommission],
        // El metodo de VERDAD, no "Cash" clavado: un Pago Movil se registraba como efectivo.
        @"pay_mode":[ConrraPagoDeViaje metodoNoBilletera:self.trip.trip_pay_mode],
        @"trans_description":@"Trip Payment",
        @"promo_amt":[Utilities formatAmount:[self.trip.trip_promo_amt floatValue]],
        @"commission_amt":[Utilities formatAmount:([[Utilities formatAmount:[self.trip.trip_fare floatValue]] floatValue]-driverCommission)]
    }];
    [UtilityClass setLH:NO wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
    [GIC mkwu:GET_WALLET_ADD_TRIP_TRAN    d:dict isa:YES   cb:^(id results, NSError *error) {
        if ([[[results objectForKey:P_STATUS] uppercaseString] isEqualToString:@"OK"]) {
            // Con su metodo, no con CASH_PAY: sobreescribir trip_pay_mode a "Cash" borraba
            // como se pago de verdad, que es justo lo que ConrraCierreDeViaje evita.
            [self updatePaymentPaidStatus:[ConrraPagoDeViaje metodoNoBilletera:self.trip.trip_pay_mode]];
        }else {
            [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
        }
    }];
}

-(void)updatePaymentPaidStatus:(NSString*)modeType {
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{
        @"trip_id"                      : self.trip.trip_Id,
    }];
    [dict setObject:modeType forKey:@"trip_pay_mode"];
    [dict setObject:TS_PAID forKey:@"trip_pay_status"];
    [dict setObject:[Utilities getStringFromDate:[NSDate date]] forKey:@"trip_pay_date"];
    [UtilityClass setLH:NO wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
    [GIC mkwu:TRIP_UPDATE  d:dict    isa:NO   cb:^(id results, NSError *error) {
        if ([[[results objectForKey:P_STATUS] uppercaseString] isEqualToString:@"OK"]) {
            [self sendNotification];
        }
        NSString *driverStatus = TS_WAITING;
        defaults_set_object(DRIVER_STATUS, driverStatus);
        [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
        [self.delegate onCashPaymentCompleted];
    }];
}
-(NSString *) getValueForKey:(NSString *) key lang:(NSString*)lang{
    return [[LanguageHelper sharedInstance] getStringWithKey:key currentLanguage:lang];
}
-(void)sendNotification{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{
        @"trip_id":self.trip.trip_Id,
        @"trip_status":TS_PAID,
        @"message"          :[self getValueForKey:@"k_9_s14_paid_successfully" lang:self.trip.user.u_language],
        @"content-available":@"1",
    }];
    [dict addEntriesFromDictionary:[self.trip.user deviceTypeAndToken]];
    if (isTokenEmpty(dict)) {
        return;
    }
    [dict setObject:@"user" forKey:@"to"];
    [GIC mk:url_notification to:send_user_notification   d:dict  isa:NO    cb:^(id results, NSError *error) {
        if ([[[results objectForKey:P_STATUS] uppercaseString] isEqualToString:@"OK"]) {
            
            
        }
    }];
}
@end
