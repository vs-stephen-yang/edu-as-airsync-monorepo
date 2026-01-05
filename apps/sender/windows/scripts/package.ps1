$windows_kit_bin_base = "C:\Program Files (x86)\Windows Kits\10\bin\"

$windows_kit_bin_dir = Get-ChildItem ${windows_kit_bin_base} | where { $_.Name -like "10.0.*" } | Select-Object -last 1

$ai_bin = "C:\Program Files (x86)\Caphyon\Advanced Installer 21.2.2\bin\x86\AdvancedInstaller.com"
$mt_bin = "${windows_kit_bin_dir}\x86\mt.exe"

$manifest_path = "${pwd}\windows\runner\runner.exe.manifest"
$edit_update_cmd = "${pwd}\windows\scripts\patch-update.ps1"

$build_dir = "build\windows\x64\runner\Release"
$executable_path = "${build_dir}\AirSync_Sender.exe"
$installer_out_dir = "windows\package"

function Run {
    param (
        $FilePath,
        $Arguments
    )
    Write-Host "Running $FilePath $Arguments`n"

    $options = @{
        FilePath     = "$FilePath"
        ArgumentList = "$Arguments"
        Wait         = $true
        NoNewWindow  = $true
        PassThru     = $true
    }
    $proc = Start-Process @options

    if ($proc.ExitCode -ne 0) {
        exit 1
    }
}


if ( $args.count -lt 1) {
    "Usage: <env>"
    exit 1
}
# environment: dev, stage, prod
$env = $args[0]

# overwrite the application manifest to bypass uipi
Write-Host "1. Overwrite the application manifest`n"

Run -FilePath "${mt_bin}" -Arguments "-manifest ""${manifest_path}"" -outputresource:""${executable_path}"";#1"

# clean the package
if (Test-Path -Path $installer_out_dir) {
    Remove-Item $installer_out_dir -Recurse -Force
}

# build the installer
Write-Host "2. Build the installer`n"

Run -FilePath "${ai_bin}" -Arguments "/rebuild windows\installer.aip -buildslist ${env}"


# edit the installer update
Write-Host "3. Edit the installer update`n"

& "${edit_update_cmd}" "${env}"

# build the installer update
Write-Host "4. Build the installer update`n"

Run -FilePath "${ai_bin}" -Arguments "/rebuild windows\update.aip"
