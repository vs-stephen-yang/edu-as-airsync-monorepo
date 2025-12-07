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

    # Output folder for generated .sym files
    [string]$SymbolsDir = "build\symbols",

    # Path to dump_syms executable
    [string]$DumpSyms = "windows\tools\dump_syms.exe",

    # Path to sentry-cli executable
    [string]$SentryCli = "windows\tools\sentry-cli-Windows-x86_64.exe",

    # Not used for now (kept for future extensions)
    [int]$Parallel = 4
)

Write-Host ""
Write-Host "=== Profile: $Profile ==="
Write-Host "BaseDir: $BaseDir"
Write-Host ""

# Build absolute scan paths from BaseDir + SubDirs
$BuildDirs = $SubDirs | ForEach-Object { Join-Path $BaseDir $_ }

Write-Host "=== Collecting PDB Files ==="
Write-Host "Resolved scan paths:"
$BuildDirs | ForEach-Object { Write-Host " - $_" }
Write-Host ""

# ------------------------------------------------------------
# Recursively find all PDB files under all scan folders
# ------------------------------------------------------------

$pdbFiles = @()

foreach ($dir in $BuildDirs) {
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

# Sort PDBs for stable, readable output
$pdbFiles = $pdbFiles | Sort-Object FullName

Write-Host ""
Write-Host "Final PDB count: $($pdbFiles.Count)"
Write-Host "PDB files to process:"
$pdbFiles | ForEach-Object { Write-Host "  $($_.FullName)" }


# ------------------------------------------------------------
Write-Host ""
Write-Host "=== Preparing Symbols Directory ==="

if (Test-Path $SymbolsDir) {
    Remove-Item -Recurse -Force $SymbolsDir
}
New-Item -ItemType Directory -Path $SymbolsDir | Out-Null


# ------------------------------------------------------------
Write-Host ""
Write-Host "=== Converting PDB → SYM ==="

# Collect successful SYM + debug_id info for summary
$symInfo = @()

foreach ($pdb in $pdbFiles) {

    $symPath = Join-Path $SymbolsDir ($pdb.BaseName + ".sym")

    Write-Host "Processing: $($pdb.Name)"

    # Call dump_syms to generate .sym
    $cmd = "`"$DumpSyms`" `"$($pdb.FullName)`" > `"$symPath`""
    cmd.exe /C $cmd | Out-Null

    # If .sym is missing or empty, skip this PDB
    if (-not (Test-Path $symPath) -or (Get-Item $symPath).Length -eq 0) {
        Write-Host "  → .sym not generated (invalid or unsupported PDB)"
        continue
    }

    # Read the first line of the .sym file (MODULE line)
    $first = Get-Content $symPath -First 1 -ErrorAction SilentlyContinue
    if (-not $first) {
        Write-Host "  → Failed to read .sym header"
        continue
    }

    $parts = $first.Split(" ", [System.StringSplitOptions]::RemoveEmptyEntries)
    if ($parts.Count -lt 4 -or $parts[0] -ne "MODULE") {
        Write-Host "  → Invalid .sym header (no MODULE line)"
        continue
    }

    $debugId = $parts[3]

    # Store info for final summary
    $symInfo += [PSCustomObject]@{
        PdbName = $pdb.Name
        SymPath = $symPath
        DebugId = $debugId
    }
}

Write-Host ""
Write-Host "SYM generation complete."


# ------------------------------------------------------------
# Print final SYM summary, sorted by PDB name
# ------------------------------------------------------------

Write-Host ""
Write-Host "Final SYM count: $($symInfo.Count)"
Write-Host "=== SYM Files Summary ==="

if ($symInfo.Count -eq 0) {
    Write-Host "No valid SYM files were generated."
}
else {
    $symInfoSorted = $symInfo | Sort-Object PdbName
    foreach ($item in $symInfoSorted) {
        Write-Host ("{0}, {1}" -f $item.PdbName, $item.DebugId)
        # If you also want path, uncomment the next line:
        # Write-Host ("    {0}" -f $item.SymPath)
    }
}


# ------------------------------------------------------------
Write-Host ""
Write-Host "=== Uploading to Sentry ==="

& $SentryCli "debug-files" "upload" "--wait" $SymbolsDir

if ($LASTEXITCODE -ne 0) {
    Write-Error "Upload failed. sentry-cli exit code: $LASTEXITCODE"
    exit $LASTEXITCODE
}

Write-Host ""
Write-Host "All symbols uploaded successfully!"
