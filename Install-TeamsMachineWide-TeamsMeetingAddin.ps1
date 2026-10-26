<#
.SYNOPSIS
    Installs the Microsoft Teams Meeting Add-in (TMA) machine-wide for Outlook Classic
    during an AVD golden image build.

.DESCRIPTION
    New Teams installs the Meeting Add-in per user at first launch (from %LocalAppData%).
    In hardened environments (e.g. Windows Installer policy DisableUserInstalls or AppLocker
    MSI rules) this per-user install fails with error 1625 "This installation is forbidden
    by system policy", leaving the add-in disabled in Outlook.

    This script uses the Teams bootstrapper with --installTMA to install the add-in
    machine-wide in C:\Program Files (x86)\Microsoft\TeamsMeetingAdd-in\<version>\,
    so no per-user MSI installation is needed.

.NOTES
    - Run as SYSTEM/Administrator during the image build (e.g. AVD Image Template customizer).
    - -p              : provisions New Teams for all users
    - --installTMA    : installs the Teams Meeting Add-in machine-wide
    - Per-user troubleshooting log: %LocalAppData%\Packages\MSTeams_8wekyb3d8bbwe\LocalCache\Microsoft\MSTeams\Logs\tma_addin_msi.txt
#>

$ErrorActionPreference = "Stop"

$TempDir = "C:\Temp"
$exe     = Join-Path $TempDir "teamsbootstrapper.exe"
$url     = "https://go.microsoft.com/fwlink/?linkid=2243204&clcid=0x409"

# 1. Download the Teams bootstrapper
New-Item -ItemType Directory -Path $TempDir -Force | Out-Null
Write-Host "[-] Downloading Teams bootstrapper..." -ForegroundColor Cyan
Invoke-WebRequest -Uri $url -OutFile $exe -UseBasicParsing

# 2. Provision New Teams and install the Meeting Add-in machine-wide
Write-Host "[-] Provisioning New Teams and installing Teams Meeting Add-in (machine-wide)..." -ForegroundColor Cyan
$Process = Start-Process -FilePath $exe -ArgumentList "-p --installTMA" -Wait -NoNewWindow -PassThru

if ($Process.ExitCode -eq 0) {
    Write-Host "[+] Teams and Teams Meeting Add-in installed successfully." -ForegroundColor Green
} else {
    Write-Error "[!] Teams bootstrapper failed with exit code: $($Process.ExitCode)"
}

# 3. Clean up
Remove-Item -Path $exe -Force -ErrorAction SilentlyContinue