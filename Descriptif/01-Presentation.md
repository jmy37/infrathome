# Descriptif du projet
## Présentation

L'objectif du projet "*Infr@home*" est de proposer une architecture simple, résiliente et abordable de système d'information permettant de suivre les standards en termes d’organisation et de cybersécurité. Le projet est totalement virtualisé en environnement Proxmox VE, mais peut facilement être transposé sur d’autres hyperviseurs, voire en environnement physique.

<!-- Cette présentation se compose de plusieurs sous-parties:
1. [Présentation du projet](01-Project.md)
2. [Conventions techniques](02-Conventions.md)
3. [Présentation réseau](03-Network.md) -->

## Le projet "*Infr@home*"

Ce projet est né de la réflexion qu'aucune solution clé en main n'existait pour mettre en place un laboratoire crédible, chaque brique pouvant être prise indépendamment ou communiquer les unes avec les autres.

Il ne s'agit pas d'un projet de développement, s'arrêtant au plus à quelques scripts élémentaires, mais d'un projet d'ingénierie ayant pour objet de permettre à chacun de monter facilement et de manière compréhensible un laboratoire complet, voire une infrastructure de production.

Une vision pédagogique est également présente, avec des explications régulières sur les commandes employées.

Une convention d'écriture élémentaire sera retenue:
> [!NOTE]  
> Ces éléments correspondent à des informations utiles.

> [!TIP]
> Ces éléments correspondent aux explications pédagogiques et conseils pour les débutants.

> [!IMPORTANT]  
> Ces éléments sont cruciaux pour parvenir à un fonctionnement optimal.

> [!WARNING]  
> Ces éléments permettent d'identifier des situations d'échecs.

> [!CAUTION]
> Ces éléments, s'ils ne sont pas pris en compte, peuvent conduire à des pertes de données ou des indisponibilités sérieuses.

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

## Conventions
### Conventions réseau

> [!WARNING]
> Les conventions réseau et les plages d'adresses IP doivent s'adapter à l'existant.
> La priorité est donc de se renseigner sur les plages déjà utilisées par l'entité, sans oublier les éventuels conflits potentiels avec les réseaux distants (branche distante joignable par VPN, par exemple).

>  [!TIP]
> Une recherche d'optimisation devrait être envisagée lors de l'intégration à un réseau existant, afin de simplifier les routes (une route globale est toujours plus simple à maintenir et moins coûteuse en routage pour les équipements que de multiples routes locales).

La séparation des réseaux dans l'ensemble de ce projet est effective telle que présentée dans le tableau ci-dessous:
| Numéro VLAN | Nom VLAN   | Adresse réseau      | Usage                              |
|-------------|------------|---------------------|------------------------------------|
| 10          | DMZ        | 192.168.10.0/24     | DMZ (serveurs de dépôt, frontend)  |
| 20          | ADMIN      | 10.1.20.0/24        | Serveurs dédiés à l'administration |
| 30          | INFRA      | 10.1.30.0/24        | Composants d'infrastructure        |
| 50          | BIGDATA    | 10.1.50.0/24        | Serveurs dédiés au big data        |
| 51          | WATER      | 10.1.51.0/24        | Usine de traitement d'eau          |
| 100         | CLT        | 10.1.100.0/24       | Postes clients                     |
| 110         | CLT_ADMIN  | 10.1.110.0/24       | Postes d'administration            |
| 254         | FWLHA_DMZ  | 10.255.254.0/30     | Synchronisation des pares-feux     |
| 255         | FWLHA_INT  | 10.255.255.0/30     | Synchronisation des pares-feux     |
<!-- | 40          | CONTAINER  | 10.1.40.0/24        | Architecture de conteneurisation   | -->
<!-- | 120         |            | 10.1.120.0/24       | Bastion d'administration           | -->
<!-- |             |            |                     |                                    | -->

> [!NOTE]
> L'antépénultième adresse IP de chaque VLAN est réservée au premier pare-feu du cluster, l'avant-dernière adresse IP est réservée au second pare-feu du cluster et la dernière adresse IP est réservée à l'adresse virtuelle de passerelle. La première adresse IP de chaque VLAN ne sera pas utilisée.

### Nomenclature des équipements

> [!WARNING]  
> Les conventions de nommage des équipements sont généralement définies par l'entité.
> Cette convention est une proposition dans le cas où l'entité n'en disposerai pas déjà, mais il reste nécessaire de s'adapter à l'existant.

La nomenclature des équipements se réalise de la manière suivante:
`<TYPE><OS><ENV><USAGE><SITE><SI>[01-99]` avec `[01-99]` un numéro incrémental allant de "01" à "99".

La nomenclature des adresses IP virtuelles se réalise de la manière suivante:
`<TYPE><OS><ENV><USAGE><SITE><SI><n1><n2>` avec `<n1>` et `<n2>` les numéros incrémentaux des hôtes cibles.

> [!NOTE]
> Cette nomenclature, très pratique pour conserver une cartographie cohérente de l'ensemble du système d'information, peut être complétée par des alias DNS permettant aux utilisateurs une identification simplifiée des services.

La nomenclature complète est présentée dans le tableau ci-dessous:
| TYPE         | OS           | ENV            | USAGE                                   | SITE       | SI                 |
|--------------|--------------|----------------|-----------------------------------------|------------|--------------------|
| L (LUN)      | L (linux)    | L (labo)       | ACS (contrôleur de domaine)             | A (site A) | BD (Big data)      |
| P (physique) | N (sans OS)  | P (production) | AVS (antivirus)                         | B (site B) | CS (Core services) |
| V (virtuel)  | S (Synology) | S (staging)    | BKP (sauvegarde)                        |            |                    |
|              | V (VMware)   |                | CLT (client)                            |            |                    |
|              |              |                | DBS (bases de données)                  |            |                    |
|              |              |                | FWL (pare-feu)                          |            |                    |
|              |              |                | GSV (GeoServer)                         |            |                    |
|              |              |                | HYP (hyperviseur)                       |            |                    |
|              |              |                | IEM (SIEM)                              |            |                    |
|              |              |                | ITM (ITSM)                              |            |                    |
|              |              |                | LOG (journaux)                          |            |                    |
|              |              |                | NAS (stockage)                          |            |                    |
|              |              |                | OSM (cartographie)                      |            |                    |
|              |              |                | PKI (infrastructure de gestion de clés) |            |                    |
|              |              |                | PRX (proxy)                             |            |                    |
|              |              |                | REP (dépôt)                             |            |                    |
|              |              |                | RDG (bastion)                           |            |                    |
|              |              |                | RTR (routeur)                           |            |                    |
|              |              |                | UPD (mises à jour)                      |            |                    |
|              |              |                | VAS (scanner de vulnérabilités)         |            |                    |
|              |              |                | VCE (vCenter)                           |            |                    |
<!-- |              |              |                |                                         |            |                    | -->

## Présentation du réseau

> [!WARNING]
> Les conventions réseau et les plages d'adresses IP doivent s'adapter à l'existant.
> La priorité est donc de se renseigner sur les plages déjà utilisées par l'entité, sans oublier les éventuels conflits potentiels avec les réseaux distants (branche distante joignable par VPN, par exemple).

### VLAN 10 "DMZ"

Ce VLAN est l'interface entre le réseau sécurisé (postes clients, postes d'administratiuon, serveurs, infrastructure...) et Internet. Son adressage IP est spécifique, compte-tenu des impératifs imposés par l'opérateur.

Le tableau ci-dessous présente l'adressage IP de ce VLAN.

| Adresse IP      | Nom DNS       | Fonctionnalité                      |
|-----------------|---------------|-------------------------------------|
| 192.168.10.1    | vllfwlacs0102 | Passerelle externe                  |
| 192.168.10.2    | vllfwlacs01   | Pare-feu DMZ 1                      |
| 192.168.10.3    | vllfwlacs02   | Pare-feu DMZ 2                      |
| 192.168.10.4    | vllfwlacs0304 | Passerelle interne                  |
| 192.168.10.5    | vllfwlacs03   | Pare-feu interne 1                  |
| 192.168.10.6    | vllfwlacs04   | Pare-feu interne 2                  |
| 192.168.10.7    | vllrepacs01   | Dépôt DNF 1                         |
| 192.168.10.8    | vllrepacs02   | Dépôt DNF 2                         |
| 192.168.10.9    | vllrepacs0102 | VIP dépôt DNF                       |
| 192.168.10.10   | vllrepacs03   | Dépôt APT 1                         |
| 192.168.10.11   | vllrepacs04   | Dépôt APT 2                         |
| 192.168.10.12   | vllrepacs0304 | VIP dépôt APT                       |
| 192.168.10.13   | vllprxacs01   | Proxy 1                             |
| 192.168.10.16   | vllmonacs03   | Relai de supervision DMZ            |
| 192.168.10.19   | vlllogacs03   | Relai journaux DMZ 1                |
| 192.168.10.20   | vlllogacs04   | Relai journaux DMZ 2                |
<!-- | 192.168.10.21   | Traefik       |                                     | -->
<!-- |                 |               |                                     | -->

### VLAN 20 "ADMIN"

Ce VLAN héberge tous les serveurs et services réseaux d'usage commun.

Le tableau ci-dessous représente l'adressage IP de ce VLAN.

| Adresse IP      | Nom DNS       | Fonctionnalité                      |
|-----------------|---------------|-------------------------------------|
| 10.1.20.1       | vllfwlacs0304 | Passerelle interne                  |
| 10.1.20.2       | vllfwlacs03   | Pare-feu interne 1                  |
| 10.1.20.3       | vllfwlacs03   | Pare-feu interne 2                  |
| 10.1.20.4       | vlllogacs01   | Serveur de journaux 1               |
| 10.1.20.5       | vlllogacs02   | Serveur de journaux 2               |
| 10.1.20.6       | vlldbsacs01   | Serveur de bases de données 1       |
| 10.1.20.7       | vlldbsacs02   | Serveur de bases de données 2       |
| 10.1.20.12      | vllmonacs01   | Serveur de supervision 1            |
| 10.1.20.15      | vllitmacs01   | Serveur ITSM                        |
<!-- |                 |               | Velociraptor                        | -->
<!-- |                 |               | Foreman                             | -->
<!-- |                 |               | Wazuh                               | -->
<!-- |                 |               | Backup                              | -->
<!-- |                 |               | PKI                                 | -->
<!-- |                 |               | VAS                                 | -->
<!-- |                 |               |                                     | -->

### VLAN 30 "INFRA"

Ce VLAN héberge les composants d'infrastructure (adresses de gestion des switchs, des serveurs, des baies de stockage).

Le tableau ci-dessous représente l'adressage IP de ce VLAN.

| Adresse IP      | Nom DNS       | Fonctionnalité                  |
|-----------------|---------------|---------------------------------|
| 10.1.30.1       | vllfwlacs0304 | Passerelle interne              |
| 10.1.30.2       | vllfwlacs03   | Pare-feu interne 1              |
| 10.1.30.3       | vllfwlacs03   | Pare-feu interne 2              |
| 10.1.30.4       | pslnasacs01   | NAS hébergeant les VM 1         |
| 10.1.30.5       | pslnasacs02   | NAS hébergeant les VM 2         |
| 10.1.30.6       | pslnasacs0102 | VIP d'hébergement des VM        |
| 10.1.30.7       | pllhypacs01   | Hyperviseur 1                   |
<!-- |                 |               |                                     | -->

<!-- ### VLAN 50 "BIGDATA"

Ce VLAN héberge une solution de traitement de données de masse avec un volet cartographique.

Le tableau ci-dessous représente l'adressage IP de ce VLAN.

| Adresse IP      | Nom DNS       | Fonctionnalité                  |
|-----------------|---------------|---------------------------------|
| 10.1.50.1       | vllfwlacs0304 | Passerelle interne              |
| 10.1.50.2       | vllfwlacs03   | Pare-feu interne 1              |
| 10.1.50.3       | vllfwlacs03   | Pare-feu interne 2              |
| 10.1.50.4       | vllosmabd01   | Cartographie OpenStreetMap 1    |
| 10.1.50.5       | vllosmabd02   | Cartographie OpenStreetMap 1    |
| 10.1.50.6       | vllosmabd0102 | VIP OpenStreetMap               |
| 10.1.50.7       | vllgsvabd01   | Serveur GeoServer 1             |
| 10.1.50.8       | vllgsvabd02   | Serveur GeoServer 2             |
| 10.1.50.9       | vllgsvabd0102 | VIP GeoServer                   |
| 10.1.50.10      | vlldssabd01   | Serveur Dataiku DSS             |
|                 |               |                                 | -->


<!-- ### VLAN 51 "WATER"

Ce VLAN héberge une usine de traitement d'eau salée afin de la rendre potable.

Le tableau ci-dessous représente l'adressage IP de ce VLAN.

| Adresse IP      | Nom DNS       | Fonctionnalité                  |
|-----------------|---------------|---------------------------------|
| 10.1.51.1       | vllfwlacs0304 | Passerelle interne              |
| 10.1.51.2       | vllfwlacs03   | Pare-feu interne 1              |
| 10.1.51.3       | vllfwlacs03   | Pare-feu interne 2              |
|                 |               |                                 | -->

### VLAN 100 "CLT"



Le tableau ci-dessous représente l'adressage IP de ce VLAN.

| Adresse IP      | Nom DNS       | Fonctionnalité                  |
|-----------------|---------------|---------------------------------|
| 10.1.100.1      | vllfwlacs0304 | Passerelle interne              |
| 10.1.100.2      | vllfwlacs03   | Pare-feu interne 1              |
| 10.1.100.3      | vllfwlacs03   | Pare-feu interne 2              |
|                 |               |                                 |

### VLAN 110 "CLT_ADMIN"



Le tableau ci-dessous représente l'adressage IP de ce VLAN.

| Adresse IP      | Nom DNS       | Fonctionnalité                  |
|-----------------|---------------|---------------------------------|
| 10.1.110.1      | vllfwlacs0304 | Passerelle interne              |
| 10.1.110.2      | vllfwlacs03   | Pare-feu interne 1              |
| 10.1.110.3      | vllfwlacs03   | Pare-feu interne 2              |
|                 |               |                                 |

### VLAN 254 "FWLHA_DMZ"

Ce VLAN permet exclusivement aux pares-feux de la DMZ de synchroniser les règles, les états et de contrôler leur bon fonctionnement mutuel.

Le tableau ci-dessous représente l'adressage IP de ce VLAN.

| Adresse IP      | Nom DNS       | Fonctionnalité                  |
|-----------------|---------------|---------------------------------|
| 10.255.254.1/30 | vllfwlacs03   | Pare-feu DMZ 1                  |
| 10.255.254.2/30 | vllfwlacs04   | Pare-feu DMZ 2                  |

### VLAN 255 "FWLHA_INT"

Ce VLAN permet exclusivement aux pares-feux internes de synchroniser les règles, les états et de contrôler leur bon fonctionnement mutuel.

Le tableau ci-dessous représente l'adressage IP de ce VLAN.

| Adresse IP      | Nom DNS       | Fonctionnalité                  |
|-----------------|---------------|---------------------------------|
| 10.255.255.1/30 | vllfwlacs03   | Pare-feu interne 1              |
| 10.255.255.2/30 | vllfwlacs04   | Pare-feu interne 2              |
