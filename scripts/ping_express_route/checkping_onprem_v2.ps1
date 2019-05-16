# ==============================================================================================
# Script             : checkping_onprem.ps1
# Description        : surveillance de l'express route permettant la connexion OnPrem avec Azure
# Paramètres         : IP des machines OnPrem (valeurs par défaut) format : "X.X.X.X,Y.Y.Y.Y,Z.Z.Z.Z" / API KEY (valeur par défaut) "XXXXXXXX"
# Retour             : Aucun
# Commentaires       : Aucun
# ------------------------------------------------------------------------------
# Historique :
# Date       Auteur              Description
# ---------- ------------------- -----------------------------------------------
# 15/05/2019 GGE-Easyteam            Création du script.
# ==============================================================================================

# valeurs par défaut
Param (
    [string]$servers = "192.168.21.100,192.168.202.33",
	#/!\ API Key A REMPLACER /!\
    [string]$APIKey = "532XXXXXXXXXXXX40fe"
	#/!\
 )

# function API Datadog
function eventDatadog([string]$APIKey, [string]$server, [string]$type, [single]$averageResponseTime) {

    # préparation des URLs
    $urlCon = "https://api.datadoghq.eu/api/v1/validate?api_key=$APIKey"
    $urlEvent = "https://api.datadoghq.eu/api/v1/events?api_key=$APIKey"

	# récupération du code HTTP d'authentification de la clé à l'API
	$statusCodeKey = (Invoke-WebRequest -Method GET -Uri "$urlCon" -TimeoutSec 10 -Headers @{"Cache-Control"="no-cache"}).StatusCode

	# clé OK
    if($statusCodeKey -eq "200") {
        Write-Host "----API Key :: OK"
		
		# envoi des data via API Datadog
		$dateOfTheDay = Get-Date -Format yyyy/MM/dd-HH:mm
		if ($type -eq "Warning") {
			$text = "PING TIMEOUT FROM AZURE -> ONPREM (IP :: $server - TIMESTAMP :: $dateOfTheDay - AVERAGERESPONSETIME :: $averageResponseTime ms)"
		} else {
			$text = "PING FAILED FROM AZURE -> ONPREM (IP :: $server - TIMESTAMP :: $dateOfTheDay)"
		}
		$content = @{title = "EXPRESS ROUTE";text = $text;priority = "normal";alert_type = $type}
		$contentFormatToJson = $content | convertto-json
		
		# envoi des donnees
        $statusCodeData = (Invoke-WebRequest -Method POST -ContentType "application/json" -Uri "$urlEvent" -Body $contentFormatToJson -Headers @{"Cache-Control"="no-cache"} -TimeoutSec 10).StatusCode
		
		# data OK
		if($statusCodeData -eq "202") {
			Write-Host "----API Data :: OK"
		}
		# data KO
		else {
			Write-Host "----API Data :: KO"
		}
    }
	# cle KO
    else {
        Write-Host "----API Key :: KO"
        exit
    }
}

$serversSplit = $servers.Split(",")
 
foreach($server in $serversSplit) {
	# test ping
    try { 
        $pings = Test-Connection -computername $server -Count 5 -ErrorAction stop
        $averageResponseTime = ($pings | Measure-Object -Property ResponseTime -Average).Average
        $statusSum = 0
        foreach ($ping in $pings) {
            $statusSum += $ping.StatusCode
        }

		# ping OK
		if (-Not($statusSum) -And ($averageResponseTime -le 30)) {
			Write-Host "--CHECK IP :" $server ":: OK"
		}
		elseif (-Not($statusSum)) {
			Write-Host "--CHECK IP :" $server ":: KO"
			# envoi d'un event à l'API Datadog
			eventDatadog $APIKey $server "Warning" $averageResponseTime
		}
		# ping KO
		else {
			Write-Host "--CHECK IP :" $server ":: KO"
			# envoi d'un event à l'API Datadog
			eventDatadog $APIKey $server "Error" -1
		}
    }
    catch { 
		Write-Host "--PING IP :" $server ":: KO"
		# envoi d'un event à l'API Datadog
		eventDatadog $APIKey $server "Error" -1
    }
}
