//
//  DriverModel.h
//  HIREME_RIDER
//
//  Created by Appicial Taxi App Solutions on 08/06/17.
//  Copyright © 2023 Appicial. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LanguageHelper.h"


@interface DriverModel : NSObject
@property(strong,nonatomic)  NSString *  driverId;
@property(strong,nonatomic)  NSString *  d_fname;
@property(strong,nonatomic)  NSString *  d_lname;
@property(strong,nonatomic)  NSString *  c_code;
@property(strong,nonatomic)  NSString *  phone;
@property(assign,nonatomic)  int   num_trip;

@property(assign,nonatomic) float d_degree;
@property(nonatomic,strong) NSString *deviceToken;
@property(nonatomic,strong) NSString *deviceType;
@property (strong,nonatomic) NSString *car_registration_no;

/**
 Datos de pago movil del conductor, tal cual los guarda el backend.

 Es el JSON {bank, phone, cc, idType, idNumber} que escribe la pantalla de ajustes. El
 pasajero lo necesita para transferirle: sin esto, el recibo de iOS no tenia como decirle a
 donde pagar. Android lo lee igual en FareActivity.updateTripData y en RecargaC2PActivity.
 */
@property (strong,nonatomic) NSString *d_bank_info;
@property(nonatomic,assign) float ratingCount;
@property(assign,nonatomic) float rating;
@property(nonatomic,assign) double lat;
@property(assign,nonatomic) double lng;
@property(assign,nonatomic) float distance;
@property(assign,nonatomic) int category_id;
@property(strong,nonatomic) NSString * carname;
@property(strong,nonatomic) NSString * d_profile_image_path;
@property(strong,nonatomic) NSString * d_car_image_path;
@property (strong,nonatomic) NSString *car_model;
@property (strong,nonatomic) NSString *car_name;
@property (strong,nonatomic) NSString *car_make;
/// El color del coche. Es lo que permite reconocerlo desde la acera, y Android ya lo usa
/// en el aviso de "voy en camino" y en la ficha de la oferta. Columna cars.car_color.
@property (strong,nonatomic) NSString *car_color;
@property (strong,nonatomic) NSString *d_lang;

@property (strong,nonatomic) NSString *d_is_available;

@property (strong,nonatomic) NSString * fire_id;

-(instancetype)initItemWithDict:(NSDictionary *)dict;
-(BOOL ) isIos;
-(void) updateDriverRating:(float   ) rating completionBlock:(void (^)(id results, NSError *error))block  isShowLoader:(BOOL)isShowLoader;

+(NSMutableArray *) parseDirversResponse:(NSArray *) arrDrivers;
-(NSMutableDictionary *) deviceTypeAndToken;
@end
