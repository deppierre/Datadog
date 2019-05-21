# ==============================================================================================
# Script             : checkping_onprem.ps1
# Description        : surveillance de l'express route permettant la connexion OnPrem avec Azure
# Paramètres         : IP des machines OnPrem (valeurs par défaut) format : "X.X.X.X,Y.Y.Y.Y,Z.Z.Z.Z" / API KEY (valeur par défaut) "XXXXXXXX"
# Retour             : Aucun
# Commentaires       : Aucun
# ------------------------------------------------------------------------------
# Historique :
# Date       Auteur              Description
# ---------- ------------------- -----------------------------------------------
# 13/05/2019 PDE-Easyteam            Création du script.
# ==============================================================================================

# valeurs par défaut

$azSAKey = "E:\scripts\easyteam\pde_gge\storage_account_list.csv"
$ddShare = "datadog"
$ddDir = "github"
$tempDir = "E:\scripts\easyteam\pde_gge\temp"
$livraison = "E:\scripts\easyteam\pde_gge\livraison"

#MAIN
#VERIFICATION DOSSIER GIT LOCAL

if(Test-Path $tempDir){
	Write-Host "Information :: temp dir :: $tempDir"
	Remove-Item "$tempDir\*" -Force -Recurse
	
	if(Test-Path $livraison){
		Write-Host "Information :: delivery dir :: $livraison"
		
		$newLivraison = Get-Childitem $livraison\*.zip | sort CreationTime | select -expandproperty FullName -last 1
		
		if($newLivraison){
			Write-Host "Information :: new file detected :: $newLivraison "
			
			Add-Type -assembly "system.io.compression.filesystem"
			[io.compression.zipfile]::ExtractToDirectory($newLivraison, $tempDir)
			
			if(Test-Path $azSAKey){
				Write-Host "Information :: AZ Storage account file :: $azSAKey"
				Get-Content $azSAKey | ForEach-Object {
					$storageAccount = $_.split(";")
					$storageAccountName = $storageAccount[0]
					$storageAccountKey = $storageAccount[1]
					
					$checkShare = az storage share exists -n $ddShare --account-name $storageAccountName --account-key $storageAccountKey --output tsv
					$checkFolder = az storage directory exists -s $ddShare -n $ddDir --account-name $storageAccountName --account-key $storageAccountKey --output tsv
					
					if($checkShare -ne "True"){
						Write-Host "Information :: $ddShare is missing"
						az storage share create --name $ddShare --quota 2048 --account-name $storageAccountName --account-key $storageAccountKey --output none
					}

					if($checkFolder -ne "True"){
						Write-Host "Information :: $ddDir is missing"
						az storage directory create -s $ddShare -n $ddDir --account-name $storageAccountName --account-key $storageAccountKey --output none
					}
					
					#UPLOAD YAML
					az storage file upload-batch -d $ddShare/$ddDir -s $tempDir/agent_datadog --account-name $storageAccountName --account-key $storageAccountKey --output table
				}
			}
			else{
				Write-Host "Error :: $azSAKey is missing"
				Exit
			}
		}
		
		else{
			Write-Host "Information :: 0 file detected"
			Exit
		}
	}
	else{
		Write-Host "Error :: $livraison is missing"
		Exit
	}
}
else{
	Write-Host "Error :: $tempDir is missing"
	Exit
}