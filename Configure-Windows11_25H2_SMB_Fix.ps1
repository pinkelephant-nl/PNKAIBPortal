Write-Host "=== Windows 11 25H2 SMB Fix for AVD ===" -ForegroundColor Cyan

# ---------------------------------------------------------
# 1. Allow insecure guest auth (needed for NAS/legacy shares)
# ---------------------------------------------------------
Write-Host "[1/6] Enabling insecure guest auth..." -ForegroundColor Yellow
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters" `
    -Name AllowInsecureGuestAuth -Type DWord -Value 1 -Force

# ---------------------------------------------------------
# 2. Disable mandatory SMB signing (some servers don't support it)
# ---------------------------------------------------------
Write-Host "[2/6] Relaxing SMB signing requirement..." -ForegroundColor Yellow
Set-SmbClientConfiguration -RequireSecuritySignature $false -Force

# ---------------------------------------------------------
# 3. Enable SMB2/SMB3 client components (SMB1 optional)
# ---------------------------------------------------------
Write-Host "[3/6] Ensuring SMB2/3 client is enabled..." -ForegroundColor Yellow
dism /online /enable-feature /featurename:SMB1Protocol-Client /All /NoRestart | Out-Null
dism /online /enable-feature /featurename:SMB1Protocol /All /NoRestart | Out-Null

# ---------------------------------------------------------
# 4. Flush DFS, SMB, DNS, and NetBIOS caches
# ---------------------------------------------------------
Write-Host "[4/6] Flushing caches (DFS/SMB/DNS/NetBIOS)..." -ForegroundColor Yellow
ipconfig /flushdns | Out-Null
nbtstat -R | Out-Null

# ---------------------------------------------------------
# 5. Remove cached credentials that break SMB after 25H2
# ---------------------------------------------------------
Write-Host "[5/6] Clearing cached Windows credentials..." -ForegroundColor Yellow
cmdkey /list | Select-String Target | ForEach-Object {
    $target = ($_ -split ': ')[1]
    cmdkey /delete:$target
}

# ---------------------------------------------------------
# 6. Restart the Workstation service to reload SMB settings
# ---------------------------------------------------------
Write-Host "[6/6] Restarting Workstation service..." -ForegroundColor Yellow
Restart-Service LanmanWorkstation -Force

Write-Host "`n=== Finished. Try connecting to your SMB share again. ===" -ForegroundColor Green
