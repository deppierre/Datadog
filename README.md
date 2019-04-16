## TELECHARGEMENT DU PACKAGE
Il faut télécharger le paquet directement depuis la source, l’url est la suivante : https://s3.amazonaws.com/ddagent-windows-stable/datadog-agent-6-latest.amd64.msi 

## ETAPE 1 : INSTALLATION
Exécuter simplement le fichier :
```
datadog-agent-6-latest.amd64.msi /qn
```
La fichier de configuration va maintenant être remplacé.

## ETAPE 2 : CONFIGURATION
Le dossier racine (= root) d’installation de Datadog (sur Windows) est le suivant : **C:\ProgramData\Datadog**  
Nous allons mettre à jour deux types de fichier de configuration (=yaml) :
- yaml lié à la configuration générale de l'agent Datadog, cf 2.1/
- yaml liés aux différentes intégrations sur notre VM (MSSQL, AD, ...), cf 2.2/

### 2.1/ Fichier datadog.yaml
Il faut mettre à jour le fichier `C:\ProgramData\Datadog\datadog.yaml` en écrasant son contenu par [datadog.yaml](datadog.yaml)

### 2.2/ Fichiers conf.yaml
#### 2.2.1 - Cas par défaut : Microsoft Windows Server
Ces fichiers de configuration sont la base d'une VM "standard" :
- fichier [conf.yaml](win32_event_log.d/conf_default.yaml) pour remonter le contenu de event_viewer
- fichier [conf.yaml](wmi_check.d/conf.yaml) pour remonter des métriques custom  
- fichier [conf.yaml](windows_service.d/conf_default.yaml) pour surveiller les services  
~~- fichier [conf.yaml](ntp.d/conf.yaml) pour se synchroniser avec le serveur temps de l'active directory~~

En complément il y a un ou plusieurs fichiers de configuration à déposer selon le périmètre applicatif

#### 2.2.2 - MSSQL
Déposez les fichiers suivants : 
 - conf sql server : [conf.yaml](sqlserver.d/conf.yaml)
 - conf wmi : [conf.yaml](wmi_check.d/conf.yaml) pour remonter des métriques custom 

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

#### 2.2.3 - Contrôleurs de domaines
Déposez les fichiers suivants : 
 - conf Active Directory : [conf.yaml](active_directory.d/conf.yaml)
 - conf Event Viewer : [conf.yaml](win32_event_log.d/conf_ad.yaml) (il doit être renommé en conf.yaml pour être pris en compte)
 - conf Service : [conf.yaml](windows_service.d/conf_ad.yaml)
 - conf wmi : [conf.yaml](wmi_check.d/conf.yaml) pour remonter des métriques custom  
 
#### 2.2.4 - Serveur Linux HAPROXY
Déposez les fichiers suivants : 
 - conf check TCP Datadog : [conf.yaml](tcp_check.d/conf.yaml)
 - conf haproxy : [conf.yaml](haproxy.d/conf.yaml)
 
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

### 2.3/ Supervision des services managés Azure (PaaS)
#### 2.3.1 - Azure backup 
Datadog ne propose pas nativement une supervision des backups générés dans Azure backup.  
Une solution a été trouvé en appelant l'API Datadog depuis Azure.  
Cette solution repose sur deux composants :
 - Azure Event hub : c'est un service de streaming qui permet de collecter des logs, les stocker et les mettre à disposition d'autres services qui seront les "consumers".  
 Le script d'installation des Hubs est [ici](scripts/deploy_event_hub.ps1)
 - Azure Function apps : ce service permet d'éxécuter du code sans serveur applicatif, appelé aussi "serverless". C'est en fait le "consumer" qui va venir lire les logs stockés dans un event hub pour les envoyer à Datadog.  
 Le code source est [ici](CGP_PRD_FCT_DDP01.js)
