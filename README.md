## TELECHARGEMENT DU PACKAGE
Il faut télécharger le paquet directement depuis la [source : ICI](https://s3.amazonaws.com/ddagent-windows-stable/datadog-agent-6-latest.amd64.msi)  

## ETAPE 1 : INSTALLATION
Exécuter simplement le fichier :
```
datadog-agent-6-latest.amd64.msi /qn
```
La fichier de configuration va maintenant être remplacé.

## ETAPE 2 : CONFIGURATION
Le dossier racine (= root) d’installation de Datadog (sur Windows) est le suivant : **C:\ProgramData\Datadog**  
Nous allons mettre à jour deux types de fichier de configuration (=yaml) :
 - [datadog.yaml](agent_datadog/datadog.yaml) liée à la configuration générale de l'agent Datadog, cf 2.1/
 - conf liées aux différentes intégrations sur notre VM (MSSQL, AD, ...), cf 2.2/  

**attention :** à chaque modification d'un fichier conf (.yaml), il faut redemarrer l'agent pour la prise en compte

### 2.1/ Fichier datadog.yaml
Il faut mettre à jour le fichier `C:\ProgramData\Datadog\datadog.yaml` en écrasant son contenu par [datadog.yaml](agent_datadog/datadog.yaml)

### 2.2/ Fichiers conf.yaml
#### 2.2.1 - Cas par défaut : Microsoft Windows Server
Ces fichiers de configuration sont la base d'une VM "standard" :
 - conf Event Viewer : [conf.yaml](agent_datadog/conf.d/default/win32_event_log.d/conf.yaml)
 - conf wmi : [conf.yaml](agent_datadog/conf.d/default/wmi_check.d/conf.yaml)  
 - conf script client : [custom_WinServMonitor.ps1](agent_datadog/checks.d/custom_WinServMonitor.ps1)  
 - conf script client : [custom_WinServMonitor.py](agent_datadog/checks.d/custom_WinServMonitor.py)  
 - conf script client : [custom_WinServMonitor.yaml](agent_datadog/conf.d/default/custom_WinServMonitor.yaml)  

#### 2.2.2 - MSSQL
Déposer les fichiers suivants : 
 - conf sql server : [conf.yaml](agent_datadog/conf.d/sqlserver/sqlserver.d/conf.yaml)
 - conf Event Viewer : [conf.yaml](agent_datadog/conf.d/sqlserver/win32_event_log.d/conf.yaml)
 - conf wmi : [conf.yaml](agent_datadog/conf.d/sqlserver/wmi_check.d/conf.yaml)
 - conf script client : [custom_WinServMonitor.ps1](agent_datadog/checks.d/custom_WinServMonitor.ps1)
 - conf script client : [custom_WinServMonitor.py](agent_datadog/checks.d/custom_WinServMonitor.py)
 - conf script client : [custom_WinServMonitor.yaml](agent_datadog/conf.d/sqlserver/custom_WinServMonitor.yaml)  

##### - Création d'un utilisateur
```sql
USE MASTER
CREATE LOGIN datadog WITH PASSWORD = '<password>', CHECK_POLICY= OFF;
CREATE USER datadog FOR LOGIN datadog;
GRANT SELECT on sys.dm_os_performance_counters to datadog;
GRANT VIEW SERVER STATE to datadog;
```
##### - Modification de l'authentification
```
EXEC xp_instance_regwrite N'HKEY_LOCAL_MACHINE', N'Software\Microsoft\MSSQLServer\MSSQLServer', N'LoginMode', REG_DWORD, 2
```
##### - Redémarrage du moteur MSSQL
Pour la prise en compte des modifications de paramètrage, il faut redémarrer l’instance SQL Server :
```
net stop MSSQLSERVER
net start MSSQLSERVER
```

#### 2.2.3 - Contrôleur de domaine
Déposer les fichiers suivants : 
 - conf Active Directory : [conf.yaml](agent_datadog/conf.d/active_directory/active_directory.d/conf.yaml)
 - conf Event Viewer : [conf.yaml](agent_datadog/conf.d/active_directory/win32_event_log.d/conf.yaml)
 - conf wmi : [conf.yaml](agent_datadog/conf.d/active_directory/wmi_check.d/conf.yaml)
 - conf service : [conf.yaml](agent_datadog/conf.d/active_directory/windows_service.d/conf.yaml)
 - conf script client : [custom_WinServMonitor.ps1](agent_datadog/checks.d/custom_WinServMonitor.ps1)
 - conf script client : [custom_WinServMonitor.py](agent_datadog/checks.d/custom_WinServMonitor.py)
 - conf script client : [custom_WinServMonitor.yaml](agent_datadog/conf.d/active_directory/custom_WinServMonitor.yaml)  
 
#### 2.2.4 - Serveur Linux HAPROXY
Déposer les fichiers suivants : 
 - conf check TCP Datadog : [conf.yaml](other/proxy/tcp_check.d/conf.yaml)
 - conf haproxy : [conf.yaml](other/proxy/haproxy.d/conf.yaml)
 
#### 2.2.5 - Windows Server Update Services - WSUS
Déposer les fichiers suivants : 
 - conf Event Viewer : [conf.yaml](agent_datadog/conf.d/wsus/win32_event_log.d/conf.yaml)
 - conf wmi : [conf.yaml](agent_datadog/conf.d/wsus/wmi_check.d/conf.yaml)  
 - conf service : [conf.yaml](agent_datadog/conf.d/wsus/windows_service.d/conf.yaml)
 - conf script client : [custom_WinServMonitor.ps1](agent_datadog/checks.d/custom_WinServMonitor.ps1)
 - conf script client : [custom_WinServMonitor.py](agent_datadog/checks.d/custom_WinServMonitor.py)
 - conf script client : [custom_WinServMonitor.yaml](agent_datadog/conf.d/wsus/custom_WinServMonitor.yaml)  
 
#### 2.2.6 - Microsoft Azure Backup - MAB
Déposer les fichiers suivants : 
 - conf Event Viewer : [conf.yaml](agent_datadog/conf.d/mab/win32_event_log.d/conf.yaml)
 - conf wmi : [conf.yaml](agent_datadog/conf.d/mab/wmi_check.d/conf.yaml)
 - conf service : [conf.yaml](agent_datadog/conf.d/mab/windows_service.d/conf.yaml)
 - conf script client : [custom_WinServMonitor.ps1](agent_datadog/checks.d/custom_WinServMonitor.ps1)  
 - conf script client : [custom_WinServMonitor.py](agent_datadog/checks.d/custom_WinServMonitor.py)   
 - conf script client : [custom_WinServMonitor.yaml](agent_datadog/conf.d/mab/custom_WinServMonitor.yaml)  
 
#### 2.2.7 - Symantec Endpoint Protection - SEP
Déposer les fichiers suivants : 
 - conf Event Viewer : [conf.yaml](agent_datadog/conf.d/sep/win32_event_log.d/conf.yaml)
 - conf wmi : [conf.yaml](agent_datadog/conf.d/sep/wmi_check.d/conf.yaml)
 - conf service : [conf.yaml](agent_datadog/conf.d/sep/windows_service.d/conf.yaml)
 - conf script client : [custom_WinServMonitor.ps1](agent_datadog/checks.d/custom_WinServMonitor.ps1)  
 - conf script client : [custom_WinServMonitor.py](agent_datadog/checks.d/custom_WinServMonitor.py)   
 - conf script client : [custom_WinServMonitor.yaml](agent_datadog/conf.d/sep/custom_WinServMonitor.yaml) 
 
 ## ETAPE 3 : VERIFICATION
Pour vérifier le statut des intégrations d'un agent local, ou pour vérifier le bon fonctionnement de l'agent en général, saisir la commande suivante dans .cmd
```
"C:\Program Files\Datadog\Datadog Agent\embedded\agent.exe" status
```
Par exemple je veux vérifier ce qui est envoyé pour une intégration de type "MSSQL" :
```
    sqlserver (1.8.1)
    -----------------
      Instance ID: sqlserver:9967a41920590b6f [[32mOK[0m]
      Total Runs: 166
      Metric Samples: Last Run: 75, Total: 12,388
      Events: Last Run: 0, Total: 0
      Service Checks: Last Run: 1, Total: 166
      Average Execution Time : 1.116s

      Instance ID: sqlserver:dbb08d75c0c639aa [[32mOK[0m]
      Total Runs: 167
      Metric Samples: Last Run: 57, Total: 9,475
      Events: Last Run: 0, Total: 0
      Service Checks: Last Run: 1, Total: 167
      Average Execution Time : 56ms
```
Je peux voir qu'il y a deux instances qui sont monitorés avec un statut "OK" et dans les deux cas l'agent remonte :
- des métrics
- aucun events
- vérification du fonctionnement d'un service

Autre exemple : 
```
"C:\Program Files\Datadog\Datadog Agent\embedded\agent.exe" check custom_WinServMonitor
```
Permet de vérifier que l'intégration [custom_WinServMonitor.yaml](agent_datadog/conf.d/sep/custom_WinServMonitor.yaml) fonctionne correctement

## SUPERVISION SUR AZURE PaaS
#### 1.1 - Azure backup 
Datadog ne propose pas nativement une supervision des backups générés dans Azure backup.  
Une solution a été trouvé en appelant l'API Datadog depuis Azure.  
Cette solution repose sur deux composants :
 - Azure Event hub : c'est un service de streaming qui permet de collecter des logs, les stocker et les mettre à disposition d'autres services qui seront les "consumers".  
 Le script d'installation des Hubs est [ici](scripts/event_hub/deploy_event_hub.ps1)
 - Azure Function apps : ce service permet d'éxécuter du code sans serveur applicatif, appelé aussi "serverless". C'est en fait le "consumer" qui va venir lire les logs stockés dans un event hub pour les envoyer à Datadog.  
 Le code source est [ici](scripts/event_hub/CGP_PRD_FCT_DDP01.js)
