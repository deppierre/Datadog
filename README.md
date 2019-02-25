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

### 2.1/ Fichier datadog.yaml
Il faut mettre à jour le fichier `C:\ProgramData\Datadog\datadog.yaml` en écrasant son contenu par [datadog.yaml](datadog.yaml)  
Ensuite il faut éditer la ligne suivante : `hostname: ""` en complétant avec le hostname de la VM concerné.  
Par exemple : `hostname: "CGP-DEV-VM-POC1"`

### 2.2/ Fichiers conf.yaml
#### 2.2.1 - Cas général : Microsoft Windows Server
Déposer les fichiers suivants : 
- fichier [conf.yaml](win32_event_log.d/conf.yaml) pour remonter le contenu de event_viewer
- fichier [conf.yaml](wmi_check.d/conf.yaml) pour remonter des métriques custom

Ensuite il y a un ou plusieurs fichiers de configuration à déposer selon le périmètre applicatif

#### 2.2.2 - MSSQL
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

#### 2.2.3 - Contrôleurs de domaines
Déposer les fichiers suivants : 
 - conf Active Directory : [conf.yaml](active_directory.d/conf.yaml)
 - conf Event Viewer : [conf.yaml](win32_event_log.d/conf_ad.yaml)
 - conf Service : [conf.yaml](windows_service.d/conf_ad.yaml)
 
#### 2.2.4 - Serveur Linux HAPROXY
Déposer les fichiers suivants : 
 - conf check TCP Datadog : [conf.yaml](tcp_check.d/conf.yaml)
 - conf haproxy : [conf.yaml](haproxy.d/conf.yaml)
