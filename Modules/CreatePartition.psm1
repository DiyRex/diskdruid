function Create-Partition {
    param (
        [int]$DiskNumber
    )
    $isPartitionCreated = $false
    # Get the disk object
    $disk = Get-Disk -Number $DiskNumber

    # Get the total size and used size of the disk
    $totalSize = $disk.Size

    # Calculate the used space by summing the sizes of all partitions
    $partitions = Get-Partition -DiskNumber $DiskNumber
    $usedSpace = ($partitions | Measure-Object -Property Size -Sum).Sum

    # Calculate the free space
    $freeSpace = $totalSize - $usedSpace

    # Convert the free space to GB for easier input
    $freeSpaceGBx = $freeSpace / 1GB
    $freeSpaceGB = $freeSpaceGBx - 1

    Write-Host "Available space on disk $DiskNumber- $freeSpaceGB GB"

    # Prompt for partition size
    do {
        $partitionSizeGB = Read-Host "Enter the size of the new partition in GB (up to $freeSpaceGB GB)"
        $partitionSizeGB = [double]$partitionSizeGB
        if ($partitionSizeGB -gt $freeSpaceGB) {
            Write-Host "Insufficient space. Please enter a size less than or equal to $freeSpaceGB GB."
        }
    } while ($partitionSizeGB -gt $freeSpaceGB)

    # Prompt for volume name
    $volumeName = Read-Host "Enter a name for the volume"

    # Create the partition and format it
   try {
    # Get the disk information and available free space
    $disk = Get-Disk -Number $diskNumber
    $availableSpaceGB = ($disk | Get-Partition | Where-Object IsActive -eq $false | Measure-Object Size -Sum).Sum / 1GB
    
    if ($availableSpaceGB -lt $partitionSizeGB) {
        Write-Host "Not enough available capacity. Available space: $availableSpaceGB GB."
        return
    }

    # Create the partition and automatically assign a drive letter
    
    Try {
    # Set ErrorActionPreference to SilentlyContinue to suppress error messages
    $ErrorActionPreference = "SilentlyContinue"
    $partition = New-Partition -DiskNumber $diskNumber -Size ($partitionSizeGB * 1GB) -AssignDriveLetter -ErrorAction Stop
    # Restore ErrorActionPreference
    $ErrorActionPreference = "Continue"
    $isPartitionCreated = $true
    # Display the assigned drive letter
    $assignedDriveLetter = $partition.DriveLetter
    Write-Host "Assigned drive letter: $assignedDriveLetter"

    # Prompt the user for a drive letter, default to the automatically assigned one
    $desiredDriveLetter = Read-Host -Prompt "Enter a drive letter for the partition (default: $assignedDriveLetter)"
    if ([string]::IsNullOrWhiteSpace($desiredDriveLetter)) {
        $desiredDriveLetter = $assignedDriveLetter
    }

    # Check if the drive letter is already in use
    $drive = Get-Volume -DriveLetter $desiredDriveLetter -ErrorAction SilentlyContinue
    if ($drive -ne $null -and $desiredDriveLetter -ne $assignedDriveLetter) {
        Write-Host "Drive letter $desiredDriveLetter is already in use. Please choose another letter."
        return
    }

    # Assign the specific drive letter if different from the default
    if ($desiredDriveLetter -ne $assignedDriveLetter) {
        Set-Partition -DiskNumber $diskNumber -PartitionNumber $partition.PartitionNumber -NewDriveLetter $desiredDriveLetter
    }

    Start-Sleep -Seconds 1

    # Format the partition to NTFS and set the volume label
    Format-Volume -DriveLetter $desiredDriveLetter -FileSystem NTFS -NewFileSystemLabel $volumeName -Confirm:$false
     if ($isPartitionCreated) {
            Write-Host "Partition created successfully with drive letter $desiredDriveLetter and volume name $volumeName."
            $isPartitionCreated = $true
        } else {
            Write-Host "Failed to create the partition. Please try again."
            $isPartitionCreated = $false
            return
        }
    } Catch {
    # Restore ErrorActionPreference in case of an error
    $ErrorActionPreference = "Continue"
    Write-Host "Exceed the available space"
    return
    }
    
    
}
catch {
        Write-Host "An error occurred: $_"
    }
}

Export-ModuleMember -Function Create-Partition
