function Delete-Partition {
    param (
        [int]$DiskNumber,
        [int]$PartitionNumber
    )

    # Get the disk object
    $disk = Get-Disk -Number $DiskNumber

    # Get the partition to delete
    $partition = Get-Partition -DiskNumber $DiskNumber | Where-Object { $_.PartitionNumber -eq $PartitionNumber }

    if ($null -ne $partition) {
        try {
            # Confirm before deleting the partition
            $confirmation = Read-Host "Are you sure you want to delete partition $PartitionNumber on disk $DiskNumber? (Y/N)"
            if ($confirmation -eq 'Y') {
                # Remove the partition
                Remove-Partition -DiskNumber $DiskNumber -PartitionNumber $PartitionNumber -Confirm:$false
                Write-Host "Partition $PartitionNumber on disk $DiskNumber has been deleted."
            } else {
                Write-Host "Operation canceled by the user."
            }
        } catch {
            Write-Host "An error occurred while deleting the partition: $_"
        }
    } else {
        Write-Host "Partition $PartitionNumber not found on disk $DiskNumber."
    }
}

Export-ModuleMember -Function Delete-Partition
