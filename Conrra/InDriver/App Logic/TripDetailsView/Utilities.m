//
//  Utilities.m
//  TableViewDemo
//
//  Created by Vishal Chikara on 05/03/15.
//  Copyright (c) 2015 Vishal. All rights reserved.
//

#import "Utilities.h"
#import "WebCallConstants.h"
#import "ConstantModel.h"
#import <Conrra-Swift.h>
@implementation Utilities


+(UIImage*)imageWithImage: (UIImage*) sourceImage scaledToWidth: (float) i_width
{
    float oldWidth = sourceImage.size.width;
    float scaleFactor = i_width / oldWidth;
    
    float newHeight = sourceImage.size.height * scaleFactor;
    float newWidth = oldWidth * scaleFactor;
    
    UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight));
    [sourceImage drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}


+(UIImage*)imageWithImageHeight: (UIImage*) sourceImage scaledToWidth: (float) i_width scaledToHeight: (float) i_height
{
    if(sourceImage.size.width<=i_width&&sourceImage.size.height<=i_height)
    {
        return sourceImage;
    }
    
    UIImage *newImage=sourceImage;
    float scaleFactor=1;
    
     if(sourceImage.size.width>sourceImage.size.height)
     {
         // lanndscape
          if(sourceImage.size.height<=i_height)
          {
              return sourceImage;
          }
         float oldHeight = sourceImage.size.height;
         scaleFactor = i_height / oldHeight;
     }else{
         //port
         if(sourceImage.size.width<=i_width)
         {
             return sourceImage;
         }
         float oldWidth = sourceImage.size.width;
         scaleFactor = i_width / oldWidth;
     }
    
    
    
    float newHeight = sourceImage.size.height * scaleFactor;
    float newWidth = sourceImage.size.width * scaleFactor;
    
    UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight));
    [sourceImage drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
    newImage= UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+(CGFloat)imageSizeWithImage: (CGSize) sourceImageSize scaleToWidth: (float) i_width
{
    float oldWidth = sourceImageSize.width;
    float scaleFactor = i_width / oldWidth;
    
    float newHeight = sourceImageSize.height * scaleFactor;
    return newHeight;
}

+ (CGFloat)getLabelHeight:(CGSize)label forText:(NSString*)textString withFont:(UIFont*)font
{
    CGSize constraint = CGSizeMake(label.width, MAXFLOAT);
    CGSize size;
    
    NSStringDrawingContext *context = [[NSStringDrawingContext alloc] init];
    
    CGSize boundingBox = [textString boundingRectWithSize:constraint
                                                  options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                               attributes:@{NSFontAttributeName:font}
                                                  context:context].size;
    
    size = CGSizeMake(ceil(boundingBox.width), ceil(boundingBox.height));
    
    return size.height;
}

- (NSString*)getLabelHeight1:(NSString*)label label2:(NSString*) label2 width:(int)widthR  withFont:(UIFont*)font
{
    CGSize constraint = CGSizeMake(widthR, MAXFLOAT);
    float width;
    
    NSString *strConcat = [NSString stringWithFormat:@"%@ %@", label, label2];
    
    NSStringDrawingContext *context = [[NSStringDrawingContext alloc] init];
    
    CGSize boundingBox = [strConcat boundingRectWithSize:constraint
                                                 options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                              attributes:@{NSFontAttributeName:font}
                                                 context:context].size;
    
    width =boundingBox.width;// CGSizeMake(ceil(boundingBox.width), ceil(boundingBox.height));
    
    
    while (width>widthR) {
        NSString *str = [label substringToIndex:label.length - 1];
        [self getLabelHeight1:str label2:label2 width:widthR withFont:font];
    }
    
    
    return strConcat;
    
}

+(NSString *)GetGMTDatetoLocalTZ:(NSString *)strGMTDate {
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSLocale *indianLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [dateFormat setLocale:indianLocale];
    [dateFormat setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    
    NSDate *ts_GMT = [dateFormat dateFromString:strGMTDate];
    
    NSDateFormatter *df_local = [[NSDateFormatter alloc] init];
    NSLocale *localLocale = [[NSLocale alloc] initWithLocaleIdentifier:[LanguageHelper getlcidCurrent]];
    [df_local setLocale:localLocale];
    [df_local setTimeZone:[NSTimeZone localTimeZone]];
    [df_local setDateFormat:@"MMM, dd yyyy hh:mm a"];
    NSString *strDTLocal = [df_local stringFromDate:ts_GMT];
    return strDTLocal;
}

+(NSDate *)GetGMTDatetoLocalTZ1:(NSString *)strGMTDate {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSLocale *indianLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [dateFormat setLocale:indianLocale];
    [dateFormat setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    
    NSDate *ts_GMT = [dateFormat dateFromString:strGMTDate];
    
    NSDateFormatter *df_local = [[NSDateFormatter alloc] init];
    
    [df_local setTimeZone:[NSTimeZone localTimeZone]];
    [df_local setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    // NSString *strDTLocal = [df_local stringFromDate:ts_GMT];
    return ts_GMT;
}

+(NSString*) getStringFromDate:(NSDate*)date{
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSLocale *indianLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [format setLocale:indianLocale];
    
    NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    [format setTimeZone:gmt];
    
    NSString *stringFromDate = [format stringFromDate:date];
    return stringFromDate;
    
}
+(NSString *)GetGMTDatetoLocalTZ:(NSString *)strGMTDate :(NSString *)desiredDateFormat

//+(NSString *)GetGMTDatetoLocalTZ:(NSString *)strGMTDate
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSLocale *indianLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [dateFormat setLocale:indianLocale];
    [dateFormat setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    
    NSDate *ts_GMT = [dateFormat dateFromString:strGMTDate];
    
    NSDateFormatter *df_local = [[NSDateFormatter alloc] init];
    NSLocale *localLocale = [[NSLocale alloc] initWithLocaleIdentifier:[LanguageHelper getlcidCurrent]];
    [df_local setLocale:localLocale];
    [df_local setTimeZone:[NSTimeZone localTimeZone]];
    [df_local setDateFormat:desiredDateFormat];
    
    NSString *strDTLocal = [df_local stringFromDate:ts_GMT];
    return strDTLocal;
}



+(NSString * ) formatCurrency:(int) value
{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    //    [formatter setLocale:[NSLocale localeWithLocaleIdentifier:@"km_KH"]];
    [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [formatter setCurrencySymbol:@""];
    [formatter setMaximumFractionDigits:0];
    NSString * bal=[formatter stringFromNumber:[NSNumber numberWithFloat:value]];
    return bal;
}
+(NSString * ) formatCurrencyFloat:(float) value
{
    return     [self formatCurrency:(int)value];
    
}
+(NSString * ) formatCurrencyString:(NSString *) value
{
    return     [self formatCurrency:[value intValue]];
}

+(UIAlertController *) showAlertwithTilte:(NSString *) title message:(NSString * ) message navigatationController:(UINavigationController *)navigatationController isBack:(BOOL) isBack
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *actionOk = [UIAlertAction actionWithTitle:[LanguageHelper getStringWithKey:@"k_18_s4_Ok"]
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {
                                                         if(isBack)
                                                         {
                                                             [navigatationController dismissViewControllerAnimated:YES completion:nil];
                                                         }
                                                     }];
    [alertController addAction:actionOk];
    [navigatationController presentViewController:alertController animated:YES completion:nil];
    return alertController;
}

+(UIAlertController *) showAlertwithTilte:(NSString *) title message:(NSString * ) message navigatationController:(UINavigationController *)navigatationController
    {
        
        return [Utilities showAlertwithTilte:title message:message navigatationController:navigatationController isBack:NO];
    }
    
    +(UIAlertController *) showAlertwithTilte:(NSString *) title message:(NSString * ) message viewController:(UIViewController *)viewController
    {
        return [Utilities showAlertwithTilte:title message:message viewController:viewController isBack:NO];
    }
    +(UIAlertController *) showAlertwithTilte:(NSString *) title message:(NSString * ) message viewController:(UIViewController *)viewController isBack:(BOOL) isBack
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                                 message:message
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *actionOk = [UIAlertAction actionWithTitle:[LanguageHelper getStringWithKey:@"k_18_s4_Ok"]
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * _Nonnull action) {
                                                             if(isBack)
                                                             {
                                                                 [viewController dismissViewControllerAnimated:YES completion:nil];
                                                             }
                                                         }];
        [alertController addAction:actionOk];
        [viewController presentViewController:alertController animated:YES completion:nil];
        return alertController;
    }
    
    
    
+(int)getRandomNumberBetween:(int)from to:(int)to
{
    return (int)from + arc4random() % (to-from+1);
}

+(UIColor*)colorWithHexString:(NSString*)hex
{
    NSString *cString = [[hex stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) return [UIColor grayColor];
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
    
    if ([cString length] != 6) return  [UIColor grayColor];
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:1.0f];
}


+(BOOL) seEnvioElSms:(id) results {
    if (results == nil || results == [NSNull null] || ![results isKindOfClass:[NSDictionary class]]) {
        return NO;
    }
    NSString *estado = [[results objectForKey:P_STATUS] uppercaseString];
    if (![estado isEqualToString:@"OK"]) {
        return NO;
    }
    id codigo = [results objectForKey:@"code"];
    if (codigo == nil || codigo == [NSNull null]) {
        return YES;
    }
    return [codigo intValue] == 200;
}

+(NSString *)  encodedOTPUrl:(NSDictionary *) dict
{
    NSString *sampleUrl = [NSString stringWithFormat:@"%@?msg=%@&ph=%@",BASE_URL_OTP_NO,[dict objectForKey:@"msg"],[dict objectForKey:@"ph"]];
    NSString* encodedUrl = [sampleUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    return encodedUrl;
}



/** Deja una cadena util, o vacia: recorta, y trata "null" y "(null)" como si no hubiera nada. */
+(NSString *) textoUtil:(id) valor {
    if (![valor isKindOfClass:[NSString class]]) {
        return @"";
    }
    NSString *t = [(NSString *)valor stringByTrimmingCharactersInSet:
                   [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([t caseInsensitiveCompare:@"null"] == NSOrderedSame ||
        [t caseInsensitiveCompare:@"(null)"] == NSOrderedSame) {
        return @"";
    }
    return t;
}

+(NSString *) ultimos4DigitosDe:(NSString *) telefono {
    NSString *t = [self textoUtil:telefono];
    if (t.length < 4) {
        return @"";
    }
    return [t substringFromIndex:t.length - 4];
}

+(NSString *) numeroParaLlamarConCodigo:(NSString *) codigo numero:(NSString *) numero {
    NSString *n = [self textoUtil:numero];
    if (n.length == 0) {
        return @"";
    }
    // Si el numero ya trae el prefijo internacional, no se le pone otro encima.
    if ([n hasPrefix:@"+"]) {
        return n;
    }

    NSString *c = [self textoUtil:codigo];
    // El codigo se guarda unas veces como "58" y otras como "+58".
    c = [c stringByReplacingOccurrencesOfString:@"+" withString:@""];
    c = [c stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (c.length == 0) {
        // Sin prefijo no se puede internacionalizar: se marca tal cual y que el telefono
        // decida, que es mejor que anteponer un + a medias.
        return n;
    }

    /*
     El numero local puede venir con su cero de tronco -- 0412... en vez de 412... -- que en
     formato internacional sobra: +580412... no existe. Se quita solo cuando hay prefijo, que
     es cuando se sabe que el numero pasa a ser internacional.
     */
    if (n.length > 1 && [n hasPrefix:@"0"]) {
        n = [n substringFromIndex:1];
    }
    // Y si el numero ya venia con el prefijo pegado, no se duplica.
    if ([n hasPrefix:c] && n.length > c.length) {
        return [NSString stringWithFormat:@"+%@", n];
    }
    return [NSString stringWithFormat:@"+%@%@", c, n];
}

+(void) handleError:(NSError *)error viewController:(UIViewController *)viewController defaultMessage:(NSString *) defaultMessage{
    NSHTTPURLResponse *dataErrorResponse=[error.userInfo objectForKey:AppKeysName.ERROR_RESPONSE];
    if(error) {
        NSData *data=[error.userInfo objectForKey:AppKeysName.ERROR_DATA];
        if(data==nil)   {
            if(![self handleWhenDataNil:error viewController:viewController]){
                [self showAlert:@"Internet error : Request timeout." viewController:viewController];
            }
            return;
        }
        NSError * jsonError=nil;
        id json= [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonError];
        if([json isKindOfClass:[NSDictionary class]]){
            long statusCode=(long)dataErrorResponse.statusCode;
            NSString * message=[json objectForKey:@"message"];
            if(statusCode>400){
                message=[NSString stringWithFormat:@"%ld - %@",statusCode,message];
            }
            [self showAlert:message viewController:viewController];
        }else{
            if(![self handleWhenDataNil:error viewController:viewController]){
                [self showAlert:defaultMessage viewController:viewController];
            }
        }
    }else  {
        if(![self handleWhenDataNil:error viewController:viewController]){
            [self showAlert:defaultMessage viewController:viewController];
        }
    }
}

+(BOOL) handleWhenDataNil:(NSError *)error viewController:(UIViewController *)viewController{
    NSString *dataSerializationResponse=[error.userInfo objectForKey:@"NSLocalizedDescription"];
    NSHTTPURLResponse *dataErrorResponse=[error.userInfo objectForKey:AppKeysName.ERROR_RESPONSE];
    if(dataErrorResponse!=nil&&dataSerializationResponse!=nil){
        [self showAlert:[NSString stringWithFormat:@"%ld - %@",(long)dataErrorResponse.statusCode,dataSerializationResponse] viewController:viewController];
        return YES;
    }
    if(dataSerializationResponse!=nil){
        [self showAlert:isEmpty(dataSerializationResponse) viewController:viewController];
        return YES;
    }
    return NO;
}



+(NSDictionary * ) handleErrorDict:(NSError *)error {
    NSHTTPURLResponse *dataErrorResponse=[error.userInfo objectForKey:AppKeysName.ERROR_RESPONSE];
    if(error) {
        NSData *data=[error.userInfo objectForKey:AppKeysName.ERROR_DATA];
        if(data==nil)   {
            if(![self handleWhenDataNil:error ]){
                
            }
            return nil;
        }
        NSError * jsonError=nil;
        id json= [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonError];
        if([json isKindOfClass:[NSDictionary class]]){
            return json;
        }else{
            if(![self handleWhenDataNil:error ]){
                return nil;
            }
        }
    }else  {
        if(![self handleWhenDataNil:error]){
            return nil;
        }
    }
    return nil;
}

+(BOOL) handleWhenDataNil:(NSError *)error{
    NSString *dataSerializationResponse=[error.userInfo objectForKey:@"NSLocalizedDescription"];
    NSHTTPURLResponse *dataErrorResponse=[error.userInfo objectForKey:AppKeysName.ERROR_RESPONSE];
    if(dataErrorResponse!=nil&&dataSerializationResponse!=nil){
        return YES;
    }
    if(dataSerializationResponse!=nil){
        return YES;
    }
    return NO;
}




+(void) showAlert:(NSString *) message viewController:(UIViewController *)viewController{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[LanguageHelper getStringWithKey:@"k_23_s3_warning"]
                                                                             message:[LanguageHelper getStringWithKey:message]
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *actionOk = [UIAlertAction actionWithTitle:[LanguageHelper getStringWithKey:@"k_18_s4_Ok"]
                                                       style:UIAlertActionStyleDefault
                                                     handler:nil];
    [alertController addAction:actionOk];
    [viewController presentViewController:alertController animated:YES completion:nil];
}

+(NSString*) formatAmountAndCurrency:(float) amount currency:(NSString *) currency
{
    return [self formatAmountAndCurrency:amount currency:currency isForWallet:NO];
}

+(NSString*) formatAmountAndCurrencyZero:(float) amount currency:(NSString *) currency
{
    return [self formatAmountAndCurrency:amount currency:currency isForWallet:NO];
}

+(NSString*) formatAmountAndCurrency:(float) amount currency:(NSString *) currency isForWallet:(BOOL)isForWallet
{
    if(amount==0){
//        return @"--";
        return [NSString stringWithFormat:@"%@0",currency];
    }
    if(amount<0) {
        amount=amount*-1;
        if(isForWallet){
            return  [self formatAmountAndCurrencyPositive:amount currency:currency];
        }
        return [self formatAmountAndCurrencyNegative:amount currency:currency];
    }
    return  [self formatAmountAndCurrencyPositive:amount currency:currency];
    
}

+(NSString*) formatAmountAndCurrencyNegative:(float) amount currency:(NSString *) currency{
    return [NSString stringWithFormat:@"-%@%@",currency,[StoryBoardUtiles formatAmountValueWithAmount:[NSString stringWithFormat:@"%.2f",amount] maxDecimalsAllowed:[ConstantModel getConstantsObject].max_decimal_allowed]];
    ;
}

+(NSString*) formatAmountAndCurrencyPositive:(float) amount currency:(NSString *) currency{
    return [NSString stringWithFormat:@"%@%@",currency,[StoryBoardUtiles formatAmountValueWithAmount:[NSString stringWithFormat:@"%.2f",amount] maxDecimalsAllowed:[ConstantModel getConstantsObject].max_decimal_allowed]];
    ;
}



+(NSString*) formatAmount:(float) amount
{  return [StoryBoardUtiles formatAmountValueWithAmount:[NSString stringWithFormat:@"%.2f",amount] maxDecimalsAllowed:[ConstantModel getConstantsObject].max_decimal_allowed];
}





+(NSString*) formatDistanceAndUnit:(float) distance unit:(NSString *) unit
{
    return [NSString stringWithFormat:@"%.2f%@",distance,unit];
}


+(NSString*) formatDistance:(float) distance
{
    return [NSString stringWithFormat:@"%.2f",distance];
}

+(NSString *) formatOtpMessageWithOtp:(int) otpCode isResetPassword:(BOOL)isResetPassword
{
    NSString *otpMessage ;
//    if(isResetPassword)
//    {
//        otpMessage =[NSString stringWithFormat:@"Use %i as your Reset Password OTP SMS. SMS is confidential. OD Partner calls you asking for SMS.", otpCode];
//    }else{
//        otpMessage =[NSString stringWithFormat:@"Use %i as your login OTP SMS. SMS is confidential. OD Partner never calls you asking for SMS.", otpCode];
//    }
    NSDictionary *bundleInfo = [[NSBundle mainBundle] infoDictionary];
    NSString *appName = [bundleInfo objectForKey:@"CFBundleDisplayName"];
    NSString * smsOtp =[NSString stringWithFormat:@"%d", otpCode];
    NSString * stringMessage;
    if(isResetPassword)
    {
        stringMessage =[LanguageHelper getStringWithKey:@"k_r25_s2_reset_otp_message"];
    }else{
        stringMessage =[LanguageHelper getStringWithKey:@"k_r25_s2_otp_message"];
    }
    NSString *stringFinal = [stringMessage
                             stringByReplacingOccurrencesOfString:@"%s" withString:@"%@"];
    otpMessage =[NSString stringWithFormat:stringFinal, smsOtp,appName];
    return otpMessage;
}


+(NSString *) validPasswordMessage{
    ConstantModel *  constantTaxiModel =[ConstantModel getConstantsObject];;
    NSString * format=[LanguageHelper getStringWithKey:@"k_41_s6_Password_should_be_at_least_4_char" defaultValue:@"Password should be at least %d char"];
    return[NSString stringWithFormat:format,constantTaxiModel.min_password_length];
}

+(NSMutableDictionary *) appBuildVersionAndOsInfo{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *majorVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    NSString *buildVersion = [infoDictionary objectForKey:@"CFBundleVersion"];

    NSMutableDictionary *dict =[[NSMutableDictionary alloc] init];
    [dict setObject:[NSString stringWithFormat:@"%@ %@",majorVersion,buildVersion] forKey:@"app_ver"];
    [dict setObject:@"IOS" forKey:@"dev_type"];
    [dict setObject:[[UIDevice currentDevice] systemVersion] forKey:@"os_ver"];
    return  dict;
}


+(BOOL) isValidLocation:(CLLocationCoordinate2D) currLoc{
    BOOL isInValid=currLoc.latitude==0.0&&currLoc.longitude==0.0;
    return  !isInValid;
}


+(NSString *)stringByStrippingHTML:(NSString *)htmlString
{
    if (!htmlString || htmlString.length == 0) return htmlString ?: @"";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"<[^>]+>" options:0 error:NULL];
    NSString *s = [regex stringByReplacingMatchesInString:htmlString options:0 range:NSMakeRange(0, htmlString.length) withTemplate:@""];
    s = [s stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return s.length > 0 ? s : @"";
}

+(NSString *)removePlusBeforeNumber:(NSString *) number{
    NSCharacterSet *numbers = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet];
    return [number stringByTrimmingCharactersInSet:numbers];
}

+(NSString *) removeAllLeadingZero:(NSString *) number{
    number= [number stringByTrimmingCharactersInSet:
             [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    number =[ self removePlusBeforeNumber:number];
    NSRange range = [number rangeOfString:@"^0*" options:NSRegularExpressionSearch];
    return [number stringByReplacingCharactersInRange:range withString:@""];
}


+(NSString *)getHoursAndMinutesMin:(NSInteger)min{
    return  [self getHoursAndMinutesSeconds:min *60];
}

+(NSString *)getHoursAndMinutesSeconds:(NSInteger)seconds{
    NSString *tmpStr;
    if(seconds<60) {
        seconds=60;
    }
    if(seconds<60) {
        tmpStr =[NSString stringWithFormat:@"%ld %@", (long)seconds,[LanguageHelper getStringWithKey:@"k_52_s3_sec"]];
        return tmpStr;
    }
    int minutes= (int)seconds/60;
    int min = (int)minutes%60;
    int hours = (minutes - min)/60;
    if(seconds%60>0) {
        min=min+1;
    }
    if (hours>0) {
        NSString * hursString=[LanguageHelper getStringWithKey:@"k_s3_hrs" defaultValue:@"hr"];
        if(hours>24){
            int days=hours/24;
            int hRemaing=hours%24;
            NSString * dayString=[LanguageHelper getStringWithKey:@"k_s3_day" defaultValue:@"day"];
            if(days>1){
                dayString=[LanguageHelper getStringWithKey:@"k_s3_day" defaultValue:@"days"];
            }
            tmpStr =[NSString stringWithFormat:@"%d%@%d%@ %d %@",days,dayString, hRemaing,hursString, min,[LanguageHelper getStringWithKey:min<=1?@"k_17_s4_min":@"k_17_s4_mins"]];
        }else{
            tmpStr =[NSString stringWithFormat:@"%d%@ %d %@", hours,hursString, min,[LanguageHelper getStringWithKey:min<=1?@"k_17_s4_min":@"k_17_s4_mins"]];
        }
    }
    else{
        tmpStr =[NSString stringWithFormat:@"%d%@", min,[LanguageHelper getStringWithKey:min<=1?@"k_17_s4_min":@"k_17_s4_mins"]];
    }
    return tmpStr;
}

+(NSString *)getRandomPINString:(NSInteger)length
{
    length=4;// for in driver
    NSMutableString *returnString = [NSMutableString stringWithCapacity:length];
    
    NSString *numbers = @"0123456789";
    
    // First number cannot be 0
    [returnString appendFormat:@"%C", [numbers characterAtIndex:(arc4random() % ([numbers length]-1))+1]];
    
    for (int i = 1; i < length; i++)
    {
        [returnString appendFormat:@"%C", [numbers characterAtIndex:arc4random() % [numbers length]]];
    }
    
    return returnString;
}
+(NSDate *)convertStringToDate:(NSString *)strDate fromFormat:(NSString *)strFromFormat
{
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = strFromFormat;
    return [dateFormatter dateFromString:strDate];
}

+(NSString *)encodeImageToBase64String:(UIImage *)image quality:(float)quality{
    return [UIImageJPEGRepresentation(image, quality) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
}

+(NSString *)encodeImageToBase64String:(UIImage *)image{
    return [self encodeImageToBase64String:image quality:.8];
}



+(NSString *)dictOrArrayToJosnString:(id) dict{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict
                                                       options: 0
                                                         error:&error];
    if (! jsonData) {
        NSLog(@"%s: error: %@", __func__, error.localizedDescription);
    } else {
       return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    return nil;
}


+(id) idFormJsonString:(NSString *) jsonString{
    if (jsonString) {
        NSError *jsonError;
        NSData *objectData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:objectData
                                                             options:NSJSONReadingMutableContainers
                                                               error:&jsonError];
        
        return json;
    }
    return nil;
}



+(NSString*)convertTimeStamp:(double)serverTimestamp{
    double seconds = serverTimestamp/1000 ;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:seconds];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMM d yyyy"];
    NSLocale *twelveHourLocale =
    [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    formatter.locale = twelveHourLocale;
    
    //NSString *dateStr = [formatter stringFromDate:date];
    NSDate *startDate = [formatter dateFromString:[formatter stringFromDate:date]];
    
    
    //NSString *dateStrToday = [formatter stringFromDate:[NSDate date]];
    NSDate *dateToday = [formatter dateFromString:[formatter stringFromDate:[NSDate date]]];
    
    
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [gregorianCalendar components:NSCalendarUnitDay
                                                        fromDate:startDate
                                                          toDate:dateToday
                                                         options:0];
    
    if ([components day] == 0) {
        [formatter setDateFormat:@"h:mm a"];
        return [formatter stringFromDate:date];
    }
    else if ([components day] == 1 || [components day] == 2 || [components day] == 3 || [components day] == 4 || [components day] == 5 || [components day] == 6){
        [formatter setDateFormat:@"EEEE 'at' h:mm a"];
        return [formatter stringFromDate:date];
    }
    else {
        [formatter setDateFormat:@"MMM d 'at' h:mm a"];
        return [formatter stringFromDate:date];
    }
}




+(void) getLocationFromAddressStringPlaceId: (NSString*) addressStr withcompletionHandler : (void(^)(CLLocationCoordinate2D loc))completionHandler {
    double latitude = 0, longitude = 0;
    NSString *esc_addr =  [addressStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
    NSString *req = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/geocode/json?key=%@&place_id=%@",[APP_DELEGATE getGoogleKey], esc_addr];
    NSString *result = [NSString stringWithContentsOfURL:[NSURL URLWithString:req] encoding:NSUTF8StringEncoding error:NULL];
    if (result) {


        NSData *data = [result dataUsingEncoding:NSUTF8StringEncoding];
        id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        
        if([json isKindOfClass:[NSDictionary class]])
        {
            NSString * status=  [json objectForKey:@"status"];
            if([[status  uppercaseString] isEqualToString:@"OK"])
            {
                NSArray *results=[json objectForKey:@"results"];
                NSDictionary * location=[[results.firstObject objectForKey:@"geometry"]  objectForKey:@"location"];
                latitude=[[location objectForKey:@"lat"] floatValue];
                longitude=[[location objectForKey:@"lng"] floatValue];
            }
        }

        //        NSScanner *scanner = [NSScanner scannerWithString:result];
        //        if ([scanner scanUpToString:@"\"lat\" :" intoString:nil] && [scanner scanString:@"\"lat\" :" intoString:nil]) {
        //            [scanner scanDouble:&latitude];
        //            if ([scanner scanUpToString:@"\"lng\" :" intoString:nil] && [scanner scanString:@"\"lng\" :" intoString:nil]) {
        //                [scanner scanDouble:&longitude];
        //            }
        //        }

    }

    CLLocationCoordinate2D center;
    center.latitude=latitude;
    center.longitude = longitude;
    completionHandler(center);

}


+ (CGFloat)widthOfString:(NSString *)string withFont:(UIFont *)font {
     NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil];
     return [[[NSAttributedString alloc] initWithString:string attributes:attributes] size].width;
 }

+(long) getTimeStampGMT{
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss";
    NSTimeZone *gmtZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    [dateFormatter setTimeZone:gmtZone];
    NSString *timeStamp = [dateFormatter stringFromDate:[NSDate date]];
    long tE = ([[dateFormatter dateFromString:timeStamp] timeIntervalSince1970]*1000);
    return tE;
}


+(void)applyGrayTintOnImageView:(UIImageView*)imageview{
    [self applyGrayTintOnImageView:imageview color:[UIColor colorNamed:@"color_gray_tint"] ];
}
+(void)applyGrayTintOnImageView:(UIImageView*)imageview color:(UIColor*)color;{
    UIImage *img = [imageview.image imageWithRenderingMode:(UIImageRenderingModeAlwaysTemplate)];
    imageview.tintColor = color;
    imageview.image = img;
}
+(void)applyTintOnButton:(UIButton*)button color:(UIColor*)color name:(NSString *)name{
    UIImage *img = [[UIImage imageNamed:name] imageWithRenderingMode:(UIImageRenderingModeAlwaysTemplate)];
    button.tintColor = color;
    [button setImage:img forState:(UIControlStateNormal)];
}
+(void) getAddressStrinByLat: (float) latitude longitude: (float) longitude withcompletionHandler : (void(^)(NSString * locAddress,NSString * country))completionHandler {
     
    // Con lo de antes las direcciones volvian de Google en ingles ("Street", "Avenue")
    // en cuanto el usuario no hubiera elegido idioma, que es siempre nada mas instalar.
    NSString *language = [LanguageHelper idiomaActual];
    NSString *req = [NSString stringWithFormat:@"https://maps.google.com/maps/api/geocode/json?latlng=%f,%f&key=%@&language=%@",latitude,longitude,[APP_DELEGATE getGoogleKey], language];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //Run your loop here
        NSString *result = [NSString stringWithContentsOfURL:[NSURL URLWithString:req] encoding:NSUTF8StringEncoding error:NULL];
        if (result) {
            NSData *data = [result dataUsingEncoding:NSUTF8StringEncoding];
            id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            NSString * formatted_address=@"";
            NSString * country=@"";
            if([json isKindOfClass:[NSDictionary class]])  {
                NSString * status=  [json objectForKey:@"status"];
                if([[status  uppercaseString] isEqualToString:@"OK"])
                {
                    NSArray *results=[json objectForKey:@"results"];
                    
                     formatted_address=[results.firstObject objectForKey:@"formatted_address"] ;
                    NSArray *address_components=[results.firstObject objectForKey:@"address_components"] ;
                    for (NSDictionary * dd in address_components) {
                        NSArray * arrTypes = [dd objectForKey:@"types"];
                        for (NSString * ty in arrTypes) {
                            if([ty isEqualToString:@"country"]){
                                country = [dd objectForKey:@"long_name"];
                            }
                            
                        }
                    }
                    
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                completionHandler( formatted_address,country);
            });
        }else{
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                completionHandler( nil,nil);
            });
        }
    });
}
/**
 La pagina de recarga, con el id del usuario.

 El id va en la direccion porque la pagina es externa al app y no comparte su sesion:
 es como sabe a que billetera abonar. Sin el se abre un formulario que no sabe de quien
 es. Si todavia no hay usuario se devuelve la pagina pelada, que al menos explica que
 hay que entrar.
 */
/**
 Un importe en dolares, escrito en bolivares.

 Equivale a Controller.formatLocalAmount de Android: importe por la tasa, con el separador
 de miles y el decimal a la venezolana (Bs -320,04). Devuelve vacio si el servidor no
 publica tasa, para que quien llame pueda esconder la linea entera en vez de enseñar un
 cero que no significa nada.
 */
+(NSString *) montoEnBolivares:(float) dolares {
    float tasa = [ConstantModel tasaDolarALocal];
    if (tasa <= 0) {
        return @"";
    }
    NSNumberFormatter *formato = [[NSNumberFormatter alloc] init];
    formato.numberStyle = NSNumberFormatterDecimalStyle;
    formato.minimumFractionDigits = 2;
    formato.maximumFractionDigits = 2;
    formato.groupingSeparator = @".";
    formato.decimalSeparator  = @",";
    NSString *numero = [formato stringFromNumber:@(dolares * tasa)];
    if (numero.length == 0) {
        return @"";
    }
    return [NSString stringWithFormat:@"Bs %@", numero];
}

+(NSString *) urlDeRecargas {
    NSDictionary *dict = [[NSUserDefaults standardUserDefaults] objectForKey:P_USER_DICT_LOGGED];
    if (dict == nil) {
        dict = [[NSUserDefaults standardUserDefaults] objectForKey:P_USER_DICT];
    }
    NSString *idUsuario = [NSString stringWithFormat:@"%@", [dict objectForKey:P_USER_ID] ?: @""];
    if (idUsuario.length == 0) {
        return URL_RECARGAS;
    }
    return [NSString stringWithFormat:@"%@?id=%@", URL_RECARGAS, idUsuario];
}

@end
