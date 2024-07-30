Import-Module "$PSScriptRoot/Modules/Banner.psm1"
Import-Module "$PSScriptRoot/Modules/DeletePartition.psm1"
Import-Module "$PSScriptRoot/Modules/CreatePartition.psm1"
Import-Module "$PSScriptRoot/Modules/ExtendPartition.psm1"
Import-Module "$PSScriptRoot/Modules/ShrinkPartition.psm1"
Import-Module "$PSScriptRoot/Modules/ChangeDriveLetter.psm1"


function Show-Menu {
    Clear-Host
    Show-Banner
    Write-Host "---Main Menu---"
    Write-Host ""
    Write-Host "1: List Disks"
    Write-Host "2: List Partitions"
    Write-Host "3: Manage Partitions"
    Write-Host "4: Exit"
    Write-Host ""
}

function Option1 {
    Clear-Host
    Show-Banner
    Write-Host "You selected Option 1"
    Write-Host ""
    Write-Host "Available Disks:"

    # Retrieve the available disks
    $disks = Get-Disk

    if ($disks.Count -eq 0) {
        Write-Host "No disks found."
    } else {
        # Display the disks in a table format with left alignment
        $disks | Format-Table -Property `
            @{Label="Disk Number"; Expression={("{0,-11}" -f $_.Number)}},
            @{Label="Status"; Expression={"{0,-8}" -f $_.OperationalStatus}},
            @{Label="Size (GB)"; Expression={"{0,-9}" -f [Math]::Round($_.Size/1GB, 2)}},
            @{Label="Partition Style"; Expression={"{0,-15}" -f $_.PartitionStyle}},
            @{Label="Friendly Name"; Expression={"{0,-12}" -f $_.FriendlyName}} -AutoSize
    }
}



function Option2 {
    Clear-Host
    Show-Banner
    Write-Host "You selected Option 2"
    Write-Host ""
    
    # Prompt the user for a disk number
    $diskNumber = Read-Host "Please enter the disk number"

    # Convert input to integer
    $diskNumber = [int]$diskNumber

    # Retrieve partitions on the specified disk
    $partitions = Get-Partition -DiskNumber $diskNumber

    if ($partitions.Count -eq 0) {
        Write-Host "No partitions found on disk $diskNumber."
    } else {
        Write-Host "Available Partitions on Disk ${diskNumber}:"

        # Display the partitions in a table format with left alignment
        $partitions | Format-Table -Property `
            @{Label="Partition Number"; Expression={"{0,-18}" -f $_.PartitionNumber}},
            @{Label="Drive Letter"; Expression={"{0,-12}" -f $_.DriveLetter}},
            @{Label="Size (GB)"; Expression={"{0,-9}" -f [Math]::Round($_.Size/1GB, 2)}},
            @{Label="Offset (MB)"; Expression={"{0,-11}" -f [Math]::Round($_.Offset/1MB, 2)}} -AutoSize
    }
}



function CreatePartition {
    Clear-Host
    Show-Banner
    Write-Host "Create a new Partition"
    $diskNumber = Read-Host "Please enter the disk number"
    $diskNumber = [int]$diskNumber
    Create-Partition -DiskNumber $diskNumber
    # Show-Menu
}

function ManagePartitions {
    Clear-Host
    Show-Banner
    Write-Host "Manage Existing Partitions"

    # Prompt the user for a disk number
    $diskNumber = Read-Host "Please enter the disk number"

    # Convert input to integer
    $diskNumber = [int]$diskNumber

    # Retrieve partitions on the specified disk
    $partitions = Get-Partition -DiskNumber $diskNumber

    if ($partitions.Count -eq 0) {
        Write-Host "No partitions found on disk $diskNumber."
        return
    }

    # Prompt the user for a partition number
    $partitionNumber = Read-Host "Please enter the partition number"

    # Convert input to integer
    $partitionNumber = [int]$partitionNumber

    # Retrieve the selected partition
    $selectedPartition = $partitions | Where-Object { $_.PartitionNumber -eq $partitionNumber }

    if ($null -eq $selectedPartition) {
        Write-Host "Partition $partitionNumber not found on disk $diskNumber."
        return
    }

    # Display the selected partition details
    Write-Host ""
    Write-Host "Disk - $diskNumber Partition No - $partitionNumber DriveLetter - $($selectedPartition.DriveLetter) Size - $([Math]::Round($selectedPartition.Size/1GB, 2))GiB"

    # Assuming these values are obtained from the system
    $availableExtendSize = 30  # in GB, replace with actual logic if needed
    $availableShrinkSize = 40  # in GB, replace with actual logic if needed

    # Display the menu
    Write-Host "1. Extend Partition (available $availableExtendSize GB)"
    Write-Host "2. Shrink Partition (available $availableShrinkSize GB)"
    Write-Host "3. Delete Partition"
    Write-Host "4. Change Drive Letter (Current: $($selectedPartition.DriveLetter))"
    Write-Host "5. Back to Main Menu"
    Write-Host ""

    # Get user selection
    $selection = Read-Host "Please select an option"

    # Handle the user selection
    switch ($selection) {
        1 {
            Write-Host "You selected to extend the partition."
            $diskNumber = [int]$diskNumber
            $partitionNumber = [int]$partitionNumber
            Extend-Partition -DiskNumber $diskNumber -PartitionNumber $partitionNumber
        }
        2 {
            Write-Host "You selected to shrink the partition."
            $diskNumber = [int]$diskNumber
            $partitionNumber = [int]$partitionNumber
            Shrink-Partition -DiskNumber $diskNumber -PartitionNumber $partitionNumber
        }
        3 {
            Write-Host "You selected to delete the partition."
            $diskNumber = [int]$diskNumber
            $partitionNumber = [int]$partitionNumber
            Delete-Partition -DiskNumber $diskNumber -PartitionNumber $partitionNumber
        }
        4 {
            Write-Host "You selected to change the drive letter."
            $diskNumber = [int]$diskNumber
            $partitionNumber = [int]$partitionNumber
            Set-DriveLetter -DiskNumber $diskNumber -PartitionNumber $partitionNumber
        }
        5 {
            Write-Host "Returning to the main menu..."
            Show-Menu
        }
        default {
            Write-Host "Invalid selection."
            ManagePartitions
        }
    }
}

function Option3 {
    Clear-Host
    Show-Banner
    Write-Host "You selected Option 3"
    
    Write-Host "1. Create new Partition"
    Write-Host "2. Manage Existing Partitions"
    Write-Host "3. Back to Main Menu"

    $choice = Read-Host "Please select an option"

    switch ($choice) {
        1 { CreatePartition }
        2 { ManagePartitions }
        3 { Show-Menu }
        default {
            Write-Host "Invalid selection."
            Option3
        }
    }
}

function Main {
    do {
        Show-Menu
        $choice = Read-Host "Please select an option (1-4)"

        switch ($choice) {
            1 { Option1 }
            2 { Option2 }
            3 { Option3 }
            4 { Write-Host "Exiting..."; exit }
            default { Write-Host "Invalid selection, please try again." }
        }

        # Ask to return to the main menu
        if ($choice -ne 4) {
            $null = Read-Host "Press Enter to return to the main menu"
        }

    } while ($choice -ne 4)
}

Main
