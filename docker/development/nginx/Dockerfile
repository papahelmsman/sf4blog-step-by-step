FROM nginx:latest

LABEL maintainer="Pavel A. Petrov <papahelmsman@gmail.com>"

COPY nginx.conf /etc/nginx/nginx.conf
COPY conf.d/symfony.conf /etc/nginx/conf.d/symfony.conf
RUN rm /etc/nginx/conf.d/default.conf

WORKDIR /usr/src/app/public
