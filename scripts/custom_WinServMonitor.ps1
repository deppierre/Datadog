Get-WmiObject -Class Win32_Service | Select-Object Name,State,StartMode | Where-Object {$_.State -ne "Running" -and $_.StartMode -eq "Auto"}
