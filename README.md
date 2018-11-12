# openslides-nightly-build
A service that automatically builds OpenSlides.

To use it, simple replace the `#USER` with the user that should execute the service and replace `#PATHTOSCRIPT` with the path to this folder. It is important that the `run.sh` and the `workingdir` are in the same folder.

You need to reown the target folder in your nginx. to `$(user):www-data` and make it availible for `770`. In our case this means:

    sudo chown -R $(users):www-data /usr/share/nginx/html
    sudo chmod 770 /usr/share/nginx/html

The `run.sh` will create a new build (but keep the database) on every run. So if you configure the service in your `cron` to run nightly, you will recieve a nightly updated version of OpenSlides.

You should also fix the replaces in the `run.sh` according to your environment.

Simply link the `.service` file to your `systemd` directory and enable the service.

## Dependencies

 * python3.7
 * angular/cli > 7.0
 * nodejs > 10

## nginx

An example for a working nginx configuration in this setup:

```
# OpenSlides Nightly


server {
    listen 80;
    listen [::]:80;
    server_name your.server.*;

    location /.well-known/acme-challenge/ {
      proxy_pass http://acmetool;
    }

    location / {
        rewrite ^ https://$server_name$request_uri ;
    }
}

server {
    listen 443 ssl spdy;
    listen [::]:443 ssl spdy;
    server_name nightly.demo.openslides.*;
    client_max_body_size 100m;

    ssl on;
    ssl_protocols TLSv1.2 TLSv1.1 TLSv1;
    ssl_ciphers EECDH+AESGCM:EDH+AESGCM:EECDH:EDH:!MD5:!RC4:!LOW:!MEDIUM:!CAMELLIA:!ECDSA:!DES:!DSS:!3DES:!NULL;
    ssl_prefer_server_ciphers on;
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload";
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;
    ssl_certificate      /var/lib/acme/live/your.server/fullchain;
    ssl_certificate_key  /var/lib/acme/live/your.server/privkey;
    root   /usr/share/nginx/html;
    index  index.html index.htm;

    location / {
       try_files $uri $uri/ /index.html;
    }
    location /apps {
       proxy_pass http://localhost:8000;
    }
    location /media {
       proxy_pass http://localhost:8000;
    }
    location /rest {
       proxy_pass http://localhost:8000;
    }
    location /ws {
       proxy_pass http://localhost:8000;
       proxy_http_version 1.1;
       proxy_set_header Upgrade $http_upgrade;
       proxy_set_header Connection "Upgrade";
    }
}
```

## cron

Add a file to your `cron.daily` (or what you prefer) and add something like:

```
#!/bin/bash

systemctl stop openslides-nightly.service
systemctl start openslides-nightly.service
```
