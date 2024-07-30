# Define the repository URL and files to download
$repoUrl = "https://raw.githubusercontent.com/diyrex/diskdruid/main"
$filesToDownload = @(
    "install.ps1",
    "DiskDruid.ps1",
    "Modules/CreatePartition.psm1",
    "Modules/ExtendPartition.psm1",
    "Modules/ShrinkPartition.psm1",
    "Modules/DeletePartition.psm1",
    "Modules/ChangeDriveLetter.psm1",
    "Modules/Banner.psm1"
)

# Define the local path to save the files
$destinationPath = "C:\GlobalScripts"

# Create the script directory if it doesn't exist
if (-Not (Test-Path -Path $destinationPath)) {
    New-Item -Path $destinationPath -ItemType Directory -Force
    Write-Output "Created directory: $destinationPath"
}

# Download each file
foreach ($file in $filesToDownload) {
    $url = "$repoUrl/$file"
    $output = Join-Path -Path $destinationPath -ChildPath (Split-Path $file -Leaf)
    
    Write-Host "Downloading $url to $output"
    Invoke-WebRequest -Uri $url -OutFile $output -ErrorAction Stop
}

Write-Host "All files have been downloaded successfully."

# Add the script directory to the system PATH if it's not already there
$path = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::Machine)
if ($path -notlike "*$destinationPath*") {
    [System.Environment]::SetEnvironmentVariable("Path", "$path;$destinationPath", [System.EnvironmentVariableTarget]::Machine)
    Write-Output "The directory $destinationPath has been added to the system PATH."
} else {
    Write-Output "The directory $destinationPath is already in the system PATH."
}

# Set the execution policy to RemoteSigned for the current user
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force

Write-Output "Setup completed. Run diskdruid to run menu, You may need to restart your PowerShell session for changes to take effect."
