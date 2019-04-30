#!/bin/sh

#INITIALISATION VARIABLES
azSAKey="/home/admin_pdepretz/clouddrive/storage_account_list.csv"
ddShare="datadog"
ddDir="github"
tempDir="/tmp/tmpDirGit"
gitRepo="https://github.com/deppierre/datadog"

#MAIN
#VERIFICATION DOSSIER GIT LOCAL
if [ -d "$tempDir" ]
then
	echo "Local temp dir :: $tempDir already exist"
	cd $tempDir
	git pull
else
	echo "Local temp dir :: $tempDir is missing"
	git clone $gitRepo $tempDir
fi

if [ -f $azSAKey ]
then
	while IFS=";" read -r accName keyNum
	do
		#VERIFICATION DU SHARE
		checkShare=`az storage share exists -n $ddShare --account-name $accName --account-key $keyNum --output tsv`
		if [ "$checkShare" = "False" ]
		then
			echo "Target share :: $ddShare is missing"
			az storage share create --name $ddShare --quota 2048 --account-name $accName --account-key "$keyNum" --output tsv
		else
			echo "Target share :: $ddShare already exist"
		fi
		
		#VERIFICATION DOSSIER DESTINATION
		checkFolder=`az storage directory exists -s $ddShare -n $ddDir --account-name "$accName" --account-key "$keyNum" --output tsv`
		if [ "$checkFolder" = "False" ]
		then
			echo "Target dir :: $ddDir is missing"
			az storage directory create -s $ddShare -n $ddDir --account-name $accName --account-key "$keyNum" --output tsv
		else
			echo "Target dir :: $ddDir already exist"
		fi
		
		#UPLOAD BATCH
		az storage file upload-batch -d $ddShare/$ddDir -s $tempDir/agent_datadog --account-name $accName --account-key "$keyNum" --output table
	done < $azSAKey
else
	echo "error: no storage account list"
fi