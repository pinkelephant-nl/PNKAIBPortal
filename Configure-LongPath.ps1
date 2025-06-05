try {
    # Define the registry path and value
    $regPath = "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem"
    $valueName = "LongPathsEnabled"
    $valueData = 1

    # Check if running as administrator
    if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        throw "This script must be run as Administrator."
    }

    # Set the registry value
    Set-ItemProperty -Path $regPath -Name $valueName -Value $valueData

    Write-Host "Long path support enabled successfully."
}
catch {
    Write-Error "An error occurred: $_"
}
