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


function Install-ChocoApp {
	

# Parameters for app name and package name
Param(
    [Parameter(Mandatory=$True,Position=1)]
    [string]$app
)

<# Check for 64 bit powershell
if("$env:PROCESSOR_ARCHITEW6432" -ne "ARM64")
{
    if(Test-Path "$($env:windir)\SysNative\WindowsPowerShell\v1.0\powershell.exe")
    {
        & "$($env:windir)\SysNative\WindowsPowerShell\v1.0\powershell.exe" -ExecutionPolicy bypass -NoProfile -File "$PSCommandPath"
        exit $LASTEXITCODE
    }
}#>

$ProgressPreference = 'SilentlyContinue' # Suppress progress bar (makes downloading super fast)
$ConfirmPreference = 'None' # Suppress confirmation prompts	

# make log path and start logging
$logPath = "$env:ProgramData\POSD\Logs\$($app)"
if(!(Test-Path $logPath))
{
    mkdir $logPath
}
Start-Transcript -Path "$($logPath)\$($app)_Install.log"

# Check for chocolatey and install
$choco = "C:\ProgramData\chocolatey"
Write-Host "Checking if Chocolatey is installed on $($env:COMPUTERNAME)..."

if(!(Test-Path $choco))
{
    Write-Host "Chocolatey was not found; installing now..."
    try 
    {
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
        Write-Host "Chocolatey was successfully installed."    
    }
    catch 
    {
        $message = $_
        Write-Host "Error installing Chocolatey: $message"
    }
}
else 
{
    Write-Host "Chocolatey already installed."
}

# Check for app and install
Write-Host "Checking if $($app) is installed on $($env:COMPUTERNAME)..."
$installed = choco list | Select-String $app

if($installed -eq $null)
{
    Write-Host "$($app) was not found; installing now..."
    try 
    {
        Start-Process -Wait -FilePath "$($choco)\choco.exe" -ArgumentList "install $($app) -y"
        Write-Host "$($app) was successfully installed."    
    }
    catch 
    {
        $message = $_
        Write-Host "Error installing $($app): $message"
    }
}
else 
{
    Write-Host "$($app) is already installed."
}

Stop-Transcript

}


Install-ChocoApp -app Filezilla -Verbose