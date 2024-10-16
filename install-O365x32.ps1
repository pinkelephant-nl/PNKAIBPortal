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


[CmdletBinding()]
param(
    # Use a existing config file
    [String]
    $ConfigurationXMLFile,
    # Path where we will store our install files and our XML file
    [String]
    $OfficeInstallDownloadPath = 'C:ScriptsOffice365Install',
    # Clean up our install files
    [Switch]
    $CleanUpInstallFiles = $False
)
begin {
    function Set-XMLFile {
        # XML data that will be used for the download/install
        # Example config below generated from https://config.office.com/
        # To use your own config, just replace <Configuration> to </Configuration> with your xml config file content.
        # Notes:
        #  "@ can not have any character after it
        #  @" can not have any spaces or character before it.
        $OfficeXML = [XML]@"
<Configuration ID="ece0670a-73d6-4bc8-9576-452049a2f333">
  <Add OfficeClientEdition="32" Channel="MonthlyEnterprise">
    <Product ID="O365ProPlusRetail">
      <Language ID="en-us" />
      <ExcludeApp ID="Groove" />
      <ExcludeApp ID="Lync" />
      <ExcludeApp ID="Bing" />
      <ExcludeApp ID="Bing" />
      <ExcludeApp ID="Bing" />
    </Product>
    <Product ID="LanguagePack">
      <Language ID="en-us" />
      <Language ID="nl-nl" />
      <Language ID="fr-fr" />
      <Language ID="de-de" />
      <Language ID="it-it" />
      <Language ID="pt-pt" />
      <Language ID="es-es" />
      <ExcludeApp ID="Bing" /> 
    </Product>
	<Product ID="ProofingTools">
      <Language ID="nl-nl" />
      <Language ID="en-us" />
      <Language ID="fr-fr" />
      <Language ID="de-de" />
      <Language ID="it-it" />
      <Language ID="pt-pt" />
      <Language ID="es-es" />
    </Product>
  </Add>
  <Updates Enabled="TRUE" />
  <RemoveMSI />
  <AppSettings>
    <User Key="software\microsoft\office\16.0\common\toolbars" Name="screentipscheme" Value="2" Type="REG_DWORD" App="office16" Id="L_ShowScreenTips" />
    <User Key="software\microsoft\office\16.0\excel\options" Name="defaultformat" Value="51" Type="REG_DWORD" App="excel16" Id="L_SaveExcelfilesas" />
    <User Key="software\microsoft\office\16.0\powerpoint\options" Name="defaultformat" Value="27" Type="REG_DWORD" App="ppt16" Id="L_SavePowerPointfilesas" />
    <User Key="software\microsoft\office\16.0\word\options" Name="defaultformat" Value="" Type="REG_SZ" App="word16" Id="L_SaveWordfilesas" />
  </AppSettings>
  <Display Level="NONE" AcceptEULA="TRUE" />
</Configuration>
"@
        #Save the XML file
        $OfficeXML.Save("$OfficeInstallDownloadPathOfficeInstall.xml")
      
    }
    function Get-ODTURL {
    
        [String]$MSWebPage = Invoke-RestMethod 'https://www.microsoft.com/en-us/download/confirmation.aspx?id=49117'
    
        $MSWebPage | ForEach-Object {
            if ($_ -match 'url=(https://.*officedeploymenttool.*.exe)') {
                $matches[1]
            }
        }
    
    }
    function Test-IsElevated {
        $id = [System.Security.Principal.WindowsIdentity]::GetCurrent()
        $p = New-Object System.Security.Principal.WindowsPrincipal($id)
        if ($p.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator))
        { Write-Output $true }
        else
        { Write-Output $false }
    }
}
process {
    $VerbosePreference = 'Continue'
    $ErrorActionPreference = 'Stop'
    if (-not (Test-IsElevated)) {
        Write-Error -Message "Access Denied. Please run with Administrator privileges."
        exit 1
    }
    $CurrentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    if (!($CurrentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))) {
        Write-Warning 'Script is not running as Administrator'
        Write-Warning 'Please rerun this script as Administrator.'
        exit 1
    }
    if (-Not(Test-Path $OfficeInstallDownloadPath )) {
        New-Item -Path $OfficeInstallDownloadPath -ItemType Directory | Out-Null
    }
    if (!($ConfigurationXMLFile)) {
        Set-XMLFile
    }
    else {
        if (!(Test-Path $ConfigurationXMLFile)) {
            Write-Warning 'The configuration XML file is not a valid file'
            Write-Warning 'Please check the path and try again'
            exit 1
        }
    }
    $ConfigurationXMLFile = "$OfficeInstallDownloadPathOfficeInstall.xml"
    $ODTInstallLink = Get-ODTURL
    #Download the Office Deployment Tool
    Write-Verbose 'Downloading the Office Deployment Tool...'
    try {
        Invoke-WebRequest -Uri $ODTInstallLink -OutFile "$OfficeInstallDownloadPathODTSetup.exe"
    }
    catch {
        Write-Warning 'There was an error downloading the Office Deployment Tool.'
        Write-Warning 'Please verify the below link is valid:'
        Write-Warning $ODTInstallLink
        exit 1
    }
    #Run the Office Deployment Tool setup
    try {
        Write-Verbose 'Running the Office Deployment Tool...'
        Start-Process "$OfficeInstallDownloadPathODTSetup.exe" -ArgumentList "/quiet /extract:$OfficeInstallDownloadPath" -Wait
    }
    catch {
        Write-Warning 'Error running the Office Deployment Tool. The error is below:'
        Write-Warning $_
        exit 1
    }
    #Run the O365 install
    try {
        Write-Verbose 'Downloading and installing Microsoft 365'
        $Silent = Start-Process "$OfficeInstallDownloadPathSetup.exe" -ArgumentList "/configure $ConfigurationXMLFile" -Wait -PassThru
    }
    Catch {
        Write-Warning 'Error running the Office install. The error is below:'
        Write-Warning $_
    }
    #Check if Office 365 suite was installed correctly.
    $RegLocations = @('HKLM:SOFTWAREMicrosoftWindowsCurrentVersionUninstall',
        'HKLM:SOFTWAREWOW6432NodeMicrosoftWindowsCurrentVersionUninstall'
    )
    $OfficeInstalled = $False
    foreach ($Key in (Get-ChildItem $RegLocations) ) {
        if ($Key.GetValue('DisplayName') -like '*Microsoft 365*') {
            $OfficeVersionInstalled = $Key.GetValue('DisplayName')
            $OfficeInstalled = $True
        }
    }
    if ($OfficeInstalled) {
        Write-Verbose "$($OfficeVersionInstalled) installed successfully!"
        shutdown.exe -r -t 60
    }
    else {
        Write-Warning 'Microsoft 365 was not detected after the install ran'
    }
    if ($CleanUpInstallFiles) {
        Remove-Item -Path $OfficeInstallDownloadPath -Force -Recurse
    }
}
end {}