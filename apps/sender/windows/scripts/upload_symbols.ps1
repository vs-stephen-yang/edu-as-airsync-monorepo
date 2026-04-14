param(
    [Parameter(Mandatory = $true)]
    [ValidateSet("Debug", "Release")]
    [string]$Profile,

    # Common base folder for all build outputs
    [string]$BaseDir = "build\windows\x64",

    # Subfolders (relative to BaseDir) to scan for PDBs
    [string[]]$SubDirs = @(
        "*\$Profile",
        "plugins\*\$Profile",
        "_deps\sentry-native-build\$Profile",
        "plugins\flutter_virtual_display\virtual_display_client\$Profile"
    ),

    # PDB name patterns to exclude
    [string[]]$ExcludePdb = @(
        "vc*.pdb",
        "vcruntime*.pdb"
    ),

    # Output folder for copied PDB files
    [string]$SymbolsDir = "build\symbols",

    # Path to sentry-cli executable
    [string]$SentryCli = "windows\tools\sentry-cli-Windows-x86_64.exe",

    # Not used for now (kept for future extensions)
    [int]$Parallel = 4
)

Write-Host ""
Write-Host "=== Profile: $Profile ==="
Write-Host "BaseDir: $BaseDir"
Write-Host ""

# Build scan patterns from BaseDir + SubDirs
$ScanPatterns = $SubDirs | ForEach-Object { Join-Path $BaseDir $_ }

Write-Host "=== Collecting PDB Files ==="
Write-Host "Scan patterns:"
$ScanPatterns | ForEach-Object { Write-Host " - $_" }
Write-Host ""

# ------------------------------------------------------------
# Expand wildcard patterns into real directories (IMPORTANT)
# ------------------------------------------------------------
$ScanDirs = @()
foreach ($p in $ScanPatterns) {
    # This expands patterns like plugins\*\Release into actual directories
    $ScanDirs += Get-ChildItem -Path $p -Directory -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName
}
$ScanDirs = $ScanDirs | Sort-Object -Unique

if ($ScanDirs.Count -eq 0) {
    Write-Error "No existing scan directories resolved from patterns."
    exit 1
}

Write-Host "Resolved scan directories:"
$ScanDirs | ForEach-Object { Write-Host " - $_" }
Write-Host ""

# ------------------------------------------------------------
# Recursively find all PDB files under all resolved scan folders
# ------------------------------------------------------------
$pdbFiles = @()

foreach ($dir in $ScanDirs) {
    Write-Host "Scanning: $dir"
    $items = Get-ChildItem -Path $dir -Recurse -Filter *.pdb -ErrorAction SilentlyContinue
    if ($items) {
        $pdbFiles += $items
    }
}

if ($pdbFiles.Count -eq 0) {
    Write-Error "No PDB files found in any of the scan folders."
    exit 1
}

Write-Host ""
Write-Host "Found $($pdbFiles.Count) PDBs before filtering."

# ------------------------------------------------------------
# Apply exclusion patterns
# ------------------------------------------------------------
if ($ExcludePdb.Count -gt 0) {
    Write-Host ""
    Write-Host "Applying exclude patterns:"
    foreach ($pattern in $ExcludePdb) {
        Write-Host " - $pattern"
        $pdbFiles = $pdbFiles | Where-Object { $_.Name -notlike $pattern }
    }
}

if ($pdbFiles.Count -eq 0) {
    Write-Error "All PDBs were excluded. Nothing to process."
    exit 1
}

$pdbFiles = $pdbFiles | Sort-Object FullName

Write-Host ""
Write-Host "Final PDB count: $($pdbFiles.Count)"

# ------------------------------------------------------------
Write-Host ""
Write-Host "=== Preparing Symbols Directory ==="

if (Test-Path $SymbolsDir) {
    Remove-Item -Recurse -Force $SymbolsDir
}
New-Item -ItemType Directory -Path $SymbolsDir | Out-Null

# Preserve relative path under BaseDir to avoid collisions
$baseDirAbs = (Resolve-Path -Path $BaseDir).Path

# Keep a set to avoid copying the same file twice
$copiedPaths = New-Object 'System.Collections.Generic.HashSet[string]' ([System.StringComparer]::OrdinalIgnoreCase)

function Copy-IfNeeded {
    param(
        [Parameter(Mandatory = $true)][string]$SrcPath,
        [Parameter(Mandatory = $true)][string]$DestPath
    )
    if (-not (Test-Path $SrcPath)) { return }

    $destDir = Split-Path $DestPath -Parent
    if (-not (Test-Path $destDir)) {
        New-Item -ItemType Directory -Path $destDir -Force | Out-Null
    }

    if ($copiedPaths.Add($DestPath)) {
        Copy-Item -Path $SrcPath -Destination $DestPath -Force
    }
}

Write-Host ""
Write-Host "=== Copying PDB (and matching DLL/EXE) Files ==="

$copiedPdbs = @()

foreach ($pdb in $pdbFiles) {
    $relative = $pdb.FullName
    if ($pdb.FullName.StartsWith($baseDirAbs, [System.StringComparison]::OrdinalIgnoreCase)) {
        $relative = $pdb.FullName.Substring($baseDirAbs.Length).TrimStart("\", "/")
    }

    # Copy PDB
    $pdbDest = Join-Path $SymbolsDir $relative
    Write-Host "Copying PDB: $($pdb.Name)"
    Copy-IfNeeded -SrcPath $pdb.FullName -DestPath $pdbDest

    $copiedPdbs += [PSCustomObject]@{
        Name = $pdb.Name
        Dest = $pdbDest
    }

    # Also copy matching DLL/EXE (helps PE debug companion / unwind)
    foreach ($ext in @(".dll", ".exe")) {
        $binPath = Join-Path $pdb.DirectoryName ($pdb.BaseName + $ext)
        if (Test-Path $binPath) {
            $binRel = $relative -replace '\.pdb$', $ext
            $binDest = Join-Path $SymbolsDir $binRel
            Write-Host "  Copying BIN: $([System.IO.Path]::GetFileName($binPath))"
            Copy-IfNeeded -SrcPath $binPath -DestPath $binDest
        }
    }
}

Write-Host ""
Write-Host "Copy complete."
Write-Host "Copied PDB count: $($copiedPdbs.Count)"

# ------------------------------------------------------------
Write-Host ""
Write-Host "=== Uploading to Sentry ==="

# Upload only what we intend: PDB + PE (companion)
& $SentryCli "debug-files" "upload" "--wait" "--type" "pdb" "--type" "pe" $SymbolsDir

if ($LASTEXITCODE -ne 0) {
    Write-Error "Upload failed. sentry-cli exit code: $LASTEXITCODE"
    exit $LASTEXITCODE
}

Write-Host ""
Write-Host "All symbols uploaded successfully!"
