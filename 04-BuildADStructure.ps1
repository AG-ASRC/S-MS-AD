Clear-Host
Write-Host '      __       ________        _______    _______  _____  ___    _______   _______        __  ___________  ______     _______          ______     _______    _______       __      _____  ___    __   ________        __  ___________  __      ______    _____  ___       ____  ____  _____  ___    __  ___________  '
Write-Host '     /""\     |"      "\      /" _   "|  /"     "|(\"   \|"  \  /"     "| /"      \      /""\("     _   ")/    " \   /"      \        /    " \   /"      \  /" _   "|     /""\    (\"   \|"  \  |" \ ("      "\      /""\("     _   ")|" \    /    " \  (\"   \|"  \     ("  _||_ " |(\"   \|"  \  |" \("     _   ") '
Write-Host '    /    \    (.  ___  :)    (: ( \___) (: ______)|.\\   \    |(: ______)|:        |    /    \)__/  \\__/// ____  \ |:        |      // ____  \ |:        |(: ( \___)    /    \   |.\\   \    | ||  | \___/   :)    /    \)__/  \\__/ ||  |  // ____  \ |.\\   \    |    |   (  ) : ||.\\   \    | ||  |)__/  \\__/  '
Write-Host '   /  /\  \   |: \   ) ||     \/ \       \/    |  |: \.   \\  | \/    |  |_____/   )   /  /\  \  \\_ /  /  /    ) :)|_____/   )     /  /    ) :)|_____/   ) \/ \        /  /\  \  |: \.   \\  | |:  |   /  ___/    /  /\  \  \\_ /    |:  | /  /    ) :)|: \.   \\  |    (:  |  | . )|: \.   \\  | |:  |   \\_ /     '
Write-Host '  //  __   \  (| (___\ ||     //  \ ___  // ___)_ |.  \    \. | // ___)_  //      /   //  __   \ |.  | (: (____/ //  //      /     (: (____/ //  //      /  //  \ ___  //  __   \ |.  \    \. | |.  |  //  \__    //  __   \ |.  |    |.  |(: (____/ // |.  \    \. |     \\ \__/ // |.  \    \. | |.  |   |.  |     '
Write-Host ' /   /  \\  \ |:       :)    (:   _(  _|(:      "||    \    \ |(:      "||:  __   \  /   /  \\  \\:  |  \        /  |:  __   \      \        /  |:  __   \ (:   _(  _|/   /  \\  \|    \    \ | /\  |\(:   / "\  /   /  \\  \\:  |    /\  |\\        /  |    \    \ |     /\\ __ //\ |    \    \ | /\  |\  \:  |     '
Write-Host '(___/    \___)(________/      \_______)  \_______) \___|\____\) \_______)|__|  \___)(___/    \___)\__|   \"_____/   |__|  \___)      \"_____/   |__|  \___) \_______)(___/    \___)\___|\____\)(__\_|_)\_______)(___/    \___)\__|   (__\_|_)\"_____/    \___|\____\)    (__________) \___|\____\)(__\_|_)  \__|     '
Write-Host 'Developped by Antoine GERMAIN - 2026'
Write-Host 'Version 1.0.0'
Write-Host ' '

$CSVFilePath = "adStructure.csv"

$OUAdded = @()
$OUAlreadyExists = @()
$OUDeleted = @()

$GetOUAlReadyExists = @()

Write-Host "[?] Tentative d'import du fichier CSV: $CSVFilePath" -ForegroundColor Yellow
Write-Host "[?] Veuillez patienter..." -ForegroundColor Yellow
Write-Host ' '
if (-Not (Test-Path -Path $CSVFilePath)) {
    Write-Host "Le fichier CSV spécifié n'existe pas: $CSVFilePath" -ForegroundColor Red
    return $null
}

try {
    $adStructure = Import-Csv -Path $CSVFilePath -Encoding UTF8 -ErrorAction Stop -Delimiter ","

    if ($adStructure.Count -eq 0) {
        Write-Host "Le fichier CSV est vide ou ne contient pas de donnees valides." -ForegroundColor Yellow
        return $null
    }

    $adStructure | ForEach-Object {
        if (-not $_.OU -or -not $_.PARENTS_OU) {
            Write-Host "Ligne invalide dans le fichier CSV: $($_ | Out-String)" -ForegroundColor Yellow
        }
    }

    Write-Host "[V] Import du fichier CSV: $CSVFilePath effectue avec succes" -ForegroundColor Green

    Get-ADOrganizationalUnit -Filter * | ForEach-Object { $GetOUAlReadyExists += $_.DistinguishedName }
    
    foreach ($entry in $adStructure) {
        
        $OU = $entry.OU
        $PARENTS_OU = $entry.PARENTS_OU

        $ouPath = "OU=$OU,$PARENTS_OU"

        if ($GetOUAlReadyExists -contains $ouPath) {
            $OUAlreadyExists += $ouPath
            
        } else {
            try {
                New-ADOrganizationalUnit -Name $OU -Path $PARENTS_OU -ProtectedFromAccidentalDeletion $true -ErrorAction Stop
                $OUAdded += $ouPath

            } catch {
                Write-Host "Erreur lors de la creation de l'OU '$OU' sous '$PARENTS_OU': $_" -ForegroundColor Red
            }
        }

    }

} catch {
    Write-Host "Erreur lors de l'importation du fichier CSV: $_" -ForegroundColor Red
    return $null
}

foreach( $ou in $GetOUAlReadyExists) {

    if ( $ou -notin $OUAdded -and $ou -notin $OUAlreadyExists ) {
        $OUDeleted += $ou
    }

}

Write-Host ' '
$OUAdded | ForEach-Object { Write-Host "OU creee: $_" -ForegroundColor Green }
Write-Host ' '
$OUAlreadyExists | ForEach-Object { Write-Host "OU deja existante: $_" -ForegroundColor Yellow }
Write-Host ' '
$OUDeleted | ForEach-Object { Write-Host "OU supprimee: $_" -ForegroundColor Red }

if ($OUDeleted.Count -gt 0) {
    Write-Host ' '
    $deleteOU = Read-Host "Voulez-vous supprimer les OU non présentes dans le fichier CSV? [Cela entrainera la supression des enfants égalements] (O/N)"

    if ($deleteOU -eq 'O' -or $deleteOU -eq 'o' -or $deleteOU -eq 'Oui' -or $deleteOU -eq 'oui' -or $deleteOU -eq 'YES' -or $deleteOU -eq 'yes' -or $deleteOU -eq 'Y' -or $deleteOU -eq 'y') {
        Write-Host "[?] Suppression des OU supprimees..." -ForegroundColor Yellow
        Write-Host ' '

    foreach ($ou in $OUDeleted) {
        try {
            Set-ADOrganizationalUnit -Identity $ou -ProtectedFromAccidentalDeletion:$false
            Remove-ADOrganizationalUnit -Identity $ou -Recursive -Confirm:$false -ErrorAction Stop
            Write-Host "OU supprimee: $ou" -ForegroundColor Red
        } catch {
            Write-Host "Erreur lors de la suppression de l'OU '$ou': $_" -ForegroundColor Red
        }
    }
}
}
