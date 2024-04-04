import QtQuick
import org.kde.plasma.plasmoid as Plasmoid
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
            stdout = stdout.replace(/\u001b\[[0-9;]*[m|K]/g, '');   // Replace ANSI characters with ASCII
            var packagelines = stdout.split("\n")

            // Error handling
            if( stderr.trim() !== "" && stdout.trim() === "" ) {
                if( plasmoid.configuration.flatpakEnabled
                    && stderr.includes(   i18n("flatpak: command not found"))   //for bash
                    || stderr.includes(i18n("Command not found: flatpak")) //for zsh
                    || stderr.includes(i18n("Unknown command: flatpak"  )) ) {  //for fish
                    plasmoid.configuration.flatpakEnabled = false;
                    main.wasFlatpakDisabled = true;
                } else if( stderr.includes("Temporary failure in name resolution") ) main.error = i18n("Problem connecting to the internet.");
                else main.error ="Command:"+sourceName+ "\nError code: "+exitCode+ "\n"+(stderr.length>200 ? stderr.substring(0,201)+"..." : stderr );
            }
            //Error handling ends
            else if( sourceName.startsWith(term)) return;
            else if( sourceName.startsWith("pacman -Qi ") || sourceName.startsWith("flatpak info")) { fetchDetails(packagelines, sourceName); return; }
            else if( sourceName === flatpakFetchCommand ) fetchFlatpakUpdateInformation(packagelines)
            else fetchAURUpdateInformation(packagelines, sourceName)
            stillUpdating --;
            main.isUpdating = stillUpdating > 0;
            if( !main.isUpdating && main.showNotification && plasmoid.configuration.lastCount != packageModel.count ) {
                main.showNotification = false;
                notif.sendEvent()
            }
        }
    }

    // ---------------------------- UTILIITY BEGIN ------------------------------------------ //

    readonly property string aur: plasmoid.configuration.aurWrapper;
    readonly property string term: plasmoid.configuration.terminal;
    readonly property string hold: plasmoid.configuration.holdKonsole ? " --hold -e ":" -e ";

    // These fields will shown in detailsText view ( Maximum 10, or it overflows )
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
    // These fields will shown in detailsText view for flatpaks ( Maximum 10, or it overflows )
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
    /*
    * Shell command to fetch flatpak update information with their version
    * Format: TODO
    * Inspiration from exequtic
    */
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
    /*
    * Shell command to fetch update information for AUR ONLY
    * Format: TODO
    */
    property string aurFetchCommand: aur+" -Qua"

    /*
    * Shell command to fetch update information from PACMAN ONLY
    * Format: TODO
    */
    property string pacmanFetchCommand: "checkupdates"

    // Shell Command to UPDATE AUR and PACMAN
    property string updateAURCommand: term+hold+aur+" -Syu "+plasmoid.configuration.aurFlags;
    // Shell Command to FLATPAKS
    property string updateFLATPAKCommand: term+hold+"flatpak update "+plasmoid.configuration.flatpakFlags;
    // Shell Command to show AUR/PACMAN package info
    property string showAURInfoCommand: term+" --hold -e pacman -Qi ";
    // Shell Command to show Flatpak package info
    property string showFLATPAKInfoCommand: term+" --hold -e flatpak info ";

    // Util function to fill details about a package
    function fillDetailsFor(name, source) {
        if( source === "FLATPAK" ) executable.exec("flatpak info"+name.split(" ").pop());
        // else if( source === "SNAP" ) details = ["Not Supported","yet"];
        else executable.exec( "pacman -Qi " + name );
    }
    // Puts package info into main.details
    function fetchDetails( lines, source ) {
        var details = [];
        const isFlatpak = plasmoid.configuration.flatpakEnabled && source.startsWith("flatpak info ");
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
    // Puts FLATPAK package updates into packageModel
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
    // Puts AUR/PACMAN package updates into packageModel
    function fetchAURUpdateInformation(lines, source) {
        lines.forEach(line => {
            if( source === "pikaur -Qua" && line.startsWith(":: aur") )
                line = line.substring(8);
            const info = line.split(/\s+/);
            if( source === "pacaur -Qua" ){
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
    // ---------------------------- UTILIITY END  ------------------------------------------ //

    // ---------------------------- ACTIONS BEGIN ------------------------------------------ //

    // Updates EVERYTHING
    function action_updateSystem() {
        timer.stop();
        packageModel.clear();
        main.wasFlatpakDisabled = false;
        isUpdating = false;
        stillUpdating = 0;
        executable.exec( updateAURCommand );
        if( plasmoid.configuration.flatpakEnabled )
            executable.exec( updateFLATPAKCommand );
        timer.start();
    }
    // UNINSTALL a package
    function action_uninstall(name, source) {
        if( source === "FLATPAK" ) executable.exec(term + " --hold -e flatpak uninstall "+name.split(" ").pop());
        // else if( source == "SNAP" ) console.log("SNAP support coming soon!");
        else executable.exec(term + " --hold -e sudo pacman -R "+name);
    }
    // Updates ONE PACKAGE
    function action_installOne(name, source) {
        if( plasmoid.configuration.allowSingularModifications === 0 ) {
            main.showAllowSingularModifications = true;
            return;
        }
        if( source === "FLATPAK" ) executable.exec(term+hold+"flatpak update "+name.split(" ").pop());
        // else if( source === "SNAP" ) console.log("SNAP support coming soon!");
        else executable.exec(term+hold+aur+" -S "+name);
    }
    //Show details in a terminal window
    function action_showInfo(name, source) {
        if( source == "FLATPAK" ) executable.exec(showFLATPAKInfoCommand+name.split(" ").pop());
        // else if( source == "SNAP" )  console.log("SNAP support coming soon!");
        else executable.exec(showAURInfoCommand+name)
    }
    function action_checkForUpdates() {
        if( main.isUpdating || stillUpdating > 0 ) return;
        packageModel.clear()
        main.error = "";
        main.wasFlatpakDisabled = false;
        main.isUpdating = true;
        main.showAllowSingularModifications = false;
        stillUpdating = 3;

        if( plasmoid.configuration.flatpakEnabled ) executable.exec( flatpakFetchCommand );
        else stillUpdating --;

        executable.exec(aurFetchCommand);

        if(aur !== 'pacaur' && aur !== 'aura' ) executable.exec(pacmanFetchCommand);
        else stillUpdating --;
    }
}
