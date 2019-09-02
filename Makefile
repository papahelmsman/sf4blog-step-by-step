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

sf-sec-check:
	docker-compose run --rm sf-php-cli ./bin/console security:check

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
