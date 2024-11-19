#requires -version 2
<#
.SYNOPSIS
  <Overview of script>

.DESCRIPTION
  <Brief description of script>

.PARAMETER <Parameter_Name>
    <Brief description of parameter input required. Repeat this attribute if required>

.INPUTS
  <Inputs if any, otherwise state None>

.OUTPUTS
  <Outputs if any, otherwise state None - example: Log file stored in C:\Windows\Temp\<name>.log>

.NOTES
  Version:        1.0
  Author:         <Name>
  Creation Date:  <Date>
  Purpose/Change: Initial script development
  
.EXAMPLE
  <Example goes here. Repeat this attribute for more than one example>
#>

$ProgressPreference = 'SilentlyContinue' # Suppress progress bar (makes downloading super fast)
$ConfirmPreference = 'None' # Suppress confirmation prompts

$OneDriveClient = "https://go.microsoft.com/fwlink/?linkid=844652"
$output = "$ENV:temp"  + '\OneDriveSetup.exe'
$apppath = "C:\Program Files (x86)\Microsoft OneDrive\OneDrive.exe"
$action = New-ScheduledTaskAction -Execute $apppath
$trigger = New-ScheduledTaskTrigger -Once -At (Get-Date)
 
Invoke-WebRequest -Uri $OneDriveClient -OutFile $output
Start-Process -FilePath $output -ArgumentList '/allusers', '/silent'
Start-Sleep -Seconds 60

Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "Launch OneDrive" | Out-Null
Start-ScheduledTask -TaskName "Launch OneDrive"
Start-Sleep -Seconds 5
Unregister-ScheduledTask -TaskName "Launch OneDrive" -Confirm:$false


New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" -Name OneDrive -PropertyType String -Value '"C:\Program Files\Microsoft OneDrive\OneDrive.exe" /background' -Force

# Define the registry path
$registryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services"

# Create the registry key if it doesn't exist
If (-Not (Test-Path $registryPath)) {
    New-Item -Path $registryPath -Force
}

# Create the DWORD value and set it to 1
New-ItemProperty -Path $registryPath -Name "UseShellAppRuntimeRemoteApp" -PropertyType DWORD -Value 1 -Force