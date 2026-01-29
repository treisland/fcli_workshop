# ---------------------------------------------------------------------------
# Script: Install-FortifyDependencies.ps1
# ---------------------------------------------------------------------------

$thirdPartyDir = "$HOME\fortify\thirdparty"
$javaDir       = Join-Path $thirdPartyDir "openjdk-21"
$mavenDir      = Join-Path $thirdPartyDir "maven"
$ProgressPreference = 'SilentlyContinue'
# Updated Maven link to a more resilient URL
$javaUrl  = "https://download.oracle.com/java/21/latest/jdk-21_windows-x64_bin.zip"
$mavenUrl = "https://archive.apache.org/dist/maven/maven-3/3.9.6/binaries/apache-maven-3.9.6-bin.zip"

Clear-Host
Write-Host "--- Fortify Dependency Check & Installer ---" -ForegroundColor Cyan

if (!(Test-Path $thirdPartyDir)) { New-Item -ItemType Directory -Path $thirdPartyDir -Force | Out-Null }

# 1. Java Check (Using -q to suppress the error you saw)
$javaCheck = Get-Command java -ErrorAction SilentlyContinue
if ($javaCheck) {
    Write-Host "[!] Java already found at: $($javaCheck.Source)" -ForegroundColor Yellow
} else {
    Write-Host "[*] Java not found. Downloading..." -ForegroundColor Gray
    $javaZip = "$env:TEMP\java21.zip"
    Invoke-WebRequest -Uri $javaUrl -OutFile $javaZip
    Expand-Archive -Path $javaZip -DestinationPath $thirdPartyDir -Force
    $extractedJava = Get-ChildItem -Path $thirdPartyDir -Filter "jdk-21*" | Select-Object -First 1
    if ($extractedJava) { Rename-Item -Path $extractedJava.FullName -NewName "openjdk-21" }
    Remove-Item $javaZip -ErrorAction SilentlyContinue
}

# 2. Maven Check & Fixed Download
$mavenCheck = Get-Command mvn -ErrorAction SilentlyContinue
if ($mavenCheck) {
    Write-Host "[!] Maven already found at: $($mavenCheck.Source)" -ForegroundColor Yellow
} else {
    Write-Host "[*] Maven not found. Downloading from Archive..." -ForegroundColor Gray
    $mavenZip = "$env:TEMP\maven.zip"
    
    try {
        Invoke-WebRequest -Uri $mavenUrl -OutFile $mavenZip -ErrorAction Stop
        Write-Host "[*] Extracting Maven..." -ForegroundColor Gray
        Expand-Archive -Path $mavenZip -DestinationPath $thirdPartyDir -Force
        
        $extractedMvn = Get-ChildItem -Path $thirdPartyDir -Filter "apache-maven*" | Select-Object -First 1
        if ($extractedMvn) { 
            Rename-Item -Path $extractedMvn.FullName -NewName "maven" 
            Write-Host "[+] Maven installed successfully." -ForegroundColor Green
        }
    } catch {
        Write-Host "[!] Failed to download Maven. The mirror might be down." -ForegroundColor Red
    } finally {
        if (Test-Path $mavenZip) { Remove-Item $mavenZip }
    }
}

# 3. Path Updates
function Update-UserPath ($newSegment) {
    if (Test-Path $newSegment) {
        $currentPath = [Environment]::GetEnvironmentVariable("PATH", "User")
        if ($currentPath -notlike "*$newSegment*") {
            [Environment]::SetEnvironmentVariable("PATH", "$currentPath;$newSegment", "User")
            return $true
        }
    }
    return $false
}

$javaAdded  = Update-UserPath (Join-Path $javaDir "bin")
$mavenAdded = Update-UserPath (Join-Path $mavenDir "bin")

if ($javaAdded -or $mavenAdded) {
    Write-Host "[+] Environment updated. Please RESTART your terminal." -ForegroundColor Green
} else {
    Write-Host "[!] No PATH changes were necessary." -ForegroundColor Yellow
}