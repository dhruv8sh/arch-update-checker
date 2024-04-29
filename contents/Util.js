
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
function isConnectedToInternet() {
    let ans = true
    packageManager.exec("ping -c 1 google.com > /dev/null",(stdout,stderr,errcode)=>{
        if(stderr != "" || stdout != null)
            createErrorPredefined(0, null)
            ans = false
    })
    return ans

}
function createErrorPredefined(kind, errcode, errinfo) {
    switch(kind) {
        case 0: err = "Internet Connection error!"; break;
        case 1: err = "Problem with pacman!\n"+errinfo;break;
        case 2: err = "Problem with pamac!\n"+errinfo;break;
        case 3: err = "Problem with "+cfg.aurWrapper+"!\n"+errinfo;break;
        case 4: err = "Problem with flatpak!\n"errinfo;break;
    }
}
function getPacmanDescription(name) {
    packageManager.exec("pacman -Qi "+name,(stdout,stderr,errcode)=>{
        if( stdout == "" && stderr != "" ) createErrorPredefined(1,stderr);
        else putAsPackage(fetchGeneric(stdout), getPacmanDescription)
    })
}
function getPamacDescription(name) {
    const cmd = `data=pamac info ${name}
    groups=$(echo $data | grep Groups | awk -F':' '{print $2}')
    echo "$groups"
    echo "$data"`
    let ans = []
    packageManager.exec(cmd,(stdout,stderr,errcode)=>{
        ans[0] = stdout.slice(0, stdout.indexOf("\n"))
        ans[1] = stdout.slice(input.indexOf("\n")+1)
    })
    return ans
}
function getPacaurDescription(name) {
    const cmd = `data=pacaur -Si ${name}
    echo "$groups"
    echo "$data"`
    let ans = ""
    packageManager.exec(cmd,(stdout,stderr,errcode)=>{
        ans = stdout
    })
    return ans
}
function getFlatpakDescription(name) {
    packageManager.exec("flatpak info "+name,(stdout,stderr,errcode)=>{
        if( stdout == "" && stderr != "" ) createErrorPredefined(1,stderr);
        else putAsPackage(fetchGeneric(stdout), getPacmanDescription)
    })
}

function fetchPacaur(data) {
    const lines = data.split('\n');
    let ans = [];

    for( let line in lines ) {
        const info = line.split(/\s+/);
        const extrainfo = fetchDescriptionPacaur(info[1])
        packageModel.append([
            Name  : info[2],
            From  : info[3],
            To    : info[5],
            Source: info[1],
            Groups: info[6],
            Desc  : extrainfo
        ]);
    }
}
function fetchPamac(data) {
    const lines = data.split('\n');
    let ans = [];
    extrainfo = fetchDescriptionPamac(info[1])
    for( let line in lines ) {
        const info = line.split(/\s+/);
        packageModel.append([
            Name  : info[1],
            From  : info[2],
            To    : info[4],
            Source: info[5],
            Groups: extrainfo[0],
            Desc  : extrainfo[1]
        ]);
    }
}
function fetchGeneric( data ) {
    const lines = data.split('\n');
    let ans = [];
    for( let line in lines ) {
        const info = line.split(/\s+/);
        extrainfo = fetchDescriptionAUR(info[1])
        packageModel.append([
            Name  : info[1],
            From  : info[2],
            To    : info[4],
            Source: extrainfo[0],
            Groups: extrainfo[1],
            Desc  : extrainfo[2]
        ]);
    }
}








function putAsPackage(lines, descriptionCallback, source) {
    for( let line in lines ) {
        packageModel.append(
            Name: line[0],
            From: line[1],
            To: line[2],
            Desc: descriptionCallback(line[0]),
            Source: source ? source : fetchSource(line[0])
        )
    }
}
function action_searchForUpdates() {
    searching()
    if( isConnectedToInternet()){
        if( cfg.usePamacInstead ) checkPamac();
        else checkPacman();
        if( cfg.useAUR ) checkAUR();
        if( cfg.useFlatpak ) checkFlatpak();
    }
    stopSearching()

    function checkPacman(){
        packageManager.exec("checkupdates",(stdout,stderr,errcode)=>{
            if( stdout == "" && stderr != "" ) createErrorPredefined(1,stderr);
            else putAsPackage(fetchGeneric(stdout), getPacmanDescription)
        })
    }
    function checkPamac(){
        packageManager.exec("pamac checkupdates",(stdout,stderr,errcode)=>{
            if( stdout == "" && stderr != "" ) createErrorPredefined(2,stderr);
            else putAsPackage(fetchGeneric(stdout), getPamacDescription)
        })
    }
    function checkAUR(){
        packageManager.exec(cfg.aurWrapper + " -Qua",(stdout,stderr,errcode)=>{
            if( stdout == "" && stderr != "" ) createErrorPredefined(3,stderr);
            else putAsPackage(fetchGeneric(stdout), getPacmanDescription, "AUR")
        })
    }
    function checkFlatpak(){
        packageManager.exec("checkupdates",(stdout,stderr,errcode)=>{
            if( stdout == "" && stderr != "" ) createErrorPredefined(4,stderr);
            else putAsPackage(fetchFlatpak(stdout), getFlatpakDescription, "FLATPAK")
        })
    }
}
