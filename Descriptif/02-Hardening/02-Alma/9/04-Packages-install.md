> [!TIP]
> Le système est supposé installé conformément au chapitre d'[installation](01-Installation.md), les [points de montage ont été reconfigurés](02-Mount-points.md) et la [synchronisation temporelle est assurée](03-Time-sync.md).

### Installation de paquets complémentaires
Certains paquets utiles ne sont pas intégrés à la distribution par défaut et doivent être installés manuellement. Le système doit également être mis à jour.

```bash
# Mise à jour du système
dnf -y update
# Installation de mlocate (indexation et recherches) et rsyslog
dnf -y install mlocate rsyslog
```

> **Intégrer une description des paquets.**

> [!NOTE]
> Dans le cadre d'une machine virtuelle, les extensions invités doivent être installées.

Pour VMware:
```bash
# Installation des additions invités pour un hôte VMware
dnf -y install open-vm-tools
```

Pour Hyper-V:
```bash
# Installation des additions invités pour un hôte Hyper-V
dnf -y install hyperv-daemons
```

Pour KVM:
```bash
# Installation des additions invités pour un hôte KVM
dnf -y install qemu-guest-agent
```

L'installation de paquets complémentaires étant terminée, poursuivre avec la [reconfiguration du noyau](./05-Kernel-compilation.md).