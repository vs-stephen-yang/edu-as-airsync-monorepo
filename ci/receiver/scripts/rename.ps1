param(
    [string]$Wd, # Working directory
    [string]$Channel, # open, ifp, edla, store    
    [string]$Target, # production, stage    
    [switch]$Single = $false,
    [switch]$Bundle = $false,
    [switch]$Split = $false
)

$channelName = $Channel.ToUpper()

if ($Target -eq "stage") {
    $variantName = "_S"
}
else {
    $variantName = ""
}


# Read the content of pubspec.yaml and find the version line
$versionLine = Select-String -Path "pubspec.yaml" -Pattern "^version: " | ForEach-Object {
    $_.Line.Substring(9)
}

# Split the version into an array by '+'
$versionNameCode = $versionLine -split '\+'

# Get the version name and version code
$versionName = $versionNameCode[0].Trim()


# Rename single apk
if ($Single) {
    $sourceAppFile = "$($Wd)/app-$($Channel)$($Target)-release.apk"
    $destAppFile = "$($Wd)/myViewBoardDisplay_APK_$($channelName)$($variantName)_v$($versionName).apk"
    
    Write-Host "$sourceAppFile -> $destAppFile"

    Rename-Item -Path $sourceAppFile -NewName $destAppFile
}

# Rename split apk
if ($Split) {

    $archs = @("arm64-v8a", "armeabi-v7a")

    if ($Channel -ieq 'open') {
        $archs += 'x86_64'
    }
    foreach ($arch in $archs) {
        $sourceAppFile = "$($Wd)/app-$($arch)-$($Channel)$($Target)-release.apk"
        $destAppFile = "$($Wd)/myViewBoardDisplay_APK_$($channelName)_$($arch)$($variantName)_v$($versionName).apk"

        Write-Host "$sourceAppFile -> $destAppFile"

        Rename-Item -Path $sourceAppFile -NewName $destAppFile
    }
}

# Rename aab
if ($Bundle) {
    $sourceAppFile = "$($Wd)/app-$($Channel)-$($target)-release.aab"
    $destAppFile = "$($Wd)/myViewBoardDisplay_APK_$($channelName)$($variantName)_v$($versionName).aab"

    Write-Host "$sourceAppFile -> $destAppFile"

    Rename-Item -Path $sourceAppFile -NewName $destAppFile
}
