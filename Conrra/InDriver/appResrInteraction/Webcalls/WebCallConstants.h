//
//  WebCallConstants.h
//  Restau
//
//  Created by   on 26/07/12.
//  Copyright (c) 2012 vinay@metadesignsolutions.in. All rights reserved.
//
#import "Keys.h"
#import "LanguageHelper.h"
#import <GIKit/GIKit.h>
#ifndef Restau_WebCallConstants_h
#define Restau_WebCallConstants_h
#define APP_DELEGATE (AppDelegate*) [[UIApplication sharedApplication] delegate]
#define APP_WEB_CALLS    (webcall*) [[webcall alloc] init]

#define FONTS_THEME_BOLD(fontSize)  (UIFont*) [UIFont fontWithName:@"Karla-Bold" size:fontSize*(SCREEN_WIDTH/414.0)]
#define FONTS_THEME_REGULAR(fontSize)  (UIFont*) [UIFont fontWithName:@"Karla-Regular" size:fontSize*(SCREEN_WIDTH/414.0)]
#define FONTS_THEME_BOLD_NO_SCALE(fontSize)  (UIFont*) [UIFont fontWithName:@"Karla-Bold" size:fontSize]
#define FONTS_THEME_REGULAR_NO_SCALE(fontSize)  (UIFont*) [UIFont fontWithName:@"Karla-Regular" size:fontSize]
// Noto Sans — used on all new/rebuilt screens (drop NotoSans-Bold.ttf + NotoSans-Regular.ttf into Supporting Files/Fonts/)
#define FONTS_NOTO_BOLD(fontSize)    (UIFont*) [UIFont fontWithName:@"NotoSans-Bold"    size:fontSize*(SCREEN_WIDTH/414.0)]
#define FONTS_NOTO_REGULAR(fontSize) (UIFont*) [UIFont fontWithName:@"NotoSans-Regular" size:fontSize*(SCREEN_WIDTH/414.0)]

#define RGBA(r, g, b, a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]

#define APP_CallAPI (CallAPI *)[[CallAPI alloc] init]



#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

#define KM_TO_MI(distance) (float) (distance*0.621371192)

static inline NSString *isEmpty(id thing) {
    return (thing == nil || [thing isKindOfClass:[NSNull class]] ||
            ([thing respondsToSelector:@selector(length)] &&
             [(NSData *)thing length] == 0) ||
            ([thing respondsToSelector:@selector(count)] &&
             [(NSArray *)thing count] == 0))
    ? @""
    : thing;
}


static inline BOOL isStatusOk(id  results) {
    return [[[results objectForKey:@"status"] uppercaseString] isEqualToString:@"OK"];
}

static inline BOOL isStatusError(id  results) {
    return [[[results objectForKey:@"status"] uppercaseString] isEqualToString:@"ERROR"];
}
static inline NSString * errorMessage(id  results) {
    return [results objectForKey:@"message"];
}


static inline BOOL isDistanceUnitKm(NSString * distanceUnit) {
    return [[distanceUnit uppercaseString] isEqualToString:@"KM"];
}

static inline BOOL isTokenEmpty(NSMutableDictionary * dict) {
    if ([[dict objectForKey:@"ios"] length]==0  && [[dict objectForKey:@"android"] length]==0) {
        return YES;
    }
    return NO;
}

static inline BOOL isOK(id  results) {
    return [[[results objectForKey:@"status"] uppercaseString] isEqualToString:@"OK"];
}


#define Localise(key) [LanguageHelper getStringWithKey:key]

#define IS_IOS10_AND_ABOVE                                                         \
([[UIDevice currentDevice].systemVersion floatValue] >= 10.0)



// DB Common

#define API_UPDATE_OFFER                         @"triprequestapi/updatetriprequest"   // <<============
#define trip_accept                         @"tripapi/tripaccept"   // <<============
#define trip_assigned                        @"tripapi/tripassigned"

#define trip_reject                        @"triprequestapi/rejecttriprequest"

#if( IS_USE_NODE_SERVER == 1)
#define send_user_notification  @""
#define send_driver_notification  @""
#else
#define send_user_notification  @"RiderAndroidIosPushNotification.php"
#define send_driver_notification  @"DriverAndroidIosPushNotification.php"
#endif


#define current = "myOutput"
#define Email_symbols @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
#define Symbols_text @"~`!@#$%^&*()+=-/;:\"\'{}[]<>^?,™£¢∞§¶•ªº¥€|_.";


//fare amount init
//#define accept_time 30
//#define price_per_km 5
//#define waiting_charge_per_min 1
//#define tax 0.05 // 5% (Percentage)
//#define driver_mi_charge 5
//#define min_percentage_charge 10
#define SIZE 10

#define MOBILE_DIGIT                14
#define PENDING_HOURS               1





#define Numbers_text @"0123456789";
#define alphabets_text @"abcdefghijklmnopqrstuvwxyz";
#define ACCEPTABLE_CHARACTERS @" ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"


#define ADD_IMAGES @"partnerassetapi/addpartnerasset"

//API's
#define API_CREATE_TRIP  @"tripapi/save"
#define DRIVER_SIGNUP @"driverapi/registration"
#define DRIVER_SIGNIN @"driverapi/login"
#define TRIP_UPDATE @"tripapi/updatetrip"
#define TRIP_GETTRIP @"tripapi/gettrips"

#define TRIP_GET_MASTER_TRIP @"mtripapi/getmtrips"
#define GET_REVISED_TRIPS  @"tripapi/getrevisedtrips"
#define CAR_GETCATEGORY @"categoryapi/getcategories"

#define GET_CAR @"carapi/getcars"
#define API_GET_CITIES @"cityapi/getcities"
#define GET_EARNINGS @"tripapi/shortstat"
#define GET_PENDING_TRIP @"tripapi/getpendingtrips"

#define ADD_ROUTE @"tripdataapi/addupdatedata"
#define GET_ROUTE @"tripdataapi/gettripdata"

//phone
#define DRIVER_PH_SIGNUP @"driverapi/phregistration"
#define DRIVER_PH_SIGNIN @"driverapi/phlogin"
#define DRIVER_PH_VALIDATE @"driverapi/phdrivervalidate"
#define ADD_DRIVER_ASSET @"driverassetapi/adddriverasset"
#define GET_DRIVER_ASSET @"driverassetapi/getdriverassets"
#define USER_PH_SIGNUP                 @"userapi/phregistrationv1"
#define USER_PH_SIGNIN                 @"userapi/phlogin"
#define USER_VALIDATE                @"userapi/uservalidate"

#define GET_DRIVER_PROFILE @"driverapi/getdrivers"
#define GET_USER_PROFILE            @"userapi/getusers"
#define DRIVER_STATUS @"driverstatus"
#define DRIVER_STATUS_TEMP @"driverstatus_TEMP"
#define TRIP_ID @"trip_id"
#define M_TRIP_ID @"m_trip_id"
#define TRIP_STATUS @"trip_status"
#define TRIP_REASON @"trip_reason"
#define TRIP_DISTANCE @"trip_distance"


// notification
#define IOS                    @"ios"
#define IOS_TOKEN                 @"ios"   
#define ANDROID_TOKEN             @"android"
//#define IOS_TOKEN                 @"token"   //@"ios"
//#define ANDROID_TOKEN             @"token"//       @"android"

#define API_GET_TAXI_CONSTANT @"constantapi/getconstants"
#define API_GET_TAXI_SETTINGS @"constantapi/getsettings"
#define API_GET_ALL_IN_ONE @"commonapi/getallinone"
#define API_VALIDATE_REFERRAL_CODE @"constantapi/validatereferral"
#define API_GET_REFERRAL @"referralapi/getreferrals"

#define UPDATE_DRIVER_ACTIVITY @"driverapi/updateactivitylog"

#define UPDATE_USER_PROFILE @"userapi/updateuserprofile"
#define UPDATE_DRIVER_PROFILE @"driverapi/updatedriverprofile"
#define UPDATE_DRIVER_PASSWORD @"driverapi/updatedriverpassword"
#define API_GET_NOTIFICATION  @"notificationapi/getnotification"
#define API_MARK_AS_READ_NOTIFICATION  @"notificationapi/setallnotificationsasread"
#define DRIVER_CHANGE_PASSWORD @"driverapi/forgetpassword"//@"reset_pwd"
#define API_VALIDATE_PROMO      @"promoapi/validatepromos"
#define  p_promo_code           @"promo_code"
#define P_EMERGENCY_CONTACT_1       @"emergency_contact_1"
#define P_EMERGENCY_CONTACT_2       @"emergency_contact_2"
#define P_EMERGENCY_CONTACT_3       @"emergency_contact_3"
#define P_EMERGENCY_EMAIL_1         @"emergency_email_1"
#define P_EMERGENCY_EMAIL_2         @"emergency_email_2"
#define P_EMERGENCY_CEMAIL_3        @"emergency_email_3"
#define P_EMERGENCY_CONTACT_3       @"emergency_contact_3"
#define P_EMERGENCY_CONTACT_4       @"emergency_contact_4"
#define P_EMERGENCY_CONTACT_5       @"emergency_contact_5"
#define APP_TIME_FORMAT @"MMM, dd yyyy hh:mm a"
#define APP_DATE_FORMAT @"MMM, dd yyyy hh:mm a"
#define APP_DATE_ONLY @"MMM, dd yyyy"
#define APP_TIME_ONLY @"hh:mm a"
#define SAVE_DATE_FORMAT @"yyyy-MM-dd HH:mm"
#define GET_USERS_NEARBY @"userapi/getnearbyuserlists"//@"near_by_users"
#define  P_IS_USER_LOGIN          @"is_user_login"

#define  TS_EXPIRED          @"expired"
#define  TS_REQUEST          @"request"
#define  TS_REJECT         @"reject"
#define  TS_ACCEPTED         @"accept"
#define  TS_ACCEPTED         @"accept"
#define  TS_END              @"completed"
#define  TS_ARRIVE           @"arrive"
#define  TS_BEGIN            @"begin"
#define  TS_DRIVER_CANCEL    @"driver_cancel"
#define  TS_CHAT            @"chat"
#define  TS_OFFER            @"offer"

#define  TS_DRIVER_CANCEL_AT_PICKUP    @"p_cancel_pickup"
#define  TS_DRIVER_CANCEL_AT_DROP      @"p_cancel_drop"
#define  TS_RIDER_CANCEL   @"cancel"
#define  TS_RIDER_CANCEL_CANCEL   @"paid_cancel"
#define  TS_PAID             @"Paid"
#define  PAY_ACCEPTED        @"payaccept"
#define  TS_WAITING          @"waiting"
#define  TS_PICKED           @"Picked"
#define  PAYPAL_PAY          @"PayPal"
#define  CASH_PAY            @"Cash"
#define  HIRE_ME_WALLET_PAY     @"Wallet"
#define  CARD            @"Card"
/// El pago movil, escrito igual que en Android (setValuePayMode).
#define  PAGO_MOVIL_PAY  @"Pago Movil"


//side Menu
#define SIDE_MENU_LOGOUT        @"power-button"
#define SIDE_MENU_TERMS         @"terms_condition"
#define SIDE_MENU_SHARE         @"share"
#define SIDE_MENU_DEACTIVATE    @"deactivate"
#define SIDE_MENU_SUPPORT       @"support"






// string contants

#define P_STATUS @"status"
#define P_RESPONSE @"response"
#define P_STATUS_OK @"OK"
#define P_MESSAGE @"message"
#define P_ERROR @"error"

#define P_FAVOURITE_DEALS @"favourite"

// LOGIN
#define P_ADDRESS @"address"
#define P_CITY @"City"
#define P_CITY_ID @"city_id"
#define P_P_CITY_ID @"p_city_id"
#define P_C_CODE @"c_code"
#define P_ISO_CODE @"iso_code"

#define P_COUNTRY @"Country"
#define P_EMAIL @"d_email"
#define P_USER_ID @"user_id"
#define P_PASSWORD @"d_password"
#define P_U_PASSWORD @"u_password"
#define P_NEW_PASSWORD @"new_password"
#define P_DRIVER_LAT @"d_lat"
#define P_DRIVER_LNG @"d_lng"
#define P_LANGUAGE @"d_lang"
#define P_U_LANGUAGE @"u_language"
#define P_MOBILE @"d_phone"
#define P_STATE @"state"
#define P_STATUS @"status"
#define P_TOKEN @"token"
#define P_USERNAME @"username"
#define P_ZIP @"u_zipcode"
#define P_FNAME @"d_fname"
#define P_DRIVER_ID @"driver_id"
#define P_DRIVER_DEGREE @"d_degree"
#define P_USER_WAlLET_AMOUNT     @"u_wallet"
#define P_DRIVER_WAlLET_AMOUNT     @"d_wallet"
#define P_IS_SINGLE_MODE     @"is_single_mode"
#define P_FIRE_ID @"fire_id"

// User Keys
#define P_U_MOBILE @"u_phone"
#define P_U_EMAIL @"u_email"
#define P_U_FNAME @"u_fname"
#define P_U_LNAME @"u_lname"
#define P_LAT                       @"lat"
#define P_LNG                       @"lng"
#define  TS_USER_CANCEL         @"cancel"
#define TS_ASSIGNED          @"assigned"
#define  TS_DRIVER_CANCEL    @"driver_cancel"
#define P_STRIPE_CUS_ID             @"stripe_cust_id"
#define P_STRIPE_DEV_CUS_ID         @"stripe_dev_cust_id"
#define P_STRIPE_CUS_DEV_CUS_ID         @"cus_Q5MoFtANgHGMPd"

#define P_USER_DEFAULT_PAY_METHOD        @"pay_method"
#define P_USER_IS_AVAILABLE         @"u_is_available"
#define TRIP_GET_USER_TRIP              @"tripapi/getusertrips"
#define API_SEND_SOS       @"constantapi/sendsos"
#define GET_DRIVERS_NEARBY          @"driverapi/getnearbydriverlists"
#define API_SAVE_RENTALS_TRIP             @"serviceapi/saverentals"
#define API_GET_TRIP_OFFERS              @"triprequestapi/gettriprequests"
#define API_UPDATE_OFFER                         @"triprequestapi/updatetriprequest"
#define GET_WALLET_ADD_TRIP_TRAN_REG          @"transactionapi/addtriptransrevised"
#define P_USER_LAT                  @"u_lat"
#define P_USER_LNG                  @"u_lng"
#define GET_SEND_NOTIFICATION_TRIP_SAVE  @"tripapi/sendnotificationontripsave"
#define P_USER_DEFAULT_PAY_MODE        @"u_pay_mode"
#define P_PROFILE_IMAGE_PATH        @"u_profile_image_path"
#define UPDATE_USER_PASSWORD        @"userapi/updateuserpassword"





#define P_DRIVER_PROFILE_IMAGE_PATH @"d_profile_image_path"
#define P_NAME @"d_name"
#define P_LNAME @"d_lname"
#define P_DRIVER_AVAILAILITY @"d_is_available"
#define P_DRIVER_VERIFIED    @"d_is_verified"
#define PROMO_PAY_ACCEPT            @"accept_payment_promo"
#define TRIP_FEEDBACK               @"trip_feedback"
#define SAVED_TOKEN             @"saveToken"
#define TRIP_GET_PENDTING_TRIP              @"tripapi/getpendingtrips"
#define P_CAR_MODEL @"car_model"
#define P_CAR_NAME  @"car_name"
#define P_CAR_MAKE  @"car_make"

#define P_CAR_LICENSE_NUMBER @"car_reg_no"

#define P_IS_SEND_EMAIL @"is_send_email"

#define P_GENDER @"gender"
#define P_API_KEY @"api_key"
#define P_DEVICE_TOKEN @"u_device_token"
#define P_DEVICE_TYPE @"u_device_type"
#define P_D_DEVICE_TOKEN @"d_device_token"
#define P_D_DEVICE_TYPE @"d_device_type"
#define P_CATEGORY_ID @"category_id"

#define P_CATEGORY_BASE_PRICE  @"cat_base_price"
#define P_CATEGORY_FARE_PER_KM  @"cat_fare_per_km"
#define P_CATEGORY_FARE_PER_MIN @"cat_fare_per_min"
#define P_CATEGORY_SPECIAL_FARE @"cat_special_fare"
#define P_CATEGORY_SPECIAL_FARE_JSON @"cat_special_fare_json"
#define P_CATEGORY_BASE_PRICE_MONDAY @"monday"
#define P_CATEGORY_BASE_PRICE_TUESDAY @"tuesday"
#define P_CATEGORY_BASE_PRICE_WEDNESDAY @"wednesday"
#define P_CATEGORY_BASE_PRICE_THURSDAY @"thursday"
#define P_CATEGORY_BASE_PRICE_FRIDAY @"friday"
#define P_CATEGORY_BASE_PRICE_SATURDAY @"saturday"
#define P_CATEGORY_BASE_PRICE_SUNDAY @"sunday"

#define P_CATEGORY_IS_FIXED_PRICE @"cat_is_fixed_price"
#define P_CATEGORY_PRIME_TIME_PERCENTAGE @"cat_prime_time_percentage"


#define P_CAR_ID @"car_id"

#define P_CAT_NAME @"cat_name"
#define P_USER_DICT @"user_dict"
#define P_USER_DICT_LOGGED @"user_dict_logged"
#define P_CATEGORY_NAME         @"cat_name"
#define P_IS_SHOW_EXTRA_POPUP @"Yes"
#define  is_availability_on     @"is_availability_on"

//  MARK:- DRIVER Wallet Api
#define GET_WALLET_USER_TRANS             @"transusrapi/getusrtrans"
#define GET_WALLET_ADD_TRIP_TRAN          @"transactionapi/addtriptrans"
#define GET_WALLET_ADD_TRAN_WITHOUT_TRIP  @"transactionapi/addtranswithouttrip"
#define GET_WALLET_TRANS                  @"transactionapi/gettransactions"
#define GET_WALLET_COMP_TRANS             @"transcompapi/getcomptrans"
#define GET_WALLET_DRV_TRANS              @"transdrvapi/getdrvtrans"
// Driver Payout
#define API_GET_DRIVER_ADD_PAYOUT              @"driverpayoutapi/addpayout"
#define API_GET_DRIVER_PAYOUT              @"driverpayoutapi/getpayouts"
#define P_APYOUT_AMOUNT @"amount"

//#define  enabledDecimal  1

#define API_ESTIMATE_FARE_NORMAL            @"tripapi/estimatetripfare"

#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)


#endif


