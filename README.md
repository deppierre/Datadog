## INSTALLATION & CONFIGURATION DE L’AGENT
### TELECHARGEMENT DU PACKAGE
Il faut télécharger le paquet directement depuis la source, l’url est la suivante : https://s3.amazonaws.com/ddagent-windows-stable/datadog-agent-6-latest.amd64.msi 

### ETAPE 1 : INSTALLATION
Lors de l’installation vous devrez passer en paramètre les paramètres suivants :
-	**APIKEY** : [6750241e300506cae9d137fc27c156c5] Obligatoire, c’est la clé API de notre portail Datadog Easyteam.
-	**PROCESS_ENABLED** : [TRUE] permet de scanner en temps réel les processus
-	**APM_ENABLED** : [FALSE]
-	**HOSTNAME** : ici il faut préciser le hostname de l’hôte sur lequel va être installé l’agent
-	**TAGS** : ici il faut compléter les tags suivants :
    - **CLIENT** : CARMIGNAC

#### EXEMPLE
Voici la chaîne d’installation complète :
```
datadog-agent-6-latest.amd64.msi /qn PROCESS_ENABLED=TRUE APM_ENABLED=FALSE HOSTNAME="<hostname>" TAGS="CLIENT:CARMIGNAC" APIKEY="6750241e300506cae9d137fc27c156c5"
```
### ETAPE 2 : CONFIGURATION
Le répertoire d’installation de la conf de Datadog (sur Windows) est le suivant : **C:\ProgramData\Datadog**
Il y a plusieurs à mettre fichiers à mettre à jour selon le périmètre applicatif

##### Fichier obligatoire : Fichier datadog.yaml
```
dd_url: https://app.datadoghq.eu
log_level: warning
apm_config:
  enabled: false
logs_enabled: true
logs_config:
  logs_dd_url: "agent-intake.logs.datadoghq.eu:443"
process_config:
  enabled: true
  process_dd_url: https://process.datadoghq.eu
```

##### Fichiers conf.yaml
Il y a plusieurs fichiers de configuration à déposer selon le périmètre applicatif
##### Cas 1 : Microsoft Windows Server
Déposer le fichier suivant :
```
conf.d\win32_event_log.d\conf.yaml
```
##### Cas 2 : Microsoft SQL Server
Déposer le fichier suivant :
```
conf.d\sqlserver.d\conf.yaml
```
###### Création d'un utilisateur
```
USE MASTER
CREATE LOGIN datadog WITH PASSWORD = 'Datadog123456789#', CHECK_POLICY= OFF;
CREATE USER datadog FOR LOGIN datadog;
GRANT SELECT on sys.dm_os_performance_counters to datadog;
GRANT VIEW SERVER STATE to datadog;
```
###### Modification de l'authentification
```
EXEC xp_instance_regwrite N'HKEY_LOCAL_MACHINE', N'Software\Microsoft\MSSQLServer\MSSQLServer', N'LoginMode', REG_DWORD, 2
```
###### REDEMARRAGE DE SQL SERVER
Pour la prise en compte des modifications de paramètrage, il faut redémarrer l’instance SQL Server :
```
net stop MSSQLSERVER
net start MSSQLSERVER
```