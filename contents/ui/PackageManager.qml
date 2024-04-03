import QtQuick
import org.kde.plasma.plasma5support as Plasma5Support

Item{
    id: packageManager
    property int stillUpdating: 0
    property string konsoleFlags: plasmoid.configuration.holdKonsole ? "--hold" : ""
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

            // Error handling
            if( stderr.trim() !== "" && stdout.trim() === "" ) {
                if( stderr.includes("flatpak: command not found")   //for bash
                    || stderr.includes("Command not found: flatpak") //for zsh
                    || stderr.includes("Unknown command: flatpak") ) {  //for fish
                    plasmoid.configuration.flatpakEnabled = false;
                    main.wasFlatpakDisabled = true;
                } else if( stderr.includes("Temporary failure in name resolution") ) main.error = i18n("Problem connecting to the internet.");
                else main.error ="Command:"+sourceName+ "\nError code: "+exitCode+ "\n"+(stderr.length>200 ? stderr.substring(0,201)+"..." : stderr );
            }
            //Error handling ends
            else if( sourceName.startsWith(plasmoid.configuration.terminal)) return;
            else if( sourceName.includes(" -Qi ")) { fetchDetails(packagelines); return; }
            else if( sourceName.startsWith("flatpak info")) { fetchDetailsFlatpak(packagelines); return; }
            else if( sourceName.startsWith("upd=$(flatpak") ) fetchFlatpakInformation(packagelines)
            else fetchAURorPACMANInformation(packagelines, sourceName)
            packageManager.stillUpdating --;
            main.isUpdating = packageManager.stillUpdating > 0;
            // if( !main.isUpdating ) {
            //     notification.sendEvent()
            // }
        }
    }
    function removeANSIEscapeCodes(str) {
        return str.replace(/\u001b\[[0-9;]*[m|K]/g, '');
    }

    //Gets package details
    function fetchDetails(lines) {
        var details = [];
        lines.forEach(line => {
            line = removeANSIEscapeCodes(line.trim());
            const info = line.split("  : ");
            if (isNeededInfoField(info[0].trim())) {
                details.push(info[0].trim());
                details.push(info[1].trim());
            }
        });
        main.details = details;
    }
    function fetchDetailsFlatpak(lines) {
        var details = [];
        lines.shift()
        details.push("Description")
        details.push(lines[0].substring(lines[0].indexOf(' - ')+3))
        lines.shift()
        lines.shift()
        lines.forEach(line => {
            line = removeANSIEscapeCodes(line.trim());
            const info = line.split(": ");
            if (isNeededInfoFieldFlatpak(info[0].trim())) {
                details.push(info[0].trim());
                details.push(info[1].trim());
            }
        });
        main.details = details;
    }

    //Gets package updates
    function fetchFlatpakInformation(lines) {
        lines.forEach(line => {
            var info = line.split(' ');
            if( info.length > 3 )
            packageModel.append({
                PackageName: info[0],
                FromVersion: info[3],
                ToVersion: info[2]+"    "+info[1],
                Source: "FLATPAK"
            });
        });
    }
    function fetchAURorPACMANInformation(lines, source) {
        lines.forEach(line => {
            line = removeANSIEscapeCodes(line.trim());
            if( source.startsWith("pikaur -Qua")&& line.startsWith(":: aur") ) line = line.substring(8);
            const info = line.split(/\s+/);
            if( source.startsWith("pacaur -Qua") ){
                info.shift();
                info.shift();
            }
            if( info[0] && info[0].trim() != "" )
            packageModel.append({
                PackageName: info[0],
                FromVersion: info[1],
                ToVersion: info[3],
                Source: source === "checkupdates" ? "" : "AUR"
            });
        });
    }

    //Updates everything
    function action_updateSystem() {
        timer.stop()
        packageModel.clear()
        main.wasFlatpakDisabled = false;
        isUpdating = false
        stillUpdating = 0
        var command = plasmoid.configuration.terminal+" "+konsoleFlags+" -e "+plasmoid.configuration.aurWrapper+" -Syu "+plasmoid.configuration.aurFlags+" && echo -en \"Finished updating.\n\"";
        if( plasmoid.configuration.flatpakEnabled )
            command += " && "+plasmoid.configuration.terminal+" "+konsoleFlags+" -e flatpak update "+plasmoid.configuration.flatpakFlags+" && echo -en \"Finished updating.\n\"";
        executable.exec(command);
        timer.start()
    }

    //Uninstall
    function uninstall(name, source) {
        if( source === "FLATPAK" ) executable.exec(plasmoid.configuration.terminal + " --hold -e flatpak uninstall "+name.split(" ").pop());
        else if( source == "SNAP" ) console.log("SNAP support coming soon!");
        else executable.exec(plasmoid.configuration.terminal + " --hold -e sudo pacman -R "+name);
    }

    //update One package
    function installOnly(name, source) {
        if( plasmoid.configuration.allowSingularModifications === 0 ) {
            main.showAllowSingularModifications = true;
            return;
        }
        if( source === "FLATPAK" ) executable.exec(plasmoid.configuration.terminal+" "+konsoleFlags+" -e flatpak update "+name.split(" ").pop()+" && echo -en \"Finished updating.\n\"");
        else if( source === "SNAP" ) console.log("SNAP support coming soon!");
        else if( source === "AUR" ) executable.exec(plasmoid.configuration.terminal+" "+konsoleFlags+" -e "+plasmoid.configuration.aurWrapper+" -S "+name+" && echo -en \"Finished updating.\n\"")
        else executable.exec(plasmoid.configuration.terminal+" "+konsoleFlags+" -e sudo pacman -S "+name+" && echo -en \"Finished updating.\n\"");
    }
    function showInfo(name, source) {
        if( source == "FLATPAK" ) {
            const id = name.split(" ").pop();
            executable.exec(plasmoid.configuration.terminal + " --hold -e flatpak info "+id);
        } else if( source == "SNAP" )  console.log("SNAP support coming soon!");
        else if( source == "AUR" ) executable.exec(plasmoid.configuration.terminal + " --hold -e "+plasmoid.configuration.aurWrapper+" -Qi "+name)
        else executable.exec(plasmoid.configuration.terminal + " --hold -e pacman -Qi "+name)
    }
    function action_checkForUpdates() {
        if( main.isUpdating || packageManager.stillUpdating > 0 ) return;
        packageModel.clear()
        main.error = "";
        main.wasFlatpakDisabled = false;
        main.isUpdating = true;
        main.showAllowSingularModifications = false;
        if( plasmoid.configuration.flatpakEnabled ) {
            stillUpdating = 3;
            //modified code from exequtic
            executable.exec(`upd=$(flatpak remote-ls --columns=name,application,version --app --updates | \
                            sed 's/ /-/g' | sed 's/\t/ /g')
                            output=""
                            if [ -n "$upd" ]; then
                                while IFS= read -r app; do
                                    id=$(echo "$app" | awk '{print $2}')
                                    ver=$(flatpak info "$id" | grep "Version:" | awk '{print $2}')
                                    output+="$(echo "$app $ver\n")"
                                done <<< "$upd"
                            fi
                            echo -en "$output"
                            `);
        }
        else stillUpdating = 2;
        executable.exec(plasmoid.configuration.aurWrapper+" -Qua");
        if(plasmoid.configuration.aurWrapper!== 'pacaur' && plasmoid.configuration.aurWrapper!== 'aura' ) executable.exec("checkupdates");
        else stillUpdating --;
    }
    function getDetailsFor(name, source) {
        if( source === "" ) executable.exec("pacman -Qi "+name)
        else if( source === "AUR" ) executable.exec(plasmoid.configuration.aurWrapper+" -Qi "+name);
        else if( source === "FLATPAK" ) {
            const id = name.split(" ").pop();
            executable.exec("flatpak info "+id);
        }
        else if( source === "SNAP" ) details = ["Not Supported","yet"];
    }
    function isNeededInfoField( key ) {
        switch( key ) {
            // case "Name":
            case "Description":
            case "Installed Size":
            case "Licences":
            case "Provides":
            case "Replaces":
            case "Build Date":
            case "Install Reason":
            case "Conflicts With":
            case "Groups":
            case "Optional For": return true;
            default: return false;
        }
    }
    function isNeededInfoFieldFlatpak( key ) {
        switch( key ) {
            case "Id":
            case "Ref":
            case "Arch":
            case "Branch":
            case "Origin":
            case "Collection":
            case "Installation":
            case "System":
            case "Commit":
            case "Date": return true;
            default: return false;
        }
    }
}
