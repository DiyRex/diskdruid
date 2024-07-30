function Show-Banner {
    $banner = @"
______ _     _   ______            _     _  
|  _  (_)   | |  |  _  \          (_)   | | 
| | | |_ ___| | _| | | |_ __ _   _ _  __| | 
| | | | / __| |/ / | | | '__| | | | |/ _  | 
| |/ /| \__ \   <| |/ /| |  | |_| | | (_| | 
|___/ |_|___/_|\_\___/ |_|   \__,_|_|\__,_| 
                                                                                   
Windows Server Disk Management Utility Tool (Powershell)

                                  Developed By DiyRex :)
"@

    Write-Host $banner -ForegroundColor Cyan
}

Export-ModuleMember -Function Show-Banner