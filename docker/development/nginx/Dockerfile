FROM nginx:1.17.2-alpine

LABEL maintainer="Pavel A. Petrovv <papahelmsman@gmail.com>"

COPY nginx.conf /etc/nginx/nginx.conf
COPY conf.d/sf4d.conf /etc/nginx/conf.d/sf4d.conf
RUN rm /etc/nginx/conf.d/default.conf

WORKDIR /app