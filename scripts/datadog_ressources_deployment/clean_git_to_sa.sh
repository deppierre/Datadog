#!/bin/sh

#INITIALISATION VARIABLES

#!!A MODIFIER!!#
azSAKey="/home/admin_pdepretz/clouddrive/storage_account_list.csv"
#!!!!!!!!!!!!!!#

ddShare="datadog"
ddDir="github"

#FUNCTION DELETE
function_purge_dir () {
	checkFolder=`az storage directory exists -s $ddShare -n $1 --account-name $2 --account-key "$3" --output tsv`
	if [ "$checkFolder" = "True" ]
	then
		for dir in `az storage file list -s $ddShare/$1 --account-name $2 --account-key "$3" --output json | jq '.[] | select (.type == "dir") | .name' -r`; do
			delDir=`az storage directory delete -s $ddShare -n $1/$dir --account-name $2 --account-key "$3" --output tsv`
				if [ "$delDir" = "True" ]
				then
					echo "--info: directory $1/$dir deleted"
				else
					echo "--error: directory $1/$dir not deleted"
				fi
		done
	else
		echo "--info: directory $1 doesn't exist"
	fi
}

#MAIN
if [ -f $azSAKey ]
then
	while IFS=";" read -r accName keyNum
	do
		#YAML
		##DELETE FILES
		echo "info: clean all files"
		az storage file delete-batch -s $ddShare/$ddDir --pattern '*' --account-name $accName --account-key "$keyNum"

		#FOLDER
		##AD
		echo "-clean dir inside : $accName : $ddDir/active_directory"
		function_purge_dir "$ddDir/active_directory" $accName "$keyNum"
		###DEFAULT
		echo "-clean dir inside : $accName : $ddDir/default"
		function_purge_dir "$ddDir/default" $accName "$keyNum"
		###IIS
		echo "-clean dir inside : $accName : $ddDir/iis"
		function_purge_dir "$ddDir/iis" $accName "$keyNum"
		###sep
		echo "-clean dir inside : $accName : $ddDir/sep"
		function_purge_dir "$ddDir/sep" $accName "$keyNum"
		###sqlserver
		echo "-clean dir inside : $accName : $ddDir/sqlserver"
		function_purge_dir "$ddDir/sqlserver" $accName "$keyNum"
		###wsus
		echo "-clean dir inside : $accName : $ddDir/wsus"
		function_purge_dir "$ddDir/wsus" $accName "$keyNum"
		###mab
		echo "-clean dir inside : $accName : $ddDir/mab"
		function_purge_dir "$ddDir/mab" $accName "$keyNum"

		#CONF
		echo "-clean dir inside : $accName : $ddDir"
		function_purge_dir "$ddDir" $accName "$keyNum"
	done < $azSAKey
else
	echo "error: no storage account list"
fi
