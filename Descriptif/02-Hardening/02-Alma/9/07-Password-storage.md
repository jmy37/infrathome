> [!NOTE]
> Le système est supposé installé conformément au chapitre d'[installation](01-Installation.md), les [points de montage ont été reconfigurés](02-Mount-points.md), la [synchronisation temporelle est assurée](03-Time-sync.md), l'[installation de paquets complémentaires](04-Packages-install.md), la [reconfiguration du noyau](05-Kernel-compilation.md) et la [configuration des banniaères](06-Bruce-banner.md).

### Politique de mots de passe
Le stockage des mots de passe doit être réalisé en utilisant des suites de chiffrement robustes.

> **Expliquer les configurations réalisées.**

```bash
echo -e "# This file is part of Infr@Home Information System
# It is under GPL-V3 license
#
# Versionning
# YYYYMMDD_hhmm | Author                | Changelog
# 20201018_1436 | jmy37                 | File creation
#
password   required     pam_unix.so obscure sha512 rounds=65536" >> /etc/pam.d/common-password

chown root:root /etc/pam.d/common-password
chmod 644 /etc/pam.d/common-password

echo "SHA_CRYPT_MIN_ROUNDS 65536\n" >> /etc/login.defs
```

La configuration du stockage des mots de passe étant terminée, poursuivre avec le [durcissement système](./08-System-hardening.md).