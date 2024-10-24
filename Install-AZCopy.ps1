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


# Azure Image Builder Portal Integration Inline Commands

# Inline command to download and extract AZCopy
New-Item -Type Directory -Path 'c:\\' -Name ImageBuilder,
invoke-webrequest -uri 'https://aka.ms/downloadazcopy-v10-windows' -OutFile 'c:\\ImageBuilder\\azcopy.zip',
Expand-Archive 'c:\\ImageBuilder\\azcopy.zip' 'c:\\ImageBuilder',
copy-item 'C:\\ImageBuilder\\azcopy_windows_amd64_*\\azcopy.exe\\' -Destination 'c:\\ImageBuilder'
