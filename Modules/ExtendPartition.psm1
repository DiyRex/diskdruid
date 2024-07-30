function Extend-Partition {
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

    # Get the disk object
    $disk = Get-Disk -Number $DiskNumber

    # Get the total and used size of the disk
    $totalSize = $disk.Size
    $usedSpace = ($disk | Get-Partition | Measure-Object -Property Size -Sum).Sum

    # Calculate the free space on the disk
    $freeSpace = $totalSize - $usedSpace

    # Calculate the current size of the partition and the available space for extension
    $currentPartitionSizeGB = [math]::Round($partition.Size / 1GB, 2)
    $freeSpaceGB = [math]::Round(($freeSpace / 1GB) - 1, 2)

    Write-Host "Current size of partition $PartitionNumber- $currentPartitionSizeGB GB"
    Write-Host "Available space on disk $DiskNumber for extension- $freeSpaceGB GB"

    # Prompt for the size to extend the partition
    do {
        $extendSizeGB = Read-Host "Enter the size to extend the partition in GB (up to $freeSpaceGB GB)"
        $extendSizeGB = [double]$extendSizeGB
        if ($extendSizeGB -gt $freeSpaceGB) {
            Write-Host "Insufficient space. Please enter a size less than or equal to $freeSpaceGB GB."
        }
    } while ($extendSizeGB -gt $freeSpaceGB)

    Try {
        # Set ErrorActionPreference to SilentlyContinue to suppress error messages
        $ErrorActionPreference = "SilentlyContinue"

        # Extend the partition
        Resize-Partition -DiskNumber $DiskNumber -PartitionNumber $PartitionNumber -Size (($currentPartitionSizeGB + $extendSizeGB) * 1GB) -ErrorAction Stop

        Write-Host "Partition $PartitionNumber extended successfully by $extendSizeGB GB."
    } Catch {
        # Restore ErrorActionPreference in case of an error
        $ErrorActionPreference = "Continue"
        Write-Host "Failed to extend the partition. Error- $_"
    } finally {
        # Restore ErrorActionPreference
        $ErrorActionPreference = "Continue"
    }
}

Export-ModuleMember -Function Extend-Partition
