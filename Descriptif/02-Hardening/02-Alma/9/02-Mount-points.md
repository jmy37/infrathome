> [!TIP]
> Le système est supposé installé conformément au chapitre d'[installation](01-Installation.md).

### Options de montage des points de montage
Spécifier les options de points de montage tel que définis dans le tableau ci-dessous:
| Point de montage | Options de montage         |
| ---------------- | -------------------------- |
| /boot            | defaults                   |
| /boot/efi        | umask=0077,shortname=winnt |
| /etc/lvm         | defaults                   |
| /home            | nosuid,nodev,noexec        |
| /opt             | nosuid,nodev               |
| /var/cache       | nosuid,nodev,noexec        |
| /var/log         | nosuid,nodev,noexec        |
| /var/spool       | nosuid,nodev,noexec        |
| /                | defaults                   |
| /tmp             | nosuid,nodev,noexec        |
| /usr             | nodev                      |
| /var             | nosuid,nodev,noexec        |
| swap             | defaults                   |

> **Intégrer une description des différentes options dans un tableau.**

Ces points de montage peuvent être définis à l'aide des commandes ci-dessous:

> [!WARNING]
> Penser à vérifier la bonne mise à jour des différents paramètres.

```bash
# Mise à jour des options de montage de /
sed -i -- 's+LV_root /                       xfs     defaults        0 0+LV_root             /              xfs  defaults                   0 0+g' /etc/fstab
# Mise à jour des options de montage de /boot
sed -i -- 's+/boot                   xfs     defaults        0 0+/boot          xfs  defaults                   0 0+g' /etc/fstab
# Mise à jour des options de montage de /boot/efi
sed -i -- 's+/boot/efi               vfat    umask=0077,shortname=winnt 0 2+                  /boot/efi      vfat umask=0077,shortname=winnt 0 2+g' /etc/fstab
# Mise à jour des options de montage de /etc/lvm
sed -i -- 's+LV_etc_lvm /etc/lvm                xfs     defaults        0 0+LV_etc_lvm          /etc/lvm       xfs  defaults                   0 0+g' /etc/fstab
# Mise à jour des options de montage de /home
sed -i -- 's+LV_home /home                   xfs     defaults        0 0+LV_home             /home          xfs  nosuid,nodev,noexec        0 0+g' /etc/fstab
# Mise à jour des options de montage de /opt
sed -i -- 's+LV_opt /opt                    xfs     defaults        0 0+LV_opt              /opt           xfs  nosuid,nodev               0 0+g' /etc/fstab
# Mise à jour des options de montage de /tmp
sed -i -- 's+LV_tmp /tmp                    xfs     defaults        0 0+LV_tmp              /tmp           xfs  nosuid,nodev,noexec        0 0+g' /etc/fstab
# Mise à jour des options de montage de /usr
sed -i -- 's+LV_usr /usr                    xfs     defaults        0 0+LV_usr              /usr           xfs  nodev                      0 0+g' /etc/fstab
# Mise à jour des options de montage de /var
sed -i -- 's+LV_var /var                    xfs     defaults        0 0+LV_var              /var           xfs  nosuid,nodev,noexec        0 0+g' /etc/fstab
# Mise à jour des options de montage de /var/cache
sed -i -- 's+LV_var_cache /var/cache              xfs     defaults        0 0+LV_var_cache        /var/cache     xfs  nosuid,nodev,noexec        0 0+g' /etc/fstab
# Mise à jour des options de montage de /var/log
sed -i -- 's+LV_var_log /var/log                xfs     defaults        0 0+LV_var_log          /var/log       xfs  nosuid,nodev,noexec        0 0+g' /etc/fstab
# Mise à jour des options de montage de /var/spool
sed -i -- 's+LV_var_spool /var/spool              xfs     defaults        0 0+LV_var_spool        /var/spool     xfs  nosuid,nodev,noexec        0 0+g' /etc/fstab
# Mise à jour des options de montage du swap
sed -i -- 's+LV_swap none                    swap    defaults        0 0+LV_swap             none           swap defaults                   0 0+g' /etc/fstab
# Prise en compte des modifications par systemctl
systemctl daemon-reload
```

La configuration des points de montage étant terminée, poursuivre avec la [synchronisation temporelle](./03-Time-sync.md).