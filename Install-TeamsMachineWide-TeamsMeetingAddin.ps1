<#
.SYNOPSIS
    Installs New Teams with AVD optimizations and the Teams Meeting Add-in (TMA)
    machine-wide for Outlook Classic during an AVD golden image build.

.DESCRIPTION
    Replaces the built-in AVD Image Template option "Install Teams with optimizations".
    That option does not install the Teams Meeting Add-in machine-wide. New Teams then
    tries to install the add-in per user at first launch, which fails in hardened
    environments (Windows Installer policy / AppLocker) with error 1625
    "This installation is forbidden by system policy". As a result, the add-in stays
    disabled in Outlook.

    This script:
      1. Sets the IsWVDEnvironment registry key (Teams AVD media optimization)
      2. Installs the Remote Desktop WebRTC Redirector Service
      3. Provisions New Teams for all users and installs the Teams Meeting Add-in
         machine-wide in C:\Program Files (x86)\Microsoft\TeamsMeetingAdd-in\<version>\

.NOTES
    - Run as SYSTEM/Administrator during the image build (AVD Image Template customizer).
    - Leave the built-in option "Install Teams with optimizations" UNCHECKED.
    - Visual C++ Redistributable x64 is installed by the built-in "Install multimedia redirection" option.
    - Bootstrapper switches:
        -p            : provisions New Teams for all users
        --installTMA  : installs the Teams Meeting Add-in machine-wide
    - Per-user troubleshooting log for the add-in:
      %LocalAppData%\Packages\MSTeams_8wekyb3d8bbwe\LocalCache\Microsoft\MSTeams\Logs\tma_addin_msi.txt
#>

$ErrorActionPreference = "Stop"
$TempDir = $env:TEMP

# 1. Teams AVD optimization registry key
Write-Host "[-] Setting IsWVDEnvironment registry key..." -ForegroundColor Cyan
$TeamsRegPath = "HKLM:\SOFTWARE\Microsoft\Teams"
if (-not (Test-Path $TeamsRegPath)) { New-Item -Path $TeamsRegPath -Force | Out-Null }
Set-ItemProperty -Path $TeamsRegPath -Name "IsWVDEnvironment" -Value 1 -Type DWord

# 2. Remote Desktop WebRTC Redirector Service
Write-Host "[-] Installing Remote Desktop WebRTC Redirector Service..." -ForegroundColor Cyan
$WebRtcMsi = Join-Path $TempDir "MsRdcWebRTCSvc_HostSetup.msi"
Invoke-WebRequest -Uri "https://aka.ms/msrdcwebrtcsvc/msi" -OutFile $WebRtcMsi -UseBasicParsing
$Proc = Start-Process msiexec.exe -ArgumentList "/i `"$WebRtcMsi`" /qn /norestart" -Wait -PassThru
if ($Proc.ExitCode -notin 0, 3010) { Write-Error "[!] WebRTC Redirector install failed: $($Proc.ExitCode)" }

# 3. New Teams + Teams Meeting Add-in (machine-wide)
Write-Host "[-] Provisioning New Teams and installing Teams Meeting Add-in..." -ForegroundColor Cyan
$Exe = Join-Path $TempDir "teamsbootstrapper.exe"
Invoke-WebRequest -Uri "https://go.microsoft.com/fwlink/?linkid=2243204&clcid=0x409" -OutFile $Exe -UseBasicParsing
$Proc = Start-Process -FilePath $Exe -ArgumentList "-p --installTMA" -Wait -NoNewWindow -PassThru
if ($Proc.ExitCode -ne 0) { Write-Error "[!] Teams bootstrapper failed: $($Proc.ExitCode)" }

# 4. Clean up
Remove-Item $WebRtcMsi, $Exe -Force -ErrorAction SilentlyContinue
Write-Host "[+] Teams with AVD optimizations and Meeting Add-in installed." -ForegroundColor Green