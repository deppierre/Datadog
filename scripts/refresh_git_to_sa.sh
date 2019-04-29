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
	git clone $gitRepo $tempDir

	#COPIE DANS CONTAINER AZURE
	az storage file upload-batch -d $ddShare/$ddDir -s $tempDir/agent_datadog --connection-string $azSAKey --output table
}

#MAIN
#VERIFICATION DOSSIER DESTINATION
checkFolder=`az storage directory exists -s $ddShare -n $ddDir --connection-string $azSAKey --output tsv`
rm -rf $tempDir

if [ "$checkFolder" = "False" ]
then
	echo "Temp folder :: $ddDir is missing"
	az storage directory create -s $ddShare -n $ddDir --connection-string $azSAKey
	function_github_sync
else
	echo "Temp folder :: $ddDir already exist"
	function_github_sync
fi
