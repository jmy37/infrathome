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

La suite de cette présentation est accessible [ici](03-Network.md).