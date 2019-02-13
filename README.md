## TELECHARGEMENT DU PACKAGE
Il faut télécharger le paquet directement depuis la source, l’url est la suivante : https://s3.amazonaws.com/ddagent-windows-stable/datadog-agent-6-latest.amd64.msi 

## ETAPE 1 : INSTALLATION
Lors de l’installation vous devrez passer en paramètre les paramètres suivants :
-	**APIKEY** : [ICI](https://easyteam.sharepoint.com/:t:/r/sites/easyshare/Documents%20partages/EMS/Support/DATADOG/api_key_carmignac.txt?csf=1&e=1AckAs)  , obligatoire, c’est la clé API de notre portail Datadog Easyteam.
-	**PROCESS_ENABLED** : [TRUE] permet de scanner en temps réel les processus
-	**APM_ENABLED** : [FALSE] licence non acquise
-	**HOSTNAME** : ici il faut préciser le hostname de l’hôte sur lequel va être installé l’agent
-	**TAGS** : ici il faut compléter les tags suivants :
    - **CLIENT** : CARMIGNAC

#### EXEMPLE
Voici la chaîne d’installation complète :
```
datadog-agent-6-latest.amd64.msi /qn PROCESS_ENABLED=TRUE APM_ENABLED=FALSE HOSTNAME="<hostname>" TAGS="CLIENT:CARMIGNAC" APIKEY="<APIKEY>"
```
## ETAPE 2 : CONFIGURATION
Le dossier racine (= root) d’installation de Datadog (sur Windows) est le suivant : **C:\ProgramData\Datadog**

### 1/ Fichier datadog.yaml
Il faut mettre à jour le fichier `C:\ProgramData\Datadog\datadog.yaml` en rajoutant les lignes suivantes à la fin :
```yaml
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

### 2/ Fichiers conf.yaml
#### Cas obligatoire : Microsoft Windows Server
Déposer les fichiers suivants : 
- fichier [conf.yaml](win32_event_log.d/conf.yaml) pour remonter le contenu de event_viewer
- fichier [conf.yaml](wmi_check.d/conf.yaml) pour remonter des métriques custom

Ensuite il y a un ou plusieurs fichiers de configuration à déposer selon le périmètre applicatif

## Cas 1 : MSSQL
Déposer le fichier suivant : [conf.yaml](sqlserver.d/conf.yaml)
### - Création d'un utilisateur
```sql
USE MASTER
CREATE LOGIN datadog WITH PASSWORD = '<password>, CHECK_POLICY= OFF;
CREATE USER datadog FOR LOGIN datadog;
GRANT SELECT on sys.dm_os_performance_counters to datadog;
GRANT VIEW SERVER STATE to datadog;
```
### - Modification de l'authentification
```
EXEC xp_instance_regwrite N'HKEY_LOCAL_MACHINE', N'Software\Microsoft\MSSQLServer\MSSQLServer', N'LoginMode', REG_DWORD, 2
```
### - Redémarrage du moteur MSSQL
Pour la prise en compte des modifications de paramètrage, il faut redémarrer l’instance SQL Server :
```
net stop MSSQLSERVER
net start MSSQLSERVER
```

## Cas 2 : Contrôleur de domaines
