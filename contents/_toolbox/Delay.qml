import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Item {

  Timer { id: sleeper }

  function exec(time, callback) {
    sleeper.interval = time * 1000; // ms to s
    sleeper.repeat = false;
    sleeper.triggered.connect(callback);
    sleeper.start();
  }
}
