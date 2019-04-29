#!/bin/sh

azSAKey="<a completer>"
ddShare="datadog"
ddDir="TestPierre"

function_purge_dir () {
	checkFolder=`az storage directory exists -s $ddShare/$ddDir -n $1  --connection-string $azSAKey --output tsv`
	if [ "$checkFolder" = "True" ]
	then
		for dir in `az storage file list -s $ddShare/$ddDir/$1 --connection-string $azSAKey --output json | jq '.[] | select (.type == "dir") | .name' -r`; do
			delDir=`az storage directory delete -s $ddShare/$ddDir/$1 -n $dir --connection-string $azSAKey --output tsv`
				if [ "$delDir" = "True" ]
				then
					echo "info: directory $1/$dir deleted"
				else
					echo "error: directory $1/$dir not deleted"
				fi
		done
	else
		echo "info: directory $1 doesn't exist"
	fi
}

#YAML
##DELETE FILES
echo "info: clean all files"
az storage file delete-batch -s $ddShare/$ddDir --pattern '*' --connection-string $azSAKey

##FOLDER
###AD
function_purge_dir "conf.d/active_directory"
###DEFAULT
function_purge_dir "conf.d/default"
###IIS
function_purge_dir "conf.d/iis"
###sep
function_purge_dir "conf.d/sep"
###sqlserver
function_purge_dir "conf.d/sqlserver"
###wsus
function_purge_dir "conf.d/wsus"

#CONF
function_purge_dir "conf.d"

#ROOT
az storage directory delete -s $ddShare/$ddDir -n conf.d --connection-string $azSAKey --output none
az storage directory delete -s $ddShare/$ddDir -n checks.d --connection-string $azSAKey --output none