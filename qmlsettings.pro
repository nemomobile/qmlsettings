QT += declarative

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

