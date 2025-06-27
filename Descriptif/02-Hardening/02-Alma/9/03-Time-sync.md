> [!TIP]
> Le système est supposé installé conformément au chapitre d'[installation](01-Installation.md) et les [points de montage ont été reconfigurés](02-Mount-points.md).

### Synchronisation temporelle
Si la configuration du fuseau horaire n'a pas été correctement configurée à l'installation, elle peut être forcée.
```bash
# Définition du fuseau horaire en UTC
timedatectl set-timezone UTC
```
Un contrôle peut être réalisé.
```bash
# Interrogation des sources de chrony
chronyc sources
# Résultat
MS Name/IP address         Stratum Poll Reach LastRx Last sample
===============================================================================
^+ vps-4fbcd565.vps.ovh.net      2  10   377    57  +1920us[+1920us] +/-   16ms
^- caladan.siberien.tf           2  10   377   277    +94us[  +94us] +/-   55ms
^- ns1.univ-montp3.fr            2  10   377   289   +882us[ +882us] +/-   33ms
^* 82-64-45-50.subs.proxad.>     1  10   377   724   +194us[+2709ns] +/- 7970us
```
Les résultats s'interprètent de la manière suivante:

<table>
	<tr>
		<th>Colonne</th>
		<th>Description</th>
		<th>Valeur</th>
		<th>Signification</th>
	</tr>
	<tr>
		<td rowspan="3">M</td>
		<td rowspan="3">Mode de la source</td>
		<td>^</td>
		<td>Serveur</td>
	</tr>
	<tr>
		<td>=</td>
		<td>Peer</td>
	</tr>
	<tr>
		<td>#</td>
		<td>Référence locale</td>
	<tr>
		<td rowspan="6">S</td>
		<td rowspan="6">Statut</td>
		<td>**</td>
		<td>Synchronisée</td>
	</tr>
	<tr>
		<td>+</td>
		<td>Source acceptable prise en compte par l'algorithme</td>
	</tr>
	<tr>
		<td>-</td>
		<td>Source acceptable exclue par l'algorithme</td>
	</tr>
	<tr>
		<td>?</td>
		<td>Source hors-ligne</td>
	</tr>
	<tr>
		<td>x</td>
		<td>Source estimée comme non-fiable</td>
	</tr>
	<tr>
		<td>~</td>
		<td>Source à forte variabilité</td>
	</tr>
	<tr>
		<td>Name/IP address</td>
		<td colspan="3">Nom ou adresse IP de la source</td>
	</tr>
	<tr>
		<td>Stratum</td>
		<td colspan="3">Éloignement de la source originale de temps, à partir de 0</td>
	</tr>
	<tr>
		<td>Poll</td>
		<td colspan="3">Fréquence de rafraîchissement</td>
	</tr>
	<tr>
		<td>Reach</td>
		<td colspan="3">Accessibilité de la source en base octale (377 signifie que la source est toujours accessible)</td>
	</tr>
	<tr>
		<td>LastRx</td>
		<td colspan="3">Dernière réception de données (par défaut en secondes)</td>
	</tr>
	<tr>
		<td>Last Sample</td>
		<td colspan="3">Dernier offset reçu</td>
	</tr>
</table>

Le remplacement des serveurs par défaut peut être réalisé en supprimant les serveurs et pools par défaut, en ajoutant les serveurs personnalisés et en redémarrant ``chrony``.

> [!TIP]
> En cas de copier/coller, ne pas oublier de mettre à jour les adresses IP ou FQDN des serveurs DNS.

```bash
# Suppression des pool par défaut
sed -i '/^pool /d' /etc/chrony.conf
# Suppression des serveurs par défaut
sed -i '/^server /d' /etc/chrony.conf
# Ajout des serveurs personnalisés
echo -e "\n# Custom NTP servers
server <NTP-server-1> iburst
server <NTP-server-2> iburst
server <NTP-server-3> iburst" >> /etc/chrony.conf
# Redémarrage de chrony
systemctl restart chronyd
```

La synchronisation temporelle ayant été réalisée, poursuivre avec l'[installation de paquets](./04-Packages-install.md).