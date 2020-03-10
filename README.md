# wordpress
Offical Wordpress Image with ssh, wp-cli, custom user and production ready config

Change vaules in `www.example.com.env` and store it under `/var/docker/env/www.example.com.env`

Use this commands in directory with the docker-compose.yml:
```
export P_DOMAIN=www.example.com
env $(cat /var/docker/env/${P_DOMAIN}.env) docker-compose -p ${P_DOMAIN} up -d
```
