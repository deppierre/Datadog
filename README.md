## TELECHARGEMENT DU PACKAGE
Il faut télécharger le paquet directement depuis la source, l’url est la suivante : https://s3.amazonaws.com/ddagent-windows-stable/datadog-agent-6-latest.amd64.msi 

## ETAPE 1 : INSTALLATION
Exécuter simplement le fichier :
```
datadog-agent-6-latest.amd64.msi /qn
```
La fichier de configuration sera écrasé plus loin

## ETAPE 2 : CONFIGURATION
Le dossier racine (= root) d’installation de Datadog (sur Windows) est le suivant : **C:\ProgramData\Datadog**

### 1/ Fichier datadog.yaml
Il faut mettre à jour le fichier `C:\ProgramData\Datadog\datadog.yaml` en écrasant son contenu par [datadog.yaml](datadog.yaml)

### 2/ Fichiers conf.yaml
#### Cas général : Microsoft Windows Server
Déposer les fichiers suivants : 
- fichier [conf.yaml](win32_event_log.d/conf.yaml) pour remonter le contenu de event_viewer
- fichier [conf.yaml](wmi_check.d/conf.yaml) pour remonter des métriques custom

Ensuite il y a un ou plusieurs fichiers de configuration à déposer selon le périmètre applicatif

#### Cas 1 : MSSQL
Déposer le fichier suivant : [conf.yaml](sqlserver.d/conf.yaml)
##### - Création d'un utilisateur
```sql
USE MASTER
CREATE LOGIN datadog WITH PASSWORD = '<password>, CHECK_POLICY= OFF;
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

#### Cas 2 : Contrôleurs de domaines
Déposer les fichiers suivants : 
 - conf Active Directory : [conf.yaml](active_directory.d/conf.yaml)
 - conf Event Viewer : [conf.yaml](win32_event_log.d/conf_ad.yaml)
 - conf Service : [conf.yaml](windows_service.d/conf_ad.yaml)
