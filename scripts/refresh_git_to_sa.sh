#!/bin/sh

#INITIALISATION VARIABLES
#SA : cgghubdgconf01
azSAKey="DefaultEndpointsProtocol=https;AccountName=cgghubdgconf01;AccountKey=zq/mRQumKZe/p5aUavFs23nvx/XdGhlXNT7KdH23yDEChN25d7PyodBDYGgp//ZmdjJztHrS3dWnBGucSgJnGQ==;EndpointSuffix=core.windows.net"
ddShare="datadog"
ddDir="TestPierre"
tempDir="/tmp/tmpDirGit"
gitRepo="https://github.com/deppierre/datadog"

#FUNCTION GIT CLONE
function_github_sync () {
	#COPIE DANS CONTAINER AZURE
	az storage file upload-batch -d $ddShare/$ddDir -s $tempDir/agent_datadog --connection-string $azSAKey --output table
}

#MAIN
#VERIFICATION DOSSIER GIT LOCAL
if [ -d "$tempDir" ]
then
	echo "Temp dir :: $tempDir already exist"
	cd $tempDir
	git pull
else
	echo "Temp dir :: $tempDir is missing"
	git clone $gitRepo $tempDir
fi

#VERIFICATION DOSSIER DESTINATION
checkFolder=`az storage directory exists -s $ddShare -n $ddDir --connection-string $azSAKey --output tsv`

if [ "$checkFolder" = "False" ]
then
	echo "Target dir :: $ddDir is missing"
	az storage directory create -s $ddShare -n $ddDir --connection-string $azSAKey
	function_github_sync
else
	echo "Target dir :: $ddDir already exist"
	function_github_sync
fi
