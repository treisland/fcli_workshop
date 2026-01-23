# ---------------------------------------------------------------------------
# Script: Uninstall-FortifyDependencies.ps1
# Description: Removes OpenJDK, Maven, and cleans up Environment Variables.
# ---------------------------------------------------------------------------

$thirdPartyDir = "$HOME\fortify\thirdparty"
$javaDir       = Join-Path $thirdPartyDir "openjdk-21"
$mavenDir      = Join-Path $thirdPartyDir "maven"

Clear-Host
Write-Host "--- Fortify Dependency Uninstaller ---" -ForegroundColor Cyan

# 1. Remove Files
if (Test-Path $thirdPartyDir) {
    Write-Host "[*] Removing third-party binaries from $thirdPartyDir..." -ForegroundColor Gray
    try {
        Remove-Item -Path $thirdPartyDir -Recurse -Force -ErrorAction Stop
        Write-Host "[+] Local binaries deleted successfully." -ForegroundColor Green
    } catch {
        Write-Host "[!] Could not delete some files. Ensure no Java or Maven processes are running." -ForegroundColor Red
    }
} else {
    Write-Host "[!] Third-party directory not found. Skipping file removal." -ForegroundColor Yellow
}

# 2. Clean Up Environment Variables
Write-Host "[*] Cleaning up Environment Variables..." -ForegroundColor Gray

$javaBin  = Join-Path $javaDir "bin"
$mavenBin = Join-Path $mavenDir "bin"

# Get current User PATH
$oldPath = [Environment]::GetEnvironmentVariable("PATH", "User")
$pathEntries = $oldPath -split ";"

# Filter out the Java and Maven entries
$newPathEntries = $pathEntries | Where-Object { 
    $_ -ne $javaBin -and $_ -ne $mavenBin -and $_ -notlike "*fortify\thirdparty*" 
}

$newPath = $newPathEntries -join ";"

# Apply the cleaned PATH
[Environment]::SetEnvironmentVariable("PATH", $newPath, "User")

# Remove JAVA_HOME if it points to our thirdparty directory
$javaHome = [Environment]::GetEnvironmentVariable("JAVA_HOME", "User")
if ($javaHome -like "*fortify\thirdparty*") {
    [Environment]::SetEnvironmentVariable("JAVA_HOME", $null, "User")
    Write-Host "[+] JAVA_HOME variable removed." -ForegroundColor Green
}

Write-Host "[+] Environment PATH scrubbed." -ForegroundColor Green

# 3. Final Feedback
Write-Host "`n--- Uninstall Complete ---" -ForegroundColor Cyan
Write-Host "Please restart your terminal to finalize the changes." -ForegroundColor Yellow