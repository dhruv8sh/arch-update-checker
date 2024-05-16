//function for UI
function searching(message, icon) {
	timer.stop()
	error = ""
	isUpdating = true
	statusMessage = message
	statusIcon = icon
	wasFlatpakDisabled = false
	showAllowSingleModifications = false
}
function stopSearch(){
	timer.start()
	isUpdating = false
	if( packageModel.count == 0 ) {
		statusMessage = ""
		statusIcon    = ""
	} else {
		statusMessage = packageModel.count + i18n(" updates available")
		statusIcon    = "update-none"
	}
}
function fetchIcon(PackageName, Source, Group) {
	if( !plasmoid.configuration.useCustomIcons ) return "server-database"
	let ans = "";
	let tempname = PackageName;
	if( tempname.startsWith("lib32-") ) tempname = PackageName.substring(6);
	else if( tempname.startsWith("lib") ) tempname = PackageName.substring(3);
	let lines = plasmoid.configuration.customIcons.split('\n');
	for (let line of lines) {
		let info = line.split('>');
		if (info.length < 3) continue; // Use continue instead of return
		let type = info[0].trim();
		let name = info[1].trim();
		let tempans = info[2].trim();
		if (type === "name" && (name === tempname || (name.endsWith('...') && tempname.startsWith(name.substring(0, name.length - 3))))) {
			ans = tempans;
			break;
		} else if (type === "source" && name === Source.toLowerCase()) {
			ans = tempans;
			break;
		} else if (type === "group" && name === Group.toLowerCase()) {
			ans = tempans === "~" ? tempname : tempans;
			break;
		}
	}
	return ans;
}

//Util functions
function action_searchForUpdates() {
	searching("Checking internet connection","speedometer")
	const flatpakCmd = `flatpak remote-ls --updates | awk '{print $2}' | while read -r appref; do flatpak info "$appref"; echo "--------------"; done`;
	packageManager.exec("ping -c 1 google.com > /dev/null",(_source, _stdout, stderr, _errcode) => {
		if( stderr === "" ) {
			packageModel.clear();
			fetchPacmanUpdates();
		}
		else {
			stopSearch();
			error = "Problems connecting to the internet";
		}
	});
	function fetchPacmanUpdates() {
		let cmd = cfg.usePamacInstead ? "pamac checkupdates" : "checkupdates --nocolor";
		searching("Checking Arch Repositories...","package");
		packageManager.exec(cmd+" | sort",(_source, stdout, _stderr, _errcode) => {
			cmd += " | awk '{print $1}' | pacinfo";
			packageManager.exec(cmd,(_source2, stdout2, _stderr2, _errcode2) => {
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
		else cmd = cfg.aurWrapper+" -Qum --color never | sort "
		searching("Checking Arch User Repositories...","package");
		if( cfg.useAUR ) packageManager.exec(cmd,(_source, stdout, _stderr, _errcode) => {
			if( cfg.aurWrapper === "pacaur" ) cmd += " | awk '{print $3}' | pacinfo";
			else cmd += " | awk '{print $1}' | pacinfo";
			packageManager.exec(cmd,(_source2, stdout2, _stderr2, _errcode2) => {
				let names = stdout.trim().split('\n');
				let details = stdout2.trim().split("\n\n");
				if( details[0].trim().length != 0 )
				for( let x = 0; x < details.length; x++ ){
					if( cfg.aurWrapper === "pacaur" ) aurFetchFromPacinfo(names[x].split(/\s+/)[5],details[x].split('\n'));
					else aurFetchFromPacinfo(names[x].split(/\s+/)[3],details[x].split('\n'));
				}
				fetchFlatpakUpdates();
			});
		}); else fetchFlatpakUpdates();
	}
	function fetchFlatpakUpdates() {
		searching("Checking Flatpak for updates...","flatpak-discover");
		if(cfg.useFlatpak) packageManager.exec(flatpakCmd,(_source, stdout, _stderr, _errcode) => {
			let lines = stdout.split('--------------');
			if( lines[0].trim().length != 0 )
			lines.forEach(flatpakFetchFromInfo);
			stopSearch();
		}); else stopSearch();
	}
	function flatpakFetchFromInfo(infolines) {
		if( infolines.trim().length === 0 ) return;
		infolines = infolines.split('\n');
		infolines.shift();
		let name = infolines[0].substring(0,infolines[0].indexOf('-')).trim();
		let desc = infolines[0].substring(infolines[0].indexOf('-')+1).trim();
		let version, description = "", id;
		infolines.shift();
		infolines.forEach( line => {
			if( line.trim().length > 0 ){
			const tag = line.substring(0,line.indexOf(':')).trim();
			const value = line.substring(line.indexOf(':')+1).trim();
			switch( tag ) {
				case "ID"      : id      = value; break;
				case "Version" : version = value; break;
				default: description += tag+":"+value+"\n"; break;
			}}
		});
		packageModel.append({
			"PackageName": name,
			"FromVersion": id,
			"ToVersion"  : version,
			"Source"     : "FLATPAK",
			"Group"      : "None",
			"Desc"       : "Description:"+desc+"\n"+description,
			"URL"        : "https://flathub.org/apps/"+id
		});
	}
	function aurFetchFromPacinfo(to, infolist) {
		let name, from, group="None", description = "", url, licenses="", requires="", optionaldeps="", provides="";
		infolist.forEach(line=>{
			const tag   = line.substring(0,line.indexOf(':')).trim();
			const value = line.substring(line.indexOf(':')+1).trim();
			switch( tag ) {
				case "Name": name = value; break;
				case "Version": from = value; break;
				case "URL": url = value; break;
				case "Description":
				case "Packager":
				case "Download Size":
				case "Installed Size":
				case "Architecture":description+= tag+":"+value+"\n"; break;
				case "Licenses": licenses += value + " "; break;
				case "Requires": requires += value + " "; break;
				case "Optional Deps": optionaldeps += value + " "; break;
				case "Provides": provides += value + " "; break;
				case "Groups" : group += value+ " "; break;
			}
		});
		if( group === "" ) group = "None";
		packageModel.append({
			"PackageName": name,
			"FromVersion": from,
			"ToVersion"  : to,
			"Source"     : "AUR",
			"Group"      : group,
			"Desc"       : description,
			"URL"        : url
		});
	}
	function pacmanFetchFromPacinfo(name, from, to, repo) {
		let source, group, description = "", url, licenses="", requires="", optionaldeps="", provides="";
		repo.forEach(line=>{
			if( line.trim().length > 1 ){
				const tag  = line.substring(0, line.indexOf(':'))
				const value= line.substring(line.indexOf(':')+1).trim()
				switch( tag ) {
					case "Groups": group = value; break;
					case "Repository": source = value; break;
					case "URL": url = value; break;
					case "Description":
					case "Packager":
					case "Download Size":
					case "Installed Size":
					case "Architecture":description+= tag+":"+value+"\n"; break;
					case "Licenses": licenses += value + " "; break;
					case "Requires": requires += value + " "; break;
					case "Optional Deps": optionaldeps += value + " "; break;
					case "Provides": provides += value + " "; break;
				}
			}
		});
		description += (licenses.length>0?"Licenses:" + licenses + '\n':"") + (requires.length>0?"Requires:" + requires + '\n':"")
		description += (optionaldeps.length>0?"Optional Deps:" + optionaldeps + '\n':"") + (provides.length>0?"Provides:" + provides:"")
		//console.log(description);
		packageModel.append({
			"PackageName": name,
			"FromVersion": from,
			"ToVersion"  : to,
			"Source"     : source.toUpperCase(),
			"Group"      : group?group:"None",
			"Desc"       : description,
			"URL"        : url
		});
	}
}
function action_updateSystem() {
	//change this
	searching("Updating system","akonadiconsole")
	let command = ""
	if( cfg.useCustomInstall ) execInTerminal(cfg.customScript, cfg.holdTerminal, true)
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
	if( cfg.showAllowSingleModifications == 1 ){
		showAllowSingleModifications = true;
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
	packageManager.exec("mkdir -p ~/.local/share/knotifications6/",(source,stdout,stderr,code)=>{})
	packageManager.exec("echo \'"+notifycontent+"\' > "+notifypath,(source,stdout,stderr,code)=>{})
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
	packageManager.exec(termCmd,(source,stdout,stderr,errcode)=>{
		console.log("errorlog:"+stderr);
		if( searchAfter ) action_searchForUpdates();
	})
}

