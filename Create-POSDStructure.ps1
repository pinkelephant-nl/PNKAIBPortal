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

$workingdir = $env:ProgramData

$rootfolders = @(
    'POSD'
   
)

$subfolders = @(
    'Logs'
	'Winget'
	'Choco'
	'O365'
)

foreach ($root in $rootfolders) {
    New-Item $workingdir\$root -Force -ItemType Directory -Verbose
    Write-Host "$root done."
}

foreach ($sub in $subfolders) {
    New-Item $workingdir\$root\$sub -Force -ItemType Directory -Verbose
    Write-Host "$sub done."
}