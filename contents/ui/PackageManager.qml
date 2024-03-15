import QtQuick
import org.kde.plasma.plasma5support as Plasma5Support

Item{
    id: packageManager
    property int stillUpdating: 0
    Plasma5Support.DataSource {
        id: "executable"
        engine: "executable"
        connectedSources: []
        onNewData:function(sourceName, data){
            var exitCode = data["exit code"]
            var exitStatus = data["exit status"]
            var stdout = data["stdout"]
            var stderr = data["stderr"]
            exited(sourceName, exitCode, exitStatus, stdout, stderr)
            disconnectSource(sourceName)
        }
        function exec(cmd) {
            connectSource(cmd)
        }
        signal exited(string sourceName, int exitCode, int exitStatus, string stdout, string stderr )
    }
    Connections {
        target: executable
        function onExited(sourceName, exitCode, exitStatus, stdout, stderr){
            var packagelines = stdout.split("\n")
            if( sourceName.startsWith("konsole")) return;
            else if( sourceName.startsWith("upd=$(flatpak") ) fetchFlatpakInformation(packagelines)
            else fetchAURorPACMANInformation(packagelines, sourceName)
            main.isUpdating = packageManager.stillUpdating == 0;
            packageManager.stillUpdating --;
        }
    }
    function removeANSIEscapeCodes(str) {
        return str.replace(/\u001b\[[0-9;]*[m|K]/g, '');
    }
    function fetchFlatpakInformation(lines) {
        lines.forEach(line => {
            var info = line.split(' ');
            if( info.length >= 3 )
            packageModel.append({
                PackageName: info[0],
                FromVersion: info[1],
                ToVersion: info[2],
                Source: "FLATPAK"
            });
        });
    }
    function fetchAURorPACMANInformation(lines, source) {
        lines.forEach(line => {
            line = removeANSIEscapeCodes(line.trim());
            if( line.startsWith(":: aur") ) line = line.substring(8);
            const info = line.split(/\s+/);
            if( info[0].trim() != "" )
            packageModel.append({
                PackageName: info[0],
                FromVersion: info[1],
                ToVersion: info[3],
                Source: source === "checkupdates" ? "" : "AUR"
            });
        });
    }
    function action_updateSystem() {
        timer.stop()
        packageModel.clear()
        isUpdating = false
        stillUpdating = 0
        var command = "konsole -e "+plasmoid.configuration.aurWrapper+" -Syu "+plasmoid.configuration.aurFlags;
        if( plasmoid.configuration.flatpakEnabled )
            command += " && konsole -e flatpak update "+plasmoid.configuration.flatpakFlags;
        executable.exec(command);
        timer.start()
    }
    function uninstall(name, source) {
        if( source === "FLATPAK" ) executable.exec("konsole --hold -e flatpak uninstall "+name);
        else if( source == "SNAP" ) console.log("SNAP support coming soon!");
        else executable.exec("konsole -e sudo pacman -R "+name);
    }
    function showInfo(name, source) {
        if( source == "FLATPAK" ) console.log("THIS IS NOT YET IMPLEMENTED!");
        else if( source == "SNAP" )  console.log("SNAP support coming soon!");
        else if( source == "AUR" ) executable.exec("konsole --hold -e "+plasmoid.configuration.aurWrapper+" -Qi "+name)
        else executable.exec("konsole --hold -e pacman -Qi "+name)
    }
    function action_checkForUpdates() {
        if( main.isUpdating || packageManager.stillUpdating > 0 ) return;
        packageModel.clear()
        main.isUpdating = true
        if( plasmoid.configuration.flatpakEnabled ) {
            packageManager.stillUpdating = 3;
            //copied from exequtic
            executable.exec(`upd=$(flatpak remote-ls --columns=name,application,version --app --updates | \
                            sed 's/ /-/g' | sed 's/\t/ /g')
                            while IFS= read -r app; do
                                    id=$(echo "$app" | awk '{print $2}')
                                    ver=$(flatpak info "$id" | grep "Version:" | awk '{print $2}')
                                    output+="$(echo "$app" | sed "s/$id/$ver/" | tr '[:upper:]' '[:lower:]')"$'\n'
                            done <<< "$upd"
                            echo -en "$output"`);
        }
        else packageManager.stillUpdating = 2;
        executable.exec(plasmoid.configuration.aurWrapper+" -Qua");
        executable.exec("checkupdates");
        console.log("now waiting for updates");
    }
}
