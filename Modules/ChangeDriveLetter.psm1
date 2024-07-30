function Set-DriveLetter {
    param (
        [int]$DiskNumber,
        [int]$PartitionNumber
    )

    # Get the partition object
    $partition = Get-Partition -DiskNumber $DiskNumber -PartitionNumber $PartitionNumber

    if ($partition -eq $null) {
        Write-Host "No partition found with the number $PartitionNumber on disk $DiskNumber."
        return
    }

    # Display the current drive letter
    $currentDriveLetter = $partition.DriveLetter
    Write-Host "Current drive letter- $currentDriveLetter"

    # Prompt for a new drive letter
    do {
        $newDriveLetter = Read-Host "Enter a new drive letter (e.g., D, E)"
        $newDriveLetter = $newDriveLetter.ToUpper()  # Convert to upper case to standardize

        # Check if the new drive letter is already in use
        $existingDrive = Get-Volume -DriveLetter $newDriveLetter -ErrorAction SilentlyContinue

        if ($existingDrive -ne $null) {
            Write-Host "Drive letter $newDriveLetter is already in use. Please choose another letter."
        }
    } while ($existingDrive -ne $null)

    # Confirm the change
    $confirmation = Read-Host "Are you sure you want to change the drive letter to $newDriveLetter? (Y/N)"
    if ($confirmation.ToUpper() -eq "Y") {
        Try {
            # Set the new drive letter
            Set-Partition -DiskNumber $DiskNumber -PartitionNumber $PartitionNumber -NewDriveLetter $newDriveLetter -ErrorAction Stop
            Write-Host "Drive letter changed successfully to $newDriveLetter."
        } Catch {
            Write-Host "Failed to change the drive letter. Error- $_"
        }
    } else {
        Write-Host "Drive letter change cancelled."
    }
}

Export-ModuleMember -Function Set-DriveLetter
