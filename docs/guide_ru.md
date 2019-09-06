# Мой опыт разработки мультиязычного блога на фреймворке Symfony с использованием инструментов Docker и Docker-Compose, шаг за шагом.

##### (материал редактируется!!!)

### Содержание

1. Цели и задачи
2. Предварительные требования
3. Сборка рабочего окружения
4. Установка шаблона
5. Установка основных компонентов для эффективной разработки
6. Параллельное тестирование и разработка блога
7. Развёртывание проекта
8. Продвижение проекта





## Цели и задачи.

От того, наколько правильно определеены цели и поставлены задачи, зависит успех любого проекта. 

Это касается даже нашего учебного блога.

Заранее определено, что мы будем использовать:
- Nginx в качестве внешнего сервера (в конце данного проекта, для сравнения, мы попробуем заменить его на связку сервера высокой доступности HAProxy и ускоритель Varnish)
- PHP-FPM в качестве внутреннего сервера
- PHP-CLI в качестве интерфейса командной строки
- PostgreSQL в качестве основной СУБД
- Redis в качестве СУБД для решения специфических задач
- NodeJS 


Мы постараемся использовать в работе самые свежие или близкие к ним инструменты разработки и своевременно корректировать данный репозиторий в случае совершенствования используемых технологий.

    

## Предвариетльные требования

Не смотря на то, что мы стремимся к максимальной автономности и независимости разработки от машины, на которой она ведётся, мы всё же установим следующие инструменты:

- Установка системы контроля версий Git
- Установка пакетного менеджера Composer
- Установка инструментов Docker и Docker-Compose
- Установка полезной утилиты **make** 

Процесс установки необходимого софта мы будем рассматривать для следующих операционных систем:
- Ubuntu, как одну из популярнейших ОС среди веб-разработчиков
- Windows 10, как текущая версия ОС от Microsoft
- Windows 7, как не менее популярная ОС у full-stack разработчиков, которые используют специфический софт, работающий только под Windows
- macOS, как текущий представитель "яблочной" ветки семейства UNIX.

### Устанавдиваем Git

#### Ubuntu 18.08 LTS Bionic Beaver

#### Windows 10

#### Windows 7 64-bit

#### macOS 10.14

### Устанавдиваем Composer

#### Ubuntu 18.08 LTS Bionic Beaver

#### Windows 10

#### Windows 7 64-bit

#### macOS 10.14

### Устанавдиваем Docker и Docker-Compose

#### Ubuntu 18.08 LTS Bionic Beaver

#### Windows 10

#### Windows 7 64-bit

#### macOS 10.14

### Устанавдиваем утилиту 'make'

#### Ubuntu 18.08 LTS Bionic Beaver

#### Windows 10

#### Windows 7 64-bit

Для этого сначала установим пакетный менеджер Chocolatey

Откроем командную строку Windows **cmd.exe** с правами администратора и выполним

```

```

Теперь установим нашу утилиту **make**

```
choco install make
```

В дальнейшем, чтобы обновить GNU Make, мы будем также открывать командную строку Windows с правами администратора и запускать команду:

```
choco upgrade make
```


#### macOS 10.14



## Сборка рабочего окружения




**.editorconfig**

```
root = true

[*]
end_of_line = lf
insert_final_newline = true

[*]
charset = utf-8

[{Dockerfile,docker-compose.yml}]
indent_style = space
indent_size = 2
```

....




#### Итак, поехали... 

Сначала создадим новый проект 

File > New Project ... 

<p>
<img src="assets/images/screens/Img_001.png" alt="">
</p>

Указываем имя проекта и создаём его нажатием кнопки 'CREATE'*. 

В корне проекта создадим первые файлы:
- файл **.gitignore**, для  указания неотслеживаемых файлав
- файл **README.md**, который будет служить входной точкой в документацию нашего проекта.

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

В корневом каталоге проекта создаем файл **docker-compose.yml**

Его наполнением мы займёмся позже, а пока здесь же, в корне проекта, создадим директорию **docker**, в которой мы будем хранить настройки нашего окружения для разработки (вложенаая директория 'development') и деплоя нашего проекта (вложенная директория 'production').

Директорию **production** пока оставим пустой до момента настройки деплоя проекта, а в директории **development** расположим вложения согласно следующей схеме:

```
docker
├─ development
│   ├─ nginx/
│   │   ├─ conf.d/
│   │   │   └──symfony.conf
│   │   ├─ Dockerfile
│   │   └─ nginx.conf
│   └─ php/
│       └─ 7.3/
│           ├─ cli/
│           │   ├─ Dockerfile
│           │   └─ xdebug.ini
│           └─ fpm/
│               └─  Dockerfile
└─ production
```

Для сборки сервиса nginx наполним два конфигурационных файла nginx.conf и /conf.d/symfony.conf сделующими блоками и директивами:

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

    error_log /var/log/nginx/symfony_error.log;
    access_log /var/log/nginx/symfony_access.log;

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

Теперь мы  можем настроить Dockerfile для сервера NGINX.

##### //docker/development/nginx/Dockerfile
``` dockerfile
FROM nginx:latest

LABEL maintainer="Pavel A. Petrov <papahelmsman@gmail.com>"

COPY nginx.conf /etc/nginx/nginx.conf
COPY conf.d/symfony.conf /etc/nginx/conf.d/symfony.conf
RUN rm /etc/nginx/conf.d/default.conf

WORKDIR /app
```

Далее,  подготовим файлы настроек для контейнеров PHP.

##### //docker/development/php/7.3/fpm/xdebug.ini
```
xdebug.remote_enable=1
xdebug.remote_port=9000
xdebug.remote_autostart=0
xdebug.remote_connect_back=1
xdebug.max_nesting_level=1200
xdebug.idekey=PHPSTORM
```

...

##### //docker/development/php/7.3/fpm/symfony.ini
```ini
apc.enable_cli = 1
date.timezone = Europe/Moscow
session.auto_start = Off
short_open_tag = Off

# https://symfony.com/doc/current/performance.html
opcache.memory_consumption = 256
opcache.max_accelerated_files = 20000
opcache.validate_timestamps=0
realpath_cache_size = 4096K
realpath_cache_ttl = 600
```



Теперь создадим файл сборки для PHP-FPM (сервиса менеджера процессов FastCGI), где установим дополнительные пакеты для корректной работы СУБД redis и СУБД PostgreSQL 

##### //docker/development/php/7.3/fpm/Dockerfile
```dockerfile
FROM php:7.3-fpm

LABEL maintainer="Pavel A. Petrov <papahelmsman@gmail.com>"

ARG APCU_VERSION=5.1.11

RUN apt-get update && apt-get install -y git zip unzip libzip-dev zlib1g-dev libpq-dev git-core libmcrypt-dev \
    libfcgi0ldbl gnupg libfreetype6-dev libjpeg62-turbo-dev libpng-dev libicu-dev wget

RUN docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql \
    && docker-php-ext-install pdo_pgsql \
    && docker-php-ext-install opcache \
    && docker-php-ext-install intl \
    && docker-php-ext-install mbstring

RUN pecl install apcu-${APCU_VERSION} \
    && docker-php-ext-enable apcu

RUN pecl install -o -f redis \
    && rm -rf /tmp/pear \
    && docker-php-ext-enable redis

RUN pecl install xdebug-beta \
    && docker-php-ext-enable xdebug

COPY xdebug.ini /usr/local/etc/php/conf.d/
COPY symfony.ini /usr/local/etc/php/conf.d/

WORKDIR /app
```

Далее, займёмся настройкой сборки сервиса PHP-CLI (интерфейса командной строки для дальнейшей разработки).

Он дополнится настройками системы профилирования и отладки **xdebug**

##### //docker/development/php/7.3/cli/xdebug.ini
```ini
xdebug.remote_enable=1
xdebug.remote_port=9000
xdebug.remote_autostart=0
xdebug.remote_connect_back=1
xdebug.max_nesting_level=1200
xdebug.idekey=PHPSTORM
```

настроками **php.ini**

##### //docker/development/php/7.3/fpm/symfony.ini
```ini
apc.enable_cli = 1
date.timezone = Europe/Moscow
session.auto_start = Off
short_open_tag = Off

# https://symfony.com/doc/current/performance.html
opcache.memory_consumption = 256
opcache.max_accelerated_files = 20000
opcache.validate_timestamps=0
realpath_cache_size = 4096K
realpath_cache_ttl = 600
```



и пакетного менеджера **composer**

Также установим переменную окружения **COMPOSER_ALLOW_SUPERUSER** чтобы  composer не ругался на /root/super user

В итоге, получим следующий файл сборки PHP-CLI:

##### //docker/development/php/7.3/cli/Dockerfile
```dockerfile
FROM php:7.3-cli

LABEL maintainer="Pavel A. Petrov <papahelmsman@gmail.com>"

ARG APCU_VERSION=5.1.11

RUN apt-get update && apt-get install -y git zip unzip libzip-dev zlib1g-dev libpq-dev git-core libmcrypt-dev \
    libfcgi0ldbl gnupg libfreetype6-dev libjpeg62-turbo-dev libpng-dev libicu-dev wget

RUN docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql \
    && docker-php-ext-install pdo_pgsql \
    && docker-php-ext-install opcache \
    && docker-php-ext-install intl \
    && docker-php-ext-install mbstring

RUN pecl install apcu-${APCU_VERSION} \
    && docker-php-ext-enable apcu

RUN pecl install -o -f redis \
    && rm -rf /tmp/pear \
    && docker-php-ext-enable redis

RUN pecl install xdebug-beta \
    && docker-php-ext-enable xdebug

COPY xdebug.ini /usr/local/etc/php/conf.d/
COPY symfony.ini /usr/local/etc/php/conf.d/

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/bin --filename=composer --quiet

ENV COMPOSER_ALLOW_SUPERUSER 1

RUN echo 'alias sf="php bin/console"' >> ~/.bashrc

WORKDIR /app
```

Обратим внимание на строку, которая добавит удобную консольную команду **sf** вместо **php bin/console** :

``` dockerfile
RUN echo 'alias sf="php bin/console"' >> ~/.bashrc
```

Здесь же можно добавить другие псевдонимы, необходимые для удобства Вашей работы.



Для других сервисов мы ока воспользуемся готовыми официальными сборками без дополнительных настроек.

Поэтому, возьмёмся за файл **docker-compose.yml**

Файл **docker-compose.yml** наполняем следующим содержанием:

##### //docker-compose.yml
```yaml
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
    build: ./docker/development/php/7.3/cli
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
      context: ./docker/development/php/7.3/cli
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

Конфигурационный файл **docker-compose.yml** с подробными комментариями можно посмотреть **здесь**

Чтобы проверить работу "поднятого" работчего окружения, создадим директорию **app** для кода нашего приложения

Затем добавим файлы index.php и info.php в каталоге /public для тестирования работы окружения

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

Добавим в host-файл системы наш локальный домен, указав отличный от 127.0.0.1 IP-адрес (если вы используемте docker-machine) и допустимое имя локального хоста на Ваше усмотрение 

```
192.168.99.100 sf4blog.dockerhost
```

Окей! Пробуем собрать...

``` bash
docker-compose build
```

... и запустить наши контейнеры

``` bash
docker-compose up -d
```

После завершения сборки контейнеров Docker можно проверить работу окружения.

Вводим в командной строке браузера:

``` http request
http://sf4blog.dockerhost/
```

и получаем корректно отработавший скрипт **index.php**.

<hr>

Поздавляю Вас! Наше окружение готово к установке шаблона Symfony!

Также мы можем посмотреть некоторые показатели нашего окружения по адресу:

``` http request
http://sf4blog.dockerhost/info.php
```

<hr>


Отметимся в git. 
> Постоянное сохранение изменений в git-репозиторий каждрй атомарной операции нашей разработки, без сомнения, является хорошим тоном.

``` bash
git status
git add .
git commit -m "Our docker environment is ready to work" 
```

Отполируем наш стартовый пакет созданием файла **Makefile**, который поможет нам облегчить работу с контейнерами во время разработки.

Создаем Makefile в корне проекта.
Если Вы используете операционную систему **Windows**, Вам необходимо установить дополнительный софт для работы утииты **make**

Шаг 1: Установите менеджер пакетов **chocolatey** 

``` http request
https://chocolatey.org/install
```

Шаг 2. Запустите командную строку Windows с правами администратора и выполните команду:
~~~ 
choco install make
~~~

Шаг 3. **Make** будет добавлен в глобальный путь и будет работать на всех CLI (powershell, git bash, cmd…)


Теперь мы можем использовать любые собственные сокращенные команды, указав из соответствующим образом в файле **Makefile**

Например:
Чтобы запустить наши контейнеры, достаточно выполнить в терминале:
``` bash
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

##### //Makefile
``` makefile
up: docker-up
down: docker-down
restart: docker-down docker-up
init: docker-down-clear sf-clear docker-pull docker-build docker-up sf-init
test: sf-test
test-coverage: sf-test-coverage
test-unit: sf-test-unit
test-unit-coverage: sf-test-unit-coverage

docker-up:
	docker-compose up -d

docker-down:
	docker-compose down --remove-orphans

docker-down-clear:
	docker-compose down -v --remove-orphans

docker-pull:
	docker-compose pull

docker-build:
	docker-compose build

sf-init: sf-composer-install sf-assets-install sf-oauth-keys sf-wait-db sf-migrations sf-fixtures sf-ready

sf-clear:
	docker run --rm -v ${PWD}/app:/app --workdir=/app alpine rm -f .ready

sf-composer-install:
	docker-compose run --rm sf-php-cli composer install

sf-assets-install:
	docker-compose run --rm sf-node yarn install
	docker-compose run --rm sf-node npm rebuild node-sass

sf-oauth-keys:
	docker-compose run --rm sf-php-cli mkdir -p var/oauth
	docker-compose run --rm sf-php-cli openssl genrsa -out var/oauth/private.key 2048
	docker-compose run --rm sf-php-cli openssl rsa -in var/oauth/private.key -pubout -out var/oauth/public.key
	docker-compose run --rm sf-php-cli chmod 644 var/oauth/private.key var/oauth/public.key

sf-wait-db:
	until docker-compose exec -T sf-postgres pg_isready --timeout=0 --dbname=app ; do sleep 1 ; done

sf-migrations:
	docker-compose run --rm sf-php-cli php bin/console doctrine:migrations:migrate --no-interaction

sf-fixtures:
	docker-compose run --rm sf-php-cli php bin/console doctrine:fixtures:load --no-interaction

sf-ready:
	docker run --rm -v ${PWD}/app:/app --workdir=/app alpine touch .ready

sf-assets-dev:
	docker-compose run --rm sf-node npm run dev

sf-test:
	docker-compose run --rm sf-php-cli php bin/phpunit

sf-test-coverage:
	docker-compose run --rm sf-php-cli php bin/phpunit --coverage-clover var/clover.xml --coverage-html var/coverage

sf-test-unit:
	docker-compose run --rm sf-php-cli php bin/phpunit --testsuite=unit

sf-test-unit-coverage:
	docker-compose run --rm sf-php-cli php bin/phpunit --testsuite=unit --coverage-clover var/clover.xml --coverage-html var/coverage

```





## Установка шаблона

Можно, конечно, сразу установить каркас включающий наиболее полный набор инструментов для разработки на Symfony - так называемый **symfony/website-skeleton**.
 
Но мы начнём с минимального пакета **symfony/skeleton** для более чёткого понимания процесса.

Для этого остановим наши контейнеры. Используя **Makefile** мы можем сделать это из терминала PhpStorm, находясь в корне нашего проекта:

``` bash
make down
```

Для установки шаблона Symfony нам понадобится менеджер пакетов **composer**, глобально установленный на нашей машине.

Можно сразу установить **website-skeleton** - полный шаблон для разработки на **symfony**

Но мы установим минимальный шаблон проекта, и последовательно будем дополнять его компонентами, для более четкого понимания процесса.

В нашем проекте заходим в терминал и выполняем:

```bash
composer create-project symfony/skeleton ./app
```

Снова запускаем в терминале наше  docker-окружение:

```
make up
```

Вводим в командной строке браузера:

```http request
http://sf4blog.dockerhost/
```

Отлично! Стартовая страница нашего приложения успешно загружается

В первую очередь выпоним некоторые настройки

1. PhpStorm

Настройка плагинов 

- Symfony Support

настройка плагина Symfony
PHP
composer path


- PHP Toolbox
- PHP Annotations

- Key Promoter X


Теперь настроим PHP-CLI.

> File > Settings > Languages & Frameworks > PHP

> Cli Interpreter:

> Add > From Docker...

> sf-php-cli

OK


> File > Settings > Languages & Frameworks > PHP > Composer

> Img_009.png



Компоненты фреймворка мы можем устанавливать в нашем терминале, но находясь внутри контейнера PHP-CLI. Для этого выполним:

```
docker-compose exec sf-php-cli bash
```

и в консоли контейнера установим первый пакет  - инструмент командной строки  **Scurity checker**

``` bash
# используется только при разработке, поэтому используем ключ --dev
composer req --dev sec-checker
```

Пробуем здесь же:

```
sf security:check
```

Получаем:

```
Symfony Security Check Report
=============================

No packages have known vulnerabilities.
```

Отлично! Ни один из установленных пакетов не имеет известных уязвимостей.

Правой кнопкой мыши кликаем по открытому ярлыку терминала и переименовываем его для удобства в 'PHP-CLI'.

Открываем ещё одно окно терминала. Оно открывается, как обычно, в корне нашего проекта. Используем новое окно для работы с Git:

```
git status
git add .
git commit -m "Adding Sec-Checker package"
```


## Установка основных компонентов

Возвращаемся в консоль котейнера PHP-CLI

Все следующие установки через **composer** мы продолжим в консоли нашего контейнера PHP-CLI (sf-php-cli)



#### Компонент Maker

```bash
composer req --dev maker
```

Смотрим изменения в проект через **git status**:

```
On branch master
Your branch is ahead of 'origin/master' by 1 commit.
  (use "git push" to publish your local commits)

Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git checkout -- <file>..." to discard changes in working directory)

        modified:   app/composer.json
        modified:   app/composer.lock
        modified:   app/config/bundles.php
        modified:   app/symfony.lock

no changes added to commit (use "git add" and/or "git commit -a")

```

Сохраняем в Git

```
git add .
git commit -m "Step - Adding Maker"
```





### Маршрутизация / Routing

Когда ваше приложение получает запрос, оно выполняет действие контроллера для генерации ответа. 

Конфигурация маршрутизации определяет, какое действие нужно выполнить для каждого входящего URL-адреса. 

Маршруты могут быть настроены в форматах YAML, XML, PHP или с использованием аннотаций.

Все форматы обеспечивают одинаковые функции и производительность, поэтому выбирайте понравившийся Вам способ настройки маршрутов. 

Symfony рекомендует использовать аннотации. Это удобно, потому что маршрут и контроллер размещены в одном месте, а не в нескольких файлах.

Мы будем использовать аннотации, поэтому установим их в первую очередь.



```
rm -rf /app/var/cache/dev/*
```

Идём в консоль PHP-CLI и устанавливаем пакеты **annotations**  (можно использовать псевдоним **annot**)

```
composer req annot
```

Переходим в консоль проекта и смотрим измегения

```
git status
```

Видим::

```
On branch master
Your branch is up to date with 'origin/master'.

Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git checkout -- <file>..." to discard changes in working directory)

        modified:   app/composer.json
        modified:   app/composer.lock
        modified:   app/config/bundles.php
        modified:   app/symfony.lock

Untracked files:
  (use "git add <file>..." to include in what will be committed)

        app/config/packages/sensio_framework_extra.yaml
        app/config/routes/annotations.yaml

no changes added to commit (use "git add" and/or "git commit -a")

```


Сохраняем в Git

```
git add .
git commit -m "Adding Annotations package"
```



#### Компонент отладки в Symfony - Debug

Компонент Debug предоставляет инструменты для облегчения отладки PHP-кода.

Устанавливаем в консоли PHP-CLI:

```bash
composer req --dev debug
```

Переходим в консоль проекта и смотрим измегения

```
git status
```

Видим:

```
On branch master
Your branch is ahead of 'origin/master' by 2 commits.
  (use "git push" to publish your local commits)

Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git checkout -- <file>..." to discard changes in working directory)

        modified:   app/composer.json
        modified:   app/composer.lock
        modified:   app/config/bundles.php
        modified:   app/symfony.lock

Untracked files:
  (use "git add <file>..." to include in what will be committed)

        app/config/packages/dev/debug.yaml
        app/config/packages/dev/easy_log_handler.yaml
        app/config/packages/dev/monolog.yaml
        app/config/packages/dev/web_profiler.yaml
        app/config/packages/prod/
        app/config/packages/test/monolog.yaml
        app/config/packages/test/web_profiler.yaml
        app/config/packages/twig.yaml
        app/config/routes/
        app/templates/

no changes added to commit (use "git add" and/or "git commit -a")

```

Сохраняем в Git

```
git add .
git commit -m "Adding Debug package"
```







```bash
docker-compose run --rm sf-php-cli composer unpack debug
```


```bash
composer unpack profiler
```




```bash
docker-compose run --rm sf-php-cli composer unpack debug
```


```bash
composer unpack profiler
```

```bash
composer require symfony/orm-pack

composer require --dev doctrine/doctrine-fixtures-bundle

composer require --dev symfony/maker-bundle

composer require symfony/validator doctrine/annotations
composer req asset
composer req form
composer req logger #symfony/monolog-bundle
composer req tanslations
composer req intl
composer req swiftmailer
composer req test --dev
composer req encore --dev
composer req twig

composer require --dev symfony/phpunit-bridge

composer require symfony/webpack-encore-bundle
yarn install

```






#### Создание маршрутов

Раскомментируем строчкм конфигурационного файла **/app/config/routes.yaml**

``` yaml
index:
    path: /
    controller: App\Controller\DefaultController::index
```

Он говорит о том, что при http-запросе на наш локальный домен будут выполнены действия метода **index()** контроллера **//app/src/Controller/DefaultController.php** .

Создаем вышеуказанный контроллер.

#### //app/src/Controlller/DeafultController.php
``` php
<?php

namespace App\Controller;

use Symfony\Component\HttpFoundation\Response;

class DefaultController
{
    public function index()
    {
        return new Response('My Default Response');
    }

}
```

После  перехода в браузере по корневому пути нашего локального домена ...

``` http request
http://sf4blog.dockerhost
```

... мы поучим страницу в исходным текстом

```
My Default Response
```

В данном случае мы использовали маршрутизацию с использованием YAML-файла **routes.yaml**

Приступим к использованию аннотаций.

Закомментируем код файла **routes.yaml**:

``` yaml
#index:
#    path: /
#    controller: App\Controller\DefaultController::index
```

Удалим контроллер

Изменим  код нашего контроллера:

``` php
<?php

namespace App\Controller;

use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Annotation\Route;

class DefaultController
{
    /**
     * @Route("/")
     */
    public function index()
    {
        return new Response('My Default Response');
    }

}
```

Добавив перед методом **index()** вышеуказанную аннотацию и выполнив импорт необходтмого класса **Route** с помощб. оператора **use**, мы получим абсолютно тот же результат.



Воспользуемся утилитой **make** из консоли  PHP-CLI и создадим новый контроллер 

```
sf make:controller BlogController
```

Через **git* можно увидеть, что был сгенерирован наш контрлллер и шаблон представления **template/blog/index.html.twig**

Изменим в контроллере аннотацию, чтобы страница открывалась по корневому адресу домена:

``` twig
    /**
     * @Route("/", name="blog")
     */
```






#### Согласование методов HTTP-запроса

По умолчанию маршруты соответствуют любому методу HTTP-запроса (GET, POST, PUT и т.д.). Используйте опцию **methods**, чтобы ограничить методы, на которые должен реагировать каждый маршрут:

``` php
/**
 * @Route("/blog/posts/{id}", methods={"GET","HEAD"})
 */
```

#### Отладка маршрутов

По мере роста нашего приложеения блога количество маршрутов будет расти.

Symfony содержит  несколько консольных команд, которые смогут помочь в отладке маршрутов.

Чтобы посмотреть имеющиеся у нас маршруты, мы можем воспользоваться консольной командой:

``` bash
debug:router
```

В нашем случае полная команда будет выглядеть так:

``` bash
docker-compose run --rm sf-php-cli ./bin/console debug:router
```

Как результат, мы увидим отчет о наших маршрутах:

~~~
 ------------------- -------- -------- ------ ------
  Name                Method   Scheme   Host   Path 
 ------------------- -------- -------- ------ ------
  app_default_index   ANY      ANY      ANY    /
  index               ANY      ANY      ANY    /
 ------------------- -------- -------- ------ ------

```

Мы можем также передать имя маршрута или его часть, чтобы увидель более подробные детали маршрута:

``` 
docker-compose run --rm sf-php-cli ./bin/console debug:router index
```

В результате мы получим развернутую информацию о маршруте примерно так:

```
+--------------+---------------------------------------------------------+
| Property     | Value                                                   |
+--------------+---------------------------------------------------------+
| Route Name   | index                                                   |
| Path         | /                                                       |
| Path Regex   | #^/$#sDu                                                |
| Host         | ANY                                                     |
| Host Regex   |                                                         |
| Scheme       | ANY                                                     |
| Method       | ANY                                                     |
| Requirements | NO CUSTOM                                               |
| Class        | Symfony\Component\Routing\Route                         |
| Defaults     | _controller: App\Controller\DefaultController::index    |
| Options      | compiler_class: Symfony\Component\Routing\RouteCompiler |
|              | utf8: true                                              |
+--------------+---------------------------------------------------------+
```

#### Параметры маршрута

Для определения маршрутов, в которых некоторые части являются переменными.

Например, URL для отображения некоторого сообщения в блоге, вероятно, будет включать заголовок или уникальная строка (slug), например, **/blog/my-first-post** или **/blog/all-about-symfony**.

В маршрутах Symfony переменные части заключены в фигурные скобки **{...}**

 и должны иметь уникальное имя. Например, маршрут для отображения содержимого сообщения блога определяется как 
 
 ``` 
 /blog/{slug}
 ```

Подробнее  о маршрутизации можно ознакомиться [здесь](annotations.md)

Зафиксируем изменения в **git** и пойдем дальше...

``` bash
git add .
git commit -m "Annotations is great!"
```




#### Шаблонизатор Twig

``` bash
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


..... ВЫНЕСТИ В ОТДЕЛЬНЫЙ ФАЙЛ

Немного поработаем над основным шаблоном

Во-первых, добавим в папку /public нашего проекта иконку для браузера favicon.png и добавим ее в шаблон.

Для этого в файле base.html.twig добавим строку:

```html
<link rel="icon" type="image/x-icon" href="{{ asset('favicon.ico') }}" />
```

-----------------------------


#### Профилировщик (Profiler)

Профилировщик - это мощный инструмент разработки, который дает подробную информацию о выполнении любого запроса. 

> Никогда не включайте профилировщик в производственных средах, так как это приведет к серьезным уязвимостям в вашем проекте.

Устанавливаем профилировщик следующей командой:

```bash
docker-compose run --rm sf-php-cli composer require profiler --dev
```

```
C:\Users\papahelmsman\Business\Projects\ssss>git status
On branch master
Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git checkout -- <file>..." to discard changes in working directory)

        modified:   app/composer.json
        modified:   app/composer.lock
        modified:   app/config/bundles.php
        modified:   app/symfony.lock

Untracked files:
  (use "git add <file>..." to include in what will be committed)

        app/config/packages/dev/web_profiler.yaml
        app/config/packages/test/web_profiler.yaml
        app/config/routes/dev/web_profiler.yaml

no changes added to commit (use "git add" and/or "git commit -a")

```




#### Компонент Asset

> Компонент Asset управляет созданием URL-адресов и управлением версиями веб-ресурсов, таких как таблицы стилей CSS, файлы JavaScript и файлы изображений.


#### Компонент Maker

```bash
docker-compose run --rm sf-php-cli composer require maker --dev
```




```bash
docker-compose run --rm sf-php-cli composer require asset
```

#### ORM-библиотека Doctrine

Symfony не предоставляет собственный компонент для работы с базами банных, но он обеспечивает тесную интеграцию со сторонней библиотекой под названием Doctrine.

Во-первых, установим поддержку Doctrine через пакет ORM.
 
Его работу по генерации кода также упростит MakerBundle, который мы установили ранее.

```bash
docker-compose exec sf-php-cli composer require orm-pack
```

```
On branch master
Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git checkout -- <file>..." to discard changes in working directory)

        modified:   app/.env
        modified:   app/.gitignore
        modified:   app/composer.json
        modified:   app/composer.lock
        modified:   app/config/bundles.php
        modified:   app/symfony.lock
        modified:   docker-compose.yml

Untracked files:
  (use "git add <file>..." to include in what will be committed)

        app/config/packages/doctrine.yaml
        app/config/packages/doctrine_migrations.yaml
        app/config/packages/prod/doctrine.yaml
        app/src/Entity/
        app/src/Migrations/
        app/src/Repository/

no changes added to commit (use "git add" and/or "git commit -a")

```

``` bash
git add .
git commit -m "Get started with Doctrine"
git status
```

В качестве СУБД  мы будем использовать PostgreSQL, поэтому произведем следующие настройки:

1. Откроем файл /app/config/package/doctrine.yaml

В начале файла добавим секцию:

```yaml
parameters:
    # Adds a fallback DATABASE_URL if the env var is not set.
    # This allows you to run cache:warmup even if your
    # environment variables are not available yet.
    # You should not need to change this value.
    env(DATABASE_URL): ''
    
```

а также заменим в нём секцию
```yaml
    dbal:
        # configure these for your database server
        driver: 'pdo_mysql'
        server_version: '5.7'
        charset: utf8mb4
        default_table_options:
            charset: utf8mb4
            collate: utf8mb4_unicode_ci

        url: '%env(resolve:DATABASE_URL)%'
        
```

на
```yaml
    dbal:
        # configure these for your database server
        driver: 'pdo_pgsql'
        server_version: '11.2'
        charset: utf8
        default_table_options:
            charset: utf8
            collate: ~

        url: '%env(resolve:DATABASE_URL)%'

        schema_filter: '~^(?!work_projects_tasks_seq)~'
```        

A файл **.env ** нашего приложения исправим, заменив шаблон настройки MySQL

```dotenv
DATABASE_URL=mysql://db_user:db_password@127.0.0.1:3306/db_name
```

на шаблон PostgreSQL:

``` dotenv
DATABASE_URL="pgsql://db_user:db_password@127.0.0.1:5432/db_name"
```

в котором далее исправим настройки PostgreSQL, указанные при сборке наших контейнеров :

> POSTGRES_USER: symfonist
> POSTGRES_PASSWORD: secret
> POSTGRES_DB: blog_db

На выходе получим:

``` dotenv
DATABASE_URL=pgsql://symfonist:secret@192.168.99.100:54321/blog_db
```

#### Система безопасности Symfony (Security-bundle)

Система безопасности Symfony невероятно мощная.

Мы используем Symfony-Flex, поэтому установка будет, ка обычно, проста:

``` bash
docker-compose exec sf-php-cli composer require security
```

```
git status
```

```
On branch master
Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git checkout -- <file>..." to discard changes in working directory)

        modified:   .gitignore
        modified:   composer.json
        modified:   composer.lock
        modified:   config/bundles.php
        modified:   symfony.lock

Untracked files:
  (use "git add <file>..." to include in what will be committed)

        .env.test
        bin/phpunit
        config/packages/security.yaml
        phpunit.xml.dist
        tests/

no changes added to commit (use "git add" and/or "git commit -a")

```






#### Переводы

> Термин «интернационализация» ('internationalization', часто сокращаемое до 'i18n') относится к процессу абстрагирования строк и других специфичных для локали областей нашего приложения в слой, где они могут быть переведены и преобразованы на основе локали пользователя (то есть его языка и страны). 

Устанавливаем необходимые пакета с помощью Symfony-Flex :

``` bash
docker-compose exec sf-php-cli composer require symfony/translation
```


#### Тестирование

> Всякий раз, когда вы пишете новую строку кода, вы также потенциально можете добавлять новые ошибки. Чтобы создавать лучшие и более надежные приложения, вы должны тестировать свой код, используя как функциональные, так и модульные тесты.



``` bash
docker-compose exec sf-php-cli composer require --dev symfony/phpunit-bridge
```

``` 
git status
```


```
On branch master
Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git checkout -- <file>..." to discard changes in working directory)

        modified:   .gitignore
        modified:   composer.json
        modified:   composer.lock
        modified:   symfony.lock

Untracked files:
  (use "git add <file>..." to include in what will be committed)

        .env.test
        bin/phpunit
        phpunit.xml.dist
        tests/

no changes added to commit (use "git add" and/or "git commit -a")

```


```
git add .
git commit -m "Adding Security System to our Blog"
```




#### Отправка сообщений

> Symfony предоставляет функцию почтовой программы на основе популярной библиотеки Swift Mailer через SwiftMailerBundle. 
> Эта почтовая программа поддерживает отправку сообщений с ваших собственных почтовых серверов.

Однако мы будем использовать экспериментальный компонент Mailer от Symfony.

Для начала установим его:

``` bash
composer req symfony/mailer
```

Посмотрим на изменения в нашем проекте:

``` bash
git status
```

```
On branch master
Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git checkout -- <file>..." to discard changes in working directory)

        modified:   app/.env
        modified:   app/composer.json
        modified:   app/composer.lock
        modified:   app/symfony.lock

Untracked files:
  (use "git add <file>..." to include in what will be committed)

        app/config/packages/mailer.yaml

no changes added to commit (use "git add" and/or "git commit -a")

C:\Users\papahelmsman\Business\Projects\ssss>

```









## Разработка



Создадим контроллер  BlogController с помощью утилиты **make**

```
docker-compose exec sf-php-cli ./bin/console make:controller BlogController
```

В результате мы получим два сгенерированных файла:
- файл контрроллера **//app/src/Controller/BlogController.php**
- файл шаблона для соержимого ответа **//app/templates/blog/index.html.twig**

Из файла **index.html.twig** видно, что он наследует базовый шаблон **base.html.twig**

Давайте немного поработаем над ним.

Но прежде, чем начать эту работу, добавим в наш проект **Webpack-Encore** - можный инструмент для сброки CSS, JS и  некоторых других эелементов нашего проекта.

Выполним установку следующей командой:

```
docker-compose exec sf-php-cli compose req encore
```

Посмотрим, что данная установка добавила в наш проект

```
git status
```


```
On branch master
Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git checkout -- <file>..." to discard changes in working directory)

        modified:   app/.gitignore
        modified:   app/composer.json
        modified:   app/composer.lock
        modified:   app/config/bundles.php
        modified:   app/symfony.lock

Untracked files:
  (use "git add <file>..." to include in what will be committed)

        app/assets/
        app/config/packages/assets.yaml
        app/config/packages/prod/webpack_encore.yaml
        app/config/packages/webpack_encore.yaml
        app/package.json
        app/webpack.config.js

no changes added to commit (use "git add" and/or "git commit -a")

```

Заглянув в файл **/app/package.json**, мы увидим некоторые зависимости, указанные по умолчанию для нашей дальнейшей разработки.

Эти пакеты установятся в наш проект в каталог **/app/node_modules** после перехода в терминале в директорию **/app** и выполнения команды **yarn** 

Файл **.gitignore** поолнился  секцией настройки **Webpack-Encore** с указанием неотслеживаемых файлов.

Теперь нас интересует каталог **assets**, расположенный в корне нашего приложения **app**.

Сюда мы будем складывать все файлы стилей, скрипты, изображения, шрифты.

Здесь же мы будем "подтягивать" к нашему проекту различные фреймворки и библиотеки, такие как jQuery, Bootstrap и многое другое.

С помощью инструментов Webpack-Encore мв будем собирать и оптимизировать файлы, необходимые в нашем проекте, после чего будем помещать их в каталог **/public/build** нашего приложения.

Эти настроойки необходимо выполнить в файле **/app/webpack.config.js**.

``` js
var Encore = require('@symfony/webpack-encore');

// Manually configure the runtime environment if not already configured yet by the "encore" command.
// It's useful when you use tools that rely on webpack.config.js file.
if (!Encore.isRuntimeEnvironmentConfigured()) {
    Encore.configureRuntimeEnvironment(process.env.NODE_ENV || 'dev');
}

Encore
    // directory where compiled assets will be stored
    .setOutputPath('public/build/')
    // public path used by the web server to access the output path
    .setPublicPath('/build')
    // only needed for CDN's or sub-directory deploy
    //.setManifestKeyPrefix('build/')

    /*
     * ENTRY CONFIG
     *
     * Add 1 entry for each "page" of your app
     * (including one that's included on every page - e.g. "app")
     *
     * Each entry will result in one JavaScript file (e.g. app.js)
     * and one CSS file (e.g. app.css) if your JavaScript imports CSS.
     */
    .addEntry('app', './assets/js/app.js')
    //.addEntry('page1', './assets/js/page1.js')
    //.addEntry('page2', './assets/js/page2.js')

    // When enabled, Webpack "splits" your files into smaller pieces for greater optimization.
    .splitEntryChunks()

    // will require an extra script tag for runtime.js
    // but, you probably want this, unless you're building a single-page app
    .enableSingleRuntimeChunk()

    /*
     * FEATURE CONFIG
     *
     * Enable & configure other features below. For a full
     * list of features, see:
     * https://symfony.com/doc/current/frontend.html#adding-more-features
     */
    .cleanupOutputBeforeBuild()
    .enableBuildNotifications()
    .enableSourceMaps(!Encore.isProduction())
    // enables hashed filenames (e.g. app.abc123.css)
    .enableVersioning(Encore.isProduction())

    // enables @babel/preset-env polyfills
    .configureBabel(() => {}, {
        useBuiltIns: 'usage',
        corejs: 3
    })

    // enables Sass/SCSS support
    //.enableSassLoader()

    // uncomment if you use TypeScript
    //.enableTypeScriptLoader()

    // uncomment to get integrity="..." attributes on your script & link tags
    // requires WebpackEncoreBundle 1.4 or higher
    //.enableIntegrityHashes(Encore.isProduction())

    // uncomment if you're having problems with a jQuery plugin
    //.autoProvidejQuery()

    // uncomment if you use API Platform Admin (composer req api-admin)
    //.enableReactPreset()
    //.addEntry('admin', './assets/js/admin.js')
;

module.exports = Encore.getWebpackConfig();
```

Закомментируем строку:

```
.enableSingleRuntimeChunk()
```

и добавим вместо неё:

```
.disableSingleRuntimeChunk()
```

Попробуем выполнить команду:

```
yarn encore dev
```

После успешного ее выполнения мы увидим новый каталог **//app/public/build/** с файлами стилей и скриптов, которые мы подключаем к базовому шаблону **base.html.twig**.

Подключаем стили. Вместо ...

``` twig
{% block stylesheets %}{% endblock %}
```

... получаем:

``` twig
{% block stylesheets %}
    {{ encore_entry_link_tags('app') }}
{% endblock %}
```

Подключаем скрипты. Вместо ...

``` twig
{% block javascripts %}{% endblock %}
```

... получаем:

``` twig
{% block javascripts %}
    {{ encore_entry_script_tags('app') }}
{% endblock %}
```

В результате после перезагрузки страницы 

``` http request 
http://sf4blog.dockerhost/blog
```

мы заметим изменение фона страницы на цвет указанный нами в файле **//app/assets/css/app.css**

~~~ css
body {
    background-color: lightgray;
}
~~~

```
yarn add sass-loader@^7.0.1 node-sass --dev
```

Откроем файл **webpack.config.js** и раскомментируем строку:

``` js
.enableSassLoader()
```





Итак, возьмём наш базовый шаблон **base.html.twig**

Добавим мета-тэг **viewort** 

```
<meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
```



Добавим в него обшую для всего проекта иконку для закладок браузера **favicon.ico**

```

```



```
require('../css/app.css');
```


```
import('../scss/app.scss');
```


```
yarn add bootstrap --dev
```

```
yarn add holderjs --dev
```

```
yarn add popper.js --dev
```



```
yarn add jquery --dev
```



Для определения наших собственных переменных и переопределения переменных bootstrap оздадим файл **//app/assets/scss/helper/_variables.scss**

Добавим в него первые переменные:

```
$info: darken(#17a2b8, 10%);
$logo-color: #4056ff;
```




```
yarn add font-awesome --dev
```


#### Header and Footer

Импорт шапки и подвала сайта




