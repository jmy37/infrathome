> [!TIP]
> Le système est supposé installé conformément au chapitre d'[installation](01-Installation.md), les [points de montage ont été reconfigurés](02-Mount-points.md), la [synchronisation temporelle est assurée](03-Time-sync.md), l'[installation de paquets complémentaires](04-Packages-install.md), la [reconfiguration du noyau](05-Kernel-compilation.md), la [configuration des banniaères](06-Bruce-banner.md), le [stockage des mots de passe](07-Password-storage.md), le [durcissement système](08-System-hardening.md), le [ducrissement réseau](09-Network-hardening.md) et les [optimisations réseau](10-Networking-optimizations.md).

### Configuration élémentaire d'auditd

Auditd permet une journalisation des actions des utilisateurs.

```bash
echo -e '# insmod, rmmod and modprobe
-w /sbin/insmod   -p x
-w /sbin/modprobe -p x
-w /sbin/rmmod    -p x

# Changes under /etc/
-w /etc/ -p wa

# Monitoring mounting/unmounting filesystems
-a exit ,always -S mount -S umount2

# x86 suspect syscalls
-a exit ,always -S ioperm -S modify_ldt

# Uncommon/suspects syscalls
-a exit ,always -S get_kernel_syms -S ptrace
-a exit ,always -S prctl

# Create/Delete files (disable if perf are more important than audit)
-a exit ,always -F arch=b64 -S unlink -S rmdir -S rename
-a exit ,always -F arch=b64 -S creat -S open -S openat -F exit=-EACCESS
-a exit ,always -F arch=b64 -S truncate -S ftruncate -F exit=-EACCESS

# Locking auditd config
-e 2' >> /etc/audit/rules.d/audit.rules
```

> [!CAUTION]
> Le système dispose d'une configuration élémentaire, mais insuffisante.\
> Une configuration fine d'iptables est également indispensable.\
> Attention aux configurations à venir, pouvant affaiblir la configuration mise en place dans ce premier guide.