> [!NOTE]
> Le système est supposé installé conformément au chapitre d'[installation](01-Installation.md), les [points de montage ont été reconfigurés](02-Mount-points.md), la [synchronisation temporelle est assurée](03-Time-sync.md), l'[installation de paquets complémentaires](04-Packages-install.md), la [reconfiguration du noyau](05-Kernel-compilation.md), la [configuration des banniaères](06-Bruce-banner.md), le [stockage des mots de passe](07-Password-storage.md) et le [durcissement du système](08-System-hardening.md).

### Durcissement réseau

Une première étape consiste à renforcer le réseau.

> [!WARNING]
> L'application stricte de ces paramètres implique la désactivation complète de l'IPv6.

```bash
echo "# This file is part of Infr@Home Information System
# It is under GPL-V3 license
#
# Versionning
# YYYYMMDD_hhmm | Author                | Changelog
# 20201018_1444 | jmy37                 | File creation
#
# No routing between interfaces
net.ipv4.ip_forward = 0

# Reverse filtering
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1

# No ICMP redirections
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0

# No routing packets
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.default.accept_source_route = 0

# No ICMP redirect type packets
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.all.secure_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.default.secure_redirects = 0

# Log abnormal IPs packets
net.ipv4.conf.all.log_martians = 1
net.ipv4.conf.default.log_martians = 1

# RFC 1337
net.ipv4.tcp_rfc1337 = 1

# Ignore bogus error responses (uncompliant with RFC 1122)
net.ipv4.icmp_ignore_bogus_error_responses = 1

# Enlarge ephemeris port pool
net.ipv4.ip_local_port_range = 32768 65535

# Use SYN cookies
net.ipv4.tcp_syncookies = 1

# Ignore ICMP broadcast
net.ipv4.icmp_echo_ignore_broadcasts = 1

# Disable all IPv6
net.ipv6.conf.all.disable_ipv6 = 1

# Disable router solicitations support
net.ipv6.conf.all.router_solicitations = 0
net.ipv6.conf.default.router_solicitations = 0

# Disable router preferences by router advertisements
net.ipv6.conf.all.accept_ra_rtr_pref = 0
net.ipv6.conf.default.accept_ra_rtr_pref = 0

# No autoconf from router advertisements
net.ipv6.conf.all.autoconf = 0
net.ipv6.conf.default.autoconf = 0

# No ICMP redirect
net.ipv6.conf.all.accept_redirects = 0
net.ipv6.conf.default.accept_redirects = 0

# No routing packets
net.ipv6.conf.all.accept_source_route = 0
net.ipv6.conf.default.accept_source_route = 0

# Setting up a max value for interface autoconf
net.ipv6.conf.all.max_addresses = 1
net.ipv6.conf.default.max_addresses = 1" > /etc/sysctl.d/10-network-hardening.conf
```

Les paramètres sysctl seront appliqués après redémarrage du système.

> **Préciser comment appliquer en live, et comment contrôler l'ordre d'application des paramètres.**

> [!INFO]
> Un contrôle de l'application de chaque paramètre peut être réalisé en bash, à l'aide de ``sysctl <paramètre>`` qui renverra la valeur actuellement chargée.
> Par exemple, le contrôle du paramètre ``kernel.sysrq`` est réalisé à l'aide de la commande ``sysctl kernel.sysrq``.

Le durcissement du réseau étant terminée, poursuivre avec les [optimisations réseau](./10-Networking-optimizations.md).