# ==== CONFIGURATION ====
$scriptPath = "C:\ProgramData\Scripts\FSLogix-Cleanup.ps1"
$taskName = "Daily_FSLogix_Profile_Cleanup"
$taskTime = "18:00"  # 6:00 PM daily

# ==== CREATE SCRIPT FILE ====
$scriptContent = @'
$localProfilePath = 'C:\Users'
$fslogixProfilePath = 'C:\Users'
$daysOld = 1
$cutoffDate = (Get-Date).AddDays(-$daysOld)

function Is-SystemProfile($folderName) {
    return $folderName -in @('Public', 'Default', 'Default User', 'All Users', 'Administrator')
}

Write-Output "Starting profile cleanup on $(hostname) at $(Get-Date)..."

Get-ChildItem -Path $localProfilePath -Directory | ForEach-Object {
    if (-not (Is-SystemProfile $_.Name)) {
        if ($_.LastWriteTime -lt $cutoffDate) {
            try {
                Write-Output "Removing local profile folder: $($_.FullName)"
                Remove-Item -Path $_.FullName -Recurse -Force
            } catch {
                Write-Warning "Failed to remove $_.FullName: $_"
            }
        }
    }
}

if (Test-Path $fslogixProfilePath) {
    Get-ChildItem -Path $fslogixProfilePath -Directory | Where-Object {
        $_.LastWriteTime -lt $cutoffDate
    } | ForEach-Object {
        try {
            Write-Output "Removing FSLogix profile folder: $($_.FullName)"
            Remove-Item -Path $_.FullName -Recurse -Force
        } catch {
            Write-Warning "Failed to remove $_.FullName: $_"
        }
    }
}

Write-Output "Profile cleanup complete at $(Get-Date)."
'@

# Save script to file
if (-not (Test-Path "C:\ProgramData\Scripts")) { New-Item -ItemType Directory -Path "C:\ProgramData\Scripts" }
$scriptContent | Out-File -FilePath $scriptPath -Encoding UTF8 -Force

# ==== CREATE SCHEDULED TASK ====
# Define time trigger
$trigger = New-ScheduledTaskTrigger -Daily -At ([datetime]::Parse($taskTime))

# Run as SYSTEM
$principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest

# Define action
$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -File `"$scriptPath`""

# Register task
Register-ScheduledTask -TaskName $taskName -Trigger $trigger -Action $action -Principal $principal -Force

Write-Host "Scheduled task '$taskName' created to run daily at $taskTime." -ForegroundColor Green
