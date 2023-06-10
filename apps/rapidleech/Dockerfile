FROM php:apache

RUN apt-get update && \
    apt-get install -y python3-pip libnet1 libnet1-dev libpcap0.8 libpcap0.8-dev git wget && \
    git clone https://github.com/Th3-822/rapidleech.git ./ && \
    apt-get -y purge \
        git \
        wget

# Avoid port 80 because we don't want to run as root
# Another option might be https://takac.dev/docker-run-apache-as-non-root-user-based-on-the-official-image/
RUN sed -i "s/Listen 80/Listen ${PORT:-8080}/g" /etc/apache2/ports.conf

ADD https://raw.githubusercontent.com/wpzzz/docker-rapidleech/master/config.php configs/ 

RUN chmod 777 -R files
RUN chmod 755 -R configs

COPY ./ /var/www/html

# Create a symlink to where files.lst will end up
RUN mkdir /config && mv /var/www/html/configs/files.lst /config/ && ln -s /config/files.lst /var/www/html/configs/files.lst

USER www-data

EXPOSE  8080