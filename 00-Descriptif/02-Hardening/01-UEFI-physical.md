# Durcissement des machines
## Durcissement des machines virtuelles VMware
La configuration matérielle est systématiquement adaptée aux machines. Les éléments qui s'y trouvent sont:
- Mémoire vive
- Processeur
- Disques durs configurés en NVMe
- Carte réseau
- Affichage

Tous les autres éléments sont supprimés.

## Options et UEFI
Les options sont systématiquement adaptées aux machines, tout en prenant en compte les impératifs de performances et de sécurité. Les configurations suivantes sont systématiquement appliquées:
- Sélection du système d'exploitation adapté
- Désactivation de la synchronisation horaire par les VMware Tools
- Désactivation de la mise à jour automatique des VMware Tools
- Utilisation de l'UEFI à la place du BIOS
- Configuration du démarrage exclusivement sur le système d'exploitation installé

Pour revenir aux durcissements, [cliquer ici](README.md).