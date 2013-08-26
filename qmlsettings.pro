QT += qml quick

TEMPLATE = app

# Input
SOURCES += main.cpp

RESOURCES += \
    res.qrc

target.path = /usr/bin
INSTALLS += target

desktop.path = /usr/share/applications
desktop.files = qmlsettings.desktop
INSTALLS += desktop

provider_ui.files = accounts/providers/*.qml
provider_ui.path = /usr/share/accounts/ui/
INSTALLS += provider_ui

providers.files = accounts/providers/*.provider
providers.path = /usr/share/accounts/providers
INSTALLS += providers

services.files = accounts/providers/*.service
services.path = /usr/share/accounts/services
INSTALLS += services

CONFIG += link_pkgconfig

packagesExist(qdeclarative5-boostable) {
    message("Building with qdeclarative5-boostable support")
    DEFINES += HAS_BOOSTER
    PKGCONFIG += qdeclarative5-boostable
} else {
    warning("qdeclarative5-boostable not available; startup times will be slower")
}
