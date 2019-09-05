## Полезные команды для инструментов Docker и Docker-Compose

```bash
# переход в консоль контейнера sf-php-cli
$ docker-compose exec sf-php-cli bash

# Composer 
# --------
# обновление пакетов
$ docker-compose exec sf-php-cli composer update

# SF - наш псевдоним команды 'php bin/console' внутри PHP-CLI контейнера
# Команда из терминала PhpStorm, выполняемая из папки нашего проекта
$ docker-compose exec sf-php-cli php bin/console cache:clear
# То же самое с использованием псевдонима
$ docker-compose exec sf-php-cli bash
$ sf cache:clear

# Retrieve an IP Address (here for the nginx container)
$ docker inspect --format '{{ .NetworkSettings.Networks.dockersymfony_default.IPAddress }}' $(docker ps -f name=nginx -q)
$ docker inspect $(docker ps -f name=sf-nginx -q) | grep IPAddress

# Команды PostgreSQL
$ docker-compose exec sf-db psql blog_db symfonist

# F***ing cache/logs folder
$ sudo chmod -R 777 var/cache var/logs var/sessions

# Check CPU consumption
$ docker stats $(docker inspect -f "{{ .Name }}" $(docker ps -q))

# Delete all containers
$ docker rm $(docker ps -aq)

# Delete all images
$ docker rmi $(docker images -q)

$ docker system prune --volumes
```