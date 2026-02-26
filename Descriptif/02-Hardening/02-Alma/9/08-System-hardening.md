> [!NOTE]
> Le système est supposé installé conformément au chapitre d'[installation](01-Installation.md), les [points de montage ont été reconfigurés](02-Mount-points.md), la [synchronisation temporelle est assurée](03-Time-sync.md), l'[installation de paquets complémentaires](04-Packages-install.md), la [reconfiguration du noyau](05-Kernel-compilation.md), la [configuration des banniaères](06-Bruce-banner.md) et le [stockage des mots de passe](07-Password-storage.md).

### Durcissement système

Un durcissement du système est également nécessaire.

```bash
echo "# This file is part of Infr@Home Information System
# It is under GPL-V3 license
#
# Versionning
# YYYYMMDD_hhmm | Author                | Changelog
# 20201018_1442 | jmy37                 | File creation
#
# Disable SysReq
kernel.sysrq = 0

# No core dump for executable setuid
fs.suid_dumpable = 0

# Protecting symlinks and hardlinks
fs.protected_symlinks = 1
fs.protected_hardlinks = 1

# ASLR activation
kernel.randomize_va_space = 2

# No memory mapping in low addresses
vm.mmap_min_addr = 65536

# Expand max value for PID attribution
kernel.pid_max = 65536

# Obfuscation of kernel memory addressing
kernel.kptr_restrict = 1

# Access restriction to dmesg buffer
kernel.dmesg_restrict = 1

# Restrict perf subsystem usage
kernel.perf_event_paranoid = 2
kernel.perf_event_max_sample_rate = 1
kernel.perf_cpu_time_max_percent = 1" > /etc/sysctl.d/10-system-hardening.conf
```

Les paramètres sysctl seront appliqués après redémarrage du système.

> **Préciser comment appliquer en live, et comment contrôler l'ordre d'application des paramètres.**

> [!INFO]
> Un contrôle de l'application de chaque paramètre peut être réalisé en bash, à l'aide de ``sysctl <paramètre>`` qui renverra la valeur actuellement chargée.
> Par exemple, le contrôle du paramètre ``kernel.sysrq`` est réalisé à l'aide de la commande ``sysctl kernel.sysrq``.

Le durcissement du système et du réseau étant terminée, poursuivre avec le [durcissement réseau](./09-Network-hardening.md).