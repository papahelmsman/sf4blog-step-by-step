# My Symfony development step by step
# Мой опыт разработки на фреймворке Symfony. Шаг за шагом.

№№№№№ (материал редактируется!!! )

Цели и задачи.
1. Развернуть рабочее окружение для разработки мультиязычного блога на фреймворке Symfony на локальной машине.
2. Использовать в работе самые свежие или близкие к ним инструменты разработки
    Nginx 1.17 +
    PHP 7.3 +
    PostgreSQL 12 +

Предвариетльные требования

1. Установка рабочего окружения


2. Настройка программного обеспечения




....




#### Итак, поехали... 

Сначала создадим новый проект 

File > New Project ... 

[Img_001]

Указываем имя проекта и создаём его нажатием кнопки 'CREATE'*. 

В корне проекта создадим первые файлыЖ
- файл [.gitignore], для  указания неотслеживаемых файлав
- файл [README.md], который будет служить входной точкой в документацию нашего проекта.

Сразу приучим себя к использованию системы контроля версий **git**

Для работы с консолью переходим в **Terminal**.

Инициализируем Git:
```
git init
```

Добавляем созданные файлы в индекс для последуюшего коммита
```
git add .gitignore
git add README.md
```

Сохраняем файлы, добавленные в индекс (с добавлением прикрепленного сообщения без открытия назначенного редактора).
```
git commit -m "Initial commit"
```
или тоже самое, но более коротко:
```
git init
git add .
git commit -m "Initial commit"
```
 
Рабочее окружение будем настраивать с помощью инструментов Docker и Docker-Compose

Docker Docs:[(https://docs.docker.com/get-started/)]

В корневом каталоге проекта создаем файл docker-compose.yml
```
touch docker-compose.yml
```

Сщздаём директорию **docker**, а в ней - следующие вложенные директории и файлы:
```
development
    nginx/
        conf.d/
            symfony.conf
        Dockerfile
        nginx.conf
    php/
        7.3/
            cli/
                Dockerfile
                
            fpm/
                Dockerfile
                
production
```

Поддтректорию **production** оставим пустой до мемента настройки деплоя проекта.

А в поддиректорию **development** создадим контент с соответствии с вышеуказанным деревом.

##### //docker/development/nginx/Dockerfile
```
FROM nginx:1.17.2-alpine

LABEL maintainer="Pavel A. Petrov <papahelmsman@gmail.com>"

COPY nginx.conf /etc/nginx/nginx.conf
COPY conf.d/symfony.conf /etc/nginx/conf.d/symfony.conf
RUN rm /etc/nginx/conf.d/default.conf

WORKDIR /app
```

##### //docker/development/nginx/conf.d/symfony.conf
```
server {
    listen 80;
    index index.php index.html;
    root /app/public;

    location / {
        try_files $uri $uri/ /index.php?$args;
    }

    location ~ \.php$ {
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass sf-php-fpm:9000;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_param PATH_INFO $fastcgi_path_info;
    }

}
```

##### //docker/development/nginx/nginx.conf
```
user nginx;
worker_processes 4;
pid /run/nginx.pid;

events {
  worker_connections  2048;
  multi_accept on;
  use epoll;
}

http {
  server_tokens off;
  sendfile on;
  tcp_nopush on;
  tcp_nodelay on;
  keepalive_timeout 15;
  types_hash_max_size 2048;
  include /etc/nginx/mime.types;
  default_type application/octet-stream;
  access_log off;
  error_log off;
  gzip on;
  gzip_disable "msie6";
  include /etc/nginx/conf.d/*.conf;
  include /etc/nginx/sites-enabled/*;
  open_file_cache max=100;
  client_body_temp_path /tmp 1 2;
  client_body_buffer_size 256k;
  client_body_in_file_only off;
}
```

##### //docker/development/php/7.3/cli/xdebug.ini
```
xdebug.remote_enable=1
xdebug.remote_port=9000
xdebug.remote_autostart=1
xdebug.remote_connect_back=0
xdebug.idekey=editor-xdebug
```

##### //docker/development/php/7.3/cli/Dockerfile
```
FROM php:7.3-cli

LABEL maintainer="Pavel A. Petrov <papahelmsman@gmail.com>"

RUN pecl install -o -f redis \
    && rm -rf /tmp/pear \
    && docker-php-ext-enable redis

RUN apt-get update && apt-get install -y libpq-dev unzip \
    && docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql \
    && docker-php-ext-install pdo_pgsql \
    && pecl install xdebug-2.7.2 \
    && docker-php-ext-enable xdebug

COPY xdebug.ini /usr/local/etc/php/conf.d/xdebug.ini

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/bin --filename=composer --quiet

ENV COMPOSER_ALLOW_SUPERUSER 1

WORKDIR /app
```

##### //docker/development/php/7.3/fpm/Dockerfile
```
FROM php:7.3-fpm

LABEL maintainer="Pavel A. Petrov <papahelmsman@gmail.com>"

RUN pecl install -o -f redis \
    && rm -rf /tmp/pear \
    && docker-php-ext-enable redis

RUN apt-get update && apt-get install -y libpq-dev \
    && docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql \
    && docker-php-ext-install pdo_pgsql

WORKDIR /app
```




Файл **docker-compose.yml** наполняем следующим содержанием:
```
//

# версия файла docker-compose
version: "3.7"

# раздел настройки сервисов
services:
  # Сервер Nginx
  nginx:
    # параметры конфигурации
    build:
      # путь к контексту сборки
      context: ./docker/development/nginx
      # имя файла для сборки (директива имеет место быть, когда мы изменяем стандартное имя файла сборки [Dockefile] на любое другое, например, [nginx.docker]
      dockerfile: Dockerfile
      

```

Если убрать комментарии и немного сократить запись, конфигурационный файл будет выглядеть примерно так:

```
version: "3.7"
services:
  sf-nginx:
    build: ./docker/development/nginx
    container_name: sf-nginx
    ports:
      - "80:80"
    volumes:
      - ./app/public:/app/public:ro
    depends_on:
      - sf-php-fpm
  sf-php-fpm:
    build: ./docker/development/php/7.3/fpm
    container_name: sf-php-fpm
    volumes:
      - ./app:/app:rw,cached
    depends_on:
      - sf-db
      - sf-redis
      - sf-queue-redis
  sf-php-cli:
    build: ./docker/dev/php/7.3/cli
    container_name: sf-php-cli
    volumes:
      - ./app:/app
      - composer:/root/.composer/cache
    depends_on:
      - sf-db
      - sf-redis
      - sf-queue-redis
    ports:
      - "9000:9001"
  sf-queue-worker:
    build:
      context: ./docker/dev/php/7.3/cli
    container_name: sf-queue-worker
    volumes:
      - ./app:/app:rw,cached
      - composer:/root/.composer/cache
    depends_on:
      - sf-db
      - sf-redis
      - sf-queue-redis
    command: sh -c "until [ -f .ready ] ; do sleep 1 ; done && php bin/console messenger:consume async -vv"
  sf-node-watch:
    image: node:12.7-alpine
    container_name: sf-node-watch
    volumes:
      - ./app:/app:rw,cached
    working_dir: /app
    command: sh -c "until [ -f .ready ] ; do sleep 1 ; done && npm run watch"

  sf-node:
    image: node:12.7-alpine
    container_name: sf-node
    volumes:
      - ./app:/app:rw,cached
    working_dir: /app
  sf-db:
    image: postgres:11.2-alpine
    container_name: sf-db
    volumes:
      - db-data:/var/lib/postgresql/data:rw
    environment:
      POSTGRES_USER: symfonist
      POSTGRES_PASSWORD: secret
      POSTGRES_DB: blog_db
    ports:
      - "54321:5432"
  sf-adminer:
    image: adminer
    container_name: sf-adminer
    depends_on:
      - sf-db
    restart: always
    ports:
      - "2000:8080"
  sf-redis:
    image: redis:5-alpine
    container_name: sf-redis
    ports:
      - "6379:6379"
    volumes:
      - redis:/data
    command:
      - 'redis-server'
      - '--databases 2'
      - '--save 900 1'
      - '--save 300 10'
      - '--save 60 10000'
      - '--requirepass secret'
  sf-queue-redis:
    image: redis:5.0-alpine
    container_name: sf-queue-redis
    volumes:
      - queue-redis:/data
volumes:
  db-data:
  redis:
  queue-redis:
  composer:
```
Создадим директорию **app** для кода нашего приложения
Затем добавим файлы index.php и info.php в каталоге /public для тестирования работы нашего окружения

##### //app/public/index.php
```php
<?php
echo 'Congratulations! It works!!!';
```

##### //app/public/info.php
```php
<?php
phpinfo();
```

Добавим в host-файл системы наш локальный домен
```
192.168.99.100 sf4blog.dockerhost
```

```
docker-compose build
```

```
docker-compose up -d
```

После завершения сборки контейнеров Docker можно проверить работу окружения.

Вводим в командной строке браузера:
```
http://sf4blog.dockerhost/
```

и  получаем:

**Congratulations! It works!!!**

Поздавляю Вас! Наше окружение готово к установке шаблона Symfony!

Также мы можем посмотреть некоторые показатели нашего окружения :
```
http://sf4blog.dockerhost/info.php
```


Отметимся в git^

```
git status
git add .
git commit -m "Docker-compose ready to work" 
```

Отполируем наш стартовый пакет созданием файла **Makefile**, который поможет нам облегчить работу с контейнерами во время разработки.

Создаем Makefile в корне проекта.
Если Вы используете операционную систему **Windows**, Вам необходимо установить дополнительный софт для работы утииты **make**

Шаг 1: Установите менеджер пакетов **chocolatey** 

https://chocolatey.org/install

Шаг 2. Запустите командную строку Windows с правами администратора и выполните команду:
~~~
choco install make
~~~

Шаг 3. **Make** будет добавлен в глобальный путь и будет работать на всех CLI (powershell, git bash, cmd…)


Теперь мы можем использовать любые собственные сокращенные команды, указав из соответствующим образом в файле **Makefile**

Например:
Чтобы запустить наши контейнеры, достаточно выполнить в терминале:
```
make up
```

При завершении работы выполняем:
```
make down
```

Чтобы пересобрать контейнеры, достаточно команды:
```
make restart
```

### Начинаем процесс разработки

Можно, конечно, сразу установить каркас включающий наиболее полный набор инструментов для разработки на Symfony
 
Но мы начнём с минимального пакета для запуска приложения


```
make down
```
Удалим папку /app из проекта для установки шаблона Symfony
Заходим в терминал и выполняем:

```
composer create-project symfony/skeleton ./app
```


```
docker-compose run --rm sf-php-cli composer create-project 
```

Снова запускаем в терминале docker-compose:

```
make up
```

Вводим в командной строке браузера:
```
http://sf4blog.dockerhost/
```

Отлично! Стартовая страница нашего приложения успешно загружается

В первую очередь выпоним некоторые настройки

1. PhpStorm

Настройка плагинов 

Symfony Plugin
PHP Toolbox
PHP Annotations

Key Promoter X


2. 

Чтобы убедиться, что наше приложение не имеет установленных зависимостей с известными уязвимостями безопасности, установим следующий пакет:
```
docker-compose run --rm sf-php-cli composer require --dev roave/security-advisories:dev-master
```

```
docker-compose run --rm sf-php-cli composer require sec-checker
```

Пробуем:
```
docker-compose run --rm sf-php-cli ./bin/console security:check
```
или то же самое более коротко с использованием утилиты make:
```
make sf-sec-check
```

Получаем:
```
Symfony Security Check Report
=============================

No packages have known vulnerabilities.
```



```
docker-compose run --rm sf-php-cli composer require twig
```

Если мы выполним команду 
```
git status
```
то увидим изменения после установки данного компонента:

Это:
- конфигурационный файл twig.yaml
- /routes/dev/twig.yaml
- новый каталог проекта templates с первым предустановленным шаблоном base.html.twig

Немного поработаем над основным шаблоном

Во-первых, добавим в папку /public нашего проекта иконку для браузера favicon.png и добавим ее в шаблон.

Для этого в файле base.html.twig добавим строку:

```html
<link rel="icon" type="image/x-icon" href="{{ asset('favicon.ico') }}" />
```

#### Profiler Pack

```
docker-compose run --rm sf-php-cli composer require profiler --dev
```

#### Debug Pack

```
docker-compose run --rm sf-php-cli composer require debug --dev
```







