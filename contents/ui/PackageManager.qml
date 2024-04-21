import QtQuick
import org.kde.plasma.plasmoid as Plasmoid
import org.kde.plasma.plasma5support as Plasma5Support

Item{
    id: packageManager
    property int stillUpdating: 0
    property string aur: plasmoid.configuration.aurWrapper
    property string startMessage: `--------------------- Arch Update Checker by dhruv8sh ---------------------`;
    property string endMessage  : `------------------------------ Process Ended ------------------------------`
    Plasma5Support.DataSource {
        id: "executable"
        engine: "executable"
        connectedSources: []
        onNewData:function(sourceName, data){
            var exitCode = data["exit code"]
            var exitStatus = data["exit status"]
            var stdout = data["stdout"].replace(/\u001b\[[0-9;]*[m|K]/g, '') //replaces ANSCI characters
            var stderr = data["stderr"]
            exited(sourceName, exitCode, exitStatus, stdout, stderr)
            disconnectSource(sourceName)
        }
        function execInTermH(command) {
            connectSource(`${plasmoid.configuration.terminal} -e bash -c 'trap "" SIGINT; echo ${startMessage}; ${command}; echo ${endMessage}; read -p "Press Any Key to exit..."'`)
        }
        function execInTermA(cmd) {
            if( plasmoid.configuration.terminal ) execInTermH(cmd);
            else connectSource(`${plasmoid.configuration.terminal} -e bash -c 'trap "" SIGINT; echo ${startMessage}; ${command}; echo ${endMessage};'`)
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
            if( plasmoid.configuration.debugCommands ) {
                console.log("source:"+source);
                console.log("stdout:"+stdout);
                console.log("exitCode:"+exitCode);
                console.log("exitStatus:"+exitStatus);
                console.log("stderr:"+stderr);
            }
            // Error handling
            if( stderr.trim() !== "" && stdout.trim() === "" ) {
                if( plasmoid.configuration.useFlatpak
                    && stderr.includes(i18n("flatpak: command not found"))      //for bash
                    || stderr.includes(i18n("Command not found: flatpak"))      //for zsh
                    || stderr.includes(i18n("Unknown command: flatpak"  )) ) {  //for fish
                    plasmoid.configuration.useFlatpak = false;
                    main.wasFlatpakDisabled = true;
                } else if( stderr.includes("Temporary failure in name resolution") ) main.error = i18n("Problem connecting to the internet.");
                else main.error ="Command:"+sourceName+ "\nError code: "+exitCode+ "\n"+(stderr.length>200 ? stderr.substring(0,201)+"..." : stderr );
            }
            //Error handling ends
            else if( sourceName.startsWith(plasmoid.configuration.terminal)) return;
            else if( sourceName.startsWith("pacman -Qi ") || sourceName.startsWith("flatpak info")) { fetchDetails(packagelines, sourceName); return; }
            else if( sourceName === flatpakFetchCommand ) fetchFlatpakUpdateInformation(packagelines)
            else fetchAURUpdateInformation(packagelines, sourceName)
            stillUpdating --;
            isUpdating = stillUpdating > 0;
            if( plasmoid.configuration.debugNormal && !isUpdating ) {
                console.log("Update List count : "+packageModel.count);
                console.log("Verbose mode is work in progress.");
            }
            if( plasmoid.configuration.useNotifications
                && !main.isUpdating
                && main.showNotification
                && plasmoid.configuration.lastCount != packageModel.count
                && packageModel.count != 0 ) {
                main.showNotification = false;
                notif.sendEvent();
                plasmoid.configuration.lastCount = packageModel.count;
            }
        }
    }

    // ---------------------------- UTILIITY BEGIN ------------------------------------------ //
    property var neededInfoFields: [
        "Description",
        "Installed Size",
        "Licences",
        "Replaces",
        "Build Date",
        "Install Reason",
        "Conflicts With",
        "Groups",
        "Optional For",
        "Provides"];
    property var neededInfoFieldsFlatpak: [
        "Id",
        "Ref",
        "Arch",
        "Branch",
        "Origin",
        "Collection",
        "Installation",
        "System",
        "Commit",
        "Date"];
    property string flatpakFetchCommand: `upd=$(flatpak remote-ls --columns=name,application,version --app --updates | \
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
                            `;
    function fillDetailsFor(name, source) {
        if( source === "FLATPAK" ) executable.exec("flatpak info "+name.split(" ").pop());
        else executable.exec("pacman -Qi " + name );
    }
    function fetchDetails( lines, source ) {
        var details = [];
        const isFlatpak = plasmoid.configuration.useFlatpak && source.startsWith("flatpak info ");
        if( isFlatpak ) {
            lines.shift()
            details.push("Description")
            details.push(lines[0].substring(lines[0].indexOf(' - ')+3))
            lines.shift()
            lines.shift()
        }
        lines.forEach(line => {
            const info = line.split(isFlatpak?"  : ":": ")
            const tag = info[0].trim()
            if ((  isFlatpak && neededInfoFieldsFlatpak.includes(tag))
                || ( !isFlatpak && neededInfoFields.includes(tag)) ) {
                details.push(info[0].trim());
                details.push(info[1].trim());
            }
        });
        main.details = details;
    }
    function fetchFlatpakUpdateInformation(lines) {
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
    function fetchAURUpdateInformation(lines, source) {
        lines.forEach(line => {
            if( source === "pikaur -Qua" && line.startsWith(":: aur") )
                line = line.substring(8);
            const info = line.split(/\s+/);
            if( source === "pacaur -Qua" ){
                info.shift();
                info.shift();
            }
            console.log(source.startsWith("checkupdates"));
            if( info[0] && info[0].trim() != "" )
                packageModel.append({
                    PackageName: info[0],
                    FromVersion: info[1],
                    ToVersion: info[3],
                    Source: source.startsWith("checkupdates") ? info[4].toUpperCase() : "AUR"
                });
        });
    }
    function notificationInstall() {
        let notifypath= '~/.local/share/knotifications6/archupdatechecker.notifyrc'
        let notifycontent= `[Global]
IconName=update-none
Comment=Arch Update Checker

[Event/sound]
Name=Sound popup
Comment=Popup and Sound options enabled
Action=Popup|Sound
Sound=message-new-instant.ogg`
        executable.exec("mkdir -p ~/.local/share/knotifications6/")
        executable.exec("echo \'"+notifycontent+"\' > "+notifypath)
    }
    // ---------------------------- UTILIITY END  ------------------------------------------ //

    // ---------------------------- ACTIONS BEGIN ------------------------------------------ //

    // Updates EVERYTHING
    function action_updateSystem() {
        timer.stop();
        packageModel.clear();
        main.wasFlatpakDisabled = false;
        isUpdating = false;
        if( plasmoid.configuration.useCustomInstall ) {
            executable.execInTermH( plasmoid.configuration.customScript )
            return;
        }
        stillUpdating = 0;
        if( plasmoid.configuration.useAUR ) executable.execInTermA( aur+" -Syu "+plasmoid.configuration.aurFlags );
        else executable.execInTermA( "pacman -Syu "+plasmoid.configuration.aurFlags );
        if( plasmoid.configuration.flatpakEnabled )
            executable.execInTermA( "flatpak update "+plasmoid.configuration.flatpakFlags );
        timer.start();
    }
    function action_uninstall(name, source) {
        if( source === "FLATPAK" ) executable.execInTermH("flatpak uninstall "+name.split(" ").pop());
        else executable.execInTermH("sudo pacman -R "+name);
    }
    function action_installOne(name, source) {
        if( plasmoid.configuration.allowSingleModification === 0 ) {
            main.showAllowSingularModifications = true;
            return;
        }
        if( source === "FLATPAK" ) executable.execInTermA("flatpak update "+name.split(" ").pop());
        else if( source === "" ) executable.execInTermA("sudo pacman -S "+name);
        else executable.execInTermA(aur+" -S "+name);
    }
    function action_showInfo(name, source) {
        if( source == "FLATPAK" ) executable.execInTermH("flatpak info "+name.split(" ").pop());
        else executable.execInTermH("pacman -Qii "+name)
    }
    function action_checkForUpdates() {
        if( main.isUpdating || stillUpdating > 0 ) return;
        packageModel.clear()
        main.error = "";
        main.wasFlatpakDisabled = false;
        main.isUpdating = true;
        main.showAllowSingularModifications = false;
        stillUpdating = 3;

        if( plasmoid.configuration.useFlatpak ) executable.exec( flatpakFetchCommand ); else stillUpdating --;
        if( plasmoid.configuration.useAUR     ) executable.exec( aur+" -Qua");          else stillUpdating--;
        if( !plasmoid.configuration.useAUR || (plasmoid.configuration.useAUR && aur !== 'pacaur' && aur !== 'aura') ) executable.exec(`checkupdates | while IFS= read -r line; do
                echo -n "$line"
                pacman -Si $(echo "$line" | awk '{print $1}') | awk 'NR==1' | awk -F':' '{print $2}'
            done
                                    `);        else stillUpdating --;
    }
    function action_clearOrphans() {
        executable.execInTermA("sudo pacman -Rns $(pacman -Qtdq)");
    }
}
