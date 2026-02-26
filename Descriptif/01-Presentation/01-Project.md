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

La suite de cette présentation est accessible [ici](02-Conventions.md).