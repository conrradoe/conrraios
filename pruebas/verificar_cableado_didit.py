# -*- coding: utf-8 -*-
"""
Comprueba sobre el CODIGO REAL que registro y reset de contrasena estan cableados a Didit.

No mira comentarios: los quita antes de buscar. Esto no es cosmetica -- mis propios
comentarios nombran `conFirebase`, `boolValue` y `d_phone` para explicar los fallos que
hubo, y un verificador que los cuente diria que el fallo sigue ahi (o al contrario, daria
por bueno un arreglo que solo esta escrito en prosa).
"""
import io, os, re, sys

RAIZ = os.path.join(os.path.dirname(os.path.dirname(
    os.path.abspath(__file__))), "Conrra")
A = RAIZ + "/InDriver/App Logic"

FICHEROS = {
    "registro":   A + "/OtpProcess/SignUpView/OtpSignUpViewController.m",
    "reset":      A + "/ForgotPasswordView/ForgotPasswordViewController.m",
    "pantalla":   A + "/OtpProcess/Otpverification/OTPVerifyViewController.m",
    "fachada":    A + "/Utility/ConrraVerificacionTelefono.m",
    "didit":      A + "/Utility/ConrraVerificacionDidit.m",
    "e164":       A + "/Utility/ConrraTelefonoE164.m",
    "keys":       RAIZ + "/Configurable/Keys/Keys.h",
}

def sin_comentarios(texto):
    texto = re.sub(r"/\*.*?\*/", " ", texto, flags=re.S)
    # El (?<!:) importa: sin el, un https:// se come a si mismo y desaparece toda URL del
    # fichero. Un // dentro de una cadena no es un comentario. El primer intento de este
    # verificador suspendio por eso: dijo que el cliente no apuntaba al rele, y el que
    # estaba roto era el verificador.
    texto = re.sub(r"(?<!:)//[^\n]*", " ", texto)
    return texto

def leer():
    return {k: sin_comentarios(io.open(v, encoding="utf-8", newline="").read())
            for k, v in FICHEROS.items()}

fallos = []
hechas = []

def revisar(etiqueta, ok):
    hechas.append(etiqueta)
    print("  %-5s %s" % ("ok" if ok else "FALLO", etiqueta))
    if not ok:
        fallos.append(etiqueta)

def cuerpo(texto, firma, hasta=4000):
    """El trozo de codigo que sigue a una firma de metodo."""
    i = texto.find(firma)
    return texto[i:i + hasta] if i >= 0 else ""

def main():
    F = leer()
    print("\n=============== EL PROVEEDOR ===============")
    revisar('el metodo elegido es "didit"',
            bool(re.search(r'kMetodo\s*=\s*@"didit"', F["fachada"])))
    revisar("la fachada manda enviarA a Didit cuando conDidit",
            "[ConrraVerificacionDidit enviarA:" in F["fachada"])
    revisar("la fachada manda comprobar a Didit cuando conDidit",
            "[ConrraVerificacionDidit comprobar:" in F["fachada"])
    revisar("conDidit hace que las casillas sean 6",
            bool(re.search(r"conDidit\]\s*\|\|\s*\[self conFirebase\]\)\s*\?\s*6", F["fachada"])))
    revisar("el cliente apunta al rele de verificacion",
            "VERIFICACION_HOST" in F["didit"]
            and 'conrraservices.com/verificacion' in F["keys"])
    revisar("el veredicto son ok Y aprobado, no el HTTP",
            bool(re.search(r'verdad:cuerpo\[@"ok"\]\]\s*&&\s*\[self verdad:cuerpo\[@"aprobado"\]\]',
                           F["didit"])))
    revisar("el telefono va escapado (el mas no puede llegar como espacio)",
            "stringByAddingPercentEncodingWithAllowedCharacters" in F["didit"])

    print("\n=============== REGISTRO ===============")
    reg = cuerpo(F["registro"], "-(void)verifyMobileNo{")
    revisar("salta el envio propio si lo verifica el servidor",
            "[ConrraVerificacionTelefono loVerificaElServidor]" in reg)
    revisar("ese corte va ANTES de usar el SMS de pago",
            reg.find("loVerificaElServidor") < reg.find("BASE_URL_OTP")
            and reg.find("BASE_URL_OTP") > 0)
    env = cuerpo(F["registro"], "-(void)sendMeToVerificationView{")
    revisar("pasa el usuario a la pantalla del codigo", "vc.usersigmUpDict" in env)
    revisar("pasa el prefijo del pais", "vc.countryDialCode" in env)

    print("\n=============== RESET DE CONTRASENA ===============")
    res = cuerpo(F["reset"], "-(void)verifyMobileNo{")
    revisar("salta el envio propio si lo verifica el servidor",
            "[ConrraVerificacionTelefono loVerificaElServidor]" in res)
    revisar("ese corte va ANTES de usar el SMS de pago",
            res.find("loVerificaElServidor") < res.find("BASE_URL_OTP")
            and res.find("BASE_URL_OTP") > 0)
    env = cuerpo(F["reset"], "-(void)sendMeToVerificationView{")
    revisar("pasa el usuario a la pantalla del codigo", "vc.usersigmUpDict" in env)
    revisar("pasa el prefijo del pais", "vc.countryDialCode" in env)
    revisar("marca el modo de recuperar contrasena", "vc.isRestPassword=YES" in env)
    revisar("arma el numero con la regla de E.164",
            "[ConrraTelefonoE164 de:" in env)
    revisar("ya no quita el cero a mano", 'hasPrefix:@"0"' not in env)

    print("\n=============== LA PANTALLA QUE COMPARTEN ===============")
    revisar("pide el codigo al abrir, no solo al reenviar",
            bool(re.search(r"loVerificaElServidor\]\s*\n\s*&&\s*!\[self otpApagado\]",
                           F["pantalla"])))
    val = cuerpo(F["pantalla"], "-(void) validateOTP:(NSString *) string{")
    revisar("al validar pregunta por quien verifica, no por el proveedor",
            "[ConrraVerificacionTelefono loVerificaElServidor]" in val
            and "conFirebase" not in val)
    revisar("el numero sale de la clave que de verdad llega (nacionalDe)",
            "[ConrraTelefonoE164 nacionalDe:" in F["pantalla"])
    con = cuerpo(F["pantalla"], "-(void)continuarTrasVerificar {")
    revisar("desenlace de registro", "registerMeWithInfo" in con)
    revisar("desenlace de recuperar contrasena", "updatePasswordScreen" in con)
    revisar("el relleno solo si el codigo lo genero el app",
            bool(re.search(r"if \(!\[ConrraVerificacionTelefono loGeneraElApp\]\)",
                           cuerpo(F["pantalla"], "-(void)setOtp{"))))

    print("\n=============== LA REGLA DE APAGADO ===============")
    revisar("is_test no se lee con boolValue en ningun sitio",
            not any('is_test"]boolValue' in F[k] or 'is_test"] boolValue' in F[k]
                    for k in ("pantalla", "registro", "reset")))
    revisar("otp_off se lee exacto en el modelo",
            bool(re.search(r'isEqualToString:@"1"',
                 sin_comentarios(io.open(A + "/model classes/ConstantModel.m",
                                         encoding="utf-8", newline="").read()))))
    revisar("el simulador ya no apaga el OTP",
            "otp_off = YES" not in sin_comentarios(
                io.open(A + "/model classes/ConstantModel.m",
                        encoding="utf-8", newline="").read()))

    print()
    if fallos:
        print("  SUSPENDE: %d comprobacion(es)" % len(fallos))
        for f in fallos:
            print("    - " + f)
        return 1
    print("  CABLEADO DIDIT: las %d comprobaciones en verde" % len(hechas))
    return 0

if __name__ == "__main__":
    sys.exit(main())
