# CSV2WWW
## Présentation du Projet
csv2www est un programme en Perl (donc fonctionnant sur un serveur Web) permettant de publier sur le Web, de façon dynamique et avec des possibilités de personnalisation graphique (via une feuille de style CSS), les informations contenues dans un fichier CSV. Le programme propose les contenus du fichier CSV sous la forme de liste de tableaux de données accessibles via des index et un petit moteur de recherche. Les index et le moteur de recherche sont paramétrables (via un fichier de configuration CFG). Le programme s’adapte à toute les structures de fichiers CSV. Perl a été choisi pour sa durabilité dans le temps et car il fonctionne sur la plupart des serveurs Web académiques.

## Prérequis
- Perl (version 5 ou supérieure)
- Serveur web : Apache ou Nginx
- Un fichier CSV à afficher

## Installation sur un serveur Web
### Serveur Apache
- Copiez le script csv2www.pl, config.cfg, data.csv dans le répertoire web (ex. /var/www/html/csv2www/).
- Rendez le script exécutable : `chmod +x csv2www.pl`
- Activez l’exécution CGI pour le répertoire. Ajoutez à votre configuration Apache ou .htaccess :
```perl
Options +ExecCGI
AddHandler cgi-script .pl
```

- Redémarrez Apache : `sudo systemctl restart apache2`
- Accédez au script depuis votre navigateur : https://votre-serveur/csv2www/csv2www.pl
### Nginx
Nginx n’exécute pas directement les scripts CGI. Il est nécessaire d’utiliser fcgiwrap ou Perl-FastCGI. Exemple avec fcgiwrap :
- Installer fcgiwrap : `sudo apt install fcgiwrap`
- Copier csv2www.pl et config.cfg dans /var/www/html/csv2www/.
- Rendre le script exécutable : `chmod +x csv2www.pl`
- Configurer Nginx pour passer les requêtes .pl à fcgiwrap. Exemple de bloc server :
```shell
location /csv2www/ {
    root /var/www/html;
    fastcgi_pass unix:/var/run/fcgiwrap.socket;
    include fastcgi_params;
    fastcgi_param SCRIPT_FILENAME /var/www/html$fastcgi_script_name;
}
```
- Redémarrez Nginx : `sudo systemctl restart nginx`
- Accédez via navigateur : https://votre-serveur/csv2www/csv2www.pl

## Utilisation

- Définisez un fichier CSV avec vos données (via des outils tels que LibreOffice, OpenRefine, Excell, etc.) et déposez dans l'espace du serveur (ex. : /var/www/html/csv2www/) ou se trouve csv2www.pl.

- Modifiez config.cfg pour définir les chemins du fichier CSV, le dossier de sortie et les options de formatage (titres, langues, etc.). Le programme est dynamique et s'adapte directement aux champs de votre fichier CSV.

- Adaptez style.css pour modifier les style CSS de la page Web qui contiendra les informations de votre fichier CSV.


## Exemple 
Une instance du programme est maintenu sur [https://www.stephanepouyllau.org/csv2www/csv2www.pl](https://www.stephanepouyllau.org/csv2www/csv2www.pl) à titre de démonstration.
