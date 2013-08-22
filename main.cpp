#include <QQuickView>
#include <QQmlEngine>
#include <QGuiApplication>
#include <QDebug>

#ifdef HAS_BOOSTER
#include <MDeclarativeCache>
#endif

#ifdef HAS_BOOSTER
Q_DECL_EXPORT
#endif
int main(int argc, char **argv)
{
    QGuiApplication* application;
    QQuickView* view;
#ifdef HAS_BOOSTER
    application = MDeclarativeCache::qApplication(argc, argv);
    view = MDeclarativeCache::qQuickView();
#else
    qWarning() << Q_FUNC_INFO << "Warning! Running without booster. This may be a bit slower.";
    QGuiApplication stackApp(argc, argv);
    QQuickView stackView;
    application = &stackApp;
    view = &stackView;
#endif

    QObject::connect(view->engine(), SIGNAL(quit()), application, SLOT(quit()));
    view->setSource(QUrl("qrc:/qml/main.qml"));
    view->setResizeMode(QQuickView::SizeRootObjectToView);
    view->showFullScreen();
    return application->exec();
}
