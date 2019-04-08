#!/bin/bash

#VARIABLES
DATETIME=`date +%"d%m%Y_%H%M"`
hostsFile=/root/dev/EMS_SUP_Snippet/PDE_AWS_EC2/hosts/hosts_$DATETIME
playbookAnsible=/root/dev/EMS_SUP_Snippet/PDE_AWS_EC2/playbooks/installDatadogAgent.yaml

#ETAPE 1 : ALIMENTATION DU FICHIER HOSTS
echo "Etape 1 : collecte des hosts"
echo "[windows_datadog_agent]" > $hostsFile

for i in `aws ec2 describe-instances --profile pde_certif --filters "Name=tag:DATADOG_INSTALL,Values=0" "Name=instance-state-name,Values=running" --query 'Reservations[*].Instances[*].{IP:PublicIpAddress}' | jq '.[]'  | jq '.[]' | jq ".IP" --raw-output`
do echo "$i" >> $hostsFile
done

echo "" >> $hostsFile
echo "[windows_datadog_agent:vars]
ansible_user = Administrator
ansible_password = XXXXXX
ansible_connection = winrm
ansible_port = 5595
ansible_winrm_transport = basic" >> $hostsFile

#ETAPE 2 : DEPLOIEMENT DU PLAYBOOK
echo "Etape 2 : Deploiement du Playbook"
ansible-playbook -i $hostsFile $playbookAnsible