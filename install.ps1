# Define the repository URL and files to download
$repoUrl = "https://raw.githubusercontent.com/diyrex/diskdruid/main"

# List of files to download
$filesToDownload = @(
    "install.ps1",
    "DiskDruid.ps1",
    "Modules/Banner.psm1",
    "Modules/CreatePartition.psm1",
    "Modules/ExtendPartition.psm1",
    "Modules/ShrinkPartition.psm1",
    "Modules/DeletePartition.psm1",
    "Modules/ChangeDriveLetter.psm1"
   
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
    # Construct the URL and output path
    $url = "$repoUrl/$file"
    
    # Determine output path and create necessary subdirectories
    $output = Join-Path -Path $destinationPath -ChildPath $file
    $outputDir = Split-Path -Path $output -Parent
    
    if (-Not (Test-Path -Path $outputDir)) {
        New-Item -Path $outputDir -ItemType Directory -Force
        Write-Output "Created directory: $outputDir"
    }

    # Download the file
    Write-Host "Downloading $url to $output"
    Invoke-WebRequest -Uri $url -OutFile $output -ErrorAction Stop
}

Write-Output "All files have been downloaded."

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
