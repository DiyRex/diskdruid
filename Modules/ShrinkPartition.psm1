function Shrink-Partition {
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

    # Get the current partition size
    $currentPartitionSizeGB = [math]::Round($partition.Size / 1GB, 2)

    # Get the volume associated with the partition
    $volume = Get-Volume -DriveLetter $partition.DriveLetter

    if ($volume -eq $null) {
        Write-Host "No volume found for partition $PartitionNumber on disk $DiskNumber."
        return
    }

    # Get the free space available within the volume
    $freeSpaceInPartition = $volume.SizeRemaining

    # Calculate the maximum shrinkable size
    $maxShrinkSizeGB = [math]::Round($freeSpaceInPartition / 1GB, 2) - 1

    Write-Host "Current size of partition $PartitionNumber- $currentPartitionSizeGB GB"
    Write-Host "Maximum shrinkable size- $maxShrinkSizeGB GB"

    # Prompt for the size to shrink the partition
    do {
        $shrinkSizeGB = Read-Host "Enter the size to shrink the partition in GB (up to $maxShrinkSizeGB GB)"
        $shrinkSizeGB = [double]$shrinkSizeGB
        if ($shrinkSizeGB -gt $maxShrinkSizeGB) {
            Write-Host "Insufficient space. Please enter a size less than or equal to $maxShrinkSizeGB GB."
        }
    } while ($shrinkSizeGB -gt $maxShrinkSizeGB)

    Try {
        # Set ErrorActionPreference to SilentlyContinue to suppress error messages
        $ErrorActionPreference = "SilentlyContinue"

        # Shrink the partition
        Resize-Partition -DiskNumber $DiskNumber -PartitionNumber $PartitionNumber -Size (($currentPartitionSizeGB - $shrinkSizeGB) * 1GB) -ErrorAction Stop

        Write-Host "Partition $PartitionNumber shrunk successfully by $shrinkSizeGB GB."
    } Catch {
        # Restore ErrorActionPreference in case of an error
        $ErrorActionPreference = "Continue"
        Write-Host "Failed to shrink the partition. Error- $_"
    } finally {
        # Restore ErrorActionPreference
        $ErrorActionPreference = "Continue"
    }
}

Export-ModuleMember -Function Shrink-Partition
