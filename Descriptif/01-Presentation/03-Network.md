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

La suite de cette présentation est accessible [ici](../02-Hardening/README.md).