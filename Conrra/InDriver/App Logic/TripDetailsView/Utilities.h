//
//  Utilities.h
//  TableViewDemo
//
//  Created by Vishal Chikara on 05/03/15.
//  Copyright (c) 2015 Vishal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "LanguageHelper.h"


@interface Utilities : NSObject

+(UIImage*)imageWithImage: (UIImage*) sourceImage scaledToWidth: (float) i_width;
+(UIImage*)imageWithImageHeight: (UIImage*) sourceImage scaledToWidth: (float) i_width scaledToHeight: (float) i_height;

+(CGFloat)imageSizeWithImage: (CGSize) sourceImageSize scaleToWidth: (float) i_width;
+ (CGFloat)getLabelHeight:(CGSize)label forText:(NSString*)textString withFont:(UIFont*)font;
+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;

+(NSString *)GetGMTDatetoLocalTZ:(NSString *)strGMTDate;
+(NSDate *)GetGMTDatetoLocalTZ1:(NSString *)strGMTDate;
+(NSString*) getStringFromDate:(NSDate*)date;
+(NSString *)GetGMTDatetoLocalTZ:(NSString *)strGMTDate :(NSString *)desiredDateFormat;
+(NSString * ) formatCurrency:(int) value;
+(NSString * ) formatCurrencyFloat:(float) value;
+(NSString * ) formatCurrencyString:(NSString *) value;
+(UIAlertController *) showAlertwithTilte:(NSString *) title message:(NSString * ) message viewController:(UIViewController *)viewController;
    +(UIAlertController *) showAlertwithTilte:(NSString *) title message:(NSString * ) message viewController:(UIViewController *)viewController isBack:(BOOL) isBack;
+(UIAlertController *) showAlertwithTilte:(NSString *) title message:(NSString * ) message navigatationController:(UINavigationController *)navigatationController;
+(UIAlertController *) showAlertwithTilte:(NSString *) title message:(NSString * ) message navigatationController:(UINavigationController *)navigatationController isBack:(BOOL) isBack;
    
+(int)getRandomNumberBetween:(int)from to:(int)to;
+(UIColor*)colorWithHexString:(NSString*)hex;
+(NSString *)  encodedOTPUrl:(NSDictionary *) dict;

/**
 Si el SMS del codigo salio de verdad.

 NO BASTA CON MIRAR status. El backend (webservices/tw_sms/index2.php) responde
 status = "OK" en TODAS sus ramas: cuando manda el SMS, cuando le faltan parametros y
 tambien dentro del catch de Twilio, donde solo cambia code a 400. Comprobar unicamente
 status, que es lo que hacian las cuatro pantallas, hace imposible distinguir un envio
 correcto de uno que Twilio rechazo por numero invalido o por saldo agotado: el usuario
 acababa delante de unas casillas esperando un codigo que nadie mando.

 Un `code` ausente se da por bueno, para no romper instalaciones cuyo backend no lo
 devuelva.
 */
+(BOOL) seEnvioElSms:(id) results;


+(void) handleError:(NSError *)error viewController:(UIViewController *)viewController defaultMessage:(NSString *) defaultMessage;

+(NSString *) formatAmountAndCurrency:(float) amount currency:(NSString *) currency;

+(NSString*) formatAmount:(float) amount;

+(NSString*) formatDistanceAndUnit:(float) distance unit:(NSString *) unit;

+(NSString*) formatDistance:(float) distance;


+(NSString *) formatOtpMessageWithOtp:(int) otpCode isResetPassword:(BOOL)isResetPassword;
+(NSString *) validPasswordMessage;

+(NSMutableDictionary *) appBuildVersionAndOsInfo;

+(BOOL) isValidLocation:(CLLocationCoordinate2D) currLoc;

+(NSString *)removePlusBeforeNumber:(NSString *) number;
+(NSString *) removeAllLeadingZero:(NSString *) number;
/// Removes HTML tags (e.g. <p>, <b>) so server strings can be shown in plain UILabels.
+(NSString *)stringByStrippingHTML:(NSString *)htmlString;
+(NSDictionary * ) handleErrorDict:(NSError *)error;
+(NSString *)getHoursAndMinutesMin:(NSInteger)min;
+(NSString *)getHoursAndMinutesSeconds:(NSInteger)seconds;
+(NSString *)getRandomPINString:(NSInteger)length;
+(NSDate *)convertStringToDate:(NSString *)strDate fromFormat:(NSString *)strFromFormat;
+(NSString *)encodeImageToBase64String:(UIImage *)image;
+(NSString *)encodeImageToBase64String:(UIImage *)image quality:(float)quality;
+(NSString *)dictOrArrayToJosnString:(id) dict;
+(id) idFormJsonString:(NSString *) jsonString;
+(NSString*)convertTimeStamp:(double)serverTimestamp;

+(NSString*) formatAmountAndCurrencyZero:(float) amount currency:(NSString *) currency;
+(void) getLocationFromAddressStringPlaceId: (NSString*) addressStr withcompletionHandler : (void(^)(CLLocationCoordinate2D loc))completionHandler ;
+ (CGFloat)widthOfString:(NSString *)string withFont:(UIFont *)font;
+(long) getTimeStampGMT;
+(void)applyGrayTintOnImageView:(UIImageView*)imageview;
+(void)applyGrayTintOnImageView:(UIImageView*)imageview color:(UIColor*)color;
+(void)applyTintOnButton:(UIButton*)button color:(UIColor*)color name:(NSString *)name;
+(void) getAddressStrinByLat: (float) latitude longitude: (float) longitude withcompletionHandler : (void(^)(NSString * locAddress,NSString * country))completionHandler;

/// La pagina de recarga de la billetera, con el id del usuario ya puesto.
+(NSString *) urlDeRecargas;
/** Un importe en dolares, escrito en bolivares: "Bs -320,04". Vacio si no hay tasa. */
+(NSString *) montoEnBolivares:(float) dolares;
@end
