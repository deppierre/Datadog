# Test-Automatic-Services.ps1 
# 
# Written by Aaron Wurthmann (aaron (AT) wurthmann (DOT) com) 
#        http://irl33t.com 
# 
# If you edit please keep my name as an original author and 
# keep me apprised of the changes, see email address above. 
# This code may not be used for commercial purposes. 
# You the executor, runner, user accept all liability. 
# This code comes with ABSOLUTELY NO WARRANTY. 
# You may redistribute copies of the code under the terms of the GPL v2. 
# ----------------------------------------------------------------------- 
# 2010.11.09 ver 2.0 
# 
# Summary: 
# Checks services set to Automatic and insures they are running. 
# Ignores an array of services such as Performance Logs and Alerts  
# which are set to Automatic but turns themselves off. 
# 
# If an Automatic service is not Running and not in the Ignore array 
# an attempt to restart the service is made. If the service is restarted 
# a Warning is returned. If the service could not be restarted a 
# Critical error is returned. 
# ----------------------------------------------------------------------- 
# Usage: 
# This script does not require any input parameters. 
#    For Nagios NRPE/NSClient++ usage add the following line to the  
#    NSC.ini file after placing this script in Scripts subdirectory. 
#    check_services=cmd /c echo scripts\Test-Automatic-Services.ps1 | powershell.exe -command - 
#    NOTE: The trailing - is required. 
# ----------------------------------------------------------------------- 
# Orgin: 
# This script (or one like it) was originally written by ronald van vugt 
#     (ronald.van.vugt@vanderlet.nl) 
# I took the vbscript\wsf version that he wrote and converted it to  
# PowerShell while adding an array of ignored services and making other 
# slight improvements such as adjusting the WMI query to only return  
# stopped services. 
# ----------------------------------------------------------------------- 
# Notes:  
# Unlike the majority of my scripts this script has rather verbose 
# comments in it. This is both to pay homage to the original author as  
# well as to aid others with learning PowerShell. The original version 
# of this script, the vbscript/wsf version was a vbscript learning 
# experience for myself and the basis of my vbscripts to follow. 
# ----------------------------------------------------------------------- 
# 30/04/2019 - CFR(Easyteam) - Adding the server exclusion list
# 10/05/2019 - CFR(Easyteam) - Add the uptime check (exit if less than 10 minutes)
# -----------------------------------------------------------------------

#Uptime check
$os = Get-WmiObject win32_operatingsystem
$uptime = ((Get-Date) - ($os.ConvertToDateTime($os.lastbootuptime))).TotalMinutes
if ($uptime -lt 10)
	{
	write-host 'OK - All automatic started services are running' 
    exit 0
	}


#get servername
$ServerName = $env:COMPUTERNAME

#set dedicated exclusion list for each server
$IgnoreSpec = switch -exact ($ServerName) {
    "ServernameXXX" {
        ''       
    }
}
# List of Global Services to Ignore. 
$IgnoreGlobal=@(
    'Volume Shadow Copy',
    'Downloaded Maps Manager',
    'IaasVmProvider',
    'Microsoft .NET Framework NGEN v4.0.30319_X64', 
    'Microsoft .NET Framework NGEN v4.0.30319_X86', 
    'Multimedia Class Scheduler', 
    'Performance Logs and Alerts', 
    'SBSD Security Center Service', 
    'Shell Hardware Detection', 
    'Software Protection', 
    'TPM Base Services',
    'Remote Registry';
)
#Global filter
$filter="NOT DisplayName like 'Sync Host%'";

$pattern = "has not registered for any start or stop triggers"
$flag = $false

#concatanation
$ExcludeList = $IgnoreGlobal + $IgnoreSpec

# Get list of services that are not running, not in the ignore list and set to automatic 
$Services=Get-WmiObject Win32_Service -Filter $filter| Where {$_.StartMode -eq 'Auto' -and $ExcludeList -notcontains $_.DisplayName -and $_.State -ne 'Running'} 
# If any services were found fitting the above description... 
if ($Services) {
    try{
            # Loop through each service in services to concatenate all DisplayName
            ForEach ($Service in $Services) { 
                if ([regex]::IsMatch((sc.exe qtriggerinfo $Service.Name),$pattern)){
		            $strResultError=$strResultError+$Service.DisplayName+";"
                    $flag = $true
                }
            }
            if($flag){
	            $strResultError=$strResultError.substring(0,$strResultError.length - 1)
	            write-host $strResultError 
                exit 2
            }else{
	            write-host 'OK - All automatic started services are running' 
	            exit 0
            }
    }
    catch{
        Write-Host "Exception executing script: " $_.exception.message
        exit 2
    }
} 
else {
	write-host 'OK - All automatic started services are running' 
	exit 0
}
