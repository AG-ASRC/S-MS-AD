param(
    [switch]$RunAsRelaunched
)

if (-not $RunAsRelaunched) {
    $scriptPath = $PSCommandPath
    if ([string]::IsNullOrWhiteSpace($scriptPath)) {
        throw "Impossible de relancer automatiquement en RunAs depuis ce contexte."
    }

    Write-Host "Execution du script dans une console RunAs..." -ForegroundColor Yellow
    Start-Process -FilePath "powershell.exe" -Verb RunAs -ArgumentList @(
        "-NoProfile",
        "-ExecutionPolicy", "Bypass",
        "-NoExit",
        "-File", ('"{0}"' -f $scriptPath),
        "-RunAsRelaunched"
    ) | Out-Null

    exit 0
}

function New-RandomPassword {
    # Genere un mot de passe admin (DSRM) en 1 ligne (16 caracteres, dont 3 speciaux minimum).
    Add-Type -AssemblyName System.Web
    $generatedAdminPassword = [System.Web.Security.Membership]::GeneratePassword(16, 3)
    $safeModeAdministratorPassword = ConvertTo-SecureString $generatedAdminPassword -AsPlainText -Force

    return $safeModeAdministratorPassword
}

$password = New-RandomPassword
$domainName = Read-Host "DomainName (ex: example.com)"
$Netbios = Read-Host "Netbios (ex: EXAMPLE)"

$ForestModeInput = Read-Host "ForestMode (Default par defaut)"
if ([string]::IsNullOrWhiteSpace($ForestModeInput)) {
    $ForestMode = "Default"
}
else {
    $ForestMode = $ForestModeInput
}

$DomainModeInput = Read-Host "DomainMode (Default par defaut)"
if ([string]::IsNullOrWhiteSpace($DomainModeInput)) {
    $DomainMode = "Default"
}
else {
    $DomainMode = $DomainModeInput
}

if (-not (Get-Command Install-WindowsFeature -ErrorAction SilentlyContinue)) {
    Write-Error "Install-WindowsFeature est indisponible. Ce script doit etre execute sur Windows Server."
    exit 1
}

Install-WindowsFeature AD-Domain-Services -IncludeManagementTools
Import-Module ADDSDeployment

Install-ADDSForest `
    -DomainName $domainName `
    -DomainNetbiosName $Netbios.ToUpper() `
    -ForestMode $ForestMode `
    -DomainMode $DomainMode `
    -SafeModeAdministratorPassword $password `
    -InstallDNS `
    -NoRebootOnCompletion `
    -Force

Write-Host " "
Write-Host "Mot de passe admin (DSRM) genere : $password" -ForegroundColor Yellow