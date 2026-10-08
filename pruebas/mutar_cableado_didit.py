# -*- coding: utf-8 -*-
"""
Rompe el cableado a proposito y exige que el verificador SUSPENDA.

Un verificador que nunca ha suspendido no ha demostrado nada: puede estar comprobando
cadenas que siempre estan ahi. Cada mutacion de aqui es un fallo que de verdad ocurrio esta
semana, y para cada una se exige que caiga LA comprobacion que le corresponde -- no una
cualquiera, que seria suspender por el motivo equivocado.

El codigo se restaura con git y al final se comprueba que el arbol quedo limpio.
"""
import io, os, subprocess, sys

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
A = REPO + "/Conrra/InDriver/App Logic"

# (nombre, fichero, lo que se rompe, por lo que se cambia, comprobacion que DEBE caer)
MUTACIONES = [
 ("volver el proveedor a Firebase",
  A + "/Utility/ConrraVerificacionTelefono.m",
  'kMetodo = @"didit"', 'kMetodo = @"firebase"',
  'el metodo elegido es "didit"'),

 ("el registro vuelve a preguntar por el proveedor",
  A + "/OtpProcess/SignUpView/OtpSignUpViewController.m",
  "[ConrraVerificacionTelefono loVerificaElServidor]",
  "[ConrraVerificacionTelefono conFirebase]",
  "salta el envio propio si lo verifica el servidor"),

 ("el reset vuelve a armar el numero a mano",
  A + "/ForgotPasswordView/ForgotPasswordViewController.m",
  "NSString *phoneNum = [ConrraTelefonoE164 de:countryCode nacional:self.txtEmail.text];",
  "NSString *phoneNum = [NSString stringWithFormat:@\"%@%@\", countryCode, self.txtEmail.text];",
  "arma el numero con la regla de E.164"),

 ("la pantalla vuelve a leer la clave del conductor",
  A + "/OtpProcess/Otpverification/OTPVerifyViewController.m",
  "[ConrraTelefonoE164 nacionalDe:_usersigmUpDict]",
  "[_usersigmUpDict objectForKey:P_MOBILE]",
  "el numero sale de la clave que de verdad llega (nacionalDe)"),

 ("el relleno deja de mirar quien genera el codigo",
  A + "/OtpProcess/Otpverification/OTPVerifyViewController.m",
  "if (![ConrraVerificacionTelefono loGeneraElApp]) {",
  "if (NO) {",
  "el relleno solo si el codigo lo genero el app"),

 ("el veredicto se queda solo en ok",
  A + "/Utility/ConrraVerificacionDidit.m",
  'if ([self verdad:cuerpo[@"ok"]] && [self verdad:cuerpo[@"aprobado"]]) {',
  'if ([self verdad:cuerpo[@"ok"]]) {',
  "el veredicto son ok Y aprobado, no el HTTP"),

 ("la puerta deja de mirar el interruptor del servidor",
  A + "/Utility/ConrraNumeroVerificado.m",
  "[ConstantModel getConstantsObject].verificacion_obligatoria",
  "YES",
  "la puerta pregunta por el interruptor"),

 ("confirmar se queda solo en ok",
  A + "/Utility/ConrraVerificacionDidit.m",
  'if ([self verdad:cuerpo[@"ok"]] && [self verdad:cuerpo[@"verificado"]]) {',
  'if ([self verdad:cuerpo[@"ok"]]) {',
  "el veredicto de confirmar son ok Y verificado"),

 ("la puerta apunta DESPUES de confirmar (bucle posible)",
  A + "/OtpProcess/Otpverification/OTPVerifyViewController.m",
  "        [ConrraNumeroVerificado anotarVerificado];",
  "        // apuntado mas tarde",
  "la puerta apunta ANTES de confirmar (no puede quedar en bucle)"),

 ("bloquear aunque no haya numero (dejar sin salida)",
  A + "/Utility/ConrraPuertaVerificacion.m",
  "return numeroE164.length > 0;",
  "return YES;",
  "sin numero NO se bloquea"),

 ("el alta deja de confirmar en el servidor",
  A + "/OtpProcess/Otpverification/OTPVerifyViewController.m",
  "               [self su_confirmarVerificacionDe:",
  "               if (NO) [self su_confirmarNada:",
  "los cuatro desenlaces confirman"),

 ("el reenviar vuelve a preguntar por el proveedor",
  A + "/OtpProcess/Otpverification/OTPVerifyViewController.m",
  "    if ([ConrraVerificacionTelefono loVerificaElServidor] && ![self otpApagado]) {",
  "    if ([ConrraVerificacionTelefono conFirebase] && ![self otpApagado]) {",
  "el reenviar pide al proveedor, no manda el SMS de pago"),

 ("el texto del aviso pierde las tildes",
  A + "/OtpProcess/Otpverification/OTPVerifyViewController.m",
  "@\"Código enviado\"", "@\"Codigo enviado\"",
  "el texto del aviso lleva las tildes"),

 ("deja de avisar de que el codigo salio",
  A + "/OtpProcess/Otpverification/OTPVerifyViewController.m",
  "            [self su_avisarCodigoEnviado];", "            // sin aviso",
  "avisa de que el codigo salio, tras el envio"),
]

def correr_verificador():
    r = subprocess.run([sys.executable, os.path.join(os.path.dirname(os.path.abspath(__file__)),
                                     "verificar_cableado_didit.py")],
                       capture_output=True, text=True)
    return r.returncode, r.stdout

def restaurar():
    subprocess.run(["git", "-C", REPO, "checkout", "--", "."], capture_output=True)

def modificados():
    """Solo lo VERSIONADO y modificado: es lo unico que la restauracion puede devolver.

    Los ficheros sin seguimiento (??) no estorban -- `git checkout -- .` no los toca --, y
    exigir que no haya ninguno hacia imposible correr esto desde una copia con cualquier
    fichero nuevo al lado, incluido este mismo.
    """
    salida = subprocess.run(["git", "-C", REPO, "status", "--porcelain"],
                            capture_output=True, text=True).stdout
    return [l for l in salida.split(chr(10)) if l.strip() and not l.startswith("??")]


def main():
    sucio = modificados()
    assert not sucio, ("hay cambios sin guardar, no se puede mutar con seguridad:"
                       + chr(10) + chr(10).join(sucio))

    codigo, _ = correr_verificador()
    assert codigo == 0, "el verificador ya suspende SIN mutar: arreglalo antes"
    print("Punto de partida: el verificador pasa con el codigo intacto.\n")

    malas = []
    for nombre, fichero, viejo, nuevo, esperada in MUTACIONES:
        t = io.open(fichero, encoding="utf-8", newline="").read()
        if t.count(viejo) < 1:
            malas.append("%s: la mutacion no se pudo aplicar (no encontre el texto)" % nombre)
            print("  ROTA  %-48s la mutacion no encaja" % nombre)
            continue
        io.open(fichero, "w", encoding="utf-8", newline="").write(t.replace(viejo, nuevo, 1))

        codigo, salida = correr_verificador()
        cayo_la_suya = any(l.strip().startswith("FALLO") and esperada in l
                           for l in salida.split("\n"))
        restaurar()

        if codigo != 0 and cayo_la_suya:
            print("  ok    %-48s suspende, y por lo suyo" % nombre)
        elif codigo != 0:
            malas.append("%s: suspende, pero no cayo '%s'" % (nombre, esperada))
            print("  MAL   %-48s suspende por otro motivo" % nombre)
        else:
            malas.append("%s: el verificador NO se entero" % nombre)
            print("  MAL   %-48s el verificador no se entero" % nombre)

    sucio = modificados()
    print()
    if sucio:
        print("  CUIDADO: quedaron cambios sin restaurar:" + chr(10) + chr(10).join(sucio))
        return 1
    print("  El arbol quedo limpio: ninguna mutacion sobrevive al final.")

    if malas:
        print("\n  EL VERIFICADOR NO SIRVE TODAVIA:")
        for m in malas:
            print("    - " + m)
        return 1
    print("  LAS %d MUTACIONES CAZADAS, cada una por su comprobacion." % len(MUTACIONES))
    return 0

if __name__ == "__main__":
    sys.exit(main())
