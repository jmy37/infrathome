> [!NOTE]
> Le système est supposé installé conformément au chapitre d'[installation](01-Installation.md), les [points de montage ont été reconfigurés](02-Mount-points.md), la [synchronisation temporelle est assurée](03-Time-sync.md), l'[installation de paquets complémentaires](04-Packages-install.md), la [reconfiguration du noyau](05-Kernel-compilation.md), la [configuration des banniaères](06-Bruce-banner.md), le [stockage des mots de passe](07-Password-storage.md), le [durcissement système](08-System-hardening.md) et le [ducrissement réseau](09-Network-hardening.md).

### Optimisation du réseau

Quelques optimisations permettent d'accélérer les résolutions DNS.

> **Préciser le rôle de ces options et regarder celles qui peuevnt être ajoutées.**

```bash
echo -e 'RES_OPTIONS="single-request-reopen timeout:1 attempts:1"' >> /etc/sysconfig/network
```

Les optimisations réseau étant terminées, poursuivre avec la [configuration d'audit](./11-Auditing-config.md).