# Conrra iOS — reparación pantalla a pantalla (flujo PASAJERO)

Referencia: `C:\Android\conrra` (versión funcional). Backend: `C:\xampp8\htdocs\apps`.
Estado de cada fila: PENDIENTE / EN CURSO / HECHO (compila) / HECHO (verificado en dispositivo).

## 0. Transversal (rompe varias pantallas a la vez)

| # | Asunto | Android | iOS | Estado |
|---|---|---|---|---|
| T1 | Relé de push | `conrraservices.com/recargas/api/push.php` → **200** | `notif.conrra.com` → **500 medido** | **HECHO** (Keys.h) |
| T2 | Traducciones del servidor | `localisationapi/*` | ~~no existe~~ **SÍ existe** en `LanguageHelper.m` | **NO APLICA** |
| T3 | Verificación de teléfono | SIM (Phone Number Hint), sin SMS de pago | Twilio `tw_sms/index2.php` | PENDIENTE |
| T4 | Sistema de diseño | `#EBB518`, Noto Sans, tokens | template Appicial | PENDIENTE |

## 1. Flujo de pasajero (orden de la app)

| # | Pantalla | Android | iOS | Estado |
|---|---|---|---|---|
| 1 | Splash | `SplashScreenActivity` (422) | `LaunchScreenDrivnew.storyboard` | PENDIENTE |
| 2 | Onboarding | `OnBoardingActivity` (258) | ¿`HelperViewController`? | PENDIENTE |
| 3 | Login | `SignInFragment` + `activity_login.xml` | `OtpSignInViewController` | PENDIENTE |
| 4 | Registro | `RegisterFragment` | `OtpSignUpViewController` | PENDIENTE |
| 5 | OTP | `OTPActivity` (889) | `OTPVerifyViewController` | PENDIENTE |
| 6 | Home | `MainScreenActivity.kt` (5933) | `UHomeViewController` (4861) | PENDIENTE |
| 7 | Ingresa tu ruta | destino en MainScreen | `URouteInputViewController` (373) | PENDIENTE |
| 8 | Tarifa recomendada | `FareActivity` (551) | `UFareSummeryViewController` (2020) | PENDIENTE |
| 9 | Ofertas de conductores | `OffersActivity.kt` | `TripOffersViewContoller` | PENDIENTE |
| 10 | Viaje en curso | `TrackDriverActivity` (427) | `BeginTripViewController` (2618) | PENDIENTE |
| 11 | Recibo | `FareDetailsActivity` (119) | `FareDetailsViewController` | PENDIENTE |
| 12 | Valoración | `FareReviewActivity` (193) | `UFareReviewViewController` (280) | PENDIENTE |

## 2. Pantallas CONRRA que en iOS NO EXISTEN

| # | Pantalla | Android | Estado |
|---|---|---|---|
| N1 | Planes (lugares/ofertas, botón IR) | `riderapp/planes/` 5 clases | PENDIENTE |
| N2 | Publicidad (carrusel al buscar conductor) | `riderapp/banners/CarruselBanners.java` | PENDIENTE |
| N3 | SOS / Emergencia | `SosActivity` (148) | PENDIENTE |
| N4 | Contactos de emergencia | `EmergencyContactsActivity` | PENDIENTE |

## 3. Cuenta del pasajero

| # | Pantalla | Android | iOS | Estado |
|---|---|---|---|---|
| C1 | Menú lateral | drawer rider | `ULeftViewController` (904) | PENDIENTE |
| C2 | Mi perfil | `EditProfileActivity` (700) | `UEditProfileViewController` (795) | PENDIENTE |
| C3 | Tus viajes | `TripHistoryActivity` (421) | `UTripHistoryViewController` (1404) | PENDIENTE |
| C4 | Notificaciones | `NotificationActivity` (170) | `UNotificationViewController` (271) | PENDIENTE |
| C5 | Billetera | `WalletActivityNew` (215) | `UWalletViewController` (556) | PENDIENTE |
| C6 | Recargar saldo | `AddMoneyActivity` (244) | `UAddMoneyWalletVC` (206) | PENDIENTE |
| C7 | Métodos de pago | `PaymentMethodsActivity` (350) | `PaymentMethodListViewController` | PENDIENTE |
| C8 | Idioma | `LanguageSelectionActivity` (168) | `LanguageViewController` | PENDIENTE |
| C9 | Mis documentos | `DocUploadUserActivity` (733) | `UploadDocumentViewController` | PENDIENTE |
| C10 | Chat | `chat/ChatActivity` | `UChatViewController` (461) | PENDIENTE |
| C11 | Refiere y gana | `ReferActivity` | `ReferralViewController` | PENDIENTE |
| C12 | Hazte conductor | `SwitchToDriverActivity` (226) | `BecomeDriverVC` (203) | PENDIENTE |
| C13 | Legal | `LegalActivity` | `LegalViewController` | PENDIENTE |

## Hechos medidos (no supuestos)

- `notif.conrra.com/backend/notification/send` → HTTP 500. `conrraservices.com/recargas/api/push.php` → HTTP 200. Medido 2026-09-13.
- Endpoints: 60 en iOS, 69 en Android, 101 en el backend.
- iOS declara 2 endpoints inexistentes (`partnerassetapi/addpartnerasset`, `serviceapi/saverentals`) pero **no los usa**: código muerto, no rotura.
- iOS **no usa nunca** `constantapi/sendsos` aunque lo declara → no hay SOS.
- Ningún proyecto es repo git: no hay historia ni forma de revertir salvo copia.


---

# CORRECCIÓN 2026-09-13 — el estado real de iOS

Mi primera lectura estaba mal. iOS **no** es el template de 2023 sin tocar: ya tiene
trabajo CONRRA hecho (onboarding de 4 páginas idéntico a Android, cadenas en español,
claves `k_s10_*` del rediseño). Dos cosas que afirmé y eran falsas:

- «iOS no tiene `localisationapi`» — sí lo tiene, en `LanguageHelper.m` como literal.
  Mi barrido solo miraba `WebCallConstants.h`.
- «iOS es el template Appicial sin personalizar» — 17 ficheros llevan el rediseño CONRRA.

## Pantallas de PASAJERO con rediseño CONRRA ya hecho

`HelperViewController` (onboarding) · `OtpSignUpViewController` (registro) ·
`UHomeViewController` (home) · `URouteInputViewController` (ruta) ·
`UFareSummeryViewController` (tarifa) · `UFareOfferViewController` (oferta) ·
`PaymentMethodViewController` · `UWalletViewController` · `ULeftViewController` (menú) ·
`SettingViewController` · `HomePaymentViewModel`

## Pantallas de PASAJERO que existen pero SIN rediseño

`OtpSignInViewController` (login) · `OTPVerifyViewController` (OTP) ·
`BeginTripViewController` (viaje en curso, 2618 líneas) · `UFareReviewViewController`
(valoración) · `FareDetailsViewController` (recibo) · `UTripHistoryViewController`
(historial) · `UNotificationViewController` · `UEditProfileViewController` (perfil) ·
`UAddMoneyWalletVC` (recargar) · `UChatViewController` · `LanguageViewController` ·
`BecomeDriverVC` · `TripOffersViewContoller` (ofertas) · `UploadDocumentViewController`

## Pantallas que NO existen en iOS (confirmado por búsqueda en todo el código)

1. **Planes** — Android: `riderapp/planes/` (5 clases). iOS: 0 ficheros.
2. **Publicidad / carrusel de banners** — Android: `riderapp/banners/CarruselBanners.java`. iOS: 0.
3. **SOS** — Android: `SosActivity`. iOS: declara `constantapi/sendsos` y **no lo llama nunca**;
   el menú lleva a `SettingViewController`.
4. **Recargas** — en iOS solo está en el menú del CONDUCTOR (`LeftViewController`, webview),
   no en el del pasajero.
5. **Documentos del pasajero** — Android usa `userassetapi/adduserasset`/`getuserassets`;
   iOS no tiene ninguno de los dos.

## Pendiente de decisión tuya

- El relé fuerza `'sound' => 'default'` (`backend-pagos/lib/fcm.php:84`), así que tras
  arreglar T1 los sonidos propios (`cab_arrive.caf`, `driver_accepted.caf`…) se pierden.
  El parche es de 2 líneas pero toca un servicio DESPLEGADO. No lo he tocado.


---

# LOTE 1 — para compilar (2026-09-13)

Ficheros tocados. Copia de seguridad de cada uno en `.backup-conrra/20260913/`.

## `Conrra/Configurable/Keys/Keys.h`
`url_notification` pasa de `notif.conrra.com/backend/notification/send` (500 medido) a
`www.conrraservices.com/recargas/api/push.php` (200 medido). Nada mas cambia: mismo
cifrado AES (IV y KEY identicos a los de Android), mismas claves de token (`ios` /
`android`), misma respuesta. Los ~10 sitios que mandan avisos siguen igual.

## `App Logic/UserAppLogic/USettings/SettingViewController.m`
Tres arreglos. La pantalla se abre desde el menu del CONDUCTOR y el del PASAJERO.

1. **Reparto por rol.** Guardaba siempre por `driverapi/updatedriverprofile` con
   `driver_id`. El pasajero no tiene `driver_id`: su contacto de emergencia no se
   guardaba en ningun sitio. Ahora el pasajero va por `userapi/updateuserprofile` con
   `user_id`, como en Android.

2. **`usr_ref_id` en el camino del conductor.** `DriverAPI::postUpdateDriverProfile`
   propaga a la tabla `users` solo dentro de `if ($userID)`, y `$userID` sale de
   `usr_ref_id`. Sin el, lo que guarda el conductor se queda en `drivers` — y
   `DriverModel::updateDriver` copia los `emergency_*` de `users` HACIA `drivers`, asi
   que se pisa en la siguiente sincronizacion. El SOS lee `P_USER_DICT_LOGGED`, que es
   el registro de usuario.

3. **Pago movil al contrato de Android.** Escribia cuatro campos inventados
   (`pago_movil_banco`, `pago_movil_telefono`, `pago_movil_doc_tipo`,
   `pago_movil_doc_numero`) que no aparecen ni una vez en el backend ni en Android.
   Ahora es el JSON `{bank, phone, cc, idType, idNumber}` en `d_bank_info` (conductor)
   o `emergency_email_3` (pasajero), que es lo que lee `RecargaC2PActivity`.

   Ademas: `CoreModel::update` mete todos los campos en un unico `UPDATE` sin filtrar
   columnas, asi que una columna inexistente tumbaba la sentencia entera — y con ella
   el `emergency_contact_1` que viajaba en la misma llamada.

4. **Destinatario del SMS de emergencia.** `ButtonSms` metia la cadena entera
   `movil|nombre|prefijo|iso` como numero, y cuando no habia contacto se guarda `"|"`,
   que tambien pasaba el `length > 0`. Nuevo helper
   `+telefonoDeContactoDeEmergencia:` que devuelve `+prefijo+movil`.

5. Se añade rama de error: antes un fallo del servidor no decia nada y la pantalla se
   quedaba como si hubiera guardado.

## Comprobado sin compilador
Simbolos usados y donde estan declarados: `P_IS_USER_LOGIN` y `P_USER_DICT_LOGGED`
(`WebCallConstants.h`), `getCurrentCountryDictWithIsoCode:` (`CounrySelectionView.h`,
ya importado), `showWarningWithMessgae:` (`BaseViewController.h`, clase padre),
`isEmpty()` (`WebCallConstants.h`), `defaults_object` (GIKit).
Llaves, corchetes y parentesis balanceados ignorando comentarios y literales.
**Esto NO sustituye a compilar.**

## Sigue pendiente de tu decision
El rele fuerza `'sound' => 'default'` (`backend-pagos/lib/fcm.php:84`): tras el arreglo
del push, los sonidos propios (`cab_arrive.caf`, `driver_accepted.caf`,
`trip_complete.caf`...) se pierden. El parche son 2 lineas pero toca un servicio
DESPLEGADO. No lo he tocado.


---

# LOTE 2 — Publicidad de la espera (2026-09-13)

En iOS no existia: 0 ficheros. Android la tiene en `riderapp/banners/CarruselBanners.java`.

## Ficheros NUEVOS
- `App Logic/UserAppLogic/Publicidad/ConrraCarruselBanners.h/.m`

Misma logica que Android: el orden lo decide el rele (premium delante, sorteado dentro de
cada grupo), **una impresion por banner y por espera** — no una por vuelta del carrusel,
que inflaria lo que se le factura al anunciante —, intervalo acotado a 3–30 s con 6 por
defecto, y todo falla hacia no molestar.

## Ficheros TOCADOS
- `Configurable/Keys/Keys.h` — `PUBLICIDAD_HOST` y las cuatro URLs.
- `Supporting Classes/InDriver-Bridging-Header.h` — para que Swift lo vea.
- `App Logic/UserAppLogic/UHome/TripOffers/TripOffersViewContoller.swift` — el hueco del
  banner debajo del boton de cancelar, en el estado "Buscando Conductor".
- `Conrra.xcodeproj/project.pbxproj` — grupo `Publicidad` bajo `UserAppLogic`.

## Comprobado midiendo
- `GET /publicidad/api/banners.php` responde **JSON en claro, sin cifrar**. Por eso se usa
  `NSURLSession` directo y no GIKit, igual que dice el propio `planes.php`: "lo que devuelve
  es publicidad, o sea justo lo que queremos que vea todo el mundo".
- Registro en el pbxproj: mi primer intento metio el `.m` en la fase **Resources**, porque
  `/* Sources */` tambien es el nombre de un PBXGroup de la libreria Socket.IO. Restaurado
  desde copia y rehecho anclando en `isa = PBXSourcesBuildPhase`.

## Divergencia deliberada frente a Android
En Android el banner vive en el mismo layout con scroll que las ofertas y se queda puesto.
Aqui el panel conmuta entre dos estados con alfa, asi que dejarlo en el de ofertas lo
montaria encima del scroll: **solo se enseña durante la espera**. Las impresiones no se
resienten, porque se cuenta una por banner y por espera.

---

# LOTE 3 — Seccion Sitios / Planes (2026-09-13)

En iOS no existia: 0 ficheros. Android la tiene en `riderapp/planes/` (5 clases).

## Ficheros NUEVOS
- `Publicidad/ConrraDestinoDePlan.h/.m` — el buzon del destino.
- `Publicidad/ConrraCatalogoDePlanes.h/.m` — API y modelo.
- `Publicidad/PlanesViewController.h/.m` — la pantalla.

## Ficheros TOCADOS
- `USideMenu/LeftVC/ULeftViewController.m` — entrada "Sitios", solo si el backend enciende
  `enable_sitios`.
- `UHome/UHomeViewController.m` — `viewDidAppear` recoge el destino preparado.
- `Conrra.xcodeproj/project.pbxproj` — los seis ficheros.

## Lo que la hace distinta de una cartelera
El boton IR no abre la web del anunciante: pone ese local como destino del viaje y devuelve
al pasajero al home con la ruta ya calculada. **No se pide el viaje solo**, a proposito: se
deja el destino puesto y la tarifa a la vista, y el pasajero decide.

## Decisiones que costaron una comprobacion
- **`enable_sitios` no se lee con `getCValueFK:`.** Ese metodo mira otro diccionario (el de
  "constants_p"). `enable_sitios` llega en la lista normal `constantResponse`, que es la que
  Android lee con `getConstantsValueForKeyEmpty`. Se añadio
  `+[PlanesViewController valorDeConstante:]` para eso, aceptando tambien la variante con
  espacios en vez de guiones bajos, como Android.
- **El buzon en vez de una propiedad**: al volver de Sitios, `UHomeViewController` casi
  siempre ya existe en la pila y no pasa por `viewDidLoad`.
- **Se reintenta 15 x 0,4 s** antes de aplicar el destino: `viewWillAppear` pone
  `direction.source` en `emptyLoc` y el origen real llega despues por GPS. Aplicarlo antes
  deja un destino escrito y ninguna ruta. Si nunca llega origen, se suelta el buzon para que
  el destino no salte en la siguiente vuelta.
- **Sin pais en el destino** (`dropCountry = @""`): el plan trae coordenadas y nombre, no
  terminos de Google. Android hace lo mismo — `setDropData` no pasa pais — y este fichero ya
  deja `dropCountry` vacio en otros caminos de reinicio.
- **La impresion se cuenta en `willDisplayCell:`**, no al construir la celda, por la misma
  razon que Android la cuenta en `onViewAttachedToWindow` y no en `onBindViewHolder`: la
  lista prepara celdas por delante del borde de la pantalla.

## Dos errores mios que corregi antes de entregar
- Use `FONTS_NOTO_BOLD_NO_SCALE` / `FONTS_NOTO_REGULAR_NO_SCALE`: **no existen**. Solo hay
  las versiones escaladas de Noto y las `_NO_SCALE` de Karla.
- Use el color `color_app_bg_card`: **no existe**. El que hay es `color_app_box_bg`.

## Lo que falta para que la seccion se vea
1. **`enable_sitios` tiene que valer 1** en la tabla de constantes del backend. Si no, la
   entrada del menu no aparece — por diseño, igual que en Android.
2. **Icono propio**: se reusa `menu_icon_star` porque no hay uno de "sitios". Es de la misma
   familia de iconos de linea, asi que el tinte gris le sienta igual. Cambiar el nombre en
   `ULeftViewController.m` basta.
3. Las claves `k_s10_planes_*` no estan en el servidor de traducciones todavia: se usan los
   textos por defecto en español, que son los mismos de `strings.xml` de Android.


---

# LOTE 4 — Login, OTP y viaje en curso (2026-09-13)

## Decision tomada: el metodo de verificacion NO se toca

Android verifica el telefono con la **Phone Number Hint API** de Play Services: el numero
sale de una SIM del propio aparato y no puede inventarse (`OTP_METODO = "sim"`). **Apple no
expone el numero de la SIM a las apps por ninguna via**, asi que las dos plataformas no se
pueden igualar aqui. Quedan pendientes las tres salidas reales — Firebase Phone Auth (que
Android ya tiene implementado en `VerificacionTelefono.java` y cuyo pod **ya esta** en el
Podfile), verificacion en el servidor, o sin verificacion. Por ahora se deja Twilio.

## Los tres fallos del login/OTP, arreglados sin tocar el metodo

### 1. El codigo reenviado nunca podia validar
`OTPVerifyViewController.verifyMobileNo` genera un `smsCode` nuevo en cada reenvio y lo
manda, pero `validateOTP` compara contra `self.verificationCode`, que solo se asignaba UNA
vez: cuando la pantalla anterior empujaba esta (`vc.verificationCode = smsCode`, en los
tres llamadores). **El unico codigo que servia era el primero.** Justo quien no recibia el
primer SMS — que es quien pulsa reenviar — se quedaba encerrado sin poder entrar ni
registrarse.

### 2. La app no podia saber si el SMS habia salido
`webservices/tw_sms/index2.php` responde `status = "OK"` en TODAS sus ramas: cuando manda
el SMS, cuando le faltan parametros, y **tambien dentro del `catch` de Twilio**, donde solo
cambia `code` a 400. Las cuatro pantallas miraban unicamente `status`, asi que un numero
invalido o el saldo agotado se leian como envio correcto.
Nuevo `+[Utilities seEnvioElSms:]`, que mira tambien `code`.

### 3. Callejon sin salida al fallar el envio
Login, registro y recuperar contraseña seguian a la pantalla del codigo aunque la respuesta
no llegara. Ahora avisan y no continuan, que es lo que ya hacia el reenvio en el mismo
fichero.

Ficheros: `Utilities.h/.m` (ayudante nuevo), `OtpSignInViewController.m`,
`OtpSignUpViewController.m`, `ForgotPasswordViewController.m`, `OTPVerifyViewController.m`.

## Viaje en curso: los avisos locales, que no existian

**En todo el proyecto iOS habia CERO notificaciones locales** (`UNMutableNotificationContent`:
0 apariciones). Sumado a que el push salia por `notif.conrra.com` — 500 en el 100% de las
llamadas hasta el lote 1 —, el pasajero de iOS **no tenia ninguna forma de enterarse de que
el conductor habia llegado** salvo mirando la pantalla.

Lo que habia: `arriveTripCalled` enseñaba una alerta dentro de la app, y solo si
`isShowAlert` daba YES, que exige que el viaje se haya modificado hace menos de 20 segundos.
Con el telefono bloqueado o la app detras, nada.

### Ficheros NUEVOS
- `App Logic/Utility/ConrraAvisoLocal.h/.m`

### Ficheros TOCADOS
- `AppDelegate.m` — dos cosas. El delegado devolvia `UNNotificationPresentationOptionNone`
  para TODO, asi que en primer plano no se veia nada; y pasaba TODO por
  `manageRemoteNotification:`, que espera un push con `aps` y `trip_status`. Los avisos
  propios se marcan en `userInfo` con `kConrraAvisoLocalMarca` y se tratan aparte.
- `BeginTripViewController.m` — `avisarConductorEnSitio` (llegada, con el codigo OTP dentro,
  sonido `cab_arrive.caf` y vibracion, una sola vez por viaje con la misma clave que Android)
  y `avisarMensajeNuevoSiToca:` (mensaje nuevo del conductor).
- `Conrra.xcodeproj/project.pbxproj` — los dos ficheros en el grupo `Utility`.

### Frenos del aviso de mensaje, los mismos que Android
Solo cuando el numero de no leidos SUBE; nunca en la primera lectura, que trae los que ya
estaban sin leer; y nunca si el pasajero ya tiene el chat delante.

### Comprobado
- `cab_arrive.caf` **si** esta en la fase Resources del proyecto (`project.pbxproj:3567`),
  asi que el sonido existe de verdad.
- `CLANG_ENABLE_MODULES = YES` en las dos configuraciones: `AudioToolbox` y
  `UserNotifications` se enlazan por modulo aunque no figuren en el pbxproj, igual que ya
  pasa con el `AppDelegate`, que usa ambos.
- El contador de no leidos y el distintivo rojo **ya existian** en iOS
  (`FirebaseUnReadChat` + `MIBadgeButton`): no se ha duplicado nada, solo faltaba avisar.


---

# LOTE 5 — Recibo y valoracion (2026-09-13)

## Primero, el mapeo correcto

En Android el recibo y la valoracion van JUNTOS en `FareActivity`. `FareReviewActivity` no
la abre nadie: es codigo muerto, como `SosActivity`. En iOS pasa lo mismo:
`UFareSummeryViewController` es el equivalente de `FareActivity`, y
`UFareReviewViewController` es el gemelo muerto.

## Dos cosas que comprobe y NO estaban rotas

- **La valoracion de iOS si actualiza la media del conductor.** Llama a
  `updateDriverRating:` (lineas 899 y 2009) y encadena `updateFeedbackInTrip:` en el
  bloque, con la misma formula que Android. Lo di por roto al mirar solo una funcion.
- **La moneda local si existe** en el recibo (`formatAmountDual:`). Tambien lo di por
  ausente antes de mirarlo entero.

## 1. La conversion a moneda local estaba AL REVES

`formatAmountDual:` dividia el importe entre la tasa y etiquetaba el original como si ya
fuera moneda local. Los importes vienen en DOLARES y la tasa dice cuantos bolivares vale un
dolar (`Controller.getDollarToLocalRate`: "el equivalente de moneda local por cada dolar,
ej. 560"). Con tasa 560 y un viaje de 10 $, iOS escribia **"($0.02 USD)"**.

Y encima leia la constante `currency_conversion` mientras Android lee **`bs`** — con
"prioridad absoluta a 'bs' para sincronizar rider/driver", dice su comentario. Mientras esa
fuera la unica clave que se mirara, lo mas probable es que iOS no enseñara ningun importe
en bolivares.

Nuevo `+[ConstantModel tasaDolarALocal]`, con la misma lista de candidatos que Android
(`bs`, `tasa`, `tasa_bs`, `taza`, `taza_bs`, `conversion_rate`, `rate`,
`currency_conversion`) y tolerante a la coma decimal.

## 2. El boton "Dar propina" hacia lo contrario de lo que decia

Su accion era `ndSkipRatingTapped`, que cierra la valoracion y se va al inicio. La propina
no existia en iOS. Portada de `FareActivity.showTipInputDialog` / `submitTip`: dialogo con
el importe, `trip_tip` por `tripapi/updatetrip`, y aviso al conductor por el rele
(`tip_received`).

## 3. El recibo no decia donde pagarle al conductor

`d_bank_info` **no existia en el `DriverModel` de iOS**, asi que los datos de pago movil del
conductor no llegaban nunca. Añadido al modelo y enseñado en el ticket, con el mismo JSON
`{bank, phone, cc, idType, idNumber}` que lee `RecargaC2PActivity` de Android y que escribe
`SettingViewController` desde el lote 1. Si las dos apps no coincidieran aqui, un conductor
de iOS seria invisible para un pasajero de Android.

**Divergencia deliberada:** Android esconde la tarjeta cuando no hay datos; aqui se enseña
siempre, con "No registrado". El recibo se monta con marcos fijos en `viewDidLoad` y los
valores llegan despues en `setDataonUI`: esconderla obligaria a recalcular el alto del
ticket y mover el boton. Ademas, decirle al pasajero que el conductor no tiene pago movil
es justo lo que necesita saber antes de intentar pagarle.

## 4. De paso: el lector de constantes, en su sitio

`+[ConstantModel valorDeConstantePorClave:]` reemplaza al duplicado que puse en
`PlanesViewController` en el lote 3. No es lo mismo que `getCValueFK:`, que mira
`enableInfo` — otro diccionario, solo con las banderas cortas.

## Ficheros
NUEVOS: ninguno.
TOCADOS: `ConstantModel.h/.m`, `DriverModel.h/.m`, `UFareSummeryViewController.m`,
`PlanesViewController.m`.

## Anotado, sin tocar
En el menu del CONDUCTOR (`LeftViewController.m:150`) la tasa de cambio esta fija en
`"Bs. 0.00"` y nadie la rellena nunca. Ahora que existe `+[ConstantModel tasaDolarALocal]`
es una linea, pero es pantalla de conductor y este trabajo va por el pasajero.
