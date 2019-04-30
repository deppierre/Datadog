#!/bin/sh

#CREATION DES STORAGE ACCOUNT POUR DEPLOIEMENT DD AGENT

#CG-Transit-SUB Azure 
#az account set --subscription f75404bd-6924-4d71-8d70-b8cb8d3b6c52
#az storage account create -g CGG-HUB-RG-INF01 -n cgghubdgconf01 --kind StorageV2 --location francecentral --sku Standard_LRS

#CGP-PRD-SUB Azure
#az account set --subscription 59d0136c-36de-44d6-b737-841c187b72b7
#az storage account create -g CGP-PRD-RG-INF01 -n cgpprddgconf01 --kind StorageV2 --location francecentral --sku Standard_LRS

#CGL-DEV-SUB Azure
az account set --subscription ffb5a733-2560-42f4-a299-c73abf406e4a --output tsv
az storage account create -g CGL-DEV-RG-INF01 -n cgldevdgconf01 --kind StorageV2 --location francecentral --sku Standard_LRS --output tsv

#CGL-UAT-SUB Azure
az account set --subscription ee95aa77-106b-440b-8883-2444d8f3bc4c --output tsv
az storage account create -g CGL-UAT-RG-INF01 -n cgluatdgconf01 --kind StorageV2 --location francecentral --sku Standard_LRS --output tsv

#CGL-PRD-SUB Azure 
az account set --subscription aba80970-1aa7-448a-860e-d309b4738c7f --output tsv
az storage account create -g CGL-PRD-RG-INF01 -n cglprddgconf01 --kind StorageV2 --location francecentral --sku Standard_LRS --output tsv

#CGP-UAT-SUB Azure
az account set --subscription 03c795e0-8a46-47eb-ba0b-10c661d9469f --output tsv
az storage account create -g CGP-UAT-RG-INF01 -n cgpuatdgconf01 --kind StorageV2 --location francecentral --sku Standard_LRS --output tsv

#CGP-DEV-SUB Azure
az account set --subscription 87b720b3-fcb9-4bd5-8047-816efd16c823 --output tsv
az storage account create -g CGP-DEV-RG-INF01 -n cgpdevdgconf01 --kind StorageV2 --location francecentral --sku Standard_LRS --output tsv