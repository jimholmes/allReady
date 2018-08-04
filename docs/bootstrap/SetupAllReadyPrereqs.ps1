Function check_admin_privs() {
	If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
		[Security.Principal.WindowsBuiltInRole] "Administrator"))
	{
		Write-Warning "This script must be executed as an Administrator. Please re-run as Administrator."
		Exit
	}
}

Function display_info() {
		Write-Host "This script sets up prerequisites for working on Humanitarian Toolbox's allReady project."
		       "This script installs Chocolatey and uses it to install several packages including Git, NodeJs,"
			   "and .NET Core. Latest versions of all packages are installed."
			   "NPM is also called to install Gulp and Bower."
			   "Additionally you're asked if you need to set proxy environment variables."
        write-host "Press any key to continue..."
		[void][System.Console]::ReadKey($true)
}

Function create_profile_if_needed() {
    if (!(test-path $profile)) {
        Write-Host "No profile found. Creating a default one."
        new-item -type file -path $profile -force
    }
}

Function install_chocolatey () {
	Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
	# Source the new profile so it's in the shell
	. $PROFILE
	RefreshEnv
}

Function install_config_git() {
	choco install -y git
	check_choco_errors $LASTEXITCODE
	# Source the new profile so it's in the shell
	. $PROFILE
	RefreshEnv
	$username = Read-Host -prompt "Enter your name for Git config, eg 'Jim Holmes'"
	$email = Read-Host -prompt "Enter your email for Git config, eg 'Jim@GuidepostSystems.com'"
	git config --global user.name $username
	git config --global user.email $email
	git config --global --add core.longpaths true
}

Function install_node_lts() {
	choco install -y nodejs-lts
	check_choco_errors $LASTEXITCODE
	RefreshEnv
}

Function set_proxy_info() {
	$using_proxy = Read-Host -prompt "Do you need to configure a proxy for your system? (Y/N)"
	if ($using_proxy.ToUpper() -eq "Y") {
		$proxy = Read-Host -prompt "Server (DNS name or IP address): "
		$port = Read-Host -prompt "Port Number: "
		
		setx http_proxy $proxy":"$port
		setx https_proxy $proxy":"$port
		
		npm config set proxy $proxy":"$port
		npm config set https-proxy $proxy":"$port
	}
}

Function install_bower() {
	npm install -g bower
}

Function install_gulp () {
	npm install -g gulp-cli
}

Function notify_visual_studio() {
	Read-Host " Make sure you have Visual Studio 2017 or higher. You'll need F# and ASP.NET features."
    write-host "Press any key to continue..."
    [void][System.Console]::ReadKey($true)
	
}

Function install_net_core() {
	choco install -y dotnetcore-sdk
	check_choco_errors $LASTEXITCODE

	RefreshEnv
}

Function check_choco_errors($exitCode) {
	$validExitCodes = @(0, 1605, 1614, 1641, 3010)
	handle_errors $exitCode $validExitCodes
}

Function check_npm_errors($exitCode) {
	$validExitCodes = @(0)
	handle_errors $exitCode $validExitCodes
}

Function handle_errors($exitCode, $validExitCodes){

	if ($validExitCodes -contains $exitCode) {
      Write-Host "OK"
	  Return
	}
	Write-Host "`n`nProblem installing package. Stopping install script.`n`nExit code was: " $exitCode
	Exit $exitCode
}


check_admin_privs
display_info
create_profile_if_needed
install_chocolatey
install_config_git
install_node_lts
set_proxy_info
install_bower
install_gulp
notify_visual_studio
install_net_core
