#!/bin/sh

#INITIALISATION
azSAKey="DefaultEndpointsProtocol=https;AccountName=cgghubdgconf01;AccountKey=zq/mRQumKZe/p5aUavFs23nvx/XdGhlXNT7KdH23yDEChN25d7PyodBDYGgp//ZmdjJztHrS3dWnBGucSgJnGQ==;EndpointSuffix=core.windows.net"
ddShare="datadog"
ddDir="TestPierre"
tempDir="/tmp/tmpDirGit"
gitRepo="https://github.com/deppierre/Datadog"
checkFolder=`az storage directory exists -s $ddShare -n $ddDir --connection-string $azSAKey --output tsv`

function_github_sync () {
	rm -rf $tempDir
	git clone $gitRepo $tempDir
	az storage file upload-batch -d $ddShare/$ddDir -s $tempDir --connection-string $azSAKey 
}

if [ "$checkFolder" = "False" ]
then
	echo "Temp folder :: $ddDir is missing"
	az storage directory create -s $ddShare -n $ddDir --connection-string $azSAKey
	function_github_sync
else
	echo "Temp folder :: $ddDir already exist"
fi
