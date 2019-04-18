#!/bin/sh

#INITIALISATION
az account clear

#CONNEXION
echo "################################"
echo "Connection with Azure ..."
az login -u pierre.depretz@easyteam.fr -p PdZ0787# -o tsv
if [ $? -eq 0 ]
then
	echo "Connection: OK"
else
	echo "Connection: KO"
	exit
fi

#COLLECTE DES SUBSCRIPTIONS
accList=`az account list --query "[?state=='Enabled'].{ subName: name, subId: id }" -o json`
accListMaxSize=`echo $accList | jq length`

#ANALYE, ETAPE 1 : LES SUBSCRIPTIONS
for ((i=0;i<$accListMaxSize;i++));
do
	echo "################################"
	echo "Connection with subscription : $(echo $accList | jq -r '.['$i'] .subName')"
	echo "..."
	subId=`echo $accList | jq -r '.['$i'] .subId'`
	az account set -s $subId
	
	#COLLECTE DES VMs
	vmList=`az vm list --show-details --query "[?powerState=='VM running' && storageProfile.osDisk.osType=='Windows'].{vmName: name, vmId: id, vmRg: resourceGroup}" -o json`
	vmListMaxSize=`echo $vmList | jq length`

	#ANALYE, ETAPE 2 : LES VMS
	if [ $vmListMaxSize -gt 0 ]
	then
		for ((j=0;j<$vmListMaxSize;j++));
		do
			vmName=`echo $vmList | jq -r '.['$j'] .vmName'`
			vmRg=`echo $vmList | jq -r '.['$j'] .vmRg'`
			echo "#Virtual Machine $j - name: $vmName, RG: $vmRg"
			
			#ANALYE, ETAPE 3 : LES SERVICES
			echo "Result: "
			az vm run-command invoke -g $vmRg -n $vmName --command-id RunPowerShellScript --scripts "@custom_WinServMonitor.ps1" -o json | jq -r '.value[0].message'
		done
	else
		echo "Warning: Aucune VM dans cette subscription"
	fi
done
echo "################################"
