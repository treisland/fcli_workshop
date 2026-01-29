# ---------------------------------------------------------------------------
# Script: Setup-FortifyFCLI-WithValidation.ps1
# Description: Validates credentials before proceeding with full installation.
# ---------------------------------------------------------------------------

$fortifyToolsDir = "$HOME\fortify\tools\bin\"
$fcliZipFile     = "$env:TEMP\fcli-windows.zip"
$fcliDownloadUrl = "https://github.com/fortify/fcli/releases/latest/download/fcli-windows.zip"
$fcliExe         = Join-Path $fortifyToolsDir "fcli.exe"
$ProgressPreference = 'SilentlyContinue'

Clear-Host
Write-Host "--- Fortify CLI (fcli) Setup & Validation ---" -ForegroundColor Cyan

# 1. Capture/Retrieve Configuration
$fodUrl    = [Environment]::GetEnvironmentVariable("FCLI_DEFAULT_FOD_URL", "User")
$clientId  = [Environment]::GetEnvironmentVariable("FCLI_DEFAULT_CLIENT_ID", "User")
$envSecret = [Environment]::GetEnvironmentVariable("FCLI_DEFAULT_CLIENT_SECRET", "User")

if ([string]::IsNullOrWhiteSpace($fodUrl) -or [string]::IsNullOrWhiteSpace($clientId) -or [string]::IsNullOrWhiteSpace($envSecret)) {
    Write-Host "[*] Configuration missing. Please provide details:" -ForegroundColor Yellow
    $fodUrl = Read-Host " > FoD URL [Default: https://ams.fortify.com]"
    if ([string]::IsNullOrWhiteSpace($fodUrl)) { $fodUrl = "https://ams.fortify.com" }
    
    $clientId = Read-Host " > FoD Client ID"
    $secSecret = Read-Host " > FoD Client Secret" -AsSecureString
    
    # Decrypt for session use
    $bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secSecret)
    $clientSecret = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr)
    [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr)

    # Persist for future sessions
    [Environment]::SetEnvironmentVariable("FCLI_DEFAULT_FOD_URL", $fodUrl, "User")
    [Environment]::SetEnvironmentVariable("FCLI_DEFAULT_CLIENT_ID", $clientId, "User")
    [Environment]::SetEnvironmentVariable("FCLI_DEFAULT_CLIENT_SECRET", $clientSecret, "User")
} else {
    $clientSecret = $envSecret
}

# 2. Preparation & Initial fcli Download (Required for testing)
if (!(Test-Path $fortifyToolsDir)) { New-Item -ItemType Directory -Path $fortifyToolsDir -Force | Out-Null }

if (!(Test-Path $fcliExe)) {
    Write-Host "[*] Downloading fcli for validation..." -ForegroundColor Gray
    Invoke-WebRequest -Uri $fcliDownloadUrl -OutFile $fcliZipFile
    Expand-Archive -Path $fcliZipFile -DestinationPath $fortifyToolsDir -Force
    Remove-Item $fcliZipFile
}

# 3. THE TEST: Login Validation
Write-Host "`n--- VALIDATING CREDENTIALS ---" -ForegroundColor Cyan
Write-Host "[*] Attempting test login to: $fodUrl" -ForegroundColor Gray

# We run the login and capture the result
& $fcliExe fod session login --url $fodUrl --client-id $clientId --client-secret $clientSecret 2>&1 | Out-Null

if ($LASTEXITCODE -eq 0) {
    Write-Host "[+] SUCCESS: Login verified. Credentials are valid." -ForegroundColor Green
    Write-Host "[*] Logging out of test session..." -ForegroundColor Gray
    & $fcliExe fod session logout | Out-Null
} else {
    Write-Host "[!] FAILURE: Could not authenticate with Fortify on Demand." -ForegroundColor Red
    Write-Host "[!] Please verify your Client ID, Secret, and URL." -ForegroundColor Red
    Write-Host "[!] Installation aborted." -ForegroundColor Yellow
    exit
}

# 4. Proceed with Installation (Only if login succeeded)
Write-Host "`n--- PROCEEDING WITH INSTALLATION ---" -ForegroundColor Cyan
Write-Host "[*] Installing ScanCentral Client..." -ForegroundColor Gray
& $fcliExe tool scancentral-client install

# 5. Finalize PATH
$oldPath = [Environment]::GetEnvironmentVariable("PATH", "User")
if ($oldPath -notlike "*$fortifyToolsDir*") {
    [Environment]::SetEnvironmentVariable("PATH", "$oldPath;$fortifyToolsDir", "User")
    Write-Host "[+] Path updated. Configuration complete." -ForegroundColor Green
}

Write-Host "`n--- Setup Finished Successfully ---" -ForegroundColor Cyan