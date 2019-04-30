#!/bin/sh

azSAKey="<à modifier>"
ddShare="datadog"
ddDir="github"

function_purge_dir () {
	checkFolder=`az storage directory exists -s $ddShare -n $1 --connection-string $azSAKey --output tsv`
	if [ "$checkFolder" = "True" ]
	then
		for dir in `az storage file list -s $ddShare/$1 --connection-string $azSAKey --output json | jq '.[] | select (.type == "dir") | .name' -r`; do
			delDir=`az storage directory delete -s $ddShare -n $1/$dir --connection-string $azSAKey --output tsv`
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

#YAML
##DELETE FILES
echo "info: clean all files"
az storage file delete-batch -s $ddShare/$ddDir --pattern '*' --connection-string $azSAKey

#FOLDER
##AD
echo "-clean dir inside : $ddDir/active_directory"
function_purge_dir "$ddDir/active_directory"
###DEFAULT
echo "-clean dir inside : $ddDir/default"
function_purge_dir "$ddDir/default"
###IIS
echo "-clean dir inside : $ddDir/iis"
function_purge_dir "$ddDir/iis"
###sep
echo "-clean dir inside : $ddDir/sep"
function_purge_dir "$ddDir/sep"
###sqlserver
echo "-clean dir inside : $ddDir/sqlserver"
function_purge_dir "$ddDir/sqlserver"
###wsus
echo "-clean dir inside : $ddDir/wsus"
function_purge_dir "$ddDir/wsus"
###mab
echo "-clean dir inside : $ddDir/mab"
function_purge_dir "$ddDir/mab"

#CONF
echo "-clean dir inside : $ddDir"
function_purge_dir "$ddDir"
