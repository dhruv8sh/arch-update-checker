const validUnits = ["B", "K", "M", "G", "T", "P", "E", "Z", "Y"];
const conversionFactor = {
    "B": 0.00000095367431640625,
    "K": 0.0009765625,
    "M": 1,
    "G": 1024,
    "T": 1024 * 1024,
    "P": 1024 * 1024 * 1024,
    "E": 1024 * 1024 * 1024 * 1024,
    "Z": 1024 * 1024 * 1024 * 1024 * 1024,
    "Y": 1024 * 1024 * 1024 * 1024 * 1024 * 1024
};
//UI
function startSearch(message, icon, busy) {
    if(busy==undefined || busy==true) timer.stop()
    error = ""
    isBusy = busy?busy:true
    statusMessage = i18n(message)
    statusIcon = icon
    showAllowSingleModifications = false
    missingDependency = false
}
function stopSearch(){
    if(isBusy) timer.start()
    isBusy = false
    if(packageModel.count>0){
        statusMessage=packageModel.count+i18n(' updates available')+(downloadSize?' ('+humanize(downloadSize)+')':'')
        statusIcon="update-none"
    } else {
        statusMessage=''
        statusIcon=''
    }
}
function endAll(){
    stopSearch()
    packageManager.endAll()
}
function errorRaised(err,message,icon){
    timer.start();
    packageManager.endAll()
    isBusy = false;
    statusMessage = i18n(message);
    error = i18n(err);
    statusIcon = icon?icon:"data-error";
}
function fetchIcon(name, Source, Group) {
    if(!cfg.useCustomIcons) return "server-database"
    let tempname = name;
    if(      tempname.startsWith("lib32-") ) tempname = name.substring(6);
    else if( tempname.startsWith("lib"   ) ) tempname = name.substring(3);
    else if( tempname.startsWith("lib32-lib") ) tempname = name.substring(8);
    let ans = cfg.customIcons
    .split('\n')
    .map(line => line.split('>').map(word=>word.trim()))
    .filter(line=>line.length === 3)
    .find(([kind,id,_])=>{
        switch (kind) {
            case "name":  if (id === tempname || (id.endsWith('...') && tempname.startsWith(id.substring(0, id.length - 3)))) return true;
            case "group": if (id === Group.toLowerCase())  return true; break;
            case "source":if (id === Source.toLowerCase()) return true;
                else if(id === "flatpak" && Source.startsWith("FLATPAK") ) break;
            default: return false;
        }});
    return ans[2]==='~'?ans[1]:ans[2];
}


//Util functions
function addToModel(...details) {
    packageModel.append({
        "PackageName": details[0],
        "FromVersion": details[1],
        "ToVersion"  : details[2]?details[2]:"latest commit",
        "Source"     : details[3],
        "Group"      : details[4]?details[4]:"None",
        "Desc"       : details[5],
        "URL"        : details[6],
        "Size"       : details[7]?details[7]:0
    });
}
function humanize(mbs) {
    let unit = 'K';
    for( let vu of validUnits )
    if( conversionFactor[vu] < mbs ) unit = vu;
    else break;
    const roundedValue = (mbs / conversionFactor[unit]).toFixed(2);
    if( unit !== 'B' ) unit += 'iB';
    return roundedValue+" "+unit;
}
function resolveAddSize(amount) {
    const [value1Str, unit1] = amount.split(' ');
    const value1 = parseFloat(value1Str);
    const megabytes = value1 * conversionFactor[unit1.charAt(0).toUpperCase()];
    downloadSize += megabytes;
    return megabytes;
}
function notificationInstall() {
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
    packageManager.exec("mkdir -p ~/.local/share/knotifications6/",(_,_,_,_)=>{})
    packageManager.exec("echo \'"+notifycontent+"\' > "+notifypath,(_,_,_,_)=>{})
}
function checkDependency(name) {
    packageManager.exec(name+" --version > /dev/null",(_, stdout, stderr, _) => {
        missingDependency = missingDependency || stdout !== ""  ||  stderr !== ""
        if( missingDependency ) {
            error = i18n("Dependencies Missing")
            statusIcon = "dependency"
            statusMessage = i18n("Missing dependencies for pacman")
        }
    });
}
//Commands
const startMessage = `
###############################################################################
############################# Arch Update Checker #############################
########################################################## by dhruv8sh ########`
const endMessage = `
###############################################################################
#############################    Process Ended    #############################
###############################################################################`
class Command {
    constructor(cmd,err,txt,icn,showsBusy,runsInTerm,callback){
        this.cmd = cmd
        this.err = err
        this.txt = txt
        this.icn = icn
        this.runsInTerm = runsInTerm
        this.showsBusy = showsBusy
        this.callback = callback
    }
    execInTerminal(newCmd) {
        let termCmd=cfg.terminal + ` bash -c 'trap "" SIGINT;
            echo "${startMessage}";
            ${newCmd}
            echo "${endMessage}";
            read -n 1 -p "Press Any Key to exit...";'`
        packageManager.exec(termCmd,(_,_2,stderr,_3)=>{
            stopSearch()
            if(cfg.debugCommands) console.log("Command: "+newCmd+"\nOutput:"+stdout+"\nstderr:"+stderr)
        })
    }
    exec(newCmd){
        packageManager.exec(newCmd,(_,stdout,stderr,_2)=>{
            this.callback(stdout)
            if(stderr!==""&&stdout.trim()==="") errorRaised(stderr,this.err)
            if(cfg.debugCommands) console.log("Command: "+newCmd+"\nOutput:"+stdout+"\nstderr:"+stderr)
        })
    }
    run(name){
        startSearch(this.txt,this.icn, this.showsBusy)
        let newCmd = this.cmd.replace(/{\$aur}/g,cfg.aurWrapper)
        .replace("{}",name);
        if(cfg.debugCommands) console.log("running "+newCmd)
        if(this.runsInTerm) this.execInTerminal(newCmd)
        else this.exec(newCmd)
    }
}
let commands = {
    checkUpdates:new Command("ping -c 1 google.com > /dev/null",
        "No internet Connection","Checking Internet Connection",
        "speedometer",true,false,internetAvailable),
    getPacman:new Command("checkupdates --nocolor|sort; echo \"--------\"; checkupdates --nocolor|sort|awk '{print $1}'|pacinfo",
        "checkupdates/pacinfo command error", "Checking Arch Repositories...",
        "package",true,false,gotPacman),
    getAUR:new Command("{$aur} -Qum|sort; echo \"--------\"; {$aur} -Qum|sort|awk '{print $1}'|pacinfo",
        "AUR Wrapper error","Checking Arch User Repositories...",
        "package",true,false,gotAUR),
    getAURAlt1:new Command("{$aur} -Qua|sort; echo \"--------\"; {$aur} -Qua|sort|awk '{print $1}'|pacinfo",
        "AUR Wrapper error","Checking Arch User Repositories...",
        "package",true,false,gotAUR),
    getAURAlt2:new Command("pacaur -Qum --color never|sort|cut -c 9-; echo \"--------\";pacaur -Qum --color never|sort|awk '{print $3}'|pacinfo",
        "AUR Wrapper error","Checking Arch User Repositories...",
        "package",true,false,gotAUR),
    getFlatpak:new Command(`flatpak remote-ls --updates --columns=application,download-size | while read -r updateline; do
id=$(echo "$updateline" | awk '{print $1}')
flatpak info "$id"
size=$(echo "$updateline" | awk '{print $2}')
echo "Download Size: $size"
echo "--------------"
done`,
        "flatpak-remote error","Checking Flatpak Remote...",
        "flatpak-discover",true,false,gotFlatpak),
    showPacmanInfo:new Command("pacman -Sii {}",
        "Terminal error","Watching package information",
        "data-information",false,true),
    showAURInfo:new Command("{$aur} -Sii {}",
        "Terminal/AUR Error","Watching package information",
        "data-information",false,true),
    showFlatpakInfo:new Command("flatpak info {}",
        "Terminal/Flatpak Error","Watching flatpak package information",
        "data-information",false,true),
    installPacman:new Command("sudo pacman -S {}",
        "Pacman error","Installing one package",
        "akonadiconsole",true,true),
    installAUR:new Command("{$aur} -S {}",
        "AUR error","Installing a package",
        "akonadiconsole",true,true),
    installFlatpak:new Command("flatpak update {}",
        "Flatpak error","Installing a package",
        "akonadiconsole",true,true),
    uninstallFlatpak:new Command("flatpak remove {}",
        "Flatpak error","Uninstalling a package",
        "akonadiconsole",true,true),
    uninstallPacman:new Command("sudo pacman -R {}",
        "Pacman error","Uninstalling one package",
        "akonadiconsole",true,true),
    uninstallAUR:new Command("sudo {$aur} -S {}",
        "AUR error","Installing a package",
        "akonadiconsole",true,true),
    cleanupPacman:new Command("sudo pacman -Rns \$(pacman -Qtdq)",
        "Pacman Error","Cleaning up orphans",
        "edit-clear-all",true,true)
}
function internetAvailable(){
    packageModel.clear()
    commands["getPacman"].run()
}
function gotPacman(output){
    let [versions,...rest] = output.split("--------")
    let details = rest.join("--------").trim().split('\n\n')
    versions = versions.trim().split('\n')
    let i = 0;
    versions.forEach(version=>{
        let vername = details[i].slice(16,details[i].indexOf('\n'))
        parsePacinfo(version, details[i+1])
        i+=2
        while(i<details.length) {
            let name = details[i].slice(16,details[i].indexOf('\n'))
            if( name === vername ) i ++
            else break
        }
    });

    if(cfg.useAUR) {
        if(cfg.aurWrapper==="trizen"||cfg.aurWrapper==="pikaur") commands["getAURAlt1"].run()
        else if(cfg.aurWrapper==="pacaur") commands["getAURAlt2"].run()
        else commands["getAUR"].run()
    } else if(cfg.useFlatpak) commands["getFlatpak"].run()
    else {
        stopSearch()
        notifBuild()
    }
}
function gotAUR(output){
    let [versions,...rest] = output.split("--------")
    let details = rest.join("--------").trim().split('\n\n')
    versions = versions.trim().split('\n')
    for(let i=0; i<versions.length; i++)
        parsePacinfo(versions[i].trim(),details[i],"AUR")
    if(cfg.useFlatpak) commands["getFlatpak"].run()
    else {
        stopSearch()
        notifBuild()
    }
}
function gotFlatpak(output){
    let lines = output.split('--------------');
    if( lines[0].trim().length > 0 )
    lines
        .map(line=>line.split('\n'))
        .filter(lines=>lines.length > 3)
        .forEach(parseFlatpakInfo);
    stopSearch()
    notifBuild()
}
function parsePacinfo(ver,deets,source){
    let [name, prev_ver, arrow, next_ver] = ver.split(/\s+/)
    let group, description = "", url="none", licenses="", requires="", optionaldeps="", provides="", size="";
    if(!deets) return
    deets.split('\n')
        .filter(line => line.trim().length > 1)
        .map( line => line.split(':').map(word=>word.trim()))
        .forEach(([tag,...rest])=>{
            const value = rest.join(':');
            switch( tag ) {
                case "Groups": group = value; break;
                case "Repository": source = source?source:value; break;
                case "URL": url = value; break;
                case "Download Size": size = resolveAddSize(value);
                case "Description":
                case "Packager":
                case "Installed Size":
                case "Architecture":description+= tag+":"+value+"\n"; break;
                case "Licenses": licenses += value + " "; break;
                case "Requires": requires += value + " "; break;
                case "Optional Deps": optionaldeps += value + " "; break;
                case "Provides": provides += value + " "; break;
            }
        })
    description += (licenses!==""?"Licenses:"+licenses+'\n':"");
    description += (requires!==""?"Requires:"+requires+'\n':"");
    description += (provides!==""?"Provide:"+provides+'\n':"");
    description += (optionaldeps!==""?"Optional Deps:"+optionaldeps+'\n':"");
    addToModel(name,prev_ver,next_ver,source.toUpperCase(),group,description,url,size);
}
function parseFlatpakInfo(infolines){
    let id, version, ref, size='0 kb', name, description="", refAlt;
    if(!infolines[0].trim().startsWith("ID")){
        infolines.shift()
        infolines.shift()
        const [namePart, ...descPart] = infolines.shift().trim().split('-');
        name = namePart.trim();
        description = "Description:"+(descPart.join('-').trim());
        infolines.shift();
    }
    infolines
        .filter(line=>line.trim().length>0)
        .map(line=>{
            const [rawTag, ...rest] = line.split(': ');
            return [rawTag.trim(), rest.join(': ').trim()];
        }).forEach(([tag,value])=>{
            switch( tag ) {
                case "ID"      : id      = value; break;
                case "Version" : version = value; break;
                case "Ref"     : ref     = value; refAlt  = value.split('/')[0]; break;
                case "Download Size" : size = resolveAddSize(value.replace('\xa0',' ').replace('?',' '));
                default: description += "\n"+tag+":"+value; break;
            }
        });
    addToModel(name?name:ref,id,version,"FLATPAK ("+refAlt+")",undefined,
        description,
        refAlt==="app"?"https://flathub.org/apps/"+id:"https://docs.flatpak.org/en/latest/available-runtimes.html",size);
}
function updateSystem() {
    let command = ""
    if( cfg.useCustomInstall ) command = cfg.customScript
    else if( cfg.useAUR ) command = cfg.aurWrapper + " -Syu "
    else command = "sudo pacman -Syu "
    command += cfg.aurFlags
    if( cfg.useFlatpak ) command += "; flatpak update "+cfg.flatpakFlags
    command += ';'
    new Command(command,
        "Error updating packages","Updating System",
        "akonadiconsole",true,true).run()
}
function notifBuild() {
    let arr=[]
    for(let i=0; i<packageModel.count; i++){
        let pkg = packageModel.get(i)
        arr.push({
            "Name":pkg["PackageName"],
            "Ver":pkg["ToVersion"],
            "Source":pkg["Source"]
        })
    }
    let prev_list = cfg.lastList.split('\n')
    let list = prev_list===""?[]:arr.map(ob=>ob.Name+" > "+ob.Ver)
    let diff = list.filter(line=>!prev_list.includes(line))
    if(diff.length>0 && showNotification){
        notifText = diff.join('\n')
        notifDiff = diff.length
        notif.sendEvent()
    }
    cfg.lastList = list.join('\n')
    showNotification = false
}
