# CSV2WWW

## Présentation du Projet
csv2www est un outil Perl qui lit des fichiers CSV et génère des pages HTML correspondantes pour affichage web. Le programme est configurable via config.cfg pour s’adapter à différents formats de CSV et besoins de sortie.

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
Modifiez config.cfg pour définir les chemins du fichier CSV, le dossier de sortie et les options de formatage. Le programme est dynamique et s'adapte directement aux champs de votre fichier CSV.
