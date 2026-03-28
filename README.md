# Infr@home

> [!NOTE]
> **Ce projet est sous licence GNU FDL 1.3**
>
> Copyright © 2026 jmy37
> Permission is granted to copy, distribute and/or modify this document under the terms of the GNU Free Documentation License, Version 1.3 or any later version published by the Free Software Foundation; with no Invariant Sections, no Front-Cover Texts, and no Back-Cover Texts.
> [License is online](https://www.gnu.org/licenses/fdl-1.3.html).
>
> Copyright © 2026 jmy37
> Il est permis de copier, distribuer et/ou modifier ce document selon les termes de la licence GNU Free Documentation, version 1.3 ou une version ultérieure publiée par la Free Software Foundation, sans modifier de section, de page de garde ou de clôture.
> [La licence est en ligne](https://www.gnu.org/licenses/fdl-1.3.html).

Ce projet a pour objectif de détailler la mise en oeuvre d'une architecture informatique complète et modulaire, à des fins de tests ou de production.

La finalité du projet sera mise en forme ultérieurement.

Le projet est décomposé en plusieurs parties:
1. [Descriptif du projet](00-Descriptif/README.md)
    1. [Présentation du projet](00-Descriptif/01-Presentation.md)
    2. [Règles de durcissement](00-Descriptif/02-Hardening/README.md)
2. [Mise en place de l'infrastructure](01-Infra/README.md)
3. [Conception de la DMZ](02-DMZ/README.md)
    1. [Pares-feux externes (PFsense)](02-DMZ/01-External-firewalls.md)
    2. [Dépôts DNF/YUM](02-DMZ/02-DNF-repo.md)
    3. [Dépôts APT](02-DMZ/03-APT-repo.md)
    4. [Proxy]
    5. [Bastion d'administration]
4. [Conception des core services](03-CS/README.md)
    1. [Pares-feux internes]
    2. [Bases de données PostgreSQL]
    3. [Supervision]
    4. [Gestion des systèmes d'information (ITSM)]
    5. [Centralisation des journaux d'évènements]
    6. [Gestion des systèmes Linux]
    7. [Gestion des conteneurs (K3S)]

> [!NOTE]  
> L'ordre d'installation, tout comme le choix des composants, n'est pas une nécessité.
> Cependant, certaines parties peuvent s'appuyer sur des composants précédemment installés.
> Il faudra alors adapter le guide pour contourner le composant non-installé.
> Si une dépendance n'est pas mentionnée, ne pas hésiter à la remonter pour correction (en tant que bug dans le projet).

<!--
> [!NOTE]  
> Highlights information that users should take into account, even when skimming.

> [!TIP]
> Optional information to help a user be more successful.

> [!IMPORTANT]  
> Crucial information necessary for users to succeed.

> [!WARNING]  
> Critical content demanding immediate user attention due to potential risks.

> [!CAUTION]
> Negative potential consequences of an action.
-->