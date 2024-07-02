
import QtQuick
import org.kde.plasma.plasma5support as Plasma5Support

Plasma5Support.DataSource {
    id: executable
    engine: "executable"
    connectedSources: []
    onNewData: (sourceName, data) => {
        var cmd = sourceName
        var out = data["stdout"].replace(/\u001b\[[0-9;]*[m|K]/g, '')
        var err = data["stderr"]
        var code = data["exit code"]
        var listener = listeners[cmd]

        if (listener) listener(cmd, out, err, code)

        exited(cmd, out, err, code)
        disconnectSource(sourceName)
    }

    signal exited(string cmd, string out, string err, int code)

    property var listeners: ({})

    function exec(cmd, callback) {
        listeners[cmd] = execCallback.bind(executable, callback)
	if(cfg.debugCommands)console.log("running command:"+cmd)
        connectSource(cmd)
    }
    function endAll(){
        for( var proc in listeners ){
            delete listeners[proc]
            disconnectSource(proc)
        }
    }
    function execCallback(callback, cmd, out, err, code) {
        delete listeners[cmd]
        if (callback) callback(cmd, out, err, code)
    }
}
