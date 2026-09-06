# S-MS-AD

Automatisation de l'installation et de la promotion d'un serveur Windows en contrôleur de domaine Active Directory.

## Vue d'ensemble

Le script [01-ActiveDirectoryInstaltion.ps1](01-ActiveDirectoryInstaltion.ps1) lance une nouvelle console PowerShell en mode RunAs, demande les informations de base du domaine, genere un mot de passe DSRM, puis installe et promeut le serveur en nouveau controleur de domaine.

## Prerequis

- Windows Server
- Session PowerShell avec droits administrateur ou lancement via le mode RunAs automatique du script
- Role AD DS disponible sur le serveur
- Execution du script avec PowerShell

## Informations demandees

Le script demande les valeurs suivantes:

- `DomainName` : nom DNS du domaine, par exemple `example.com`
- `Netbios` : nom NetBIOS, par exemple `EXAMPLE`
- `ForestMode` : mode de foret, `Default` par defaut
- `DomainMode` : mode de domaine, `Default` par defaut

## Comportement du script

- Lance automatiquement une nouvelle console PowerShell en RunAs si la session n'est pas deja elevee
- Verifie la disponibilite de `Install-WindowsFeature`
- Installe `AD-Domain-Services` avec les outils d'administration
- Importe `ADDSDeployment`
- Execute `Install-ADDSForest`
- Genere un mot de passe DSRM temporaire et l'affiche dans la console

## Utilisation

1. Ouvrir PowerShell
2. Lancer le script:

```powershell
.\01-ActiveDirectoryInstaltion.ps1
```

3. Renseigner les invites:
- domaine
- nom NetBIOS
- modes de foret et de domaine si necessaire

## Notes

- Le script est concu pour un environnement Windows Server, pas pour un poste client Windows.
- Si `Install-WindowsFeature` n'existe pas, le script s'arrete avec un message clair.
- Le mot de passe DSRM est affiche une seule fois dans la console. Pensez a le conserver.
