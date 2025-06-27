> [!TIP]
> Le système est supposé installé conformément au chapitre d'[installation](01-Installation.md), les [points de montage ont été reconfigurés](02-Mount-points.md), la [synchronisation temporelle est assurée](03-Time-sync.md), l'[installation de paquets complémentaires](04-Packages-install.md) et la [reconfiguration du noyau](05-Kernel-compilation.md).

### Mise en place d'une bannière
La bannière a un caractère légal, définissant clairement qu'il est interdit de se connecter à l’équipement. Il est également judicieux, afin de rendre plus difficile l'exploitation d'une éventuelle faille de sécurité, de ne pas y exposer son système d'exploitation ou la version de son noyau.

```bash
# Mise en place d'une bannière au démarrage du système
echo "---- UNAUTHORIZED ACCESS TO THIS DEVICE IS PROHIBITED       ----

---- LES ACCES NON-AUTORISES A CET EQUIPEMENT SONT PROHIBES ----

You must have explicit, authorized permission to access or configure this device. Unauthorized attempts and actions to access or use this system may result in civil and/or criminal penalties. All activities performed on this device are logged and monitored.

Vous devez avoir une autorisation explicite afin d'acceder ou de configurer cet equipement. Les tentatives non-autorisees et les actions pour acceder ou utiliser ce systeme peuvent conduire a des poursuites civiles et/ou penales. Toutes les activites realisees sur cet equipement sont enregistrees et supervisees." > /etc/issue
```

La bannière doit ensuite être déployée pour les connexions SSH.

```bash
# Remplacement de la bannière par défaut du serveur SSH par la bannière système
sed -i -- 's+#Banner none+Banner /etc/issue+g' /etc/ssh/sshd_config
```

La configuration des bannières étant terminée, poursuivre avec la [configuration du stockage des mots de passe](./07-Password-storage.md).