> [!NOTE]
> Le système est supposé installé conformément au chapitre d'[installation](01-Installation.md), les [points de montage ont été reconfigurés](02-Mount-points.md), la [synchronisation temporelle est assurée](03-Time-sync.md) et l'[installation de paquets complémentaires](04-Packages-install.md).

### Reconfiguration du noyau
Avant de procéder à une recompilation du noyau, il est important de noter les paramètres initiaux.

```bash
# Interrogation des paramètres actuels de GRUB
grubby --info DEFAULT
index=0
kernel="/boot/vmlinuz-5.14.0-570.21.1.el9_6.x86_64"
args="ro crashkernel=1G-4G:192M,4G-64G:256M,64G-:512M resume=/dev/mapper/VG_System-LV_swap rd.lvm.lv=VG_System/LV_root rd.lvm.lv=VG_System/LV_swap rd.lvm.lv=VG_System/LV_usr"
root="/dev/mapper/VG_System-LV_root"
initrd="/boot/initramfs-5.14.0-570.21.1.el9_6.x86_64.img"
title="AlmaLinux (5.14.0-570.21.1.el9_6.x86_64) 9.6 (Sage Margay)"
id="c2971228158949fea95e94ff39160644-5.14.0-570.21.1.el9_6.x86_64"
```

Les principales modifications seront des ajouts d'arguments:
- Audit du kernel à l'aide de ``audit=1``
- Désactivation globale de l'IPv6 à l'aide de ``ipv6.disable=1``
- Activation de l'IOMMU à l'aide de ``iommu=force``

> **Expliquer les concepts.**

Il faut ajouter les arguments nécessaires à ceux existants.

```bash
# Mise à jour des arguments
grubby --update-kernel=ALL --args="ro crashkernel=1G-4G:192M,4G-64G:256M,64G-:512M resume=/dev/mapper/VG_System-LV_swap rd.lvm.lv=VG_System/LV_root rd.lvm.lv=VG_System/LV_swap rd.lvm.lv=VG_System/LV_usr audit=1 ipv6.disable=1 iommu=force"
```

La reconfiguration du noyau étant terminée, poursuivre avec la [mise en place d'une bannière](./06-Bruce-banner.md).