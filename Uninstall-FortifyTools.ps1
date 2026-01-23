# ---------------------------------------------------------------------------
# Script: User-Level-Cleanup.ps1 (NO ADMIN REQUIRED)
# ---------------------------------------------------------------------------

$fortifyBase = "$HOME\fortify\tools"

Clear-Host
Write-Host "=== STARTING USER-LEVEL CLEANUP ===" -ForegroundColor Cyan

# 1. Remove File Directories
if (Test-Path $fortifyBase) {
    Write-Host "[*] Deleting $fortifyBase..." -ForegroundColor Gray
    Remove-Item -Path $fortifyBase -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "[+] Files removed." -ForegroundColor Green
}

# 2. Clean User PATH (Registry-Free Method)
Write-Host "[*] Scrubbing User PATH..." -ForegroundColor Gray
$userPath = [Environment]::GetEnvironmentVariable("PATH", "User")
$newPath = ($userPath -split ";" | Where-Object { $_ -notlike "*\fortify\*" }) -join ";"

# This sets it for the current USER only, which usually doesn't trigger UAC
[Environment]::SetEnvironmentVariable("PATH", $newPath, "User")

# 3. Clear JAVA_HOME
[Environment]::SetEnvironmentVariable("JAVA_HOME", $null, "User")

Write-Host "[+] Cleanup Complete!" -ForegroundColor Green
Write-Host "Press any key to close..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")