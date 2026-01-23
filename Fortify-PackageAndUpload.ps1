# ---------------------------------------------------------------------------
# Script: Fortify-PackageAndUpload.ps1
# Description: Packages IWA-Java and uploads it to FoD in one workflow.
# ---------------------------------------------------------------------------

# 1. Configuration & Paths
$scriptHome  = Get-Location
$workDir     = "$HOME\fortify\test-package"
$repoUrl     = "https://github.com/fortify/IWA-Java/archive/refs/heads/main.zip"
$zipFile     = Join-Path $workDir "IWA-Java.zip"
$extractDir  = Join-Path $workDir "IWA-Java-main"
$packageFile = "package.zip" # Relative to the extract directory

Clear-Host
Write-Host "--- Fortify End-to-End: Package & Upload ---" -ForegroundColor Cyan

# 2. Capture Target Release Info (Early to avoid waiting later)
Write-Host "[*] Target Release Required (e.g., 12345 or AppName:ReleaseName)" -ForegroundColor Yellow
$releaseIdentifier = Read-Host " > Release Identifier"

if ([string]::IsNullOrWhiteSpace($releaseIdentifier)) {
    Write-Host "[!] Error: Release identifier cannot be empty." -ForegroundColor Red
    exit
}

# 3. Preparation & Source Download
if (!(Test-Path $workDir)) { New-Item -ItemType Directory -Path $workDir -Force | Out-Null }

Write-Host "[*] Downloading and extracting sample code..." -ForegroundColor Gray
Invoke-WebRequest -Uri $repoUrl -OutFile $zipFile
Expand-Archive -Path $zipFile -DestinationPath $workDir -Force

# 4. Packaging Step
Write-Host "[*] Navigating to source for packaging..." -ForegroundColor Gray
Push-Location $extractDir

try {
    Write-Host "[*] Running ScanCentral Package..." -ForegroundColor Yellow
    scancentral package -o $packageFile
    
    if (!(Test-Path $packageFile)) {
        Write-Host "[!] Error: Packaging failed. Aborting upload." -ForegroundColor Red
        return
    }

    # 5. Authentication & Upload Step
    Write-Host "`n[*] Authenticating with Fortify on Demand..." -ForegroundColor Gray
    & fcli fod session login 2>&1 | Out-Null

    if ($LASTEXITCODE -ne 0) {
        Write-Host "[!] Login Failed. Check your FCLI_DEFAULT environment variables." -ForegroundColor Red
        return
    }
    
    Write-Host "[+] Login successful. Starting SAST upload..." -ForegroundColor Green
    & fcli fod sast start -f $packageFile --release $releaseIdentifier
    $uploadStatus = $LASTEXITCODE

    # 6. Logout
    Write-Host "[*] Logging out..." -ForegroundColor Gray
    & fcli fod session logout | Out-Null
    
} finally {
    # Always return back to the script folder
    Pop-Location
    Write-Host "[*] Returned to script directory." -ForegroundColor Gray
}

# 7. Final Results
if ($uploadStatus -eq 0) {
    Write-Host "[+] SUCCESS: Full workflow complete!" -ForegroundColor Green
} else {
    Write-Host "[!] FAILURE: The upload step failed." -ForegroundColor Red
}

Write-Host "`n--- Task Finished ---" -ForegroundColor Cyan