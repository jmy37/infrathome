# Dépôts DNF/YUM
## Descriptif
Ce chapitre décrit l'installation, l'exploitation et la résolution de pannes associées au dépôt DNF/YUM du projet [Infr@home](../README.md). Ce dépôt est également une source de temps reconnu, et est capable de synchroniser des sources HTTP/HTTPS, GIT ou encore rsync.
Enfin, il est en capacité de récupérer les fichiers de mise à jour de ClamAV Antivirus.

## Composition du serveur
Ce dépôt s'appuie sur une installation minimale d'Alma Linux conforme au [guide de durcissement du projet](../00-Descriptif/02-Hardening/02-01-Alma9.md).
La composition minimale du serveur est présentée dans le tableau ci-dessous:
| Composant     | Caractéristique           | 
|---------------|---------------------------|
| Processeur    | 1 cœur (minimal)         |
| Mémoire vive  | 2Go (minimal)             |
| Stockage      | 35Go (système)            |
|               | 50Go extensibles (dépôt)  |

> [!NOTE]
> La taille affinée des dépôts est présentée dans le tableau ci-dessous, permettant d'ajuster la taille du disque en fonction des besoins réels.
> Ces tailles sont données à titre d'illustration, et sont susecptibles d'évoluer.
> | Type de source      | Dépôt                                 | Taille    |
> |---------------------|---------------------------------------|-----------|
> | **Alma Linux 8**        | **TOTAL ALMA LINUX 8**                | **101Go** |
> |                         | appstream-alma8                       | 15Go      |
> |                         | baseos-alma8                          | 5Go       |
> |                         | epel-alma8                            | 20Go      |
> |                         | epel-modular-alma8                    | 1Go       |
> |                         | extras-alma8                          | 1Go       |
> |                         | percona-noarch-alma8                  | 1Go       |
> |                         | percona-x86_64-alma8                  | 35Go      |
> |                         | pgAdmin4-alma8                        | 5Go       |
> |                         | pgdg16-alma8                          | 1Go       |
> |                         | pgdg-common-alma8                     | 1Go       |
> |                         | powertools-alma8                      | 15Go      |
> |                         | zabbix62-alma8                        | 1Go       |
> | **Alma Linux 9**        | **TOTAL ALMA LINUX 9**                | **80Go**  |
> |                         | appstream-alma9                       | 15Go      |
> |                         | baseos-alma9                          | 5Go       |
> |                         | crb-alma9                             | 20Go      |
> |                         | epel-alma9                            | 20Go      |
> |                         | extras-alma9                          | 1Go       |
> |                         | percona-noarch-alma9                  | 1Go       |
> |                         | percona-x86_64-alma9                  | 10Go      |
> |                         | pgAdmin4-alma9                        | 5Go       |
> |                         | pgdg16-alma9                          | 1Go       |
> |                         | pgdg-common-alma9                     | 1Go       |
> |                         | zabbix64-alma9                        | 1Go       |
> | **OPNsense (RSYNC)**    | **TOTAL OPNSENSE**                    | **95Go**  |
> |                         | 22.1                                  | 20Go      |
> |                         | 22.7                                  | 25Go      |
> |                         | 23.1                                  | 15Go      |
> |                         | 23.7                                  | 15Go      |
> |                         | 24.1                                  | 5Go       |
> | **HTTP/HTTPS (wget)**   | iTop                                  |           |
> |                         | **TOTAL OPENSTREETMAP**               |           |
> |                         | OpenStreetMap Afrique                 | 10Go      |
> |                         | OpenStreetMap Antarctique             | 1Go       |
> |                         | OpenStreetMap Asie                    | 13Go      |
> |                         | OpenStreetMap Australie et Océanie    | 5Go       |
> |                         | OpenStreetMap Amérique Centrale       | 1Go       |
> |                         | OpenStreetMap Amérique du Nord        | 15Go      |
> |                         | OpenStreetMap Amérique du Sud         | 5Go       |
> |                         | OpenStreetMap Europe                  | 30Go      |
> |                         | OpenStreetMap France                  | 5Go       |
> |                         | OpenStreetMap Planète                 | 80Go      |
> |                         | OpenStreetMap Sources                 |           |

## Matrice de flux
Les ports présentés dans le tableau ci-dessous doivent être ouverts:
| Protocole | Port source       | Adresse source            | Port destination  | Adresse destination       | Explication                       |
|-----------|-------------------|---------------------------|-------------------|---------------------------|-----------------------------------|
| tcp       | *                 | Serveurs clients          | 80                | Dépôts DNF DMZ            | Mise à jour interne               |
| tcp       | *                 | Serveurs clients          | 443               | Dépôts DNF DMZ            | Mise à jour interne               |
| tcp       | *                 | Dépôts DNF DMZ            | 80                | Serveurs externes         | Récupération données externes     |
| tcp       | *                 | Dépôts DNF DMZ            | 443               | Serveurs externes         | Récupération données externes     |
| tcp       | *                 | Clients d'administration  | 22                | Dépôts DNF DMZ            | Administration via SSH            |

# Installation
## Installation des prérequis
### Configuration du disque supplémentaire
Le disque supplémentaire doit être dimensionné en conformité avec les données à héberger.

Les paramètres suivant doivent être adaptés à l'environnement:
- **Disque physique**: ``/dev/nvme0n2``
- **Groupe de volumes logique**: ``VG_Repo``
- **Volume logique**: ``LV_repo``
- **Point de montage**: ``/var/www``
- **Options de montage**: ``nosuid,nodev,noexec``
```bash
pvcreate /dev/nvme0n2
vgcreate VG_Repo /dev/nvme0n2
lvcreate -n /dev/VG_Repo/LV_repo -l +100%FREE
mkfs -t xfs /dev/mapper/VG_Repo-LV_repo
mkdir /var/www
echo -e "/dev/mapper/VG_Repo-LV_repo               /var/www       xfs  nosuid,noexec,nodev        0 0" >> /etc/fstab
mount -a
systemctl daemon-reload
```

> [!TIP]
> Un contrôle du bon montage du disque peut être réalisé à l'aide de la commande ``df -h /var/www``.

### Installation des prérequis applicatifs
La récupération des données s'appuie sur des briques élémentaires:
- **Un serveur web Apache**: ``httpd``
- **Le support SSL pour Apache**: ``mod_ssl``
- **Les outils DNF**: ``dnf-utils``
- **Un outil de téléchargement avancé**: ``wget``
- **Un outil de synchronisation RSYNC**: ``rsync``
```bash
dnf -y install httpd mod_ssl dnf-utils wget rsync
```

La page d'accueil d'Apache ne permet pas la consultation rapide du dépôt, et peut être supprimée.
```bash
echo "# This file is part of Infr@Home Information System
# It is under GPL-V3 license
#
# Versionning
# YYYYMMDD_hhmm | Author                | Changelog
# 20240525_0957 | jmy37                 | File creation
#
# This configuration file enables the default "Welcome" page if there
# is no default index page present for the root URL.  To disable the
# Welcome page, comment out all the lines below.
#
# NOTE: if this file is removed, it will be restored on upgrades.
#" > /etc/httpd/conf.d/welcome.conf
```

Le serveur web doit être démarré et configuré pour se lancer automatiquement au démarrage du serveur.
```bash
systemctl enable --now httpd
```

### Configuration du pare-feu local
Les flux requis doivent être ouverts sur le pare-feu local.
```bash
firewall-cmd --add-service={ssh,http,https} --permanent
firewall-cmd --reload
```

## Mise en place du script de récupération de données
### Environnement
Les paramètres ci-dessous sont à adapter à l'environnement retenu:
- **Compte de service effectuant la récupération des données**: ``svc_repodnf``
- **Racine du serveur web**: ``/var/www/html``
- **Répertoire de configuration du script de téléchargement**: ``/opt/sync_sources``
- **Script de récupération des sources**: ``sync_sources.sh``

### Création d'un compte de service
Le compte de service doit être propriétaire du répertoire hébergeant les dépôts.
```bash
mkdir -p /opt/sync_sources
useradd svc_repodnf -s /sbin/nologin
chown -R svc_repodnf: /var/www/html/ /opt/sync_sources
```

### Script de récupération des sources
Le script doit être adapté (notamment dans les variables) au système sur lequel il est exécuté.
```bash
echo -e '#!/bin/sh

# This script is part of Infr@Home Information System
# It is under GPL-V3 license
#
# Versionning
# YYYYMMDD_hhmm | Author                | Changelog
# 20201018_1436 | jmy37                 | Script creation
# 20201210_1431 | jmy37                 | Add rsync and wget repositories
# 20220128_1736 | jmy37                 | Add Rocky Linux repositories
# 20221107_2104 | jmy37                 | Add Alma Linux repositories
# 20240525_0959 | jmy37                 | Remove CentOS and Rocky repositories
#

# Variables
WEB_PATH=/var/www/html
LOG_PATH=/var/log
ERROR_LOG=$LOG_PATH/sync_error.log
DEBUG_LOG=$LOG_PATH/sync_debug.log
REPOLIST_FILES=/opt/sync_sources
ALMA_REPOLIST=$REPOLIST_FILES/alma
RSYNC_REPOLIST=$REPOLIST_FILES/rsync
WGET_REPOLIST=$REPOLIST_FILES/wget

# System variables
TOUCH_BIN=/usr/bin/touch
REPOSYNC_BIN=/usr/bin/reposync
RSYNC_BIN=/usr/bin/rsync
WGET_BIN=/usr/bin/wget
CURL_BIN=/usr/bin/curl

# Create log files
$TOUCH_BIN $ERROR_LOG
$TOUCH_BIN $DEBUG_LOG

# Starting synchronization
NOW=$(date +"%Y %m %d  %T")
echo -e "["$NOW"] Start syncing..." >> $DEBUG_LOG

# Alma Linux sync
while IFS=, read -r ALMA_RELEASE REPOID
do
  NOW=$(date +"%Y %m %d  %T")
  echo -e "["$NOW"] Starting to sync ["$REPOID"]..." >> $DEBUG_LOG
  if $REPOSYNC_BIN --download-metadata --delete --download-path=$WEB_PATH/alma/$ALMA_RELEASE/ --repoid=$REPOID >> $DEBUG_LOG ; then
    NOW=$(date +"%Y %m %d  %T")
    echo -e "["$NOW"] Repo ["$REPOID"] successfully synced" >> $DEBUG_LOG
  else
    echo -e "["$NOW"] Error syncing ["$REPOID"]" >> $ERROR_LOG
    echo -e "["$NOW"] Error syncing ["$REPOID"]" >> $DEBUG_LOG
  fi
done < $ALMA_REPOLIST

# Rsync repositories
while IFS=, read -r REPOID RSYNC_URL
do
  NOW=$(date +"%Y %m %d  %T")
  echo -e "["$NOW"] Starting to sync ["$REPOID"]..." >> $DEBUG_LOG
  if $RSYNC_BIN --archive --hard-links --numeric-ids --stats rsync://$RSYNC_URL $WEB_PATH/$REPOID/ >> $DEBUG_LOG ; then
    NOW=$(date +"%Y %m %d  %T")
    echo -e "["$NOW"] Repo ["$REPOID"] successfully synced" >> $DEBUG_LOG
  else
    echo -e "["$NOW"] Error syncing ["$REPOID"]" >> $ERROR_LOG
    echo -e "["$NOW"] Error syncing ["$REPOID"]" >> $DEBUG_LOG
  fi
done < $RSYNC_REPOLIST

# Wget repositories
while IFS=, read -r REPOID WGET_CUTDIRS WGET_DOMAIN WGET_URL
do
  NOW=$(date +"%Y %m %d  %T")
  echo -e "["$NOW"] Starting to sync ["$REPOID"]..." >> $DEBUG_LOG
  if $WGET_BIN --quiet --reject=md5,txt,html,tmp --recursive --no-host-directories --cut-dirs=$WGET_CUTDIRS --convert-links --no-parent --domains=$WGET_DOMAIN --directory-prefix=$WEB_PATH/$REPOID/ $WGET_URL >> $DEBUG_LOG ; then
    NOW=$(date +"%Y %m %d  %T")
    echo -e "["$NOW"] Repo ["$REPOID"] successfully synced" >> $DEBUG_LOG
  else
    echo -e "["$NOW"] Error syncing ["$REPOID"]" >> $ERROR_LOG
    echo -e "["$NOW"] Error syncing ["$REPOID"]" >> $DEBUG_LOG
  fi
done < $WGET_REPOLIST

# End of script
echo -e "["$NOW"] Syncing is over. Thanks to check log above for errors." >> $DEBUG_LOG

exit\n' > /opt/sync_sources/sync_sources.sh
```

Le script doit être en lecture seule afin d'éviter toute modification par un éventuel acteur malveillant ayant réussi à s'insérer dans le système.
```bash
chmod 500 /opt/sync_sources/sync_sources.sh
chown svc_repodnf: /opt/sync_sources.sh
```

### Création des chemins indispensables
Les chemins de base doivent être créés manuellement.
```bash
mkdir -p /var/www/html/alma/8
mkdir -p /var/www/html/alma/9
mkdir -p /var/www/html/clamav-antivirus
mkdir -p /var/www/html/dataiku-dss
mkdir -p /var/www/html/geoserver
mkdir -p /var/www/html/itop
mkdir -p /var/www/html/openstreetmap/data
mkdir -p /var/www/html/openstreetmap/src
mkdir -p /var/www/html/opnsense
mkdir -p /var/www/html/redmine
mkdir -p /var/www/html/rpm-gpg-key
mkdir -p /var/www/html/yum.repos.d.sample
```

Les fichiers sources doivent également être créés manuellement.
```bash
touch /opt/sync_sources/alma
touch /opt/sync_sources/rsync
touch /opt/sync_sources/wget
```

Les fichiers doivent être la propriété du compte de service.
```bash
chown -R svc_repodnf: /opt/sync_sources
```

Les fichiers de logs doivent eux aussi être créés manuellement et propriétés du compte de service.
```bash
touch /var/log/sync_debug.log /var/log/sync_error.log
chown svc_repodnf: /var/log/sync_*.log
```

### Planification par cron
La tâche planifiée en charge de lancer le script peut s'exécuter tous les jours, afin de garantir la fraicheur des données.
```bash
echo -e "  0  0  *  *  * svc_repodnf /opt/sync_sources/sync_sources.sh" >> /etc/crontab
```

> [!IMPORTANT]
> Afin de limiter le risque de surcharge du réseau, privilégier un créneau de faible affluence.
> Prendre également en compte les horaires des créneaux de mise à jour, afin de s'assurer que la mise à jour depuis Internet soit terminée avant d'exécuter la mise à jour locale.

### Activation de rsync
Rsync permet la synchronisation simplifiée entre plusieurs serveurs.
C'est également le protocole utilisé pour mettre à jour les pares-feux OPNsense.
Son activation est simple et rapide:
- Installer le démon rsync
- Créer un fichier de configuration associé à rsync
- Y ajouter la configuration des dépôts à partager (dans l'exemple ci-dessous, opensense)
- Y spécifier les hôtes autorisés (dans l'exemple ci-dessous, vllfwlacs01 et vllfwlacs02)
- Autoriser le démon rsync dans la configuration du pare-feu
- Autoriser le démon rsync dans la configuration de SELinux
- Activer au démarrage le démon rsync
- Exécuter le démon rsync
```bash
dnf -y install rsync-daemon
echo -e "pid file = /var/run/rsyncd.pid
log file = /var/log/rsyncd.log
max connections = 4
transfer logging = no" >> /etc/rsyncd.conf
echo -e "[opnsense]
path = /var/www/html/opnsense/
hosts allow = vlsfwlacs03.infra-at-home.com vlsfwlacs04.infra-at-home.com
hosts deny = *
list = true
uid = root
gid = root
read only = true" >> /etc/rsyncd.conf
firewall-cmd --add-service=rsyncd --permanent
firewall-cmd --reload
setsebool -P rsync_full_access on
systemctl enable rsyncd
systemctl start rsyncd
```

## Création d'un cluster de tolérances de panne
### Présentation de la solution
Puisqu'il n'y a pas de base de données sur ce système, la configuration de la tolérance de panne est très simple à mettre en œuvre.

Les pares-feux étant déjà configurés, et pouvant facilement superviser les deux serveurs, le plus simple est que ce soit eux qui supportent l'adresse IP virtuelle.

> [!CAUTION]
> **ATTENTION**: Cette solution implique que toutes les modifications apportées au script de récupération de fichiers, aux sources et aux fichiers modèles devra être réalisée depuis le serveur principal.
> Si cette règle n'est pas respectée, les fichiers mis à jour depuis le serveur secondaire seront écrasés à intervalles réguliers.

### Installation du second serveur
L'installation du serveur est très similaire à l'installation du premier.
- Créer un serveur correspondant à la [composition attendue](#composition-du-serveur)
- Ouvrir les flux identifiés dans la [matrice de flux](#matrice-de-flux)
- Créer le [compte de service](#création-dun-compte-de-service)
- Mettre en place le [script de récupération des sources](#script-de-récupération-des-sources)
- Créer les [chemins indispensables](#création-des-chemins-indispensables)
- Configurer [rsync](#activation-de-rsync)

### Configuration de la réplication, des paramètres et des modèles

> [!IMPORTANT]
> Toutes les actions ci-dessous sont réalisées **uniquement sur le serveur principal**.

Le serveur principal doit être en mesure de synchroniser les différents fichiers utiles, afin d'éviter toute recopie. Cette synchronisation sera réalisée à l'aide du démon ``lsync``.
```bash
dnf -y install lsyncd
```

Une clé SSH doit être réalisée depuis le serveur principal, et partagée sur le serveur secondaire.
```bash
ssh-keygen -q -t rsa -b 4096 -f /root/.ssh/id_rsa -N ""
ssh-copy-id root@vlsrepacs02.infra-at-home.com
[...]
root@vlsrepacs02's password:
[...]
```

Le fichier de configuration de ``lsync`` doit désormais être renseigné.
```bash
echo -e '----
-- User configuration file for lsyncd.
settings {
  logfile="/var/log/lsyncd/lsyncd.log",
  statusFile="/var/log/lsyncd/lsyncd.status",
  insist=true
  }

sync{
  default.rsyncssh,
  source="/opt/",
  host="vlsrepacs02",
  targetdir="/opt/"
  }

sync{
  default.rsyncssh,
  source="/etc/yum.repos.d/",
  host="vlsrepacs02",
  targetdir="/etc/yum.repos.d/"
  }

sync{
  default.rsyncssh,
  source="/var/www/html/yum.repos.d.sample/",
  host="vlsrepacs02",
  targetdir="/var/www/html/yum.repos.d.sample/"
  }

sync{
  default.rsyncssh,
  source="/var/www/html/rpm-gpg-key/",
  host="vlsrepacs02",
  targetdir="/var/www/html/rpm-gpg-key/"
  }\n' > /etc/lsyncd.conf
```

Le démon ``lsync`` doit désormais être exécuté au lancement du système, et immédiatement.
```bash
systemctl start lsyncd
systemctl enable lsyncd
```

### Planification de la synchronisation sur le serveur secondaire
La synchronisation mise en œuvre sur le premier serveur doit être mise en œuvre sur le second serveur.
```bash
echo -e "  0  1  *  *  * svc_repodnf /opt/sync_sources/sync_sources.sh" >> /etc/crontab
```

> [!TIP]
> Afin de limiter la charge réseau, une heure différente de celle configurée sur le premier serveur doit être privilégiée.
> Ces deux créneaux horaires ne doivent pas entrer en collision avec les créneaux de mises à jour planifiées; ce comportement pourrait causer des erreurs de mises à jour, l'OS client cherchant à récupérer des fichiers pas encore téléchargés.

# Ajout de sources
## Sources DNF/YUM
L'ajout de sources DNF/YUM se fait facilement à l'aide des étapes suivantes:
- Créer un fichier de dépôt désactivé en spécifiant l'ID et le nom de dépôt, l'URL de téléchargement et l'emplacement de la clé GPG
- Importer la clé du dépôt sur le serveur depuis l'emplacement en ligne
- Importer le dépôt dans le modèle de configuration YUM/DNF en spécifiant l'ID et le nom du dépôt, l'URL locale et l'emplacement de la clé GPG locale
- Ajouter les informations relatives au dépôt dans le fichier listant les dépôts
- Réaliser une synchronisation initiale

### Alma Linux 8
#### Alma Linux 8 AppStream
Le fichier de dépôt source est créé ci-dessous:
```bash
echo -e "[appstream-alma8]
name=AppStream for Alma 8 (x86_64)
mirrorlist=https://mirrors.almalinux.org/mirrorlist/8/appstream
gpgcheck=1
enabled=0
gpgkey=https://repo.almalinux.org/almalinux/RPM-GPG-KEY-AlmaLinux-8\n" >> /etc/yum.repos.d/alma8-external.repo
```

La clé GPG est récupérée ci-dessous:
```bash
sudo -u svc_repodnf curl https://repo.almalinux.org/almalinux/RPM-GPG-KEY-AlmaLinux-8 --output /var/www/html/rpm-gpg-key/RPM-GPG-KEY-AlmaLinux-8
```

Le fichier de dépôt local est créé ci-dessous:
```bash
echo -e "[appstream-alma8-intra-at-home]
name=AppStream for Alma 8 (x86_64) - provided by Infra-at-Home
baseurl=http://vlsrepacs01/alma/8/appstream-alma8/
gpgcheck=1
enabled=1
gpgkey=http://vlsrepacs01/rpm-gpg-key/RPM-GPG-KEY-AlmaLinux-8\n" >> /var/www/html/yum.repos.d.sample/alma8-infra-at-home.repo
```

L'ajout à la liste de dépôts est réalisé ci-dessous:
```bash
echo -e "8,appstream-alma8" >> /opt/sync_sources/alma
```

La synchronisation initiale est réalisée ci-dessous:
```bash
sudo -u svc_repodnf reposync --download-metadata --delete --download-path=/var/www/html/alma/8/ --repoid=appstream-alma8
```

#### Alma Linux 8 BaseOS
Le fichier de dépôt source est créé ci-dessous:
```bash
echo -e "[baseos-alma8]
name=BaseOS for Alma 8 (x86_64)
mirrorlist=https://mirrors.almalinux.org/mirrorlist/8/baseos
gpgcheck=1
enabled=0
gpgkey=https://repo.almalinux.org/almalinux/RPM-GPG-KEY-AlmaLinux-8\n" >> /etc/yum.repos.d/alma8-external.repo
```

La clé GPG est récupérée ci-dessous:
```bash
sudo -u svc_repodnf curl https://repo.almalinux.org/almalinux/RPM-GPG-KEY-AlmaLinux-8 --output /var/www/html/rpm-gpg-key/RPM-GPG-KEY-AlmaLinux-8
```

Le fichier de dépôt local est créé ci-dessous:
```bash
echo -e "[baseos-alma8-intra-at-home]
name=BaseOS for Alma 8 (x86_64) - provided by Infra-at-Home
baseurl=http://vlsrepacs01/alma/8/baseos-alma8/
gpgcheck=1
enabled=1
gpgkey=http://vlsrepacs01/rpm-gpg-key/RPM-GPG-KEY-AlmaLinux-8\n" >> /var/www/html/yum.repos.d.sample/alma8-infra-at-home.repo
```

L'ajout à la liste de dépôts est réalisé ci-dessous:
```bash
echo -e "8,baseos-alma8" >> /opt/sync_sources/alma
```

La synchronisation initiale est réalisée ci-dessous:
```bash
sudo -u svc_repodnf reposync --download-metadata --delete --download-path=/var/www/html/alma/8/ --repoid=baseos-alma8
```

#### Alma Linux 8 Extras
Le fichier de dépôt source est créé ci-dessous:
```bash
echo -e "[extras-alma8]
name=Extras for Alma 8 (x86_64)
mirrorlist=https://mirrors.almalinux.org/mirrorlist/8/extras
gpgcheck=1
enabled=0
gpgkey=https://repo.almalinux.org/almalinux/RPM-GPG-KEY-AlmaLinux-8\n" >> /etc/yum.repos.d/alma8-external.repo
```

La clé GPG est récupérée ci-dessous:
```bash
sudo -u svc_repodnf curl https://repo.almalinux.org/almalinux/RPM-GPG-KEY-AlmaLinux-8 --output /var/www/html/rpm-gpg-key/RPM-GPG-KEY-AlmaLinux-8
```

Le fichier de dépôt local est créé ci-dessous:
```bash
echo -e "[extras-alma8-intra-at-home]
name=Extras for Alma 8 (x86_64) - provided by Infra-at-Home
baseurl=http://vlsrepacs01/alma/8/extras-alma8/
gpgcheck=1
enabled=1
gpgkey=http://vlsrepacs01/rpm-gpg-key/RPM-GPG-KEY-AlmaLinux-8\n" >> /var/www/html/yum.repos.d.sample/alma8-infra-at-home.repo
```

L'ajout à la liste de dépôts est réalisé ci-dessous:
```bash
echo -e "8,extras-alma8" >> /opt/sync_sources/alma
```

La synchronisation initiale est réalisée ci-dessous:
```bash
sudo -u svc_repodnf reposync --download-metadata --delete --download-path=/var/www/html/alma/8/ --repoid=extras-alma8
```

#### Alma Linux 8 PowerTools
Le fichier de dépôt source est créé ci-dessous:
```bash
echo -e "[powertools-alma8]
name=PowerTools for Alma 8 (x86_64)
mirrorlist=https://mirrors.almalinux.org/mirrorlist/8/powertools
gpgcheck=1
enabled=0
gpgkey=https://repo.almalinux.org/almalinux/RPM-GPG-KEY-AlmaLinux-8\n" >> /etc/yum.repos.d/alma8-external.repo
```

La clé GPG est récupérée ci-dessous:
```bash
sudo -u svc_repodnf curl https://repo.almalinux.org/almalinux/RPM-GPG-KEY-AlmaLinux-8 --output /var/www/html/rpm-gpg-key/RPM-GPG-KEY-AlmaLinux-8
```

Le fichier de dépôt local est créé ci-dessous:
```bash
echo -e "[powertools-alma8-intra-at-home]
name=PowerTools for Alma 8 (x86_64) - provided by Infra-at-Home
baseurl=http://vlsrepacs01/alma/8/powertools-alma8/
gpgcheck=1
enabled=0
gpgkey=http://vlsrepacs01/rpm-gpg-key/RPM-GPG-KEY-AlmaLinux-8\n" >> /var/www/html/yum.repos.d.sample/alma8-infra-at-home.repo
```

L'ajout à la liste de dépôts est réalisé ci-dessous:
```bash
echo -e "8,powertools-alma8" >> /opt/sync_sources/alma
```

La synchronisation initiale est réalisée ci-dessous:
```bash
sudo -u svc_repodnf reposync --download-metadata --delete --download-path=/var/www/html/alma/8/ --repoid=powertools-alma8
```

#### Alma Linux 8 EPEL
Le fichier de dépôt source est créé ci-dessous:
```bash
echo -e "[epel-alma8]
name=EPEL for Alma 8 (x86_64)
metalink=https://mirrors.fedoraproject.org/metalink?repo=epel-8&arch=x86_64&infra=os&content=
gpgcheck=1
enabled=0
gpgkey=http://fr2.rpmfind.net/linux/epel/RPM-GPG-KEY-EPEL-8\n" >> /etc/yum.repos.d/alma8-external.repo
```

La clé GPG est récupérée ci-dessous:
```bash
sudo -u svc_repodnf curl http://fr2.rpmfind.net/linux/epel/RPM-GPG-KEY-EPEL-8 --output /var/www/html/rpm-gpg-key/RPM-GPG-KEY-EPEL-8
```

Le fichier de dépôt local est créé ci-dessous:
```bash
echo -e "[epel-alma8-intra-at-home]
name=EPEL for Alma 8 (x86_64) - provided by Infra-at-Home
baseurl=http://vlsrepacs01/alma/8/epel-alma8/
gpgcheck=1
enabled=1
gpgkey=http://vlsrepacs01/rpm-gpg-key/RPM-GPG-KEY-EPEL-8\n" >> /var/www/html/yum.repos.d.sample/alma8-infra-at-home.repo
```

L'ajout à la liste de dépôts est réalisé ci-dessous:
```bash
echo -e "8,epel-alma8" >> /opt/sync_sources/alma
```

La synchronisation initiale est réalisée ci-dessous:
```bash
sudo -u svc_repodnf reposync --download-metadata --delete --download-path=/var/www/html/alma/8/ --repoid=epel-alma8
```

#### Alma Linux 8 EPEL Modular
Le fichier de dépôt source est créé ci-dessous:
```bash
echo -e "[epel-modular-alma8]
name=EPEL Modular for Alma 8 (x86_64)
metalink=https://mirrors.fedoraproject.org/metalink?repo=epel-modular-8&arch=x86_64&infra=os&content=
gpgcheck=1
enabled=0
gpgkey=http://fr2.rpmfind.net/linux/epel/RPM-GPG-KEY-EPEL-8\n" >> /etc/yum.repos.d/alma8-external.repo
```

La clé GPG est récupérée ci-dessous:
```bash
sudo -u svc_repodnf curl http://fr2.rpmfind.net/linux/epel/RPM-GPG-KEY-EPEL-8 --output /var/www/html/rpm-gpg-key/RPM-GPG-KEY-EPEL-8
```

Le fichier de dépôt local est créé ci-dessous:
```bash
echo -e "[epel-modular-alma8-intra-at-home]
name=EPEL Modular for Alma 8 (x86_64) - provided by Infra-at-Home
baseurl=http://vlsrepacs01/alma/8/epel-modular-alma8/
gpgcheck=1
enabled=0
gpgkey=http://vlsrepacs01/rpm-gpg-key/RPM-GPG-KEY-EPEL-8\n" >> /var/www/html/yum.repos.d.sample/alma8-infra-at-home.repo
```

L'ajout à la liste de dépôts est réalisé ci-dessous:
```bash
echo -e "8,epel-modular-alma8" >> /opt/sync_sources/alma
```

La synchronisation initiale est réalisée ci-dessous:
```bash
sudo -u svc_repodnf reposync --download-metadata --delete --download-path=/var/www/html/alma/8/ --repoid=epel-modular-alma8
```

#### Alma Linux 8 PostgreSQL Common
Le fichier de dépôt source est créé ci-dessous:
```bash
echo -e "[pgdg-common-alma8]
name=PGSQL Common for Alma 8 (x86_64)
baseurl=https://download.postgresql.org/pub/repos/yum/common/redhat/rhel-8-x86_64
gpgcheck=1
enabled=0
gpgkey=https://download.postgresql.org/pub/repos/yum/RPM-GPG-KEY-PGDG\n" >> /etc/yum.repos.d/alma8-external.repo
```

La clé GPG est récupérée ci-dessous:
```bash
sudo -u svc_repodnf curl https://download.postgresql.org/pub/repos/yum/RPM-GPG-KEY-PGDG --output /var/www/html/rpm-gpg-key/RPM-GPG-KEY-PGDG
```

Le fichier de dépôt local est créé ci-dessous:
```bash
echo -e "[pgdg-common-alma8-intra-at-home]
name=PGSQL Common for Alma 8 (x86_64) - provided by Infra-at-Home
baseurl=http://vlsrepacs01/alma/8/pgdg-common-alma8/
gpgcheck=1
enabled=0
gpgkey=http://vlsrepacs01/rpm-gpg-key/RPM-GPG-KEY-PGDG\n" >> /var/www/html/yum.repos.d.sample/alma8-infra-at-home.repo
```

L'ajout à la liste de dépôts est réalisé ci-dessous:
```bash
echo -e "8,pgdg-common-alma8" >> /opt/sync_sources/alma
```

La synchronisation initiale est réalisée ci-dessous:
```bash
sudo -u svc_repodnf reposync --download-metadata --delete --download-path=/var/www/html/alma/8/ --repoid=pgdg-common-alma8
```

#### Alma Linux 8 PostgreSQL 16
Le fichier de dépôt source est créé ci-dessous:
```bash
echo -e "[pgdg16-alma8]
name=PGSQL 16 for Alma 8 (x86_64)
baseurl=https://download.postgresql.org/pub/repos/yum/16/redhat/rhel-8-x86_64
gpgcheck=1
enabled=0
gpgkey=https://download.postgresql.org/pub/repos/yum/RPM-GPG-KEY-PGDG-16\n" >> /etc/yum.repos.d/alma8-external.repo
```

La clé GPG est récupérée ci-dessous:
```bash
sudo -u svc_repodnf curl https://download.postgresql.org/pub/repos/yum/RPM-GPG-KEY-PGDG16 --output /var/www/html/rpm-gpg-key/RPM-GPG-KEY-PGDG-16
```

Le fichier de dépôt local est créé ci-dessous:
```bash
echo -e "[pgdg16-alma8-intra-at-home]
name=PGSQL 16 for Alma 8 (x86_64) - provided by Infra-at-Home
baseurl=http://vlsrepacs01/alma/8/pgdg16-alma8/
gpgcheck=1
enabled=0
gpgkey=http://vlsrepacs01/rpm-gpg-key/RPM-GPG-KEY-PGDG-16\n" >> /var/www/html/yum.repos.d.sample/alma8-infra-at-home.repo
```

L'ajout à la liste de dépôts est réalisé ci-dessous:
```bash
echo -e "8,pgdg16-alma8" >> /opt/sync_sources/alma
```

La synchronisation initiale est réalisée ci-dessous:
```bash
sudo -u svc_repodnf reposync --download-metadata --delete --download-path=/var/www/html/alma/8/ --repoid=pgdg16-alma8
```

#### Alma Linux 8 PgAdmin 4
Le fichier de dépôt source est créé ci-dessous:
```bash
echo -e "[pgAdmin4-alma8]
name=pgAdmin4 for Alma 8 (x86_64)
baseurl=https://ftp.postgresql.org/pub/pgadmin/pgadmin4/yum/redhat/rhel-8-x86_64
gpgcheck=1
enabled=0
gpgkey=file:///var/www/html/rpm-gpg-key/PGADMIN_PKG_KEY\n" >> /etc/yum.repos.d/alma8-external.repo
```

La clé GPG est récupérée ci-dessous:
```bash
sudo -u svc_repodnf sh -c 'echo -e "-----BEGIN PGP PUBLIC KEY BLOCK-----

mQINBFtyz58BEACgKbtY59R0mxs8rWJNAn1BWNXwhuTvELNCV6gZkMRGFP14tMop
d9VcUx5UWiulT5wysji63xhkNljmE90jJdlxZwZ+XtnmLzIqp6i29EkAIUt1AoxM
w2ipMhfuwE6WA6VYxQihu5z2IDOR1PdDUHF5cX/GZgBon/2A33rG5IKTcaNZzL0O
c3rS5VzOzwnp1FHPlR7PY7BRDNe8q1MrQq14tlgMTaYziNg2t2YwjuhNV6G33qGE
h390aUnO/eMWIPJzKoi4mE5mhEbh4L/7sFlcRUC6Vs1xa5Ab+L5y2xoDe2grraKD
u+XpGJaDPLunlhDSTUsp0HsoLVU4ne/HNbCAm2b25tKFcFTUwDH4Ekge1/bQLCvx
kB63MMLa/FgsJ0XAr8zKEQFrc89qJU4JuvadL4hAIqZ1ywFlwTOBaNfZHbW2Pt5f
prktIL5d5jIHAdQrFPvLqhhjhM03de6O6dS5lDeP8dTdqzMcqBkwFMmjZMeRAcoJ
vs0jJNc0fYwL3h2JSWQnIhsvcSe6gk8GFVRbCCy9UplK1K/5TWw+y3mtfWwUCUSW
nBIuUTV+5iG21o3rdZgfEjXJtBAWW/hKoVwBTe5Ir9yIqaomG5ul0Sn2EgOravns
AWe2nk4l9cno5CPhGunEtiOD8YQJHskk7/NMtnPegB5j4tprXGS/cK/5hQARAQAB
tDxQYWNrYWdlIE1hbmFnZXIgKFBhY2thZ2UgU2lnbmluZyBLZXkpIDxwYWNrYWdl
c0BwZ2FkbWluLm9yZz6JAk4EEwEKADgWIQToaX4u73bALTpjMneIgbKoIQl28gUC
W3LPnwIbAwULCQgHAgYVCgkICwIEFgIDAQIeAQIXgAAKCRCIgbKoIQl28ukfD/4y
3gGysVSJU1964mpi/4NtSTruQ+fx8rN1vY/cctdQVr1ltuJsDRyPgGpXIh9zeK0/
bkCreCcuGezm2WOUFR6Kf54zMWWbIrAPpbib7rYi8n50jz7SkCfSyJZgqO2bAPBU
MP6Y09mdLaB4jib9Y6nDhFgm2V0rO64yX/bznVjBzNXFjCTgbPoABU0Guy4yHGUF
HkQ7Hdg1QLhupMWlphlMJbeSxZJx0T6ApNvr2Qg+uFykSXbXjP2e/tXGb9NeHveT
tw/hD2yMPzXJZ4uQbk8mJWDfD87fHY4ZUVqLJtKiS3omePJ5FWMPnLl0PLICkvmh
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
czb/7fY4Fah80eE59/M=
=E6/L
----END PGP PUBLIC KEY BLOCK-----" > /var/www/html/rpm-gpg-key/PGADMIN_PKG_KEY'
```

Le fichier de dépôt local est créé ci-dessous:
```bash
echo -e "[pgAdmin4-alma8-intra-at-home]
name=pgAdmin4 for Alma 8 (x86_64) - provided by Infra-at-Home
baseurl=http://vlsrepacs01/alma/8/pgAdmin4-alma8/
gpgcheck=1
enabled=0
gpgkey=http://vlsrepacs01/rpm-gpg-key/PGADMIN_PKG_KEY\n" >> /var/www/html/yum.repos.d.sample/alma8-infra-at-home.repo
```

L'ajout à la liste de dépôts est réalisé ci-dessous:
```bash
echo -e "8,pgAdmin4-alma8" >> /opt/sync_sources/alma
```

La synchronisation initiale est réalisée ci-dessous:
```bash
sudo -u svc_repodnf reposync --download-metadata --delete --download-path=/var/www/html/alma/8/ --repoid=pgAdmin4-alma8
```

#### Alma Linux 8 Percona x86_64
Le fichier de dépôt source est créé ci-dessous:
```bash
echo -e "[percona-x86_64-alma8]
name=Percona for Alma 8 (x86_64)
baseurl=https://repo.percona.com/percona/yum/release/8/RPMS/x86_64/
gpgcheck=1
enabled=0
gpgkey=https://repo.percona.com/percona/yum/PERCONA-PACKAGING-KEY\n" >> /etc/yum.repos.d/alma8-external.repo
```

La clé GPG est récupérée ci-dessous:
```bash
sudo -u svc_repodnf curl https://repo.percona.com/percona/yum/PERCONA-PACKAGING-KEY --output /var/www/html/rpm-gpg-key/PERCONA-PACKAGING-KEY
```

Le fichier de dépôt local est créé ci-dessous:
```bash
echo -e "[percona-x86_64-alma8-intra-at-home]
name=Percona for Alma 8 (x86_64) - provided by Infra-at-Home
baseurl=http://vlsrepacs01/alma/8/percona-x86_64-alma8/
gpgcheck=1
enabled=0
gpgkey=http://vlsrepacs01/rpm-gpg-key/PERCONA-PACKAGING-KEY\n" >> /var/www/html/yum.repos.d.sample/alma8-infra-at-home.repo
```

L'ajout à la liste de dépôts est réalisé ci-dessous:
```bash
echo -e "8,percona-x86_64-alma8" >> /opt/sync_sources/alma
```

La synchronisation initiale est réalisée ci-dessous:
```bash
sudo -u svc_repodnf reposync --download-metadata --delete --download-path=/var/www/html/alma/8/ --repoid=percona-x86_64-alma8
```

#### Alma Linux 8 Percona NoArch
Le fichier de dépôt source est créé ci-dessous:
```bash
echo -e "[percona-noarch-alma8]
name=Percona for Alma 8 (NoArch)
baseurl=https://repo.percona.com/percona/yum/release/8/RPMS/noarch/
gpgcheck=1
enabled=0
gpgkey=https://repo.percona.com/percona/yum/PERCONA-PACKAGING-KEY\n" >> /etc/yum.repos.d/alma8-external.repo
```

La clé GPG est récupérée ci-dessous:
```bash
sudo -u svc_repodnf curl https://repo.percona.com/percona/yum/PERCONA-PACKAGING-KEY --output /var/www/html/rpm-gpg-key/PERCONA-PACKAGING-KEY
```

Le fichier de dépôt local est créé ci-dessous:
```bash
echo -e "[percona-noarch-alma8-intra-at-home]
name=Percona for Alma 8 (NoArch) - provided by Infra-at-Home
baseurl=http://vlsrepacs01/alma/8/percona-noarch-alma8/
gpgcheck=1
enabled=0
gpgkey=http://vlsrepacs01/rpm-gpg-key/PERCONA-PACKAGING-KEY\n" >> /var/www/html/yum.repos.d.sample/alma8-infra-at-home.repo
```

L'ajout à la liste de dépôts est réalisé ci-dessous:
```bash
echo -e "8,percona-noarch-alma8" >> /opt/sync_sources/alma
```

La synchronisation initiale est réalisée ci-dessous:
```bash
sudo -u svc_repodnf reposync --download-metadata --delete --download-path=/var/www/html/alma/8/ --repoid=percona-noarch-alma8
```

#### Alma Linux 8 Zabbix 6.2
Le fichier de dépôt source est créé ci-dessous:
```bash
echo -e "[zabbix62-alma8]
name=Zabbix 6.2 for Alma 8 (x86_64)
baseurl=http://repo.zabbix.com/zabbix/6.2/rhel/8/x86_64/
gpgcheck=1
enabled=0
gpgkey=http://repo.zabbix.com/zabbix-official-repo.key\n" >> /etc/yum.repos.d/alma8-external.repo
```

La clé GPG est récupérée ci-dessous:
```bash
sudo -u svc_repodnf curl http://repo.zabbix.com/zabbix-official-repo.key --output /var/www/html/rpm-gpg-key/zabbix-official-repo.key
```

Le fichier de dépôt local est créé ci-dessous:
```bash
echo -e "[zabbix62-alma8-intra-at-home]
name=Zabbix 6.2 for Alma 8 (x86_64) - provided by Infra-at-Home
baseurl=http://vlsrepacs01/alma/8/zabbix62-alma8/
gpgcheck=1
enabled=1
gpgkey=http://vlsrepacs01/rpm-gpg-key/zabbix-official-repo.key\n" >> /var/www/html/yum.repos.d.sample/alma8-infra-at-home.repo
```

L'ajout à la liste de dépôts est réalisé ci-dessous:
```bash
echo -e "8,zabbix62-alma8" >> /opt/sync_sources/alma
```

La synchronisation initiale est réalisée ci-dessous:
```bash
sudo -u svc_repodnf reposync --download-metadata --delete --download-path=/var/www/html/alma/8/ --repoid=zabbix62-alma8
```

### Alma Linux 9
#### Alma Linux 9 AppStream
Le fichier de dépôt source est créé ci-dessous:
```bash
echo -e "[appstream-alma9]
name=AppStream for Alma 9 (x86_64)
mirrorlist=https://mirrors.almalinux.org/mirrorlist/9/appstream
gpgcheck=1
enabled=0
gpgkey=https://repo.almalinux.org/almalinux/RPM-GPG-KEY-AlmaLinux-9\n" >> /etc/yum.repos.d/alma9-external.repo
```

La clé GPG est récupérée ci-dessous:
```bash
sudo -u svc_repodnf curl https://repo.almalinux.org/almalinux/RPM-GPG-KEY-AlmaLinux-9 --output /var/www/html/rpm-gpg-key/RPM-GPG-KEY-AlmaLinux-9
```

Le fichier de dépôt local est créé ci-dessous:
```bash
echo -e "[appstream-alma9-intra-at-home]
name=AppStream for Alma 9 (x86_64) - provided by Infra-at-Home
baseurl=http://vlsrepacs01/alma/9/appstream-alma9/
gpgcheck=1
enabled=1
gpgkey=http://vlsrepacs01/rpm-gpg-key/RPM-GPG-KEY-AlmaLinux-9\n" >> /var/www/html/yum.repos.d.sample/alma9-infra-at-home.repo
```

L'ajout à la liste de dépôts est réalisé ci-dessous:
```bash
echo -e "9,appstream-alma9" >> /opt/sync_sources/alma
```

La synchronisation initiale est réalisée ci-dessous:
```bash
sudo -u svc_repodnf reposync --download-metadata --delete --download-path=/var/www/html/alma/9/ --repoid=appstream-alma9
```

#### Alma Linux 9 BaseOS
Le fichier de dépôt source est créé ci-dessous:
```bash
echo -e "[baseos-alma9]
name=BaseOS for Alma 9 (x86_64)
mirrorlist=https://mirrors.almalinux.org/mirrorlist/9/baseos
gpgcheck=1
enabled=0
gpgkey=https://repo.almalinux.org/almalinux/RPM-GPG-KEY-AlmaLinux-9\n" >> /etc/yum.repos.d/alma9-external.repo
```

La clé GPG est récupérée ci-dessous:
```bash
sudo -u svc_repodnf curl https://repo.almalinux.org/almalinux/RPM-GPG-KEY-AlmaLinux-9 --output /var/www/html/rpm-gpg-key/RPM-GPG-KEY-AlmaLinux-9
```

Le fichier de dépôt local est créé ci-dessous:
```bash
echo -e "[baseos-alma9-intra-at-home]
name=BaseOS for Alma 9 (x86_64) - provided by Infra-at-Home
baseurl=http://vlsrepacs01/alma/9/baseos-alma9/
gpgcheck=1
enabled=1
gpgkey=http://vlsrepacs01/rpm-gpg-key/RPM-GPG-KEY-AlmaLinux-9\n" >> /var/www/html/yum.repos.d.sample/alma9-infra-at-home.repo
```

L'ajout à la liste de dépôts est réalisé ci-dessous:
```bash
echo -e "9,baseos-alma9" >> /opt/sync_sources/alma
```

La synchronisation initiale est réalisée ci-dessous:
```bash
sudo -u svc_repodnf reposync --download-metadata --delete --download-path=/var/www/html/alma/9/ --repoid=baseos-alma9
```

#### Alma Linux 9 Code Ready Builder (CRB)
Le fichier de dépôt source est créé ci-dessous:
```bash
echo -e "[crb-alma9]
name=CodeReady Builder (CRB) for Alma 9 (x86_64)
mirrorlist=https://mirrors.almalinux.org/mirrorlist/9/crb
gpgcheck=1
enabled=0
gpgkey=https://repo.almalinux.org/almalinux/RPM-GPG-KEY-AlmaLinux-9\n" >> /etc/yum.repos.d/alma9-external.repo
```

La clé GPG est récupérée ci-dessous:
```bash
sudo -u svc_repodnf curl https://repo.almalinux.org/almalinux/RPM-GPG-KEY-AlmaLinux-9 --output /var/www/html/rpm-gpg-key/RPM-GPG-KEY-AlmaLinux-9
```

Le fichier de dépôt local est créé ci-dessous:
```bash
echo -e "[crb-alma9-intra-at-home]
name=CodeReady Builder (CRB) for Alma 9 (x86_64) - provided by Infra-at-Home
baseurl=http://vlsrepacs01/alma/9/crb-alma9/
gpgcheck=1
enabled=1
gpgkey=http://vlsrepacs01/rpm-gpg-key/RPM-GPG-KEY-AlmaLinux-9\n" >> /var/www/html/yum.repos.d.sample/alma9-infra-at-home.repo
```

L'ajout à la liste de dépôts est réalisé ci-dessous:
```bash
echo -e "9,crb-alma9" >> /opt/sync_sources/alma
```

La synchronisation initiale est réalisée ci-dessous:
```bash
sudo -u svc_repodnf reposync --download-metadata --delete --download-path=/var/www/html/alma/9/ --repoid=crb-alma9
```

#### Alma Linux 9 Extras
Le fichier de dépôt source est créé ci-dessous:
```bash
echo -e "[extras-alma9]
name=Extras for Alma 9 (x86_64)
mirrorlist=https://mirrors.almalinux.org/mirrorlist/9/extras
gpgcheck=1
enabled=0
gpgkey=https://repo.almalinux.org/almalinux/RPM-GPG-KEY-AlmaLinux-9\n" >> /etc/yum.repos.d/alma9-external.repo
```

La clé GPG est récupérée ci-dessous:
```bash
sudo -u svc_repodnf curl https://repo.almalinux.org/almalinux/RPM-GPG-KEY-AlmaLinux-9 --output /var/www/html/rpm-gpg-key/RPM-GPG-KEY-AlmaLinux-9
```

Le fichier de dépôt local est créé ci-dessous:
```bash
echo -e "[extras-alma9-intra-at-home]
name=Extras for Alma 9 (x86_64) - provided by Infra-at-Home
baseurl=http://vlsrepacs01/alma/9/extras-alma9/
gpgcheck=1
enabled=1
gpgkey=http://vlsrepacs01/rpm-gpg-key/RPM-GPG-KEY-AlmaLinux-9\n" >> /var/www/html/yum.repos.d.sample/alma9-infra-at-home.repo
```

L'ajout à la liste de dépôts est réalisé ci-dessous:
```bash
echo -e "9,extras-alma9" >> /opt/sync_sources/alma
```

La synchronisation initiale est réalisée ci-dessous:
```bash
sudo -u svc_repodnf reposync --download-metadata --delete --download-path=/var/www/html/alma/9/ --repoid=extras-alma9
```

#### Alma Linux 9 EPEL
Le fichier de dépôt source est créé ci-dessous:
```bash
echo -e "[epel-alma9]
name=EPEL for Alma 9 (x86_64)
metalink=https://mirrors.fedoraproject.org/metalink?repo=epel-9&arch=x86_64&infra=os&content=
gpgcheck=1
enabled=0
gpgkey=http://fr2.rpmfind.net/linux/epel/RPM-GPG-KEY-EPEL-9\n" >> /etc/yum.repos.d/alma9-external.repo
```

La clé GPG est récupérée ci-dessous:
```bash
sudo -u svc_repodnf curl http://fr2.rpmfind.net/linux/epel/RPM-GPG-KEY-EPEL-9 --output /var/www/html/rpm-gpg-key/RPM-GPG-KEY-EPEL-9
```

Le fichier de dépôt local est créé ci-dessous:
```bash
echo -e "[epel-alma9-intra-at-home]
name=EPEL for Alma 9 (x86_64) - provided by Infra-at-Home
baseurl=http://vlsrepacs01/alma/9/epel-alma9/
gpgcheck=1
enabled=1
gpgkey=http://vlsrepacs01/rpm-gpg-key/RPM-GPG-KEY-EPEL-9\n" >> /var/www/html/yum.repos.d.sample/alma9-infra-at-home.repo
```

L'ajout à la liste de dépôts est réalisé ci-dessous:
```bash
echo -e "9,epel-alma9" >> /opt/sync_sources/alma
```

La synchronisation initiale est réalisée ci-dessous:
```bash
sudo -u svc_repodnf reposync --download-metadata --delete --download-path=/var/www/html/alma/9/ --repoid=epel-alma9
```

#### Alma Linux 9 PostgreSQL Common
Le fichier de dépôt source est créé ci-dessous:
```bash
echo -e "[pgdg-common-alma9]
name=PGSQL Common for Alma 9 (x86_64)
baseurl=https://download.postgresql.org/pub/repos/yum/common/redhat/rhel-9-x86_64
gpgcheck=1
enabled=0
gpgkey=https://download.postgresql.org/pub/repos/yum/RPM-GPG-KEY-PGDG\n" >> /etc/yum.repos.d/alma9-external.repo
```

La clé GPG est récupérée ci-dessous:
```bash
sudo -u svc_repodnf curl https://download.postgresql.org/pub/repos/yum/RPM-GPG-KEY-PGDG --output /var/www/html/rpm-gpg-key/RPM-GPG-KEY-PGDG
```

Le fichier de dépôt local est créé ci-dessous:
```bash
echo -e "[pgdg-common-alma9-intra-at-home]
name=PGSQL Common for Alma 9 (x86_64) - provided by Infra-at-Home
baseurl=http://vlsrepacs01/alma/9/pgdg-common-alma9/
gpgcheck=1
enabled=0
gpgkey=http://vlsrepacs01/rpm-gpg-key/RPM-GPG-KEY-PGDG\n" >> /var/www/html/yum.repos.d.sample/alma9-infra-at-home.repo
```

L'ajout à la liste de dépôts est réalisé ci-dessous:
```bash
echo -e "9,pgdg-common-alma9" >> /opt/sync_sources/alma
```

La synchronisation initiale est réalisée ci-dessous:
```bash
sudo -u svc_repodnf reposync --download-metadata --delete --download-path=/var/www/html/alma/9/ --repoid=pgdg-common-alma9
```

#### Alma Linux 9 PostgreSQL 16
Le fichier de dépôt source est créé ci-dessous:
```bash
echo -e "[pgdg16-alma9]
name=PGSQL 16 for Alma 9 (x86_64)
baseurl=https://download.postgresql.org/pub/repos/yum/16/redhat/rhel-9-x86_64
gpgcheck=1
enabled=0
gpgkey=https://download.postgresql.org/pub/repos/yum/RPM-GPG-KEY-PGDG-16\n" >> /etc/yum.repos.d/alma9-external.repo
```

La clé GPG est récupérée ci-dessous:
```bash
sudo -u svc_repodnf curl https://download.postgresql.org/pub/repos/yum/RPM-GPG-KEY-PGDG16 --output /var/www/html/rpm-gpg-key/RPM-GPG-KEY-PGDG-16
```

Le fichier de dépôt local est créé ci-dessous:
```bash
echo -e "[pgdg16-alma9-intra-at-home]
name=PGSQL 16 for Alma 9 (x86_64) - provided by Infra-at-Home
baseurl=http://vlsrepacs01/alma/9/pgdg16-alma9/
gpgcheck=1
enabled=0
gpgkey=http://vlsrepacs01/rpm-gpg-key/RPM-GPG-KEY-PGDG-16\n" >> /var/www/html/yum.repos.d.sample/alma9-infra-at-home.repo
```

L'ajout à la liste de dépôts est réalisé ci-dessous:
```bash
echo -e "9,pgdg16-alma9" >> /opt/sync_sources/alma
```

La synchronisation initiale est réalisée ci-dessous:
```bash
sudo -u svc_repodnf reposync --download-metadata --delete --download-path=/var/www/html/alma/9/ --repoid=pgdg16-alma9
```

#### Alma Linux 9 PgAdmin4
Le fichier de dépôt source est créé ci-dessous:
```bash
echo -e "[pgAdmin4-alma9]
name=pgAdmin4 for Alma 9 (x86_64)
baseurl=https://ftp.postgresql.org/pub/pgadmin/pgadmin4/yum/redhat/rhel-9-x86_64
gpgcheck=1
enabled=0
gpgkey=file:///var/www/html/rpm-gpg-key/PGADMIN_PKG_KEY\n" >> /etc/yum.repos.d/alma9-external.repo
```

La clé GPG est récupérée ci-dessous:
```bash
sudo -u svc_repodnf sh -c 'echo -e "-----BEGIN PGP PUBLIC KEY BLOCK-----

mQINBFtyz58BEACgKbtY59R0mxs8rWJNAn1BWNXwhuTvELNCV6gZkMRGFP14tMop
d9VcUx5UWiulT5wysji63xhkNljmE90jJdlxZwZ+XtnmLzIqp6i29EkAIUt1AoxM
w2ipMhfuwE6WA6VYxQihu5z2IDOR1PdDUHF5cX/GZgBon/2A33rG5IKTcaNZzL0O
c3rS5VzOzwnp1FHPlR7PY7BRDNe8q1MrQq14tlgMTaYziNg2t2YwjuhNV6G33qGE
h390aUnO/eMWIPJzKoi4mE5mhEbh4L/7sFlcRUC6Vs1xa5Ab+L5y2xoDe2grraKD
u+XpGJaDPLunlhDSTUsp0HsoLVU4ne/HNbCAm2b25tKFcFTUwDH4Ekge1/bQLCvx
kB63MMLa/FgsJ0XAr8zKEQFrc89qJU4JuvadL4hAIqZ1ywFlwTOBaNfZHbW2Pt5f
prktIL5d5jIHAdQrFPvLqhhjhM03de6O6dS5lDeP8dTdqzMcqBkwFMmjZMeRAcoJ
vs0jJNc0fYwL3h2JSWQnIhsvcSe6gk8GFVRbCCy9UplK1K/5TWw+y3mtfWwUCUSW
nBIuUTV+5iG21o3rdZgfEjXJtBAWW/hKoVwBTe5Ir9yIqaomG5ul0Sn2EgOravns
AWe2nk4l9cno5CPhGunEtiOD8YQJHskk7/NMtnPegB5j4tprXGS/cK/5hQARAQAB
tDxQYWNrYWdlIE1hbmFnZXIgKFBhY2thZ2UgU2lnbmluZyBLZXkpIDxwYWNrYWdl
c0BwZ2FkbWluLm9yZz6JAk4EEwEKADgWIQToaX4u73bALTpjMneIgbKoIQl28gUC
W3LPnwIbAwULCQgHAgYVCgkICwIEFgIDAQIeAQIXgAAKCRCIgbKoIQl28ukfD/4y
3gGysVSJU1964mpi/4NtSTruQ+fx8rN1vY/cctdQVr1ltuJsDRyPgGpXIh9zeK0/
bkCreCcuGezm2WOUFR6Kf54zMWWbIrAPpbib7rYi8n50jz7SkCfSyJZgqO2bAPBU
MP6Y09mdLaB4jib9Y6nDhFgm2V0rO64yX/bznVjBzNXFjCTgbPoABU0Guy4yHGUF
HkQ7Hdg1QLhupMWlphlMJbeSxZJx0T6ApNvr2Qg+uFykSXbXjP2e/tXGb9NeHveT
tw/hD2yMPzXJZ4uQbk8mJWDfD87fHY4ZUVqLJtKiS3omePJ5FWMPnLl0PLICkvmh
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
czb/7fY4Fah80eE59/M=
=E6/L
----END PGP PUBLIC KEY BLOCK-----" > /var/www/html/rpm-gpg-key/PGADMIN_PKG_KEY'
```

Le fichier de dépôt local est créé ci-dessous:
```bash
echo -e "[pgAdmin4-alma9-intra-at-home]
name=pgAdmin4 for Alma 9 (x86_64) - provided by Infra-at-Home
baseurl=http://vlsrepacs01/alma/9/pgAdmin4-alma9/
gpgcheck=1
enabled=0
gpgkey=http://vlsrepacs01/rpm-gpg-key/PGADMIN_PKG_KEY\n" >> /var/www/html/yum.repos.d.sample/alma8-infra-at-home.repo
```

L'ajout à la liste de dépôts est réalisé ci-dessous:
```bash
echo -e "9,pgAdmin4-alma9" >> /opt/sync_sources/alma
```

La synchronisation initiale est réalisée ci-dessous:
```bash
sudo -u svc_repodnf reposync --download-metadata --delete --download-path=/var/www/html/alma/9/ --repoid=pgAdmin4-alma9
```

#### Alma Linux 9 Percona x86_64
Le fichier de dépôt source est créé ci-dessous:
```bash
echo -e "[percona-x86_64-alma9]
name=Percona for Alma 9 (x86_64)
baseurl=https://repo.percona.com/percona/yum/release/9/RPMS/x86_64/
gpgcheck=1
enabled=0
gpgkey=https://repo.percona.com/percona/yum/PERCONA-PACKAGING-KEY\n" >> /etc/yum.repos.d/alma9-external.repo
```

La clé GPG est récupérée ci-dessous:
```bash
sudo -u svc_repodnf curl https://repo.percona.com/percona/yum/PERCONA-PACKAGING-KEY --output /var/www/html/rpm-gpg-key/PERCONA-PACKAGING-KEY
```

Le fichier de dépôt local est créé ci-dessous:
```bash
echo -e "[percona-x86_64-alma9-intra-at-home]
name=Percona for Alma 9 (x86_64) - provided by Infra-at-Home
baseurl=http://vlsrepacs01/alma/9/percona-x86_64-alma9/
gpgcheck=1
enabled=0
gpgkey=http://vlsrepacs01/rpm-gpg-key/PERCONA-PACKAGING-KEY\n" >> /var/www/html/yum.repos.d.sample/alma9-infra-at-home.repo
```

L'ajout à la liste de dépôts est réalisé ci-dessous:
```bash
echo -e "9,percona-x86_64-alma9" >> /opt/sync_sources/alma
```

La synchronisation initiale est réalisée ci-dessous:
```bash
sudo -u svc_repodnf reposync --download-metadata --delete --download-path=/var/www/html/alma/9/ --repoid=percona-x86_64-alma9
```

#### Alma Linux 9 Percona NoArch
Le fichier de dépôt source est créé ci-dessous:
```bash
echo -e "[percona-noarch-alma9]
name=Percona for Alma 9 (NoArch)
baseurl=https://repo.percona.com/percona/yum/release/9/RPMS/noarch/
gpgcheck=1
enabled=0
gpgkey=https://repo.percona.com/percona/yum/PERCONA-PACKAGING-KEY\n" >> /etc/yum.repos.d/alma9-external.repo
```

La clé GPG est récupérée ci-dessous:
```bash
sudo -u svc_repodnf curl https://repo.percona.com/percona/yum/PERCONA-PACKAGING-KEY --output /var/www/html/rpm-gpg-key/PERCONA-PACKAGING-KEY
```

Le fichier de dépôt local est créé ci-dessous:
```bash
echo -e "[percona-noarch-alma9-intra-at-home]
name=Percona for Alma 9 (NoArch) - provided by Infra-at-Home
baseurl=http://vlsrepacs01/alma/9/percona-noarch-alma9/
gpgcheck=1
enabled=0
gpgkey=http://vlsrepacs01/rpm-gpg-key/PERCONA-PACKAGING-KEY\n" >> /var/www/html/yum.repos.d.sample/alma9-infra-at-home.repo
```

L'ajout à la liste de dépôts est réalisé ci-dessous:
```bash
echo -e "9,percona-noarch-alma9" >> /opt/sync_sources/alma
```

La synchronisation initiale est réalisée ci-dessous:
```bash
sudo -u svc_repodnf reposync --download-metadata --delete --download-path=/var/www/html/alma/9/ --repoid=percona-noarch-alma9
```

#### Alma Linux 9 Zabbix 6.4
Le fichier de dépôt source est créé ci-dessous:
```bash
echo -e "[zabbix64-alma9]
name=Zabbix 6.4 for Alma 9 (x86_64)
baseurl=http://repo.zabbix.com/zabbix/6.4/rhel/9/x86_64/
gpgcheck=1
enabled=0
gpgkey=http://repo.zabbix.com/zabbix-official-repo.key\n" >> /etc/yum.repos.d/alma9-external.repo
```

La clé GPG est récupérée ci-dessous:
```bash
sudo -u svc_repodnf curl http://repo.zabbix.com/zabbix-official-repo.key --output /var/www/html/rpm-gpg-key/zabbix-official-repo.key
```

Le fichier de dépôt local est créé ci-dessous:
```bash
echo -e "[zabbix64-alma9-intra-at-home]
name=Zabbix 6.4 for Alma 9 (x86_64) - provided by Infra-at-Home
baseurl=http://vlsrepacs01/alma/9/zabbix64-alma9/
gpgcheck=1
enabled=1
gpgkey=http://vlsrepacs01/rpm-gpg-key/zabbix-official-repo.key\n" >> /var/www/html/yum.repos.d.sample/alma9-infra-at-home.repo
```

L'ajout à la liste de dépôts est réalisé ci-dessous:
```bash
echo -e "9,zabbix64-alma9" >> /opt/sync_sources/alma
```

La synchronisation initiale est réalisée ci-dessous:
```bash
sudo -u svc_repodnf reposync --download-metadata --delete --download-path=/var/www/html/alma/9/ --repoid=zabbix64-alma9
```

<!-- 
Le fichier de dépôt source est créé ci-dessous:
```bash

```

La clé GPG est récupérée ci-dessous:
```bash

```

Le fichier de dépôt local est créé ci-dessous:
```bash

```

L'ajout à la liste de dépôts est réalisé ci-dessous:
```bash

```

La synchronisation initiale est réalisée ci-dessous:
```bash

```
-->

## Sources RSYNC
L'ajout de sources synchronisées par RSYNC se fait facilement par un référencement dans le fichier de configuration suivi d'une synchronisation initiale.

### OPNsense
OPNsense bloque régulièrement les connexions, les restreignant à un nombre limité de connexions simultannées. L'ajout de multiples dépôts permet de facilement contourner cette restriction, un dépôt à jour ne monopolisant les ressources qu'un très court laps de temps.

Ajouter différents dépôts pour la version courante de FreeBSD pour OPNsense.
```bash
echo -e "opnsense,mirror.ams1.nl.leaseweb.net/opnsense/FreeBSD:13:amd64/" >> /opt/sync_sources/rsync
echo -e "opnsense,mirror.fra10.de.leaseweb.net/opnsense/FreeBSD:13:amd64/" >> /opt/sync_sources/rsync
echo -e "opnsense,mirror.sfo12.us.leaseweb.net/opnsense/FreeBSD:13:amd64/" >> /opt/sync_sources/rsync
echo -e "opnsense,mirror.wdc1.us.leaseweb.net/opnsense/FreeBSD:13:amd64/" >> /opt/sync_sources/rsync
```

Exécuter une synchronisation initiale sur ces dépôts.
```bash
sudo -u svc_repodnf rsync --archive --hard-links --numeric-ids --stats rsync://mirror.ams1.nl.leaseweb.net/opnsense/FreeBSD:13:amd64/ /var/www/html/opnsense/
sudo -u svc_repodnf rsync --archive --hard-links --numeric-ids --stats rsync://mirror.fra10.de.leaseweb.net/opnsense/FreeBSD:13:amd64/ /var/www/html/opnsense/
sudo -u svc_repodnf rsync --archive --hard-links --numeric-ids --stats rsync://mirror.sfo12.us.leaseweb.net/opnsense/FreeBSD:13:amd64/ /var/www/html/opnsense/
sudo -u svc_repodnf rsync --archive --hard-links --numeric-ids --stats rsync://mirror.wdc1.us.leaseweb.net/opnsense/FreeBSD:13:amd64/ /var/www/html/opnsense/
```

Ajouter différents dépôts pour la version à venir de FreeBSD pour OPNsense.
```bash
echo -e "opnsense,mirror.ams1.nl.leaseweb.net/opnsense/FreeBSD:14:amd64/" >> /opt/sync_sources/rsync
echo -e "opnsense,mirror.fra10.de.leaseweb.net/opnsense/FreeBSD:14:amd64/" >> /opt/sync_sources/rsync
echo -e "opnsense,mirror.sfo12.us.leaseweb.net/opnsense/FreeBSD:14:amd64/" >> /opt/sync_sources/rsync
echo -e "opnsense,mirror.wdc1.us.leaseweb.net/opnsense/FreeBSD:14:amd64/" >> /opt/sync_sources/rsync
```


Exécuter une synchronisation initiale sur ces dépôts.
```bash
sudo -u svc_repodnf rsync --archive --hard-links --numeric-ids --stats rsync://mirror.ams1.nl.leaseweb.net/opnsense/FreeBSD:14:amd64/ /var/www/html/opnsense/
sudo -u svc_repodnf rsync --archive --hard-links --numeric-ids --stats rsync://mirror.fra10.de.leaseweb.net/opnsense/FreeBSD:14:amd64/ /var/www/html/opnsense/
sudo -u svc_repodnf rsync --archive --hard-links --numeric-ids --stats rsync://mirror.sfo12.us.leaseweb.net/opnsense/FreeBSD:14:amd64/ /var/www/html/opnsense/
sudo -u svc_repodnf rsync --archive --hard-links --numeric-ids --stats rsync://mirror.wdc1.us.leaseweb.net/opnsense/FreeBSD:14:amd64/ /var/www/html/opnsense/
```

## Sources HTTP/HTTPS (wget)
L'ajout de sources http/https se fait facilement à l'aide des étapes suivantes:
- Ajouter les informations relatives au dépôt dans le fichier listant les dépôts (cible, niveaux à couper, domaine et lien)
- Réaliser une synchronisation initiale

### iTop
Le téléchargement régulier des versions d'iTop est inutile.
Un téléchargement manuel lors des sorties de nouvelles versions est plus cohérent.

```bash
sudo -u svc_repodnf wget -P /var/www/html/itop/ https://sourceforge.net/projects/itop/files/itop/3.1.0-2/iTop-3.1.0-2-11973.zip
sudo -u svc_repodnf wget --directory-prefix=/var/www/html/itop/ https://sourceforge.net/projects/teemip/files/teemip%20-%20an%20iTop%20module/3.1.3/teemip-core-ip-mgmt-3.1.3-810.zip
```

### OpenStreetMap
Les fichiers cartographiques d'OpenStreetMap sont actualisés quotidiennement.
Un ajustement peut être effectué afin de ne télécharger que ceux utiles.

> [!TIP]
> La documentation relative à l'installation d'un serveur local OpenStreetMap détaille l'utilité de chaque fichier.

#### France
```bash
echo -e "openstreetmap/data,1,geofabric.de,https://download.geofabrik.de/europe/france-latest.osm.pbf" >> /opt/sync_sources/wget
sudo -u svc_repodnf wget -R md5,txt,html,tmp -r -nH --cut-dirs=1 -k -np -D geofabrik.de -P /var/www/html/openstreetmap/data/ https://download.geofabrik.de/europe/france-latest.osm.pbf
```

#### Afrique
```bash
echo -e "openstreetmap/data,0,geofabric.de,https://download.geofabrik.de/africa-latest.osm.pbf" >> /opt/sync_sources/wget
sudo -u svc_repodnf wget -R md5,txt,html,tmp -r -nH --cut-dirs=0 -k -np -D geofabrik.de -P /var/www/html/openstreetmap/data/ https://download.geofabrik.de/africa-latest.osm.pbf
```

#### Amérique centrale
```bash
echo -e "openstreetmap/data,0,geofabric.de,https://download.geofabrik.de/central-america-latest.osm.pbf" >> /opt/sync_sources/wget
sudo -u svc_repodnf wget -R md5,txt,html,tmp -r -nH --cut-dirs=0 -k -np -D geofabrik.de -P /var/www/html/openstreetmap/data/ https://download.geofabrik.de/central-america-latest.osm.pbf
```

#### Amérique du nord
```bash
echo -e "openstreetmap/data,0,geofabric.de,https://download.geofabrik.de/north-america-latest.osm.pbf" >> /opt/sync_sources/wget
sudo -u svc_repodnf wget -R md5,txt,html,tmp -r -nH --cut-dirs=0 -k -np -D geofabrik.de -P /var/www/html/openstreetmap/data/ https://download.geofabrik.de/north-america-latest.osm.pbf
```

#### Amérique du sud
```bash
echo -e "openstreetmap/data,0,geofabric.de,https://download.geofabrik.de/south-america-latest.osm.pbf" >> /opt/sync_sources/wget
sudo -u svc_repodnf wget -R md5,txt,html,tmp -r -nH --cut-dirs=0 -k -np -D geofabrik.de -P /var/www/html/openstreetmap/data/ https://download.geofabrik.de/south-america-latest.osm.pbf
```

#### Antarctique
```bash
echo -e "openstreetmap/data,0,geofabric.de,https://download.geofabrik.de/antarctica-latest.osm.pbf" >> /opt/sync_sources/wget
sudo -u svc_repodnf wget -R md5,txt,html,tmp -r -nH --cut-dirs=0 -k -np -D geofabrik.de -P /var/www/html/openstreetmap/data/ https://download.geofabrik.de/antarctica-latest.osm.pbf
```

#### Asie
```bash
echo -e "openstreetmap/data,0,geofabric.de,https://download.geofabrik.de/asia-latest.osm.pbf" >> /opt/sync_sources/wget
sudo -u svc_repodnf wget -R md5,txt,html,tmp -r -nH --cut-dirs=0 -k -np -D geofabrik.de -P /var/www/html/openstreetmap/data/ https://download.geofabrik.de/asia-latest.osm.pbf
```

#### Europe
```bash
echo -e "openstreetmap/data,0,geofabric.de,https://download.geofabrik.de/europe-latest.osm.pbf" >> /opt/sync_sources/wget
sudo -u svc_repodnf wget -R md5,txt,html,tmp -r -nH --cut-dirs=0 -k -np -D geofabrik.de -P /var/www/html/openstreetmap/data/ https://download.geofabrik.de/europe-latest.osm.pbf
```

#### Océanie
```bash
echo -e "openstreetmap/data,0,geofabric.de,https://download.geofabrik.de/australia-oceania-latest.osm.pbf" >> /opt/sync_sources/wget
sudo -u svc_repodnf wget -R md5,txt,html,tmp -r -nH --cut-dirs=0 -k -np -D geofabrik.de -P /var/www/html/openstreetmap/data/ https://download.geofabrik.de/australia-oceania-latest.osm.pbf
```

#### Planète entière
```bash
echo -e "openstreetmap/data,1,openstreetmap.org,http://planet.openstreetmap.org/pbf/planet-latest.osm.pbf" >> /opt/sync_sources/wget
sudo -u svc_repodnf wget -R md5,txt,html,tmp -r -nH --cut-dirs=1 -k -np -D openstreetmap.org -P /var/www/html/openstreetmap/data/ http://planet.openstreetmap.org/pbf/planet-latest.osm.pbf
```

## Sources Git
> [!CAUTION]
> Ce type de dépôt doit être créé.

### Apache Guacamole



## Base de signatures virales ClamAV
ClamAV ne permet pas le téléchargement automatique des fichiers de mises à jour. Cependant, le serveur disposant lui-même de l'antivirus, une simple copie de ses bases de définition aboutit au même résultat.

> [!NOTE]
> La mise à jour des paquets est assurée par la mise à jour du système, ceux-ci faisant partie du dépôt EPEL.

```bash
echo -e "  15 *  *  *  * root       /usr/bin/cp /var/lib/clamav/* /var/www/html/clamav-antivirus/" >> /etc/crontab
```

> [!NOTE]
> Si la [configuration durcie](../00-Descriptif/02-Hardening/02-01-Alma9.md) a été appliquée, les mises à jour ne sont pas récupérées en ligne.
> Il est alors nécessaire de mettre à jour la source de mises à jour de ClamAV.
> ```bash
> sed -i -- 's+PrivateMirror vlsrepacs01+#PrivateMirror vlsrepacs01+g' /etc/freshclam.conf
> sed -i -- 's+#DatabaseMirror database.clamav.net+DatabaseMirror database.clamav.net+g' /etc/freshclam.conf
> ```

Pour revenir à la configuration de la DMZ, [cliquez ici](README.md).