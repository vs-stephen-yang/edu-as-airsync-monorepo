$ai_bin = '"C:\Program Files (x86)\Caphyon\Advanced Installer 18.5\bin\x86\AdvancedInstaller.com"'
$url_base = 'https://store2.myviewboard.com/uploads/DisplayCast'
$version_reg_key = 'HKUD\Software\ViewSonic\Display Cast\Version'

$update_ai_path = '.\windows\update.aip'
$executable_path = '.\build\windows\runner\Release\Display_Cast.exe'

$update_name = 'Update'

$edit_cmd = "$ai_bin /edit $update_ai_path"

if( $args.count -lt 1) {
	"Usage: <env>"
	exit 1
}

# environment: dev, stage, prod
$env = $args[0]

if ($env -eq "prod") {
	$env_suffix = "";
} else {
	$env_suffix = "-$env"
}

# extract executable version
$ver = (Get-Item $executable_path).VersionInfo.FileVersionRaw

$msi_file = "DisplayCast-${ver}${env_suffix}.msi"
$msi_path = "windows\package\$msi_file"

$main_url = "$url_base$env_suffix/$msi_file"

# patch the version and msi path
# https://www.advancedinstaller.com/user-guide/set-update-options.html
$cmdline = "$edit_cmd /UpdateInstaller $update_name -path $msi_path -prod_version $ver"
cmd.exe /c $cmdline

# patch main_url
# https://www.advancedinstaller.com/user-guide/set-update-properties.html
$cmdline = "$edit_cmd /UpdateProperties $update_name -main_url $main_url"
cmd.exe /c $cmdline

#update registry check
$cmdline = "$edit_cmd /UpdateInstalledDetection $update_name -detection_type RegKeySearch -path ""$version_reg_key"" -expected_value $ver"
cmd.exe /c $cmdline
