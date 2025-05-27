Document: Pare-feu externe PFsense\
Projet: Infr@home\
Localisation: DMZ\
GitHub: https://github.com/jmy37/infrathome\
Type de document: Guide d'installation\
Licence: GNU FDL 1.3

# Licence
Copyright © 2021 – jmy37\
Il est permis de copier, distribuer et/ou modifier ce document selon les termes de la licence GNU Free Documentation, version 1.3 ou une version ultérieure publiée par la Free Software Foundation, sans modifier de section, de page de garde ou de clôture.\
[La licence est en ligne](https://www.gnu.org/licenses/fdl-1.3.html).

# Historique des modifications

| **Version** | **Date**   | **Auteur** | **Objet de la modification**                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       |
| ----------- | ---------- | ---------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **1.0**     | 20/10/2020 | jmy37      | Création du document                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               |
| **1.1**     | 09/12/2020 | jmy37      | Ajout du serveur NTP (titre 5.7)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   |
| **2.0**     |            | jmy37      | Renommage du document pour séparer les pares-feux internes et externes<br><br>Mise à jour de la licence vers FDL 1.3<br><br>Ajout d’un disclaimer relatif aux choix des pares-feux au titre 3.1<br><br>Passage du routeur en UTC au titre 4<br><br>Ajout du layout français en console au titre 4<br><br>Ajout de la configuration au titre 5<br><br>Revue des alias au titre 7.1 et ruissellement dans la suite du document<br><br>Création de l’annexe 8.1 relative à la configuration de clients NTP<br><br>Création de l’annexe 8.3 relative aux alias du projet<br><br>Création de l’annexe 8.4 relative aux règles du projet |

# Préambule
Ce document décrit l’installation, l’exploitation et la résolution de pannes associées au composant « Pare-feu » de la solution « Infr@home ».

## Le projet PFsense
PFSense est une solution de pare-feu s’appuyant sur le système d’exploitation FreeBSD. Le suivi du projet est assuré par la société Netgate. Le site [https://www.pfsense.org/](https://www.pfsense.org/) met à disposition le téléchargement des sources et de nombreuses documentations relatives au projet.

**Ce pare-feu est choisi dans le cadre du projet car il est disponible en sources ouvertes. Cependant, les deux pares-feux ne devraient pas être issus d’un même développement ; un pare-feu au moins devrait être un produit qualifié par l’ANSSI (idéalement le plus proche d’Internet).**

## Configuration requise
La [configuration minimale](https://docs.netgate.com/pfsense/en/latest/book/hardware/minimum-hardware-requirements.html) (trafic non-chiffré à 100Mo/s) pour PFSense est définie ci-dessous.

| **Composant**    | **Serveur virtuel**             | **Serveur physique**             |
| ---------------- | ------------------------------- | -------------------------------- |
| **Processeur**   | 1 cœur                          | 600MHz                           |
| **Mémoire vive** | 1Go                             | 1Go                              |
| **Stockage**     | 4Go                             | 4Go                              |
| **Réseau**       | Au moins une par réseau soutenu | Au moins une par réseau physique |

Les performances requises peuvent être affinées en fonction des fonctionnalités à activer. Le détail des calculs est donné sur [le site de PFsense](https://docs.netgate.com/pfsense/en/latest/book/hardware/hardware-sizing-guidance.html#feature-considerations).

Il est ensuite nécessaire de récupérer la dernière image ISO de PFSense depuis le site de l’éditeur, en architecture x64 : [https://www.pfsense.org/download/](https://www.pfsense.org/download/).

L’installation peut alors commencer.