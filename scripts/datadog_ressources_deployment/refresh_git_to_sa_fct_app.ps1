using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)

# Init Param
$gitRepo="https://github.com/deppierre/datadog"
$ddShare = "datadog"
$ddDir = "github"

# Local temp
$azSAKey = "D:\home\site\wwwroot\HttpTrigger1\storage_account_list.csv"
$tempDir = "D:\home\site\wwwroot\HttpTrigger1\temp"

if(Test-Path $azSAKey){

    # Lecture du fichier AzSA
	Get-Content $azSAKey | ForEach-Object {

	    $storageAccount = $_.split(";")
	    $storageAccountName = $storageAccount[0]
	    $storageAccountKey = $storageAccount[1]

		# Set Context	
        $context = New-AzStorageContext -StorageAccountName $storageAccountName -StorageAccountKey $storageAccountKey
	    
        # Set Container
	    $Container  = Get-AzStorageShare -Name $ddShare -Context $context
	   			
        # Check Container(Az Share)
	    if(!$Container){
		    Write-Host "Information :: file share $ddShare is missing"
            New-AzStorageShare -Name $ddShare -Context $context
			New-AzStorageDirectory -ShareName $ddShare -Path $ddDir -Context $context
	    }
		else{
			Write-Host "Share OK"
		}

        # Init Temp Dir
        if(!(test-path $tempDir))
        {
            New-Item -ItemType Directory -Force -Path $tempDir

            # Git clone
			$command = '"D:\Program Files\Git\bin\git" clone $gitRepo $tempDir'
        }
		else{
			Set-Location -Path $tempDir

            # Git pull
			$command = '"D:\Program Files\Git\bin\git" pull'

		}

        # Sync Git
        Invoke-Expression "& $command"

        # Upload AzSA
        Set-AzStorageFileContent -ShareName $ddShare -Path $ddDir -Context $context -Source $tempDir/agent_datadog/datadog.yaml -Force
        
        # todo : etudier Start-AzStorageFileCopy
    }
}
else{
	Write-Host "Error :: source file $azSAKey is missing"
}
