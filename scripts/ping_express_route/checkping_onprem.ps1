# ==============================================================================================
# Script             : checkping_onprem.ps1
# Description        : surveillance de l'express route permettant la connexion OnPrem avec Azure
# Paramètres         : Nom de la machine distance
# Retour             : Aucun
# Commentaires       : Aucun
# ------------------------------------------------------------------------------
# Historique :
# Date       Auteur              Description
# ---------- ------------------- -----------------------------------------------
# 13/05/2019 PDE-Easyteam            Création du script.
# ==============================================================================================

Param (
    [string]$servers = "192.168.21.100,192.168.202.99",
    [string]$APIKey = "5321dfc8ff286241945c10c6f21e40fe"
 )

function eventDatadog([string]$APIKey, [string]$server) {

    # verification de la connexion
    $urlCon = "https://api.datadoghq.eu/api/v1/validate?api_key=$APIKey"
    $urlEvent = "https://api.datadoghq.eu/api/v1/events?api_key=$APIKey"

	$statusCodeKey = (Invoke-WebRequest -Method GET -Uri "$urlCon" -TimeoutSec 10 -Headers @{"Cache-Control"="no-cache"}).StatusCode

    if($statusCodeKey -eq "200") {
        Write-Host "----API Key :: OK"
		
		# envoi de l'erreur a datadog
		$dateOfTheDay = Get-Date -Format yyyy/MM/dd-HH:mm
		$content = @{title = "EXPRESS ROUTE";text = "PING FAILED FROM AZURE -> ONPREM (IP :: $server - TIMESTAMP :: $dateOfTheDay)";priority = "normal";alert_type = "Error"}
		$contentFormatToJson = $content | convertto-json
        $statusCodeData = (Invoke-WebRequest -Method POST -ContentType "application/json" -Uri "$urlEvent" -Body $contentFormatToJson -Headers @{"Cache-Control"="no-cache"} -TimeoutSec 10).StatusCode
		
		if($statusCodeData -eq "202") {
			Write-Host "----API Data :: OK"
		}
		else {
			Write-Host "----API Data :: KO"
		}
    }
    else {
        Write-Host "----API Key :: KO"
        exit
    }
}

$serversSplit = $servers.Split(",")
 
foreach($server in $serversSplit) {

	#test de connexion
	$onlinetest = Test-Connection -computername $server -Count 2 -quiet

    if($onlinetest) {
        Write-Host "--CHECK IP :" $server ":: OK"
    }
    else {
        Write-Host "--CHECK IP :" $server ":: KO"
        eventDatadog $APIKey $server
    }
}