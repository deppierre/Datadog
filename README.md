## TELECHARGEMENT DU PACKAGE
Il faut télécharger le paquet directement depuis la source, l’url est la suivante : https://s3.amazonaws.com/ddagent-windows-stable/datadog-agent-6-latest.amd64.msi 

## ETAPE 1 : INSTALLATION
Lors de l’installation vous devrez passer en paramètre les paramètres suivants :
-	**APIKEY** : ![a link](https://easyteam.sharepoint.com/:t:/r/sites/easyshare/Documents%20partages/EMS/Support/DATADOG/api_key_carmignac.txt?csf=1&e=1AckAs)  Obligatoire, c’est la clé API de notre portail Datadog Easyteam.
-	**PROCESS_ENABLED** : [TRUE] permet de scanner en temps réel les processus
-	**APM_ENABLED** : [FALSE]
-	**HOSTNAME** : ici il faut préciser le hostname de l’hôte sur lequel va être installé l’agent
-	**TAGS** : ici il faut compléter les tags suivants :
    - **CLIENT** : CARMIGNAC

### EXEMPLE
Voici la chaîne d’installation complète :
```
datadog-agent-6-latest.amd64.msi /qn PROCESS_ENABLED=TRUE APM_ENABLED=FALSE HOSTNAME="<hostname>" TAGS="CLIENT:CARMIGNAC" APIKEY="![a link](https://easyteam.sharepoint.com/:t:/r/sites/easyshare/Documents%20partages/EMS/Support/DATADOG/api_key_carmignac.txt?csf=1&e=1AckAs)"
```
## ETAPE 2 : CONFIGURATION
Le répertoire d’installation de la conf de Datadog (sur Windows) est le suivant : **C:\ProgramData\Datadog**
Il y a plusieurs fichiers à mettre à jour selon le périmètre applicatif

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
```conf.d\win32_event_log.d\conf.yaml```
```conf.d\wmi_check.d\conf.yaml```

Ensuite il y a un ou plusieurs fichiers de configuration à déposer selon le périmètre applicatif

## Cas 1 : Microsoft SQL Server
Déposer le fichier suivant : [a workaround link](Datadog/blob/master/sqlserver.d/conf.yaml)
`conf.d\sqlserver.d\conf.yaml`
### - Création d'un utilisateur
```sql
USE MASTER
CREATE LOGIN datadog WITH PASSWORD = 'Datadog123456789#', CHECK_POLICY= OFF;
CREATE USER datadog FOR LOGIN datadog;
GRANT SELECT on sys.dm_os_performance_counters to datadog;
GRANT VIEW SERVER STATE to datadog;
```
### - Modification de l'authentification
```
EXEC xp_instance_regwrite N'HKEY_LOCAL_MACHINE', N'Software\Microsoft\MSSQLServer\MSSQLServer', N'LoginMode', REG_DWORD, 2
```
### - REDEMARRAGE DE SQL SERVER
Pour la prise en compte des modifications de paramètrage, il faut redémarrer l’instance SQL Server :
```
net stop MSSQLSERVER
net start MSSQLSERVER
```

## Cas 2 : Contrôleur de domaines
