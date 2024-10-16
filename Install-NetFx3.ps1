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

function Install-NetFx3 {
Param(
[Parameter(Mandatory=$true)]
[ValidateSet("Install", "Uninstall")]
[String[]]
$Mode
)
 
If ($Mode -eq "Install")
 
{
if (Test-path .\sxs\Microsoft-Windows-NetFx3-OnDemand-Package*.cab)
{
#Offline Installer
Enable-WindowsOptionalFeature -Online -FeatureName 'NetFx3' -Source .\sxs\ -NoRestart -LimitAccess
 
}
else
{
#Online installer
Enable-WindowsOptionalFeature -Online -FeatureName 'NetFx3' -NoRestart
}
 
}
 
If ($Mode -eq "Uninstall")
 
{
 
Disable-WindowsOptionalFeature -Online -FeatureName 'NetFx3' -Remove -NoRestart
 
}

}

Install-NetFx3 -Mode Install