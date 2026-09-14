//
//  Keys.h

//
//  Created by  Appicial on 06/10/17.
//  Copyright © 2023 Appicial. All rights reserved.
//

#ifndef Keys_h
#define Keys_h

#define IS_USE_NODE_SERVER 1

#define SOCKET @"https://socket.conrra.com"

#define BASE_URL_DRIVER     @"https://apps.conrra.com/webservices/1.1.3/index.php/"       // add your base url here
#define url_base_images     @"https://apps.conrra.com/webservices/images/originals/"      // add your image base url here

// Los avisos push salen por el rele de conrraservices, NO por notif.conrra.com.
//
// Aquel servicio (EadminNs, Node) levanta HTTPS con el certificado de apps.conrra.com
// para servir notif.conrra.com: el proxy rechaza el handshake y devuelve 500 en el 100%
// de las llamadas. Medido el 2026-09-13 y tambien el 2026-09-01 desde Android.
//
// El rele nuevo habla FCM v1 directamente con Google y entiende el MISMO formato: mismo
// cifrado AES-128-CBC (IV/KEY de abajo, identicos a los de Android), el token en "ios" o
// "android" y la misma respuesta {"status":"OK","code":200,...}. Por eso los ~10 sitios
// que mandan avisos en esta app no cambian: solo cambia la URL.
#if( IS_USE_NODE_SERVER == 1)
#define url_notification    @"https://www.conrraservices.com/recargas/api/push.php"
#else
#define url_notification    @"https://apps.conrra.com/webservices/push/"                  // add your notification base url here
#endif
#define BASE_NODE_API    @"https://getservice.ca:3003/"



#define url_booking @"https://bookaride.getservice.ca/"
#define SHARE_TRIP_URL                @"https://indriver.stitchmyapp.com/indriver1.0/MapRoute/index.php"

/**
 Publicidad y Planes.

 Despliegue aparte del backend de produccion: el catalogo necesita plan, vigencia, URL de
 destino y contadores, y la tabla announcements del backend no tiene nada de eso. Ademas
 lleva cuentas, roles y circuito de aprobacion propios. Ver backend-publicidad/ en el
 repositorio de Android.

 NO VA CIFRADO, a diferencia del resto de la API: lo que devuelve es publicidad, o sea
 justo lo que queremos que vea todo el mundo. Por eso se pide con NSURLSession directo y
 no por GIKit.

 La diferencia entre banners y planes es el destino. Un banner trae una URL y el app abre
 el navegador; un plan trae un PUNTO y el app lo pone como destino del viaje.
 */
#define PUBLICIDAD_HOST     @"https://conrraservices.com/publicidad"
#define URL_BANNERS         PUBLICIDAD_HOST @"/api/banners.php"
#define URL_BANNER_EVENTO   PUBLICIDAD_HOST @"/api/banner_evento.php"
#define URL_PLANES          PUBLICIDAD_HOST @"/api/planes.php"
#define URL_PLAN_EVENTO     PUBLICIDAD_HOST @"/api/plan_evento.php"

/**
 La recarga de la billetera. Se le pega el id del usuario: ?id=1234.

 Es la misma pagina que abre Android (WebPageActivity con este enlace) y la misma que
 debe abrir "Recargas" del menu lateral -- que apuntaba a google.com con un TODO.
 */
#define URL_RECARGAS        @"https://www.conrraservices.com/recargas/index.php"

#define BASE_URL_OTP        @"https://apps.conrra.com/webservices/tw_sms/index2.php"
#define BASE_URL_OTP_NO        @"https://apps.conrra.com/webservices/tw_sms/index.php"
#define url_base_app_images             @"https://apps.conrra.com/webservices/images/app_images/"    // Image Base URL
#define url_base_category             @"https://backend.conrra.com/"    // Image Base URL
 
#define default_fire_password              @"testtest"
#define pre_fix_fire_email              @""
#define default_u_fire_password              @"testtest"
#define pre_fix_u_fire_email              @""

#define TRIP_TIMER_DURATION 5.0

#define IS_PHONE_VERIFICATION   1
#define IS_PHONE_VERIFICATION_WITH_PASSWORD   1


#define IS_ENABLE_TRAFFIC    0   // Keep this value same in Driver also


#define RIDE_LATER_DELAY 30*60 // one hours
#define TRIP_EXPIRE_TIME 5*60 // one hours
//#define TRIP_EXPIRE_TIME 125*60 // one hours

#define  IV  @"OWMwZjczMDg2MGNm"
#define  KEY  @"26kozQaKwRuNJ24t"
#define  enabledEncy  YES


#define  DAY_START_HURS  7
#define  DAY_END_HURS  17

#define Default_City_Count 1
#define Data_BASE_NAME @"routePath.db"
#define Default_Country_Code @"91"

#define Password_Length 1
#define  Mobile_Min_Length 5

#endif /* Keys_h */
