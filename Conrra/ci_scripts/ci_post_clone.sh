#!/bin/sh
#
# ci_post_clone.sh
#
# Xcode Cloud clona el repositorio y se pone a compilar: no ejecuta pod install por su
# cuenta. Y Pods/ no esta versionado a proposito -- son unos 200 MB que se reconstruyen
# con un comando, y meterlos en git ensucia cada diff.
#
# Sin este script la compilacion muere a los 0,1 segundos buscando
# Pods-Conrra.release.xcconfig, que es un fichero que genera pod install.
#
# Xcode Cloud busca la carpeta ci_scripts junto al proyecto o al workspace, por eso vive
# en Conrra/ y no en la raiz del repositorio.

set -e

# La imagen de Xcode Cloud no trae CocoaPods preinstalado.
export HOMEBREW_NO_AUTO_UPDATE=1
brew install cocoapods

# El workspace esta en Conrra/, un nivel por debajo de la raiz del repositorio.
cd "$CI_PRIMARY_REPOSITORY_PATH/Conrra"

# --repo-update NO: el Podfile fija versiones exactas y existe Podfile.lock. Actualizar el
# indice de specs alargaria cada compilacion varios minutos sin cambiar el resultado.
pod install

echo "ci_post_clone: pod install terminado"
