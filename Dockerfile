FROM ubuntu

RUN apt-get -y update
RUN apt-get -y install build-essential zlib1g-dev libssl-dev \
    libyaml-dev wget openssl git libreadline-dev libgdbm-dev \
    wget libpq-dev libpq5 libpqxx-4.0 mysql-client \
    libpqxx-dev memcached nodejs nodejs-dev redis-server libxml2 libsasl2-2 \
    libxslt-dev libxml2-dev libgmp-dev libgmp3-dev libgmp10 libmysql++-dev \
    libmysqlclient-dev libmysqld-dev librtmp-dev \
    postgresql-client postgresql-client-common git

RUN cd /tmp && \
    wget http://ftp.ruby-lang.org/pub/ruby/2.2/ruby-2.2.4.tar.gz && \
    tar -xvzf ruby-2.2.4.tar.gz && \
    cd ruby-2.2.4/ && \
    ./configure --with-openssl-dir=/usr/bin && \
    make && \
    make install

ADD . /app
WORKDIR /app

ENV REDISTOGO_URL=${REDISTOGO_URL:-redis://redis:6379}
ENV BEACONCONTROL_MYSQL_HOST=${BEACONCONTROL_MYSQL_HOST:-mysql}
ENV BEACONCONTROL_MYSQL_PORT=${BEACONCONTROL_MYSQL_PORT:-3306}
ENV BEACONCONTROL_MYSQL_USERNAME=${BEACONCONTROL_MYSQL_USERNAME:-root}
ENV BEACONCONTROL_MYSQL_PASSWORD=${BEACONCONTROL_MYSQL_PASSWORD:-pass}
ENV SEED_ADMIN_EMAIL=${SEED_ADMIN_EMAIL:-admin@gmail.com}
ENV SEED_ADMIN_PASSWORD=${SEED_ADMIN_PASSWORD:-test123}

RUN cd /app && gem install bundler && bundle install

ENTRYPOINT rake db:create && rake db:migrate && rake db:seed && rails s -b 0.0.0.0
