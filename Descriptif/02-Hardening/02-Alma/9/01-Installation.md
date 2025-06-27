### Installation du système
1. Choisir la langue et la disposition de clavier françaises
2. Sous ``Système``, accéder à ``Réseau et nom d'hôte``
	1. Définir le nom d'hôte au format FQDN
	2. Configurer le réseau (dans cette documentation, en DHCP) et l'activer
3. Sous ``Utilisateurs``, accéder à la ``Création de l'utilisateur``
	1. Renseigner l'identité, le nom d'utilisateur et le mot de passe (dans cette documentation, ``adminfra``|``adminfra``|``1fr@home``)
	2. Faire de cet utilisateur un administrateur (cette configuration désactive le compte ``root``)
4. Sous ``Localisation``, accéder à ``Heure et date``
	1. Choisir la région ``Etc`` et la ville ``Temps universel coordonné``
	2. Activer l'heure du réseau (synchronisation NTP)
5. Sous ``Logiciel``, accéder à la ``Source d'installation`` et choisir ``Sur le réseau: Miroir le plus proche``
6. Sous ``Logiciel``, accéder à la ``Sélection de logiciels`` et choisir une ``Installation minimale``
7. Sous ``Système``, accéder à ``Destination de l'installation`` et choisir une configuration personnalisée du stockage ; le stockage sera conforme au tableau ci-dessous:

| Point de montage | Capacité | Système de fichiers  | Groupe de volumes | Volume logique |
| ---------------- | -------- | -------------------- | ----------------- | -------------- |
| /boot            | 1Go      | xfs                  | Non-concerné      | Non-concerné   |
| /boot/efi        | 1Go      | EFI System Partition | Non-concerné      | Non-concerné   |
| /etc/lvm         | 512Mo    | xfs                  | VG_System         | LV_etc_lvm     |
| /home            | 512Mo    | xfs                  | VG_System         | LV_home        |
| /opt             | 512Mo    | xfs                  | VG_System         | LV_opt         |
| /var/cache       | 3Go      | xfs                  | VG_System         | LV_var_cache   |
| /var/log         | 2Go      | xfs                  | VG_System         | LV_var_log     |
| /var/spool       | 2Go      | xfs                  | VG_System         | LV_var_spool   |
| /                | 2Go      | xfs                  | VG_System         | LV_root        |
| /tmp             | 512Mo    | xfs                  | VG_System         | LV_tmp         |
| /usr             | 5Go      | xfs                  | VG_System         | LV_usr         |
| /var             | 3Go      | xfs                  | VG_System         | LV_var         |
| swap             | 4Go      | xfs                  | VG_System         | LV_swap        |

> [!TIP]
> La taille du swap peut être ajustée finement en fonction de la configuration du système. [RedHat](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/9/html/managing_storage_devices/getting-started-with-swap_managing-storage-devices#recommended-system-swap-space_getting-started-with-swap) préconise différentes tailles en fonction de la quantité de mémoire vive disponible et de l'activation de l'hibernation.
> 
> | Mémoire vive du serveur | Taille de swap recommandée (sans hibernation) | Taille de swap recommandée (avec hibernation) |
> | ----------------------- | --------------------------------------------- | --------------------------------------------- |
> | ≤ 2Go                   | Mémoire vive multipliée par 2                 | Mémoire vive multipliée par 3                 |
> | > 2Go et ≤ 8Go          | = mémoire vive                                | Mémoire vive multipliée par 2                 |
> | > 8Go et ≤ 64Go         | Au moins 4Go                                  | Mémoire vive multipliée par 1,5               |
> | > 64Go                  | Au moins 4Go                                  | Hibernation non-recommandée                   |

L'installation étant terminée, poursuivre avec la [configuration initiale du système](./02-Mount-points.md).