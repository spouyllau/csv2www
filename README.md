# CSV2WWW
## Project Overview
csv2www is a Perl program (meaning it runs on a web server) that allows you to publish the information contained in a CSV file on the web in a dynamic way, with options for graphic customization (via a CSS style sheet). The program displays the contents of the CSV file in the form of a list of data tables accessible via indexes and a small search engine. The indexes and search engine are configurable (via a CFG configuration file). The program adapts to all CSV file structures. Perl was chosen for its durability over time and because it runs on most academic web servers.
## Requirements
- Perl (version 5 or higher)
- Web server: Apache or Nginx
- a CSV file to be displayed
## Installation on a Web Server
### Apache
- Copy the csv2www.pl script, config.cfg, data.csv to your web server directory (e.g., /var/www/html/csv2www/).
- Ensure the script is executable: `chmod +x csv2www.pl`
- Enable CGI execution for the directory. Add to your Apache configuration or .htaccess:

```perl
Options +ExecCGI
AddHandler cgi-script .pl
```

- Restart Apache: `sudo systemctl restart apache2`

- Access the script via your browser: https://your-server/csv2www/csv2www.pl
### Nginx
Nginx does not execute CGI scripts directly, so you need fcgiwrap or Perl-FastCGI. Example using fcgiwrap:

- Install fcgiwrap: `sudo apt install fcgiwrap`
- Copy csv2www.pl and config.cfg to /var/www/html/csv2www/.
- Make the script executable: `chmod +x csv2www.pl``
- Configure Nginx to pass .pl requests to fcgiwrap. Example server block snippet:
```shell
location /csv2www/ {
    root /var/www/html;
    fastcgi_pass unix:/var/run/fcgiwrap.socket;
    include fastcgi_params;
    fastcgi_param SCRIPT_FILENAME /var/www/html$fastcgi_script_name;
}
```

- Restart Nginx: `sudo systemctl restart nginx`
- Access via browser: https://your-server/csv2www/csv2www.pl

## Usage

- Create a CSV file with your data (using tools such as LibreOffice, OpenRefine, Excel, etc.) and place it in the server space (e.g., /var/www/html/csv2www/) where csv2www.pl is located.

- Edit config.cfg to define the paths of the CSV file, the output folder, and the formatting options (titles, languages, etc.). The program is dynamic and adapts directly to the fields in your CSV file.

- Adapt style.css to modify the CSS styles of the web page that will contain the information from your CSV file.

Translated with DeepL.com (free version)

## Example
A example (with french data) is awailable at [https://www.stephanepouyllau.org/csv2www/csv2www.pl](https://www.stephanepouyllau.org/csv2www/csv2www.pl). 