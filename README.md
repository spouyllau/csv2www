# README
English Version
## Project Overview
csv2www is a Perl-based tool that reads data from CSV files and generates corresponding HTML pages for web display. The program is configurable via config.cfg to adapt to different CSV formats and output requirements.
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

Edit config.cfg to specify CSV file paths, output folder, and formatting options. This program is dynamic and detect all structure from CSV.