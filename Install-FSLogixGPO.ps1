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

# Define paths for ADMX and ADML destinations
$admxDestination = "C:\Windows\PolicyDefinitions"
$admlDestination = "C:\Windows\PolicyDefinitions\en-US"

# Create temporary folder for download and extraction
$tempFolder = New-Item -ItemType Directory -Path "$env:TEMP\FSLogix"

# URL for FSLogix download (modify if necessary)
$fslogixUrl = "https://aka.ms/fslogix_download"

# Path for the downloaded file
$downloadedFile = "$tempFolder\FSLogix_Setup.zip"

# Download the latest FSLogix installer
Invoke-WebRequest -Uri $fslogixUrl -OutFile $downloadedFile

# Extract the contents of the downloaded installer
Expand-Archive -LiteralPath $downloadedFile -DestinationPath $env:TEMP\extracted -Force -Verbose

# Path to the extracted ADMX and ADML files
$admxSource = "$env:TEMP\extracted\fslogix.admx"
$admlSource = "$env:TEMP\extracted\fslogix.adml"

# Check if the ADMX source exists after extraction
if (Test-Path $admxSource) {
    # Copy ADMX files to the PolicyDefinitions folder
    Copy-Item -Path "$admxSource" -Destination $admxDestination -Recurse -Force
    Write-Host "FSLogix ADMX files have been copied to $admxDestination"
} else {
    Write-Host "ADMX source folder not found. Check if the extraction was successful."
}

# Check if the ADML source exists after extraction
if (Test-Path $admlSource) {
    # Ensure the destination language folder exists
    if (-not (Test-Path $admlDestination)) {
        New-Item -ItemType Directory -Path $admlDestination
    }

    # Copy ADML files to the en-US folder
    Copy-Item -Path "$admlSource" -Destination $admlDestination -Recurse -Force
    Write-Host "FSLogix ADML files have been copied to $admlDestination"
} else {
    Write-Host "ADML source folder not found. Check if the extraction was successful."
}

# Clean up the temporary files
Remove-Item -Recurse -Force $tempFolder
