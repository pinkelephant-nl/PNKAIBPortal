# Define repo
$Repo = "The-Virtual-Desktop-Team/Virtual-Desktop-Optimization-Tool"

# Get latest release metadata from GitHub API
$Release = Invoke-RestMethod -Uri "https://api.github.com/repos/$Repo/releases/latest"

# Use zipball_url (Source code zip)
$DownloadUrl = $Release.zipball_url

# Define paths
$DownloadPath = "C:\VDOT\VDOT.zip"
$ExtractPath  = "C:\VDOT"

# Ensure target folder exists
if (!(Test-Path $ExtractPath)) {
    New-Item -ItemType Directory -Path $ExtractPath | Out-Null
}

# Download latest source code zip
Invoke-WebRequest -Uri $DownloadUrl -OutFile $DownloadPath

# Unblock and extract
Unblock-File -Path $DownloadPath
Expand-Archive -Path $DownloadPath -DestinationPath $ExtractPath -Force

# Move into the extracted folder (it will have a random suffix)
$SubFolder = Get-ChildItem $ExtractPath | Where-Object { $_.PSIsContainer } | Sort-Object LastWriteTime -Descending | Select-Object -First 1
Set-Location $SubFolder.FullName

# Allow script execution for this session
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process -Force

# Run the optimization script
.\Windows_VDOT.ps1 -Optimizations  -Optimizations Autologgers,DefaultUserSettings,DiskCleanup,NetworkOptimizations,ScheduledTasks,Services,WindowsMediaPlayer -Verbose -AcceptEULA -ErrorAction SilentlyContinue
