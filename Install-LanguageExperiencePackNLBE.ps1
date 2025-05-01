<#
Version: Number : 1.0
Author: PinkElephant
Script: Install-LanguageExperiencePackNL.ps1
Description: Install Language Pack during Task Sequence
#>

$exitCode = 0

#Set variables:
#Company name
$CompanyName = "PinkElephant"
# The language we want as new default. Language tag can be found here: https://learn.microsoft.com/en-us/windows-hardware/manufacture/desktop/available-language-packs-for-windows
$language = "nl-BE"

if (![System.Environment]::Is64BitProcess)
{
     # start new PowerShell as x64 bit process, wait for it and gather exit code and standard error output
    $sysNativePowerShell = "$($PSHOME.ToLower().Replace("syswow64", "sysnative"))\powershell.exe"

    $pinfo = New-Object System.Diagnostics.ProcessStartInfo
    $pinfo.FileName = $sysNativePowerShell
    $pinfo.Arguments = "-ex bypass -file `"$PSCommandPath`""
    $pinfo.RedirectStandardError = $true
    $pinfo.RedirectStandardOutput = $true
    $pinfo.CreateNoWindow = $true
    $pinfo.UseShellExecute = $false
    $p = New-Object System.Diagnostics.Process
    $p.StartInfo = $pinfo
    $p.Start() | Out-Null

    $exitCode = $p.ExitCode

    $stderr = $p.StandardError.ReadToEnd()

    if ($stderr) { Write-Error -Message $stderr }
}
else
{
    # start logging to TEMP in file "scriptname".log
    Start-Transcript -Path "$env:TEMP\$($(Split-Path $PSCommandPath -Leaf).ToLower().Replace(".ps1",".log"))" | Out-Null

    
   
     try
     {
        # Install an additional language pack including FODs
	"Installing languagepack"
	Install-Language $language -ErrorAction Stop

	# Add registry key
	"Add registry key"
	REG add "HKLM\Software\$CompanyName\LanguagePack\v1.0" /v "SetLanguage-$language" /t REG_DWORD /d 1
     }
     catch
     {   
         Write-Error -Message "Could not install language pack" -Category OperationStopped
         $exitCode = -1
     }



    Stop-Transcript | Out-Null
}

exit $exitCode