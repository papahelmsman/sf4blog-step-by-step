## Useful Commands for Docker and Docker-Compose Tools

```bash
# bash commands
$ docker-compose exec sf-php-cli bash

# Composer (e.g. composer update)
$ docker-compose exec sf-php-cli composer update

# SF commands (Tips: there is an alias inside php container)
$ docker-compose exec sf-php-cli php bin/console cache:clear
# Same command by using alias
$ docker-compose exec sf-php-cli bash
$ sf cache:clear

# Retrieve an IP Address (here for the nginx container)
$ docker inspect --format '{{ .NetworkSettings.Networks.dockersymfony_default.IPAddress }}' $(docker ps -f name=nginx -q)
$ docker inspect $(docker ps -f name=sf-nginx -q) | grep IPAddress

# PostgreSQL commands
$ docker-compose exec sf-db psql blog_db symfonist

# F***ing cache/logs folder
$ sudo chmod -R 777 app/cache app/logs # Symfony2
$ sudo chmod -R 777 var/cache var/logs var/sessions # Symfony3

# Check CPU consumption
$ docker stats $(docker inspect -f "{{ .Name }}" $(docker ps -q))

# Delete all containers
$ docker rm $(docker ps -aq)

# Delete all images
$ docker rmi $(docker images -q)
```