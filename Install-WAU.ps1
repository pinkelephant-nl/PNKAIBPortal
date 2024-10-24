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

# Define the GitHub API URL for Romanitho's Winget-AutoUpdate latest release
$repoUrl = "https://api.github.com/repos/Romanitho/Winget-AutoUpdate/releases/latest"

# Create a temporary folder for downloading the MSI file
$tempFolder = New-Item -ItemType Directory -Path "$env:TEMP\WingetAutoUpdate"

# Download the latest release information from GitHub
$releaseInfo = Invoke-RestMethod -Uri $repoUrl

# Find the MSI file in the latest release assets
$msiAsset = $releaseInfo.assets | Where-Object { $_.name -like "*.msi" }

if ($null -eq $msiAsset) {
    Write-Host "Failed to find the latest MSI release for Winget-AutoUpdate."
    exit
}

# Define the download URL and the path to save the MSI file
$downloadUrl = $msiAsset.browser_download_url
$msiFile = "$tempFolder\WingetAutoUpdate.msi"

# Download the MSI file
Invoke-WebRequest -Uri $downloadUrl -OutFile $msiFile

# Install the MSI package
Start-Process msiexec.exe -ArgumentList "/i `"$msiFile`" /quiet /norestart RUN_WAU=NO UPDATESATLOGON=0 UPDATESINTERVAL=Daily USERCONTEXT=1" -Wait

# Check if the installation was successful by verifying if the WAU.exe exists in Program Files
$installPath = "C:\Program Files\Winget-AutoUpdate"
if (Test-Path "$installPath\Winget-Upgrade.ps1") {
    Write-Host "Winget-AutoUpdate has been successfully installed."
} else {
    Write-Host "Installation failed. WAU.exe not found."
}

# Clean up temporary files
Remove-Item -Recurse -Force $tempFolder
