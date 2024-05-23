const validUnits = ["B", "K", "M", "G", "T", "P", "E", "Z", "Y"];
const conversionFactor = {
	"B": 0.0009765625,
	"K": 1,
	"M": 1024,
	"G": 1024 * 1024,
	"T": 1024 * 1024 * 1024,
	"P": 1024 * 1024 * 1024 * 1024,
	"E": 1024 * 1024 * 1024 * 1024 * 1024,
	"Z": 1024 * 1024 * 1024 * 1024 * 1024 * 1024,
	"Y": 1024 * 1024 * 1024 * 1024 * 1024 * 1024 * 1024
};
//function for UI
function searching(message, icon) {
	timer.stop()
	error = ""
	isUpdating = true
	statusMessage = i18n(message)
	statusIcon = icon
	wasFlatpakDisabled = false
	showAllowSingleModifications = false
}
function stopSearch(){
	timer.start()
	isUpdating = false
	statusMessage = packageModel.count === 0 ? "" : packageModel.count + i18n(" updates available")+(downloadSize?" ("+humanize(downloadSize)+")":0)
	statusIcon    = packageModel.count === 0 ? "" : "update-none"
}
function stopSearchWithError(stderror,code,message,icon){
	timer.start();
	isUpdating = false;
	statusMessage = i18n(`${message}; Code:${code}`);
	error = i18n(stderror);
	statusIcon = icon?icon:"data-error";
}
function fetchIcon(PackageName, Source, Group) {
	if( !cfg.useCustomIcons ) return "server-database"
	let tempname = PackageName;
	if(      tempname.startsWith("lib32-") ) tempname = PackageName.substring(6);
	else if( tempname.startsWith("lib"   ) ) tempname = PackageName.substring(3);
	let ans = cfg.customIcons
		.split('\n')
		.map(line => line.split('>').map(word=>word.trim()))
		.filter(line=>line.length === 3)
		.find(([kind,id,_])=>{
			switch (kind) {
      				case "name":  if (id === tempname || (id.endsWith('...') && tempname.startsWith(id.substring(0, id.length - 3)))) return true;
				case "group": if (id === Group.toLowerCase())  return true; break;
      				case "source":if (id === Source.toLowerCase()) return true; break;
    				default: return false;
			}});
	return ans[2] === "~" ? ans[1]:ans[2];
}

//Util functions
function action_searchForUpdates() {
	searching("Checking internet connection","speedometer")
	const flatpakCmd = `flatpak remote-ls --updates --columns=application,download-size | while read -r updateline; do
    		id=$(echo "$updateline" | awk '{print $1}')
    		flatpak info "$id"
    		size=$(echo "$updateline" | awk '{print $2}')
    		echo "Download Size: $size"
			echo "--------------"
	done`;
	packageManager.exec("ping -c 1 google.com > /dev/null",(_,_,stderr,_) => {
		if( stderr === "" ) {
			packageModel.clear();
			downloadSize = 0;
			fetchPacmanUpdates();
		} else stopSearchWithError("Problems connecting to the internet",0,"Internet Error","network-offline");
	});
	function fetchPacmanUpdates() {
		let cmd = cfg.usePamacInstead ? "pamac checkupdates" : "checkupdates --nocolor";
		searching("Checking Arch Repositories...","package");
		packageManager.exec(cmd+" | sort",(_, stdout, stderr, _) => {
			cmd += " | awk '{print $1}' | pacinfo";
			if( stdout === "" && stderr !== "") stopSearchWithError(stderr,1,"Pacman Error","state-error");
			else packageManager.exec(cmd,(_, stdout2, stderr2, _) => {
				if( stdout2 === "" && stderr2 !== "") stopSearchWithError(stderr2,-1,"Pacinfo error");
				let names = stdout.trim().split('\n');
				let details = stdout2.trim().split("\n\n");
				if( details[0].trim().length > 3 && names.length > 3 )
					for( let x = 0; x < names.length; x++ ){
						let namedetails = names[x].split(/\s+/);
						if( details[2*x+1] && namedetails.length > 3 )
							pacmanFetchFromPacinfo(namedetails[0],namedetails[1],namedetails[3],details[2*x+1].split('\n'));
					}
				fetchAURUpdates();
			});
		});
	}
	function fetchAURUpdates() {
		let cmd = ""
		if( cfg.aurWrapper==="trizen"||cfg.aurWrapper==="pikaur") cmd = cfg.aurWrapper+" -Qua --color never | sort";
		else cmd = cfg.aurWrapper+" -Qum --color never | sort ";
		searching("Checking Arch User Repositories...","package");
		if( cfg.useAUR ) packageManager.exec(cmd,(_, stdout, stderr, _) => {
			if( cfg.aurWrapper === "pacaur" ) cmd += " | awk '{print $3}' | pacinfo";
			else cmd += " | awk '{print $1}' | pacinfo";
			if( stdout === "" && stderr !== "") stopSearchWithError(stderr,2,"AUR Error","state-error");
			else packageManager.exec(cmd,(_, stdout2, stderr2, _) => {
				if( stdout2 === "" && stderr2 !== "") stopSearchWithError(stderr2,-1,"Pacinfo error");
				let names = stdout.trim().split('\n');
				let details = stdout2.trim().split("\n\n");
				if( details[0].trim().length != 0 )
					for( let x = 0; x < details.length; x++ )
						aurFetchFromPacinfo(
							names[x].split(/\s+/)[cfg.aurWrapper === "pacaur" ? 5:3],
							details[x].split('\n')
						);
				fetchFlatpakUpdates();
			});
		}); else fetchFlatpakUpdates();
	}
	function fetchFlatpakUpdates() {
		searching("Checking Flatpak for updates...","flatpak-discover");
		if(cfg.useFlatpak) packageManager.exec(flatpakCmd,(_, stdout, stderr, _) => {
			let lines = stdout.split('--------------');
			if( stdout === "" && stderr !== "") stopSearchWithError(stderr,"Flatpak Error",3,"state-error");
			else if( lines[0].trim().length > 0 )
				lines
					.map(line=>line.split('\n'))
					.filter(lines=>lines.length > 3)
					.forEach(flatpakFetchFromInfo);
			stopSearch();
		}); else stopSearch();
	}
	function flatpakFetchFromInfo(infolines) {
		let id, version, ref, size, name, description="", refAlt;
		if( !infolines[0].trim().startsWith("ID") ) {
			infolines.shift();
			infolines.shift();
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
			}).forEach(([tag,value])=>{ switch( tag ) {
					case "ID"      : id      = value; break;
					case "Version" : version = value; break;
					case "Ref"     : ref     = value; refAlt  = value.split('/')[0]; break;
					case "Download Size" : value = value.replace('?',' ');
						size = resolveAddSize(value.replace('?',' '));
					default: description += "\n"+tag+":"+value; break;
				}
			});
		addToModel(name?name:id,
			ref,
			version,
			"FLATPAK ("+refAlt+")",
			undefined,
			description,
			refAlt==="app"?"https://flathub.org/apps/"+id:"https://docs.flatpak.org/en/latest/available-runtimes.html",
			size);
	}
	function aurFetchFromPacinfo(to, infolist) {
		let name, from, description = "", url, licenses="", requires="", optionaldeps="", provides="", size;
		infolist
			.map(line=>line.split(':').map(word=>word.trim()))
			.forEach(([tag,...rest])=>{
				const value = rest.join(':');
				switch( tag ) {
					case "Name": 		name = value; break;
					case "Version": 	from = value; break;
					case "URL": 		url = value; break;
					case "Download Size": 	size = resolveAddSize(value);
					case "Description":
					case "Packager":
					case "Installed Size":
					case "Architecture":	description+= tag+":"+value+"\n"; break;
					case "Licenses": 	licenses += value + " "; break;
					case "Requires": 	requires += value + " "; break;
					case "Optional Deps": 	optionaldeps += value + " "; break;
					case "Provides": 	provides += value + " "; break;
				}});
		addToModel(name,
			from,
			to,
			"AUR",
			undefined,
			description,
			url,
			size);
	}
	function pacmanFetchFromPacinfo(name, from, to, repo) {
		let source, group, description = "", url, licenses="", requires="", optionaldeps="", provides="", size="";
		repo
			.filter(line => line.trim().length > 1)
			.map( line => line.split(':').map(word=>word.trim()))
			.forEach(([tag,...rest])=>{
				const value = rest.join(':');
				switch( tag ) {
					case "Groups": group = value; break;
					case "Repository": source = value; break;
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
				}});
		description += (licenses!==""?"Licenses:"+licenses+'\n':"");
		description += (requires!==""?"Licenses:"+requires+'\n':"");
		description += (provides!==""?"Licenses:"+provides+'\n':"");
		description += (optionaldeps!==""?"Licenses:"+optionaldeps+'\n':"");
		addToModel(name,
			from,
			to,
			source.toUpperCase(),
			group,
			description,
			url,
			size);
	}
}
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
function humanize(kbs) {
	let unit = validUnits.reverse().find(u => kbs > conversionFactor[u]);
	const roundedValue = (kbs / conversionFactor[unit]).toFixed(2);
	return roundedValue+" "+unit;
}
function resolveAddSize(amount) {
	const [value1Str, unit1] = amount.split(' ');
	const value1 = parseFloat(value1Str);
	const kilobytes = value1 * conversionFactor[unit1.charAt(0).toUpperCase()];
	downloadSize += kilobytes;
	return kilobytes;
}
function action_updateSystem() {
	searching("Updating system","akonadiconsole")
	let command = ""
	if( cfg.useCustomInstall ) {
		execInTerminal(cfg.customScript, cfg.holdTerminal, true);
		return;
	}
	if( cfg.useAUR ) command = cfg.aurWrapper == "pamac" ? "pamac upgrade ": cfg.aurWrapper + " -Syu "
	else command = "sudo pacman -Syu "
	command += cfg.aurFlags+"; "
	if( cfg.useFlatpak ) command += "flatpak update "+cfg.flatpakFlags+";"
	execInTerminal(command, cfg.holdTerminal, true)
}
function action_clearOrphans() {
	let command = ""
	if( cfg.useAUR && aurWrapper === "pamac") command = "pamac remove -o";
	else if( cfg.useAUR ) 			  command = `${cfg.aurWrapper} -Rns $(${cfg.aurWrapper} -Qtdq)`;
	else 					  command = "sudo pacman -Rns $(pacman -Qtdq)";
	command += ';'
	execInTerminal(command, true, true)
}
function action_installOne(name, source) {
	console.log( cfg.allowSingleModification );
	if( cfg.allowSingleModification == 1 ){
		showAllowSingleModifications = true;
		return;
	} else if( cfg.allowSingleModification == 0 ){
		return;
	}
	let command = ""
	if( source === "FLATPAK" ) command = "flatpak update " + name
	else if( source === "AUR") command = cfg.aurWrapper+" -S " + name
	else                       command = "sudo pacman -S " + name
	command += ';'
	execInTerminal(command, true, true)
}
function action_showDetailedInfo(name, source) {
	let command = ""
	if( source === "FLATPAK" )  command = "flatpak info "+name;
	else if( source === "AUR" ) command = cfg.aurWrapper+" -Sii "+name
	else 			    command = "pacman -Sii "+name
	command += ';'
	execInTerminal(command, true, false)
}
function action_uninstall(source, name) {
	let command = ""
	if( source === "FLATPAK" ) command = "sudo flatpak uninstall "+name;
	else if( source === "AUR" )command = cfg.aurWrapper+" -R "+name
	else command = "sudo pacman -R "+name
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
	packageManager.exec("mkdir -p ~/.local/share/knotifications6/",(_,_,_,_)=>{})
	packageManager.exec("echo \'"+notifycontent+"\' > "+notifypath,(_,_,_,_)=>{})
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
	let termCmd  = cfg.terminal + ` -e bash -c 'trap "" SIGINT; echo "${startMessage}"; ${cmd} echo "${endMessage}";`
	if( hold ) termCmd += `read -n 1 -p "Press Any Key to exit...";'`
	else termCmd += `'`
	packageManager.exec(termCmd,(_,_,stderr,_)=>{
		console.log("errorlog:"+stderr);
		if( searchAfter ) action_searchForUpdates();
	})
}
