# Infr@home
Ce projet a pour objectif de détailler la mise en oeuvre d'une architecture informatique complète et modulaire, à des fins de tests ou de production.

La finalité du projet sera mise en forme ultérieurement.

Le projet est décomposé en plusieurs parties:
1. [Descriptif du projet](00-Descriptif/README.md)
    1. [Présentation du projet](00-Descriptif/01-Presentation.md)
    2. [Règles de durcissement](00-Descriptif/02-Hardening/README.md)
2. [Mise en place de l'infrastructure](01-Infra/README.md)
3. [Conception de la DMZ](02-DMZ/README.md)
4. [Conception des core services](03-CS/README.md)

Le projet mènera à l'installation des composants suivants (dans cet ordre):
| Fonctionnalité                                | Guide d'installation                  |
|-----------------------------------------------|---------------------------------------|
| Filtrage de flux (périmétrie)                 |                                       |
| Filtrage de flux (interne)                    |                                       |
| Proxy                                         |                                       |
| Bastion d'administration                      |                                       |
| Bases de données PostgreSQL                   |                                       |
| Supervision                                   |                                       |
| Gestion des systèmes d'information (ITSM)     |                                       |
| Gestion des journaux d'évènements             |                                       |
| Mise à jour des systèmes Linux                |                                       |

> [!NOTE]  
> L'ordre d'installation, tout comme le choix des composants, n'est pas une nécessité.
> Cependant, certaines parties peuvent s'appuyer sur des composants précédemment installés.
> Il faudra alors adapter le guide pour contourner le composant non-installé.
> Si une dépendance n'est pas mentionnée, ne pas hésiter à la remonter pour correction (en tant que bug dans le projet).

<!-- > [!NOTE]  
> Highlights information that users should take into account, even when skimming.

> [!TIP]
> Optional information to help a user be more successful.

> [!IMPORTANT]  
> Crucial information necessary for users to succeed.

> [!WARNING]  
> Critical content demanding immediate user attention due to potential risks.

> [!CAUTION]
> Negative potential consequences of an action. -->