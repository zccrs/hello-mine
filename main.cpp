#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQuickStyle>
#include <QQmlContext>

class GameApplication : public QGuiApplication
{
    Q_OBJECT

public:
    GameApplication(int &argc, char **argv)
        : QGuiApplication(argc, argv) {

    }

    Q_INVOKABLE Qt::KeyboardModifiers keyboardModifiers() const {
        return QGuiApplication::keyboardModifiers();
    }
    Q_INVOKABLE Qt::KeyboardModifiers queryKeyboardModifiers() const {
        return QGuiApplication::queryKeyboardModifiers();
    }
    Q_INVOKABLE Qt::MouseButtons mouseButtons() const {
        return QGuiApplication::mouseButtons();
    }
};

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QQuickStyle::setStyle("Material");
    GameApplication app(argc, argv);

    QQmlApplicationEngine engine;
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;

    engine.rootContext()->setContextProperty("gameApplication", &app);

    return app.exec();
}

#include "main.moc"
