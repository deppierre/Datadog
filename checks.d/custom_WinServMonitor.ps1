# List of Services to Ignore. 
$Ignore=@(
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
$pattern = "has not registered for any start or stop triggers"
$flag = $false
# Get list of services that are not running, not in the ignore list and set to automatic 
$Services=Get-WmiObject Win32_Service -Filter "NOT DisplayName like 'Sync Host%'" | Where {$_.StartMode -eq 'Auto' -and $Ignore -notcontains $_.DisplayName -and $_.State -ne 'Running'} 
 
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
	            $strResultError=$strResultError.substring(0,$strResultError.length - 2)
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
