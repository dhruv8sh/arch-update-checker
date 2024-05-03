// -------------------------------- UI functions ------------------------------
function searching() {
    timer.stop()
    error = ""
    isUpdating = true
    packageModel.clear()
    wasFlatpakDisabled = false
    showAllowSingleModifications = false
}
function stopSearching() {
    timer.start()
    isUpdating = false
}


// --------------------------------- Util functions ----------------------------
function usePacmanTag(tag) {
    return true;
}
function useFlatpakTag(tag) {
    return true;
}
function execInTerminal( cmd, hold, searchAfter ) {
    const startMessage = `
###############################################################################
############################# Arch Update Checker #############################
########################################################## by dhruv8sh ########`
    const endMessage = `
###############################################################################
#############################    Process Ended    #############################
###############################################################################`
    let termCmd  = cfg.terminal + ` -e bash -c 'trap "" SIGINT; echo "${startMessage}"; ${cmd}; echo "${endMessage}";`
    if( hold ) termCmd += `read -p "Press Any Key to exit...";'`
    else termCmd += `'`
    packageManager.exec(termCmd,(source,stdout,stderr,errcode)=>{
        if( searchAfter ) action_searchForUpdates();
    })
}


function isConnectedToInternet() {
    let ans = true
    packageManager.exec("ping -c 1 google.com > /dev/null",(source,stdout,stderr,errcode)=>{
        if(stderr !== "")
            createErrorPredefined(0, null)
            ans = false
    })
    return ans

}
function createErrorPredefined(kind, errcode, errinfo) {
    switch(kind) {
        case 0: error = "Internet Connection error! Fetching local updates."; break;
        case 1: error = "Problem with pacman!\n"+errinfo;break;
        case 2: error = "Problem with pamac!\n"+errinfo;break;
        case 3: error = "Problem with "+cfg.aurWrapper+"!\n"+errinfo;break;
        case 4: error = "Problem with flatpak!\n"+errinfo;break;
        default: error = "Unknown error\n"+errinfo;break;
    }
}
function getGenericDescription(name, source) {
    let ans = []
    const cmd = `data=${source} -Si ${name}
    repo=echo $data | grep Repository | awk -F ':' {print $2}
    groups=echo $data | grep Groups | awk -F ':' {print $2}
    echo "$repo"
    echo "$groups"
    echo "$data"
    `
    packageManager.exec("pacman -Si "+name,(source,stdout,stderr,errcode)=>{
        ans[0] = stdout.substring(0, stdout.indexOf("\n"))
        stdout = stdout.substring(stdout.indexOf("\n"))
        ans[1] = stdout.substring(0, stdout.indexOf("\n"))
        ans[2] = stdout.substring(stdout.indexOf("\n"))
    })
    return ans
}
function getPamacDescription(name) {
    const cmd = `data=pamac info ${name}
    groups=$(echo $data | grep Groups | awk -F':' '{print $2}')
    echo "$groups"
    echo "$data"`
    let ans = []
    packageManager.exec(cmd,(source,stdout,stderr,errcode)=>{
        ans[0] = stdout.substring(0, stdout.indexOf("\n"))
        ans[1] = stdout.substring(input.indexOf("\n")+1)
    })
    return ans
}
function getPacaurDescription(name) {
    const cmd = `data=pacaur -Si ${name}
    echo "$data"`
    let ans = ""
    packageManager.exec(cmd,(source,stdout,stderr,errcode)=>{
        ans = stdout
    })
    return ans
}
function fetchPacaur( data, source ) {
    const lines = data.split('\n');
    lines.shift();
    for( let index in lines ) {
        if( lines[index].trim().length == 0 ) continue;
        const info = lines[index].split(/\s+/);
        const group = info[6].substring(1,info[6].length-1).split(' ')[0];
        packageManager.exec("pacman -Si "+info[0], (sourceName, stdout, stderr, code)=>{
            let lines = stdout.split('\n');
            let details = []
            let source2 = ""
            let group = ""
            lines.forEach(line => {
                if( line.trim().length > 0 ) {
                    const info = line.split(": ")
                    const tag = info[0].trim()
                    if( usePacmanTag(tag) ) {
                        details.push(tag);
                        details.push(info[1].trim());
                    }
                }
                packageModel.append({
                    "PackageName"  : info[0],
                    "FromVersion"  : info[1],
                    "ToVersion"    : info[3],
                    "Source"       : info[4],
                    "Group"        : group,
                    "Desc"         : details
                });
            });
        });
    }
}
function fetchPamac( data, source ) {
    const lines = data.split('\n');
    for( let index in lines ) {
        if( lines[index].trim().length == 0 ) continue;
        const info = lines[index].split(/\s+/);
        packageModel.append({
            "PackageName"  : info[0],
            "FromVersion"  : info[1],
            "ToVersion"    : info[3],
            "Source"       : info[4],
            "Group"        : group
        });
    }
}
function fetchGeneric( data, source ) {
    const lines = data.split('\n');
    for( let index in lines ) {
        if( lines[index].trim().length == 0 ) continue;
        const info = lines[index].split(/\s+/);
        packageManager.exec("pacman -Si "+info[0],(source,stdout,stderr,errcode)=>{
            let details = []
            let detailLines = stdout.split("\n")
            detailLines.forEach(line=>{
                const data = line.split(": ");

            });
        }
        packageModel.append({
            "PackageName"  : info[0],
            "FromVersion"  : info[1],
            "ToVersion"    : info[3],
            "Source"       : fetch,
            "Group"        : group
        });
    }
}
function fetchDetails(name, source) {
    var details = []
    if( source === "FLATPAK" ) packageManager.exec("pacman -Si "+PackageName, (sourceName, stdout, stderr, code)=>{
        let lines = stdout.split('\n');
        lines.shift()
        details.push("Description")
        details.push(lines[0].substring(lines[0].indexOf(' - ')+3))
        lines.shift()
        lines.shift()
        lines.forEach( line => {
            const info = line.split("  : ")
            const tag = info[0].trim()
            details.push(info[0].trim());
            details.push(info[1].trim());
        });
    });
    else packageManager.exec("pacman -Qi "+PackageName, (sourceName, stdout, stderr, code)=>{
        let lines = stdout.split('\n');
        lines.forEach( line => {
            const info = line.split(": ")
            const tag = info[0].trim()
            details.push(tag);
            details.push(info[1].trim());
        });
    });
    return details;
}
function action_searchForUpdates() {
    searching()
    let doubleUpdate = false;
    if( isConnectedToInternet()){
        doubleUpdate = cfg.useFlatpak;
        console.log("Connected to internet")
        if( cfg.useAUR ) checkAUR();
        else checkPacman();
        if( cfg.useFlatpak ) checkFlatpak();
    }
    //we pre-fetch source list so its faster to fetch packages
    // function fetchSourceList() { packageManager.exec("pacman -Sl | grep installed",(source,stdout,stderr,errcode)=>{ sourceList = stdout } }
    function checkPacman() {
        packageManager.exec("checkupdates",(source,stdout,stderr,errcode)=>{
            if( stdout == "" && stderr != "" ) createErrorPredefined(1,stderr);
            else fetchGeneric(stdout,"pacman")
            if( doubleUpdate ) doubleUpdate = false;
            else stopSearching()
        })
    }
    function checkAUR() {
        if( cfg.aurWrapper === "pamac" ) packageManager.exec("pamac checkupdates",(source,stdout,stderr,errcode) => {
            if( stdout == "" && stderr != "" ) createErrorPredefined(2,stderr);
            else fetchPamac(stdout)
            if( doubleUpdate ) doubleUpdate = false
            else stopSearching()
        })
        else if( cfg.aurWrapper === "pacaur" ) packageManager.exec("pacaur -Qu",(source,stdout,stderr,errcode)=>{
            if( stdout == "" && stderr != "" ) createErrorPredefined(2,stderr);
            else fetchPacaur(stdout)
            if( doubleUpdate ) doubleUpdate = false
            else stopSearching()
        })
        else packageManager.exec(cfg.aurWrapper + " -Qu",(source,stdout,stderr,errcode) => {
            if( stdout == "" && stderr != "" ) createErrorPredefined(3,stderr);
            else fetchGeneric(stdout, cfg.aurWrapper)
            if( doubleUpdate ) doubleUpdate = false
            else stopSearching()
        })
    }
    function checkFlatpak(){
        packageManager.exec("checkupdates",(source,stdout,stderr,errcode) => {
            if( stdout == "" && stderr != "" ) createErrorPredefined(4,stderr);
            else fetchFlatpak(stdout)
            if( doubleUpdate ) doubleUpdate = false
            stopSearching()
        })
    }
}
function action_updateSystem() {
    //change this
    searching()
    let command = ""
    if( cfg.useAUR ) command = cfg.aurWrapper == "pamac" ? "pamac upgrade ": cfg.aurWrapper + " -Syu "
    else command = "sudo pacman -Syu "
    command += cfg.aurFlags+"; "
    if( cfg.useFlatpak ) command += "flatpak update "+cfg.flatpakFlags+""
    execInTerminal(command, cfg.holdTerminal, true)
}
function action_clearOrphans() {
    let command = ""
    if( cfg.useAUR && aurWrapper === "pamac") command = "pamac remove -o";
    else if( cfg.useAUR ) command = `${cfg.aurWrapper} -Rns $(${cfg.aurWrapper} -Qtdq)`;
    else command = "sudo pacman -Rns $(pacman -Qtdq)";
    execInTerminal(command, true, true)
}
function action_installOne(name, source) {
    if( cfg.showAllowSingleModifications == 1 ){
        showAllowSingleModifications = true;
        return;
    }
    let command = ""
    if( source === "FLATPAK" ) command = "flatpak update " + name
    else if( source === "AUR") command = cfg.aurWrapper+" -S " + name
    else                       command = "sudo pacman -S " + name
    execInTerminal(command, true, true)
}
function action_showDetailedInfo(name, source) {
    let command = ""
    if( source === "FLATPAK" ) command = "flatpak info "+name;
    else if( source === "AUR" )command = cfg.aurWrapper+" -Sii "+name
    else command = "pacman -Sii "+name
    execInTerminal(command, true, false)
}
function action_uninstall(source, name) {
    let command = ""
    if( source === "FLATPAK" ) command = "flatpak uninstall "+name;
    else if( source === "AUR" )command = cfg.aurWrapper+" -R "+name
    else command = "pacman -R "+name
    execInTerminal(command, true, false)
}
function action_notificationInstall() {
    let notifypath= '~/.local/share/knotifications6/archupdatechecker.notifyrc'
        let notifycontent= `
[Global]
IconName=update-none
Comment=Arch Update Checker

[Event/sound]
Name=Sound popup
Comment=Popup and Sound options enabled
Action=Popup|Sound
Sound=message-new-instant.ogg`
        packageManager.exec("mkdir -p ~/.local/share/knotifications6/",(source,stdout,stderr,code)=>{})
        packageManager.exec("echo \'"+notifycontent+"\' > "+notifypath,(source,stdout,stderr,code)=>{})
}
