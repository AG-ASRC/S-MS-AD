# Changelog

Toutes les modifications notables de ce projet sont listees dans ce fichier.

## [Unreleased]

### Added
- Relance automatique du script dans une console PowerShell RunAs.
- Saisie interactive de `DomainName`, `Netbios`, `ForestMode` et `DomainMode`.
- Generation automatique d'un mot de passe DSRM.
- Installation automatique du role `AD-Domain-Services` avant la promotion en controleur de domaine.
- Controle d'environnement pour Windows Server et message explicite si la cmdlet n'est pas disponible.

### Changed
- Simplification du flux d'execution du script pour une utilisation plus directe.
- Ajout d'un message de sortie pour rappeler le mot de passe DSRM genere.

## [1.0.0] - 2026-09-06

### Added
- Premiere version documentee du script d'installation Active Directory.